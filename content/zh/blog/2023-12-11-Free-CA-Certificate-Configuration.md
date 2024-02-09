---
title:       "免费CA认证详细流程"
subtitle:    ""
description: "免费CA证书配置全流程"
date:        2023-12-11
author:      ""
image:       ""
tags:        ["CA"]
categories:  ["Tech" ]
thumbnail: "/img/blog/CA.png"
---


## 免费CA证书配置

+ 安装certbot

```bash

   yum install certbot

```


+ 手动只安装证书

```shell

 certbot run -a manual -i nginx -d domain.com,www.domain.com

```

```shell
Saving debug log to /var/log/letsencrypt/letsencrypt.log
Requesting a certificate for www.domain.com

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Create a file containing just this data:

I7Sl7-xakxMT9dCS67OrHmzn_tFiBx-64g58jlkj9FM.LdWLRuDDIqZUWnece6JOlugrqigifvupPi5EXSfWi0M

And make it available on your web server at this URL:

http://www.yuntun.com/.well-known/acme-challenge/I7Sl7-xakxMT9dCS67OrHmzn_tFiBx-64g58jlkj9FM

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Press Enter to Continue

```


+ 创建验证文件
    +  按上面提示创建对应的文件
    +  自己验证http文件可访问 
    + 继续按continue


```shell
  


```

## 重启nginx服务