FROM alpine:edge

# TODO: Cleanup
ADD repositories /etc/apk/repositories
ADD deploy-key /home/root/deploy-key
ADD root /
ADD config.cfg /cfg/config.cfg
ADD / /repo
RUN apk -u add alpine-sdk lua-aports openssh sshfs && \
    mkdir -p /var/cache/distfiles && \
    adduser -D builder && \
    addgroup builder abuild && \
    chgrp abuild /var/cache/distfiles && \
    chmod g+w /var/cache/distfiles && \
    mkdir /remote-fs && \
    chgrp abuild /remote-fs && \
    chown -R builder:builder /repo && \
    echo "builder ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    patch -d / -p 1 < /repo/.build/abuild-sign.patch && \
    cp -a /repo/.keys/. /etc/apk/keys

USER builder