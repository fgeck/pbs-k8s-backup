FROM debian:bookworm

# renovate: release=bookworm depName=curl
ENV CURL_VERSION="7.88.1-10+deb12u12"
# renovate: release=bookworm depName=ca-certificates
ENV CA_CERTIFICATES_VERSION="20230311+deb12u1"
# renovate: release=bookworm depName=gnupg
ENV GNUPG_VERSION="2.2.40-1.1"
# renovate: datasource=custom.postgresql depName=postgresql-client-17
ENV POSTGRESQL_CLIENT_17_VERSION="17.6-1.pgdg120+1"
# Manually managed for PBS server 3.3.6 compatibility - renovate:ignore
ENV PROXMOX_BACKUP_CLIENT_VERSION="3.3.*"

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl=${CURL_VERSION} \
    ca-certificates=${CA_CERTIFICATES_VERSION} \
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

# Copy scripts and entrypoint
COPY backup-postgres.sh /backup-postgres.sh
COPY backup-pvcs.sh /backup-pvcs.sh
COPY entrypoint.sh /entrypoint.sh

# Make scripts executable
RUN chmod +x /backup-postgres.sh && \
    chmod +x /backup-pvcs.sh && \
    chmod +x /entrypoint.sh

# Set default working directory for PVC backups
WORKDIR /pvcs

# Use flexible entrypoint
ENTRYPOINT ["/entrypoint.sh"]
CMD ["pvcs"]
