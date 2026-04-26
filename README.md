# 景区知识库模板

> Obsidian + llmwiki + gbrain 三层知识库，人能读、AI 能搜、知识能累积。

一个以 Obsidian vault 为载体、llmwiki 为知识规范、gbrain 为检索引擎的领域知识库模板。当前以景区知识库为示范，可替换为任意垂直领域。

---

## 三层架构

```
Obsidian          人的界面：可视化编辑、双链图谱、Dataview 动态表格
    ↕
llmwiki           知识规范：分层结构、frontmatter 元数据、AI 操作协议（CLAUDE.md）
    ↕
gbrain            检索引擎：Postgres + pgvector 混合搜索，支持 10,000+ 文件
```

三层分工明确，互不干扰：

- **Obsidian** 负责人工浏览和编辑，知识图谱可视化
- **llmwiki**（`CLAUDE.md`）定义知识的组织方式和 AI 的操作规范
- **gbrain** 在底层提供规模化检索，文件量小时可不启用

---

## 目录结构

```
raw/                    原始资料（只读）
  articles/             网页文章
  podcasts/             播客笔记
  papers/               论文
  my-notes/             个人笔记
  ScenicDatas/          景区结构化数据

wiki/                   结构化知识页面
  INDEX.md              页面目录 + Dataview 动态视图
  log.md                操作日志（append-only）
  summaries/            景点摘要页
  concepts/             概念页（佛教文化、禅意美学等）
  entities/             实体页（景区、景点、人物等）
  scenarios/            场景页（游览攻略、亲子路线等）
  syntheses/            综合分析页
  qa/                   问答记录

templates/              Obsidian Templater 模板
gbrain/                 gbrain 检索引擎（git submodule）
```

---

## 快速开始

**前提条件**：已安装 [Obsidian](https://obsidian.md) 和 [git](https://git-scm.com)

```bash
git clone <this-repo>
cd <repo-name>
```

**Windows：**
```powershell
.\init.ps1
```

**Mac / Linux：**
```bash
chmod +x init.sh && ./init.sh
```

脚本会自动完成：
- 创建目录结构
- 下载 Obsidian 插件（Clipper、Dataview、Templater）
- 安装 bun（如未安装）
- clone + 初始化 gbrain，导入 wiki 页面

完成后用 Obsidian 打开此文件夹即可。

---

## 支持的 AI 工具

任何能读取 `CLAUDE.md` 的 AI IDE 均可驱动此知识库，无需额外配置：

| 工具 | 说明 |
|---|---|
| [Kiro](https://kiro.dev) | 推荐，原生支持 MCP |
| [Cursor](https://cursor.sh) | 支持 `.cursorrules` / CLAUDE.md |
| [Windsurf](https://codeium.com/windsurf) | 同上 |
| [Qwen Code](https://github.com/QwenLM/qwen-code) | 阿里云，无需 Anthropic key |
| [Claude Code](https://claude.ai/code) | gbrain 原生设计目标 |
| OpenAI Codex | 支持 |

---

## 核心操作

在 AI IDE 中直接用自然语言触发：

```
ingest raw/ScenicDatas/01_灵山大照壁.md     # 导入新景点数据
query 灵山胜境有哪些免费景点                  # 查询知识库
生成亲子游览的场景页                          # 生成场景分析
生成关于佛教文化旅游的综合分析                 # 跨景点综合
lint                                        # 健检：孤立页面、死链、矛盾
```

---

## Obsidian 插件

| 插件 | 用途 | 安装方式 |
|---|---|---|
| **Obsidian Clipper** | 网页剪藏 → `raw/articles/` | init 脚本自动安装 |
| **Dataview** | frontmatter 动态查询表格 | init 脚本自动安装 |
| **Templater** | 新建页面自动填充 frontmatter | init 脚本自动安装 |

Templater 模板位于 `templates/`，覆盖所有页面类型：
`summary` / `entity-scenic_area` / `entity-scenic_spot` / `concept` / `scenario` / `qa`

---

## gbrain 检索

```bash
# 关键词搜索（开箱即用）
gbrain query "灵山胜境门票"

# 向量语义搜索（需要 OpenAI 兼容 API key）
export OPENAI_API_KEY=your-key
gbrain embed --stale
gbrain query "适合老人的景点"

# 同步新增的 wiki 页面
gbrain sync --repo wiki/ && gbrain embed --stale

# 查看索引状态
gbrain stats
```

向量搜索支持 OpenAI 兼容接口，阿里云 DashScope 等国内服务可通过设置 `OPENAI_BASE_URL` 接入（需修改 `gbrain/src/core/embedding.ts` 中的模型名）。

---

## 替换为其他领域

此模板以景区知识库为示范，替换领域只需：

1. 修改 `CLAUDE.md` 顶部的领域描述和 `domain` 枚举值
2. 修改 `entity_type` 枚举（当前为 `scenic_area` / `scenic_spot`）
3. 清空 `wiki/` 下的示范页面，放入自己的 `raw/` 原始资料
4. 运行 `ingest` 重建知识库

适用领域举例：医疗知识库、法律条文库、产品文档库、企业内部知识库。

---

## 技术栈

- [llmwiki](https://github.com/llmwiki/llmwiki) — 知识库规范和 AI 操作协议
- [gbrain](https://github.com/garrytan/gbrain) — Postgres-native 混合搜索引擎（MIT）
- [Obsidian](https://obsidian.md) — Markdown 知识库可视化工具
- PGLite — 嵌入式 Postgres，无需独立数据库服务

---

## License

MIT
