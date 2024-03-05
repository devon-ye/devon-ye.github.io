---
title:       "Nginx 教程"
description: "Nginx快速上手教程!"
date:        2024-02-11
author:   "Devean"
tags:        ["Nginx","Web Server"]
categories:  ["Tech" ]
math: true
thumbnail: "/img/blog/tracing2.png"
keywords: ["nginx","反向代理","静态部署"]
draft: true
---


# Nginx 快速上手教程
## 启动部署命令

```bash
  nginx -t #测试配置文件
  systemctl start nginx  #服务重启
  systemctl restart nginx  #服务重启
  systemctl stop nginx  #服务停止
  systemctl reload nginx  #重新加载配置文件
````

## 配置项详解


### events 详解
```yml
events {
    # 设置每个工作进程的最大连接数
    worker_connections  1024;

    # 设置每个工作进程可以同时处理的最大连接数，一般情况下，这个值等于系统的最大文件描述符数。
    # 该值应该根据系统的配置和负载情况进行调整。
    multi_accept on;

    # 设置每个工作进程可以同时接受的最大连接数。这个值可以用来控制连接的排队行为。
    # 例如，如果设置为 64，当一个工作进程已经有 64 个连接在队列中时，新连接将被拒绝。
    # 默认值为 512。
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




## 静态服务配置模版

## 反向代理配置模版


## 负载均衡配置模版


## 动静分离配置模版

## 高可用配置模版

## 安全配置模版

## 动静结合多服务部署模版

```yaml



```


## 注意事项





    
    

 

