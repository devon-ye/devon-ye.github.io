---
title:       "并发与多线程"
description: "本文java线程状态、锁、线程池、线程安全模型、并发数据结构、应用场景等角度解读并发与多线程"
date:        2019-09-17
author:      "Devean"
image:       ""
tags: ["系统设计"]
math: true
categories:  ["Tech" ]
thumbnail: "/img/blog/multi-thread.png"

keywords: ["并发","多线程","线程安全","系统设计"]
---


## 1 常见概念

### 1.1 操作系统线程运行状态

        
        NEW
        RUNNABLE
        RUNNING
        BLOCKED

### 1.2 Java虚拟机线程实际运行状态
```java
         public enum State {
                NEW
                    尚未开始的线程处于此状态，即刚创建线程对象，未调用start()方法
      
                RUNNABLE
                    新建线程调用start()方法后，在Java虚拟机中执行的线程处于此状态，但它可能正在等待来自操作系统的其他资源（如处理器）。
                          
                BLOCKED
                    处于阻塞状态的线程正在等待监视器锁定进入同步块或同步方法，或者重入锁进入同步块或同步方法
                 后调用Object.wait()方法
  
                WAITING
                     由于调用以下方法之一，线程处于等待状态
                        Object.wait(); 无超时
                        Thread.join(); 无超时
                        LockSupport.park();
                     例如，a.在对象上调用Object.wait（）的线程正在等待另一个线程调用Object.notify（）或Object.notifyAll（）在该对象。
                          b.一个名为Thread.join（的线程正在等待指定的线程终止。
                              
                TIMED_WAITING
                      由于调用一个线程，线程处于定时等待状态,使线程处于定时等待状态可调用方法如下：
                         Thread.sleep(long);
                         Object.wait(long)
                         Thread.join(long);
                         LockSupport.parkNanos(long);
                         LockSupport.parkUntil(long);

                TERMINATED
                    终止线程的线程状态。 即线程已完成当前任务的执行。
         }
         ```
### 1.3 重入锁

#### 概念：
        一个线程试图获得它自己持有的锁，那么这个请求就会成功
#### 实现原理：
       1.为每个锁绑定所有者和计数值,每重入一次该计数值自增1，而当线程每退出一次计数值递减，直到计数值为零才释放锁。
#### 常用实现
       
        
### 1.4 sychroinzed
####     概述：
    在JDK1.6之前被称为重量级锁，然后在JDK1.6中为了减少获得和释放锁所带来的性能消耗引入了偏量锁和轻量级锁
      
####      实现原理：
        互斥同步原理，JVM规范中都是给予进入和对出Monitor对象来实现方法同步和代码块同步的，但两者的实现细节不同:
        代码块同步是使用monitorenter和monitorexit指令实现的
####  使用分类

   * 按目标分类：类锁和对象锁
    
   * 按范围分类：方法和代码块
   
####      使用形式：
            
#####     普通方法+syncronized
   锁是当前实例对象
            
```java  

    public  class InstanceObjectSyncronizedTest{
         private Integer  num = 5;
           
         public syncronized Integer getNum(){
                num++
                return num;
         }
    }
    
```    




#####            静态方法+syncronized
锁是当前类的Class对象

```java

    public  class InstanceObjectSyncronizedTest{
          private static Integer  num = 5;
          
          public static synchronized  void IntegergetNum() {
                  ++num; 
          }
    }
    
```






#####     方法块+syncronized(Object.Class)
   锁是当前类的Class对象
```java


@ThreadSafe
public class DoubleCheckLazySingleton {

   private static volatile DoubleCheckLazySingleton instance;

   public DoubleCheckLazySingleton getInstance(){
   	    if(instance == null){
   	    	synchronized (DoubleCheckLazySingleton.class){
   	    		if(instance == null){
   	    			instance = new DoubleCheckLazySingleton();
				}
			}
		}
   	    return instance;
   }

   DoubleCheckLazySingleton(){}

}

```
            

 ### 1.5 lock接口及实现
 
 ### 1.6 volatile
    volatile是轻量级的sncronized的实现，只修饰变量，多线程访问不会发生阻塞，但volatile不具备原子性，功能使变量在多线程间可见。
   * 使用方式：
    
          1）确保自身状态的可见性
          2）确保他们所引用的对象的可见性
   * 应用场景：
   
          1）标记循环控制状态，检查状态来判断是否退出循环
          2）单线程写,多线程读
### 1.7 线程池
   * 拒绝策略
   
     重试策略
```java   
         public static class CallerRunsPolicy implements RejectedExecutionHandler {
            /**
             * Creates a {@code CallerRunsPolicy}.
             */
            public CallerRunsPolicy() { }
    
            /**
             * Executes task r in the caller's thread, unless the executor
             * has been shut down, in which case the task is discarded.
             *
             * @param r the runnable task requested to be executed
             * @param e the executor attempting to execute this task
             */
            public void rejectedExecution(Runnable r, ThreadPoolExecutor e) {
                if (!e.isShutdown()) {
                    r.run();
                }
            }
         }
 ```   
     异常抛出策略
```java         
         /**
         * A handler for rejected tasks that throws a
         * {@code RejectedExecutionException}.
         */
          public static class AbortPolicy implements RejectedExecutionHandler {
            /**
             * Creates an {@code AbortPolicy}.
             */
            public AbortPolicy() { }
    
            /**
             * Always throws RejectedExecutionException.
             *
             * @param r the runnable task requested to be executed
             * @param e the executor attempting to execute this task
             * @throws RejectedExecutionException always
             */
            public void rejectedExecution(Runnable r, ThreadPoolExecutor e) {
                throw new RejectedExecutionException("Task " + r.toString() +
                                                     " rejected from " +
                                                     e.toString());
            }
        }
```  
     旧任务丢弃策略
```java
/**
         * A handler for rejected tasks that silently discards the
         * rejected task.
         */
public static class DiscardPolicy implements RejectedExecutionHandler {
    /**
     * Creates a {@code DiscardPolicy}.
     */
    public DiscardPolicy() {
    }

    /**
     * Does nothing, which has the effect of discarding task r.
     *
     * @param r the runnable task requested to be executed
     * @param e the executor attempting to execute this task
     */
    public void rejectedExecution(Runnable r, ThreadPoolExecutor e) {
    }
}
```
      当前任务丢弃策略
```java
         /**
         * A handler for rejected tasks that discards the oldest unhandled
         * request and then retries {@code execute}, unless the executor
         * is shut down, in which case the task is discarded.
         */
         public static class DiscardOldestPolicy implements RejectedExecutionHandler {
            /**
             * Creates a {@code DiscardOldestPolicy} for the given executor.
             */
            public DiscardOldestPolicy() { }
    
            /**
             * Obtains and ignores the next task that the executor
             * would otherwise execute, if one is immediately available,
             * and then retries execution of task r, unless the executor
             * is shut down, in which case task r is instead discarded.
             *
             * @param r the runnable task requested to be executed
             * @param e the executor attempting to execute this task
             */
            public void rejectedExecution(Runnable r, ThreadPoolExecutor e) {
                if (!e.isShutdown()) {
                    e.getQueue().poll();
                    e.execute(r);
                }
            }
         }
 ```
 ## 2 线程安全模型
 
### 2.1 COW（copy on  write）
      来源于linux的fork命令，java中的实现类CopyOnWriteArrayList 读操作无需加锁，可能会出现脏数据，遍历时被其他线程修改不会出现并发修改异常（CurrentModificationException）
### 2.2 CAS(compare and swap) 
      即比较与替换被封装为原子操做，ConcurrentHashMap和HashMap都采用数组+链表+红黑数的结构存储数据
### 2.3 RWS(read write separate) 
      即读写分离，LinkedBlockingQueue，用两个可重入锁枷锁head和last

## 3 并发数据结构

### 阻塞型数据结构
    
        当你调用某个方法但是类库无法执行该操作，这种结构将线程阻塞直到这些操作可以执行。（数据元素为空时）
       
### 非阻塞型数据结构
        
        当你调用某个方法但是类库无法执行该操作，该方法会返回一个特定的值或抛出一个异常。（因为结构为满或空时） 
### Java并发数据结构
  
  * 接口
    
            
    BlockingQueue
    BlockingDeque
    ConcurrentMap
    TransferQueue
 * 类
 
      
    LinkedBlockingQueue
    ConcurrentLinkedQueue
    LinkedBlockingDeque
    ConcurrentLinkedDeque
    ArrayBlockingQueue
    DelayQueue
    LinkedTransferQueue
    PriorityBlockingQueue
    ConcurrentHashMap
     
## 4 应用场景
 
 ### 4.1 多读少写
 
 ### 4.2 多写少读
 
 ## 5 线程安全的类的设计
  
 ### 5.1 判断类是否是线程安全的
 
 * 找出构成对象状态的所有变量
 * 找出约束状态变量的不变性条件
 * 建立对象状态的并发访问管理策略
 
 ## 同步机制
 
 ### 进程同步
        
        控制执行任务顺序时，使用进程同步
 ### 数据同步
        
        多线程访问同一数据块时
     
 
 
