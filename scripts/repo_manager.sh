#!/bin/bash
# repo_manager.sh - Clone and manage git repositories

# Exit on any error
set -e

# Function to clone or update a repository with a specific version
clone_repo() {
  local repo_url=$1
  local version=$2
  local target_dir=$3
  local repo_name=$(basename "$repo_url" .git)
  
  echo "Cloning $repo_name ($version)..."
  
  if [ -d "$target_dir" ]; then
    echo "Directory $target_dir already exists."
    
    # Change to target directory
    cd "$target_dir" || {
      echo "Error: Failed to change to directory $target_dir" >&2
      exit 1
    }
    
    # Check if the repository is already cloned
    if git rev-parse --git-dir > /dev/null 2>&1; then
      echo "Updating existing repository..."
      
      # Fetch updates
      git fetch --all || {
        echo "Error: Failed to fetch updates for $repo_name" >&2
        exit 1
      }
      
      # Stash any local changes
      git stash || true
      
      # Checkout specific version or branch
      if [ "$version" = "latest" ]; then
        # Try to checkout main branch first, if not, try master
        if git show-ref --verify --quiet refs/remotes/origin/main; then
          git checkout main || {
            echo "Error: Failed to checkout main branch for $repo_name" >&2
            exit 1
          }
        else
          git checkout master || {
            echo "Error: Failed to checkout master branch for $repo_name" >&2
            exit 1
          }
        fi
        
        # Pull latest changes
        git pull || {
          echo "Error: Failed to pull latest changes for $repo_name" >&2
          exit 1
        }
        
        echo "Checked out latest from main/master branch"
      else
        # Try to checkout the specific version
        if git show-ref --verify --quiet "refs/tags/$version" 2>/dev/null; then
          # Version is a tag
          git checkout "tags/$version" || {
            echo "Error: Failed to checkout tag $version for $repo_name" >&2
            exit 1
          }
        elif git show-ref --verify --quiet "refs/remotes/origin/$version" 2>/dev/null; then
          # Version is a branch
          git checkout "$version" || {
            echo "Error: Failed to checkout branch $version for $repo_name" >&2
            exit 1
          }
          git pull origin "$version" || {
            echo "Error: Failed to pull latest changes for branch $version" >&2
            exit 1
          }
        else
          # Version might be a commit hash
          if git rev-parse --quiet --verify "$version^{commit}" >/dev/null 2>&1; then
            git checkout "$version" || {
              echo "Error: Failed to checkout commit $version for $repo_name" >&2
              exit 1
            }
          else
            echo "Warning: Version $version not found. Using latest from main/master branch."
            # Try to checkout main branch first, if not, try master
            if git show-ref --verify --quiet refs/remotes/origin/main; then
              git checkout main || git checkout master || {
                echo "Error: Failed to checkout main/master branch for $repo_name" >&2
                exit 1
              }
            else
              git checkout master || {
                echo "Error: Failed to checkout master branch for $repo_name" >&2
                exit 1
              }
            fi
            git pull || {
              echo "Error: Failed to pull latest changes for $repo_name" >&2
              exit 1
            }
          fi
        fi
      fi
    else
      echo "Directory exists but is not a git repository. Re-cloning..."
      cd .. || {
        echo "Error: Failed to change to parent directory" >&2
        exit 1
      }
      rm -rf "$target_dir" || {
        echo "Error: Failed to remove directory $target_dir" >&2
        exit 1
      }
      
      # Fresh clone
      git clone "$repo_url" "$target_dir" || {
        echo "Error: Failed to clone repository $repo_url" >&2
        exit 1
      }
      
      # Change to the newly cloned repository
      cd "$target_dir" || {
        echo "Error: Failed to change to directory $target_dir" >&2
        exit 1
      }
      
      # Checkout specific version if not latest
      if [ "$version" != "latest" ]; then
        if git show-ref --verify --quiet "refs/tags/$version" 2>/dev/null; then
          git checkout "tags/$version" || {
            echo "Error: Failed to checkout tag $version for $repo_name" >&2
            exit 1
          }
        elif git show-ref --verify --quiet "refs/remotes/origin/$version" 2>/dev/null; then
          git checkout "$version" || {
            echo "Error: Failed to checkout branch $version for $repo_name" >&2
            exit 1
          }
        elif git rev-parse --quiet --verify "$version^{commit}" >/dev/null 2>&1; then
          git checkout "$version" || {
            echo "Error: Failed to checkout commit $version for $repo_name" >&2
            exit 1
          }
        else
          echo "Warning: Version $version not found. Using latest from main/master branch."
        fi
      fi
    fi
  else
    # Fresh clone
    git clone "$repo_url" "$target_dir" || {
      echo "Error: Failed to clone repository $repo_url" >&2
      exit 1
    }
    
    # Change to the newly cloned repository
    cd "$target_dir" || {
      echo "Error: Failed to change to directory $target_dir" >&2
      exit 1
    }
    
    # Checkout specific version if not latest
    if [ "$version" != "latest" ]; then
      if git show-ref --verify --quiet "refs/tags/$version" 2>/dev/null; then
        git checkout "tags/$version" || {
          echo "Error: Failed to checkout tag $version for $repo_name" >&2
          exit 1
        }
      elif git show-ref --verify --quiet "refs/remotes/origin/$version" 2>/dev/null; then
        git checkout "$version" || {
          echo "Error: Failed to checkout branch $version for $repo_name" >&2
          exit 1
        }
      elif git rev-parse --quiet --verify "$version^{commit}" >/dev/null 2>&1; then
        git checkout "$version" || {
          echo "Error: Failed to checkout commit $version for $repo_name" >&2
          exit 1
        }
      else
        echo "Warning: Version $version not found. Using latest from main/master branch."
      fi
    fi
  fi
  
  # Return to the original directory
  cd - > /dev/null || {
    echo "Error: Failed to change back to original directory" >&2
    exit 1
  }
}