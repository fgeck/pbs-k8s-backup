FROM debian:bookworm

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    gnupg

RUN curl -o /etc/apt/trusted.gpg.d/proxmox-release-bookworm.gpg https://enterprise.proxmox.com/debian/proxmox-release-bookworm.gpg && \
echo "deb http://download.proxmox.com/debian/pbs-client bookworm main" > /etc/apt/sources.list.d/pbs-client.list

RUN apt-get update && \
    apt-get install -y \
    postgresql-client \
    proxmox-backup-client \
    && rm -rf /var/lib/apt/lists/*

COPY backup-postgres.sh /usr/local/bin/backup-postgres.sh
RUN chmod +x /usr/local/bin/backup-postgres.sh

ENTRYPOINT ["backup-postgres.sh"]
