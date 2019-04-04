FROM alpine:3.9

RUN apk update && apk --no-cache add nginx \
 && mkdir -p /run/nginx 

COPY default.conf /etc/nginx/conf.d/
COPY index.html /usr/share/nginx/html/

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]