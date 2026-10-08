FROM debian:bookworm

RUN apt-get update && 
apt-get install -y nginx openssl && 
rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/nginx/ssl

RUN openssl req -x509 -nodes -days 365 
-newkey rsa:2048 
-keyout /etc/nginx/ssl/server.key 
-out /etc/nginx/ssl/server.crt 
-subj "/C=SG/ST=Singapore/L=Singapore/O=42/CN=localhost"

COPY conf/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]
