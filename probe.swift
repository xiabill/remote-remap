// probe.swift
// 探测 XING WEI 2.4G 遥控键盘 (VID 0x1915 / PID 0x1025) 的所有按键
// 运行: swift probe.swift
// 退出: Ctrl+C
//
// 输出三类信息:
//   [REPORT]  原始 HID input report (十六进制), reportID + 字节序列
//   [VALUE]   解析出的单个 HID element: UsagePage / Usage / 值
//   [INFO]    设备插拔/匹配信息
//
// macOS 可能弹出 "输入监听" 权限请求, 同意即可 (针对 Terminal 或当前父进程).

import Foundation
import IOKit
import IOKit.hid

let TARGET_VID: Int = 0x1915
let TARGET_PID: Int = 0x1025

func ts() -> String {
    let f = DateFormatter()
    f.dateFormat = "HH:mm:ss.SSS"
    return f.string(from: Date())
}

func hex(_ data: UnsafePointer<UInt8>, _ len: Int) -> String {
    var s = ""
    for i in 0..<len {
        s += String(format: "%02X ", data[i])
    }
    return s.trimmingCharacters(in: .whitespaces)
}

func usagePageName(_ page: UInt32) -> String {
    switch page {
    case 0x01: return "GenericDesktop"
    case 0x07: return "Keyboard"
    case 0x09: return "Button"
    case 0x0C: return "Consumer"
    case 0xFF00...0xFFFF: return "VendorDefined(0x\(String(page, radix: 16)))"
    default:   return "Page(0x\(String(page, radix: 16)))"
    }
}

// ---- 回调: 每次输入报告 ----
let reportCallback: IOHIDReportCallback = { context, result, sender, reportType, reportID, report, reportLength in
    let bytes = hex(report, reportLength)
    print("[\(ts())] [REPORT] id=\(reportID) len=\(reportLength)  \(bytes)")
}

// ---- 回调: 每个 HID element 的值变化 ----
let inputValueCallback: IOHIDValueCallback = { context, result, sender, value in
    let element = IOHIDValueGetElement(value)
    let usagePage = IOHIDElementGetUsagePage(element)
    let usage = IOHIDElementGetUsage(element)
    let intValue = IOHIDValueGetIntegerValue(value)
    // 过滤掉 release=0 的噪声? 先全部打印, 方便看 down/up
    print("[\(ts())] [VALUE]  \(usagePageName(usagePage)) usage=0x\(String(usage, radix: 16))  value=\(intValue)")
}

// ---- 回调: 设备匹配/移除 ----
let matchingCallback: IOHIDDeviceCallback = { context, result, sender, device in
    let vid = IOHIDDeviceGetProperty(device, kIOHIDVendorIDKey as CFString) as? Int ?? 0
    let pid = IOHIDDeviceGetProperty(device, kIOHIDProductIDKey as CFString) as? Int ?? 0
    let product = IOHIDDeviceGetProperty(device, kIOHIDProductKey as CFString) as? String ?? "?"
    let usagePage = IOHIDDeviceGetProperty(device, kIOHIDPrimaryUsagePageKey as CFString) as? Int ?? 0
    let usage = IOHIDDeviceGetProperty(device, kIOHIDPrimaryUsageKey as CFString) as? Int ?? 0
    print("[\(ts())] [INFO] matched: \(product)  VID=0x\(String(vid, radix: 16)) PID=0x\(String(pid, radix: 16))  primaryUsagePage=0x\(String(usagePage, radix: 16)) usage=0x\(String(usage, radix: 16))")

    // 申请独立 reportBuffer
    let bufSize = 64
    let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufSize)
    IOHIDDeviceRegisterInputReportCallback(device, buffer, bufSize, reportCallback, nil)
    IOHIDDeviceRegisterInputValueCallback(device, inputValueCallback, nil)
}

let removalCallback: IOHIDDeviceCallback = { context, result, sender, device in
    print("[\(ts())] [INFO] removed device")
}

// ---- 启动 IOHIDManager ----
let manager = IOHIDManagerCreate(kCFAllocatorDefault, IOOptionBits(kIOHIDOptionsTypeNone))

// 匹配该 VID/PID 下的所有 HID interface (键盘 + 厂商页都能抓到)
let matching: [String: Any] = [
    kIOHIDVendorIDKey as String: TARGET_VID,
    kIOHIDProductIDKey as String: TARGET_PID,
]
IOHIDManagerSetDeviceMatching(manager, matching as CFDictionary)

IOHIDManagerRegisterDeviceMatchingCallback(manager, matchingCallback, nil)
IOHIDManagerRegisterDeviceRemovalCallback(manager, removalCallback, nil)

IOHIDManagerScheduleWithRunLoop(manager, CFRunLoopGetMain(), CFRunLoopMode.defaultMode.rawValue)

let openResult = IOHIDManagerOpen(manager, IOOptionBits(kIOHIDOptionsTypeNone))
if openResult != kIOReturnSuccess {
    print("[\(ts())] [INFO] IOHIDManagerOpen failed: 0x\(String(openResult, radix: 16))")
    print("       提示: 第一次运行时, macOS 可能要求 '输入监听 (Input Monitoring)' 权限.")
    print("       请到 系统设置 > 隐私与安全性 > 输入监听 中, 给运行该脚本的 Terminal 勾上, 然后重跑.")
    exit(1)
}

print("[\(ts())] [INFO] probing VID=0x\(String(TARGET_VID, radix: 16)) PID=0x\(String(TARGET_PID, radix: 16))  —— 按遥控器上任意键试试, Ctrl+C 退出")

CFRunLoopRun()
