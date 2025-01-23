const std = @import("std");
const engine = @import("engine");
const state = @import("state.zig");
const game = @import("game");

test "game state initialization" {
    try state.GameState.init();
}

test "game initialization" {
    var game_memory = engine.GameAllocator.init();
    defer game_memory.deinit();

    const game_instance = try game.RpsGame.init(&game_memory);
    defer game_instance.deinit();

    try std.testing.expectEqual(game_instance.player_wins, 0);
}

test "rps game mechanics" {
    var game_memory = engine.GameAllocator.init();
    defer game_memory.deinit();

    const game_instance = try game.RpsGame.init(&game_memory);
    defer game_instance.deinit();

    // First round should be in progress
    const result = try game_instance.play(.rock);
    try std.testing.expectEqual(result, game.GameResult.in_progress);

    // Test move history
    const history = game_instance.getHistory();
    try std.testing.expectEqual(history.len, 1);
    try std.testing.expectEqual(history[0], game.Choice.rock);

    // Test game continues until win condition
    var final_result = result;
    while (final_result == .in_progress) {
        final_result = try game_instance.play(.rock);
    }

    // Game should eventually end
    try std.testing.expect(final_result != .in_progress);
}

test "rps choice mechanics" {
    try std.testing.expect(game.Choice.rock.beats(.scissors));
    try std.testing.expect(game.Choice.paper.beats(.rock));
    try std.testing.expect(game.Choice.scissors.beats(.paper));
}
