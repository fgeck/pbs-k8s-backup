FROM debian@sha256:18023f131f52fc3ea21973cabffe0b216c60b417fd2478e94d9d59981ebba6af

# renovate: release=bookworm depName=curl
ENV CURL_VERSION="7.88.1-10+deb12u12"
# renovate: release=bookworm depName=ca-certificates
ENV CA_CERTIFIFCATES_VERSION="20230311"
# renovate: release=bookworm depName=gnupg
ENV GNUPG_VERSION="2.2.40-1.1"
# Todo: Renovate
ENV POSTGRESQL_CLIENT_17_VERSION="17.4-1.pgdg120+2"
# Todo: Renovate
ENV PROXMOX_BACKUP_CLIENT_VERSION="3.3.2-1"


RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl=${CURL_VERSION} \
    ca-certificates=${CA_CERTIFIFCATES_VERSION} \
    gnupg=${GNUPG_VERSION} && \
    echo "deb http://apt.postgresql.org/pub/repos/apt bookworm-pgdg main" > /etc/apt/sources.list.d/pgdg.list && \
    curl -s https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor -o /etc/apt/trusted.gpg.d/postgresql.gpg && \
    curl -o /etc/apt/trusted.gpg.d/proxmox-release-bookworm.gpg https://enterprise.proxmox.com/debian/proxmox-release-bookworm.gpg && \
    echo "deb http://download.proxmox.com/debian/pbs-client bookworm main" > /etc/apt/sources.list.d/pbs-client.list && \
    apt-get update && \
    apt-get install -y \
    postgresql-client-17=${POSTGRESQL_CLIENT_17_VERSION} \
    proxmox-backup-client=${PROXMOX_BACKUP_CLIENT_VERSION} \
    && rm -rf /var/lib/apt/lists/*

COPY backup-postgres.sh /backup-postgres.sh
COPY backup-pvcs.sh /backup-pvcs.sh
RUN chmod +x /backup-postgres.sh && chmod +x /backup-pvcs.sh

ENTRYPOINT ["/bin/bash", "-c"]
CMD ["/backup-pvcs.sh"]  # Default script
