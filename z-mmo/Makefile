# Detect OS
ifeq ($(OS),Windows_NT)
    SHELL_EXT := .ps1
else
    SHELL_EXT := .sh
endif

.PHONY: all clean test test-basic test-unit test-integration test-all build-debug build-release run

# Default target
all: build-debug

# Clean build artifacts
clean:
	@pwsh -NoProfile -ExecutionPolicy Bypass -File scripts/clean.ps1

# Test targets - all using build.zig test artifacts
test-basic:
	@pwsh -NoProfile -ExecutionPolicy Bypass -File scripts/run-tests.ps1 -Level basic

test-unit:
	@pwsh -NoProfile -ExecutionPolicy Bypass -File scripts/run-tests.ps1 -Level unit

test-integration:
	@pwsh -NoProfile -ExecutionPolicy Bypass -File scripts/run-tests.ps1 -Level integration

test-all:
	@pwsh -NoProfile -ExecutionPolicy Bypass -File scripts/run-tests.ps1 -Level all

# Build targets
build-debug:
	@pwsh -NoProfile -ExecutionPolicy Bypass -File scripts/build.ps1 -Config Debug

build-release:
	@pwsh -NoProfile -ExecutionPolicy Bypass -File scripts/build.ps1 -Config Release

# Run target
run:
	./zig-out/bin/z-mmo.exe rps