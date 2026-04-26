---
title: Wiki Index
last_updated: 2026-04-26
---

## Summaries

- [[summaries/灵山大照壁]] — 灵山胜境入口标志性景观，"华夏第一壁"，青石雕刻，赵朴初题字 (source: raw/ScenicDatas/01_灵山大照壁.md)
- [[summaries/拈花广场]] — 拈花湾禅意小镇入口核心广场，"拈花微笑"鎏金雕塑，夜间演艺重点区域 (source: raw/ScenicDatas/17_拈花广场.md)

## Concepts

- [[concepts/佛教文化景观]] — 以佛教历史、典故、建筑为核心的主题旅游景观体系；涵盖灵山大照壁、拈花广场两处案例
- [[concepts/禅意美学]] — 以禅宗哲学为内核的设计与体验理念；青石、鎏金、光影、仪式感的综合运用

## Entities

- [[entities/灵山胜境]] — 无锡太湖国家旅游度假区大型佛教文化主题景区；成人票210元；含灵山大照壁、梵宫、九龙灌浴等
- [[entities/拈花湾禅意小镇]] — 无锡马山"东方禅意生活乐土"定位景区；成人票150元；含拈花广场、香月花街、拈花塔等

## Syntheses

<!-- 暂无，待多文件 ingest 完成后手动触发 -->

## QA

- [[qa/灵山胜境介绍]] — 灵山胜境基本情况介绍，来源：entities/灵山胜境 + summaries/灵山大照壁

## 待处理文件（binary，需人工辅助读取）

- raw/ScenicDatas/灵山胜境 景点结构化数据集.docx
- raw/ScenicDatas/灵山胜境：历史、文化、景点特色与个性化游览指南.docx
- raw/ScenicDatas/景点景区旅游数据行为分析数据.xlsx

---

## Dataview 动态视图

> 以下查询块需安装 Dataview 插件后生效，自动从 frontmatter 读取数据。

### 所有景点摘要（按景区分组）

```dataview
TABLE scenic_area AS "景区", spot_id AS "景点ID", date AS "录入日期"
FROM "wiki/summaries"
WHERE type = "summary"
SORT scenic_area ASC, spot_id ASC
```

### 所有景区实体

```dataview
TABLE location AS "地址", region AS "地区"
FROM "wiki/entities"
WHERE entity_type = "scenic_area"
SORT title ASC
```

### 未索引页面（gbrain_indexed = false）

```dataview
TABLE type AS "类型", file.folder AS "目录"
FROM "wiki"
WHERE gbrain_indexed = false AND type != null
SORT type ASC
```

### 最近更新的页面

```dataview
TABLE type AS "类型", last_updated AS "更新日期"
FROM "wiki"
WHERE last_updated != null
SORT last_updated DESC
LIMIT 10
```


### 概念页置信度总览

```dataview
TABLE confidence AS "置信度", source_count AS "来源数"
FROM "wiki/concepts"
WHERE type = "concept"
SORT confidence ASC
```
