const std = @import("std");

const data = @embedFile("data/day10.txt");

const cols: usize = std.mem.indexOfScalar(u8, data, '\n').?;
const rows: usize = (data.len + 1) / (cols + 1);

fn inBounds(r: i32, c: i32) bool {
    return r >= 0 and r < rows and c >= 0 and c < cols;
}

fn getValue(r: usize, c: usize) usize {
    return data[r * (cols + 1) + c] - '0';
}

fn floodfill(r: i32, c: i32, seen: [][cols]bool, target: usize, paths: bool) usize {
    if (!inBounds(r, c)) return 0;

    const ir: usize = @intCast(r);
    const ic: usize = @intCast(c);

    if (getValue(ir, ic) == target and (!seen[ir][ic] or paths)) {
        seen[ir][ic] = true;

        if (target == 9) {
            return 1;
        } else {
            return floodfill(r + 1, c, seen, target + 1, paths) +
                floodfill(r - 1, c, seen, target + 1, paths) +
                floodfill(r, c + 1, seen, target + 1, paths) +
                floodfill(r, c - 1, seen, target + 1, paths);
        }
    }

    return 0;
}

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    var out1: usize = 0;
    var out2: usize = 0;

    var seen: [rows][cols]bool = std.mem.zeroes([rows][cols]bool);
    for (0..rows) |r| {
        for (0..cols) |c| {
            seen = std.mem.zeroes([rows][cols]bool);
            out1 += floodfill(@intCast(r), @intCast(c), &seen, 0, false);
            out2 += floodfill(@intCast(r), @intCast(c), &seen, 0, true);
        }
    }
    try stdout.print("1: {d}\n", .{out1});
    try stdout.print("2: {d}\n", .{out2});
}
