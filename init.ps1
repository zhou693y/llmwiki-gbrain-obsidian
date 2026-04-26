# LLM Wiki — One-click initialization script (Windows PowerShell)
# Run with: .\init.ps1
# If blocked by execution policy, run first:
#   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

$ErrorActionPreference = "Stop"

# Write UTF-8 without BOM — compatible with PS 5.1 and PS 7+.
# Out-File -Encoding utf8 adds a BOM on PS 5.x which breaks Obsidian JSON parsing.
function Write-UTF8NoBOM {
  param([string]$Path, [string]$Content)
  $enc = New-Object System.Text.UTF8Encoding $false
  [System.IO.File]::WriteAllText((Join-Path (Get-Location) $Path), $Content, $enc)
}

Write-Host ""
Write-Host "========================================="
Write-Host "  LLM Wiki - Knowledge Base Setup"
Write-Host "========================================="
Write-Host ""

# --- Language selection ---
Write-Host "Choose your preferred language for CLAUDE.md:"
Write-Host "  1) English (default)"
Write-Host "  2) Chinese (zhong wen)"
Write-Host ""
$langChoice = Read-Host "Enter 1 or 2 [1]"
if (-not $langChoice) { $langChoice = "1" }

# --- Create all directories (idempotent) ---
$dirs = @(
  "raw\articles", "raw\podcasts", "raw\papers", "raw\my-notes", "raw\assets",
  "wiki\summaries", "wiki\concepts", "wiki\entities",
  "wiki\scenarios", "wiki\syntheses", "wiki\qa"
)
foreach ($dir in $dirs) {
  New-Item -ItemType Directory -Force -Path $dir | Out-Null
  # Ensure .gitkeep exists
  $gitkeep = Join-Path $dir ".gitkeep"
  if (-not (Test-Path $gitkeep)) { New-Item -ItemType File -Force -Path $gitkeep | Out-Null }
}
Write-Host "✓ Directory structure created"

# --- Copy the appropriate CLAUDE.md ---
if ($langChoice -eq "2") {
  if (Test-Path "CLAUDE.zh-CN.md") {
    Copy-Item "CLAUDE.zh-CN.md" -Destination "CLAUDE.md" -Force
    Write-Host "✓ CLAUDE.md set to Chinese version"
  } else {
    Write-Host "Warning: CLAUDE.zh-CN.md not found, keeping existing CLAUDE.md"
  }
} else {
  Write-Host "✓ Using English CLAUDE.md (default)"
}

# --- Seed wiki/INDEX.md if missing or empty ---
$indexPath = "wiki\INDEX.md"
if (-not (Test-Path $indexPath) -or (Get-Item $indexPath).Length -eq 0) {
  Write-UTF8NoBOM $indexPath @"
---
title: Wiki Index
last_updated: (updated automatically after each ingest)
---

## Concepts

## Entities

## Syntheses

## QA

## Summaries
"@
  Write-Host "✓ wiki\INDEX.md initialized"
}

# --- Seed wiki/log.md if missing or empty ---
$logPath = "wiki\log.md"
if (-not (Test-Path $logPath) -or (Get-Item $logPath).Length -eq 0) {
  $today = Get-Date -Format "yyyy-MM-dd"
  Write-UTF8NoBOM $logPath @"
# Operation Log

## [$today] init | Knowledge base initialized | 0
"@
  Write-Host "✓ wiki\log.md initialized"
}

# --- Optional: Obsidian plugin setup ---
Write-Host ""
$setupObsidian = Read-Host "Set up Obsidian plugins (Clipper + Dataview + Templater)? [y/N]"
if ($setupObsidian -match "^[Yy]$") {
  function Install-ObsidianPlugin {
    param([string]$PluginId, [string]$Repo)
    $pluginDir = ".obsidian\plugins\$PluginId"
    New-Item -ItemType Directory -Force -Path $pluginDir | Out-Null
    $base = "https://github.com/$Repo/releases/latest/download"
    Write-Host "  Downloading $PluginId..."
    try {
      Invoke-WebRequest -Uri "$base/main.js"       -OutFile "$pluginDir\main.js"       -UseBasicParsing
      Invoke-WebRequest -Uri "$base/manifest.json" -OutFile "$pluginDir\manifest.json" -UseBasicParsing
      try {
        Invoke-WebRequest -Uri "$base/styles.css"  -OutFile "$pluginDir\styles.css"    -UseBasicParsing
      } catch { <# styles.css is optional #> }
    } catch {
      Write-Host "  ✗ Failed to download $PluginId. Check your internet connection."
      if (Test-Path $pluginDir) { Remove-Item -Recurse -Force $pluginDir }
    }
  }

  New-Item -ItemType Directory -Force -Path ".obsidian\plugins" | Out-Null

  Install-ObsidianPlugin "obsidian-clipper"    "obsidianmd/obsidian-clipper"
  Install-ObsidianPlugin "dataview"            "blacksmithgu/obsidian-dataview"
  Install-ObsidianPlugin "templater-obsidian"  "SilentVoid13/Templater"

  # Enable plugins
  Write-UTF8NoBOM ".obsidian\community-plugins.json" @'
[
  "obsidian-clipper",
  "dataview",
  "templater-obsidian"
]
'@

  # Templater config — point to templates/ folder
  New-Item -ItemType Directory -Force -Path ".obsidian\plugins\templater-obsidian" | Out-Null
  Write-UTF8NoBOM ".obsidian\plugins\templater-obsidian\data.json" @'
{
  "template_folder": "templates",
  "auto_jump_to_cursor": true,
  "trigger_on_file_creation": false,
  "enable_system_commands": false
}
'@

  # Obsidian app config — exclude non-wiki dirs from graph/search
  Write-UTF8NoBOM ".obsidian\app.json" @'
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
'@

  Write-Host "✓ Obsidian plugins installed (Clipper, Dataview, Templater)"
  Write-Host "  → Open this folder in Obsidian to complete plugin activation"
}

# --- Optional: gbrain setup ---
Write-Host ""
$setupGbrain = Read-Host "Set up gbrain search engine? Requires bun + git [y/N]"
if ($setupGbrain -match "^[Yy]$") {
  # Check bun
  $bunPath = "$env:USERPROFILE\.bun\bin\bun.exe"
  if (-not (Test-Path $bunPath)) {
    Write-Host "  bun not found. Installing bun..."
    powershell -c "irm bun.sh/install.ps1|iex" | Out-Null
    Write-Host "  ✓ bun installed"
  }
  $env:PATH += ";$env:USERPROFILE\.bun\bin"
  if (-not (Test-Path "gbrain")) {
    Write-Host "  Cloning garrytan/gbrain..."
    git clone https://github.com/garrytan/gbrain.git gbrain
  }
  Write-Host "  Installing dependencies..."
  Push-Location gbrain
  bun install --ignore-scripts
  bun link
  Pop-Location
  Write-Host "  Initializing brain database..."
  $env:PATH += ";$env:USERPROFILE\.bun\bin"
  gbrain init
  Write-Host "  Importing wiki pages..."
  gbrain import wiki/ --no-embed
  Write-Host "✓ gbrain ready. Run 'gbrain query <question>' to search."
  Write-Host "  → For vector search: set OPENAI_API_KEY and run 'gbrain embed --stale'"
}

# --- Initialize git repo if not already one ---
if (-not (Test-Path ".git")) {
  git init -q
  Write-Host "✓ Git repository initialized"
} else {
  Write-Host "✓ Git repository already exists, skipping"
}

Write-Host ""
Write-Host "========================================="
Write-Host "  Setup complete!"
Write-Host "========================================="
Write-Host ""
Write-Host "Next steps:"
Write-Host ""
Write-Host "  1. Open this folder in Obsidian"
Write-Host "  2. Open your AI IDE (Kiro / Cursor / Qwen Code) in this folder"
Write-Host "  3. Drop a file into raw\ScenicDatas\ (or raw\articles\, raw\my-notes\)"
Write-Host "  4. Tell your AI:  ingest raw/ScenicDatas/your-file.md"
Write-Host ""
Write-Host "Tip: Edit CLAUDE.md to customize the domain and scenic areas."
Write-Host ""
