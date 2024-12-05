const std = @import("std");

const data = @embedFile("data/$.txt");

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    // part 1
    try stdout.print("1: {d}\n", .{1});

    // part 2
    try stdout.print("2: {d}\n", .{2});
}
