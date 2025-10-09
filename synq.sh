#!/bin/bash

# Get the mode
MODE=$1

# Default location for repositories
DEFAULT_LOCATION="$HOME/Documents/code/github.com"
REPOSITORIES_FILE="repositories.yaml"

# Function to show usage
show_usage() {
    echo "Usage: $0 <mode> [location]"
    echo ""
    echo "Modes:"
    echo "  push    - List directories and add to repositories.yaml"
    echo "  pull    - Clone repositories from repositories.yaml"
    echo ""
    echo "Options:"
    echo "  location - Directory to scan/clone to (default: $DEFAULT_LOCATION)"
    echo ""
    echo "Examples:"
    echo "  $0 push"
    echo "  $0 push /path/to/repositories"
    echo "  $0 pull"
    echo "  $0 pull /path/to/clone/repositories"
}

# Function to implement push mode
push_mode() {
    local location="${2:-$DEFAULT_LOCATION}"
    
    echo "Scanning directory: $location"
    
    # Check if location exists
    if [ ! -d "$location" ]; then
        echo "Error: Directory '$location' does not exist"
        exit 1
    fi
    
    # Create temporary file for new repositories
    local temp_file=$(mktemp)
    
    # Start with the repositories header
    echo "repositories:" > "$temp_file"
    
    # Find all organization directories and then scan each for repositories
    find "$location" -maxdepth 1 -type d -not -path "$location" | while read -r org_dir; do
        local org_name=$(basename "$org_dir")
        echo "Scanning organization: $org_name"
        
        # Find all repository directories within each organization
        find "$org_dir" -maxdepth 1 -type d -not -path "$org_dir" | while read -r repo_dir; do
            local repo_name=$(basename "$repo_dir")
            echo "  - $org_name/$repo_name" >> "$temp_file"
        done
    done
    
    # Replace the repositories.yaml file
    mv "$temp_file" "$REPOSITORIES_FILE"
    
    echo "Successfully updated $REPOSITORIES_FILE with repositories from $location"
    
    # Count total repositories added
    local total_repos=$(grep -c "  - " "$REPOSITORIES_FILE" 2>/dev/null || echo "0")
    echo "Added $total_repos repositories"
}

# Function to implement pull mode
pull_mode() {
    local location="${2:-$DEFAULT_LOCATION}"
    
    echo "Cloning repositories to: $location"
    
    # Check if repositories.yaml exists
    if [ ! -f "$REPOSITORIES_FILE" ]; then
        echo "Error: $REPOSITORIES_FILE not found. Run 'push' mode first to generate it."
        exit 1
    fi
    
    # Check if location exists, create if it doesn't
    if [ ! -d "$location" ]; then
        echo "Creating directory: $location"
        mkdir -p "$location"
    fi
    
    local cloned_count=0
    local skipped_count=0
    
    # Read repositories from YAML file and clone each one
    grep "  - " "$REPOSITORIES_FILE" | sed 's/  - //' | while read -r repo_path; do
        local org_name=$(echo "$repo_path" | cut -d'/' -f1)
        local repo_name=$(echo "$repo_path" | cut -d'/' -f2)
        local full_path="$location/$org_name/$repo_name"
        local git_url="https://github.com/$repo_path.git"
        
        echo "Processing: $repo_path"
        
        # Create organization directory if it doesn't exist
        mkdir -p "$location/$org_name"
        
        # Check if repository already exists
        if [ -d "$full_path" ]; then
            echo "  ✓ Repository already exists, skipping: $repo_path"
            skipped_count=$((skipped_count + 1))
        else
            echo "  📥 Cloning: $git_url"
            if git clone "$git_url" "$full_path" 2>/dev/null; then
                echo "  ✓ Successfully cloned: $repo_path"
                cloned_count=$((cloned_count + 1))
            else
                echo "  ✗ Failed to clone: $repo_path"
            fi
        fi
    done
    
    echo ""
    echo "Clone operation completed!"
    echo "Cloned: $cloned_count repositories"
    echo "Skipped: $skipped_count repositories (already exist)"
}

# Main script logic
case "$MODE" in
    "push")
        push_mode "$@"
        ;;
    "pull")
        pull_mode "$@"
        ;;
    "help"|"-h"|"--help"|"")
        show_usage
        ;;
    *)
        echo "Error: Unknown mode '$MODE'"
        echo ""
        show_usage
        exit 1
        ;;
esac