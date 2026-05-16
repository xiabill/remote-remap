# Remote Remap

> 把 **2.4G 无线遥控键盘** 的每一颗按键独立映射到任意 macOS 键盘 chord 的菜单栏小工具。
> **开源 / MIT / 完全由 [Claude Code](https://claude.com/claude-code) 写就。**

![Hardware](assets/remote-hardware.jpg)

---

## 这是什么

一类便宜的 **2.4G 无线遥控键盘**（淘宝 / 拼多多 / 1688 上几十块到一百多块都能买到，原本是配 Android 电视盒 / HTPC 用的）插到 Mac 上能正常发按键事件，但很多按键 macOS 上没有对应行为或者干的事不是你想要的（比如方向键、🏠 主页、🎤 语音、☰ 菜单等）。

本 app 把这些按键**精确接管**，每颗都可以映射成任意键盘 chord（单键或多键组合，比如 `⌘ ⇧ V`），同时**完美拦截系统的原始事件**，不会双触发。

跟 [AirPodsRemap](https://github.com/xiabill/airpods-remap) 是兄弟项目，共享同一套 chord 引擎。

---

## 项目缘起

开始 vibe coding 之后，对**语音输入** + **手边能一键触发各种快捷键**的需求越来越强。一直在找一个**一体化的硬件**：手里拿着，按一下说话录音、再按一下触发常用快捷键，最好还能配合手势导航。

试了一圈现成方案：

- **Apple TV 遥控器**：主要给 tvOS 用，跟 Mac 配对后大多数按键无意义，自定义能力近乎为零
- **Amazon Fire TV 遥控器**：跟 Apple TV 同病，对 Mac 几乎零支持
- 各种**专业演示器 / Stream Deck mini / 蓝牙手柄**：要么太贵、要么按键太少、要么得装一堆专有软件还只支持自家生态

最后绕了一圈，发现**国产 2.4G 飞鼠遥控键盘**这一类硬件最接近理想：

- 自带麦克风、十几个按键、方向键 + OK + Home/Back/Menu 全有，还能切空中飞鼠模式
- 几十块到一百多块，淘宝 / 拼多多 / 1688 一搜就一大堆
- 插到 Mac 上能被识别成标准 HID 键盘（不需要专有 driver）

唯一问题：macOS 上**原生行为乱七八糟**（方向键移光标、🎤 触发 Siri/听写、Menu 在某些 app 里弹右键菜单……），没法直接当成自定义控制器用。

于是有了这个 app —— **精确接管这类硬件的每颗按键，自定义映射成任何你想要的快捷键 chord**。配合 Typeless / WhisperKey / MacWhisper 这种第三方听写工具（输入设备记得改成 Mac 内置 mic，详见下方限制），就是一套接近完美的「**手持遥控器式 vibe coding 装备**」。

如果你也有类似需求 —— 一边写代码一边窝在沙发上瘫着，按按钮触发各种操作 —— 这个项目就是给你做的。

---

## 兼容硬件

### 已知工作

| 硬件 | VID:PID | 备注 |
|---|---|---|
| **XING WEI 2.4G USB 遥控键盘**（默认） | `0x1915:0x1025` | 淘宝/拼多多搜「**2.4G 无线遥控键盘**」「**Android TV 飞鼠遥控**」等关键词的一大类常见货色用的方案 |

### 想测试你自己的遥控器？

只要它满足这两个条件，**理论上都能用**：

1. 通过 **USB 2.4G 接收器** 接入 Mac（蓝牙的不支持，要改代码）
2. 在 macOS 里被识别为 **HID 键盘**（不是专有 driver）

直接：
1. 安装 v1.0.3+ 版本
2. 配置面板顶部「目标设备」→ 点「切换…」→ **下拉里会列出所有当前接着的 HID 键盘类设备** → 点你的遥控器
3. 试按几颗键，能直接生效就成功了

如果按某些键没反应，说明这颗按键发的 HID usage 跟我们 hardcoded 的列表不一样，**欢迎提 PR / issue 报告**，把按键映射加进 `remoteButtons` 数组即可（详见下方「贡献新设备」）。

### 想全新硬件支持？欢迎贡献

如果你有不同的 2.4G 遥控键盘，跑一下 `swift probe.swift`，按按键看打印出的 HID 事件，把：
- 你的设备 VID/PID
- 每颗按键的 `(usagePage, usage)`
- 一张实物图

**提个 issue 或 PR 过来**，我把它合并进兼容设备列表，让别人也能受益。开源项目大家共建。

---

## 功能

- **12 颗按键独立映射**（方向 × 4 / OK / 菜单 / 主页 / 返回 / 语音 / 静音 / Vol± × 2）
- **任意 chord**：单键或多键组合，修饰键的 flags 自动累加
- **长按自动重复**：开关可关，启动延迟（200–1500ms）+ 重复间隔（30–500ms）滑块可调，节奏对齐 macOS 系统键盘
- **65+ 个可选键码**：左右修饰键独立、F13–F20、Letters、Digits、方向键、Space/Return/Esc/Tab/Delete 等
- **设备热切换**：UI 里扫描 + 选择目标硬件，不需要改源码
- **系统原行为精确拦截**（不会双触发）
- **状态栏 app**：菜单栏图标 / 配置面板 / 右键菜单 / 暂停启动 / 开机自启

---

## 安装

### 方式 A：下载 DMG（推荐）

到 [Releases](https://github.com/xiabill/remote-remap/releases) 下载最新的 `RemoteRemap-x.y.z.dmg`：

1. 双击挂载 → 拖 RemoteRemap.app 到「应用程序」
2. 启动会被 macOS 拦下（self-signed 应用），系统设置 → 隐私与安全性 → 拉到最下 → **仍要打开**
3. 授权两个权限：**输入监听** + **辅助功能**（系统设置 → 隐私与安全性 里都打开 RemoteRemap）
4. 杀掉重启一次：`pkill -f RemoteRemap && open /Applications/RemoteRemap.app`
5. 菜单栏出现遥控器图标 = 成功

### 方式 B：从源码构建

需要 Xcode Command Line Tools (`xcode-select --install`)。

```bash
git clone https://github.com/xiabill/remote-remap
cd remote-remap
./setup-codesign.sh    # 一次性：创建 self-signed 证书让权限永久保留
./build.sh             # 编译 + 签名 + 嵌图标 → RemoteRemap.app
open RemoteRemap.app
```

---

## 工作原理

| 层 | 干什么 |
|---|---|
| **IOHIDManager** | 按 VID/PID 精确匹配你选的那台遥控器（用「输入监听」权限读 HID） |
| **CGEventTap** | 系统级事件钩子，识别到映射按键时吞掉系统原始事件（用「辅助功能」权限） |
| **CGEvent post + sourceUserData magic** | chord 输出，带自家戳防止被 tap 自吞 |
| **Timer** | 长按自动重复，按 Config 的延迟和间隔节奏 fire chord |

为什么不直接 seize HID 设备独占接管？因为 self-signed app 拿不到 `com.apple.developer.driverkit.transport.usb` entitlement，seize 会返回 `kIOReturnNotPrivileged`。CGEventTap 是变通方案，**对绝大多数按键都管用**，少数走系统内核私有路径的（语音键的 macOS 听写）拦不到 —— 详见下方限制。

---

## 已知限制

### 🎤 语音键无法完全拦截 macOS 听写

按 🎤 时 macOS 会同时启动系统听写（Dictation）。我们能拦住对应的 CGEvent (kc=176)，但 **macOS 还有一条私有路径把 HID Consumer 0xCF 直接路由到听写守护进程**（属于内核 IOHIDEventSystem），用户态 CGEventTap 看不到、也拦不掉。这跟 AirPods Pro 2 stem 事件被锁进 MediaRemote 是同一类问题，只有 DriverKit 系统扩展能解决，本项目作为 self-signed 单文件 app 无法做到。

**绕过方案**：
- 系统设置 → 键盘 → 听写 → 把「快捷键」改成「关闭」或别的组合
- 或者干脆不映射 🎤，让它专门做听写

### 🎙️ 遥控器麦克风 1–2 分钟自动断流

遥控器自带的 USB 麦克风（注册为 16kHz 单声道音频输入）在 macOS 上看着是常开设备，但**实测连续录音 1–2 分钟后会自动断流**，需要再按一次 🎤 才能重新开始。

**根因**：这是**遥控器固件的硬性 timeout**（典型的 TV 遥控器省电策略 —— mic 持续通电吃电池），不是 macOS / Typeless / 本 app 能干预的。我们尝试过：
- 让其他 app 同时持续读取该 mic → 不能续命
- 寻找 vendor-specific USB 控制命令 → 没有公开文档

**绕过方案**：
- 把第三方听写工具（Typeless / WhisperKey / MacWhisper 等）的输入设备改成 **Mac 内置麦克风**，遥控器只用来按键触发。Mac 内置 mic 音质更好、永不超时。
- 或换一款专门为 PC 设计的"始终在线"USB 麦克风遥控器。

### 其他

- 鼠标接口（飞鼠 / pointer 模式）**留给系统处理**，不会被接管 —— 指针功能照常用。
- 100ms 的 tap 吞咽窗口期内，任何其他来源的同 keycode 事件也会被吞。例如映射了 🔊 Vol+，这 100ms 内 Mac 主键盘的 F12（Vol+）按键也会被吞。实际很少冲突。

---

## 贡献新设备

如果你的遥控器跟默认的 XING WEI 不一样、有些按键收不到，做这三件事帮我把它加进兼容列表：

1. 跑探测：
   ```bash
   cd remote-remap
   swift probe.swift
   ```
   按一下你想加的按键，记下打印的 `HID page=0xXX usage=0xYY value=1` 这一行
2. 在 `RemoteRemap.swift` 的 `remoteButtons` 数组里加一行：
   ```swift
   .init(id: "myButton", label: "我的按键", usagePage: 0x07, usage: 0xXX, passthrough: .none),
   ```
3. 提 PR / issue，包含：设备 VID/PID + 按键 usage 表 + 实物图

---

## 项目结构

```
remote-keyboard/
├── RemoteRemap.swift     # 单文件 app
├── probe.swift           # HID 事件探测器（加新硬件时用）
├── make-icon.swift       # 程序图标生成器
├── build.sh              # 编译 + 签名 + 打包 .app
├── make-dmg.sh           # 打 DMG
├── setup-codesign.sh     # 一次性创建 self-signed 证书
├── assets/               # README 用的图片
├── USAGE.txt             # 用户使用说明
└── README.md
```

---

## License

MIT — 自由 fork / 改 / 商用。代码全开放，**欢迎提 issue / PR 报告兼容硬件、报 bug、加功能**。

如果这个项目对你有帮助，给个 ⭐ Star。
