FROM alpine AS build

ARG ARCH=arm64
ARG VERSION=0.99.2

WORKDIR /opt

RUN wget https://github.com/AdguardTeam/AdGuardHome/releases/download/v$VERSION/AdGuardHome_linux_$ARCH.tar.gz \
  && tar x -vzf AdGuardHome_linux_$ARCH.tar.gz \
  && rm AdGuardHome_linux_$ARCH.tar.gz

FROM alpine AS runner

RUN apk --no-cache --update add ca-certificates libcap && \
    rm -rf /var/cache/apk/* && \
    mkdir -p /opt/adguardhome/conf /opt/adguardhome/work && \
    chown -R nobody: /opt/adguardhome

COPY --from=build --chown=nobody:nogroup /opt/AdGuardHome/AdGuardHome /opt/adguardhome/AdGuardHome

RUN setcap 'cap_net_bind_service=+eip' /opt/adguardhome/AdGuardHome

EXPOSE 53/tcp 53/udp 67/udp 68/udp 80/tcp 443/tcp 853/tcp 3000/tcp
VOLUME ["/opt/adguardhome/conf", "/opt/adguardhome/work"]
WORKDIR /opt/adguardhome/work

ENTRYPOINT ["/opt/adguardhome/AdGuardHome"]
CMD ["-c", "/opt/adguardhome/conf/AdGuardHome.yaml", "-w", "/opt/adguardhome/work", "--no-check-update"]
