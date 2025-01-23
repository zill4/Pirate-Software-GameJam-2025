const std = @import("std");
const memory = @import("memory.zig");

pub const LogLevel = enum {
    debug,
    info,
    warning,
    err,

    pub fn toString(self: LogLevel) []const u8 {
        return switch (self) {
            .debug => "DEBUG",
            .info => "INFO",
            .warning => "WARNING",
            .err => "ERROR",
        };
    }
};

pub const LogEntry = struct {
    timestamp: i64,
    level: LogLevel,
    message: []const u8,
    module: []const u8,

    pub fn init(level: LogLevel, message: []const u8, module: []const u8) LogEntry {
        return .{
            .timestamp = std.time.timestamp(),
            .level = level,
            .message = message,
            .module = module,
        };
    }
};

pub const Logger = struct {
    allocator: std.mem.Allocator,
    entries: std.ArrayList(LogEntry),
    min_level: LogLevel,

    pub fn init(allocator: std.mem.Allocator, min_level: LogLevel) Logger {
        return .{
            .allocator = allocator,
            .entries = std.ArrayList(LogEntry).init(allocator),
            .min_level = min_level,
        };
    }

    pub fn deinit(self: *Logger) void {
        self.entries.deinit();
    }

    pub fn log(self: *Logger, level: LogLevel, message: []const u8, module: []const u8) !void {
        if (@intFromEnum(level) < @intFromEnum(self.min_level)) return;

        const entry = LogEntry.init(level, message, module);
        try self.entries.append(entry);

        // Print to console
        std.debug.print("[{s}] {s}: {s}\n", .{
            level.toString(),
            module,
            message,
        });
    }

    pub fn debug(self: *Logger, message: []const u8, module: []const u8) !void {
        try self.log(.debug, message, module);
    }

    pub fn info(self: *Logger, message: []const u8, module: []const u8) !void {
        try self.log(.info, message, module);
    }

    pub fn warning(self: *Logger, message: []const u8, module: []const u8) !void {
        try self.log(.warning, message, module);
    }

    pub fn err(self: *Logger, message: []const u8, module: []const u8) !void {
        try self.log(.err, message, module);
    }
};
