# syntax=docker/dockerfile:1.4
FROM alpine:latest
MAINTAINER Adrian Dvergsdal [atmoz.net]

# Steps done in one RUN layer:
# - Install packages
# - OpenSSH needs /var/run/sshd to run
# - Remove generic host keys, entrypoint generates unique keys
RUN <<EOR
echo "@community http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories
apk add --no-cache bash shadow@community openssh-server-pam openssh-sftp-server rsync
ln -s /usr/sbin/sshd.pam /usr/sbin/sshd
mkdir -p /var/run/sshd
rm -f /etc/ssh/ssh_host_*key*
EOR

COPY files/sshd_config /etc/ssh/sshd_config
COPY --chmod=744 files/create-sftp-user.sh /usr/local/bin/
COPY --chmod=744 files/entrypoint.sh /

EXPOSE 22

ENTRYPOINT ["/entrypoint.sh"]
