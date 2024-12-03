const std = @import("std");

const data = @embedFile("data/day03.txt");

fn getTotal(s: []const u8) i32 {
    var total: i32 = 0;
    var sections = std.mem.splitSequence(u8, s, "mul(");
    while (sections.next()) |section| {
        const next_comma = std.mem.indexOfScalar(u8, section, ',');
        const next_rparen = std.mem.indexOfScalar(u8, section, ')');

        if (next_comma) |c| {
            if (next_rparen) |p| {
                if (c > 0 and c < 4 and p - c > 1 and p - c < 5) {
                    total += (std.fmt.parseInt(i32, section[0..c], 10) catch 0) *
                        (std.fmt.parseInt(i32, section[c + 1 .. p], 10) catch 0);
                }
            }
        }
    }
    return total;
}

pub fn main() !void {
    // get output writer
    const stdout = std.io.getStdOut().writer();

    // part 1
    const total1 = getTotal(data);
    try stdout.print("1: {d}\n", .{total1});

    // part 2
    var total2: i32 = 0;
    var do = std.mem.splitSequence(u8, data, "do()");
    while (do.next()) |do_sec| {
        const stop = std.mem.indexOf(u8, do_sec, "don't()") orelse do_sec.len;
        total2 += getTotal(do_sec[0..stop]);
    }
    try stdout.print("2: {d}\n", .{total2});
}
