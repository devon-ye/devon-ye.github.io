---
title:       "免费CA认证详细流程"
description: "教你1分钟搞定免费CA证书配置"
date:        2023-12-11
author:      ""
image:       ""
tags:        ["运维"]
categories:  ["Tech"]
keywords: []
thumbnail: "/img/blog/CA.png"
keyword: ["CA证书","SSL证书","certbot","nginx","https配置"]
draft: false
---



## Nginx配置


### nginx.conf配置
```bash
    server {
        listen 80;
        listen [::]:80;
        server_name  www.domain.com domain.com;
        return 301 https://$server_name$request_uri;
    }
    # HTTPS服务器
    server {
        listen 443 ssl;
        listen [::]:443 ssl;
        server_name www.domain.com  domain.com;
        
         # 网站根目录
        root /usr/share/nginx/domain;
        index index.html index.htm;
        
        # SSL
        ssl_session_cache shared:SSL:1m;
        ssl_session_timeout 10m;
        ssl_ciphers PROFILE=SYSTEM;
	    ssl_protocols TLSv1 TLSv1.1 TLSv1.2 TLSv1.3;
        ssl_prefer_server_ciphers on;
        proxy_ssl_server_name on;
        
	    location / {
	    }
	    
        error_page 404 /404.html;
            location = /40x.html {
        }
        
        error_page 500 502 503 504 /50x.html;
            location = /50x.html {
        }
    }

```
### Nginx验证配置正确性
```bash
   nginx -t
   nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
   nginx: configuration file /etc/nginx/nginx.conf **test is successful
```
### Nginx加载新增配置
```bash
   systemctl reload nginx
```

## DNS配置及验证

### DNS配置
  在DNS厂商DNS配置服务里配置  www.domain.com 到服务器IP地址解析

### 验证域名访问

+ 浏览器访问域名 www.domain.com

![](/img/blog/not-secure.png)


 + 1. 可正常访问站点
 + 2. 浏览器显示站点不安全

## 免费CA证书申请

### 安装certbot

```bash

   yum install certbot

```
![img_1.png](/img/blog/yum-install-certbot.png)

### 自动安装证书

```bash
   certbot --nginx
```

![img_2.png](/img/blog/certbot-nginx.png)

## 验证安装结果

![img_2.png](/img/blog/ssl-secured.png)
