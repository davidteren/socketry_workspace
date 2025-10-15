# Socketry Quickstart Guide

This workspace manages 140+ repositories from the Socketry organization efficiently.

## Quick Setup

```bash
# Install dependencies
bundle install

# Clone and organize all repositories
./socketry.rb setup
```

## Common Commands

```bash
# Update all repositories
./socketry.rb update

# View statistics
./socketry.rb stats

# Organize repositories by category
./socketry.rb organize

# Refresh dependency information
./socketry.rb refresh-deps
```

## Selective Repository Management

Don't need all repos locally? Disable the ones you don't want:

```bash
# Disable example/demo repositories
./socketry.rb disable falcon-benchmark
./socketry.rb disable flappy-bird
./socketry.rb disable async-websocket-pubsub-example

# Remove from disk if already cloned
rm -rf 04-frameworks/falcon-benchmark
rm -rf 99-miscellaneous/flappy-bird

# List all disabled repos
./socketry.rb list-disabled

# Re-enable if needed
./socketry.rb enable falcon-benchmark
```

## How It Works

1. **Metadata**: `.workspace_metadata.json` tracks all repo state
2. **Enabled Flag**: Each repo has `enabled: true/false` (default: true)
3. **Categories**: Repos auto-organize based on `categories.json` patterns
4. **Dependencies**: Gemspec files are scanned for intra-org dependencies

## Configuration

Edit `.workspace_metadata.json` to manually set repository flags:

```json
{
  "repositories": {
    "flappy-bird": {
      "category": "99-miscellaneous",
      "enabled": false,
      "dependencies": []
    }
  }
}
```

## Running Tests

```bash
bundle exec rake test
```

## Help

```bash
./socketry.rb help
```

---

For full documentation, see [README.md](README.md)
