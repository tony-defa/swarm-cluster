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

# Derive stack name from filename if not provided
if [ -z "$STACK_NAME" ]; then
  STACK_NAME=$(basename "$STACK_FILE")
  STACK_NAME="${STACK_NAME%.*}"
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
  docker compose -f "$STACK_FILE" config | grep -v '^name' | docker stack deploy --with-registry-auth -c - "$STACK_NAME"
else
  echo "No .env file found in $STACK_DIR – using direct stack deploy"
  docker stack deploy --with-registry-auth -c "$STACK_FILE" "$STACK_NAME"
fi