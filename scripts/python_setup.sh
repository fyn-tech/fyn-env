#!/bin/bash

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
    return 1
  fi
  
  # Full path to the virtual environment
  local venv_path="$output_dir/$venv_name"
  
  # Check if Python 3 is installed
  if ! command -v python3 &> /dev/null; then
    echo "Error: Python 3 is required but not installed!" >&2
    return 1
  fi
  
  # Check if virtualenv is installed
  if ! command -v virtualenv &> /dev/null; then
    echo "Installing virtualenv..."
    pip3 install virtualenv
  fi
  
  # Create or update virtual environment
  if [ -d "$venv_path" ]; then
    echo "Python virtual environment already exists at $venv_path"
  else
    echo "Creating Python virtual environment at $venv_path"
    virtualenv "$venv_path"
  fi
  
  # Activate virtual environment and install requirements
  echo "Installing Python requirements from $requirements_file"
  # Use a subshell to avoid affecting the parent shell's environment
  (
    # Source the virtual environment activation script
    if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
      # Windows
      source "$venv_path/Scripts/activate"
    else
      # Unix-like
      source "$venv_path/bin/activate"
    fi
    
    # Install/update requirements
    pip install -r "$requirements_file"
    
  )
  
  echo "Python environment setup complete"
}