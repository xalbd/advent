const std = @import("std");

const data = @embedFile("data/day02.txt");

pub fn main() !void {
    // get output writer
    const stdout = std.io.getStdOut().writer();

    // allocator for heap
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    // part 1
    var safe: i32 = 0;
    var lines = std.mem.splitScalar(u8, data, '\n');
    while (lines.next()) |line| {
        var prev: ?i32 = null;
        var increasing: ?bool = null;
        var isSafe = true;

        var values = std.mem.splitScalar(u8, line, ' ');
        while (values.next()) |val| {
            const level = try std.fmt.parseInt(i32, val, 10);
            if (prev != null) {
                if (increasing == null) {
                    increasing = level > prev.?;
                }

                const diff = @abs(level - prev.?);
                if (diff < 1 or diff > 3 or (increasing.? and level <= prev.?) or (!increasing.? and level >= prev.?)) {
                    isSafe = false;
                    break;
                }
            }
            prev = level;
        }

        if (isSafe) safe += 1;
    }
    try stdout.print("1: {d}\n", .{safe});

    // part 2
    safe = 0;
    lines = std.mem.splitScalar(u8, data, '\n');
    while (lines.next()) |line| {
        var list = std.ArrayList(i32).init(allocator);
        defer list.deinit();

        // put values into ArrayList
        var values = std.mem.splitScalar(u8, line, ' ');
        while (values.next()) |val| {
            const level = try std.fmt.parseInt(i32, val, 10);
            try list.append(level);
        }

        // try removing each element and no element
        for (0..list.items.len + 1) |remove| {
            var prev: ?i32 = null;
            var increasing: ?bool = null;
            var isSafe = true;

            for (list.items, 0..) |level, index| {
                if (index == remove) continue;
                if (prev != null) {
                    if (increasing == null) {
                        increasing = level > prev.?;
                    }

                    const diff = @abs(level - prev.?);
                    if (diff < 1 or diff > 3 or (increasing.? and level <= prev.?) or (!increasing.? and level >= prev.?)) {
                        isSafe = false;
                        break;
                    }
                }
                prev = level;
            }

            if (isSafe) {
                safe += 1;
                break;
            }
        }
    }
    try stdout.print("2: {d}\n", .{safe});
}
