# Socketry Organization Repositories

This repo contains tools to pull organized clones of repositories from the [Socketry GitHub Organization](https://github.com/socketry), created and maintained by Samuel Williams.
There is also a [Socketry Libraries Explorer](https://davidteren.github.io/socketry_workspace/).

## About This Project

**This is an unofficial community tool** created to help developers explore and understand the Socketry organization's extensive library ecosystem. It is **not an official Socketry project**.

### What It Does

This tool provides:
- **Visual Explorer**: A web-based catalog of Socketry repositories with metadata, categorization, and easy navigation
- **Local Workspace**: Organized clones of repositories grouped by category for detailed examination
- **Metadata Management**: Automated tracking of dependencies, descriptions, and repository information

### How to Use It

1. **Browse Online**: Visit the [Socketry Libraries Explorer](https://davidteren.github.io/socketry_workspace/) to explore available libraries
2. **Clone Locally**: Use this tool to clone and organize repositories on your machine for detailed code examination
3. **Explore Source**: View the source code for this explorer tool at [github.com/davidteren/socketry_workspace](https://github.com/davidteren/socketry_workspace)

This tool makes it easier to discover what libraries are available in the Socketry ecosystem and understand what each one does, helping you find the right tools for your asynchronous Ruby projects.

## Overview

Socketry is a collection of modern, high-performance Ruby libraries focused on asynchronous I/O, networking, and web development. The repositories are organized into logical categories for easy navigation and understanding.

## Directory Structure

- **01-async-core**: Core asynchronous I/O and concurrency libraries
- **02-http-web**: HTTP client/server implementations and web protocols
- **03-dns-network**: DNS server and network utilities
- **04-frameworks**: Web frameworks and CMS (Utopia, Falcon, etc.)
- **05-database**: Database adapters and connection pooling
- **06-protocols**: Protocol implementations (Redis, MessagePack, etc.)
- **07-console**: Console and logging utilities
- **08-testing**: Testing frameworks (Sus)
- **09-io-libraries**: Low-level I/O abstractions
- **10-dev-tools**: Build and development tools (Bake)
- **11-security**: Security and authentication utilities
- **12-low-level**: C extensions and system libraries
- **13-utilities**: General utility libraries

## Setup

### Prerequisites

- Ruby 3.1+ (recommended)
- git installed and available on PATH
- Optional: GitHub token for higher API rate limits
  - Set `GITHUB_TOKEN` or `GH_TOKEN` in your environment

```bash
bundle install
```

### Initial Setup (First Time)

Clone this repository and run the setup:

```bash
git clone <your-repo-url> socketry
cd socketry
bundle install
./socketry.rb setup
```

This will:
1. Clone all non-archived socketry repositories (only enabled ones)
2. Organize them into categories
3. Generate metadata with dependency information

**Note:** The cloned repositories are not tracked by git (they're in .gitignore). Only the management scripts and documentation are version controlled.

## Usage

### Update Repositories

```bash
./socketry.rb update
```

The update command will:
- Pull latest changes from all enabled repositories
- Check for new repositories in the organization
- Update metadata and remote timestamps
- Skip any disabled repositories

### Organize Repositories

```bash
# Preview organization changes
./socketry.rb organize --dry-run

# Apply organization changes
./socketry.rb organize
```

### Managing Repositories

You can selectively enable/disable repositories to control which ones are cloned and updated:

```bash
# Disable a repository (it won't be updated and can be removed)
./socketry.rb disable flappy-bird

# Enable a repository
./socketry.rb enable flappy-bird

# List all disabled repositories
./socketry.rb list-disabled
```

**Example workflow for excluding repos:**
```bash
# Disable example/demo repos you don't need locally
./socketry.rb disable falcon-benchmark
./socketry.rb disable falcon-example-sinatra
./socketry.rb disable async-websocket-pubsub-example

# Remove them from disk if already cloned
rm -rf 04-frameworks/falcon-benchmark
rm -rf 04-frameworks/falcon-example-sinatra
rm -rf 02-http-web/async-websocket-pubsub-example

# Future updates will skip these repos
./socketry.rb update
```

### Refresh Dependencies

Update the dependency graph by scanning gemspec files:

```bash
./socketry.rb refresh-deps
```

This scans all gemspec files and updates the `dependencies` array in `.workspace_metadata.json` with intra-organization dependencies only.

### View Statistics

```bash
./socketry.rb stats
```

### Regenerate Metadata

```bash
./socketry.rb metadata
```

## Metadata Structure

The `.workspace_metadata.json` file contains:

```json
{
  "generated_at": "2025-10-15T15:02:05+02:00",
  "org": "socketry",
  "categories": {
    "01-async-core": { "count": 10 }
  },
  "repositories": {
    "async": {
      "category": "01-async-core",
      "enabled": true,
      "description": "The main 'brain' that lets Ruby do many things at once without waiting...",
      "last_pull_at": "2025-10-15T14:32:52+02:00",
      "remote_pushed_at": "2025-10-08T11:29:38Z",
      "remote_updated_at": "2025-10-13T14:27:58Z",
      "dependencies": ["console"]
    }
  }
}
```

### Repository Fields

- **enabled** (default: `true`): Set to `false` to exclude a repository from cloning and updates
  - Disabled repos won't be cloned during setup
  - Disabled repos are skipped during updates
  - You can safely remove disabled repos from disk
  - Useful for excluding example projects, archived code, or repos you don't need locally

- **description**: Human-friendly explanation of what the library does
  - Written in simple, accessible language
  - Explains what it does, when to use it, and how it helps
  - Lives in `.workspace_metadata.json` under repositories.<name>.description
  - You can edit it directly in `.workspace_metadata.json`

## Categorization Rules

Repositories are categorized using patterns defined in `categories.json`. To change categorization:

1. Edit `categories.json`
2. Run `./socketry.rb organize --dry-run` to preview
3. Run `./socketry.rb organize` to apply changes

## Development

### Running Tests

```bash
bundle exec rake test
```

### Project Structure

```
socketry/
├── socketry.rb              # Main entry point
├── Gemfile                  # Dependencies
├── Rakefile                 # Test tasks
├── lib/
│   ├── socketry_manager.rb
│   └── socketry_manager/
│       ├── configuration.rb      # Config & settings
│       ├── git_operations.rb     # Git commands
│       ├── github_api.rb         # GitHub API client
│       ├── categorizer.rb        # Repository categorization
│       ├── metadata_manager.rb   # Metadata CRUD
│       ├── updater.rb            # Update & clone logic
│       └── cli.rb                # Command-line interface
├── test/
│   ├── test_helper.rb
│   ├── configuration_test.rb
│   ├── categorizer_test.rb
│   └── metadata_manager_test.rb
└── categories.json          # Category patterns
```

## Docs

This repository intentionally keeps documentation minimal:
- Usage and setup: this README
- Category patterns: categories.json
- Workspace metadata schema: .workspace_metadata.json (generated)

Currently used JSON files:
- categories.json (input)
- .workspace_metadata.json (generated)

For background on the tool and architecture, review the source under lib/ and run ./socketry.rb help.

## About Socketry

Socketry is maintained by Samuel Williams (@ioquatix) and provides a comprehensive ecosystem for building high-performance, asynchronous Ruby applications. These libraries power modern Ruby web servers like Falcon and are designed to work seamlessly together.

## Links

- [Socketry Organization](https://github.com/socketry)
- [Samuel Williams (@ioquatix)](https://github.com/ioquatix)

---

*This workspace is managed by a Ruby-based tool using Zeitwerk for autoloading and organized with object-oriented design.*
