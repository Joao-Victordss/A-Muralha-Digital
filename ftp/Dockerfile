FROM debian:bookworm-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends vsftpd \
    && rm -rf /var/lib/apt/lists/* \
    && useradd -m -d /srv/ftp/student -s /bin/sh student \
    && echo "student:student" | chpasswd

COPY vsftpd.conf /etc/vsftpd.conf
COPY files/ /srv/ftp/student/
COPY entrypoint.sh /usr/local/bin/ftp-entrypoint

RUN mkdir -p /srv/ftp/student/upload \
    && chown -R student:student /srv/ftp/student \
    && chmod 755 /usr/local/bin/ftp-entrypoint

EXPOSE 21 21100-21110

CMD ["ftp-entrypoint"]
