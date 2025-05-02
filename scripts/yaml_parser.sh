#!/bin/bash
# yaml_parser.sh - Parse YAML configuration file

# Exit on any error
set -e

# Function to parse YAML configuration file and extract environment-specific settings
parse_yaml_config() {
  local yaml_file="$1"
  local env_name="$2"
  
  # Check if the file exists
  if [ ! -f "$yaml_file" ]; then
    echo "Error: YAML file '$yaml_file' does not exist" >&2
    exit 1
  fi
  
  # Find the start of the environment section
  start_line=$(grep -n "^[[:space:]]*$env_name:" "$yaml_file" | cut -d: -f1)
  if [ -z "$start_line" ]; then
    echo "Error: Environment '$env_name' not found in $yaml_file" >&2
    exit 1
  fi

  # Extract all lines from the file
  all_lines=$(cat "$yaml_file")
  
  # Extract environment description
  environment_description=$(echo "$all_lines" | grep -A 20 "^[[:space:]]*$env_name:" | grep "description:" | head -1 | sed 's/.*description:[[:space:]]*"\([^"]*\)".*/\1/')
  
  # Extract component versions
  schema_version=$(echo "$all_lines" | grep -A 20 "^[[:space:]]*$env_name:" | grep "fyn-schema:" | head -1 | awk '{print $2}')
  api_version=$(echo "$all_lines" | grep -A 20 "^[[:space:]]*$env_name:" | grep "fyn-api:" | head -1 | awk '{print $2}')
  runner_version=$(echo "$all_lines" | grep -A 20 "^[[:space:]]*$env_name:" | grep "fyn-runner:" | head -1 | awk '{print $2}')
  frontend_version=$(echo "$all_lines" | grep -A 20 "^[[:space:]]*$env_name:" | grep "fyn-frontend:" | head -1 | awk '{print $2}')
  env_version=$(echo "$all_lines" | grep -A 20 "^[[:space:]]*$env_name:" | grep "fyn-env:" | head -1 | awk '{print $2}')
  
  # Extract Python settings
  python_section=$(echo "$all_lines" | grep -A 20 "^[[:space:]]*$env_name:" | sed -n '/python:/,/^[[:space:]]*[a-z]/p')
  if [ -n "$python_section" ]; then
    python_requirements=$(echo "$python_section" | grep "requirements:" | head -1 | awk '{print $2}')
    python_venv=$(echo "$python_section" | grep "virtual_env:" | head -1 | awk '{print $2}')
  fi

  # Check for missing values and provide defaults
  if [ -z "$environment_description" ]; then
    environment_description="$env_name Environment"
    echo "Warning: Environment description not found, using default: '$environment_description'"
  fi
  
  if [ -z "$env_version" ]; then
    env_version="latest"
    echo "Warning: fyn-env version not found, using '$env_version'"
  fi
  
  if [ -z "$schema_version" ]; then
    schema_version="latest"
    echo "Warning: fyn-schema version not found, using '$schema_version'"
  fi
  
  if [ -z "$api_version" ]; then
    api_version="latest"
    echo "Warning: fyn-api version not found, using '$api_version'"
  fi
  
  if [ -z "$runner_version" ]; then
    runner_version="latest"
    echo "Warning: fyn-runner version not found, using '$runner_version'"
  fi
  
  if [ -z "$frontend_version" ]; then
    frontend_version="latest"
    echo "Warning: fyn-frontend version not found, using '$frontend_version'"
  fi
  
  if [ -z "$python_requirements" ]; then
    python_requirements="requirements_${env_name}.txt"
    echo "Warning: Python requirements file not found, using '$python_requirements'"
  fi
  
  if [ -z "$python_venv" ]; then
    python_venv="venv_${env_name}"
    echo "Warning: Python virtual environment name not found, using '$python_venv'"
  fi
  
  # Validate that we have all necessary information
  if [ -z "$schema_version" ] || [ -z "$api_version" ] || [ -z "$runner_version" ] || [ -z "$frontend_version" ]; then
    echo "Error: Missing required component versions in YAML file for $env_name environment" >&2
    exit 1
  fi
}