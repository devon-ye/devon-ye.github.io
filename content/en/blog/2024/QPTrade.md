---
title:       "Low-Latency, High-Availability, High-Concurrency Trading Service Technical Solution"
description: "This article discusses the technical solution for a trading service with low latency, high availability, and high concurrency, covering requirements, functional and non-functional requirements, core business processes, technical challenges, solutions, and core logic implementation using Canal, Kafka for low latency and low coupling, Disruptor for high concurrency, and Zookeeper for high availability."
date:        2024-03-01
author:      "Devean"
image:       ""
math: true
categories:  ["Tech"]
thumbnail: "/img/blog/QPTrade1.webp"
tags:        ["System Design"]
keywords:    ["Low Latency", "High Concurrency", "High Availability", "System Design"]
---

## Background
+ **Current Situation:** BTC and ETH simple option orders can only be placed with BTC or ETH, not with the stablecoin USDT.

### Functional Requirements
+ Users can directly place option orders using USDT stablecoin.
+ After closing options, BTC and ETH are directly exchanged for USDT and transferred to the user's account.

### Non-Functional Requirements
+ Low latency (dependence on market matching of trading services, higher latency may result in capital loss due to market changes)
+ High availability (service should not be down, upgrade and release should minimize downtime, and automatic complete recovery should be possible after restart)
+ High concurrency (when trading market data arrives, multiple users operate concurrently, and users are concurrent, no queuing for processing)

## Business Process
1. Users place option orders in USDT mode for BTC simple options.
2. Counter quote interface enters the number of BTC options, the counter service adds the spread and calls the fund account to return the required amount of USDT.
3. Users place orders for BTC opening option contracts, the counter quotes with fund account quotes, deducts USDT from the user account, and opens BTC simple option contracts for users, and the user end opens successfully.
4. On the server side, the counter asynchronously synchronizes the BTC option opening orders to the acceptance service.
    + i. Acceptance service calls the counter service interface to complete the system account's addition of USDT and subtraction of BTC.
    + ii. Acceptance service calls the fund service to complete the system account to fund account USDT transfer.
    + iii. Acceptance service calls the trading service interface to complete the USDT to BTC exchange.
    + iv. Acceptance service calls the fund account to transfer the exchanged BTC back to the system account.

## Technical Challenges

1. Synchronize orders from the counter service library across systems to the acceptance service with low latency and high availability, Canal, Kafka middleware cluster exceptions need fault tolerance processing.
2. After the counter service completes the deduction of USDT from the user account and opens the BTC option contract action, the acceptance service needs to complete the subsequent clearing operation within an extremely low latency time. Due to currency exchange depending on market conditions, the higher the latency, the higher the probability of slippage.
3. The acceptance service needs to complete the clearing operation, ensuring the sequential dependence of the four interface calls and concurrency between multiple users.
    + i. The acceptance service calls the counter service interface to complete the system account's addition of USDT and subtraction of BTC.
    + ii. The acceptance service calls the fund service to complete the system account to fund account USDT transfer.
    + iii. The acceptance service calls the trading service interface to complete the USDT to BTC exchange.
    + iv. The acceptance service calls the fund account to transfer the exchanged BTC back to the system account.
4. Service iteration or abnormal restart deployment, orders in the intermediate state can still be recovered to complete the remaining steps and complete the currency exchange action.
5. To avoid excessive delay in normal shutdowns leading to capital losses, service upgrades need to be non-stop.

## Solutions

### Low-Latency, High-Availability Order Synchronization from Counter Service to Acceptance Service
1. The counter service adds synchronization order tables and configures Canal table synchronization, writing the table to Kafka.
2. The acceptance service consumes the topic, parses Binlog, filters non-exchange orders, writes orders to the acceptance service synchronization order table, and performs idempotent verification of the unique order id.
3. After the acceptance service is inserted into the database, it submits the offset. Then the order is placed in the Disruptor memory queue.
4. After the service starts, it will start a scheduled task to load the millisecond-level timestamp of the last record of each shard in the current order table, and cache the last timestamp of each shard. Map<shardId, timestamp>.
5. After a new order record is written to the Disruptor memory queue, the timestamp of the record is compared with the cached timestamp. If it is greater than the cached timestamp, the cached timestamp is updated.
6. The scheduled task checks every 3 seconds, querying whether there are delayed or unsynchronized orders in the counter service synchronization order table, and directly pulls the latest orders as synchronized orders via the interface.

### State Machine Architecture Pattern for Low-Latency, High-Concurrency, High-Reliability Clearing Process

1. Implement four dependent interfaces asynchronously and execute them in multiple threads, that is, implementing multi-thread asynchronous execution based on the Disruptor's EventHandler and WorkHandler interfaces.
+ Configure multi-level and multi-step threads.
```java
@Configuration
public class DisruptorAutoConfiguration {

   @Autowired
   private BizExceptionHandler bizExceptionHandler;
   public final Integer RING_BUFFER_SIZE = 1024 * 2;
   public final Integer CORE_SIZE = Runtime.getRuntime().availableProcessors();

   @Bean("steptOneRingBuffer")
   public RingBuffer<EventWrapper<BizEvent>> createStepOneRingBuffer(StepOneHandler stepOneHandler) {
      Disruptor<EventWrapper<BizEvent>> disruptor = createDisruptor((WorkHandler<EventWrapper<BizEvent>>) stepOneHandler, "stepOneHandler");
      return disruptor.getRingBuffer();
   }
   
   @Bean("stepTwoRingBuffer")
   public RingBuffer<EventWrapper<BizEvent>> createStepTwoRingBuffer(StepTwoHandler stepTwoHandler) {
      Disruptor<EventWrapper<BizEvent>> disruptor = createDisruptor(stepTwoHandler, "stepTwoHandler");
      return disruptor.getRingBuffer();
   }
   
   private Disruptor<EventWrapper<BizEvent>> createDisruptor(WorkHandler<EventWrapper<BizEvent>> workHandler, String workPrefix) {
      WorkHandler<EventWrapper<BizEvent>>[] workHandlers = new WorkHandler[CORE_SIZE];
      Arrays.fill(workHandlers, workHandler);
      Disruptor<EventWrapper<BizEvent>> disruptor = new Disruptor<>(EventWrapper::new, RING_BUFFER_SIZE, new DefaultThreadFactory(workPrefix), ProducerType.MULTI, new BlockingWaitStrategy());
      disruptor.handleEventsWithWorkerPool(workHandlers);
      disruptor.setDefaultExceptionHandler(bizExceptionHandler);
      disruptor.start();
      return disruptor;
   }
}
```
+ Sequential dependency concurrency processing

```java

public class StepOneHandler implements EventHandler<EventWrapper>, WorkHandler<EventWrapper> {

   private RingBuffer<EventWrapper<BizEvent>> stepTwoRingBuffer;

   @Override
   public void onEvent(EventWrapper eventWrapper) throws Exception {

       //TODO BUSINESS
      //  TODO call thirtyPartyService
      stepTwoRingBuffer.publishEvent((event, sequence, arg0) -> event.setEvent(arg0), eventWrapper.getEvent());
   }

   @Override
   public void onEvent(EventWrapper eventWrapper, long l, boolean b) throws Exception {
      this.onEvent(eventWrapper);
   }
}
```



### Persisting State and Fault Tolerance Handling

#### Restart Recovery Processing

After the service restarts, an exception recovery task loads records in the intermediate state from the status table and inserts them into the Disruptor memory queue. Then, it proceeds to execute the remaining steps.

#### Third-Party Service Exception Handling

In the event of an abnormal third-party interface call, the exception result is written to the status table. Depending on the return error code, the system distinguishes between retryable and non-retryable errors. These details are also written to the status table. A scheduled task regularly checks for abnormal records in the status table and initiates multiple retries or manual intervention based on the error code.

#### Middleware Exception Handling

If the Canal or Kafka cluster experiences abnormalities, causing orders to fail to synchronize with the acceptance service in real-time, an external exception compensation task scans the trading service order table to resynchronize unsynchronized orders with the acceptance service.

### Master-Slave Switching

Utilizing Zookeeper's master-slave switching mechanism ensures continuous service availability during upgrades and restart deployments.

- Upon service startup, a temporary node is registered with Zookeeper. A listener event is registered for the parent node, listening for the deletion event of the child node.
- When the child node deletion event occurs, indicating service downtime, Zookeeper deletes the temporary node associated with the service. This triggers the parent node's listening event, prompting it to re-elect a new master-slave node, update the master-slave machine, and update the service status.


[ProcessOn Graph](https://www.processon.com/view/65e17ac82fedec13cb3d998e#pc)
