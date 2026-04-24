# 当前进度与交付状态

> 更新日期：2026-04-25

## 1. 总体状态

| 项目 | 状态 | 说明 |
|---|---|---|
| 静态 UI 原型 | 已完成一版 | 覆盖微信、Android、iOS 主要页面与最新 INR/强提醒/双曲线趋势 |
| 需求整理 | 进行中，已沉淀 | 已按最新 11 条需求更新产品和技术文档 |
| 技术方案 | 已有基础版，本次补充架构报告 | Go/Gin、Flutter、小程序、MySQL、Redis 路线明确 |
| 服务端 MVP | 已实现基础接口 | 首页、服药记录、INR、设置；SQLite 存储 |
| 微信小程序 | 已有 TypeScript MVP | 首页、服药、INR、设置页逻辑与 fallback 数据 |
| Flutter App | 已有源码骨架 | 首页、服药、INR、设置；当前机器缺少 Flutter CLI，未本机测试 |
| OpenAPI 契约 | 已建立 | 覆盖 HomeSummary、Medication、INR、Settings |
| Cloudflare 文档站 | 本次改造 | 主页作为文档入口，Markdown 在线美化查看 |

## 2. 已完成需求映射

| 用户需求 | 当前处理 |
|---|---|
| 首页增加最近一次 INR 和下次检测时间 | 已在原型、API、Flutter、小程序中覆盖 |
| 服药完成后选择明日剂量 | 已有 planned/manual 两种模式，手动模式输入剂量 |
| INR 异常 ±0.1 弱提示，超过强提示 | 服务端、端侧工具函数、UI 原型均覆盖 |
| 设置里添加检测方式 | 设置页与 API settings 中覆盖 |
| 所有地方显示校正后 INR，弱显示校准前 | 首页、INR 列表、趋势文档均按此规则 |
| 检测周期按天/周/月自由设置 | settings.testCycle 支持 day/week/month + interval |
| 首页状态卡片保持 | 原型保留并增强信息层级 |
| 多吃暂不做规划 | 功能池后置，MVP 排除 |
| 不需要补服，只记录服药时间 | 无补服入口；服药记录由服务端生成系统时间 |
| INR 趋势显示校准前/后两条线 | 原型与接口返回 `rawValue/correctedValue` 趋势点 |
| 首页必须有超明显提醒机制 | `prominentReminder` 与首页强提醒卡片 |

## 3. 当前文档入口

| 分类 | 文档 | 内容 |
|---|---|---|
| 需求/功能 | `docs/product/module-feature-inventory.md` | 按端模块梳理功能、实现方式、理由、状态 |
| UI | `docs/ui/README.md` | 三端 UI 原型说明 |
| 技术方案 | `docs/tech/technical-proposal.md` | 总体技术方案、API、阶段拆分 |
| 架构 | `docs/tech/architecture-report.md` | 架构边界、业务流、部署、安全 |
| 数据库/缓存 | `docs/tech/database-and-cache-design.md` | SQLite/MySQL/Redis 设计 |
| 基础数据 | `docs/tech/base-data-and-schema-review.md` | 枚举、默认值、结构审核清单 |
| 开发计划 | `docs/plans/2026-04-24-multiplatform-mvp.md` | 多端 MVP 拆解计划 |

## 4. 已验证项

| 验证项 | 状态 |
|---|---|
| Go 服务端测试 | 已通过（前次提交） |
| Go vet | 已通过（前次提交） |
| 小程序 TypeScript 测试 | 已通过（前次提交） |
| 根项目 build / product / markdown preview | 已通过（前次提交） |
| Flutter test | 当前机器无 Flutter CLI，待安装后补跑 |
| 静态安全 grep | 前次提交未发现敏感信息/危险模式 |
| 独立代码评审 | 前次提交通过；本次文档/主页改造完成后继续评审 |

## 5. 下一步建议

1. 完成 MySQL repository 与 migration。
2. 接入真实微信登录/session。
3. 设置 Redis：session、限流、首页缓存、提醒锁。
4. 小程序补 WXML/WXSS 真实页面联调。
5. Flutter 安装 SDK 后跑测试并补 UI 测试。
6. 实现提醒任务：服药提醒、检测周期提醒、INR 异常提醒。
7. 部署 API 预览环境，Cloudflare 文档站继续作为需求/UI/技术入口。
