const std = @import("std");

const data = @embedFile("data/day06.txt");

const cols: usize = std.mem.indexOfScalar(u8, data, '\n').?;
const rows: usize = (data.len + 1) / (cols + 1);
const directions: [4][2]i32 = .{ .{ -1, 0 }, .{ 0, 1 }, .{ 1, 0 }, .{ 0, -1 } };

fn exit(map: [][rows]u8, r_start: usize, c_start: usize) ?u32 {
    var seen: [rows][cols][4]bool = std.mem.zeroes([rows][cols][4]bool);
    var dir: usize = 0;

    var out: u32 = 0;
    var r: i32 = @intCast(r_start);
    var c: i32 = @intCast(c_start);

    while (r >= 0 and r < rows and c >= 0 and c < cols) {
        const rn: usize = @intCast(r);
        const cn: usize = @intCast(c);

        if (seen[rn][cn][dir]) {
            return null;
        } else if (map[rn][cn] == '.' and !seen[rn][cn][0] and !seen[rn][cn][1] and !seen[rn][cn][2] and !seen[rn][cn][3]) {
            out += 1;
        }

        seen[rn][cn][dir] = true;
        const nextr = r + directions[dir][0];
        const nextc = c + directions[dir][1];

        if (nextr >= 0 and nextr < rows and nextc >= 0 and nextc < cols and map[@intCast(nextr)][@intCast(nextc)] == '#') {
            dir = if (dir == 3) 0 else dir + 1;
        } else {
            r += directions[dir][0];
            c += directions[dir][1];
        }
    }

    return out;
}

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    // part 1
    var map: [rows][cols]u8 = std.mem.zeroes([rows][cols]u8);
    var r_start: usize = 0;
    var c_start: usize = 0;
    for (0..rows) |r| {
        for (0..cols) |c| {
            const ch = data[r * (cols + 1) + c];
            switch (ch) {
                '\n' => {},
                '^' => {
                    r_start = r;
                    c_start = c;
                    map[r][c] = '.';
                },
                else => map[r][c] = ch,
            }
        }
    }

    const out1 = exit(&map, r_start, c_start).?;
    try stdout.print("1: {d}\n", .{out1});

    // part 2
    var out2: u32 = 0;
    for (0..rows) |sr| {
        for (0..cols) |sc| {
            if (map[sr][sc] == '#') continue;

            map[sr][sc] = '#';
            if (exit(&map, r_start, c_start) == null) {
                out2 += 1;
            }
            map[sr][sc] = '.';
        }
    }
    try stdout.print("2: {d}\n", .{out2});
}
