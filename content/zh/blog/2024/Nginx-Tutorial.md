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

## 单机nginx标准配置
```bash
http {
    # 定义限速区域
    limit_req_zone $binary_remote_addr zone=one:10m rate=1000r/s;  # 每秒 1000 个请求
    limit_conn_zone $binary_remote_addr zone=addr:10m;  # 连接数区域

    # HTTP 服务器配置
    server {
        listen 80;
        listen [::]:80;
        server_name domain.com www.domain.com;
        
        # 将所有请求重定向到 HTTPS
        return 301 https://$server_name$request_uri;
    }

    # HTTPS 服务器配置
    server {
        listen 443 ssl http2;
        listen [::]:443 ssl http2;
        server_name knowhub.yuntun.group;

        # SSL安全证书配置
        ssl_certificate /etc/letsencrypt/live/domain.com/fullchain.pem;
        ssl_certificate_key /etc/letsencrypt/live/domain.com/privkey.pem;
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_prefer_server_ciphers off;
        ssl_ciphers 'TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256:TLS_AES_128_GCM_SHA256';

        # 安全头配置
        # HSTS (强制使用 HTTPS)
        add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
        # 防止点击劫持
        add_header X-Frame-Options "SAMEORIGIN";
        # 防止 XSS 攻击
        add_header X-XSS-Protection "1; mode=block";
        # 防止 MIME 类型嗅探
        add_header X-Content-Type-Options "nosniff";

        # 限速和限流配置
        limit_req zone=one burst=20 nodelay;
        limit_conn addr 10;
        # 定义限速区域
        limit_req_zone $binary_remote_addr zone=one:10m rate=1r/s;  # 每秒 1 个请求
        limit_conn_zone $binary_remote_addr zone=addr:10m;  # 连接数区域
        
        # 允许每个 IP 地址最多同时建立 10 个连接
        limit_conn addr 100;

        # 配置你的站点
        root /var/www/html;
        index index.html index.htm index.nginx-debian.html;

        location / {
              # 每个客户端连接的传输速率限制为 1MB/s
            limit_rate 1m;

            # 最大请求体大小为 10MB
            client_max_body_size 10m;

            # 黑名单和白名单配置 
            # 允许的 IP 列表 (白名单)
            allow 192.168.1.1;  # 单个 IP
            allow 192.168.1.0/24;  # 子网
            allow 10.0.0.0/8;  # 大子网

            # 拒绝的 IP 列表 (黑名单)
            deny 192.168.2.1;  # 单个 IP
            deny 192.168.2.0/24;  # 子网
            deny 11.0.0.0/8;  # 大子网

            # 默认拒绝所有其他 IP
            deny all;
            try_files $uri $uri/ =404;
        }
        
        # 配置 API 代理
        location /api {
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_pass http://localhost:3000;
        }
        
        # 处理静态文件
        location ~* \.(jpg|jpeg|png|gif|ico|css|js)$ {
            expires 7d;
            add_header Cache-Control "public, must-revalidate, proxy-revalidate";
        }

        # 日志配置
        access_log /var/log/nginx/access.log;
        error_log /var/log/nginx/error.log;
    }
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





    
    

 

