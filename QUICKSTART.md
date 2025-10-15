# Quick Start Guide

## 🚀 For First-Time Setup

Someone who clones this repo can get all 143 socketry repositories organized in one command:

```bash
# Clone this setup repository
git clone <your-repo-url> socketry
cd socketry

# Run the all-in-one setup script
./setup_all.sh
```

That's it! The script will:
1. ✅ Clone all 143+ non-archived socketry repositories from GitHub
2. ✅ Organize them into 14 logical categories
3. ✅ Generate README files for each category with descriptions

**Time estimate:** ~5-10 minutes depending on your connection

## 📁 What You'll Get

After running the setup, you'll have:

```
socketry/
├── 01-async-core/          # Core async framework
├── 02-http-web/            # HTTP/WebSocket libraries
├── 03-dns-network/         # DNS utilities
├── 04-frameworks/          # Falcon, Utopia
├── 05-database/            # Database adapters
├── 06-protocols/           # Redis, MessagePack
├── 07-console/             # Logging
├── 08-testing/             # Sus testing framework
├── 09-io-libraries/        # I/O abstractions
├── 10-dev-tools/           # Bake build tools
├── 11-security/            # CloudFlare, security
├── 12-low-level/           # C extensions (nio4r)
├── 13-utilities/           # General utilities
└── 99-miscellaneous/       # Examples, experiments
```

Each category contains the actual git repositories and a README with descriptions.

## 🔄 Keeping Up-to-Date

Run this regularly to pull latest changes from all repos:

```bash
./update.sh
```

The update script will:
- Pull changes from all 143+ repositories
- Show which ones were updated
- Detect any new repos added by Samuel Williams
- Display statistics

## 💡 Why This Approach?

**What's tracked in git:**
- ✅ Setup scripts
- ✅ Documentation
- ✅ Configuration (.gitignore)

**What's NOT tracked:**
- ❌ The 143 cloned socketry repositories (they're in .gitignore)
- ❌ Generated files (.repo_list.json)

This means:
- 📦 This repo is tiny (~50KB vs 286MB with all repos)
- 🔄 Always get fresh clones of socketry repos
- 🚀 Easy to share and maintain
- 🎯 No nested git repository issues

## 📖 Documentation

- **README.md** - Overview and usage
- **SETUP_SUMMARY.md** - Detailed setup documentation
- **QUICKSTART.md** - This file!

## 🎯 Key Repositories to Explore First

After setup, check out:

```bash
cd 01-async-core/async       # The foundation
cd 04-frameworks/falcon      # Web server
cd 02-http-web/async-http    # HTTP client
cd 08-testing/sus            # Testing framework
```

## 🆘 Troubleshooting

**Q: The setup failed partway through**
- Just run `./setup_all.sh` again - it skips already-cloned repos

**Q: I want to re-organize everything**
- Delete the category directories and run `./setup_all.sh`

**Q: How do I update to get new repos?**
- Run `./update.sh` - it will show new repos and you can manually clone them

**Q: Can I customize the categories?**
- Yes! Edit `organize_repos.sh` and re-run it

## 🔗 Links

- [Socketry Organization](https://github.com/socketry)
- [Samuel Williams (@ioquatix)](https://github.com/ioquatix)
- [Async Documentation](https://socketry.github.io/async/)
- [Falcon Documentation](https://socketry.github.io/falcon/)

---

**Happy exploring!** 🎉
