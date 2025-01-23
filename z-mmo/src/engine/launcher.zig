const std = @import("std");
const memory = @import("memory.zig");
const logger = @import("logger.zig");
const Logger = logger.Logger;

pub const GameType = enum {
    rps,
    // Future games will be added here

    pub fn fromString(str: []const u8) !GameType {
        if (std.mem.eql(u8, str, "rps")) return .rps;
        return error.UnknownGame;
    }
};

pub const GameLauncher = struct {
    memory: *memory.GameAllocator,
    logger: *logger.Logger,

    pub fn init(game_memory: *memory.GameAllocator, game_logger: *logger.Logger) GameLauncher {
        return .{
            .memory = game_memory,
            .logger = game_logger,
        };
    }

    pub fn launchGame(self: *GameLauncher, game_type: GameType) !void {
        try self.logger.info("Launching game...", @tagName(game_type));

        switch (game_type) {
            .rps => {
                try self.logger.info("Starting Rock Paper Scissors", "RPS");
                // Instead of directly launching the game here, we'll return and let main.zig handle it
                // This breaks the circular dependency
            },
        }
    }
};
