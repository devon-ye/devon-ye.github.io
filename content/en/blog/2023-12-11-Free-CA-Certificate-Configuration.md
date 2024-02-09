---
title:       "Free CA certification details process"
description: "Complete process for configuring a free CA certificate"
date:        2023-12-11
author:      ""
image:       ""
tags:        ["CA"]
categories:  ["Tech" ]
thumbnail: "/img/blog/CA.png"

keywords: ["CA","SSL"]
---


## Free CA Certificate Configuration

+ install certbot

```bash

   yum install certbot

```


+ Manual certificate-only installation

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


+ Creating Validation Files
    +  Follow the instructions above to create the corresponding file
    +  Verify that the http file is accessible yourself 
    + Press continue


```shell
  


```

## Restart the nginx service