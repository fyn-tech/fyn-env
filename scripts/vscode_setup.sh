#!/bin/bash

# Function to create a VSCode workspace file
create_vscode_workspace() {
  local output_dir="$1"
  local env_name="$2"
  
  echo "Creating VSCode workspace file..."
  
  # Define the workspace filename
  local workspace_file="$output_dir/fyn-tech.code-workspace"
  
  # Create the workspace JSON file with fixed formatting
  cat > "$workspace_file" << EOF
{
  "folders": [
    {
      "path": "fyn-env"
    },
    {
      "path": "fyn-schema"
    },
    {
      "path": "fyn-api"
    },
    {
      "path": "fyn-runner"
    },
    {
      "path": "fyn-front"
    }
  ],
  "settings": {
    "python.defaultInterpreterPath": "${output_dir}/venv_${env_name}/bin/python",
    "python.terminal.activateEnvironment": true
  }
}
EOF

  echo "VSCode workspace created at: $workspace_file"
}