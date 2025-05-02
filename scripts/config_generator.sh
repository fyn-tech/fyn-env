#!/bin/bash

# Function to generate configuration files
generate_config_files() {
  local output_dir="$1"
  local env_flag="$2"
  local schema_version="$3"
  local api_version="$4"
  local runner_version="$5"
  local frontend_version="$6"
  local description="$7"

  # Generate shell configuration file
  cat > "$output_dir/env-config.sh" << EOF
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
  chmod +x "$output_dir/env-config.sh"

  # Generate YAML configuration file
  cat > "$output_dir/env-config.yaml" << EOF
# Generated environment configuration - $(date)
environment: $env_flag
description: "$description"
components:
  fyn-schema: $schema_version
  fyn-api: $api_version
  fyn-runner: $runner_version
  fyn-frontend: $frontend_version
EOF

  echo "Configuration files generated in $output_dir/"
}