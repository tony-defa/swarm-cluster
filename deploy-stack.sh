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

# Check if yq is installed for YAML parsing
if command -v yq &> /dev/null; then
  # Extract secret names from the top-level secrets section in the YAML file
  SECRET_NAMES=$(yq eval '.secrets | keys[]' "$STACK_FILE" 2>/dev/null | tr -d '"')

  if [ $? -eq 0 ] && [ -n "$SECRET_NAMES" ]; then
    # Convert secret names to array and iterate
    readarray -t SECRET_ARRAY <<< "$SECRET_NAMES"

    # Iterate over each secret name
    for SECRET_NAME in "${SECRET_ARRAY[@]}"; do
      # Skip empty lines
      [ -z "$SECRET_NAME" ] && continue

      # Check if secret already exists in Docker
      if docker secret ls --format "table {{.Name}}" | grep -q "^${SECRET_NAME}$"; then
        echo "✓ Secret '$SECRET_NAME' already exists - skipping"
      else
        echo "Enter value for secret '$SECRET_NAME':"
        # Read input without echoing to terminal for security
        # Use stty to ensure we can read from terminal properly
        stty -echo
        read USER_INPUT
        stty echo
        echo ""

        # Create the Docker secret
        if printf '%s' "$USER_INPUT" | docker secret create "$SECRET_NAME" - >/dev/null 2>&1; then
          echo "✓ Created Docker secret: $SECRET_NAME"
        else
          echo "✗ Failed to create Docker secret: $SECRET_NAME"
          exit 3
        fi
      fi
    done
  fi
else
  echo "Warning: yq not found - skipping secret parsing. Install yq to enable automatic secret creation."
  echo "You can install yq using your package manager (e.g., 'apt install yq' on Ubuntu/Debian)"
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
  docker compose -f "$STACK_FILE" config --no-normalize | grep -v '^name' | sed '/published:/ s/"//g' | docker stack deploy --with-registry-auth -c - "$STACK_NAME"
else
  echo "No .env file found in $STACK_DIR – using direct stack deploy"
  docker stack deploy --with-registry-auth -c "$STACK_FILE" "$STACK_NAME"
fi
