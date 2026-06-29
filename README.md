# 专注时钟 (AttentionClock)

一款 macOS 原生专注倒计时应用，默认 25 分钟，支持自定义时长、暂停与结束，并统计每日专注数据。

## 功能

- **一键开始**：打开应用即可点击「开始专注」，默认 25 分钟
- **灵活时长**：可调整默认时长与本次专注时长（±5 分钟快捷调节）
- **完整控制**：支持暂停、继续、提前结束
- **数据统计**：
  - 今日完成次数（🌳 象征每完成一次种一棵树）与总时长
  - 全部汇总、每日记录
  - 日均次数与日均时长
  - 总时长包含完成、暂停结束、提前结束的所有记录

## 运行

### 方式一：Xcode

```bash
open AttentionClock.xcodeproj
```

在 Xcode 中点击 Run (⌘R)。

### 方式二：命令行构建

```bash
xcodebuild -project AttentionClock.xcodeproj -scheme AttentionClock -configuration Debug build
open ~/Library/Developer/Xcode/DerivedData/AttentionClock-*/Build/Products/Debug/AttentionClock.app
```

## 设计

- SwiftUI 原生界面，遵循 Apple Human Interface Guidelines
- 白皙简洁的视觉风格，大圆环进度、细体数字、充足留白
- 系统 Tab 导航：专注 / 统计 / 设置

## 技术栈

- Swift 5 + SwiftUI
- macOS 14.0+
- 本地 JSON 持久化（`~/Library/Application Support/AttentionClock/`）
