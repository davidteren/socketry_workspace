# Socketry Organization Repositories

This directory contains organized clones of repositories from the [Socketry GitHub Organization](https://github.com/socketry), created and maintained by Samuel Williams.

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

## Common Dependencies

Many socketry projects depend on these core libraries:

- **async**: The foundational async/await framework
- **console**: Logging and debugging
- **sus**: Testing framework
- **bake**: Build and task automation

## Usage

### Initial Setup (First Time)

Clone this repository and run the setup script:

```bash
git clone <your-repo-url> socketry
cd socketry
./setup_all.sh
```

This will:
1. Clone all 143+ non-archived socketry repositories
2. Organize them into 14 categories
3. Create README files for each category

**Note:** The cloned repositories are not tracked by git (they're in .gitignore). Only the setup scripts and documentation are version controlled.

### Regular Updates

```bash
# Pull latest changes from all repositories
./update.sh
```

The update script will:
- Pull the latest changes from all repositories
- Check for new repositories added to the organization
- Display update statistics

## About Socketry

Socketry is maintained by Samuel Williams (@ioquatix) and provides a comprehensive ecosystem for building high-performance, asynchronous Ruby applications. These libraries power modern Ruby web servers like Falcon and are designed to work seamlessly together.

## Links

- [Socketry Organization](https://github.com/socketry)
- [Samuel Williams (@ioquatix)](https://github.com/ioquatix)

---

*This directory structure was automatically generated and is regularly updated.*
