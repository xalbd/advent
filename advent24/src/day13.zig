const std = @import("std");

const data = @embedFile("data/day13.txt");

fn tokens(x_goal: isize, y_goal: isize, a_x: isize, a_y: isize, b_x: isize, b_y: isize) isize {
    // Cramer's Rule
    const a_top = x_goal * b_y - b_x * y_goal;
    const b_top = a_x * y_goal - x_goal * a_y;
    const det = a_x * b_y - b_x * a_y;

    if (@mod(a_top, det) == 0 and @mod(b_top, det) == 0) {
        return 3 * @divFloor(a_top, det) + @divFloor(b_top, det);
    }

    return 0;
}

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    var out1: isize = 0;
    var out2: isize = 0;

    var current: usize = 0;
    var a_x: isize = undefined;
    var a_y: isize = undefined;
    var b_x: isize = undefined;
    var b_y: isize = undefined;
    var x_goal: isize = undefined;
    var y_goal: isize = undefined;

    var input_sections = std.mem.tokenizeScalar(u8, data, '\n');
    while (input_sections.next()) |sec| {
        switch (current) {
            0 => {
                a_x = try std.fmt.parseInt(isize, sec[12..14], 10);
                a_y = try std.fmt.parseInt(isize, sec[18..20], 10);
            },
            1 => {
                b_x = try std.fmt.parseInt(isize, sec[12..14], 10);
                b_y = try std.fmt.parseInt(isize, sec[18..20], 10);
            },
            else => {
                const x_start: usize = std.mem.indexOf(u8, sec, "X=").?;
                const x_end: usize = std.mem.indexOf(u8, sec, ", ").?;
                x_goal = try std.fmt.parseInt(isize, sec[x_start + 2 .. x_end], 10);
                y_goal = try std.fmt.parseInt(isize, sec[x_end + 4 ..], 10);
                out1 += tokens(x_goal, y_goal, a_x, a_y, b_x, b_y);
                out2 += tokens(x_goal + 10000000000000, y_goal + 10000000000000, a_x, a_y, b_x, b_y);
            },
        }

        current = if (current == 2) 0 else current + 1;
    }

    try stdout.print("1: {d}\n", .{out1});
    try stdout.print("2: {d}\n", .{out2});
}
