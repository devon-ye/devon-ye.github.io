---
title:       "如何设计低延迟、高可用、高并发的交易服务技术方案"
description: "基于Disruptor、kafka、canal、mysql、zookeeper、spring-boot技术栈实现低延迟、高并发写、高可用的、交易服务状态机架构模式系统"
date:        2024-03-01
author:      "Devean"
image:       ""
math: true
categories:  ["Tech" ]
thumbnail: "/img/blog/QPTrade1.png"
tags:        ["系统设计"]

keywords: ["低延迟","高并发","高可用","系统设计"]
---

# 承兑服务技术方案要点


> 

## 需求背景
+ **现状：** BTC、ETH简选期权只能以BTC或ETH下单，而不能以稳定币USDT下单。

### 功能需求
+ 用户以USDT稳定币直接下单开仓期权。
+ 期权平仓后将BTC、ETH直接兑换为USDT划入用户账户。
### 非功能性需求
 + 低延迟(依赖交易服务市场撮合、故延迟越高、行情变化可能导致系统账户产生资损)
 + 高可用 (即服务不可宕机、升级发布尽可能不停机，重启部署可自动完全恢复)
 + 高并发（即交易行情到来时、多用户并发操作、用户间是并发的，不能排队处理）

## 业务流程
1. 用户在页面操作简选期权下单以USDT下单模式下单BTC简选期权。
2. 柜台报价接口传入BTC期权张数，柜台服务加上价差后调用资金账户返回所需USDT数量。
3. 用户下单BTC开仓期权张数,柜台以资金账户报价、扣除用户账户USDT,给用户开仓BTC简选期权，用户端开仓成功。
4. 服务端，柜台将BTC期权开仓订单记录以异步的方式同步给承兑服务、承兑服务完成后续的交易服务平账操作。
   + i. 承兑服务调用柜台服务接口完成换币系统账户加USDT、减BTC的操作。
   + ii. 承兑服务调用资金服务完成系统账户到资金账户的USDT划转。
   + iii. 承兑服务调用交易服务接口完成USDT换BTC的操作。
   + iv. 承兑服服务调用资金账户将换回的BTC划转值系统账户。
## 技术难点

1. 从柜台服务库夸系统低延迟交易订单同步至承兑服务后**不丢**、**不重**，Canal、Kafka**中间件集群异常需要容错处理。**
2. 柜台服务从用户账户完成减USDT、开仓BTC期权动作后,完成用户端交互。而承兑服务需要在极低延迟时间内需要完成后续平账的操作，因换币依赖于市场行情，延迟越高存在差价滑点的概率越高。
3. 承兑服务要完成平账操作,保证以下4次接口调用顺序性依赖、且多用户执行时多用户间并发性。
    + i. 承兑服务调用柜台服务接口完成换币系统账户加USDT、减BTC的操作。
    + ii. 承兑服务调用资金服务完成系统账户到资金账户的USDT划转。
    + iii. 承兑服务调用交易服务接口完成USDT换BTC的操作。
    + iv. 承兑服服务调用资金账户将换回的BTC划转值系统账户。
4. 服务迭代或异常重启部署、中间态的订单依旧可恢复完成剩余步骤，完成换币动作。
5. 为了避免正常停机导致订单延迟过高产生资损,服务升级需要不停机。

## 解决方案

### 柜台服务到承兑服务订单低延迟、高可用同步
1.  柜台服务加同步订单表、配置canal表同步，将该表同步写入kafka 
2.  承兑服务消费topic后解析Binlog、过滤非换币订单、将订单写入承兑服务同步订单表，以订单唯一id幂等校验。
3.  承兑服务入库后提交offset。随后将该订单放入Disruptor内存队列。
4.  服务启动后会启动定时任务，加载当前订单表每个shard最后一条记录的毫秒级时间戳、缓存每个分片的最后一条记录的时间戳。Map<shardId,timestamp>。
5.  新消费订单记录写入Disruptor内存队列后，会将该记录的时间戳与缓存的时间戳比较，如果大于缓存的时间戳，更新缓存的时间戳。
6.  定时任务每隔3秒检查一次，去查询柜台服务同步订单表,是否存在延迟或未同步订单直接以接口拉取最新为同步订单

### 状态机架构模式换成低延迟、高并发、高可靠平账流程


1. 实现四个顺序依赖的接口完全异步、多线程并发执行，即基于Disruptor的EventHandler、WorkHandler两个接口实现多线程异步执行。
+ 配置多层多步线程
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
+ 顺序依赖并发处理
```java

public class StepOneHandler implements EventHandler<EventWrapper>, WorkHandler<EventWrapper> {

   private RingBuffer<EventWrapper<BizEvent>> stepTwoRingBuffer;

   @Override
   public void onEvent(EventWrapper eventWrapper) throws Exception {

      //TODO BUSSINESS
       
      //  TODO call thirtyPartyService
      
      stepTwoRingBuffer.publishEvent((event, sequence, arg0) -> event.setEvent(arg0), eventWrapper.getEvent());
   }

   @Override
   public void onEvent(EventWrapper eventWrapper, long l, boolean b) throws Exception {
      this.onEvent(eventWrapper);
   }
}
```

2.基于库表存储持久化每一步状态，保证服务重启后可恢复执行剩余步骤。



### 容错处理

+ 重启恢复处理
   
  + 服务重启后，异常恢复任务会加载状态表中处于中间态的记录，并将其放入Disruptor内存队列，接着执行剩余步骤。

+  三方服务异常处理

  + 当三方接口调用异常，将异常结果写入状态表，根据返回错误码，区分是可重试或不可重试的错误,写入状态表，定时任务会定时检查状态表中的异常记录，根据错误码进行多次重试或人工介入处理。

+ 中间件异常处理
   + Canal、Kafka集群异常，订单无法实时同步至承兑服务时，外部异常补偿任务会扫描交易服务的订单表，将未同步的订单重新同步至承兑服务。


### 主备切换

   基于zookeeper的主备切换，保证服务不可宕机，升级发不停机，重启部署可自动完全恢复。
1. 服务启动时，注册临时节点至zookeeper，给父节点注册监听事件，监听子节点的删除事件。
2. 当触发子节点监听事件，即服务宕机，zookeeper会将服务的临时节点删除，触发父节点的监听事件，父节点会重新选举新的主备节点，更新主备机器、服务的状态。





