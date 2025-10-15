# Quick Reference: Finding the Right Library

Use this guide to find the socketry library you need!

## 🚀 Getting Started

**Want async superpowers?**
- `async` - The foundation. Start here!

**Building a web app?**
- `falcon` - Super-fast web server (like Puma but faster)
- `utopia` - Full web framework (like Rails but async)

**Need HTTP requests?**
- `async-http` - Make many HTTP requests at once

**Real-time features?**
- `async-websocket` - Real-time bidirectional communication
- `live` - Real-time reactive views

## 📊 By Use Case

### Web Servers & Frameworks
- `falcon` - Production web server
- `utopia` - Full-featured web framework
- `protocol-rack` - Connect Rack apps to async servers

### HTTP & APIs
- `async-http` - Async HTTP client/server
- `async-rest` - REST API helpers
- `http-accept` - Content negotiation

### Real-Time Communication
- `async-websocket` - WebSocket connections
- `live` - Real-time reactive UIs
- `async-cable` - ActionCable for async

### Database
- `db-postgres` - PostgreSQL driver
- `db-mariadb` - MariaDB driver
- `async-pool` - Connection pooling

### Background Jobs
- `async-job` - Background job processing
- `async-worker` - Worker pools
- `async-cron` - Scheduled tasks

### Logging & Monitoring
- `console` - Beautiful structured logging
- `metrics` - Application metrics
- `traces` - Distributed tracing

### Testing
- `sus` - Modern test framework
- `covered` - Code coverage
- `async-rspec` - Async RSpec support

### Templates & Views
- `xrb` - Fast, safe HTML templates
- `xrb-formatters` - Template helpers

### Low-Level / Advanced
- `io-event` - Event loop core
- `async-limiter` - Rate limiting
- `async-pool` - Resource pooling

## 🎯 Common Scenarios

**"I want to build a high-performance web API"**
→ `falcon` + `async-http` + `db-postgres`

**"I need to scrape 1000 websites"**
→ `async` + `async-http` + `async-limiter`

**"I'm building a real-time dashboard"**
→ `falcon` + `live` + `async-websocket`

**"I need background job processing"**
→ `async-job` + `async-redis`

**"I want better Rails performance"**
→ `falcon-rails` + `async-cable`

**"I need to monitor my app"**
→ `console` + `metrics` + `traces`

## 📚 Learn More

View full descriptions:
```bash
cat .workspace_metadata.json | jq '.repositories.<repo-name>.description'
```

Example:
```bash
cat .workspace_metadata.json | jq '.repositories.falcon.description'
```
