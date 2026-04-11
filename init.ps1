# LLM Wiki — One-click initialization script (Windows PowerShell)
# Run with: .\init.ps1
# If blocked by execution policy, run first:
#   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

$ErrorActionPreference = "Stop"

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
  @"
---
title: Wiki Index
last_updated: (updated automatically after each ingest)
---

## Concepts

## Entities

## Syntheses

## QA

## Summaries
"@ | Out-File -FilePath $indexPath -Encoding utf8
  Write-Host "✓ wiki\INDEX.md initialized"
}

# --- Seed wiki/log.md if missing or empty ---
$logPath = "wiki\log.md"
if (-not (Test-Path $logPath) -or (Get-Item $logPath).Length -eq 0) {
  $today = Get-Date -Format "yyyy-MM-dd"
  @"
# Operation Log

## [$today] init | Knowledge base initialized | 0
"@ | Out-File -FilePath $logPath -Encoding utf8
  Write-Host "✓ wiki\log.md initialized"
}

# --- Optional: Obsidian plugin setup ---
Write-Host ""
$setupObsidian = Read-Host "Set up Obsidian plugins (Claudian + Clipper)? [y/N]"
if ($setupObsidian -match "^[Yy]$") {
  function Install-ObsidianPlugin {
    param([string]$PluginId, [string]$Repo)
    $pluginDir = ".obsidian\plugins\$PluginId"
    New-Item -ItemType Directory -Force -Path $pluginDir | Out-Null
    $base = "https://github.com/$Repo/releases/latest/download"
    Write-Host "  Downloading $PluginId..."
    Invoke-WebRequest -Uri "$base/main.js"       -OutFile "$pluginDir\main.js"       -UseBasicParsing
    Invoke-WebRequest -Uri "$base/manifest.json" -OutFile "$pluginDir\manifest.json" -UseBasicParsing
    try {
      Invoke-WebRequest -Uri "$base/styles.css"  -OutFile "$pluginDir\styles.css"    -UseBasicParsing
    } catch { <# styles.css is optional #> }
  }

  New-Item -ItemType Directory -Force -Path ".obsidian\plugins" | Out-Null

  Install-ObsidianPlugin "obsidian42-brat"  "TfTHacker/obsidian42-brat"
  Install-ObsidianPlugin "claudian"         "YishenTu/claudian"
  Install-ObsidianPlugin "obsidian-clipper" "jgchristopher/obsidian-clipper"

  # Enable plugins
  @'
[
  "obsidian42-brat",
  "claudian",
  "obsidian-clipper"
]
'@ | Out-File -FilePath ".obsidian\community-plugins.json" -Encoding utf8

  # Configure BRAT to track Claudian for future updates
  New-Item -ItemType Directory -Force -Path ".obsidian\plugins\obsidian42-brat" | Out-Null
  @'
{
  "pluginList": ["YishenTu/claudian"],
  "pluginSubListFrozenVersion": [
    { "repo": "YishenTu/claudian", "version": "latest" }
  ],
  "updateAtStartup": true,
  "enableAfterInstall": true,
  "notificationsEnabled": true
}
'@ | Out-File -FilePath ".obsidian\plugins\obsidian42-brat\data.json" -Encoding utf8

  # Minimal Obsidian app config
  "{}" | Out-File -FilePath ".obsidian\app.json" -Encoding utf8

  Write-Host "✓ Obsidian plugins installed (BRAT, Claudian, Clipper)"
  Write-Host "  → Open this folder in Obsidian to complete plugin activation"
  Write-Host "  → Configure Claudian: Settings → Claudian → enter your API key"
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
Write-Host "  1. Open this folder in Obsidian (or any markdown editor)"
Write-Host "  2. Open Claude Code in this folder:  claude"
Write-Host "  3. Drop a file into raw\articles\    (or podcasts\, papers\, my-notes\)"
Write-Host "  4. Tell Claude Code:  ingest raw/articles/your-file.md"
Write-Host ""
Write-Host "Tip: Edit CLAUDE.md to customize the domain description for your topic."
Write-Host ""
