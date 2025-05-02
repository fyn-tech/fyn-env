#!/bin/bash
# config_generator.sh - Generate configuration files for environment

# Exit on any error
set -e

# Function to generate configuration files
generate_config_files() {
  local output_dir="$1"
  local env_flag="$2"
  local schema_version="$3"
  local api_version="$4"
  local runner_version="$5"
  local frontend_version="$6"
  local description="$7"

  # Ensure output directory exists
  if [ ! -d "$output_dir" ]; then
    echo "Creating output directory: $output_dir"
    mkdir -p "$output_dir" || {
      echo "Error: Failed to create output directory $output_dir" >&2
      exit 1
    }
  fi

  echo "Generating configuration files for $env_flag environment..."

  # Generate shell configuration file
  config_file="$output_dir/env-config.sh"
  echo "Creating shell configuration: $config_file"
  
  cat > "$config_file" << EOF
#!/bin/bash
# Generated environment configuration - $(date)
# Environment: $env_flag

export FYN_ENV="$env_flag"
export FYN_SCHEMA_VERSION="$schema_version"
export FYN_API_VERSION="$api_version"
export FYN_RUNNER_VERSION="$runner_version"
export FYN_FRONTEND_VERSION="$frontend_version"
EOF

  # Make it executable
  chmod +x "$config_file" || {
    echo "Error: Failed to make $config_file executable" >&2
    exit 1
  }

  # Generate YAML configuration file
  yaml_file="$output_dir/env-config.yaml"
  echo "Creating YAML configuration: $yaml_file"
  
  cat > "$yaml_file" << EOF
# Generated environment configuration - $(date)
environment: $env_flag
description: "$description"
components:
  fyn-schema: $schema_version
  fyn-api: $api_version
  fyn-runner: $runner_version
  fyn-frontend: $frontend_version
EOF

  echo "Configuration files generated successfully."
}