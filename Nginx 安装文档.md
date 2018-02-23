# Nginx 安装文档

## 1.下载安装nginx

- 从nginx 官网下载合适的nginx 版本

  ```
  wget http://nginx.org/download/nginx-1.10.3.tar.gz
  ```

- 解压并编译安装

```shell
tar -xf nginx-1.10.3.tar.gz
cd nginx-1.10.3
./configure  --prefix=/usr/local/nginx --user=nginx --group=nginx --with-pcre --with-http_ssl_module --with-http_stub_status_module --with-http_realip_module --add-module=/media/nginx-goodies-nginx-sticky-module-ng-08a395c66e42 --add-module=/media/nginx_upstream_check_module-0.3.0
```

- 添加配置文件

```
cat /usr/local/nginx/conf/nginx.conf

user  nginx;
worker_processes  4;
worker_cpu_affinity 0001 0010 0100 1000;
#error_log  logs/error.log;
#error_log  logs/error.log  notice;
#error_log  logs/error.log  info;

#pid        logs/nginx.pid;


events {
    use epoll ;
    worker_connections  1024;
}


http {
    include       mime.types;
    default_type  application/octet-stream;
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" $upstream_addr '
    #                  '$status $body_bytes_sent "$http_referer" '
    #                  '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  logs/access.log  main;
    upstream xinyangpayment{
        server 192.168.1.218:18080;
        }
    upstream xinyangweb{
        server 192.168.1.218:28080;
        }
#    upstream xinyangpayment2{
#       server 192.168.1.216:18080;
#       }
#    upstream xinyangweb2{
        #server 192.168.1.216:28080;
        #}
#    upstream testpublicServer {
#       server 192.168.1.220:48080;
#       }
    upstream publicServer {
        server 192.168.1.220:38080;
        }
    upstream  bairongshangmao{
        server 192.168.1.220:18080;
        }
    upstream  parkingISV{
        server 192.168.1.220:28080;
        }
    sendfile        on;
    #tcp_nopush     on;

    #keepalive_timeout  0;
    keepalive_timeout  65;

    #gzip  on;

    server {
        listen       80;
        server_name  webpay.51sspay.com ;

        #charset koi8-r;

        #access_log  logs/host.access.log  main;
        location /paymentrouting {
            proxy_pass http://xinyangpayment;
            error_log logs/nginx_paymentrouting_error.log warn;
        }
        #location ~.html$ {
        location / {
            root /var/www/html;

        }
            
#        location /xinyangpayment  {
#               index login.jsp;
#                proxy_pass http://xinyangpayment;
#                #proxy_redirect off;
#        }

        location /webcashier {
                proxy_pass http://xinyangweb;
                error_log logs/nginx_webcashier_error.log warn;
                #proxy_redirect off;
        }
      
        location /publicServer  {
                proxy_pass http://publicServer;
                error_log logs/nginx_publicServer_error.log warn;
                #proxy_redirect off;
        }

#        location /testpublicServer  {
#                proxy_pass http://testpublicServer;
#               error_log logs/nginx_testpublicServer_error.log warn;
#                #proxy_redirect off;
#        }
#




        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   html;
        }

        # proxy the PHP scripts to Apache listening on 127.0.0.1:80
        #
        #location ~ \.php$ {
        #    proxy_pass   http://127.0.0.1;
        #}

        # pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000
        #
        #location ~ \.php$ {
        #    root           html;
        #    fastcgi_pass   127.0.0.1:9000;
        #    fastcgi_index  index.php;
        #    fastcgi_param  SCRIPT_FILENAME  /scripts$fastcgi_script_name;
        #    include        fastcgi_params;
        #}


#       location ~ \.php$ {
#            root           /var/www/html;
#            fastcgi_pass   127.0.0.1:9000;
#            fastcgi_index  index.php;
#            fastcgi_param  SCRIPT_FILENAME  $document_root$fastcgi_script_name;
#            include        fastcgi_params;
#    }
    }

server {
        listen       80;
        server_name  bairong.51sspay.com;
        location /  {
                proxy_pass http://bairongshangmao;
                error_log logs/nginx_bairong_error.log warn;
}
}
server {
        listen       80;
        server_name  parking.51sspay.com;
        location / {
            proxy_pass http://parkingISV;
            error_log logs/nginx_parkingISV_error.log warn;
         }

}
server {
        listen       443;
        server_name  parking.51sspay.com;

        ssl                  on;

    root html;
    index index.html index.htm;
    ssl_certificate   cert/214260178260230.pem;
    ssl_certificate_key  cert/214260178260230.key;
    ssl_session_timeout 5m;
    ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE:ECDH:AES:HIGH:!NULL:!aNULL:!MD5:!ADH:!RC4;
    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
    ssl_prefer_server_ciphers on;
    location / {
            root   html;
            index  index.html index.htm;
            proxy_pass http://parkingISV;
            error_log logs/nginx_parkingISVs_error.log warn;
        }
    }

} 
```

