import Cocoa
import SwiftUI
import IOKit
import IOKit.hid
import CoreGraphics
import Combine
import ServiceManagement
import Darwin

// MARK: - 可选键位目录（映射目标可以选的按键）

struct KeyChoice: Identifiable, Hashable {
    let id: String
    let label: String
    let keyCode: UInt16
    let flags: UInt64
}

let keyChoices: [KeyChoice] = [
    .init(id: "lopt",    label: "Left Option ⌥",   keyCode: 58, flags: 0),
    .init(id: "ropt",    label: "Right Option ⌥",  keyCode: 61, flags: 0),
    .init(id: "lcmd",    label: "Left Command ⌘",  keyCode: 55, flags: 0),
    .init(id: "rcmd",    label: "Right Command ⌘", keyCode: 54, flags: 0),
    .init(id: "lctrl",   label: "Left Control ⌃",  keyCode: 59, flags: 0),
    .init(id: "rctrl",   label: "Right Control ⌃", keyCode: 62, flags: 0),
    .init(id: "lshift",  label: "Left Shift ⇧",    keyCode: 56, flags: 0),
    .init(id: "rshift",  label: "Right Shift ⇧",   keyCode: 60, flags: 0),
    .init(id: "fn",      label: "Fn",              keyCode: 63, flags: 0),

    .init(id: "f13", label: "F13", keyCode: 105, flags: 0),
    .init(id: "f14", label: "F14", keyCode: 107, flags: 0),
    .init(id: "f15", label: "F15", keyCode: 113, flags: 0),
    .init(id: "f16", label: "F16", keyCode: 106, flags: 0),
    .init(id: "f17", label: "F17", keyCode:  64, flags: 0),
    .init(id: "f18", label: "F18", keyCode:  79, flags: 0),
    .init(id: "f19", label: "F19", keyCode:  80, flags: 0),
    .init(id: "f20", label: "F20", keyCode:  90, flags: 0),

    .init(id: "space",   label: "Space 空格",         keyCode: 49,  flags: 0),
    .init(id: "return",  label: "Return / Enter ↵",   keyCode: 36,  flags: 0),
    .init(id: "esc",     label: "Escape",             keyCode: 53,  flags: 0),
    .init(id: "tab",     label: "Tab",                keyCode: 48,  flags: 0),
    .init(id: "delete",  label: "Delete ⌫ (退格)",    keyCode: 51,  flags: 0),
    .init(id: "fwddel",  label: "Forward Delete ⌦",   keyCode: 117, flags: 0),

    .init(id: "up",      label: "↑ Up Arrow",         keyCode: 126, flags: 0),
    .init(id: "down",    label: "↓ Down Arrow",       keyCode: 125, flags: 0),
    .init(id: "left",    label: "← Left Arrow",       keyCode: 123, flags: 0),
    .init(id: "right",   label: "→ Right Arrow",      keyCode: 124, flags: 0),
    .init(id: "pgup",    label: "Page Up",            keyCode: 116, flags: 0),
    .init(id: "pgdn",    label: "Page Down",          keyCode: 121, flags: 0),
    .init(id: "home",    label: "Home",               keyCode: 115, flags: 0),
    .init(id: "end",     label: "End",                keyCode: 119, flags: 0),

    .init(id: "n1", label: "1", keyCode: 18, flags: 0),
    .init(id: "n2", label: "2", keyCode: 19, flags: 0),
    .init(id: "n3", label: "3", keyCode: 20, flags: 0),
    .init(id: "n4", label: "4", keyCode: 21, flags: 0),
    .init(id: "n5", label: "5", keyCode: 23, flags: 0),
    .init(id: "n6", label: "6", keyCode: 22, flags: 0),
    .init(id: "n7", label: "7", keyCode: 26, flags: 0),
    .init(id: "n8", label: "8", keyCode: 28, flags: 0),
    .init(id: "n9", label: "9", keyCode: 25, flags: 0),
    .init(id: "n0", label: "0", keyCode: 29, flags: 0),

    .init(id: "kA", label: "A", keyCode:  0, flags: 0),
    .init(id: "kB", label: "B", keyCode: 11, flags: 0),
    .init(id: "kC", label: "C", keyCode:  8, flags: 0),
    .init(id: "kD", label: "D", keyCode:  2, flags: 0),
    .init(id: "kE", label: "E", keyCode: 14, flags: 0),
    .init(id: "kF", label: "F", keyCode:  3, flags: 0),
    .init(id: "kG", label: "G", keyCode:  5, flags: 0),
    .init(id: "kH", label: "H", keyCode:  4, flags: 0),
    .init(id: "kI", label: "I", keyCode: 34, flags: 0),
    .init(id: "kJ", label: "J", keyCode: 38, flags: 0),
    .init(id: "kK", label: "K", keyCode: 40, flags: 0),
    .init(id: "kL", label: "L", keyCode: 37, flags: 0),
    .init(id: "kM", label: "M", keyCode: 46, flags: 0),
    .init(id: "kN", label: "N", keyCode: 45, flags: 0),
    .init(id: "kO", label: "O", keyCode: 31, flags: 0),
    .init(id: "kP", label: "P", keyCode: 35, flags: 0),
    .init(id: "kQ", label: "Q", keyCode: 12, flags: 0),
    .init(id: "kR", label: "R", keyCode: 15, flags: 0),
    .init(id: "kS", label: "S", keyCode:  1, flags: 0),
    .init(id: "kT", label: "T", keyCode: 17, flags: 0),
    .init(id: "kU", label: "U", keyCode: 32, flags: 0),
    .init(id: "kV", label: "V", keyCode:  9, flags: 0),
    .init(id: "kW", label: "W", keyCode: 13, flags: 0),
    .init(id: "kX", label: "X", keyCode:  7, flags: 0),
    .init(id: "kY", label: "Y", keyCode: 16, flags: 0),
    .init(id: "kZ", label: "Z", keyCode:  6, flags: 0),
]

func keyChoice(_ id: String) -> KeyChoice? {
    keyChoices.first { $0.id == id }
}

// MARK: - 遥控器物理按键目录

/// 遥控器上一颗按键的硬件标识。
/// HID 事件用 (usagePage, usage) 唯一识别一颗物理键。
struct RemoteButton: Identifiable, Hashable {
    let id: String          // 配置存储 key
    let label: String       // 显示名
    let usagePage: UInt32   // HID usage page (0x07=Keyboard, 0x0C=Consumer)
    let usage: UInt32       // HID usage id
    /// 若该按键 macOS 有原生等价行为，未映射时透传给系统的"等价物"。
    /// .none 表示无等价（如 Home / Back / Voice 在 Mac 上没动作），未映射就静默丢弃。
    let passthrough: PassthroughKind
}

enum PassthroughKind: Hashable {
    case none
    case keyboard(UInt16)   // Mac virtual keycode
    case consumer(Int32)    // NX_KEYTYPE_* 通过 NSSystemDefined 发出
}

private let NX_KEYTYPE_SOUND_UP:   Int32 =  0
private let NX_KEYTYPE_SOUND_DOWN: Int32 =  1
private let NX_KEYTYPE_MUTE:       Int32 =  7
private let NX_KEYTYPE_PLAY:       Int32 = 16

let remoteButtons: [RemoteButton] = [
    // —— 方向键 + 确定 + 菜单（走标准 HID Keyboard usage page）——
    .init(id: "up",     label: "↑ 上",     usagePage: 0x07, usage: 0x52, passthrough: .keyboard(126)),
    .init(id: "down",   label: "↓ 下",     usagePage: 0x07, usage: 0x51, passthrough: .keyboard(125)),
    .init(id: "left",   label: "← 左",     usagePage: 0x07, usage: 0x50, passthrough: .keyboard(123)),
    .init(id: "right",  label: "→ 右",     usagePage: 0x07, usage: 0x4F, passthrough: .keyboard(124)),
    .init(id: "ok",     label: "⭕ OK 确认", usagePage: 0x07, usage: 0x28, passthrough: .keyboard(36)),
    // Menu HID 0x65 → Mac kVK_Menu (110) Application 键，某些 app 弹右键菜单
    .init(id: "menu",   label: "☰ 菜单",   usagePage: 0x07, usage: 0x65, passthrough: .keyboard(110)),

    // —— 功能键（走 Consumer page，TV 遥控器风格）——
    // Home / Back 在 macOS 上无标准 CGEvent 映射（实测无任何系统事件产生）
    .init(id: "home",   label: "🏠 主页",   usagePage: 0x0C, usage: 0x223, passthrough: .none),
    .init(id: "back",   label: "↩ 返回",   usagePage: 0x0C, usage: 0x224, passthrough: .none),
    // Voice 语音键：macOS 把 HID Consumer 0xCF 转成 Mac kc=176（Apple 给听写/Siri 用的扩展键码）。
    // 实测拦下 kc=176 后 Siri 不会再弹。
    .init(id: "voice",  label: "🎤 语音",   usagePage: 0x0C, usage: 0x0CF, passthrough: .keyboard(176)),
    .init(id: "mute",   label: "🔇 静音",   usagePage: 0x0C, usage: 0x0E2, passthrough: .consumer(NX_KEYTYPE_MUTE)),
    .init(id: "volup",  label: "🔊 音量+",  usagePage: 0x0C, usage: 0x0E9, passthrough: .consumer(NX_KEYTYPE_SOUND_UP)),
    .init(id: "voldn",  label: "🔉 音量-",  usagePage: 0x0C, usage: 0x0EA, passthrough: .consumer(NX_KEYTYPE_SOUND_DOWN)),
]

private let buttonByUsage: [UInt64: RemoteButton] = Dictionary(uniqueKeysWithValues:
    remoteButtons.map { (UInt64($0.usagePage) << 32 | UInt64($0.usage), $0) }
)

func remoteButton(usagePage: UInt32, usage: UInt32) -> RemoteButton? {
    buttonByUsage[UInt64(usagePage) << 32 | UInt64(usage)]
}

// MARK: - 配置（每颗按键对应一个 chord 映射）

enum MappingMode: String, Codable, CaseIterable {
    case tap
    case holdToggle
}

struct ButtonMapping: Codable, Equatable {
    var enabled: Bool
    var keys: [String]
    var mode: MappingMode

    init(enabled: Bool = false, keys: [String] = [], mode: MappingMode = .tap) {
        self.enabled = enabled
        self.keys = keys
        self.mode = mode
    }
}

final class Config: ObservableObject {
    static let shared = Config()
    private let storeKey = "remote_remap_v1"

    /// 每颗按键的映射（key 是 RemoteButton.id）。
    @Published var mappings: [String: ButtonMapping] {
        didSet { save() }
    }

    private init() {
        var initial: [String: ButtonMapping] = [:]
        for b in remoteButtons { initial[b.id] = ButtonMapping() }
        if let data = UserDefaults.standard.data(forKey: storeKey),
           let loaded = try? JSONDecoder().decode([String: ButtonMapping].self, from: data) {
            for (k, v) in loaded { initial[k] = v }
        }
        self.mappings = initial
    }

    private func save() {
        if let data = try? JSONEncoder().encode(mappings) {
            UserDefaults.standard.set(data, forKey: storeKey)
        }
    }

    func resetToDefaults() {
        var fresh: [String: ButtonMapping] = [:]
        for b in remoteButtons { fresh[b.id] = ButtonMapping() }
        mappings = fresh
    }

    func binding(for buttonId: String) -> Binding<ButtonMapping> {
        Binding(
            get: { self.mappings[buttonId] ?? ButtonMapping() },
            set: { self.mappings[buttonId] = $0 }
        )
    }
}

// MARK: - 修饰键 keyCode → CGEventFlags 的对应

private let modifierKeyMask: [UInt16: CGEventFlags] = [
    58: .maskAlternate,
    61: .maskAlternate,
    55: .maskCommand,
    54: .maskCommand,
    59: .maskControl,
    62: .maskControl,
    56: .maskShift,
    60: .maskShift,
    63: .maskSecondaryFn,
]

// MARK: - HID 引擎（独占接管遥控器，处理映射 / 透传）

/// 目标设备：XING WEI 2.4G USB
private let TARGET_VID: Int = 0x1915
private let TARGET_PID: Int = 0x1025

/// 我们自己 post 的 CGEvent 会把这个魔数写进 CGEventSource.userData，
/// 让 handleTap() 一眼认出是自家事件、不吞掉自己。
/// 关键场景：用户把"OK→Enter"，OK 的 swallow=kc36，chord 也是 kc36 —— 不戳就自吞。
private let RR_EVENT_MAGIC: Int64 = 0x52524D50  // "RRMP" ASCII


final class RemoteEngine: ObservableObject {
    static let shared = RemoteEngine()

    @Published private(set) var isRunning = false
    @Published private(set) var deviceConnected = false
    @Published var lastError: String?  // 启动失败时显示给用户

    private var manager: IOHIDManager?
    private var openedDevices: Set<IOHIDDevice> = []
    private var eventTap: CFMachPort?
    private var tapRunLoopSource: CFRunLoopSource?

    /// 长按自动重复：HID down 后等 initialDelay，没松手就以 interval 周期重复触发 chord。
    /// 模仿 macOS 系统键盘的"延迟 + 重复"节奏。
    private var repeatTimers: [String: Timer] = [:]
    private let autoRepeatInitialDelay: TimeInterval = 0.5  // 长按 0.5s 后开始
    private let autoRepeatInterval:     TimeInterval = 0.1  // 之后每 100ms 重复一次

    /// CGEventTap 当前要吞掉的系统事件键集合 —— 由 IOHID 在检测到映射按键时填充。
    /// 双层架构核心：不 seize 设备（避免 0xE00002C1 特权问题），改用 tap 拦截系统事件。
    enum SwallowKey: Hashable {
        case keyboard(Int64)   // Mac 虚拟键码
        case consumer(Int32)   // NX_KEYTYPE_*（NSSystemDefined）
    }
    private var swallowSet: Set<SwallowKey> = []
    private let swallowLock = NSLock()

    private func addSwallow(_ k: SwallowKey) {
        swallowLock.lock(); swallowSet.insert(k); swallowLock.unlock()
    }
    private func removeSwallow(_ k: SwallowKey) {
        swallowLock.lock(); swallowSet.remove(k); swallowLock.unlock()
    }
    private func shouldSwallow(_ k: SwallowKey) -> Bool {
        swallowLock.lock(); defer { swallowLock.unlock() }
        return swallowSet.contains(k)
    }
    private func clearSwallows() {
        swallowLock.lock(); swallowSet.removeAll(); swallowLock.unlock()
    }

    /// 把 RemoteButton 的 passthrough 信息映射成等价的系统事件键，用于吞咽。
    /// 仅当映射启用时才会注册吞咽 —— 未配置的按键不会被拦。
    private func swallowKey(for button: RemoteButton) -> SwallowKey? {
        switch button.passthrough {
        case .keyboard(let kc): return .keyboard(Int64(kc))
        case .consumer(let kt): return .consumer(kt)
        case .none:             return nil
        }
    }

    /// 串行后台队列：所有 chord 的 keyDown/keyUp 都按顺序、带节奏 post
    private let chordQueue = DispatchQueue(label: "RemoteRemap.chord", qos: .userInteractive)
    private let perKeyDelayUS: useconds_t = 12_000

    // ----- 启动 / 停止 -----

    /// 检查并按需请求"输入监听 Input Monitoring"权限。
    /// 关键：必须主动调一次 IOHIDRequestAccess，系统才会把本 app
    /// 加进「系统设置 > 隐私与安全性 > 输入监听」列表里，否则用户根本看不见我们。
    @discardableResult
    func ensureHIDAccess() -> Bool {
        let access = IOHIDCheckAccess(kIOHIDRequestTypeListenEvent)
        if access == kIOHIDAccessTypeGranted { return true }
        // 弹系统授权对话框（非阻塞，立即返回）。用户点了"允许"后需要重启 app 生效。
        let granted = IOHIDRequestAccess(kIOHIDRequestTypeListenEvent)
        return granted
    }

    /// 辅助功能权限（post CGEvent 需要）。
    @discardableResult
    func ensureAccessibility(prompt: Bool) -> Bool {
        let opts = [
            kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: prompt
        ] as CFDictionary
        return AXIsProcessTrustedWithOptions(opts)
    }

    @discardableResult
    func start() -> Bool {
        if isRunning { return true }

        // 1. 必须先有输入监听权限。第一次会弹系统对话框 → 把本 app 加进列表。
        if !ensureHIDAccess() {
            DispatchQueue.main.async { [weak self] in
                self?.lastError = "缺少「输入监听」权限。系统已弹授权对话框，请在「系统设置 → 隐私与安全性 → 输入监听」打开 RemoteRemap，然后退出 App 重新启动。"
            }
            return false
        }
        // 2. 辅助功能权限（post 模拟按键用）。第一次也会弹对话框。
        _ = ensureAccessibility(prompt: true)

        let m = IOHIDManagerCreate(kCFAllocatorDefault, IOOptionBits(kIOHIDOptionsTypeNone))

        // 只按 VID/PID 匹配，让所有接口（Keyboard / Mouse / Consumer）都进来。
        // dispatch() 里按 (usagePage, usage) 查表过滤，未知元素自动丢弃 ——
        // 所以体感飞鼠的 pointer 事件不会被误处理（我们只认 remoteButtons 里列的按键）。
        let matching: [String: Any] = [
            kIOHIDVendorIDKey as String:  TARGET_VID,
            kIOHIDProductIDKey as String: TARGET_PID,
        ]
        IOHIDManagerSetDeviceMatching(m, matching as CFDictionary)

        let selfPtr = Unmanaged.passUnretained(self).toOpaque()

        IOHIDManagerRegisterDeviceMatchingCallback(m, { ctx, _, _, device in
            guard let ctx else { return }
            let me = Unmanaged<RemoteEngine>.fromOpaque(ctx).takeUnretainedValue()
            me.onDeviceMatched(device)
        }, selfPtr)

        IOHIDManagerRegisterDeviceRemovalCallback(m, { ctx, _, _, device in
            guard let ctx else { return }
            let me = Unmanaged<RemoteEngine>.fromOpaque(ctx).takeUnretainedValue()
            me.onDeviceRemoved(device)
        }, selfPtr)

        IOHIDManagerScheduleWithRunLoop(m, CFRunLoopGetMain(), CFRunLoopMode.defaultMode.rawValue)

        // 不 seize（self-signed app 拿不到 com.apple.developer.driverkit.* entitlement，
        // seize 会返回 kIOReturnNotPrivileged 0xE00002C1）。
        // 改成普通 open 读事件 + CGEventTap 吞咽对应系统事件实现"替换"效果。
        let r = IOHIDManagerOpen(m, IOOptionBits(kIOHIDOptionsTypeNone))
        if r != kIOReturnSuccess {
            let hex = String(format: "0x%X", UInt32(bitPattern: r))
            DispatchQueue.main.async { [weak self] in
                self?.lastError = "IOHIDManagerOpen 返回 \(hex)。请确认遥控器已插入、并且「输入监听」权限给到了 RemoteRemap。"
            }
            NSLog("RemoteEngine: IOHIDManagerOpen failed: \(hex)")
            IOHIDManagerUnscheduleFromRunLoop(m, CFRunLoopGetMain(), CFRunLoopMode.defaultMode.rawValue)
            return false
        }

        // 安装 CGEventTap，负责拦截/吞咽系统事件。
        // 失败通常是 Accessibility 权限不足 —— 这时 IOHID 部分仍工作（叠加模式：
        // Home/Back/Voice/Menu 这些 Mac 无默认动作的键可正常触发映射）。
        if !installEventTap() {
            DispatchQueue.main.async { [weak self] in
                self?.lastError = "已启动 HID 监听，但 CGEventTap 安装失败 —— 多半是「辅助功能」权限未授予。Home/Back/Voice/Menu 仍可工作；方向键/Vol/Mute 的映射会与系统行为叠加。请到「系统设置 → 隐私与安全性 → 辅助功能」打开 RemoteRemap，重启 App。"
            }
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.lastError = nil
            }
        }

        manager = m
        isRunning = true
        return true
    }

    private func installEventTap() -> Bool {
        if eventTap != nil { return true }

        // 关注 keyDown / keyUp（虚拟键码 10/11）+ NSSystemDefined（14）
        let mask: CGEventMask = (1 << 10) | (1 << 11) | (1 << 14)
        let selfPtr = Unmanaged.passUnretained(self).toOpaque()

        guard let tap = CGEvent.tapCreate(
            tap: .cghidEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: mask,
            callback: { _, type, event, userInfo in
                guard let userInfo = userInfo else { return Unmanaged.passUnretained(event) }
                let me = Unmanaged<RemoteEngine>.fromOpaque(userInfo).takeUnretainedValue()
                return me.handleTap(type: type, event: event)
            },
            userInfo: selfPtr
        ) else {
            return false
        }

        let src = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        CFRunLoopAddSource(CFRunLoopGetMain(), src, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)

        eventTap = tap
        tapRunLoopSource = src
        return true
    }

    private func handleTap(type: CGEventType, event: CGEvent) -> Unmanaged<CGEvent>? {
        if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
            if let tap = eventTap { CGEvent.tapEnable(tap: tap, enable: true) }
            return Unmanaged.passUnretained(event)
        }

        // 自家发的 chord 事件携带 RR_EVENT_MAGIC，直接放行 ——
        // 否则会发生"OK→Enter 把自己也吞了"那类自吞 bug。
        if event.getIntegerValueField(.eventSourceUserData) == RR_EVENT_MAGIC {
            return Unmanaged.passUnretained(event)
        }

        if type == .keyDown || type == .keyUp {
            let kc = event.getIntegerValueField(.keyboardEventKeycode)
            if shouldSwallow(.keyboard(kc)) { return nil }
        } else if type.rawValue == 14 {
            guard let nsEvent = NSEvent(cgEvent: event), nsEvent.subtype.rawValue == 8 else {
                return Unmanaged.passUnretained(event)
            }
            let keyType = Int32((nsEvent.data1 & 0xFFFF0000) >> 16)
            if shouldSwallow(.consumer(keyType)) { return nil }
        }
        return Unmanaged.passUnretained(event)
    }

    func stop() {
        guard isRunning else { return }
        stopAllAutoRepeats()
        clearSwallows()
        if let tap = eventTap {
            CGEvent.tapEnable(tap: tap, enable: false)
        }
        if let src = tapRunLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetMain(), src, .commonModes)
        }
        eventTap = nil
        tapRunLoopSource = nil
        if let m = manager {
            IOHIDManagerClose(m, IOOptionBits(kIOHIDOptionsTypeNone))
            IOHIDManagerUnscheduleFromRunLoop(m, CFRunLoopGetMain(), CFRunLoopMode.defaultMode.rawValue)
        }
        manager = nil
        openedDevices.removeAll()
        DispatchQueue.main.async { [weak self] in
            self?.deviceConnected = false
        }
        isRunning = false
    }

    func toggle() {
        if isRunning { stop() } else { _ = start() }
    }

    // ----- 设备连接 / 断开 -----

    private func onDeviceMatched(_ device: IOHIDDevice) {
        openedDevices.insert(device)

        let selfPtr = Unmanaged.passUnretained(self).toOpaque()
        IOHIDDeviceRegisterInputValueCallback(device, { ctx, _, _, value in
            guard let ctx else { return }
            let me = Unmanaged<RemoteEngine>.fromOpaque(ctx).takeUnretainedValue()
            me.handleInputValue(value)
        }, selfPtr)

        DispatchQueue.main.async { [weak self] in
            self?.deviceConnected = true
        }
    }

    private func onDeviceRemoved(_ device: IOHIDDevice) {
        openedDevices.remove(device)
        DispatchQueue.main.async { [weak self] in
            self?.deviceConnected = !(self?.openedDevices.isEmpty ?? true)
        }
    }

    // ----- 输入处理 -----

    private func handleInputValue(_ value: IOHIDValue) {
        let element = IOHIDValueGetElement(value)
        let usagePage = IOHIDElementGetUsagePage(element)
        let usage = IOHIDElementGetUsage(element)
        let intValue = IOHIDValueGetIntegerValue(value)

        // 只处理我们认识的物理按键。array element / ErrorRollOver / 空 usage 全部忽略。
        guard let button = remoteButton(usagePage: usagePage, usage: usage) else { return }

        let isDown = (intValue != 0)
        dispatch(button: button, isDown: isDown)
    }

    private func dispatch(button: RemoteButton, isDown: Bool) {
        let cfg = Config.shared
        let mapping = cfg.mappings[button.id] ?? ButtonMapping()

        // 没启用映射 → 不动，让系统照常处理（飞鼠模式等不会冲突）
        guard mapping.enabled, !mapping.keys.isEmpty else { return }

        // 有映射 + 该按键有等价系统事件：告诉 tap 在接下来的窗口里吞掉它
        if let sk = swallowKey(for: button) {
            if isDown {
                addSwallow(sk)
            } else {
                // 100ms 延迟摘除，确保系统的"按起"事件（以及 auto-repeat 残留）也被吞掉
                let key = sk
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                    self?.removeSwallow(key)
                }
            }
        }

        if isDown {
            // 立即 fire 一次（保持点按的即时响应感）
            postChordDown(keyIds: mapping.keys)
            postChordUp(keyIds: mapping.keys)
            // 启动长按自动重复
            startAutoRepeat(buttonId: button.id, keys: mapping.keys)
        } else {
            stopAutoRepeat(buttonId: button.id)
        }
    }

    private func startAutoRepeat(buttonId: String, keys: [String]) {
        stopAutoRepeat(buttonId: buttonId)  // 防御性：清掉残留 timer
        let interval = autoRepeatInterval
        let initial = Timer.scheduledTimer(withTimeInterval: autoRepeatInitialDelay, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            // 进入重复阶段
            let repeating = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
                self?.postChordDown(keyIds: keys)
                self?.postChordUp(keyIds: keys)
            }
            self.repeatTimers[buttonId] = repeating
        }
        repeatTimers[buttonId] = initial
    }

    private func stopAutoRepeat(buttonId: String) {
        repeatTimers[buttonId]?.invalidate()
        repeatTimers[buttonId] = nil
    }

    private func stopAllAutoRepeats() {
        for (_, t) in repeatTimers { t.invalidate() }
        repeatTimers.removeAll()
    }

    // ----- chord 输出（从 AirPodsRemap 复用） -----

    private func postChordDown(keyIds: [String]) {
        let choices = keyIds.compactMap { keyChoice($0) }
        let baseFlagsArr: [UInt64] = {
            var accumulated: CGEventFlags = []
            return choices.map { c in
                let f = CGEventFlags(rawValue: c.flags).union(accumulated).rawValue
                if let mod = modifierKeyMask[c.keyCode] { accumulated.insert(mod) }
                return f
            }
        }()
        let delay = perKeyDelayUS
        chordQueue.async { [weak self] in
            guard let self else { return }
            for (i, c) in choices.enumerated() {
                self.postKeyDown(keyCode: c.keyCode, flags: baseFlagsArr[i])
                if i < choices.count - 1 { usleep(delay) }
            }
        }
    }

    private func postChordUp(keyIds: [String]) {
        let choices = keyIds.compactMap { keyChoice($0) }
        var accumulated: CGEventFlags = []
        for c in choices {
            if let mod = modifierKeyMask[c.keyCode] { accumulated.insert(mod) }
        }
        let reversed = Array(choices.reversed())
        let baseFlagsArr: [UInt64] = reversed.map { c in
            if let mod = modifierKeyMask[c.keyCode] { accumulated.remove(mod) }
            return CGEventFlags(rawValue: c.flags).union(accumulated).rawValue
        }
        let delay = perKeyDelayUS
        chordQueue.async { [weak self] in
            guard let self else { return }
            for (i, c) in reversed.enumerated() {
                self.postKeyUp(keyCode: c.keyCode, flags: baseFlagsArr[i])
                if i < reversed.count - 1 { usleep(delay) }
            }
        }
    }

    private func postKeyDown(keyCode: UInt16, flags: UInt64) {
        let src = CGEventSource(stateID: .hidSystemState)
        let down = CGEvent(keyboardEventSource: src, virtualKey: keyCode, keyDown: true)
        var f = CGEventFlags(rawValue: flags)
        if let modMask = modifierKeyMask[keyCode] { f.insert(modMask) }
        down?.flags = f
        // 自家戳：把 RR magic 写进 event 的 sourceUserData 字段，handleTap 见到就放行
        down?.setIntegerValueField(.eventSourceUserData, value: RR_EVENT_MAGIC)
        down?.post(tap: .cghidEventTap)
    }

    private func postKeyUp(keyCode: UInt16, flags: UInt64) {
        let src = CGEventSource(stateID: .hidSystemState)
        let up = CGEvent(keyboardEventSource: src, virtualKey: keyCode, keyDown: false)
        up?.flags = CGEventFlags(rawValue: flags)
        up?.setIntegerValueField(.eventSourceUserData, value: RR_EVENT_MAGIC)
        up?.post(tap: .cghidEventTap)
    }

}

// MARK: - 开机自启动

final class LaunchAtLogin: ObservableObject {
    static let shared = LaunchAtLogin()
    @Published private(set) var isEnabled: Bool = false
    @Published var lastError: String?

    private init() { refresh() }

    func refresh() {
        isEnabled = SMAppService.mainApp.status == .enabled
    }

    func setEnabled(_ enabled: Bool) {
        do {
            if enabled {
                if SMAppService.mainApp.status != .enabled {
                    try SMAppService.mainApp.register()
                }
            } else {
                if SMAppService.mainApp.status == .enabled {
                    try SMAppService.mainApp.unregister()
                }
            }
            lastError = nil
        } catch {
            lastError = error.localizedDescription
            NSLog("LaunchAtLogin error: \(error)")
        }
        refresh()
    }
}

// MARK: - SwiftUI: 单按键配置行（从 AirPodsRemap MappingRow 改造）

struct MappingRow: View {
    let button: RemoteButton
    @Binding var mapping: ButtonMapping

    private var firstKeyBinding: Binding<String> {
        Binding(
            get: { mapping.keys.first ?? "lopt" },
            set: { v in
                if mapping.keys.isEmpty { mapping.keys.append(v) }
                else { mapping.keys[0] = v }
            }
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            // 主行：勾选 + 名字 + 第一个按键 + 加号
            HStack(spacing: 6) {
                Toggle("", isOn: $mapping.enabled).labelsHidden()
                Text(button.label)
                    .frame(width: 78, alignment: .leading)
                    .font(.system(size: 12))

                Picker("", selection: firstKeyBinding) {
                    ForEach(keyChoices) { c in Text(c.label).tag(c.id) }
                }
                .labelsHidden()
                .frame(maxWidth: .infinity)
                .disabled(!mapping.enabled)
                .controlSize(.small)

                Button {
                    mapping.keys.append("lopt")
                } label: {
                    Image(systemName: "plus.circle")
                }
                .buttonStyle(.borderless)
                .help("追加 chord 按键")
                .disabled(!mapping.enabled)
            }

            // chord：第 2..N 个按键往下排，缩进对齐到第一个 picker
            if mapping.keys.count > 1 {
                ForEach(1..<mapping.keys.count, id: \.self) { idx in
                    HStack(spacing: 6) {
                        Spacer().frame(width: 102)
                        Image(systemName: "plus")
                            .foregroundColor(.secondary)
                            .font(.system(size: 9))
                        Picker("", selection: Binding(
                            get: { idx < mapping.keys.count ? mapping.keys[idx] : "lopt" },
                            set: { v in if idx < mapping.keys.count { mapping.keys[idx] = v } }
                        )) {
                            ForEach(keyChoices) { c in Text(c.label).tag(c.id) }
                        }
                        .labelsHidden()
                        .frame(maxWidth: .infinity)
                        .controlSize(.small)
                        Button {
                            if idx < mapping.keys.count { mapping.keys.remove(at: idx) }
                        } label: { Image(systemName: "minus.circle") }
                            .buttonStyle(.borderless)
                    }
                    .disabled(!mapping.enabled)
                }
            }
        }
    }
}

// MARK: - SwiftUI: 配置面板主视图

struct ContentView: View {
    @ObservedObject var config = Config.shared
    @ObservedObject var engine = RemoteEngine.shared
    @ObservedObject var loginItem = LaunchAtLogin.shared

    private let groupDpad: [String]    = ["up", "down", "left", "right", "ok", "menu"]
    private let groupSystem: [String]  = ["home", "back", "voice"]
    private let groupVolume: [String]  = ["mute", "volup", "voldn"]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                header
                runStatus
                if let err = engine.lastError {
                    Text("⚠️ \(err)")
                        .font(.caption)
                        .foregroundColor(.orange)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(6)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(6)
                }

                sectionGroup("方向 / 确认", ids: groupDpad)
                sectionGroup("系统功能",   ids: groupSystem)
                sectionGroup("音量",       ids: groupVolume)

                HStack(spacing: 8) {
                    Toggle(isOn: Binding(
                        get: { loginItem.isEnabled },
                        set: { loginItem.setEnabled($0) }
                    )) { Text("开机自启").font(.caption) }
                    .toggleStyle(.checkbox)
                    Spacer()
                    Button("重置全部") { config.resetToDefaults() }
                        .buttonStyle(.borderless).font(.caption)
                    Button("退出") { NSApp.terminate(nil) }
                        .buttonStyle(.borderless).font(.caption)
                        .keyboardShortcut("q")
                }
                .padding(.top, 4)

                if let err = loginItem.lastError {
                    Text("自启动设置失败：\(err)")
                        .font(.caption2).foregroundColor(.orange)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(12)
        }
        .frame(width: 460, height: 540)
    }

    private func sectionGroup(_ title: String, ids: [String]) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption2).foregroundColor(.secondary)
                .padding(.top, 2)
            ForEach(ids, id: \.self) { id in mappingRow(for: id) }
        }
    }

    private var header: some View {
        HStack(spacing: 6) {
            Image(systemName: "av.remote").imageScale(.large)
            Text("Remote Remap").font(.headline)
            Spacer()
            Circle()
                .fill(engine.isRunning && engine.deviceConnected ? Color.green
                      : engine.isRunning ? Color.orange : Color.secondary)
                .frame(width: 8, height: 8)
            Text(engine.isRunning
                 ? (engine.deviceConnected ? "运行中" : "等待设备")
                 : "已暂停")
                .font(.caption).foregroundColor(.secondary)
        }
    }

    private var runStatus: some View {
        HStack(spacing: 8) {
            Button {
                if engine.isRunning { engine.stop() } else { _ = engine.start() }
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: engine.isRunning ? "pause.fill" : "play.fill")
                    Text(engine.isRunning ? "暂停" : "启动")
                }.frame(maxWidth: .infinity)
            }
            .keyboardShortcut("s")

            Button("输入监听权限…") {
                NSWorkspace.shared.open(URL(string:
                    "x-apple.systempreferences:com.apple.preference.security?Privacy_ListenEvent")!)
            }
        }
    }

    private func sectionTitle(_ s: String) -> some View {
        Text(s).font(.caption).foregroundColor(.secondary)
    }

    private func mappingRow(for id: String) -> some View {
        Group {
            if let b = remoteButtons.first(where: { $0.id == id }) {
                MappingRow(button: b, mapping: config.binding(for: id))
            }
        }
    }
}

// MARK: - AppDelegate（状态栏 + 弹层 + 右键菜单）

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    private var cancellables = Set<AnyCancellable>()

    func applicationDidFinishLaunching(_ notification: Notification) {
        setvbuf(stdout, nil, _IOLBF, 0)
        _ = Config.shared

        _ = RemoteEngine.shared.start()

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            applyStatusIcon(to: button)
            button.target = self
            button.action = #selector(handleStatusClick(_:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
        updateIconAppearance()

        RemoteEngine.shared.$isRunning
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.updateIconAppearance() }
            .store(in: &cancellables)

        RemoteEngine.shared.$deviceConnected
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.updateIconAppearance() }
            .store(in: &cancellables)

        DistributedNotificationCenter.default.addObserver(
            forName: Notification.Name("AppleInterfaceThemeChangedNotification"),
            object: nil, queue: .main
        ) { [weak self] _ in self?.updateIconAppearance() }

        popover = NSPopover()
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: ContentView())
    }

    private func applyStatusIcon(to button: NSStatusBarButton) {
        let img = NSImage(systemSymbolName: "av.remote", accessibilityDescription: "Remote Remap")
        img?.isTemplate = true
        button.image = img
    }

    private func updateIconAppearance() {
        guard let button = statusItem?.button else { return }
        let eng = RemoteEngine.shared
        button.alphaValue = eng.isRunning ? 1.0 : 0.4
        applyStatusIcon(to: button)
        if eng.isRunning && !eng.deviceConnected {
            button.contentTintColor = .systemOrange
        } else {
            button.contentTintColor = nil
        }
    }

    @objc private func handleStatusClick(_ sender: NSStatusBarButton) {
        guard let event = NSApp.currentEvent else { return }
        if event.type == .rightMouseUp || event.modifierFlags.contains(.control) {
            showContextMenu(from: sender, event: event)
        } else {
            togglePopover(sender)
        }
    }

    private func togglePopover(_ sender: Any?) {
        guard let button = statusItem.button else { return }
        if popover.isShown {
            popover.performClose(sender)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            popover.contentViewController?.view.window?.makeKey()
        }
    }

    private func showContextMenu(from button: NSStatusBarButton, event: NSEvent) {
        let menu = NSMenu()
        let eng = RemoteEngine.shared

        let toggle = NSMenuItem(
            title: eng.isRunning ? "⏸  暂停" : "▶  启动",
            action: #selector(menuToggleRunning), keyEquivalent: "s")
        toggle.target = self
        menu.addItem(toggle)

        let stateItem = NSMenuItem(
            title: eng.isRunning ? (eng.deviceConnected ? "状态：运行中" : "状态：运行中（未检测到遥控器）")
                                 : "状态：已暂停",
            action: nil, keyEquivalent: "")
        stateItem.isEnabled = false
        menu.addItem(stateItem)

        menu.addItem(.separator())

        let cfg = Config.shared
        let enabledRows = remoteButtons.compactMap { b -> NSMenuItem? in
            guard let m = cfg.mappings[b.id], m.enabled, !m.keys.isEmpty else { return nil }
            let names = m.keys.compactMap { keyChoice($0)?.label }.joined(separator: " + ")
            let item = NSMenuItem(title: "\(b.label) → \(names)", action: nil, keyEquivalent: "")
            item.isEnabled = false
            return item
        }
        if enabledRows.isEmpty {
            let item = NSMenuItem(title: "（尚未配置任何映射）", action: nil, keyEquivalent: "")
            item.isEnabled = false
            menu.addItem(item)
        } else {
            for r in enabledRows { menu.addItem(r) }
        }

        menu.addItem(.separator())

        let openConfig = NSMenuItem(title: "打开配置面板",
            action: #selector(menuOpenConfig), keyEquivalent: ",")
        openConfig.target = self
        menu.addItem(openConfig)

        let openListen = NSMenuItem(title: "输入监听权限设置…",
            action: #selector(menuOpenListenEvent), keyEquivalent: "")
        openListen.target = self
        menu.addItem(openListen)

        let resetItem = NSMenuItem(title: "重置全部映射",
            action: #selector(menuReset), keyEquivalent: "")
        resetItem.target = self
        menu.addItem(resetItem)

        menu.addItem(.separator())

        let loginItem = NSMenuItem(title: "开机时自动启动",
            action: #selector(menuToggleLoginItem), keyEquivalent: "")
        loginItem.target = self
        loginItem.state = LaunchAtLogin.shared.isEnabled ? .on : .off
        menu.addItem(loginItem)

        menu.addItem(.separator())

        let about = NSMenuItem(title: "关于 Remote Remap",
            action: #selector(menuAbout), keyEquivalent: "")
        about.target = self
        menu.addItem(about)

        let restart = NSMenuItem(title: "重新启动",
            action: #selector(menuRestart), keyEquivalent: "r")
        restart.target = self
        menu.addItem(restart)

        let quit = NSMenuItem(title: "退出",
            action: #selector(menuQuit), keyEquivalent: "q")
        quit.target = self
        menu.addItem(quit)

        NSMenu.popUpContextMenu(menu, with: event, for: button)
    }

    @objc private func menuToggleRunning() { RemoteEngine.shared.toggle() }
    @objc private func menuOpenConfig() { togglePopover(nil) }
    @objc private func menuOpenListenEvent() {
        NSWorkspace.shared.open(URL(string:
            "x-apple.systempreferences:com.apple.preference.security?Privacy_ListenEvent")!)
    }
    @objc private func menuReset() { Config.shared.resetToDefaults() }
    @objc private func menuToggleLoginItem() {
        LaunchAtLogin.shared.setEnabled(!LaunchAtLogin.shared.isEnabled)
    }
    @objc private func menuAbout() {
        let alert = NSAlert()
        alert.messageText = "Remote Remap"
        alert.informativeText = """
            把 2.4G 遥控键盘（XING WEI / VID 0x1915）每颗按键映射到任意键盘 chord。

            • 左键状态栏图标 → 配置面板
            • 右键状态栏图标 → 快捷菜单

            版本 1.0.1
            """
        alert.runModal()
    }
    @objc private func menuRestart() {
        let bundlePath = Bundle.main.bundlePath
        let task = Process()
        task.launchPath = "/bin/sh"
        task.arguments = ["-c", "sleep 0.5 && open \"\(bundlePath)\""]
        try? task.run()
        NSApp.terminate(nil)
    }
    @objc private func menuQuit() { NSApp.terminate(nil) }

    func applicationWillTerminate(_ notification: Notification) {
        RemoteEngine.shared.stop()  // 释放设备 + tap，让系统恢复原生处理
    }
}

// MARK: - App 入口

@main
struct RemoteRemapApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        Settings { EmptyView() }
    }
}
