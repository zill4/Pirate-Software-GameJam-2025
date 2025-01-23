# Detect OS
ifeq ($(OS),Windows_NT)
    SHELL_EXT := .ps1
else
    SHELL_EXT := .sh
endif

.PHONY: all debug release clean test test-unit test-integration test-bench check

all: debug

debug:
	@pwsh -NoProfile -ExecutionPolicy Bypass -File scripts/build.ps1 -Config Debug

release:
	@pwsh -NoProfile -ExecutionPolicy Bypass -File scripts/build.ps1 -Config Release

clean:
	@pwsh -NoProfile -ExecutionPolicy Bypass -File scripts/clean.ps1

# Basic compilation check (used by CI)
check:
	@pwsh -NoProfile -ExecutionPolicy Bypass -File scripts/check-build.ps1

# Different test levels
test:
	@pwsh -NoProfile -ExecutionPolicy Bypass -File scripts/run-tests.ps1 -Level basic

test-unit:
	@pwsh -NoProfile -ExecutionPolicy Bypass -File scripts/run-tests.ps1 -Level unit

test-integration:
	@pwsh -NoProfile -ExecutionPolicy Bypass -File scripts/run-tests.ps1 -Level integration

test-bench:
	@pwsh -NoProfile -ExecutionPolicy Bypass -File scripts/run-tests.ps1 -Level benchmark

test-all:
	@pwsh -NoProfile -ExecutionPolicy Bypass -File scripts/run-tests.ps1 -Level all