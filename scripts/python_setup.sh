#!/bin/bash
# python_setup.sh - Set up Python virtual environment

# Exit on any error
set -e

# Function to set up Python virtual environment and install requirements
setup_python_env() {
  local env_name="$1"
  local requirements_file="$2"
  local venv_name="$3"
  local output_dir="$4"
  
  echo "Setting up Python environment for $env_name"
  
  # Check if requirements file exists
  if [ ! -f "$requirements_file" ]; then
    echo "Error: Python requirements file '$requirements_file' not found." >&2
    exit 1
  fi
  
  # Full path to the virtual environment
  local venv_path="$output_dir/$venv_name"
  
  # Check if Python 3 is installed
  if ! command -v python3 &> /dev/null; then
    echo "Error: Python 3 is required but not installed!" >&2
    exit 1
  fi
  
  # Check if virtualenv is installed
  if ! command -v virtualenv &> /dev/null; then
    echo "Installing virtualenv..."
    pip3 install virtualenv || {
      echo "Error: Failed to install virtualenv" >&2
      exit 1
    }
  fi
  
  # Create or update virtual environment
  if [ -d "$venv_path" ]; then
    echo "Python virtual environment already exists at $venv_path"
  else
    echo "Creating Python virtual environment at $venv_path"
    virtualenv "$venv_path" || {
      echo "Error: Failed to create virtual environment" >&2
      exit 1
    }
  fi
  
  # Determine activation script based on OS
  if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    # Windows
    activate_script="$venv_path/Scripts/activate"
  else
    # Unix-like
    activate_script="$venv_path/bin/activate"
  fi
  
  # Check if activation script exists
  if [ ! -f "$activate_script" ]; then
    echo "Error: Virtual environment activation script not found at $activate_script" >&2
    exit 1
  fi
  
  # Activate virtual environment and install requirements
  echo "Installing Python requirements from $requirements_file"
  # Use a subshell to avoid affecting the parent shell's environment
  (
    # Source the virtual environment activation script
    source "$activate_script" || {
      echo "Error: Failed to activate virtual environment" >&2
      exit 1
    }
    
    # Install/update requirements
    pip install -r "$requirements_file" || {
      echo "Error: Failed to install Python requirements" >&2
      exit 1
    }
  ) || {
    echo "Error: Failed to set up Python environment" >&2
    exit 1
  }
  
  echo "Python environment setup complete"
}