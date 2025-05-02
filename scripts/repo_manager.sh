#!/bin/bash

# Function to clone or update a repository with a specific version
clone_repo() {
  local repo_url=$1
  local version=$2
  local target_dir=$3
  local repo_name=$(basename "$repo_url" .git)
  
  echo "Cloning $repo_name ($version)..."
  
  if [ -d "$target_dir" ]; then
    echo "Directory $target_dir already exists. Updating..."
    cd "$target_dir"
    
    # Check if the repository is already cloned
    if git rev-parse --git-dir > /dev/null 2>&1; then
      # Fetch updates
      git fetch --all
      
      # Checkout specific version or branch
      if [ "$version" = "latest" ]; then
        git checkout main || git checkout master
        git pull
        echo "Checked out latest from main/master branch"
      else
        git checkout "$version" 2>/dev/null || git checkout -b "$version" 2>/dev/null || git checkout tags/"$version" 2>/dev/null
        if [ $? -ne 0 ]; then
          echo "Warning: Version $version not found. Using latest from main/master branch."
          git checkout main 2>/dev/null || git checkout master
          git pull
        fi
      fi
    else
      echo "Directory exists but is not a git repository. Removing and cloning fresh."
      cd ..
      rm -rf "$target_dir"
      git clone "$repo_url" "$target_dir"
      cd "$target_dir"
      
      if [ "$version" != "latest" ]; then
        git checkout "$version" 2>/dev/null || git checkout tags/"$version" 2>/dev/null
        if [ $? -ne 0 ]; then
          echo "Warning: Version $version not found. Using latest from main/master branch."
        fi
      fi
    fi
  else
    # Fresh clone
    git clone "$repo_url" "$target_dir"
    cd "$target_dir"
    
    if [ "$version" != "latest" ]; then
      git checkout "$version" 2>/dev/null || git checkout tags/"$version" 2>/dev/null
      if [ $? -ne 0 ]; then
        echo "Warning: Version $version not found. Using latest from main/master branch."
      fi
    fi
  fi
  
  cd - > /dev/null  # Return to previous directory
}