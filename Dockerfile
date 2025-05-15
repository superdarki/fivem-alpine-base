FROM    --platform=$TARGETOS/$TARGETARCH alpine:3.21

LABEL   author="superdarki" maintainer="superdarki@proton.me" org.opencontainers.image.source="https://github.com/superdarki/fivem-alpine-base" 

RUN     adduser -D -h /home/container container

RUN     echo http://dl-cdn.alpinelinux.org/alpine/v3.12/main >>/etc/apk/repositories &&\
        echo http://dl-cdn.alpinelinux.org/alpine/v3.14/main >>/etc/apk/repositories &&\
        apk --no-cache upgrade alpine-keys &&\
        apk --no-cache update &&\
        apk --no-cache upgrade &&\
        apk add --no-cache curl ca-certificates

RUN     curl --http1.1 -sLo /etc/apk/keys/peachypies@protonmail.ch-5adb3818.rsa.pub https://runtime.fivem.net/client/alpine/peachypies@protonmail.ch-5adb3818.rsa.pub &&\
        curl -sLo /etc/apk/keys/hydrogen@fivem.net-614370b9.rsa.pub https://mirrors.fivem.net/build/linux/hydrogen@fivem.net-614370b9.rsa.pub &&\
        echo https://runtime.fivem.net/client/alpine/builds >>/etc/apk/repositories &&\
        echo https://runtime.fivem.net/client/alpine/main >>/etc/apk/repositories &&\
        echo https://runtime.fivem.net/client/alpine/testing >>/etc/apk/repositories &&\
        echo https://runtime.fivem.net/client/alpine/community >>/etc/apk/repositories &&\
        echo https://mirrors.fivem.net/build/linux/packages/cfx >>/etc/apk/repositories &&\
        apk --no-cache update

RUN     apk del curl &&\
        apk add --no-cache tini curl=7.72.0-r99 libssl1.1 libcrypto1.1 libunwind libstdc++ zlib c-ares v8~=9.3 musl-dbg libatomic

USER        container
ENV         USER=container HOME=/home/container
WORKDIR     /home/container

STOPSIGNAL SIGINT

COPY        --chown=container:container ./entrypoint.sh /entrypoint.sh
RUN         chmod +x /entrypoint.sh
ENTRYPOINT  ["/sbin/tini", "-g", "--"]
CMD         ["/entrypoint.sh"]