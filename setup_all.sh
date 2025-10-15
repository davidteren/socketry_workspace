#!/usr/bin/env bash

set -e

echo "=========================================="
echo "Socketry Repository Collection Setup"
echo "=========================================="
echo ""
echo "This script will:"
echo "  1. Clone all non-archived socketry repositories"
echo "  2. Organize them into categories"
echo "  3. Create README files for each category"
echo ""
read -p "Continue? (y/n) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Setup cancelled."
    exit 1
fi

echo ""
echo "Step 1/3: Cloning repositories..."
echo "=========================================="
./initial_setup.sh

echo ""
echo "Step 2/3: Organizing into categories..."
echo "=========================================="
./organize_repos.sh

echo ""
echo "Step 3/3: Creating README files..."
echo "=========================================="
./create_readmes.sh

echo ""
echo "=========================================="
echo "✅ Setup Complete!"
echo "=========================================="
echo ""
echo "You now have 143 socketry repositories organized into 14 categories."
echo ""
echo "Next steps:"
echo "  - Run ./update.sh regularly to keep repositories up-to-date"
echo "  - Read SETUP_SUMMARY.md for detailed documentation"
echo "  - Explore individual categories (e.g., cd 01-async-core)"
echo ""
