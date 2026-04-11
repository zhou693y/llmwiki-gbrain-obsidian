#!/usr/bin/env bash
# LLM Wiki — One-click initialization script
set -e

echo ""
echo "========================================="
echo "  LLM Wiki — Knowledge Base Setup"
echo "========================================="
echo ""

# --- Language selection ---
echo "Choose your preferred language for CLAUDE.md:"
echo "  1) English (default)"
echo "  2) 中文 (Chinese)"
echo ""
read -r -p "Enter 1 or 2 [1]: " lang_choice
lang_choice="${lang_choice:-1}"

# --- Create all directories (idempotent) ---
mkdir -p raw/{articles,podcasts,papers,my-notes,assets}
mkdir -p wiki/{summaries,concepts,entities,scenarios,syntheses,qa}

# Ensure .gitkeep files exist in empty dirs
for dir in raw/articles raw/podcasts raw/papers raw/my-notes raw/assets \
           wiki/summaries wiki/concepts wiki/entities wiki/scenarios wiki/syntheses wiki/qa; do
  touch "${dir}/.gitkeep"
done

echo "✓ Directory structure created"

# --- Copy the appropriate CLAUDE.md ---
if [[ "$lang_choice" == "2" ]]; then
  if [[ -f "CLAUDE.zh-CN.md" ]]; then
    cp "CLAUDE.zh-CN.md" "CLAUDE.md"
    echo "✓ CLAUDE.md set to Chinese version"
  else
    echo "Warning: CLAUDE.zh-CN.md not found, keeping existing CLAUDE.md"
  fi
else
  echo "✓ Using English CLAUDE.md (default)"
fi

# --- Seed wiki/INDEX.md if it doesn't exist or is empty ---
if [[ ! -s "wiki/INDEX.md" ]]; then
  cat > wiki/INDEX.md << 'EOF'
---
title: Wiki Index
last_updated: (updated automatically after each ingest)
---

## Concepts

## Entities

## Syntheses

## QA

## Summaries
EOF
  echo "✓ wiki/INDEX.md initialized"
fi

# --- Seed wiki/log.md if it doesn't exist or is empty ---
if [[ ! -s "wiki/log.md" ]]; then
  today=$(date +%Y-%m-%d)
  cat > wiki/log.md << EOF
# Operation Log

## [${today}] init | Knowledge base initialized | 0
EOF
  echo "✓ wiki/log.md initialized"
fi

# --- Initialize git repo if not already one ---
if [[ ! -d ".git" ]]; then
  git init -q
  echo "✓ Git repository initialized"
else
  echo "✓ Git repository already exists, skipping"
fi

echo ""
echo "========================================="
echo "  Setup complete!"
echo "========================================="
echo ""
echo "Next steps:"
echo ""
echo "  1. Open this folder in Obsidian or your favorite markdown editor"
echo "  2. Open Claude Code in this folder: claude"
echo "  3. Drop a file into raw/articles/ (or podcasts/, papers/, my-notes/)"
echo "  4. Tell Claude Code:  ingest raw/articles/your-file.md"
echo ""
echo "Tip: Edit CLAUDE.md to customize the domain description for your"
echo "     specific knowledge base topic."
echo ""
