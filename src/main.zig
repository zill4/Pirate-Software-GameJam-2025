const std = @import("std");
const testing = std.testing;
const TestContext = @import("testing.zig").TestContext;
const TrackedAllocator = @import("memory/allocator.zig").TrackedAllocator;

pub fn main() !void {
    std.debug.print("Z3R0-ENGINE initializing...\n", .{});
}

test "Memory System - Basic Allocation" {
    const t = TestContext.init("Memory System - Basic Allocation");
    defer t.done();

    // Setup GPA
    t.step("Setting up General Purpose Allocator");
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer {
        const leaked = gpa.deinit();
        testing.expect(leaked == .ok) catch @panic("memory leak detected");
    }
    t.ok("GPA initialized");

    t.step("Initializing Tracked Allocator");
    var tracked = TrackedAllocator.init(gpa.allocator());
    var allocator = tracked.allocator();
    t.ok("Tracked Allocator ready");

    // Test 1: Basic Allocation
    t.step("Testing basic memory allocation");
    var data = try allocator.alloc(u8, 100);
    defer allocator.free(data);
    t.ok("Memory allocated");

    // Test 2: Current Usage
    t.step("Verifying current memory usage");
    try testing.expectEqual(@as(usize, 100), tracked.stats.current_usage);
    t.ok("Current usage verified");

    // Test 3: Total Allocation
    t.step("Verifying total allocation");
    try testing.expectEqual(@as(usize, 100), tracked.stats.total_allocated);
    t.ok("Total allocation verified");

    // Test 4: Memory Freed
    t.step("Verifying freed memory");
    try testing.expectEqual(@as(usize, 0), tracked.stats.total_freed);
    t.ok("Freed memory verified");
}
