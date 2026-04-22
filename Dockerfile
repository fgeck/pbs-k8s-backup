FROM debian:trixie

# renovate: release=trixie depName=curl
ENV CURL_VERSION="8.14.1-2+deb13u2"
# renovate: release=trixie depName=ca-certificates
ENV CA_CERTIFICATES_VERSION="20250419"
# renovate: release=trixie depName=gnupg
ENV GNUPG_VERSION="2.4.7-21+deb13u1"
# renovate: datasource=repology depName=debian_13/postgresql-client-17
ENV POSTGRESQL_CLIENT_17_VERSION="17.9-0+deb13u1"
# Manually managed for PBS server 3.3.6 compatibility - renovate:ignore
ENV PROXMOX_BACKUP_CLIENT_VERSION="4.*"

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl=${CURL_VERSION} \
    ca-certificates=${CA_CERTIFICATES_VERSION} \
    gnupg=${GNUPG_VERSION} && \
    echo "deb http://apt.postgresql.org/pub/repos/apt trixie-pgdg main" > /etc/apt/sources.list.d/pgdg.list && \
    curl -s https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor -o /etc/apt/trusted.gpg.d/postgresql.gpg && \
    curl -o /etc/apt/trusted.gpg.d/proxmox-release-trixie.gpg https://enterprise.proxmox.com/debian/proxmox-release-trixie.gpg && \
    echo "deb http://download.proxmox.com/debian/pbs-client trixie main" > /etc/apt/sources.list.d/pbs-client.list && \
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
