#!/bin/bash
# update_requirements.sh - Update Python requirements file

# Exit on any error
set -e

# Function to update Python requirements file with absolute path to fyn-schema
update_requirements_file() {
  local source_req_file="$1"
  local output_dir="$2"
  local schema_path="$output_dir/fyn-schema/generated/python"
  
  echo "Updating requirements file with absolute path to fyn-schema..."
  
  # Check if the requirements file exists
  if [ ! -f "$source_req_file" ]; then
    echo "Error: Requirements file '$source_req_file' not found!" >&2
    exit 1
  fi
  
  # Check if the schema directory exists
  if [ ! -d "$schema_path" ]; then
    echo "Error: Schema package directory '$schema_path' not found!" >&2
    exit 1
  fi
  
  # Create the directory for the generated requirements file if it doesn't exist
  local dest_dir="$output_dir/fyn-env/environments/python"
  if [ ! -d "$dest_dir" ]; then
    mkdir -p "$dest_dir" || {
      echo "Error: Failed to create directory '$dest_dir'" >&2
      exit 1
    }
  fi
  
  # Define the output file path
  gen_req_file="$dest_dir/requirements_generated.txt"
  
  # Copy the source file to the destination
  cp "$source_req_file" "$gen_req_file" || {
    echo "Error: Failed to copy requirements file" >&2
    exit 1
  }
  
  # Find and replace the fyn-schema line using grep and sed
  if grep -q "fyn-schema" "$gen_req_file"; then
    # Use sed to replace the line containing fyn-schema with the correct path
    if [[ "$OSTYPE" == "darwin"* ]]; then
      # macOS requires different sed syntax
      sed -i '' "s|.*fyn-schema.*|-e \"$schema_path\"|g" "$gen_req_file" || {
        echo "Error: Failed to update fyn-schema reference in requirements file" >&2
        exit 1
      }
    else
      # Linux and others
      sed -i "s|.*fyn-schema.*|-e \"$schema_path\"|g" "$gen_req_file" || {
        echo "Error: Failed to update fyn-schema reference in requirements file" >&2
        exit 1
      }
    fi
    echo "Replaced fyn-schema reference with: -e \"$schema_path\""
  else
    echo "Error: Could not find 'fyn-schema' in requirements file \"$gen_req_file\"" >&2
    exit 1
  fi
  
  echo "Generated requirements file at: $gen_req_file"
  return 0
}