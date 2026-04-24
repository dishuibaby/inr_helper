# 抗凝小助手端模块功能清单

> 范围：微信小程序、Flutter Android/iOS、Go 服务端、静态 Cloudflare 文档站。  
> 原则：只做记录、提醒、风险分层和复查管理；不提供自动调药建议。

## 1. 总览

| 端/模块 | 主要职责 | 当前实现方式 | 使用理由 |
|---|---|---|---|
| 微信小程序 | 高频快速记录、微信提醒入口 | 原生小程序 + TypeScript + 统一 request 封装 | 接近用户日常微信场景，记录成本低；原生小程序复杂度低、审核路径清晰 |
| Flutter App | Android/iOS 长期记录与本地提醒 | Flutter + Riverpod + Material UI + API Client 抽象 | 双端共用主体代码，后续适合本地缓存、通知、图表能力 |
| Go API | 业务规则、数据持久化、跨端同步 | Go + Gin + service/repository/model 分层 | 单体优先，性能足够，部署简单；业务规则集中，保证跨端一致 |
| SQLite MVP | 本地/开发主数据存储 | repository 接口 + SQLite 实现 | 当前阶段轻量可运行，便于测试；保留后续 MySQL 切换空间 |
| Cloudflare 文档站 | UI/需求/技术/进度入口 | Workers Static Assets + Markdown 美化预览 | 给用户直接在线查看，文档与原型同源部署，低成本稳定 |

## 2. 微信小程序模块

### 2.1 首页模块

| 节点 | 功能 | 实现方式/方案 | 使用理由 | 状态 |
|---|---|---|---|---|
| 今日服药状态 | 显示今日是否已记录、计划剂量 | `pages/home/home.ts` 调 `/home/summary`，失败时显示 fallback | 首页聚合接口减少前端拼装复杂度；弱网仍可演示 | 已有 MVP |
| 最近一次 INR | 显示校正后 INR 主值、校准前值弱展示 | `latestInr.correctedValue` 主显示，`rawValue` 作为副文案 | 满足“所有地方主显示校正后，同步弱显示校准前” | 已有 MVP |
| 下次检测时间 | 显示 `nextTestAt` | 服务端按检测周期计算后返回 | 保证跨端展示一致，避免端上各算各的 | 已有 MVP |
| 超明显提醒 | 首页顶部强提醒 | `prominentReminder.level/title/body` 驱动 UI | 对未服药/异常 INR 形成强触达，但文案不越界 | 已有 MVP |

### 2.2 服药模块

| 节点 | 功能 | 实现方式/方案 | 使用理由 | 状态 |
|---|---|---|---|---|
| 完成服药 | 用户确认已服药 | 点击后弹确认，POST `/medication/records`，`recordedAt` 由服务端系统时间生成 | 用户不用填时间，记录事实；避免客户端时间被随意修改 | 已有 MVP |
| 明日剂量选择 | 完成后选择“按计划/手动输入” | `tomorrowDoseMode=planned/manual`，手动时校验 `tomorrowDoseTablets` | 不自动建议剂量，只记录用户/医生已确定的信息 | 已有 MVP |
| 不做补服 | 无补服入口 | UI 与文案只保留完成/暂停/漏服记录 | 补服涉及医疗风险，当前阶段避免误导 | 已按需求排除 |

### 2.3 INR 模块

| 节点 | 功能 | 实现方式/方案 | 使用理由 | 状态 |
|---|---|---|---|---|
| INR 列表 | 展示历史检测记录 | GET `/inr/records` 返回 `records` | 后端排序和字段统一，端上只渲染 | 已有 MVP |
| 双曲线趋势 | 显示原始值与校正值 | 响应中返回 `trend[{date, rawValue, correctedValue}]` | 让校正影响可追溯，便于发现仪器/方式偏差 | 已有 MVP |
| 异常分层 | ±0.1 内弱提示，超过强提示 | `classifyInr`/服务端 `abnormalTier`：normal/weak/strong | 减少轻微波动造成焦虑，强异常明确提示复测/咨询医生 | 已有 MVP |
| 检测方式 | 医院/POCT/家用/其他 | 设置页维护 `testMethods`，新增记录带 `testMethod` | 不同方式可能存在系统偏差，配合 offset 保留来源 | 已有 MVP |

### 2.4 设置模块

| 节点 | 功能 | 实现方式/方案 | 使用理由 | 状态 |
|---|---|---|---|---|
| 目标范围 | 设置 INR 下限/上限 | `targetInrMin/Max`，保存前校验 | 用户个体化目标，后续可扩展医生确认来源 | 已有 MVP |
| 检测周期 | 按天/周/月设置 | `testCycle.unit=day/week/month` + `interval` | 覆盖稳定期和调整期不同复查频率 | 已有 MVP |
| 校正偏移量 | 设置 INR offset | `inrOffset` 默认值，新增 INR 可传覆盖值 | 历史记录固化当时 offset，避免改设置影响历史 | 已有 MVP |

## 3. Flutter Android/iOS 模块

### 3.1 首页

- **实现方式**：`HomePage` 使用 `homeSummaryProvider` 拉取 `HomeSummary`；`ReminderBanner` 展示强提醒；`SummaryCard` 展示今日计划、最近 INR、下次检测。
- **理由**：Flutter 端保持与小程序同一 API 契约，便于后续统一验收；Riverpod 让刷新、加载、错误状态清晰。
- **状态**：源码骨架已实现；当前机器缺少 Flutter CLI，未能本机跑 `flutter test`。

### 3.2 服药

- **实现方式**：`MedicationPage` 提供服药动作选择、实际剂量输入、明日剂量模式选择；提交 `CreateMedicationRecordRequest`。
- **UI 方案**：`SegmentedButton` 做动作选择；`DoseModeSelector` 做按计划/手动；手动模式才显示输入框。
- **理由**：渐进式显示减少误填；明日剂量记录不等同调药建议。
- **状态**：已实现 MVP。

### 3.3 INR

- **实现方式**：`InrPage` 拉取记录，`InrTrendCard` 展示趋势；新增表单支持原始 INR、offset、检测方式。
- **UI 方案**：校正值作为列表主值，原始值在标题/副文案弱展示；异常 tier 在 trailing 展示。
- **理由**：符合“校正值优先、原始值可追溯”；图表和列表都能发现长期趋势。
- **状态**：已实现 MVP。

### 3.4 设置

- **实现方式**：`SettingsPage` 展示目标范围、服药时间、检测周期、检测方式、INR offset。
- **后续方案**：增加编辑表单/弹窗并保存到 `/settings`。
- **理由**：当前先完成读取和展示，后续把编辑体验与小程序保持一致。
- **状态**：展示已实现；编辑增强待做。

## 4. 服务端模块

| 模块 | 功能节点 | 实现方式/方案 | 使用理由 | 状态 |
|---|---|---|---|---|
| handler | HTTP 入参/响应 | Gin router + JSON envelope | 统一错误和成功结构，前端处理简单 | 已有 MVP |
| service | 业务规则 | `HomeSummary`、`CreateMedication`、`CreateINR`、`ListINR`、`UpdateSettings` | 规则集中，避免端上重复实现导致不一致 | 已有 MVP |
| repository | 数据访问 | interface + SQLite/memory 实现 | 便于测试，也为 MySQL 切换做准备 | 已有 MVP |
| model | API/领域结构 | Go struct 与 OpenAPI 对齐 | 保持服务端、前端、小程序契约一致 | 已有 MVP |
| 配置 | DB DSN/运行参数 | `internal/config` | 环境差异由配置承担 | 已有 MVP |

### 4.1 首页聚合

- **接口**：`GET /api/v1/home/summary`
- **实现**：读取 settings、latest INR、今日服药记录；计算 nextTestAt；生成 prominentReminder。
- **理由**：首页要快且一致，端上避免多个接口串联。

### 4.2 INR 写入

- **接口**：`POST /api/v1/inr/records`
- **实现**：解析 `testedAt`，取请求 offset 或设置 offset，计算 `correctedValue=round(raw+offset)`，再计算 `trend/abnormalTier`。
- **理由**：校正、分层属于核心业务规则，必须服务端统一。

### 4.3 服药写入

- **接口**：`POST /api/v1/medication/records`
- **实现**：服务端用 `now()` 生成 `recordedAt`，写入动作、实际剂量、明日剂量模式。
- **理由**：记录用户操作事实和系统时间，避免补服逻辑带来医疗风险。

## 5. Cloudflare 文档/原型站

| 节点 | 功能 | 实现方式/方案 | 使用理由 |
|---|---|---|---|
| 主页文档入口 | 按需求、UI、技术方案、架构、数据库、进度分类 | `landing()` 输出文档卡片 | 用户可在 CF 直接查阅，不需要翻仓库 |
| Markdown 美化 | `.md` 路径自动渲染为 HTML | `worker.js` 将 `.md` rewrite 到预览路由；`markdown.js` 客户端渲染 | 保留 Markdown 源文件，同时提供可读页面 |
| 静态构建 | 复制原型路由与文档路由 | `build-dist.py` | Cloudflare Workers Static Assets 无服务端构建依赖 |
| 原型入口 | 微信/Android/iOS 页面路由 | `/wechat/home/` 等 | 文档和 UI 原型可互相对照 |

## 6. 后续功能池

| 功能 | 建议阶段 | 理由 |
|---|---|---|
| 小程序服务通知 | 提醒增强阶段 | 需要模板配置和用户授权，先不阻塞 MVP |
| Flutter 本地通知 | App MVP 后半段 | App 端提醒可靠性更高，但需真机验证 |
| 数据导出 | 稳定记录后 | 便于就医沟通和备份 |
| 多成员/医生协作 | 长期扩展 | 涉及权限和隐私，MVP 不做 |
| 设备导入 | 长期扩展 | 需对接不同设备/格式，先保留 `source` 扩展位 |
| 自动调药建议 | 不做 | 医疗风险高，本产品边界明确排除 |
