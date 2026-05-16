#!/bin/bash
# 一次性创建本地 self-signed code signing 证书并导入登录钥匙串。
#
# 用稳定证书签名后，cdhash 保持一致 → 辅助功能 / 输入监听权限重编后不丢。
# 跑一次就行。已存在同名证书时会跳过。

set -euo pipefail

CN="${1:-RemoteRemap Self-Signed}"
KEYCHAIN="${HOME}/Library/Keychains/login.keychain-db"
DAYS=3650
TMP_DIR="$(mktemp -d)"
trap "rm -rf '$TMP_DIR'" EXIT

echo "→ 检查是否已有同名 code signing 证书…"
if security find-identity -v -p codesigning "$KEYCHAIN" 2>/dev/null | grep -q "\"$CN\""; then
    echo "✅ 已存在证书 \"$CN\"，跳过创建。build.sh 直接可用。"
    exit 0
fi

echo "→ 生成 X.509 配置 + RSA 2048 私钥 + 自签证书（${DAYS} 天有效）…"
cat > "$TMP_DIR/cert.conf" <<EOF
[req]
distinguished_name = dn
prompt = no
req_extensions = v3_req
[dn]
CN = $CN
[v3_req]
keyUsage = critical, digitalSignature
extendedKeyUsage = critical, codeSigning
basicConstraints = critical, CA:false
EOF

openssl req -new -x509 -days "$DAYS" -nodes \
    -newkey rsa:2048 \
    -keyout "$TMP_DIR/cert.key" \
    -out "$TMP_DIR/cert.crt" \
    -config "$TMP_DIR/cert.conf" \
    -extensions v3_req \
    2>/dev/null

echo "→ 打包成 PKCS#12（legacy 模式 + SHA1 MAC 兼容 macOS Security framework）…"
PASS="tmp"
openssl pkcs12 -export -legacy \
    -macalg SHA1 \
    -keypbe PBE-SHA1-3DES -certpbe PBE-SHA1-3DES \
    -inkey "$TMP_DIR/cert.key" \
    -in "$TMP_DIR/cert.crt" \
    -out "$TMP_DIR/cert.p12" \
    -password "pass:$PASS" \
    -name "$CN" \
    2>/dev/null

echo "→ 导入登录钥匙串…"
security import "$TMP_DIR/cert.p12" -P "$PASS" -A -k "$KEYCHAIN" > /dev/null

echo "→ 标记为可信（仅 codeSign 策略，会弹出电脑密码授权）…"
security add-trusted-cert -d -r trustRoot -p codeSign -k "$KEYCHAIN" "$TMP_DIR/cert.crt" \
    2>&1 | grep -v "SecTrustSettingsSetTrustSettings: The authorization was canceled by the user." || true

if security find-identity -v -p codesigning "$KEYCHAIN" 2>/dev/null | grep -q "\"$CN\""; then
    echo ""
    echo "✅ 证书已就绪：\"$CN\""
    echo "   下一步: ./build.sh"
else
    echo "⚠️ 导入似乎成功但 codesign 找不到。手动到 Keychain Access 把证书设为「始终信任」。"
    exit 1
fi
