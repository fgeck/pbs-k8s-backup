FROM debian:bookworm-20250224-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl=7.88.1-10+deb12u8 \
    ca-certificates=20230311 \
    gnupg=2.2.40-1.1 && \
    echo "deb http://apt.postgresql.org/pub/repos/apt bookworm-pgdg main" > /etc/apt/sources.list.d/pgdg.list && \
    curl -s https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor -o /etc/apt/trusted.gpg.d/postgresql.gpg && \
    curl -o /etc/apt/trusted.gpg.d/proxmox-release-bookworm.gpg https://enterprise.proxmox.com/debian/proxmox-release-bookworm.gpg && \
    echo "deb http://download.proxmox.com/debian/pbs-client bookworm main" > /etc/apt/sources.list.d/pbs-client.list && \
    apt-get update && \
    apt-get install -y \
    postgresql-client-17=17.4-1.pgdg120+2 \
    proxmox-backup-client=3.3.2-1 \
    && rm -rf /var/lib/apt/lists/*

COPY backup-postgres.sh /backup-postgres.sh
COPY backup-pvcs.sh /backup-pvcs.sh
RUN chmod +x /backup-postgres.sh && chmod +x /backup-pvcs.sh

ENTRYPOINT ["/bin/bash", "-c"]
CMD ["/backup-pvcs.sh"]  # Default script
