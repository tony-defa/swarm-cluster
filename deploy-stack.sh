#!/bin/bash

# Exit codes
readonly EXIT_INVALID_ARGS=1
readonly EXIT_FILE_NOT_FOUND=2
readonly EXIT_SECRET_FAILED=3

# Default values
readonly SCRIPT_NAME=$(basename "$0")

# Validate script arguments
validate_arguments() {
  if [ -z "$1" ]; then
    echo "Usage: $SCRIPT_NAME <stack-file.yml> [stack-name]"
    exit $EXIT_INVALID_ARGS
  fi

  STACK_FILE="$1"
  STACK_NAME="$2"

  # Verify that the stack file exists
  if [ ! -f "$STACK_FILE" ]; then
    echo "Error: Stack file '$STACK_FILE' does not exist."
    exit $EXIT_FILE_NOT_FOUND
  fi
}

# Check for and handle override file
check_override_file() {
  local override_file
  override_file="$(dirname "$STACK_FILE")/override.$(basename "$STACK_FILE")"

  if [ -f "$override_file" ]; then
    echo "Found override stack file: $override_file"
    read -rp "Do you want to deploy from the override file? (Y/n): " use_override
    if [[ ! "$use_override" =~ ^[Nn]$ ]]; then
      STACK_FILE="$override_file"
    fi
  fi
}

# Derive stack name from filename if not provided
derive_stack_name() {
  if [ -z "$STACK_NAME" ]; then
    local base_name
    base_name=$(basename "$STACK_FILE")
    # Remove "override." if present
    base_name="${base_name#override.}"
    STACK_NAME="${base_name%.*}"
  fi
}

# Create Docker secrets from YAML file
create_secrets() {
  if ! command -v yq &> /dev/null; then
    echo "Warning: yq not found - skipping secret parsing. Install yq to enable automatic secret creation."
    echo "You can install yq using your package manager (e.g., 'apt install yq' on Ubuntu/Debian)"
    return 0
  fi

  # Extract secret names from the top-level secrets section in the YAML file
  local secret_names
  secret_names=$(yq eval '.secrets | keys[]' "$STACK_FILE" 2>/dev/null | tr -d '"')

  if [ $? -ne 0 ] || [ -z "$secret_names" ]; then
    return 0
  fi

  # Convert secret names to array and iterate
  readarray -t secret_array <<< "$secret_names"

  # Iterate over each secret name
  for secret_name in "${secret_array[@]}"; do
    # Skip empty lines
    [ -z "$secret_name" ] && continue

    # Check if secret already exists in Docker
    if docker secret ls --format "table {{.Name}}" | grep -q "^${secret_name}$"; then
      echo "✓ Secret '$secret_name' already exists - skipping"
    else
      create_single_secret "$secret_name"
    fi
  done
}

# Create a single Docker secret
create_single_secret() {
  local secret_name="$1"
  local user_input

  echo "Enter value for secret '$secret_name':"
  # Read input without echoing to terminal for security
  stty -echo
  read user_input
  stty echo
  echo ""

  # Create the Docker secret
  if printf '%s' "$user_input" | docker secret create "$secret_name" - >/dev/null 2>&1; then
    echo "✓ Created Docker secret: $secret_name"
  else
    echo "✗ Failed to create Docker secret: $secret_name"
    exit $EXIT_SECRET_FAILED
  fi
}

# Create directories for HOST_* variables from .env file
create_host_directories() {
  local env_file="$1"
  local stack_dir="$2"

  if [ ! -f "$env_file" ]; then
    return 0
  fi

  echo "Using .env file in $stack_dir"

  # Create folders for HOST_* variables if they don't exist
  grep "^HOST_[A-Z]" "$env_file" | cut -d'=' -f2 | while read -r dir; do
    if [ ! -d "$dir" ]; then
      echo "Creating directory: $dir"
      sudo mkdir -p "$dir"
      sudo chown -R :docker "$dir"
    fi
  done
}

# Deploy the Docker stack
deploy_stack() {
  local stack_dir
  stack_dir=$(dirname "$STACK_FILE")
  local env_file="$stack_dir/.env"

  if [ -f "$env_file" ]; then
    # Deploy using compose config (with .env file)
    docker compose -f "$STACK_FILE" config --no-normalize | \
      grep -v '^name' | \
      sed '/published:/ s/"//g' | \
      docker stack deploy --with-registry-auth -c - "$STACK_NAME"
  else
    echo "No .env file found in $stack_dir - using direct stack deploy"
    docker stack deploy --with-registry-auth -c "$STACK_FILE" "$STACK_NAME"
  fi
}

# Main execution flow
main() {
  validate_arguments "$@"
  check_override_file
  derive_stack_name
  create_secrets
  create_host_directories "$STACK_DIR/.env" "$STACK_DIR"
  deploy_stack
}

# Run main function with all arguments
main "$@"
