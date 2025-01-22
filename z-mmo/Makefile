# Detect OS
ifeq ($(OS),Windows_NT)
    SHELL_EXT := .ps1
else
    SHELL_EXT := .sh
endif

.PHONY: all debug release dev clean test bench run

all: debug

debug:
	@pwsh -NoProfile -ExecutionPolicy Bypass -File scripts/build.ps1 -Config Debug

release:
	@pwsh -NoProfile -ExecutionPolicy Bypass -File scripts/build.ps1 -Config Release

dev:
	@./scripts/build$(SHELL_EXT) -t dev

clean:
	@pwsh -NoProfile -ExecutionPolicy Bypass -File scripts/clean.ps1

test:
	@pwsh -NoProfile -ExecutionPolicy Bypass -File scripts/run-tests.ps1

bench: release
	@./scripts/run-tests$(SHELL_EXT) --bench

run: debug
	@zig build run