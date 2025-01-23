const std = @import("std");
const state = @import("state.zig");
const rps = @import("rps.zig");

test "game state initialization" {
    try state.GameState.init();
}

test "rps game initialization" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const game = try rps.RpsGame.init(allocator);
    defer game.deinit();
}

test "rps game mechanics" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const game = try rps.RpsGame.init(allocator);
    defer game.deinit();

    // Test that computer always wins
    const result = try game.play(.rock);
    try std.testing.expectEqual(result, rps.GameResult.lose);

    // Test move history
    const history = game.getHistory();
    try std.testing.expectEqual(history.len, 1);
    try std.testing.expectEqual(history[0], rps.Choice.rock);
}

test "rps choice mechanics" {
    try std.testing.expect(rps.Choice.rock.beats(.scissors));
    try std.testing.expect(rps.Choice.paper.beats(.rock));
    try std.testing.expect(rps.Choice.scissors.beats(.paper));
}
