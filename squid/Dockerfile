FROM debian:bookworm-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends squid ca-certificates \
    && rm -rf /var/lib/apt/lists/*

COPY squid.conf /etc/squid/squid.conf
COPY allowed_ips.txt /etc/squid/allowed_ips.txt

RUN mkdir -p /var/log/squid /var/spool/squid \
    && chown -R proxy:proxy /var/log/squid /var/spool/squid /etc/squid

EXPOSE 3128 2121

CMD ["squid", "-N", "-d", "1"]
