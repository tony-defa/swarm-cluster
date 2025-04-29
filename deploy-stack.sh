#!/bin/bash

# Check if the stack file is provided
if [ -z "$1" ]; then
  echo "Usage: $(basename "$0") <stack-file.yml> [stack-name]"
  exit 1
fi

STACK_FILE="$1"
STACK_NAME="$2"

# Verify that the stack file exists
if [ ! -f "$STACK_FILE" ]; then
  echo "Error: Stack file '$STACK_FILE' does not exist."
  exit 2
fi

# Check for override stack file
OVERRIDE_FILE="$(dirname "$STACK_FILE")/override.$(basename "$STACK_FILE")"
if [ -f "$OVERRIDE_FILE" ]; then
  echo "Found override stack file: $OVERRIDE_FILE"
  read -rp "Do you want to deploy from the override file? (Y/n): " USE_OVERRIDE
  if [[ ! "$USE_OVERRIDE" =~ ^[Nn]$ ]]; then
    STACK_FILE="$OVERRIDE_FILE"
  fi
fi

# Derive stack name from filename if not provided
if [ -z "$STACK_NAME" ]; then
  BASE_NAME=$(basename "$STACK_FILE")
  # Remove "override." if present
  BASE_NAME="${BASE_NAME#override.}"
  STACK_NAME="${BASE_NAME%.*}"
fi

# Get the directory of the stack file
STACK_DIR=$(dirname "$STACK_FILE")
ENV_FILE="$STACK_DIR/.env"

# Handle .env variables
if [ -f "$ENV_FILE" ]; then
  echo "Using .env file in $STACK_DIR"

  # Create folders for HOST_* variables if they don't exist
  grep "^HOST_[A-Z]" "$ENV_FILE" | cut -d'=' -f2 | while read -r DIR; do
    if [ ! -d "$DIR" ]; then
      echo "Creating directory: $DIR"
      sudo mkdir -p "$DIR"
      sudo chown -R :docker "$DIR"
    fi
  done

  # Deploy using compose config
  docker compose -f "$STACK_FILE" config | grep -v '^name' | sed '/published:/ s/"//g' | docker stack deploy --with-registry-auth -c - "$STACK_NAME"
else
  echo "No .env file found in $STACK_DIR – using direct stack deploy"
  docker stack deploy --with-registry-auth -c "$STACK_FILE" "$STACK_NAME"
fi