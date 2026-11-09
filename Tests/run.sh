#!/bin/sh
set -eu
cd "$(dirname "$0")/.."
test_binary=$(mktemp -t static-menu-tests)
trap 'rm -f "$test_binary"' EXIT
clang -fobjc-arc -fmodules -I Static \
    -framework Cocoa -framework CoreAudio -framework ServiceManagement \
    Static/AppDelegate.m Tests/MenuRefreshTests.m -o "$test_binary"
"$test_binary"
