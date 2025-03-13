#!/bin/bash

# Input arguments
PACKAGE_NAME=$1
NEW_VERSION=$2

# Convert package name to environment variable format
ENV_VAR=$(echo "$PACKAGE_NAME" | tr '-' '_' | tr '[:lower:]' '[:upper:]')

# Update Dockerfile with the new version
sed -i "s/ENV $ENV_VAR=\".*\"/ENV $ENV_VAR=\"$NEW_VERSION\"/" Dockerfile

echo "Updated Dockerfile: ENV $ENV_VAR=$NEW_VERSION"