# LLM Wiki 模板

**用 Claude Code 搭建个人知识库。**

丢进原始资料，让 Claude 导入，得到一个结构化、互相链接的 wiki——由 LLM 自动维护，负责阅读、摘要、交叉引用和回答问题。

> 灵感来自 [Andrej Karpathy 的 llm-wiki](https://github.com/karpathy/llm-wiki) 概念。

📖 [English README](README.md)

---

## 这是什么？

思路很简单：你收集原始资料（文章、播客、论文、笔记），Claude Code 充当不知疲倦的 wiki 编辑——读每一份资料，提取关键想法，构建一个可以用自然语言查询的结构化知识库。

```
raw/                      ← 你把原始文件放这里
  articles/
  podcasts/
  papers/
  my-notes/

wiki/                     ← Claude 维护这里
  INDEX.md                ← 所有页面的主索引
  log.md                  ← 只追加的操作日志
  summaries/              ← 每个原始文件对应一个摘要
  concepts/               ← 概念页（思想、方法、框架）
  entities/               ← 实体页（人物、工具、公司）
  scenarios/              ← 场景页（特定领域的用例）
  syntheses/              ← 跨来源的综合分析
  qa/                     ← 保存的问答记录
```

每个 wiki 页面都有结构化的 YAML frontmatter，记录它是从哪些原始文件生成的——方便在原始资料更新时做增量重编译。

---

## 前提条件

- **[Claude Code](https://claude.ai/code)** — 作为 wiki 维护者运行的 CLI 工具
- **Markdown 编辑器** — [Obsidian](https://obsidian.md/) 非常适合（图谱视图 + wikilink），任何编辑器都可以用
- 一个你想积累知识的主题

---

## 快速开始

**Mac / Linux**

```bash
# 1. 使用此模板（点击 GitHub 上的"Use this template"）或直接克隆
git clone https://github.com/jingw2/llm-wiki-template.git my-wiki
cd my-wiki

# 2. 运行初始化脚本
./init.sh
# → 选择语言（英文 / 中文）
# → 选择是否安装 Obsidian 插件（Claudian + Clipper）

# 3. 在 Claude Code 中打开
claude

# 4. 把原始文件放进 raw/
# （例如，把一篇文章粘贴到 raw/articles/2026-01-15_my-article.md）

# 5. 告诉 Claude Code 导入它
# > ingest raw/articles/2026-01-15_my-article.md
```

**Windows（PowerShell）**

```powershell
# 1. 克隆仓库
git clone https://github.com/jingw2/llm-wiki-template.git my-wiki
cd my-wiki

# 2. 允许运行脚本（一次性，仅当前用户）
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# 3. 运行初始化脚本
.\init.ps1
```

就这样。Claude 会生成摘要页，更新相关的概念和实体页，并在索引和日志中添加条目。

---

## 使用方法

所有操作都是在 Claude Code 里用自然语言下达指令。

### 导入新文档

```
ingest raw/articles/my-article.md
```

Claude 会：
1. 读取并识别文档类型
2. 生成 `wiki/summaries/My-Article.md`
3. 创建或更新相关的 `concepts/` 和 `entities/` 页面
4. 更新 `INDEX.md` 并追加到 `log.md`

### 提问

直接用自然语言提问：

```
X 和 Y 的核心区别是什么？
关于 Z，现有资料说了什么？
总结我对 [主题] 的所有认知
```

Claude 会先搜索 wiki（L1: 索引 → L2: 相关页面 → L3: 原始资料），带引用地回答，并把问答保存到 `wiki/qa/`。

### 生成场景页

```
生成 [场景名] 的场景页
```

Claude 把所有相关知识综合成 `wiki/scenarios/<名称>.md`。

### 生成综合分析

```
生成关于 [主题] 的综合分析
```

Claude 交叉引用所有相关概念、实体、摘要和问答，生成 `wiki/syntheses/<主题>.md`。

### 健康检查

```
lint
```

Claude 检查孤立页面、死链、缺失摘要和矛盾内容，并追加报告到 `log.md`。

---

## 页面类型

| 类型 | 位置 | 用途 |
|------|------|------|
| 摘要页 | `wiki/summaries/` | 每个原始文件对应一页——关键要点和链接 |
| 概念页 | `wiki/concepts/` | 可复用的想法、框架或方法 |
| 实体页 | `wiki/entities/` | 人物、工具、公司或框架 |
| 场景页 | `wiki/scenarios/` | 领域特定的用例和工作流 |
| 综合分析页 | `wiki/syntheses/` | 跨来源分析——论点加证据 |
| 问答页 | `wiki/qa/` | 你提问后保存的答案 |

---

## 自定义

### 1. 在 `CLAUDE.md` 里修改领域描述

在 `CLAUDE.md` 顶部，把通用描述替换成你的具体领域：

```markdown
## Who You Are

You are the maintainer of this knowledge base. This wiki covers
[你的领域——例如"机器学习研究"、"AI 产品分析"、"个人投资与理财"]。
```

或者切换到中文版：把 `CLAUDE.zh-CN.md` 的内容复制到 `CLAUDE.md`，再修改领域描述即可（或直接运行 `./init.sh` 并选择中文）。

### 2. 设置场景领域

在 `CLAUDE.md` 中找到场景页的 frontmatter 部分，把 `<your-domain>` 替换成符合你知识库的值：

```yaml
domain: research|engineering|business   # 改成你自己的值
```

### 3. 添加自定义原始资料类别

在 `raw/` 下新建子目录即可：

```bash
mkdir raw/videos
mkdir raw/tweets
```

在 `CLAUDE.md` 里告诉 Claude 这个目录里放的是什么类型的内容。

---

## Obsidian 配置（可选）

Obsidian 不是必须的，但和这个模板配合得很好——图谱视图能漂亮地可视化 wiki 交叉引用。

### 自动安装（推荐）

运行 `./init.sh`（Windows 用 `.\init.ps1`），在提示时输入 **y** 安装插件，脚本会自动下载并配置：

| 插件 | 用途 |
|------|------|
| **Claudian** | 在 Obsidian 内直接与 Claude 对话 |
| **Clipper** | 一键把网页内容剪藏到 `raw/articles/` |
| **BRAT** | 自动管理 Claudian 的后续更新 |

脚本完成后：
1. 用 Obsidian 打开此目录
2. 进入 **设置 → Claudian**，填写你的 API 密钥
3. 插件在启动时自动激活

### 手动安装

1. 打开 Obsidian → "Open folder as vault" → 选择这个目录
2. 设置 → 社区插件 → 浏览
3. 安装：**BRAT**、**Clipper**
4. 通过 BRAT 安装 Claudian：`YishenTu/claudian`

---

## 工作原理

**Token 预算策略：** Claude 分层渐进地读取：
- L1（会话开始）：只读 `INDEX.md`（约 1-2K tokens）
- L2（问题相关）：读 2-3 个具体 wiki 页面（约 2-5K tokens）
- L3（深度分析）：才读完整页面和原始资料

**增量索引：** 每个 wiki 页面的 frontmatter 有 `source_files: []` 字段，记录了哪些原始文件贡献了这个页面。更新原始资料时，Claude 知道确切需要重编译哪些 wiki 页面。

**只追加日志：** `wiki/log.md` 是所有操作的永久记录。格式支持 grep 解析，方便审计变更历史。

---

## 致谢

- 灵感来自 [Andrej Karpathy 的 llm-wiki](https://github.com/karpathy/llm-wiki)
- 基于 Anthropic 的 [Claude Code](https://claude.ai/code) 构建
