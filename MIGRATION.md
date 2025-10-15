# Migration Guide: Bash to Ruby

This project has been migrated from bash scripts to a Ruby-based OOP solution using Zeitwerk.

## What Changed

### Removed ❌
- `setup_all.sh` → `./socketry.rb setup`
- `update.sh` → `./socketry.rb update`
- `organize_repos.sh` → `./socketry.rb organize`
- `emit_metadata.sh` → `./socketry.rb metadata`
- `scripts/refresh_dependencies.sh` → `./socketry.rb refresh-deps`
- `create_readmes.sh` (removed - no longer needed)
- `initial_setup.sh` (merged into setup command)
- `validate_categories.sh` (integrated into organize)
- `.repos_metadata.json` (consolidated into `.workspace_metadata.json`)

### Added ✅
- `socketry.rb` - Main entry point
- `lib/socketry_manager/` - OOP Ruby classes
  - `configuration.rb` - Settings and config
  - `git_operations.rb` - Git commands
  - `github_api.rb` - GitHub API integration
  - `categorizer.rb` - Repository categorization
  - `metadata_manager.rb` - Metadata operations
  - `updater.rb` - Update and clone logic
  - `cli.rb` - Command-line interface
- `test/` - Minitest test suite
- `Gemfile` - Dependencies (zeitwerk, minitest, rake)
- `Rakefile` - Test runner

## Command Mapping

| Old Bash Script | New Ruby Command |
|----------------|------------------|
| `./setup_all.sh` | `./socketry.rb setup` |
| `./update.sh` | `./socketry.rb update` |
| `./organize_repos.sh` | `./socketry.rb organize` |
| `DRY_RUN=1 ./organize_repos.sh` | `./socketry.rb organize --dry-run` |
| `./emit_metadata.sh` | `./socketry.rb metadata` |
| `./scripts/refresh_dependencies.sh` | `./socketry.rb refresh-deps` |
| N/A | `./socketry.rb stats` |
| N/A | `./socketry.rb disable <repo>` |
| N/A | `./socketry.rb enable <repo>` |
| N/A | `./socketry.rb list-disabled` |

## New Features

### 1. Repository Enable/Disable Flag
Each repository now has an `enabled` flag in `.workspace_metadata.json`:

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

**Benefits:**
- Skip cloning repos you don't need
- Exclude repos from updates
- Mark archived/demo projects as disabled

### 2. Object-Oriented Design
- Clean separation of concerns
- Easier to test and maintain
- Uses Zeitwerk for autoloading
- Follows Ruby best practices

### 3. Test-Driven Development
- Comprehensive test suite with minitest
- Test helpers for easy testing
- Run tests with `bundle exec rake test`

### 4. Simplified Metadata
- Single source of truth: `.workspace_metadata.json`
- Removed redundant `.repos_metadata.json`
- Cleaner, more maintainable structure

## Migration Steps

If you're migrating an existing workspace:

```bash
# 1. Install dependencies
bundle install

# 2. The old bash scripts have been removed
# Your existing .workspace_metadata.json is preserved

# 3. Test the new commands
./socketry.rb stats
./socketry.rb help

# 4. Use the new update command
./socketry.rb update

# 5. (Optional) Disable repos you don't need
./socketry.rb disable falcon-benchmark
./socketry.rb disable flappy-bird
```

## Benefits

1. **Less verbose**: One Ruby app vs 8+ bash scripts
2. **Better structure**: OOP with clear responsibilities
3. **Testable**: Full test suite with minitest
4. **More features**: Enable/disable repos, better error handling
5. **Easier to extend**: Add new commands easily
6. **Type-safe**: Ruby vs bash string manipulation
7. **Better error messages**: Clear Ruby exceptions

## Running Tests

```bash
# Run all tests
bundle exec rake test

# Run specific test file
ruby test/configuration_test.rb
```

## Architecture

```
SocketryManager
├── Configuration    - Load settings and categories
├── GitOperations    - Execute git commands
├── GithubApi        - Fetch data from GitHub API
├── Categorizer      - Assign repos to categories
├── MetadataManager  - CRUD for metadata
├── Updater          - Update/clone repositories
└── CLI              - Command-line interface
```

## Questions?

See [README.md](README.md) for full documentation.
