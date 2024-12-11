const std = @import("std");

const data = @embedFile("data/day11.txt");

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    var counts = std.AutoHashMap(usize, usize).init(allocator);
    var new_counts = std.AutoHashMap(usize, usize).init(allocator);
    defer {
        counts.deinit();
        new_counts.deinit();
    }

    var sections = std.mem.splitScalar(u8, data, ' ');
    while (sections.next()) |sec| {
        const val = try std.fmt.parseInt(usize, sec, 10);
        try counts.put(val, 1 + (counts.get(val) orelse 0));
    }

    var out1: usize = 0;
    var out2: usize = 0;
    for (1..75 + 1) |iteration| {
        var it = counts.iterator();
        while (it.next()) |entry| {
            const val = entry.key_ptr.*;
            const count = entry.value_ptr.*;
            const len = if (val > 0) std.math.log10_int(val) + 1 else 1;

            if (val == 0) {
                try new_counts.put(1, count + (new_counts.get(1) orelse 0));
            } else if (len % 2 == 0) {
                const section1 = val % std.math.pow(usize, 10, len / 2);
                const section2 = val / std.math.pow(usize, 10, len / 2);
                try new_counts.put(section1, count + (new_counts.get(section1) orelse 0));
                try new_counts.put(section2, count + (new_counts.get(section2) orelse 0));
            } else {
                try new_counts.put(val * 2024, count + (new_counts.get(val * 2024) orelse 0));
            }
        }

        counts.deinit();
        counts = try new_counts.clone();
        new_counts.clearAndFree();

        if (iteration == 25 or iteration == 75) {
            var values = counts.valueIterator();
            while (values.next()) |count| {
                (if (iteration == 25) out1 else out2) += count.*;
            }
        }
    }
    try stdout.print("1: {d}\n", .{out1});
    try stdout.print("2: {d}\n", .{out2});
}
