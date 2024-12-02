const std = @import("std");

const data = @embedFile("data/day01.txt");

pub fn main() !void {
    // get output writer
    const stdout = std.io.getStdOut().writer();

    // allocator for heap
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    var left = std.ArrayList(i32).init(allocator);
    var right = std.ArrayList(i32).init(allocator);
    defer {
        left.deinit();
        right.deinit();
    }
    var isLeft: bool = true;

    // parse input and store in ArrayList
    var iter = std.mem.tokenizeAny(u8, data, " \n");
    while (iter.next()) |x| : ({
        isLeft = !isLeft;
    }) {
        const val = try std.fmt.parseInt(i32, x, 10);
        if (isLeft) try left.append(val) else try right.append(val);
    }

    // part 1
    std.mem.sort(i32, left.items, {}, std.sort.asc(i32));
    std.mem.sort(i32, right.items, {}, std.sort.asc(i32));

    var total1: u32 = 0;
    for (left.items, right.items) |l, r| {
        total1 += @abs(l - r);
    }
    try stdout.print("1: {d}\n", .{total1});

    // part 2
    var freq = std.AutoHashMap(i32, i32).init(allocator);
    defer freq.deinit();
    for (right.items) |x| {
        try freq.put(x, 1 + (freq.get(x) orelse 0));
    }

    var total2: i32 = 0;
    for (left.items) |x| {
        total2 += x * (freq.get(x) orelse 0);
    }
    try stdout.print("2: {d}\n", .{total2});
}
