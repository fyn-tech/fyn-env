#!/bin/bash

# Function to parse command line arguments
parse_args() {
  # Default values
  env_flag=""
  yaml_file="./versions/environment.yaml"  # Default to consolidated file
  output_dir="./output"  # Default output directory

  while [ $# -gt 0 ]; do
    case "$1" in
      --development)
        env_flag="development"
        shift
        ;;
      --staging)
        env_flag="staging"
        shift
        ;;
      --production)
        env_flag="production"
        shift
        ;;
      --version_file)
        if [ $# -gt 1 ] && [[ "$2" != --* ]]; then
          yaml_file="$2"
          shift 2  # Skip both the flag and its value
        else
          echo "Error: --version_file requires a filename" >&2
          exit 1
        fi
        ;;
      --output_directory)
        if [ $# -gt 1 ] && [[ "$2" != --* ]]; then
          output_dir="$2"
          shift 2  # Skip both the flag and its value
        else
          echo "Error: --output_directory requires a directory" >&2
          exit 1
        fi
        ;;
      *)
        echo "Invalid option: $1" >&2
        echo "Usage: $0 [--development|--staging|--production] [--version_file YAML_FILE] [--output_directory OUTPUT_DIR]"
        exit 1
        ;;
    esac
  done

  # Set default if no environment specified
  if [ -z "$env_flag" ]; then
    echo "No environment specified, defaulting to production"
    env_flag="production"
  fi

  # Check if yaml file exists
  if [ ! -f "$yaml_file" ]; then
    echo "Error: YAML file '$yaml_file' does not exist" >&2
    exit 1
  fi
}