#!/bin/sh
set -eu
cd "$(dirname "$0")/.."
sparkle_dir="${SPARKLE_FRAMEWORK_DIR:-$PWD/build/SourcePackages/artifacts/sparkle/Sparkle/Sparkle.xcframework/macos-arm64_x86_64}"
if [ ! -d "$sparkle_dir/Sparkle.framework" ]; then
    echo "Build the Xcode project with -derivedDataPath build first, or set SPARKLE_FRAMEWORK_DIR." >&2
    exit 1
fi
test_binary=$(mktemp -t static-menu-tests)
trap 'rm -f "$test_binary"' EXIT
clang -fobjc-arc -fmodules -I Static -F "$sparkle_dir" -framework Sparkle \
    -Wl,-rpath,"$sparkle_dir" \
    -framework Cocoa -framework CoreAudio -framework ServiceManagement \
    Static/AppDelegate.m Tests/MenuRefreshTests.m -o "$test_binary"
"$test_binary"
