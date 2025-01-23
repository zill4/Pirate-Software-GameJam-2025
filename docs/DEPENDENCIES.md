# Development Dependencies

## Required Tools
- Make (GNU Make)
- Zig (v0.13.0)
- Ninja Build System

## Windows Installation

### Using Chocolatey (Recommended)

# CI uses this
make check

# Different test levels
make test           # Basic compilation check
make test-unit      # Unit tests
make test-integration # Integration tests
make test-bench     # Benchmarks
make test-all       # Everything