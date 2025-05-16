FROM        --platform=$TARGETOS/$TARGETARCH debian:bookworm-slim

LABEL       author="superdarki" maintainer="superdarki@proton.me"

LABEL       org.opencontainers.image.source="https://github.com/pterodactyl/yolks"
LABEL       org.opencontainers.image.licenses=MIT

ENV         DEBIAN_FRONTEND=noninteractive

RUN         useradd -m -d /home/container -s /bin/bash container

RUN         ln -s /home/container/ /nonexistent

## Update base packages
RUN         apt update \
            && apt upgrade -y

## Install dependencies
RUN         apt install -y curl wget ca-certificates tini locales iproute2

## Configure locale
RUN         update-locale lang=en_US.UTF-8 \
            && dpkg-reconfigure --frontend noninteractive locales

USER        container
ENV         USER=container HOME=/home/container
WORKDIR     /home/container

STOPSIGNAL SIGINT

COPY        --chown=container:container ./entrypoint.sh /entrypoint.sh
RUN         chmod +x /entrypoint.sh
ENTRYPOINT  ["/usr/bin/tini", "-g", "--"]
CMD         ["/entrypoint.sh"]