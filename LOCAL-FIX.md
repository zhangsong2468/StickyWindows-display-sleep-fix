# 本地补丁：熄屏误删标签修复 + 键盘与办公增强

基于 aaronfisher/StickyWindows v0.5.0 官方源码，保留原 LICENSE 和 NOTICE。

## 新增功能（build 52）

快捷键均可在 Settings → Shortcuts 中修改或清除，下面是默认值。

| 功能 | 默认快捷键 | 说明 |
| --- | --- | --- |
| 下一个 / 上一个停靠窗口 | ⌃⌥⌘] / ⌃⌥⌘[ | 拉出下一个窗口，同时收回当前有焦点的停靠窗口，连续按可逐个翻看 |
| 第 N 个停靠窗口 | ⌃⌥⌘1 … ⌃⌥⌘9 | 拉出第 N 个窗口；它已在最前时再按一次收回，并把焦点还给之前的应用 |
| 全部收起 | ⌃⌥⌘0 | 收回所有已拉出的停靠窗口；菜单栏菜单中也有 Tuck All Away |
| 隐藏 / 显示标签 | ⌃⌥⌘H | 临时把所有边缘标签撤下（共享屏幕、演示时用），再按恢复；菜单栏菜单中也有 Hide Tabs |
| 闲置自动收回 | — | Settings → General → Reveal → Tuck idle windows back，默认 Never |

- 编号顺序：按显示器，先左边缘从上到下，再右边缘，再底部边缘从左到右；同组窗口依次排列。
  标签的悬停提示和菜单栏的 Parked 列表会显示编号 / 对应快捷键。
- 隐藏标签期间窗口仍保持停靠，快捷键照常可用；菜单栏图标变暗作为提示。该状态不保存，重启后标签恢复显示。
- 闲置自动收回：窗口拉出后连续这么久没有处于最前（没有键盘焦点）就收回。
  睡眠 / 熄屏的时间不计入；全屏窗口和正在拖动时不收回。

以上功能已通过云端编译，尚未逐项实机验证。

## 熄屏修复范围

仅修复系统休眠或显示器熄屏期间，周期检查误将窗口判为失效并删除全部标签的路径。

- 监听 `NSWorkspace.willSleepNotification` 和 `screensDidSleepNotification`。
- 进入休眠/熄屏状态时暂停 `removeInvalidWindows()`，并清空旧失败计数。
- 收到系统/显示器唤醒通知时解除暂停，继续使用原有的 20 秒清理宽限期。
- 不修改 Peek / Pop-out、窗口布局或真正关闭窗口时的事件处理。

另有一处与行为无关的编译适配：`SettingsView.swift` 中两个 `Binding(set:)` 由方法引用改为等价闭包。
Swift 6.2.4–6.3.3（Xcode 26.3–26.6）在方法引用写法上编译器崩溃，官方 0.5.0 用 Xcode 27.1 构建不受影响。

这是一项针对已观察问题的保护修复；不保证能重新绑定唤醒后永久失效的 AX 引用。

## 构建

需要完整 Xcode（建议 26 或更新版本，以支持工程中的 Icon Composer 资源）。
首次构建还需联网下载 KeyboardShortcuts 和 Sparkle Swift Package。

```sh
bash build-local.sh   # 在仓库根目录执行
```

没有本机 Xcode 时，用 GitHub Actions 构建：推送 `display-sleep-fix` 分支会触发
`.github/workflows/build-local-fix.yml`，在 macOS 26 构建机上运行同一个脚本，
产物以 artifact 形式附在该次运行上。只需要单一架构时可设 `BUILD_ARCHS=arm64`。

脚本使用归档中自带的 Xcode 工程，不依赖 XcodeGen，不使用原作者签名团队。
输出为本地 ad-hoc 签名，未经过 Apple 公证；安装后可能需要重新授予辅助功能权限。
本地构建关闭自动更新检查，避免修复被上游未修复版本覆盖。

## 验证状态

源码修改已完成；GitHub Actions（macOS 26，Xcode 26.6）编译通过，产物为 ad-hoc 签名的通用二进制。
尚未进行熄屏实机回归。

编译后需验证：停靠多个窗口，熄屏至少 30 秒，亮屏等待超过 20 秒，
确认标签和 parked.json 记录仍保留，点击标签可操作窗口；正常关闭窗口仍会删除对应标签。
