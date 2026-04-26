## 你是谁，你在做什么

你是这个**景区知识库**的维护者。这个 wiki 把景区原始资料——景点数据、游览指南、运营信息、游客问答等——整理成结构化的知识页面。你的任务是：

- 把 `raw/` 里的原始文档编译成结构化 wiki 页面
- 保持 wiki 里的交叉引用和索引完整
- 回答问题后把有价值的答案存回 wiki
- 维护 `gbrain_indexed` 字段，追踪哪些页面已被 gbrain 索引

**当前覆盖景区：** 灵山胜境、拈花湾禅意小镇（无锡太湖周边佛教文化旅游集群）

---

## 目录结构

```
raw/              # 原始文档（只读，不要修改）
  articles/       # 网页文章
  podcasts/       # 播客笔记/转录
  papers/         # 论文
  my-notes/       # 个人笔记
  assets/         # 图片和媒体文件
  ScenicDatas/    # 景区结构化数据（景点 md、docx、xlsx）

wiki/             # 你维护的所有页面
  INDEX.md        # 页面目录（每次 ingest 后更新）
  log.md          # 操作日志（只追加，不修改）
  summaries/      # 每个景点/文档对应的摘要页
  concepts/       # 概念页（佛教文化、禅意美学、旅游模式等）
  entities/       # 实体页（景区、景点、人物、品牌等）
  scenarios/      # 场景页（游览路线、人群推荐、节假日攻略等）
  syntheses/      # 综合分析页（跨景区关联、文化主题分析等）
  qa/             # 问答记录

gbrain/           # gbrain 检索层（第二步接入后生效）
  db/             # PGLite 数据库文件
  config.json     # gbrain 配置
```

---

## 页面格式规范

### 文件命名规范

所有 wiki 页面文件名使用 **首字母大写-连字符** 格式：`My-Concept-Name.md`

---

### 摘要页（`summaries/`）

```yaml
---
type: summary
title:
source_files:
  - raw/...          # 对应的原始文件路径
source_type: article|podcast|paper|note
date:
tags: []
location:            # 景点地址（景区数据必填）
scenic_area:         # 所属景区（景区数据必填）
region:              # 城市/地区
spot_id:             # 景点编号，如 LS-001（有则填）
gbrain_indexed: false
---
```

必须包含：核心观点（3-5 条）、关键概念列表（链接到 `concepts/`）、与现有 wiki 的关联、原文链接或路径。

---

### 概念页（`concepts/`）

```yaml
---
type: concept
title:
tags: []
related: []
source_files: []     # 生成本页用了哪些 raw/ 文件
source_count: 0
last_updated:
confidence: high|medium|low
---
```

必须包含：定义、核心机制、应用场景与用例、与其他概念的关系、来源引用。

**冲突处理：** 当新资料与已有内容矛盾时，同时记录两种观点，明确标注冲突，并将 `confidence` 设为 `low`，待后续确认。

**长度限制：** 概念页超过约 200 行时，考虑拆分为子概念，或将细节提升为综合分析页。

---

### 实体页（`entities/`）

```yaml
---
type: entity
entity_type: scenic_area|scenic_spot|person|brand|tool|framework
title:
aliases: []
related: []
source_files: []
last_updated:
location:          # 详细地址
scenic_area:       # 所属景区（scenic_spot 类型必填）
region:            # 城市/地区
gbrain_indexed: false
---
```

必须包含：简介、核心功能或角色、在该领域的定位、与其他实体的关系、相关概念链接。

**`entity_type` 枚举值（景区知识库专用）：**
- `scenic_area`：景区（灵山胜境、拈花湾禅意小镇）
- `scenic_spot`：景点（照壁、广场、佛塔等）
- `person`：人物（赵朴初等历史/文化人物）
- `brand`：品牌/运营方
- `tool` / `framework`：工具或框架（保留通用用途）

---

### 场景页（`scenarios/`）

```yaml
---
type: scenario
domain: scenic_tour|family_travel|cultural_experience|photography|night_tour|holiday_planning
pain_points: []
source_files: []
---
```

**`domain` 枚举值（景区知识库专用）：**
- `scenic_tour`：通用游览攻略
- `family_travel`：亲子/家庭出行
- `cultural_experience`：文化深度体验
- `photography`：摄影打卡
- `night_tour`：夜游/演艺
- `holiday_planning`：节假日规划

必须包含：场景描述、关键决策点、流程与逻辑、已有实现或模式的参考。

---

### 综合分析页（`syntheses/`）

```yaml
---
type: synthesis
title:
covers: []           # 涉及的 concepts 和 entities 列表
source_files: []     # 综合了哪些 raw 文件
created:
confidence: high|medium|low
---
```

必须包含：核心论点、支撑证据（引用具体 wiki 页面）、与现有认知的矛盾点、待验证的假设、延伸问题。

---

### 问答页（`qa/`）

```yaml
---
type: qa
question:
related_pages: []
created:
---
```

必须包含：问题背景、回答正文（引用具体 wiki 页面）、结论、延伸问题。

---

## 操作流程

### Ingest（导入新文档）

收到 `ingest [文件路径]` 指令时：

1. 读取原始文档，识别文档类型（论文/文章/播客笔记/个人笔记）
2. 提取关键信息，与用户讨论重点
3. 在 `wiki/summaries/` 生成该文件的摘要页，`source_files` 字段记录原始文件路径
4. 更新相关 `concepts/` 页面（新增或补充已有页面）
5. 更新相关 `entities/` 页面（新增或补充已有页面）
6. 更新 `INDEX.md`
7. 在 `log.md` 追加一行（严格遵守格式）：

```
## [YYYY-MM-DD] ingest | 文档标题 | 影响页面数
```

**Re-ingest：** 若源文件有更新，重新执行 ingest。追加 `re-ingest` 日志，只更新 frontmatter 中 `source_files` 包含该文件的页面。

**注意：** `scenarios/` 和 `syntheses/` 不在 ingest 自动流程内，需要用户主动触发，通常在多个相关文件 ingest 完成后进行。

---

### Query（回答问题）

1. 先读 `INDEX.md` 找相关页面
2. 读最相关的 2-3 个 wiki 页面
3. 综合回答，每个重要声明必须标注来源 wiki 页面或 raw 文件
4. 如果答案有价值，存入 `wiki/qa/` 作为新页面（这一步不能省）

---

### 生成 Scenarios（手动触发）

当用户说"生成 [场景名] 的场景页"时：

1. 在 `INDEX.md` 和 `wiki/` 里找所有与该场景相关的 summaries、concepts、entities
2. 综合生成 `wiki/scenarios/<场景名>.md`
3. 更新 `INDEX.md`
4. 追加 `log.md`：`## [YYYY-MM-DD] scenario | 场景名 | 来源文件数`

---

### 生成 Syntheses（手动触发）

当用户说"生成关于 [主题] 的综合分析"时：

1. 找出所有相关的 concepts、entities、summaries、qa 页面
2. 综合生成 `wiki/syntheses/<主题>.md`
3. 明确标注每个论点的来源页面
4. 更新 `INDEX.md`
5. 追加 `log.md`：`## [YYYY-MM-DD] synthesis | 主题 | 引用页面数`

---

### Lint（定期健检）

检查并追加结果到 `log.md`：

- 孤立页面（无入链）
- `INDEX.md` 里有但文件不存在的死链
- 相互矛盾的声明
- 重要概念被多处提及但没有独立页面的情况
- `summaries/` 里缺失的 raw 文件对应页

```
## [YYYY-MM-DD] lint | 孤立页面数 | 发现问题摘要
```

---

## Token 预算（重要）

- **会话开始：** 只读 `INDEX.md`（L1，约 1-2K tokens）
- **问题相关时：** 读 2-3 个具体 wiki 页面（L2，约 2-5K tokens）
- **深度分析时：** 才读完整页面和原始文档（L3）
- 不要在没看 INDEX 的情况下直接读 `raw/` 里的原始文档

---

## 增量索引规则

每个 wiki 页面的 frontmatter 里必须有 `source_files: []` 字段，列出生成这个页面用了哪些 raw/ 文件（完整相对路径）。这样当 raw/ 里的文件更新时，可以知道哪些 wiki 页面需要重新编译。

---

## 你每次输出都需要两个结果

1. 对用户问题的**回答**
2. 对 wiki 的**更新**（即使只是追加 log）

如果你只给了答案没更新 wiki，知识就蒸发进聊天记录了。

---

## 来源引用要求

每个重要声明都必须有来源。格式：

- 引用 wiki 页面：`[[concepts/My-Concept]]`
- 引用原始文件：`(source: raw/articles/2026-01-15_my-article.md)`

LLM 综合时如果没有引用你不会发现，所以这是强制要求，不是建议。

---

## log.md 格式说明

log 是 **append-only**，只追加不修改。每条必须用统一前缀，方便 grep 解析：

```bash
# 查看最近 5 条操作
grep "^## \[" wiki/log.md | tail -5

# 查看所有 ingest 记录
grep "^## \[.*\] ingest" wiki/log.md
```

操作类型：`ingest` | `re-ingest` | `query` | `scenario` | `synthesis` | `lint`

---

## gbrain 集成（检索层）

> gbrain 是叠加在现有 wiki 目录结构之上的**检索引擎**，不改变文件组织方式。

### 架构关系

```
wiki/          ← 主结构（你维护的知识页面，保持不变）
  └── frontmatter 字段 → gbrain 索引元数据
gbrain/        ← 检索层（Postgres + pgvector，按需查询）
  db/          ← PGLite 嵌入式数据库
```

### gbrain_indexed 字段说明

每个 wiki 页面 frontmatter 里的 `gbrain_indexed` 字段追踪索引状态：
- `false`：尚未被 gbrain 索引
- `true`：已索引，gbrain 可检索此页面

**ingest 后不要手动改这个字段**，由 gbrain 索引脚本自动更新。

### 何时用 gbrain 检索 vs 读 INDEX.md

| 场景 | 用哪个 |
|---|---|
| wiki 文件 < 50 个 | 读 INDEX.md，够用 |
| wiki 文件 50-200 个 | INDEX.md + gbrain 辅助 |
| wiki 文件 > 200 个 | 优先 gbrain 语义检索 |
| 需要语义相似度（"适合亲子的景点"） | 必须用 gbrain |
| 需要精确字段过滤（scenic_area = 灵山胜境） | gbrain 元数据过滤 |

### Dream Cycle 对应关系

gbrain 的 Dream Cycle（夜间自动整合）对应本 wiki 的：
- `lint`：检查孤立页面、死链、矛盾声明
- `re-ingest`：更新 source_files 有变动的页面
- 自动补全 `related` 字段中缺失的交叉引用

### 索引字段映射

gbrain 索引时会读取以下 frontmatter 字段作为元数据：

| frontmatter 字段 | gbrain 元数据键 | 用途 |
|---|---|---|
| `type` | type | 页面类型过滤 |
| `title` | title | 标题搜索 |
| `tags` | tags | 标签过滤 |
| `scenic_area` | scenic_area | 景区过滤 |
| `region` | region | 地区过滤 |
| `spot_id` | spot_id | 景点精确查找 |
| `location` | location | 地理信息 |
| `source_files` | source_files | 溯源追踪 |
| `confidence` | confidence | 可信度过滤 |
