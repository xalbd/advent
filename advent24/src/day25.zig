const std = @import("std");

const data = @embedFile("data/day25.txt");

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocator = arena.allocator();
    defer _ = arena.deinit();

    // part 1
    var keys = std.ArrayList([5]usize).init(allocator);
    var locks = std.ArrayList([5]usize).init(allocator);
    var sections = std.mem.split(u8, data, "\n\n");
    while (sections.next()) |section| {
        var cur: [5]usize = std.mem.zeroes([5]usize);

        var rows = std.mem.splitScalar(u8, section, '\n');
        while (rows.next()) |row| {
            for (row, 0..) |v, j| {
                cur[j] += @intFromBool(v == '#');
            }
        }

        if (section[0] == '.') {
            try keys.append(cur);
        } else {
            try locks.append(cur);
        }
    }

    var out1: usize = 0;
    for (keys.items) |k| {
        for (locks.items) |l| {
            for (0..5) |i| {
                if (k[i] + l[i] > 7) break;
            } else {
                out1 += 1;
            }
        }
    }
    try stdout.print("1: {d}\n", .{out1});
}
