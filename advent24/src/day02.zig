const std = @import("std");

const data = @embedFile("data/day02.txt");

fn check(values: []i32, remove: usize) bool {
    var prev: ?i32 = null;
    var increasing: ?bool = null;

    return for (values, 0..) |level, index| {
        if (index == remove) continue;
        if (prev != null) {
            if (increasing == null) {
                increasing = level > prev.?;
            }

            const diff = @abs(level - prev.?);
            if (diff < 1 or diff > 3 or (increasing.? and level <= prev.?) or (!increasing.? and level >= prev.?)) {
                break false;
            }
        }
        prev = level;
    } else true;
}

pub fn main() !void {
    // get output writer
    const stdout = std.io.getStdOut().writer();

    // allocator for heap
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    var safe1: i32 = 0;
    var safe2: i32 = 0;
    var lines = std.mem.splitScalar(u8, data, '\n');
    while (lines.next()) |line| {
        var list = std.ArrayList(i32).init(allocator);
        defer list.deinit();

        var values = std.mem.splitScalar(u8, line, ' ');
        while (values.next()) |val| {
            const level = try std.fmt.parseInt(i32, val, 10);
            try list.append(level);
        }

        if (check(list.items, list.items.len + 1)) {
            safe1 += 1;
            safe2 += 1;
        } else {
            for (0..list.items.len) |remove| {
                if (check(list.items, remove)) {
                    safe2 += 1;
                    break;
                }
            }
        }
    }
    try stdout.print("1: {d}\n", .{safe1});
    try stdout.print("2: {d}\n", .{safe2});
}
