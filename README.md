# LLM Wiki Template

[![GitHub stars](https://img.shields.io/github/stars/jingw2/llm-wiki-template?style=social)](https://github.com/jingw2/llm-wiki-template/stargazers)

**Build a personal knowledge base powered by Claude Code.**

Drop in raw sources. Ask Claude to ingest them. Get a structured, interlinked wiki — automatically maintained by an LLM that reads, summarizes, cross-references, and answers questions.

> Inspired by [Andrej Karpathy's llm-wiki](https://github.com/karpathy/llm-wiki) concept.

📖 [中文文档 README.zh-CN.md](README.zh-CN.md)

---

## What is this?

The idea is simple: you collect raw materials (articles, podcasts, papers, notes), and Claude Code acts as a tireless wiki editor — reading each source, extracting key ideas, and building a structured knowledge base you can query in natural language.

```
raw/                      ← You drop source files here
  articles/
  podcasts/
  papers/
  my-notes/

wiki/                     ← Claude maintains this
  INDEX.md                ← Master index of all pages
  log.md                  ← Append-only operation log
  summaries/              ← One summary per source file
  concepts/               ← Concept pages (ideas, methods, frameworks)
  entities/               ← Entity pages (people, tools, companies)
  scenarios/              ← Domain-specific scenario pages
  syntheses/              ← Cross-source synthesis and analysis
  qa/                     ← Saved Q&A records
```

Every wiki page has structured YAML frontmatter that tracks which source files it was built from — enabling incremental updates when sources change.

---

## Prerequisites

- **[Claude Code](https://claude.ai/code)** — the CLI that runs as your wiki maintainer
- **A markdown editor** — [Obsidian](https://obsidian.md/) works great for browsing the wiki with graph view and wikilinks; any editor works
- A topic you want to build knowledge around

---

## Quickstart

**Mac / Linux**

```bash
# 1. Use this template (click "Use this template" on GitHub) or clone directly
git clone https://github.com/jingw2/llm-wiki-template.git my-wiki
cd my-wiki

# 2. Run the init script
./init.sh
# → Choose language (English / Chinese)
# → Choose whether to install Obsidian plugins (Claudian + Clipper)

# 3. Open in Claude Code
claude

# 4. Drop a source file into raw/
# (e.g., paste an article into raw/articles/2026-01-15_my-article.md)

# 5. Tell Claude Code to ingest it
# > ingest raw/articles/2026-01-15_my-article.md
```

**Windows (PowerShell)**

```powershell
# 1. Clone the repo
git clone https://github.com/jingw2/llm-wiki-template.git my-wiki
cd my-wiki

# 2. Allow script execution (one-time, current user only)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# 3. Run the init script
.\init.ps1
```

That's it. Claude will generate a summary page, update relevant concept and entity pages, and add an entry to the index and log.

---

## Usage

All operations are natural language commands in Claude Code.

### Ingest a new source

```
ingest raw/articles/my-article.md
```

Claude will:
1. Read and identify the document type
2. Generate `wiki/summaries/My-Article.md`
3. Create or update relevant `concepts/` and `entities/` pages
4. Update `INDEX.md` and append to `log.md`

### Ask a question

Just ask in natural language:

```
What are the key differences between X and Y?
What does the research say about Z?
Summarize everything I know about [topic]
```

Claude searches the wiki first (L1: index → L2: relevant pages → L3: raw sources), answers with citations, and saves the Q&A to `wiki/qa/`.

### Generate a scenario page

```
Generate a scenario page for [scenario name]
```

Claude synthesizes all related knowledge into `wiki/scenarios/<name>.md`.

### Generate a synthesis

```
Generate a synthesis about [topic]
```

Claude cross-references all related concepts, entities, summaries, and Q&A records into `wiki/syntheses/<topic>.md`.

### Run a health check

```
lint
```

Claude checks for orphaned pages, dead links, missing summaries, and contradictions, then appends a report to `log.md`.

---

## Page Types

| Type | Location | Purpose |
|------|----------|---------|
| Summary | `wiki/summaries/` | One page per raw source — key takeaways and links |
| Concept | `wiki/concepts/` | A reusable idea, framework, or method |
| Entity | `wiki/entities/` | A person, tool, company, or framework |
| Scenario | `wiki/scenarios/` | Domain-specific use cases and workflows |
| Synthesis | `wiki/syntheses/` | Cross-source analysis — arguments with evidence |
| Q&A | `wiki/qa/` | Saved answers to questions you've asked |

---

## Customization

### 1. Edit the domain description in `CLAUDE.md`

At the top of `CLAUDE.md`, replace the generic description with your specific domain:

```markdown
## Who You Are

You are the maintainer of this knowledge base. This wiki covers
[your domain — e.g., "machine learning research", "competitive intelligence
for the SaaS industry", "personal finance and investing"].
```

### 2. Set scenario domains

In `CLAUDE.md`, find the scenario frontmatter section and replace `<your-domain>` with values that match your knowledge base:

```yaml
domain: research|engineering|business   # your values here
```

### 3. Add custom raw source categories

Just create a new subdirectory under `raw/`:

```bash
mkdir raw/videos
mkdir raw/tweets
```

Tell Claude what kinds of content to expect there in `CLAUDE.md`.

---

## Obsidian Setup (Optional)

Obsidian is not required but pairs well with this template — the graph view visualizes wiki cross-references beautifully.

### Automatic (via init script)

Run `./init.sh` (or `.\init.ps1` on Windows) and answer **y** when prompted to install plugins. The script will download and configure:

| Plugin | Purpose |
|--------|---------|
| **Claudian** | Chat with Claude directly inside Obsidian |
| **Clipper** | Clip web pages into `raw/articles/` with one click |
| **BRAT** | Manages Claudian updates automatically |

After the script finishes:
1. Open this folder in Obsidian
2. Go to **Settings → Claudian** and enter your API key
3. Plugins activate automatically on startup

### Manual

1. Open Obsidian → "Open folder as vault" → select this directory
2. Go to Settings → Community plugins → Browse
3. Install: **BRAT**, **Clipper**
4. Use BRAT to install Claudian from `YishenTu/claudian`

---

## How It Works

**Token budget strategy:** Claude reads progressively deeper:
- L1 (session start): Only `INDEX.md` (~1–2K tokens)
- L2 (question-relevant): 2–3 specific wiki pages (~2–5K tokens)
- L3 (deep analysis): Full pages and raw source documents

**Incremental indexing:** Every wiki page has `source_files: []` in its frontmatter, recording which raw files contributed to it. When you update a source, Claude knows exactly which wiki pages to recompile.

**Append-only log:** `wiki/log.md` is a permanent record of every operation. Grep-parseable format makes it easy to audit what changed.

---

## Credits

- Inspired by [Andrej Karpathy's llm-wiki](https://github.com/karpathy/llm-wiki)
- Built to work with [Claude Code](https://claude.ai/code) by Anthropic
