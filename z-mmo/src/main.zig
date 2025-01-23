const std = @import("std");
const engine = @import("engine");
const rps = @import("game/rps.zig");
const blockchain = @import("blockchain");

pub fn main() !void {
    // Initialize game memory
    var game_memory = engine.GameAllocator.init();
    defer game_memory.deinit();

    // Initialize logger
    var game_logger = engine.Logger.init(game_memory.allocator(), .info);
    defer game_logger.deinit();

    // Initialize game launcher
    var launcher = engine.GameLauncher.init(&game_memory, &game_logger);

    // Start the game
    try launcher.launchGame(.rps);

    // Create and start the RPS game
    const game = try rps.RpsGame.init(&game_memory);
    defer game.deinit();
    try rps.startGame(game, &game_logger);
}

test "basic test" {
    try std.testing.expectEqual(true, true);
}
