#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"

APP_NAME="RemoteRemap"
APP_BUNDLE="${APP_NAME}.app"
BUNDLE_ID="com.xiabill.remote-remap"
VERSION="1.0.2"

# 1. 生成图标（不存在时）
if [[ ! -f AppIcon.icns ]]; then
  echo "→ 生成 icon…"
  swiftc -framework Cocoa make-icon.swift -o make-icon
  ./make-icon AppIcon.iconset
  iconutil -c icns AppIcon.iconset -o AppIcon.icns
  rm -rf AppIcon.iconset make-icon
fi

# 2. 清理上次构建
rm -rf "$APP_BUNDLE"
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"

# 2. 编译（仅 arm64；M 芯片本机用，省时间。需要 universal 时加 x86_64 lipo）
echo "→ 编译 arm64…"
swiftc -O -parse-as-library \
  -target arm64-apple-macos13.0 \
  -framework Cocoa -framework SwiftUI -framework CoreGraphics \
  -framework ServiceManagement -framework IOKit \
  RemoteRemap.swift \
  -o "$APP_BUNDLE/Contents/MacOS/$APP_NAME"

file "$APP_BUNDLE/Contents/MacOS/$APP_NAME" | sed 's/^/   /'

# 拷贝 icon 到 bundle
if [[ -f AppIcon.icns ]]; then
  cp AppIcon.icns "$APP_BUNDLE/Contents/Resources/AppIcon.icns"
fi

# 3. Info.plist
cat > "$APP_BUNDLE/Contents/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleExecutable</key><string>${APP_NAME}</string>
  <key>CFBundleIdentifier</key><string>${BUNDLE_ID}</string>
  <key>CFBundleName</key><string>${APP_NAME}</string>
  <key>CFBundleDisplayName</key><string>Remote Remap</string>
  <key>CFBundleVersion</key><string>${VERSION}</string>
  <key>CFBundleShortVersionString</key><string>${VERSION}</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleIconFile</key><string>AppIcon</string>
  <key>LSUIElement</key><true/>
  <key>LSMinimumSystemVersion</key><string>13.0</string>
  <key>NSHighResolutionCapable</key><true/>
  <key>NSHumanReadableCopyright</key><string>© 2026 xiabill</string>
</dict>
</plist>
EOF

# 4. 签名：依次尝试 SIGNING_IDENTITY 环境变量 → RemoteRemap Self-Signed → AirPodsRemap Self-Signed → ad-hoc
#    用稳定证书签名后 cdhash 不变，TCC 权限不会随每次重编丢失。
pick_signing_identity() {
    local candidate
    for candidate in "${SIGNING_IDENTITY:-}" "RemoteRemap Self-Signed" "AirPodsRemap Self-Signed"; do
        [[ -z "$candidate" ]] && continue
        if security find-identity -v -p codesigning 2>/dev/null | grep -q "\"$candidate\""; then
            echo "$candidate"
            return 0
        fi
    done
    return 1
}

if IDENT=$(pick_signing_identity); then
    echo "→ 用 self-signed 证书签名（$IDENT）…"
    codesign --force --deep --sign "$IDENT" "$APP_BUNDLE" >/dev/null
else
    echo "→ ad-hoc 签名（重编后 TCC 权限会丢失。建议跑 ./setup-codesign.sh 创建稳定证书）…"
    codesign --force --deep --sign - "$APP_BUNDLE" >/dev/null
fi

xattr -dr com.apple.quarantine "$APP_BUNDLE" 2>/dev/null || true
touch "$APP_BUNDLE"

echo "✅ 构建完成: $PWD/$APP_BUNDLE"
echo "   启动: open '$PWD/$APP_BUNDLE'"
