#!/usr/bin/env bash

set -e

BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
UNSORTED_DIR="$BASE_DIR/unsorted"

# Define categories and their repos (based on analysis of the repos)
declare -A CATEGORIES

# Core Async Framework
CATEGORIES["01-async-core"]="async async-io async-container"

# HTTP & Web
CATEGORIES["02-http-web"]="async-http async-websocket protocol-http protocol-http1 protocol-http2 protocol-hpack async-http-cache async-http-faraday protocol-rack rack-conform async-rest live protocol-websocket"

# DNS & Network
CATEGORIES["03-dns-network"]="async-dns rubydns resolv-replace"

# Web Frameworks & CMS
CATEGORIES["04-frameworks"]="utopia falcon xrb xrb-formatters trenni trenni-sanitize trenni-formatters utopia-project utopia-gallery decode utopia-wiki"

# Database
CATEGORIES["05-database"]="db db-postgres db-mariadb db-active_record async-pool"

# Protocols & Serialization
CATEGORIES["06-protocols"]="protocol-redis async-redis msgpack"

# Console & Logging
CATEGORIES["07-console"]="console console-adapter-falcon console-output-datadog"

# Testing
CATEGORIES["08-testing"]="sus sus-fixtures-async sus-fixtures-async-http covered"

# I/O Libraries
CATEGORIES["09-io-libraries"]="io-stream io-endpoint io-notification event localhost"

# Development Tools
CATEGORIES["10-dev-tools"]="bake bake-modernize bake-gem bake-github-pages bake-bundler bake-test bake-test-external build build-files build-dependency standard-metrics standard-procedure standard-request rspec-files rspec-memory .github"

# Security & Auth
CATEGORIES["11-security"]="samovar cloudflare cloudflare-dns-update openssl-signature_algorithm variant"

# Low-level / C Extensions
CATEGORIES["12-low-level"]="nio4r cool.io timers thread-local"

# Utilities
CATEGORIES["13-utilities"]="mapping traces metrics process-metrics process-terminal multipart-post async-service rack vips-thumbnail mail-verifier random"

echo "Organizing repositories into categories..."
echo ""

# Create category directories and move repos
for category in "${!CATEGORIES[@]}"; do
    category_dir="$BASE_DIR/$category"
    mkdir -p "$category_dir"
    
    # Split the repo list and move each repo
    for repo in ${CATEGORIES[$category]}; do
        if [ -d "$UNSORTED_DIR/$repo" ]; then
            echo "Moving $repo to $category/"
            mv "$UNSORTED_DIR/$repo" "$category_dir/"
        fi
    done
done

# Move any remaining repos to a "miscellaneous" category
if [ -d "$UNSORTED_DIR" ] && [ "$(ls -A "$UNSORTED_DIR" 2>/dev/null)" ]; then
    mkdir -p "$BASE_DIR/99-miscellaneous"
    echo ""
    echo "Moving uncategorized repos to 99-miscellaneous/:"
    for repo in "$UNSORTED_DIR"/*; do
        if [ -d "$repo" ]; then
            repo_name=$(basename "$repo")
            echo "  - $repo_name"
            mv "$repo" "$BASE_DIR/99-miscellaneous/"
        fi
    done
fi

# Remove empty unsorted directory
if [ -d "$UNSORTED_DIR" ] && [ ! "$(ls -A "$UNSORTED_DIR" 2>/dev/null)" ]; then
    rmdir "$UNSORTED_DIR"
fi

echo ""
echo "Organization complete!"
echo ""
echo "Next step: Create README files for each category."
