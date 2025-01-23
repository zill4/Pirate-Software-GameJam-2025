const std = @import("std");

// Build mode configuration
const BuildMode = enum {
    debug,
    release_safe,
    release_fast,
    release_small,
};

// Build features configuration
const BuildFeatures = struct { enable_logging: bool = true, enable_profiling: bool = false };

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Create build features options
    const features = BuildFeatures{ .enable_logging = b.option(
        bool,
        "logging",
        "Enable debug logging (default: true)",
    ) orelse true, .enable_profiling = b.option(
        bool,
        "profile",
        "Enable performance profiling (default: false)",
    ) orelse false };

    // Create build options
    const build_options = b.addOptions();
    build_options.addOption(bool, "enable_logging", features.enable_logging);
    build_options.addOption(bool, "enable_profiling", features.enable_profiling);
    build_options.addOption(bool, "dx12_enabled", true);

    //
    // 1. Engine Module Setup
    //
    const engine_module = b.addModule("engine", .{
        .root_source_file = .{ .src_path = .{ .owner = b, .sub_path = "src/engine/module.zig" } },
    });

    //
    // 2. Dependent Modules Setup
    //
    const blockchain_module = b.addModule("blockchain", .{
        .root_source_file = .{ .src_path = .{ .owner = b, .sub_path = "src/blockchain/block.zig" } },
    });
    blockchain_module.addImport("engine", engine_module);

    const game_module = b.addModule("game", .{
        .root_source_file = .{ .src_path = .{ .owner = b, .sub_path = "src/game/rps.zig" } },
    });
    game_module.addImport("engine", engine_module);

    // Engine tests
    const engine_tests = b.addTest(.{
        .root_source_file = .{ .src_path = .{ .owner = b, .sub_path = "src/engine/tests.zig" } },
        .target = target,
        .optimize = optimize,
    });
    engine_tests.root_module.addImport("engine", engine_module);
    engine_tests.root_module.addOptions("build_options", build_options);
    const run_engine_tests = b.addRunArtifact(engine_tests);

    // Dependent module tests
    const blockchain_tests = b.addTest(.{
        .root_source_file = .{ .src_path = .{ .owner = b, .sub_path = "src/blockchain/tests.zig" } },
        .target = target,
        .optimize = optimize,
    });
    blockchain_tests.root_module.addImport("engine", engine_module);
    blockchain_tests.root_module.addImport("blockchain", blockchain_module);
    blockchain_tests.root_module.addOptions("build_options", build_options);
    const run_blockchain_tests = b.addRunArtifact(blockchain_tests);

    const game_tests = b.addTest(.{
        .root_source_file = .{ .src_path = .{ .owner = b, .sub_path = "src/game/tests.zig" } },
        .target = target,
        .optimize = optimize,
    });
    game_tests.root_module.addImport("engine", engine_module);
    game_tests.root_module.addImport("game", game_module);
    game_tests.root_module.addOptions("build_options", build_options);
    const run_game_tests = b.addRunArtifact(game_tests);

    // Main executable
    const exe = b.addExecutable(.{
        .name = "z-mmo",
        .root_source_file = .{ .src_path = .{ .owner = b, .sub_path = "src/main.zig" } },
        .target = target,
        .optimize = optimize,
    });
    exe.root_module.addImport("engine", engine_module);
    exe.root_module.addImport("blockchain", blockchain_module);
    exe.root_module.addImport("game", game_module);
    exe.root_module.addOptions("build_options", build_options);

    // Test step setup
    const test_step = b.step("test", "Run all tests");
    test_step.dependOn(&run_engine_tests.step);
    test_step.dependOn(&run_blockchain_tests.step);
    test_step.dependOn(&run_game_tests.step);

    b.installArtifact(exe);

    // Run step setup
    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    const run_step = b.step("run", "Run the application");
    run_step.dependOn(&run_cmd.step);

    // Benchmark tests (only in release mode)
    if (optimize != .Debug) {
        const bench_tests = b.addTest(.{
            .root_source_file = .{ .src_path = .{ .owner = b, .sub_path = "src/tests/benchmarks.zig" } },
            .target = target,
            .optimize = .ReleaseFast,
        });
        bench_tests.root_module.addOptions("build_options", build_options);

        const run_bench_tests = b.addRunArtifact(bench_tests);
        const bench_step = b.step("bench", "Run benchmarks");
        bench_step.dependOn(&run_bench_tests.step);
    }
}
