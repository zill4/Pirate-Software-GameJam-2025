const std = @import("std");
const build_options = @import("build_options");
const rps = @import("game/rps.zig");
const memory = @import("engine/memory.zig");

pub fn main() !void {
    if (build_options.enable_logging) {
        std.debug.print("Logging enabled\n", .{});
    }

    if (build_options.enable_profiling) {
        std.debug.print("Profiling enabled\n", .{});
    }

    std.debug.print("MMO Engine Starting...\n", .{});

    // Initialize game memory
    var game_memory = memory.GameAllocator.init();
    defer game_memory.deinit();

    // Create RPS game
    const game = try rps.RpsGame.init(&game_memory);
    defer game.deinit();

    std.debug.print("\nWelcome to Rock Paper Scissors!\n", .{});
    std.debug.print("First to win 2 rounds wins the game (max 10 rounds)\n", .{});
    std.debug.print("Enter 'r' for rock, 'p' for paper, or 's' for scissors\n", .{});

    var result: rps.GameResult = .in_progress;
    var buffer: [10]u8 = undefined;

    while (result == .in_progress) {
        std.debug.print("\nMake your choice (r/p/s): ", .{});

        const user_input = try std.io.getStdIn().reader().readUntilDelimiter(&buffer, '\n');
        const trimmed_input = std.mem.trim(u8, user_input, &std.ascii.whitespace);

        const choice = rps.Choice.fromInput(trimmed_input) catch {
            std.debug.print("Invalid input! Please enter 'r', 'p', or 's'\n", .{});
            continue;
        };

        result = try game.play(choice);
    }

    // Game over - display final result
    switch (result) {
        .win => std.debug.print("\nCongratulations! You won the game!\n", .{}),
        .lose => std.debug.print("\nGame Over! Computer wins!\n", .{}),
        .cats_game => std.debug.print("\nCat's game! No winner after 10 rounds.\n", .{}),
        else => unreachable,
    }

    std.debug.print("\nGame History:\n", .{});
    for (game.getHistory(), 0..) |move, i| {
        std.debug.print("Round {d}: {s}\n", .{ i + 1, @tagName(move) });
    }
}

test "basic test" {
    try std.testing.expectEqual(true, true);
}
