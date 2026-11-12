#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"

# Sparkle compares BUILD, so it has to go up with every release.
VERSION=1.0.1
BUILD=55
# Updates come from this repository's releases, signed with its own EdDSA key (private half in the
# SPARKLE_PRIVATE_KEY secret), not from upstream.
REPO="${GITHUB_REPOSITORY:-zhangsong2468/StickyWindows-display-sleep-fix}"
FEED_URL="https://github.com/$REPO/releases/latest/download/appcast.xml"
SPARKLE_PUBLIC_KEY="4c756yXBowgtk4eXlzavVuhNOKRJVVoLjCgPCFQCPuw="

if ! xcrun --find xcodebuild >/dev/null 2>&1; then
    echo '缺少完整 Xcode。请安装 Xcode 26 或更新版本，并完成首次启动设置。' >&2
    exit 1
fi

# BUILD_ARCHS=arm64 builds a single slice; the default matches the project's universal Release build.
xcodebuild -project StickyWindows.xcodeproj -scheme StickyWindows \
    -configuration Release -derivedDataPath "$PWD/build" \
    ARCHS="${BUILD_ARCHS:-arm64 x86_64}" ONLY_ACTIVE_ARCH=NO \
    CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO DEVELOPMENT_TEAM= \
    MARKETING_VERSION="$VERSION" CURRENT_PROJECT_VERSION="$BUILD" build

app="$PWD/build/Build/Products/Release/Sticky Windows.app"
plist="$app/Contents/Info.plist"
# A local build must never update to an upstream build, which has none of the patches.
/usr/libexec/PlistBuddy -c "Set :SUFeedURL $FEED_URL" "$plist"
/usr/libexec/PlistBuddy -c "Set :SUPublicEDKey $SPARKLE_PUBLIC_KEY" "$plist"
/usr/libexec/PlistBuddy -c 'Set :SUEnableAutomaticChecks true' "$plist"
# SIGN_IDENTITY: a certificate that stays the same from build to build, so macOS keeps the Accessibility
# grant across updates. Without one the build is ad-hoc signed and every new build has to be granted again.
codesign --force --deep --sign "${SIGN_IDENTITY:--}" "$app"
codesign --verify --deep --strict "$app"
mkdir -p dist
ditto -c -k --sequesterRsrc --keepParent "$app" "$PWD/dist/StickyWindows-$VERSION.zip"
echo "构建完成：$app"
echo "安装归档：$PWD/dist/StickyWindows-$VERSION.zip"
