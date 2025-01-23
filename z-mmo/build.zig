const std = @import("std");

// Build mode configuration
const BuildMode = enum {
    debug,
    release_safe,
    release_fast,
    release_small,
};

// Build features configuration
const BuildFeatures = struct {
    enable_logging: bool = true,
    enable_profiling: bool = false,
    enable_vulkan_validation: bool = false,
};

pub fn build(b: *std.Build) void {
    // Standard target options
    const target = b.standardTargetOptions(.{});

    // Get optimization choice from CLI or default to debug
    const optimize = b.standardOptimizeOption(.{});

    // Create build features options
    const features = BuildFeatures{
        .enable_logging = b.option(
            bool,
            "logging",
            "Enable debug logging (default: true)",
        ) orelse true,
        .enable_profiling = b.option(
            bool,
            "profile",
            "Enable performance profiling (default: false)",
        ) orelse false,
        .enable_vulkan_validation = b.option(
            bool,
            "vulkan-validation",
            "Enable Vulkan validation layers (default: false)",
        ) orelse false,
    };

    // Create build options module
    const build_options = b.addOptions();
    build_options.addOption(bool, "enable_logging", features.enable_logging);
    build_options.addOption(bool, "enable_profiling", features.enable_profiling);
    build_options.addOption(bool, "enable_vulkan_validation", features.enable_vulkan_validation);
    build_options.addOption(bool, "dx12_enabled", true);

    // Main executable
    const exe = b.addExecutable(.{
        .name = "z-mmo",
        .root_source_file = .{ .src_path = .{
            .owner = b,
            .sub_path = "src/main.zig",
        } },
        .target = target,
        .optimize = optimize,
    });

    // Add the options as a module
    exe.root_module.addOptions("build_options", build_options);

    // Install the executable in the prefix
    b.installArtifact(exe);

    // Create run step
    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    const run_step = b.step("run", "Run the application");
    run_step.dependOn(&run_cmd.step);

    // Unit tests
    const unit_tests = b.addTest(.{
        .root_source_file = .{ .src_path = .{ .owner = b, .sub_path = "src/main.zig" } },
        .target = target,
        .optimize = optimize,
    });
    unit_tests.root_module.addOptions("build_options", build_options);

    const run_unit_tests = b.addRunArtifact(unit_tests);
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_unit_tests.step);

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
