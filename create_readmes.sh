#!/usr/bin/env bash

set -e

BASE_DIR="$(cd "$(dirname "$0")" && pwd)"

# Function to create README for a category
create_readme() {
    local category_dir="$1"
    local category_name="$2"
    local description="$3"
    local readme_file="$category_dir/README.md"
    
    cat > "$readme_file" << EOF
# $category_name

$description

## Repositories

EOF
    
    # List all repos in this category
    for repo in "$category_dir"/*; do
        if [ -d "$repo" ] && [ "$(basename "$repo")" != "README.md" ]; then
            repo_name=$(basename "$repo")
            
            # Try to get description from repo's README or GitHub
            if [ -f "$repo/README.md" ]; then
                # Extract first non-empty line after title
                desc=$(head -20 "$repo/README.md" | grep -v "^#" | grep -v "^$" | head -1 | sed 's/^[*-] //')
                if [ -z "$desc" ]; then
                    desc="(See repository README for details)"
                fi
            else
                desc="(No description available)"
            fi
            
            echo "- **[$repo_name]($repo_name)**: $desc" >> "$readme_file"
        fi
    done
    
    echo "" >> "$readme_file"
    echo "---" >> "$readme_file"
    echo "*Last updated: $(date +"%Y-%m-%d")*" >> "$readme_file"
}

# Create README for each category
echo "Creating README files..."

if [ -d "$BASE_DIR/01-async-core" ]; then
    create_readme "$BASE_DIR/01-async-core" "Async Core Framework" \
        "Core asynchronous I/O and concurrency libraries that form the foundation of the socketry ecosystem."
fi

if [ -d "$BASE_DIR/02-http-web" ]; then
    create_readme "$BASE_DIR/02-http-web" "HTTP & Web Protocols" \
        "HTTP client/server implementations, WebSocket support, and related web protocols."
fi

if [ -d "$BASE_DIR/03-dns-network" ]; then
    create_readme "$BASE_DIR/03-dns-network" "DNS & Network Utilities" \
        "DNS server and client libraries for network service discovery and resolution."
fi

if [ -d "$BASE_DIR/04-frameworks" ]; then
    create_readme "$BASE_DIR/04-frameworks" "Web Frameworks & CMS" \
        "Full-featured web frameworks, content management systems, and templating engines."
fi

if [ -d "$BASE_DIR/05-database" ]; then
    create_readme "$BASE_DIR/05-database" "Database Libraries" \
        "Database adapters and connection pooling for PostgreSQL, MariaDB, and ActiveRecord integration."
fi

if [ -d "$BASE_DIR/06-protocols" ]; then
    create_readme "$BASE_DIR/06-protocols" "Protocols & Serialization" \
        "Protocol implementations including Redis, MessagePack, and other data formats."
fi

if [ -d "$BASE_DIR/07-console" ]; then
    create_readme "$BASE_DIR/07-console" "Console & Logging" \
        "Advanced console and logging utilities with support for structured logging and various output formats."
fi

if [ -d "$BASE_DIR/08-testing" ]; then
    create_readme "$BASE_DIR/08-testing" "Testing Frameworks" \
        "Testing libraries and fixtures specifically designed for async code and HTTP services."
fi

if [ -d "$BASE_DIR/09-io-libraries" ]; then
    create_readme "$BASE_DIR/09-io-libraries" "I/O Libraries" \
        "Low-level I/O abstractions for streams, endpoints, and event notifications."
fi

if [ -d "$BASE_DIR/10-dev-tools" ]; then
    create_readme "$BASE_DIR/10-dev-tools" "Development Tools" \
        "Build tools, task automation (Bake), and development utilities for Ruby projects."
fi

if [ -d "$BASE_DIR/11-security" ]; then
    create_readme "$BASE_DIR/11-security" "Security & Authentication" \
        "Security utilities, CloudFlare integration, and cryptographic tools."
fi

if [ -d "$BASE_DIR/12-low-level" ]; then
    create_readme "$BASE_DIR/12-low-level" "Low-level Libraries" \
        "C extensions and low-level system libraries for I/O multiplexing and timers."
fi

if [ -d "$BASE_DIR/13-utilities" ]; then
    create_readme "$BASE_DIR/13-utilities" "General Utilities" \
        "Various utility libraries for common tasks including mapping, tracing, metrics, and more."
fi

if [ -d "$BASE_DIR/99-miscellaneous" ]; then
    create_readme "$BASE_DIR/99-miscellaneous" "Miscellaneous" \
        "Other repositories that don't fit into specific categories."
fi

echo "README files created successfully!"
