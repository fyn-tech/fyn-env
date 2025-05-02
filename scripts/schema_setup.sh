#!/bin/bash

# Function to set up the fyn-schema repository and generate Python models
setup_schema_repo() {
  local output_dir="$1"
  local schema_dir="$output_dir/fyn-schema"
  
  echo "Setting up fyn-schema repository..."
  
  # Check if the schema directory exists
  if [ ! -d "$schema_dir" ]; then
    echo "Error: Schema directory '$schema_dir' does not exist!" >&2
    return 1
  fi
  
  # Check if the generator script exists
  if [ ! -f "$schema_dir/generators/python/generate.py" ]; then
    echo "Error: Schema generator script not found!" >&2
    return 1
  fi
  
  # Generate Python models
  echo "Generating Python models from JSON schema..."
  
  # Check if Python 3 is installed
  if ! command -v python3 &> /dev/null; then
    echo "Error: Python 3 is required but not installed!" >&2
    return 1
  fi
  
  # Create a temporary virtual environment for generation if needed
  if [ ! -d "$schema_dir/generators/venv" ]; then
    echo "Creating temporary virtual environment for schema generation..."
    # Check if virtualenv is installed
    if ! command -v virtualenv &> /dev/null; then
      echo "Installing virtualenv..."
      pip3 install virtualenv
    fi
    
    # Create virtual environment
    virtualenv "$schema_dir/generators/venv"
    
    # Activate virtual environment and install requirements
    (
      if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
        # Windows
        source "$schema_dir/generators/venv/Scripts/activate"
      else
        # Unix-like
        source "$schema_dir/generators/venv/bin/activate"
      fi
      
      # Install datamodel-code-generator
      pip install datamodel-code-generator
    )
  fi
  
  # Run the generator script in the virtual environment
  echo "Running schema generator..."
  (
    if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
      # Windows
      source "$schema_dir/generators/venv/Scripts/activate"
    else
      # Unix-like
      source "$schema_dir/generators/venv/bin/activate"
    fi
    
    # Change to the schema repository directory and run the generator
    cd "$schema_dir"
    python generators/python/generate.py
  )
  
  # Check if generation was successful
  if [ ! -d "$schema_dir/generated/python" ]; then
    echo "Error: Failed to generate Python models!" >&2
    return 1
  fi
  
  echo "Schema repository setup complete."
}