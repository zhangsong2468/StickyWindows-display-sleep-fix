#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"

if ! xcrun --find xcodebuild >/dev/null 2>&1; then
    echo '缺少完整 Xcode。请安装 Xcode 26 或更新版本，并完成首次启动设置。' >&2
    exit 1
fi

# BUILD_ARCHS=arm64 builds a single slice; the default matches the project's universal Release build.
xcodebuild -project StickyWindows.xcodeproj -scheme StickyWindows \
    -configuration Release -derivedDataPath "$PWD/build" \
    ARCHS="${BUILD_ARCHS:-arm64 x86_64}" ONLY_ACTIVE_ARCH=NO \
    CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO DEVELOPMENT_TEAM= \
    MARKETING_VERSION=0.5.0 CURRENT_PROJECT_VERSION=51 build

app="$PWD/build/Build/Products/Release/Sticky Windows.app"
# A local patch must not silently update back to an upstream build without the fix.
/usr/libexec/PlistBuddy -c 'Set :SUEnableAutomaticChecks false' "$app/Contents/Info.plist"
codesign --force --deep --sign - "$app"
codesign --verify --deep --strict "$app"
mkdir -p dist
ditto -c -k --sequesterRsrc --keepParent "$app" "$PWD/dist/StickyWindows-0.5.0-display-sleep-fix.zip"
echo "构建完成：$app"
echo "安装归档：$PWD/dist/StickyWindows-0.5.0-display-sleep-fix.zip"
