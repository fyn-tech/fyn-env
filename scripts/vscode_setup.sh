#!/bin/bash
# vscode_setup.sh - Create VS Code workspace file

# Exit on any error
set -e

# Function to create a VSCode workspace file
create_vscode_workspace() {
  local output_dir="$1"
  local env_name="$2"
  
  echo "Creating VSCode workspace file..."
  
  # Define the workspace filename
  local workspace_file="$output_dir/fyn-tech.code-workspace"
  
  # Determine the correct path format for the Python interpreter
  local python_path
  if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    # Windows
    python_path="\${workspaceFolder}/../venv_${env_name}/Scripts/python.exe"
  else
    # Unix-like
    python_path="\${workspaceFolder}/../venv_${env_name}/bin/python"
  fi
  
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
    "python.defaultInterpreterPath": "$python_path",
    "python.terminal.activateEnvironment": true,
    "python.linting.enabled": true,
    "python.linting.pylintEnabled": true,
    "python.linting.flake8Enabled": true,
    "editor.formatOnSave": true,
    "python.formatting.provider": "black"
  }
}
EOF

  echo "VSCode workspace created at: $workspace_file"
}