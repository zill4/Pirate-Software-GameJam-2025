# Basic debug build
./scripts/build.sh

# Release build with tests and benchmarks
./scripts/build.sh -t release -T -b

# Clean, build dev version, and run
./scripts/build.sh -t dev -c -r

# Just run tests
./scripts/run-tests.sh

# Clean build artifacts
./scripts/clean.sh