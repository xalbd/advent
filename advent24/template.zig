const std = @import("std");

const data = @embedFile("data/$.txt");

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocator = arena.allocator();
    defer _ = arena.deinit();

    // part 1
    const out1: usize = 0;
    try stdout.print("1: {d}\n", .{out1});

    // part 2
    const out2: usize = 0;
    try stdout.print("2: {d}\n", .{out2});
}
