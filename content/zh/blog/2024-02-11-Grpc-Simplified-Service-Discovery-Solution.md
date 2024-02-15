---
title:       "GRPC简化版服务发现方案"
description: "GRPC、spring-boot、zookeeper实现轻量化服务发现"
date:        2024-02-11
author:   "Devean"
tags:       ["Service Discovery"]
categories:  ["Tech" ]
math: true
thumbnail: "/img/blog/service-zk.png"
keywords: ["服务发现","服务注册","健康检查"]
---


# GRPC简化版服务发现方案

## 背景
+ 目前服务配置复杂、且测试环境要保证端口不重复
+ server端做自动扩缩容后,client端无法消费最新的server,需要重启client端
+ 新server服务需要在调用它的client端做大量配置
+ 目前grpc服务心跳也无法生效，需要手动在每个server端服务端添加心跳接口实现
+ 目前服务负载均衡基于AWS的DNS建立长链接,无法均衡


## 核心痛点

+ server服务自动扩缩容，需要重启client才能生效
+ 服务化配置复杂，容易配置错误主机信息

## 需求
### 功能性需求
* 现阶段
    + 服务发现
        * 服务扩缩容后，可在client端实时更新，无需重启服务
    + 服务健康检查
        * 服务出现踢出重连
    + 简化rpc服务配置

* 后期
    + 权限控制
    + 灰度路由
    + 服务治理
    + 服务预热
### 非功能性需求
+ 高可用且
+ 可拓展，具备后期拓展权限控制、限流、熔断、服务预热等治理
## 方案设计

### 服务注册流程
#### grpc-server启动服务注册流程

![](/img/blog/service-register.png)


### 服务发现流程

![](/img/blog/service-discovery.png)


### 具体方案

#### DB存储方案
+ DB 存储结构

| cluster_name |server_name |own_address | heat_beat| instance_hash  |  
| --- | --- | --- | --- | ---|
| default | user-center | host:port | timestamp | 集群名+服务名+主机端口的hash |  

+ 方案描述
1. server端启动后将服务信息写入表，并周期更新心跳,
2. 服务启动时加载shutdownhook钩子函数,服务关闭时删除服务当前实例服务信息
3. client端调启动时加载服务信息列表并创建rpc链接
4. client端添加定时任务，根据服务名扫描服务实例信息，并做合并

+ 优点
  + 实现简单
  + 维护成本低
+ 缺点
  + 无法实现强一致性
  + 延迟高
  + 后期拓展接口粒度服务注册时，不易拓展
#### zk存储方案

* zk存储结构

![](/img/blog/service-zk.png)

* 方案描述
  1./grpc-clusterName /serverName为实体节点 配置不同的clusterName来区分不同环境
  2.主机信息节点为虚节点，以zk心跳来做服务心跳
  3.grpc_client端监听serverName节点的子节点事件，处理服务上线下
  4.主机节点包含主机写入时间戳

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