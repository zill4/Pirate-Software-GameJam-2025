const std = @import("std");
const memory = @import("memory.zig");

pub fn main() !void {
    // Initialize our game allocator with the page allocator
    var game_allocator = memory.GameAllocator.init(std.heap.page_allocator);
    const allocator = game_allocator.allocator();

    // Example allocation for game state
    const game_state = try allocator.alloc(u8, 1024);
    defer allocator.free(game_state);

    // Print memory stats
    game_allocator.printStats();
}
