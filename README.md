# Remote Remap

把 **2.4G 无线遥控键盘**（XING WEI 系列接收器 / VID `0x1915` PID `0x1025`）的每一颗按键映射到任意键盘 chord（组合键）的 macOS 菜单栏小工具。

> 跟 [AirPodsRemap](https://github.com/xiabill/airpods-remap) 是兄弟项目，同一套 chord 引擎，只是输入源从 AirPods stem 换成了 HID 遥控器。**完全由 [Claude Code](https://claude.com/claude-code) 写就。**

---

## 硬件支持

只认 **VID `0x1915` / PID `0x1025`** 这一款 2.4G USB 接收器。常见于淘宝/AliExpress 卖的 "迷你无线遥控键盘"、"TV box 飞鼠遥控器" 等 Android TV 风格遥控器。

如果你的遥控器 VID/PID 不同，改 `RemoteRemap.swift` 顶部的两个常量即可：

```swift
private let TARGET_VID: Int = 0x1915
private let TARGET_PID: Int = 0x1025
```

---

## 12 颗按键

| 分组 | 物理键 | HID 来源 |
|---|---|---|
| 方向 | ↑ ↓ ← → | Keyboard usage 0x52 / 0x51 / 0x50 / 0x4F |
| 确认 | ⭕ OK | Keyboard usage 0x28 |
| 菜单 | ☰ Menu | Keyboard usage 0x65 |
| 系统 | 🏠 主页 / ↩ 返回 / 🎤 语音 | Consumer usage 0x223 / 0x224 / 0xCF |
| 音量 | 🔊 Vol+ / 🔉 Vol- / 🔇 静音 | Consumer usage 0xE9 / 0xEA / 0xE2 |

每颗键独立映射，支持：

- **任意 chord**：单键或多键（比如 `⌘ ⇧ V`）
- **长按自动重复**：按住遥控器按键不放，立刻触发一次，0.5 秒后开始以约 10 Hz 重复，松手即停（节奏对齐 macOS 系统键盘）
- **65+ 个可选键码**：左右修饰键独立、F13–F20、Letters、Digits、方向键、Space/Return/Esc/Tab/Delete 等

---

## 工作原理（与 AirPodsRemap 的关键差异）

| 方面 | AirPodsRemap | Remote Remap |
|---|---|---|
| 输入源 | CGEventTap 拦 NSSystemDefined (media key) | IOHIDManager 直接读硬件 HID |
| 设备识别 | 不区分（任何 media key 都算） | 按 VID/PID 精确匹配，**只动这台遥控器** |
| 接管方式 | 拦 + 选择性透传 | 双层：IOHID 识别 + CGEventTap 吞咽对应系统事件 |
| 权限 | 辅助功能 | 辅助功能 **+ 输入监听** |

为什么要双层？因为 self-signed app 拿不到 IOKit 的 `kIOHIDOptionsTypeSeizeDevice` 特权（会返回 `0xE00002C1 kIOReturnNotPrivileged`）。所以我们：

1. IOHIDManager **不 seize**，只读事件（用"输入监听"权限）
2. 同时挂一个 CGEventTap（用"辅助功能"权限），当 IOHID 识别到映射按键时，告诉 tap 在接下来的 100ms 内吞掉对应的系统事件
3. 这样既能精确"接管"，又不需要 DriverKit / root

---

## 安装

### 从源码构建

需要 Xcode Command Line Tools（`xcode-select --install`）。

```bash
git clone <repo>
cd remote-keyboard
./setup-codesign.sh    # 一次性：创建 self-signed 证书让权限永久保留
./build.sh             # 编译并签名 RemoteRemap.app
open RemoteRemap.app
```

> 如果跳过 `setup-codesign.sh` 直接 `./build.sh`，会用 ad-hoc 签名 —— 能跑，但每次重编都会丢权限要重新授权。

### 首次启动权限

1. App 启动后状态栏出现遥控器图标 📺
2. 系统会**依次弹两个权限对话框**：
   - 「想要监听键盘事件」→ **输入监听** → 在「系统设置 → 隐私与安全性 → 输入监听」打开 RemoteRemap
   - 「想要控制您的电脑」→ **辅助功能** → 同上路径打开
3. **关键**：每次新装/重建签名都要确认两个权限里 RemoteRemap 是当前签名的版本。授权后**杀掉 app 重新打开**。
4. 状态栏图标变绿点 + "运行中" = 大功告成

---

## 使用

- **左键**状态栏图标 → 配置面板
- **右键**状态栏图标 → 快捷菜单（启动 / 暂停 / 重启 / 退出）
- 每个按键勾选 → 选「点按」or「按住」→ 选目标键（可加多个组成 chord）→ 自动保存

### 状态栏图标颜色

| 颜色 | 含义 |
|---|---|
| 绿点 | 运行中 + 检测到遥控器 |
| 橙点 | 运行中但**找不到遥控器**（拔了 / 没插好） |
| 灰 | 已暂停 |
| 红 | 当前有按键处于"按住"状态（防止 Opt 卡死的提醒） |

---

## 已知限制

### 🎤 语音键无法完全拦截 macOS 听写

按 🎤 时 macOS 会同时启动系统听写（Dictation）。我们能拦住对应的 CGEvent (kc=176)，但 **macOS 还有一条私有路径把 HID Consumer 0xCF 直接路由到听写守护进程**（属于内核 IOHIDEventSystem），用户态 CGEventTap 看不到、也拦不掉。这跟 AirPods Pro 2 stem 事件被锁进 MediaRemote 是同一类问题，只有 DriverKit 系统扩展能解决，本项目作为 self-signed 单文件 app 无法做到。

**绕过方案**：
- 系统设置 → 键盘 → 听写 → 把「快捷键」改成「关闭」或别的组合
- 或者干脆不映射 🎤，让它专门做听写

### 🎙️ 遥控器麦克风 1–2 分钟自动断流

遥控器自带的 USB 麦克风（注册为 16kHz 单声道音频输入）在 macOS 上看着是常开设备，但**实测连续录音 1–2 分钟后会自动断流**，需要再按一次 🎤 才能重新开始。

**根因**：这是**遥控器固件的硬性 timeout**（典型的 TV 遥控器省电策略 —— mic 通电吃电池），不是 macOS / Typeless / 本 app 能干预的。我们尝试过：
- 让其他 app 同时持续读取该 mic → 不能续命
- 寻找 vendor-specific USB 控制命令 → 没有公开文档

**绕过方案**：
- **把第三方听写工具（Typeless / WhisperKey / MacWhisper 等）的输入设备改成 Mac 内置麦克风**，遥控器只用来按键触发。Mac 内置 mic 音质更好、永不超时。
- 或换一款专门为 PC 设计的"始终在线"USB 麦克风遥控器。

### 其他

- 只支持 **VID/PID 写死** 的那一款接收器。其他遥控器需改源码常量。
- 鼠标接口（飞鼠 / pointer 模式）**留给系统处理**，不会被接管 —— 指针功能照常用。
- 100ms 的 tap 吞咽窗口期内，任何其他来源的同 keycode 事件也会被吞。例如映射了 🔊 Vol+，那这 100ms 内 Mac 主键盘的 F12（Vol+）按键也会被吞。实际很少冲突。

---

## 文件结构

```
remote-keyboard/
├── RemoteRemap.swift     # 单文件 app（约 600 行）
├── build.sh              # 编译 + 签名 + 打包成 .app
├── setup-codesign.sh     # 一次性创建 self-signed 证书
├── probe.swift           # 调试工具：列出遥控器所有 HID 事件
└── README.md
```

`probe.swift` 是当时摸清遥控器 12 颗键编码用的探测器，跑 `swift probe.swift` 然后按按键就会打印 raw HID report。出新硬件时可以用来扩展按键表。

---

## License

MIT
