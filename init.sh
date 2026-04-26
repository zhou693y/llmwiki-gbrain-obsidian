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
read -r -p "Set up Obsidian plugins (Clipper + Dataview + Templater)? [y/N]: " setup_obsidian
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
      local ok=1
      curl -sSL "${base}/main.js"       -o "${plugin_dir}/main.js"       || ok=0
      curl -sSL "${base}/manifest.json" -o "${plugin_dir}/manifest.json" || ok=0
      curl -sSL "${base}/styles.css"    -o "${plugin_dir}/styles.css" 2>/dev/null || true
      if [[ $ok -eq 0 ]]; then
        echo "  ✗ Failed to download ${plugin_id}."
        rm -rf "${plugin_dir}"
        return 0
      fi
    }

    mkdir -p .obsidian/plugins
    install_plugin "obsidian-clipper"   "obsidianmd/obsidian-clipper"
    install_plugin "dataview"           "blacksmithgu/obsidian-dataview"
    install_plugin "templater-obsidian" "SilentVoid13/Templater"

    cat > .obsidian/community-plugins.json << 'EOF'
[
  "obsidian-clipper",
  "dataview",
  "templater-obsidian"
]
EOF

    mkdir -p .obsidian/plugins/templater-obsidian
    cat > .obsidian/plugins/templater-obsidian/data.json << 'EOF'
{
  "template_folder": "templates",
  "auto_jump_to_cursor": true,
  "trigger_on_file_creation": false,
  "enable_system_commands": false
}
EOF

    cat > .obsidian/app.json << 'EOF'
{
  "userIgnoreFilters": [
    "gbrain",
    "raw",
    "templates",
    "CLAUDE.md",
    "init.ps1",
    "init.sh"
  ]
}
EOF

    echo "✓ Obsidian plugins installed (Clipper, Dataview, Templater)"
    echo "  → Open this folder in Obsidian to complete plugin activation"
  fi
fi

# --- Optional: gbrain setup ---
echo ""
read -r -p "Set up gbrain search engine? Requires bun + git [y/N]: " setup_gbrain
if [[ "$setup_gbrain" =~ ^[Yy]$ ]]; then
  # Check bun
  if ! command -v bun &>/dev/null; then
    echo "  bun not found. Installing bun..."
    curl -fsSL https://bun.sh/install | bash
    export PATH="$HOME/.bun/bin:$PATH"
    echo "  ✓ bun installed"
  fi
  export PATH="$HOME/.bun/bin:$PATH"
  if [[ ! -d "gbrain" ]]; then
    echo "  Cloning garrytan/gbrain..."
    git clone https://github.com/garrytan/gbrain.git gbrain
  fi
  echo "  Installing dependencies..."
  cd gbrain && bun install --ignore-scripts && bun link && cd ..
  echo "  Initializing brain database..."
  export PATH="$HOME/.bun/bin:$PATH"
  gbrain init
  echo "  Importing wiki pages..."
  gbrain import wiki/ --no-embed
  echo "✓ gbrain ready. Run 'gbrain query <question>' to search."
  echo "  → For vector search: set OPENAI_API_KEY and run 'gbrain embed --stale'"
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
echo "  1. Open this folder in Obsidian"
echo "  2. Open your AI IDE (Kiro / Cursor / Qwen Code) in this folder"
echo "  3. Drop a file into raw/ScenicDatas/  (or raw/articles/, raw/my-notes/)"
echo "  4. Tell your AI:  ingest raw/ScenicDatas/your-file.md"
echo ""
echo "Tip: Edit CLAUDE.md to customize the domain and scenic areas."
echo ""
