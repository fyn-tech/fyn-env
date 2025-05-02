#!/bin/bash
# setup.sh - Master setup script for fyn environments

# Exit on any error
set -e

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

# Show banner
echo "========================================"
echo "  Fyn Environment Setup Tool"
echo "========================================"
echo

# Parse command line arguments
parse_args "$@"

# Extract configuration from YAML file
parse_yaml_config "$yaml_file" "$env_flag"

# Create output directory if it doesn't exist
if [ ! -d "$output_dir" ]; then
  mkdir -p "$output_dir" || {
    echo "Error: Failed to create output directory" >&2
    exit 1
  }
fi

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
echo -e "\nStep 1: Cloning repositories..."
# Clone the environment repository itself
clone_repo "git@github.com:fyn-tech/fyn-env.git" "$env_version" "$output_dir/fyn-env"
clone_repo "git@github.com:fyn-tech/fyn-schema.git" "$schema_version" "$output_dir/fyn-schema"
clone_repo "git@github.com:fyn-tech/fyn-api.git" "$api_version" "$output_dir/fyn-api"
clone_repo "git@github.com:fyn-tech/fyn-runner.git" "$runner_version" "$output_dir/fyn-runner"
clone_repo "git@github.com:fyn-tech/fyn-front.git" "$frontend_version" "$output_dir/fyn-front"

# Set up schema repository first
echo -e "\nStep 2: Setting up schema repository..."
setup_schema_repo "$output_dir"

# Generate configuration files
echo -e "\nStep 3: Generating configuration files..."
generate_config_files "$output_dir" "$env_flag" "$schema_version" "$api_version" "$runner_version" "$frontend_version" "$environment_description"

# Update the requirements file with the correct schema path
echo -e "\nStep 4: Updating requirements file..."
# First, check if the requirements file exists in the current directory
if [ -f "environments/python/$python_requirements" ]; then
  requirement_source_path="environments/python/$python_requirements"
else
  # Check if it exists in the cloned fyn-env repository
  requirement_source_path="$output_dir/fyn-env/environments/python/$python_requirements"
  if [ ! -f "$requirement_source_path" ]; then
    echo "Error: Requirements file not found at either locations:" >&2
    echo "  - environments/python/$python_requirements" >&2
    echo "  - $requirement_source_path" >&2
    exit 1
  fi
fi

# Update the requirements file
update_requirements_file "$requirement_source_path" "$output_dir"

# Set up Python environment
echo -e "\nStep 5: Setting up Python environment..."
# Make sure we have the generated requirements file
gen_req_file="$output_dir/fyn-env/environments/python/requirements_generated.txt"
if [ ! -f "$gen_req_file" ]; then
  echo "Error: Generated requirements file not found at $gen_req_file" >&2
  exit 1
fi

# Set up the Python environment
setup_python_env "$env_flag" "$gen_req_file" "$python_venv" "$output_dir"

# Create VSCode workspace file
echo -e "\nStep 6: Creating VSCode workspace file..."
create_vscode_workspace "$output_dir" "$env_flag"

echo -e "\n========================================"
echo " Environment setup complete"
echo "========================================"
echo "Configuration files created in $output_dir/"
echo "To activate environment: source $output_dir/env-config.sh"
echo "To open in VSCode: code $output_dir/fyn-tech.code-workspace"
echo "========================================"