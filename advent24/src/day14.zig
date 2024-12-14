const std = @import("std");

const data = @embedFile("data/day14.txt");
const x_max: isize = 101;
const y_max: isize = 103;
const x_mid: isize = @divFloor(x_max, 2);
const y_mid: isize = @divFloor(y_max, 2);

const Robot = struct { x: isize, y: isize, x_speed: isize, y_speed: isize };

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    // part 1
    var quadrants: [4]usize = std.mem.zeroes([4]usize);
    var counts: [x_max][y_max]usize = std.mem.zeroes([x_max][y_max]usize);

    var robots = std.ArrayList(Robot).init(allocator);
    defer robots.deinit();

    var input_sections = std.mem.splitScalar(u8, data, '\n');
    while (input_sections.next()) |sec| {
        var numbers = std.mem.tokenizeAny(u8, sec, "p=, v");
        const x_start: isize = try std.fmt.parseInt(isize, numbers.next().?, 10);
        const y_start: isize = try std.fmt.parseInt(isize, numbers.next().?, 10);
        const x_speed: isize = try std.fmt.parseInt(isize, numbers.next().?, 10);
        const y_speed: isize = try std.fmt.parseInt(isize, numbers.next().?, 10);

        try robots.append(.{ .x = x_start, .y = y_start, .x_speed = x_speed, .y_speed = y_speed });
        counts[@intCast(x_start)][@intCast(y_start)] += 1;

        const x_final: isize = @mod(x_start + 100 * x_speed, x_max);
        const y_final: isize = @mod(y_start + 100 * y_speed, y_max);

        var index: usize = 0;
        if (x_final == x_mid or y_final == y_mid) continue;
        if (x_final > x_mid) index += 1;
        if (y_final > y_mid) index += 2;
        quadrants[index] += 1;
    }

    const out1: usize = quadrants[0] * quadrants[1] * quadrants[2] * quadrants[3];
    try stdout.print("1: {d}\n", .{out1});

    // part 2
    const print: bool = true;
    var elapsed: usize = 0;
    outer: while (true) {
        elapsed += 1;
        for (0..robots.items.len) |i| {
            var robot: *Robot = &robots.items[i];
            counts[@intCast(robot.x)][@intCast(robot.y)] -= 1;
            robot.x = @mod(robot.x + robot.x_speed, x_max);
            robot.y = @mod(robot.y + robot.y_speed, y_max);
            counts[@intCast(robot.x)][@intCast(robot.y)] += 1;
        }

        for (0..x_max) |x| {
            for (0..y_max) |y| {
                if (counts[x][y] > 1) {
                    continue :outer;
                }
            }
        }

        if (print) {
            try stdout.print("\n{d}\n", .{elapsed});
            for (0..y_max) |y| {
                for (0..x_max) |x| {
                    const out: u8 = if (counts[x][y] == 1) '0' else '.';
                    try stdout.print("{c}", .{out});
                }
                try stdout.print("\n", .{});
            }
            try stdout.print("\n", .{});
        }

        if (elapsed > 6911) {
            break;
        }
    }

    const out2: usize = elapsed;
    try stdout.print("2: {d}\n", .{out2});
}
