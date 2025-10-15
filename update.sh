#!/usr/bin/env bash

set -e

BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
ORG="socketry"
REPO_LIST_FILE="$BASE_DIR/.repo_list.json"

echo "=========================================="
echo "Socketry Repository Update Script"
echo "=========================================="
echo ""

# Function to get all non-archived repos from GitHub
fetch_current_repos() {
    local page=1
    local all_repos="[]"
    
    while true; do
        local response=$(curl -s "https://api.github.com/orgs/$ORG/repos?per_page=100&page=$page")
        local count=$(echo "$response" | jq '. | length')
        
        if [ "$count" -eq 0 ]; then
            break
        fi
        
        local non_archived=$(echo "$response" | jq '[.[] | select(.archived == false) | {name: .name, clone_url: .clone_url}]')
        all_repos=$(echo "$all_repos $non_archived" | jq -s 'add')
        
        ((page++))
    done
    
    echo "$all_repos"
}

# Function to update existing repositories
update_repos() {
    echo "Updating existing repositories..."
    echo ""
    
    local updated=0
    local skipped=0
    local failed=0
    
    # Find all git repositories
    for category_dir in "$BASE_DIR"/[0-9]*; do
        if [ ! -d "$category_dir" ]; then
            continue
        fi
        
        for repo_dir in "$category_dir"/*; do
            if [ ! -d "$repo_dir" ] || [ ! -d "$repo_dir/.git" ]; then
                continue
            fi
            
            repo_name=$(basename "$repo_dir")
            
            echo -n "  Updating $repo_name... "
            
            cd "$repo_dir"
            
            # Check if there are any changes
            git fetch origin --quiet
            
            LOCAL=$(git rev-parse @ 2>/dev/null || echo "")
            REMOTE=$(git rev-parse @{u} 2>/dev/null || echo "")
            
            if [ "$LOCAL" = "$REMOTE" ]; then
                echo "✓ up-to-date"
                ((skipped++))
            else
                if git pull --quiet; then
                    echo "✓ updated"
                    ((updated++))
                else
                    echo "✗ failed"
                    ((failed++))
                fi
            fi
            
            cd "$BASE_DIR"
        done
    done
    
    echo ""
    echo "Update Summary:"
    echo "  - Updated: $updated"
    echo "  - Up-to-date: $skipped"
    echo "  - Failed: $failed"
    echo ""
}

# Function to check for new repositories
check_new_repos() {
    echo "Checking for new repositories..."
    echo ""
    
    local current_repos=$(fetch_current_repos)
    
    # Save current repo list
    echo "$current_repos" | jq '.' > "$REPO_LIST_FILE"
    
    # Get list of currently cloned repos
    local cloned_repos=()
    for category_dir in "$BASE_DIR"/[0-9]*; do
        if [ ! -d "$category_dir" ]; then
            continue
        fi
        for repo_dir in "$category_dir"/*; do
            if [ -d "$repo_dir" ] && [ -d "$repo_dir/.git" ]; then
                cloned_repos+=("$(basename "$repo_dir")")
            fi
        done
    done
    
    # Check for new repos
    local new_repos=()
    while IFS= read -r repo_name; do
        local found=0
        for cloned in "${cloned_repos[@]}"; do
            if [ "$cloned" = "$repo_name" ]; then
                found=1
                break
            fi
        done
        
        if [ $found -eq 0 ]; then
            new_repos+=("$repo_name")
        fi
    done < <(echo "$current_repos" | jq -r '.[].name')
    
    if [ ${#new_repos[@]} -eq 0 ]; then
        echo "  No new repositories found."
    else
        echo "  Found ${#new_repos[@]} new repository/repositories:"
        for repo in "${new_repos[@]}"; do
            echo "    - $repo"
        done
        echo ""
        echo "  To clone these repositories, add them to the appropriate"
        echo "  category directory or run the initial setup again."
    fi
    
    echo ""
}

# Function to display statistics
display_stats() {
    echo "Repository Statistics:"
    echo ""
    
    for category_dir in "$BASE_DIR"/[0-9]*; do
        if [ -d "$category_dir" ]; then
            category_name=$(basename "$category_dir" | sed 's/^[0-9]*-//')
            repo_count=$(find "$category_dir" -mindepth 1 -maxdepth 1 -type d | wc -l)
            echo "  - $category_name: $repo_count repos"
        fi
    done
    
    echo ""
    local total=0
    for category_dir in "$BASE_DIR"/[0-9]*; do
        if [ -d "$category_dir" ]; then
            count=$(find "$category_dir" -mindepth 1 -maxdepth 1 -type d -name ".git" | wc -l | xargs)
            total=$((total + count))
        fi
    done
    echo "  Total: $total repositories"
    echo ""
}

# Main execution
update_repos
check_new_repos
display_stats

echo "=========================================="
echo "Update complete!"
echo "=========================================="
