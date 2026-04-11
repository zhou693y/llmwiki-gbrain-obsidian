#!/usr/bin/env bash
# LLM Wiki — One-click initialization script (Mac / Linux)
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

# --- Optional: Obsidian plugin setup ---
echo ""
read -r -p "Set up Obsidian plugins (Claudian + Clipper)? [y/N]: " setup_obsidian
if [[ "$setup_obsidian" =~ ^[Yy]$ ]]; then
  if ! command -v curl &>/dev/null; then
    echo "Warning: curl not found. Skipping plugin installation."
  else
    install_plugin() {
      local plugin_id="$1"
      local repo="$2"
      local plugin_dir=".obsidian/plugins/${plugin_id}"
      mkdir -p "$plugin_dir"
      local base="https://github.com/${repo}/releases/latest/download"
      echo "  Downloading ${plugin_id}..."
      curl -fsSL "${base}/main.js"       -o "${plugin_dir}/main.js"
      curl -fsSL "${base}/manifest.json" -o "${plugin_dir}/manifest.json"
      curl -fsSL "${base}/styles.css"    -o "${plugin_dir}/styles.css" 2>/dev/null || true
    }

    mkdir -p .obsidian/plugins

    install_plugin "obsidian42-brat"  "TfTHacker/obsidian42-brat"
    install_plugin "claudian"         "YishenTu/claudian"
    install_plugin "obsidian-clipper" "jgchristopher/obsidian-clipper"

    # Enable plugins in Obsidian config
    cat > .obsidian/community-plugins.json << 'EOF'
[
  "obsidian42-brat",
  "claudian",
  "obsidian-clipper"
]
EOF

    # Configure BRAT to track Claudian for future updates
    mkdir -p .obsidian/plugins/obsidian42-brat
    cat > .obsidian/plugins/obsidian42-brat/data.json << 'EOF'
{
  "pluginList": ["YishenTu/claudian"],
  "pluginSubListFrozenVersion": [
    { "repo": "YishenTu/claudian", "version": "latest" }
  ],
  "updateAtStartup": true,
  "enableAfterInstall": true,
  "notificationsEnabled": true
}
EOF

    # Minimal Obsidian app config
    cat > .obsidian/app.json << 'EOF'
{}
EOF

    echo "✓ Obsidian plugins installed (BRAT, Claudian, Clipper)"
    echo "  → Open this folder in Obsidian to complete plugin activation"
    echo "  → Configure Claudian: Settings → Claudian → enter your API key"
  fi
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
echo "  1. Open this folder in Obsidian (or any markdown editor)"
echo "  2. Open Claude Code in this folder:  claude"
echo "  3. Drop a file into raw/articles/    (or podcasts/, papers/, my-notes/)"
echo "  4. Tell Claude Code:  ingest raw/articles/your-file.md"
echo ""
echo "Tip: Edit CLAUDE.md to customize the domain description for your topic."
echo ""
