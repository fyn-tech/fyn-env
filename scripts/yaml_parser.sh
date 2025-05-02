#!/bin/bash

# Function to parse YAML configuration file and extract environment-specific settings
parse_yaml_config() {
  local yaml_file="$1"
  local env_name="$2"
  
  # Find the start of the environment section
  start_line=$(grep -n "^  $env_name:" "$yaml_file" | cut -d: -f1)
  if [ -z "$start_line" ]; then
    echo "Error: Environment '$env_name' not found in $yaml_file" >&2
    exit 1
  fi

  # Extract lines relevant to this environment (adjust number if needed)
  env_lines=$(tail -n +$start_line "$yaml_file" | head -20)

  # Extract component versions
  environment_description=$(echo "$env_lines" | grep "description:" | sed 's/.*description:[[:space:]]*"\([^"]*\)".*/\1/')
  env_version=$(echo "$env_lines" | grep "fyn-env:" | awk '{print $2}')
  schema_version=$(echo "$env_lines" | grep "fyn-schema:" | awk '{print $2}')
  api_version=$(echo "$env_lines" | grep "fyn-api:" | awk '{print $2}')
  runner_version=$(echo "$env_lines" | grep "fyn-runner:" | awk '{print $2}')
  frontend_version=$(echo "$env_lines" | grep "fyn-frontend:" | awk '{print $2}')
  
  # Extract Python settings if they exist
  python_section=$(echo "$env_lines" | sed -n '/python:/,/^  [a-z]/p')
  if [ -n "$python_section" ]; then
    python_requirements=$(echo "$python_section" | grep "requirements:" | awk '{print $2}')
    python_venv=$(echo "$python_section" | grep "virtual_env:" | awk '{print $2}')
  fi

  # Check for missing values and provide defaults
  if [ -z "$env_version" ]; then
    echo "Warning: fyn-env version not found, using 'latest'"
    env_version="latest"
  fi
  
  if [ -z "$python_requirements" ]; then
    echo "Warning: Python requirements not found, using default"
    python_requirements="requirements_${env_name}.txt"
  fi
  
  if [ -z "$python_venv" ]; then
    echo "Warning: Python virtual environment name not found, using default"
    python_venv="venv_${env_name}"
  fi
}