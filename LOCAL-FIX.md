# 本地补丁：熄屏误删标签修复 + 键盘与办公增强 + 固定标签

基于 aaronfisher/StickyWindows v0.5.0 官方源码，保留原 LICENSE 和 NOTICE。
本地构建自 build 54 起版本号标为 1.0.x（仅为本地编号，与上游版本号无关）。

## 自动更新与签名（1.0.1 / build 55 起）

- **更新源**：应用检查本仓库最新 Release 里的 `appcast.xml`
  （`https://github.com/<仓库>/releases/latest/download/appcast.xml`），不再连接上游官方更新源。
- **更新包签名**：使用本仓库自己的 EdDSA 密钥。公钥写在 `build-local.sh`，私钥在仓库 Secret `SPARKLE_PRIVATE_KEY`。
- **代码签名**：使用固定的自签名证书 “Sticky Windows Local Signing”（Secrets `SIGNING_P12_BASE64` / `SIGNING_P12_PASSWORD`），
  签名身份在各次构建间保持不变，目的是更新后保留辅助功能授权。没有这些 Secret 时退回 ad-hoc 签名且不发布。
- **发布新版本**：提高 `build-local.sh` 里的 `VERSION` 和 `BUILD`（Sparkle 比较的是 `BUILD`，必须递增）后推送
  `display-sleep-fix` 分支，工作流会构建并创建 `v<VERSION>` Release（dmg、zip、appcast.xml）。
  版本号不变的推送只留下运行产物，不会覆盖已有 Release。
- 密钥和证书的本机备份在 `~/.sticky-windows-signing/`（不在仓库中）。丢失后已安装的版本无法再收到更新，只能手动重装。
- 仓库必须保持公开，否则下载地址需要登录，更新会失败。
- 仍未经过 Apple 公证：首次安装需右键 → 打开。从 ad-hoc 版本（≤ 1.0.0）升级到 1.0.1 需手动安装并重新授权一次。

## 固定标签 Pin（build 53）

- **固定**：右键标签 → Pin Tab（再点一次取消）。固定的标签左上/右上角有小图钉。
- **常驻**：固定标签的窗口被关闭、应用退出、Sticky Windows 重启或重启电脑后，标签仍留在原位置，变灰表示窗口未打开。
- **点击重开**：点击变灰的固定标签（或用编号快捷键）会启动 / 激活该应用，新出现的窗口重新挂回这个标签并恢复到原来的位置和大小。
  应用能报告文档路径时（预览、文本编辑、Finder 文件夹等）会直接重开原文档；同名窗口已打开则直接接管。
  应用没有新开窗口时，约 1.5 秒后接管该应用当前最前的普通窗口。
- **红色按钮改为收回**（默认关闭）：Settings → General → Reveal → Close button tucks pinned windows。
  打开后，固定窗口被拉出时红色关闭按钮显示为琥珀色，点击是收回到标签而不是关闭；⌥ 点击才真正关闭。
  只对已固定的停靠窗口生效，其他窗口不受影响。
- 取消固定一个已变灰（无窗口）的标签会直接移除它；右键 Remove Tab 同样移除。

限制：⌘W / ⌘Q 无法拦截，窗口仍会真的关闭（标签保留，可点击重开）；浏览器页面、终端会话等无法恢复到同一内容，重开的是该应用的新窗口。
分组标签（多个窗口共用一个标签）内的固定窗口没有单独的图钉 / 变灰显示。

已通过云端编译，尚未实机验证。

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
本机直接运行脚本时输出为 ad-hoc 签名（可用 `SIGN_IDENTITY` 指定证书），未经过 Apple 公证；ad-hoc 构建安装后需要重新授予辅助功能权限。
更新源已改为本仓库，不会被上游未修复版本覆盖。

## 验证状态

源码修改已完成；GitHub Actions（macOS 26，Xcode 26.6）编译通过，产物为 ad-hoc 签名的通用二进制。
尚未进行熄屏实机回归。

编译后需验证：停靠多个窗口，熄屏至少 30 秒，亮屏等待超过 20 秒，
确认标签和 parked.json 记录仍保留，点击标签可操作窗口；正常关闭窗口仍会删除对应标签。
