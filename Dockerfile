FROM debian:bookworm

RUN apt-get update && \
        apt-get install -y --no-install-recommends \
        curl \
        ca-certificates \
        gnupg

RUN  echo "deb http://apt.postgresql.org/pub/repos/apt bookworm-pgdg main" > /etc/apt/sources.list.d/pgdg.list && \
    curl -s https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor -o /etc/apt/trusted.gpg.d/postgresql.gpg && \
    curl -o /etc/apt/trusted.gpg.d/proxmox-release-bookworm.gpg https://enterprise.proxmox.com/debian/proxmox-release-bookworm.gpg && \
    echo "deb http://download.proxmox.com/debian/pbs-client bookworm main" > /etc/apt/sources.list.d/pbs-client.list

RUN apt-get update && \
        apt-get install -y \
        postgresql-client-17 \
        proxmox-backup-client \
        && rm -rf /var/lib/apt/lists/*

COPY backup-postgres.sh /usr/local/bin/backup-postgres.sh
RUN chmod +x /usr/local/bin/backup-postgres.sh

ENTRYPOINT ["backup-postgres.sh"]
