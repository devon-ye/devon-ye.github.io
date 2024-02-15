---
title:       "Nginx Tutorial"
description: "Nginx Quick Start Tutorial"
date:        2024-02-11
author:   "Devean"
tags:        ["Nginx","Web Server"]
categories:  ["Tech" ]
math: true
thumbnail: "/img/blog/tracing2.png"
keywords: ["nginx","reverse proxy ","Static deployment"]

draft: true
---

# Nginx Quick Start Tutorial

## Start deployment command

```bash
  nginx -t #test configuration file
  systemctl start nginx  #service restart
  systemctl restart nginx  #service restart
  systemctl stop nginx  #service stop
  systemctl reload nginx  #reload configuration file
```

## Configuration item details
```yml

events {
    # set the maximum number of connections for each worker process
    worker_connections  1024;

    # set the maximum number of connections that each worker process can handle at the same time. In general, this value is equal to the maximum number of file descriptors in the system.
    # This value should be adjusted according to the system configuration and load.
    multi_accept on;

    # set the maximum number of connections that each worker process can accept at the same time. This value can be used to control the queuing behavior of connections.
    # For example, if set to 64, when a worker process already has 64 connections in the queue, new connections will be rejected.
    # The default value is 512.
    accept_mutex on;
    
    # 在连接保持的情况下，保持连接处于活跃状态的最大时间，默认为 65 秒。
    # 如果超过这个时间，连接将会被关闭。
    keepalive_timeout 65;

    # 用于处理长连接的定时器超时，默认值为 60 秒。
    keepalive_requests 100;

    # 配置Nginx是否开启优化TCP连接的参数，默认为 on。
    # 在高负载环境下，关闭 TCP_DEFER_ACCEPT 可以减少连接队列的排队时间，提高连接的响应速度。
    tcp_nodelay on;
    
    # 用于优化数据的发送，默认为 on。
    # 开启 tcp_nopush 后，Nginx 会尝试将数据放入 TCP 发送缓冲区的末尾，
    # 直到缓冲区被填满或者到达了 flush 数据的时间点。
    tcp_nopush on;

    # 用于设置连接的超时时间，单位是秒，默认值为 75 秒。
    # 当连接空闲超过这个时间时，连接将被关闭。
    # 如果设置为 0，表示不启用连接超时。
    client_body_timeout 12;
}


```
### HTTP 配置模版
```yml

```



## 静态服务配置模版

## 反向代理配置模版


## 负载均衡配置模版


## 动静分离配置模版

## 高可用配置模版

## 安全配置模版

## 性能优化配置模版


## 注意事项





    
    

 

