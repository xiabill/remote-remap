#!/bin/bash
# 生成 .dmg 安装镜像（含 Applications 拖拽快捷方式）
set -euo pipefail
cd "$(dirname "$0")"

APP_NAME="RemoteRemap"
APP_BUNDLE="${APP_NAME}.app"
VERSION="1.0.3"
DIST_DIR="dist"
DMG_PATH="${DIST_DIR}/${APP_NAME}-${VERSION}.dmg"
STAGING="${DIST_DIR}/.dmg-staging"

if [[ ! -d "$APP_BUNDLE" ]]; then
  echo "未找到 $APP_BUNDLE，先跑 ./build.sh"
  exit 1
fi

mkdir -p "$DIST_DIR"
rm -rf "$STAGING" "$DMG_PATH"
mkdir -p "$STAGING"

cp -R "$APP_BUNDLE" "$STAGING/"
ln -s /Applications "$STAGING/Applications"
cp USAGE.txt "$STAGING/使用说明.txt"

echo "→ 生成 DMG…"
hdiutil create \
  -volname "Remote Remap ${VERSION}" \
  -srcfolder "$STAGING" \
  -ov \
  -format UDZO \
  "$DMG_PATH" >/dev/null

rm -rf "$STAGING"

SIZE=$(du -h "$DMG_PATH" | awk '{print $1}')
echo "✅ 已生成: $PWD/$DMG_PATH  ($SIZE)"
