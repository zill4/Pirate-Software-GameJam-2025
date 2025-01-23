const std = @import("std");
const memory = @import("../engine/memory.zig");

pub const Choice = enum {
    rock,
    paper,
    scissors,

    pub fn beats(self: Choice, other: Choice) bool {
        return switch (self) {
            .rock => other == .scissors,
            .paper => other == .rock,
            .scissors => other == .paper,
        };
    }

    pub fn fromInput(input: []const u8) !Choice {
        if (std.mem.eql(u8, input, "r") or std.mem.eql(u8, input, "rock")) return .rock;
        if (std.mem.eql(u8, input, "p") or std.mem.eql(u8, input, "paper")) return .paper;
        if (std.mem.eql(u8, input, "s") or std.mem.eql(u8, input, "scissors")) return .scissors;
        return error.InvalidChoice;
    }
};

pub const GameResult = enum {
    win,
    lose,
    draw,
    in_progress,
    cats_game,
};

pub const RpsGame = struct {
    memory: *memory.GameAllocator,
    moves_history: std.ArrayList(Choice),
    player_wins: u32,
    computer_wins: u32,
    round: u32,
    prng: std.rand.DefaultPrng,

    pub fn init(game_memory: *memory.GameAllocator) !*RpsGame {
        const game = try game_memory.allocator().create(RpsGame);
        game.* = RpsGame{
            .memory = game_memory,
            .moves_history = std.ArrayList(Choice).init(game_memory.allocator()),
            .player_wins = 0,
            .computer_wins = 0,
            .round = 0,
            .prng = std.rand.DefaultPrng.init(@intCast(std.time.timestamp())),
        };
        return game;
    }

    pub fn deinit(self: *RpsGame) void {
        self.moves_history.deinit();
        self.memory.allocator().destroy(self);
    }

    pub fn play(self: *RpsGame, player_choice: Choice) !GameResult {
        self.round += 1;

        // Random computer choice
        const choices = [_]Choice{ .rock, .paper, .scissors };
        const computer_choice = choices[self.prng.random().intRangeAtMost(usize, 0, 2)];

        try self.moves_history.append(player_choice);

        std.debug.print("\nRound {d}:\n", .{self.round});
        std.debug.print("You chose: {s}\n", .{@tagName(player_choice)});
        std.debug.print("Computer chose: {s}\n", .{@tagName(computer_choice)});

        // Determine round winner
        if (player_choice == computer_choice) {
            std.debug.print("It's a draw!\n", .{});
        } else if (player_choice.beats(computer_choice)) {
            self.player_wins += 1;
            std.debug.print("You win this round!\n", .{});
        } else {
            self.computer_wins += 1;
            std.debug.print("Computer wins this round!\n", .{});
        }

        std.debug.print("Score - You: {d}, Computer: {d}\n", .{ self.player_wins, self.computer_wins });

        // Check game state
        if (self.player_wins >= 2) return .win;
        if (self.computer_wins >= 2) return .lose;
        if (self.round >= 10) return .cats_game;
        return .in_progress;
    }

    pub fn getHistory(self: *const RpsGame) []const Choice {
        return self.moves_history.items;
    }
};
