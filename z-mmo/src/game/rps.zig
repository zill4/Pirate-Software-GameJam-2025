const std = @import("std");
const engine = @import("engine");
const Logger = engine.Logger;
const GameAllocator = engine.GameAllocator;

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
    memory: *GameAllocator,
    moves_history: std.ArrayList(Choice),
    player_wins: u32,
    computer_wins: u32,
    round: u32,
    prng: std.rand.DefaultPrng,

    pub fn init(game_memory: *GameAllocator) !*RpsGame {
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

pub fn startGame(game: *RpsGame, logger: *Logger) !void {
    try logger.info("Welcome to Rock Paper Scissors!", "RPS");
    try logger.info("First to win 2 rounds wins the game (max 10 rounds)", "RPS");
    try logger.info("Enter 'r' for rock, 'p' for paper, or 's' for scissors", "RPS");

    var buffer: [100]u8 = undefined;
    var result = GameResult.in_progress;

    while (result == .in_progress) {
        try logger.info("Make your choice (r/p/s): ", "RPS");

        const user_input = try std.io.getStdIn().reader().readUntilDelimiter(&buffer, '\n');
        const trimmed_input = std.mem.trim(u8, user_input, &std.ascii.whitespace);

        const choice = Choice.fromInput(trimmed_input) catch {
            try logger.warning("Invalid input! Please enter 'r', 'p', or 's'", "RPS");
            continue;
        };

        result = try game.play(choice);
    }

    // Game over - display final result
    switch (result) {
        .win => try logger.info("Congratulations! You won the game!", "RPS"),
        .lose => try logger.info("Game Over! Computer wins!", "RPS"),
        .cats_game => try logger.info("Cat's game! No winner after 10 rounds.", "RPS"),
        else => unreachable,
    }

    try logger.info("\nGame History:", "RPS");
    for (game.getHistory(), 0..) |move, i| {
        const message = try std.fmt.allocPrint(game.memory.allocator(), "Round {d}: {s}", .{ i + 1, @tagName(move) });
        defer game.memory.allocator().free(message);
        try logger.info(message, "RPS");
    }
}
