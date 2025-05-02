#!/bin/bash

# Master setup script for fyn environments
# This script orchestrates the environment setup process

# Source utility scripts
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/scripts/parse_args.sh"
source "${SCRIPT_DIR}/scripts/yaml_parser.sh"
source "${SCRIPT_DIR}/scripts/repo_manager.sh"
source "${SCRIPT_DIR}/scripts/config_generator.sh"
source "${SCRIPT_DIR}/scripts/schema_setup.sh"
source "${SCRIPT_DIR}/scripts/update_requirements.sh"
source "${SCRIPT_DIR}/scripts/python_setup.sh"
source "${SCRIPT_DIR}/scripts/vscode_setup.sh"

# Parse command line arguments
parse_args "$@"

# Extract configuration from YAML file
parse_yaml_config "$yaml_file" "$env_flag"

# Create output directory if it doesn't exist
mkdir -p "$output_dir"

echo "Using config file: $yaml_file"
echo "Setting up $env_flag environment"
echo "Output directory: $output_dir"
echo "Environment: $environment_description"

# Print component versions
echo "Components:"
echo "  fyn-env: $env_version"
echo "  fyn-schema: $schema_version"
echo "  fyn-api: $api_version"
echo "  fyn-runner: $runner_version"
echo "  fyn-frontend: $frontend_version"

# Clone repositories
echo "Cloning repositories..."
# Clone the environment repository itself
clone_repo "git@github.com:fyn-tech/fyn-env.git" "$env_version" "$output_dir/fyn-env"
clone_repo "git@github.com:fyn-tech/fyn-schema.git" "$schema_version" "$output_dir/fyn-schema"
clone_repo "git@github.com:fyn-tech/fyn-api.git" "$api_version" "$output_dir/fyn-api"
clone_repo "git@github.com:fyn-tech/fyn-runner.git" "$runner_version" "$output_dir/fyn-runner"
clone_repo "git@github.com:fyn-tech/fyn-front.git" "$frontend_version" "$output_dir/fyn-front"

# Set up schema repository first
echo "Setting up schema repository..."
setup_schema_repo "$output_dir"

# Generate configuration files
generate_config_files "$output_dir" "$env_flag" "$env_version" "$schema_version" "$api_version" "$runner_version" "$frontend_version" "$environment_description"

# Update the requirements file with the correct schema path
echo "Updating requirements file..."
update_requirements_file "environments/python/$python_requirements" "$output_dir" "$gen_req_file"
  
# Set up Python environment if specified
# Generate a new requirements file with the correct schema path
echo "Setting up Python environment..."
setup_python_env "$env_flag" "$gen_req_file" "$python_venv" "$output_dir"

# Create VSCode workspace file
create_vscode_workspace "$output_dir" "$env_flag"

echo "Environment setup complete. Configuration files created in $output_dir/"
echo "To use: source $output_dir/env-config.sh"
echo "To open in VSCode: code $output_dir/fyn-tech.code-workspace"