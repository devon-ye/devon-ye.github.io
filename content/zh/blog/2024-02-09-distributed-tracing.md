---
title:       "全链路追踪"
description: "Tracing 核心概念、java进程内、进程间实现方法"
date:        2024-02-09
author:      "Devean"
tags:        ["Tracing","Architecture "]
categories:  ["Tech" ]
math: true
thumbnail: "/img/blog/tracing2.png"
keywords: ["分布式追踪","分布式架构","Tracing"]
---


# 分布式追踪
## 什么是分布式追踪？

分布式追踪也叫分布式请求跟踪，是一种针对分布式服务概要分析和监控的方法，特别对于故障发生未知及性能下降原因
### 核心概念

+ `traceId`:标识一次用户请求生成的唯一ID
+ `spanId`:标识本次调用在调用链中的位置


![](/img/blog/tracing1.png)

![](/img/blog/tracing2.png)

## 为什么需要分布式追踪？
随着业务量增长，单体服务已经无法满足需求，因此SOA服务化和微服务，且每个服务多实例部署，导致排查故障及性能问题的难度加大

## 我们能用分布式追踪能做什么？
+  故障定位
+  跨系统全链路日志聚合
+  跨系统全链路性能分析
+  服务依赖拓扑图查看

## 分布式追踪的实现原理
夸线程:ThreadLocal传递traceId等信息
跨进程:通过封装RPC、HTTP、MQ 协议的header传递traceId等信息

## 实现方法:
业界中间件SDK封装，在需要的地方手动处理
编译器字节码插装
好处:业务无感知，开箱即用

### GlobalTracing


  ```java
 public class GlobalTracing {

    private static final ThreadLocal<String> TRACE_ID_LOCAL = new ThreadLocal<>();
    public static final String TRACE_ID = "trace_id";


    private GlobalTracing() {
    }


    public static void setTraceId(String traceId) {
        TRACE_ID_LOCAL.set(traceId);
        LogUtils.setTraceId(traceId);
    }

    public static String getTraceId() {
        return TRACE_ID_LOCAL.get();
    }

    public static void remove() {
        TRACE_ID_LOCAL.remove();
    }
}
```
### 跨进程

#### Grpc Client

 ```java
public class TracingClientInterceptor implements ClientInterceptor {
    private static final Metadata.Key<String> TRACE_ID_KEY = Metadata.Key.of(GlobalTracing.TRACE_ID, Metadata.ASCII_STRING_MARSHALLER);

    @Override
    public <ReqT, RespT> ForwardingClientCall.SimpleForwardingClientCall interceptCall(MethodDescriptor<ReqT, RespT> methodDescriptor, CallOptions callOptions, Channel channel) {

        return new ForwardingClientCall.SimpleForwardingClientCall(channel.newCall(methodDescriptor, callOptions)) {
            @Override
            protected ClientCall delegate() {
                return super.delegate();
            }

            @Override
            public void start(Listener responseListener, Metadata headers) {
                String traceId = GlobalTracing.getTraceId();
                if (traceId != null) {
                    headers.put(TRACE_ID_KEY, traceId);
                }
                super.start(responseListener, headers);
            }
       }
}
```

#### Grpc Server

```java

public class TracingServerInterceptor implements ServerInterceptor {
    private static final Metadata.Key<String> TRACE_ID_KEY = Metadata.Key.of(GlobalTracing.TRACE_ID, Metadata.ASCII_STRING_MARSHALLER);

    @Override
    public <ReqT, RespT> ServerCall.Listener<ReqT> interceptCall(ServerCall<ReqT, RespT> serverCall, Metadata header, ServerCallHandler<ReqT, RespT> serverCallHandler) {
        Set<String> keys = header.keys();
        for (String key : keys) {
            if (GlobalTracing.TRACE_ID.equals(key)) {
                String traceId = header.get(TRACE_ID_KEY);
                header.removeAll(TRACE_ID_KEY);
                GlobalTracing.setTraceId(traceId);
                break;
            }
        }
        return new TracingForwardingServerCallListener(serverCallHandler.startCall(serverCall, header), serverCall.getMethodDescriptor());
    }
}
```

#### Feign

```java
public class FeignTraceInterceptor implements RequestInterceptor {

    @Override
    public void apply(RequestTemplate template) {
        String traceId = TraceContext.getTraceId();
        if (traceId != null) {
            MDC.put(TraceContext.LOG_PATTER_TRACE_ID, traceId);
            template.header(TraceContext.TRACE_ID_KEY, traceId);
        }
    }
}
```

###

```java
public class TraceHystrixConcurrencyStrategy extends HystrixConcurrencyStrategy {
    private static final Logger LOG = LoggerFactory.getLogger(TraceHystrixConcurrencyStrategy.class);


    public TraceHystrixConcurrencyStrategy() {
        LOG.info("TraceHystrixConcurrencyStrategy init!");
    }

    @Override
    public <T> Callable<T> wrapCallable(Callable<T> callable) {
        return new CallableDecorator<>(callable);
    }
}

```

### 进程内跨线程

#### Runnnable接口代理封装

```java

    public class RunnableWrapper implements Runnable {
    final Runnable runnable;
    final String traceId;


    public RunnableWrapper(Runnable runnable) {
        this.traceId = GlobalTracing.getTraceId();
        this.runnable = runnable;
    }

    @Override
    public void run() {
        if (this.traceId != null) {
            GlobalTracing.setTraceId(this.traceId);
            this.runnable.run();
        } else {
            this.runnable.run();
        }
    }
}

```

#### ExcutorService代理封装

```java


public class TracingExecutorServiceImpl implements ExecutorService {

    private ExecutorService executorService;


    public TracingExecutorServiceImpl(ExecutorService executorService) {
        this.executorService = executorService;
    }

    @Override
    public <T> Future<T> submit(Callable<T> task) {
        return executorService.submit(new CallableWrapper<>(task));
    }

    @Override
    public <T> Future<T> submit(Runnable task, T result) {
        return executorService.submit(new RunnableWrapper(task), result);
    }
}
```
#### 代理ExecutorService

```java

public final class ConcurrentUtils {

    public static final ExecutorService EXECUTOR = new TracingExecutorServiceImpl(Executors.newFixedThreadPool(96, new BasicThreadFactory.Builder()
            .namingPattern("utils-execute-%d")
            .uncaughtExceptionHandler((t, e) -> log.error("execute runnable failed: ", e))
            .build()));
    
```
#### Spring的TaskDecorator的实现
```java
public class TraceTaskDecorator implements TaskDecorator {
    @Override
    public Runnable decorate(Runnable runnable) {
        return new RunnableWrapper(runnable);
    }
}
```



    
    

 

