#!/bin/bash

apt-get update
apt-get install -y curl gnupg2
curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
echo "deb http://apt.postgresql.org/pub/repos/apt bookworm-pgdg main" > /etc/apt/sources.list.d/pgdg.list
apt-get update

CURRENT_VERSION=$(grep 'ENV POSTGRESQL_CLIENT_17_VERSION' Dockerfile | cut -d'"' -f2)
LATEST_VERSION=$(apt-cache policy postgresql-client-17 | grep Candidate | cut -d: -f2 | tr -d ' ')
echo "Current version: $CURRENT_VERSION"
echo "Latest version: $LATEST_VERSION"
if [ "$CURRENT_VERSION" != "$LATEST_VERSION" ]; then
    echo "::set-output name=new_version::$LATEST_VERSION"
    echo "::set-output name=update_needed::true"
else
    echo "::set-output name=update_needed::false"
fi
