.PHONY: all debug release dev clean test bench run

all: debug

debug:
	@./scripts/build.sh -t debug

release:
	@./scripts/build.sh -t release

dev:
	@./scripts/build.sh -t dev

clean:
	@./scripts/clean.sh

test:
	@./scripts/run-tests.sh

bench: release
	@./scripts/run-tests.sh --bench

run: debug
	@zig build run