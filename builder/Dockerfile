FROM alpine:edge

ADD repositories /etc/apk/repositories

RUN apk -u add alpine-sdk

RUN mkdir -p /var/cache/distfiles && \
    adduser -D builder && \
    addgroup builder abuild && \
    chgrp abuild /var/cache/distfiles && \
    chmod g+w /var/cache/distfiles && \
    echo "builder ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

USER packager
