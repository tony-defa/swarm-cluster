#!/bin/bash

# Exit codes
readonly EXIT_INVALID_ARGS=1
readonly EXIT_FILE_NOT_FOUND=2
readonly EXIT_SECRET_FAILED=3
readonly EXIT_MUSTACHE_FAILED=4

# Default values
readonly SCRIPT_NAME=$(basename "$0")

# Global variables for mustache support
IS_MUSTACHE=false
GENERATED_YAML=""
VIEW_FILE=""

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

  # Extract secret names from the top-level secrets section in the YAML content
  local secret_names
  if [ "$IS_MUSTACHE" == true ]; then
    # For generated YAML, use echo with yq
    secret_names=$(echo "$GENERATED_YAML" | yq eval '.secrets | keys[]' - 2>/dev/null | tr -d '"')
  else
    # For file-based YAML, use the file directly
    secret_names=$(yq eval '.secrets | keys[]' "$STACK_FILE" 2>/dev/null | tr -d '"')
  fi

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
  local env_file="$ENV_FILE"
  local compose_file="${STACK_DIR}/.tmp-compose.yml"

  if [ "$IS_MUSTACHE" == true ]; then
    tee $compose_file <<< "$GENERATED_YAML" >/dev/null 2>&1
  else 
    compose_file="$STACK_FILE"
  fi

  if [ -f "$env_file" ]; then
    echo "Deploying stack with env file: $env_file"

    # Deploy using compose config (with .env file)
    docker compose -f "$compose_file" --env-file "$env_file" config --no-normalize | \
      grep -v '^name' | \
      sed '/published:/ s/"//g' | \
      docker stack deploy --with-registry-auth -c - "$STACK_NAME"
  else
    echo "No .env file found in $STACK_DIR - using direct stack deploy"
    docker stack deploy --with-registry-auth -c "$compose_file" "$STACK_NAME"
  fi

  if [ "$IS_MUSTACHE" == true ]; then
    rm "$compose_file"
  fi
}

maybe_adjust_stack_name() {
  local base_name  
  base_name=$(basename "${STACK_FILE%.*}")
  if [ $(basename $VIEW_FILE) != ".view.json" ] && [ "$base_name" == $STACK_NAME ]; then
    STACK_NAME=$(basename "$VIEW_FILE" .view.json)
    STACK_NAME="${STACK_NAME//./}"
  fi
}

# Find available view files in the same directory as the template
find_available_view_files() {
  local template_dir="$1"
  local view_files=()

  # Find all .view.json files (excluding example.*)
  while IFS= read -r -d '' file; do
    view_files+=("$(basename "$file")")
  done < <(find "$template_dir" -maxdepth 1 -name "*.view.json" ! -name "example.*" -print0 2>/dev/null | sort -z)

  echo "${view_files[@]}"
}

# Prompt user to select view file
select_view_file() {
  local template_dir="$1"
  local view_files=($2)

  if [ ${#view_files[@]} -eq 0 ]; then
    if [ -f "$template_dir/.view.json" ]; then
      VIEW_FILE="$template_dir/.view.json"
    else 
      echo "No view files found in $template_dir"
      return 1
    fi
  elif [ ${#view_files[@]} -eq 1 ]; then
    VIEW_FILE="$template_dir/${view_files[0]}"
    echo "Using view file: $VIEW_FILE"
    return 0
  else
    echo "Available view files:"
    for i in "${!view_files[@]}"; do
      echo "$((i+1)). ${view_files[$i]}"
    done

    local selection
    read -p "Select view file (1-${#view_files[@]}), or 0 for default .view.json: " selection

    if [ "$selection" -eq 0 ]; then
      VIEW_FILE="$template_dir/.view.json"
      echo "Using view file: $VIEW_FILE"
      return 0
    elif [[ "$selection" =~ ^[0-9]+$ ]] && [ "$selection" -ge 1 ] && [ "$selection" -le "${#view_files[@]}" ]; then
      VIEW_FILE="$template_dir/${view_files[$((selection-1))]}"
      echo "Using view file: $VIEW_FILE"
      return 0
    else
      echo "Invalid selection"
      return 1
    fi
  fi
}

# Auto-select env file based on view file name, with fallback
select_env_file() {
  local template_dir="$1"
  local view_file="$2"

  # Extract base name from view file (e.g., ".test2.view.json" -> "test2")
  local base_name
  base_name=$(basename "$view_file" .view.json)
  base_name=".${base_name#.}"

  # Check for corresponding env file first
  local corresponding_env="$template_dir/$base_name.env"
  if [ -f "$corresponding_env" ]; then
    ENV_FILE="$corresponding_env"
    echo "Auto-selected env file: $ENV_FILE"
    return 0
  fi

  # Fallback to default .env
  ENV_FILE="$template_dir/.env"
  echo "Corresponding env file not found, using default: $ENV_FILE"
  return 0
}

# Generate YAML from mustache template
generate_yaml_from_mustache() {
  local view_file="$1"
  local template_file="$2"

  if [ ! -f "$view_file" ]; then
    echo "Error: View file '$view_file' does not exist."
    exit $EXIT_FILE_NOT_FOUND
  fi

  # Generate YAML content and store in variable for reuse
  GENERATED_YAML=$(mustache "$view_file" "$template_file" 2>/dev/null)
  local exit_code=$?

  if [ $exit_code -ne 0 ] || [ -z "$GENERATED_YAML" ]; then
    echo "Error: Failed to generate YAML from mustache template"
    exit $EXIT_MUSTACHE_FAILED
  fi
}

# Create host directories from view.json file
create_host_directories_from_view() {
  local view_file="$1"

  if [ ! -f "$view_file" ]; then
    return 0
  fi

  if ! command -v jq &> /dev/null; then
    echo "Warning: jq not found - skipping host directory creation from view file"
    return 0
  fi

  # Extract host_ prefixed values and create directories
  local host_paths
  host_paths=$(cat "$view_file" | jq -r '. | to_entries[] | select(.key | startswith("host_")) | .value' 2>/dev/null)

  if [ $? -eq 0 ] && [ -n "$host_paths" ]; then
    echo "$host_paths" | while read -r dir; do
      if [ -n "$dir" ] && [ ! -d "$dir" ]; then
        echo "Creating host directory: $dir"
        sudo mkdir -p "$dir"
        sudo chown -R :docker "$dir"
      fi
    done
  fi
}

# Handle stack file deployment
handle_stack_file() {
  # Check for and handle override file
  local override_file
  override_file="$STACK_DIR/override.$(basename "$STACK_FILE")"

  if [ -f "$override_file" ]; then
    echo "Found override stack file: $override_file"
    read -rp "Do you want to deploy from the override file? (Y/n): " use_override
    if [[ ! "$use_override" =~ ^[Nn]$ ]]; then
      STACK_FILE="$override_file"
    fi
  fi

  # Set default env file for regular stacks
  ENV_FILE="$STACK_DIR/.env"

  create_host_directories "$ENV_FILE" "$STACK_DIR"
}

# Handle mustache template deployment
handle_mustache_template() {
  local template_file="$1"

  if ! command -v mustache &> /dev/null; then
    echo "Error: mustache not found - Mustache templates require the 'mustache' command to be installed."
    echo "You can install mustache using your package manager (e.g., 'npm install -g mustache' or 'apt install ruby-mustache')"
    exit $EXIT_MUSTACHE_FAILED
  fi

  local template_dir
  template_dir=$(dirname "$template_file")

  # Find available view files
  local available_view_files
  IFS=' ' read -ra available_view_files <<< "$(find_available_view_files "$template_dir")"

  # Select view file
  if ! select_view_file "$template_dir" "${available_view_files[*]}"; then
    exit $EXIT_INVALID_ARGS
  fi

  # Maybe adjust stack name
  maybe_adjust_stack_name

  # Auto-select corresponding env file based on view file
  select_env_file "$template_dir" "$VIEW_FILE"

  # Generate YAML from mustache template
  generate_yaml_from_mustache "$VIEW_FILE" "$STACK_FILE"

  # Create host directories from view file
  create_host_directories_from_view "$VIEW_FILE"
}

# Main execution flow
main() {
  validate_arguments "$@"

  if [[ "$STACK_FILE" == *.mustache ]]; then
    IS_MUSTACHE=true
  else
    IS_MUSTACHE=false
  fi

  STACK_DIR=$(dirname "$STACK_FILE")
  derive_stack_name

  # Check if this is a mustache template
  if [ "$IS_MUSTACHE" == true ]; then
    handle_mustache_template "$STACK_FILE"
  else
    # Handle regular stack file
    handle_stack_file
  fi

  create_secrets
  deploy_stack
}

# Run main function with all arguments
main "$@"
