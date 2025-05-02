#!/bin/bash
# schema_setup.sh - Set up schema repository and generate models

# Exit on any error
set -e

# Function to set up the fyn-schema repository and generate Python models
setup_schema_repo() {
  local output_dir="$1"
  local schema_dir="$output_dir/fyn-schema"
  
  echo "Setting up fyn-schema repository..."
  
  # Check if the schema directory exists
  if [ ! -d "$schema_dir" ]; then
    echo "Error: Schema directory '$schema_dir' does not exist!" >&2
    exit 1
  fi
  
  # Check if the generator script exists
  generator_script="$schema_dir/generators/python/generate.py"
  if [ ! -f "$generator_script" ]; then
    echo "Error: Schema generator script not found at '$generator_script'!" >&2
    exit 1
  fi
  
  # Generate Python models
  echo "Generating Python models from JSON schema..."
  
  # Check if Python 3 is installed
  if ! command -v python3 &> /dev/null; then
    echo "Error: Python 3 is required but not installed!" >&2
    exit 1
  fi
  
  # Create a temporary virtual environment for generation if needed
  venv_path="$schema_dir/generators/venv"
  if [ ! -d "$venv_path" ]; then
    echo "Creating temporary virtual environment for schema generation..."
    
    # Check if virtualenv is installed
    if ! command -v virtualenv &> /dev/null; then
      echo "Installing virtualenv..."
      pip3 install virtualenv || {
        echo "Error: Failed to install virtualenv" >&2
        exit 1
      }
    fi
    
    # Create virtual environment
    virtualenv "$venv_path" || {
      echo "Error: Failed to create virtual environment" >&2
      exit 1
    }
    
    # Activate virtual environment and install requirements
    (
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
      
      # Source the activation script
      source "$activate_script" || {
        echo "Error: Failed to activate virtual environment" >&2
        exit 1
      }
      
      # Install datamodel-code-generator
      pip install datamodel-code-generator || {
        echo "Error: Failed to install datamodel-code-generator" >&2
        exit 1
      }
    ) || {
      echo "Error: Failed to set up virtual environment dependencies" >&2
      exit 1
    }
  fi
  
  # Run the generator script in the virtual environment
  echo "Running schema generator..."
  (
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
    
    # Source the activation script
    source "$activate_script" || {
      echo "Error: Failed to activate virtual environment" >&2
      exit 1
    }
    
    # Change to the schema repository directory and run the generator
    cd "$schema_dir" || {
      echo "Error: Failed to change to schema directory" >&2
      exit 1
    }
    
    python generators/python/generate.py || {
      echo "Error: Failed to run schema generator" >&2
      exit 1
    }
  ) || {
    echo "Error: Failed to generate schema models" >&2
    exit 1
  }
  
  # Check if generation was successful
  if [ ! -d "$schema_dir/generated/python" ]; then
    echo "Error: Failed to generate Python models - directory not created!" >&2
    exit 1
  fi
  
  echo "Schema repository setup complete."
}