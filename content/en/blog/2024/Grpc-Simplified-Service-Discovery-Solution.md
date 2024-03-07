---
title:       "GRPC Simplified Service Discovery Program"
description: "GRPC, spring-boot, zookeeper for lightweight service discovery"
date:        2024-02-11
author:   "Devean"
tags:       ["Service Discovery"]
categories:  ["Tech" ]
math: true
thumbnail: "/img/blog/service-zk.png"
keywords: ["Service Discovery","Service Register","Service Health Check"]
draft: true
---


## summary

+ The current service configuration is complex, and the test environment must ensure that the ports are not repeated
+ After the capacity is automatically expanded or shrunk on the server, the client cannot consume the latest server and needs to restart the client
+ The new server service requires a lot of configuration on the client side that calls it
+ Currently, the grpc service heartbeat cannot take effect. You need to manually add a heartbeat interface to each server
+ The current service load balancing is based on AWS DNS to establish long links, which cannot be balanced

## Core pain point

+ The capacity of the server service is expanded or shrunk automatically. You need to restart the client to take effect
+ The server configuration is complicated, and incorrect host information is easy to be configured

## Requirements

### Functional requirements
* Current stage
  +  Service Discovery
      + After the service capacity is expanded or shrunk, the service can be updated in real time on the client without restarting the service
  + Service health check
  
      + The service has a kick out reconnection
  + Simplify rpc service configuration

+ Later stage
  + Permission control
  + Grayscale routing
  + Service governance
  + Service preheating

### Non-functional requirements

+ High availability
+ Can be expanded, with later expansion rights control, current limiting, circuit breaker, service preheating and other governance

## Program design

### Service registration process

#### grpc-server starts the service registration process


![](/img/blog/service-register.png)

### Service discovery process


![](/img/blog/service-discovery.png)


### Specific scheme

#### DB storage scheme

+ DB storage structure


| cluster_name |server_name |own_address | heat_beat| instance_hash                               |  
| --- | --- | --- | --- |---------------------------------------------|
| default | user-center | host:port | timestamp | (cluster name +service name+ host:port)hash |  

+ Program description

1. After the server starts, it writes the service information to the table and updates the heartbeat periodically.
2. Load the shutdownhook hook function when the service is started and delete the current instance service information when the service is stopped
3. The client loads the service information list and creates an rpc link
4. The client adds a scheduled task, scans for service instances by service name, and merges them

+ Advantages
  + Simple implementation
  + Low maintenance cost

+ Disadvantages
  + Unable to achieve strong consistency
  + High latency
  + Difficult to expand the interface granularity when registering services later 
    
#### zk storage scheme

* zk storage structure


![](/img/blog/service-zk.png)

* Solution Description
  1. grpc-clusterName/serverName Configure different Clusternames for the entity nodes to distinguish different environments
  2. The host information node is a virtual node and uses the zk heartbeat as the service heartbeat
  3. The grpc_client listens to the child node events of the serverName node and processes the online and offline services
  4. The host node contains the write timestamp of the host

+ 优点
  低延迟
  强一致
  后期拓展接口粒度服务注册时，易于拓展
+ 缺点
  维护成本高

### 存储方案对比

|  | DB |redis |zookeeper | etcd |Eureka  | Consul | Nacos|
| --- | --- | --- | --- | --- | --- | --- |---|
| 一致性 | 弱 | 弱 | CP | CP | AP | CP | CP+AP|
| 健康检查 | 不支持 | 不支持 | 支持 | 支持 |支持 |支持  |双向心跳|
| watcher支持 | 不支持 | 不支持 |多次注册  |一次注册  | 支持 | 支持 |支持
| 自动注销 | 不支持 | 不支持 |支持 | 支持 | 需调用其API或超过延迟时间下线 |支持 |支持
| 最少节点数 | 1 |  | 3 | 3 | 1 | 3 |3|
| 社区 |  |  | 活跃 | 活跃 | 不活跃 | 活跃 |活跃|
|延迟|高|较高| 低|低|较高| 低|低|
|拓展接口注册|难度大|容易|容易|容易|容易|容易|难|
|语言|C++|C++|Java|go|Java|go|Java|
|缺点||可靠性低|当服务达到一定规模是,写入性能存在瓶颈|||
|备注| |依赖SDK|依赖SDK |与Registrator结合实现服务发现预注册|eureka1.x停止维护 ,2.x闭源|



### 结论
+ 基于强一致性和健康检查、监听机制
  包括zookeeper、etcd、Consul、Nacos
+ 易拓展原则
  包括zookeeper、etcd、Consul
+ 简单原则
  包括zookeeper、etcd、Consul
+ 适合原则
  zookeeper 团队内大家都不熟悉go
+ 演化原则
  zookeeper