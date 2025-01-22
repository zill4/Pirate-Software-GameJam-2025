#!/bin/bash

# Print header
echo -e "\n🚀 Running Z3R0-ENGINE Test Suite"
echo "=================================="

# Record start time
start_time=$(date +%s.%N)

# Clean the zig-cache and zig-out directories
echo -e "🧹 Cleaning build artifacts..."
rm -rf zig-cache/ zig-out/

# Run the tests with color output
echo -e "⚡ Executing tests...\n"
zig build test --color on 2>&1 | while IFS= read -r line; do
    if [[ $line == "run test: error:"* ]]; then
        echo "${line#run test: error: }"
    else
        echo "$line"
    fi
done

# Calculate execution time
end_time=$(date +%s.%N)
execution_time=$(echo "$end_time - $start_time" | bc)
echo "=================================="
printf "⏱️  Test suite completed in %.2f seconds\n\n" $execution_time 