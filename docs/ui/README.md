# UI 设计说明

本目录用于沉淀抗凝小助手的 UI 设计资料，与技术方案分开维护。

当前仓库根目录仍保留可直接预览和部署的静态原型：

- 入口：`/index.html`
- 逻辑：`/app.js`
- 样式：`/styles.css`
- 平台路由：
  - `/wechat/home/`、`/wechat/records/`、`/wechat/inr/`、`/wechat/me/`
  - `/android/home/`、`/android/records/`、`/android/inr/`、`/android/me/`
  - `/ios/home/`、`/ios/records/`、`/ios/inr/`、`/ios/me/`

## UI 当前范围

- 首页：今日服药、强提醒、最近 INR、下次检测、INR 趋势。
- 记录：每日服药时间线，按系统操作时间记录服药动作。
- INR：校准后/校准前双曲线、异常分层、检测记录。
- 我的/设置：检测方式、偏移量、检测周期、服药规则、通知、账号等。

## 后续建议

正式开发时建议把当前静态原型拆分为：

- Flutter 页面组件规范。
- 微信小程序页面组件规范。
- 设计 Token：颜色、间距、字号、状态色、圆角、阴影。
- 交互规则：完成服药后确认明日剂量、INR 异常提醒、检测周期设置等。
