---
title:       "Free CA certification details process"
description: "Complete process for configuring a free CA certificate"
date:        2023-12-11
author:      ""
image:       ""
tags:        ["DevOps"]
categories:  ["Tech" ]
thumbnail: "/img/blog/CA.png"

keyword: ["CA","SSL","certbot","nginx","https configuration"]

---

## Nginx Configuration


### nginx.conf config
```bash
    server {
        listen 80;
        listen [::]:80;
        server_name  www.domain.com domain.com;
        return 301 https://$server_name$request_uri;
    }
    # HTTPS server
    server {
        listen 443 ssl;
        listen [::]:443 ssl;
        server_name www.domain.com  domain.com;
        
         # website root direction
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
###Nginx verifies that the configuration is correct
```bash
   nginx -t
   nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
   nginx: configuration file /etc/nginx/nginx.conf **test is successful
```
### Nginx Reload new Configuration
```bash
   systemctl reload nginx
```

## DNS Configuration and Verification

### DNS Configuration

+ In the DNS vendor DNS configuration service, configure www.domain.com to resolve the server IP address

### Verify Domain Name

+ Browser access domain name www.domain.com

![](/img/blog/not-secure.png)


+ 1. The site can be accessed normally
+ 2. Browsers display sites that are not secure

## Free CA (Certificate Application)

### Install Certbot

```bash

   yum install certbot

```
![img_1.png](/img/blog/yum-install-certbot.png)

### Automatic Installation Certificate

```bash
   certbot --nginx
```

![img_2.png](/img/blog/certbot-nginx.png)

## Verify Installation Results

![img_2.png](/img/blog/ssl-secured.png)
