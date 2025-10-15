#!/usr/bin/env bash

set -e

BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
UNSORTED_DIR="$BASE_DIR/unsorted"
ORG="socketry"

echo "Fetching repositories from $ORG organization..."

# Create unsorted directory
mkdir -p "$UNSORTED_DIR"

# Fetch all repositories from the organization
page=1
while true; do
    echo "Fetching page $page..."
    
    response=$(curl -s "https://api.github.com/orgs/$ORG/repos?per_page=100&page=$page")
    
    # Check if we got an empty array (no more pages)
    if [ "$(echo "$response" | jq '. | length')" -eq 0 ]; then
        break
    fi
    
    # Extract non-archived repos
    echo "$response" | jq -r '.[] | select(.archived == false) | .clone_url + " " + .name' | while read -r clone_url name; do
        if [ -d "$UNSORTED_DIR/$name" ]; then
            echo "  [SKIP] $name already exists"
        else
            echo "  [CLONE] Cloning $name..."
            cd "$UNSORTED_DIR"
            git clone "$clone_url" "$name" 2>&1 | grep -E "(Cloning|done)"
            cd "$BASE_DIR"
        fi
    done
    
    ((page++))
done

echo ""
echo "All non-archived repositories have been cloned to $UNSORTED_DIR"
echo "Total repos: $(find "$UNSORTED_DIR" -mindepth 1 -maxdepth 1 -type d | wc -l)"
echo ""
echo "Next step: Run ./organize_repos.sh to categorize repositories."
