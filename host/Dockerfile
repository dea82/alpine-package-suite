FROM alpine:latest
MAINTAINER Andreas L.

RUN apk add --update nginx && \
    rm -rf /var/cache/apk/* && \
    mkdir /run/nginx && \
    adduser -D -g 'www' www && \
    mkdir /www && \
    chown -R www:www /var/lib/nginx && \
    chown -R www:www /www

ADD root /

# Expose the ports for nginx
EXPOSE 80 443