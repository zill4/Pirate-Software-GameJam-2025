# Build and Test Scripts

## Building
- Basic debug build: `make build-debug`
- Release build: `make build-release`
- Clean and rebuild: `make clean build-debug`

## Testing
All tests are run through build.zig to ensure proper module dependencies:

- Basic compilation check: `make test-basic`
- Unit tests: `make test-unit`
- Integration tests: `make test-integration`
- All tests: `make test-all`

## Running
- Run the game: `make run`

## Clean
- Clean build artifacts: `make clean`