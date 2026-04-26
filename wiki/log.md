# Operation Log

<!-- Append-only. Do not modify existing entries. -->
<!-- Format: ## [YYYY-MM-DD] <type> | <title> | <detail> -->
<!-- Types: ingest | re-ingest | query | scenario | synthesis | lint -->

## [2026-04-26] ingest | 灵山大照壁 | 影响页面数：4（summaries/灵山大照壁, concepts/佛教文化景观, concepts/禅意美学, entities/灵山胜境）
## [2026-04-26] ingest | 拈花广场（微笑广场） | 影响页面数：4（summaries/拈花广场, concepts/佛教文化景观, concepts/禅意美学, entities/拈花湾禅意小镇）
## [2026-04-26] lint | 跳过binary文件 | raw/ScenicDatas/灵山胜境 景点结构化数据集.docx、灵山胜境：历史、文化、景点特色与个性化游览指南.docx、景点景区旅游数据行为分析数据.xlsx 无法直接读取，需人工辅助处理
## [2026-04-26] query | 灵山胜境介绍 | 引用页面：entities/灵山胜境, summaries/灵山大照壁；存入 qa/灵山胜境介绍.md
## [2026-04-26] query | 推荐游玩项目 | 引用页面：entities/灵山胜境, entities/拈花湾禅意小镇, summaries/灵山大照壁, summaries/拈花广场；未存入qa（信息不完整，待docx处理后补充）
## [2026-04-27] synthesis | gbrain 集成 | 第一步：frontmatter 升级（entity_type/location/scenic_area/region/spot_id/gbrain_indexed），CLAUDE.md 补充景区领域规范和 gbrain 架构说明；第二步：gbrain 0.21.0 安装、init（PGLite，29 迁移），import wiki/（9页），MCP server 配置至 ~/.kiro/settings/mcp.json
