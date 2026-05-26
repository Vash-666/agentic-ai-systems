# Skills Quick Reference Card

**Updated:** 2026-05-10  
**Purpose:** Fast lookup for most-used skills

---

## 🚀 Essential Skills (Use Daily)

### Development
```bash
# Coding tasks → Codex/Claude/Pi agents
coding-agent
Dependencies: Codex/Claude/Pi

# GitHub operations
github
Command: gh <subcommand>

# GitHub issue workflows
gh-issues
Command: gh issues list | gh pr status

# Create/edit skills
skill-creator
Purpose: Build new AgentSkills
```

### Content & Analysis
```bash
# Summarize anything
summarize <url|file|youtube>
Supports: URLs, videos, PDFs, podcasts

# AI Q&A (Google)
gemini "Your question"

# Advanced reasoning (xAI)
@grok "Complex analysis"
Agent: @grok only
```

### Productivity
```bash
# Task management (macOS)
things-mac
Command: things <action>

# Notes (macOS)
apple-notes | bear-notes | obsidian
Choose based on preference

# Calendar & Email
gog calendar list
gog gmail read
```

### Messaging
```bash
# iMessage (macOS)
imsg send <recipient> <message>

# Discord
message action=send target=discord:<channel>

# Slack
message action=send target=slack:<channel>

# X/Twitter
xurl post "Your tweet"
```

---

## 🔧 Project Skills (Use Weekly)

### Project Creation
```bash
# Generate full project (@scaffolder agent)
scaffold create <name> <template> [--github]
Templates: nextjs-fullstack, express-react

# Scaffolder agent workflow
@scaffolder "Create a Next.js app for [purpose]"
```

### Quality & Testing
```bash
# Code review with second model
oracle <files> --prompt "Review this"

# Security audit
healthcheck --full
Checks: SSH, firewall, updates, exposure
```

### Orchestration
```bash
# Multi-step durable tasks
taskflow create <job-name>
Use for: Long-running workflows

# Example: Inbox automation
taskflow-inbox-triage
Pattern: Triage → route → wait → summarize
```

---

## 🏠 Smart Home (Use as Needed)

### Lighting
```bash
# Philips Hue
openhue lights on
openhue scene activate <scene>
```

### Audio
```bash
# Sonos
sonoscli play <source>

# BluOS
blucli play <url>

# Spotify
spogo play <track|playlist>
```

### Cameras
```bash
# Capture frame/clip
camsnap --camera <name> --output snap.jpg
```

### Sleep
```bash
# Eight Sleep pod
eightctl status
eightctl temp 68
```

---

## 🌐 Web & Data (Use as Needed)

### Web
```bash
# Weather
weather <location>
weather forecast <location>

# Google Places
goplaces search "coffee near me"
goplaces details <place_id>
```

### Notes & Documents
```bash
# Notion
notion create-page <title>

# Obsidian
obsidian create <note-name>

# PDF editing
nano-pdf edit <file> --instruction "Add watermark"
```

---

## 🎥 Media (Use as Needed)

### Audio
```bash
# Speech-to-text (local)
openai-whisper <audio-file>

# Speech-to-text (API)
openai-whisper-api <audio-file>

# Text-to-speech (cloud)
sag "Your text"

# Text-to-speech (local)
sherpa-onnx-tts "Your text"
```

### Video
```bash
# Extract frames
video-frames extract <video> --frame 30

# Audio visualization
songsee <audio-file>
```

### GIFs
```bash
# Search and download
gifgrep "funny cat"
```

---

## 🔐 Security & System (Use as Needed)

### Credentials
```bash
# 1Password
op read "op://vault/item/field"

# Node diagnostics
node-connect diagnose
```

### Logs & Analytics
```bash
# Session logs
session-logs search <query>

# Model cost tracking
model-usage summary --model claude
```

### System
```bash
# macOS UI automation
peekaboo capture <region>

# tmux control
tmux send-keys <session> "command"
```

---

## 📦 Package & Distribution (Use Rarely)

### Skills Management
```bash
# Search/install skills
clawhub search <query>
clawhub install <skill>

# Publish skills
clawhub publish <skill-dir>
```

---

## 🎯 Workflow Patterns

### Complete Website (Multi-Agent)
```
User → @product (requirements)
     → @grok (architecture)
     → @scaffolder (implementation)
     → @quality (validation)
     → @switch (deployment)
     → @content (documentation)
```

### Issue Fix Workflow
```
gh-issues fetch
  → spawn subagent per issue
  → fix + test
  → open PR
  → watch for reviews
  → merge
```

### Content Workflow
```
summarize <youtube-url>
  → gemini "Expand on key points"
  → @content "Write blog post"
  → github "Commit to blog repo"
```

---

## 🚨 Emergency Skills

### Quick Fixes
```bash
# Security audit NOW
healthcheck --urgent

# Rollback deployment
# (Need: vercel-deploy skill - see backlog)

# Check system status
# (Need: monitoring skill - see backlog)
```

### Diagnostics
```bash
# Node connection issues
node-connect diagnose --verbose

# Check logs
session-logs search "error" --recent

# Model costs
model-usage current
```

---

## 🔗 Skill Combinations

### Research → Summary → Share
```bash
summarize "https://article.com"
gemini "Key takeaways from: <summary>"
xurl post "<takeaways>"
```

### Task → Reminder → Calendar
```bash
things-mac add "Task name"
apple-reminders add "Reminder" --date tomorrow
gog calendar create "Event" --date "2026-05-15 10:00"
```

### Code → Review → Deploy
```bash
coding-agent "Build feature X"
oracle review <files>
scaffold create <project> --github
# Then: vercel-deploy (coming soon)
```

---

## 📚 Most Common Commands

### By Frequency (Estimated)
1. `github` / `gh-issues` - Daily
2. `summarize` - Daily
3. `coding-agent` - Daily
4. `gemini` / `@grok` - Daily
5. `things-mac` / productivity - Daily
6. `imsg` / messaging - Daily
7. `weather` - Daily
8. `scaffold` - Weekly
9. `healthcheck` - Weekly
10. `taskflow` - As needed

---

## 🎓 Learning Path

### Week 1: Basics
- `github` - Version control
- `summarize` - Content processing
- Messaging skills - Communication

### Week 2: Development
- `coding-agent` - Delegation
- `scaffold` - Project creation
- `skill-creator` - Skill building

### Week 3: Orchestration
- `taskflow` - Workflows
- `@grok` - Advanced reasoning
- Multi-agent patterns

### Week 4: Specialization
- Choose domain (smart home, media, productivity)
- Master 3-5 related skills
- Build custom workflows

---

## 📞 Getting Help

### Skill Documentation
```bash
# Read full SKILL.md
read /opt/homebrew/lib/node_modules/openclaw/skills/<skill>/SKILL.md

# For workspace skills
read /Users/rohitvashist/.openclaw/workspace/<project>/skills/<skill>/SKILL.md
```

### Quick Examples
Most SKILL.md files have examples at the top. Jump to "Quick Start" or "Usage Examples" sections.

### Common Issues
1. **Skill not found** → Check clawhub for installation
2. **Permission denied** → Check API keys in `.env`
3. **Command fails** → Read SKILL.md troubleshooting section

---

## 🔄 Version Info

**Catalog Version:** 1.0  
**Total Skills:** 57  
**Last Full Audit:** 2026-05-10  
**Next Audit:** 2026-06-10

---

## 📋 Related Documents

- **Full Catalog:** `SKILLS-CATALOG.md` (complete inventory)
- **Gap Analysis:** `SKILLS-GAP-ANALYSIS.md` (what's missing)
- **Backlog:** `SKILLS-BACKLOG.md` (what's coming)
- **Summary:** `SKILLS-SUMMARY.md` (executive overview)

---

**Print this page** for desk reference or bookmark for quick lookup!
