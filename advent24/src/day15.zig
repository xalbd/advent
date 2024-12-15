const std = @import("std");

const data = @embedFile("data/day15.txt");
const directions: [4][2]isize = .{ .{ -1, 0 }, .{ 0, 1 }, .{ 1, 0 }, .{ 0, -1 } };

fn floodfill(r: isize, c: isize, seen: [][]bool, map: [][]u8, going: usize) void {
    const ur: usize = @intCast(r);
    const uc: usize = @intCast(c);

    if ((map[ur][uc] == '[' or map[ur][uc] == ']') and !seen[ur][uc]) {
        seen[ur][uc] = true;

        for (directions, 0..) |dir, i| {
            if ((going == 0 and (i == 2 or (i == 1 and map[ur][uc] == ']') or (i == 3 and map[ur][uc] == '['))) or
                (going == 2 and (i == 0 or (i == 1 and map[ur][uc] == ']') or (i == 3 and map[ur][uc] == '['))) or
                (going == 1 and i != 1) or
                (going == 3 and i != 3))
            {
                continue;
            }

            floodfill(r + dir[0], c + dir[1], seen, map, going);
        }
    }
}

fn getMove(m: u8) usize {
    return switch (m) {
        ('^') => 0,
        ('v') => 2,
        ('<') => 3,
        ('>') => 1,
        else => 0,
    };
}

fn fill2DWith(comptime T: type, x: [][]T, fill: T) void {
    for (x) |y| {
        @memset(y, @as(T, fill));
    }
}

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocator = arena.allocator();
    defer _ = arena.deinit();

    const split = std.mem.indexOf(u8, data, "\n\n").?;
    const moves = std.mem.indexOfAny(u8, data, "<>^v").?;
    const cols = std.mem.indexOfScalar(u8, data, '\n').?;
    const rows: usize = (split + 1) / (cols + 1);

    var map: [][]u8 = try allocator.alloc([]u8, rows);
    var wide_map: [][]u8 = try allocator.alloc([]u8, rows);

    for (map) |*x| x.* = try allocator.alloc(u8, cols);
    for (wide_map) |*x| x.* = try allocator.alloc(u8, cols * 2);

    // part 1
    var rc: isize = 0;
    var cc: isize = 0;
    var wide_rc: isize = 0;
    var wide_cc: isize = 0;
    for (0..rows) |r| {
        for (0..cols) |c| {
            const tile = data[r * (cols + 1) + c];

            if (tile == '@') {
                map[r][c] = '.';
                rc = @intCast(r);
                cc = @intCast(c);

                wide_map[r][2 * c] = '.';
                wide_map[r][2 * c + 1] = '.';
                wide_rc = rc;
                wide_cc = cc * 2;
            } else {
                map[r][c] = tile;

                if (tile == 'O') {
                    wide_map[r][2 * c] = '[';
                    wide_map[r][2 * c + 1] = ']';
                } else {
                    wide_map[r][2 * c] = tile;
                    wide_map[r][2 * c + 1] = tile;
                }
            }
        }
    }

    for (data[moves..]) |move| {
        if (move == '\n') continue;

        const dir = getMove(move);
        const r_next: isize = rc + directions[dir][0];
        const c_next: isize = cc + directions[dir][1];

        switch (map[@intCast(r_next)][@intCast(c_next)]) {
            '.' => {
                rc = r_next;
                cc = c_next;
            },
            '#' => {
                continue;
            },
            else => {
                var r_check: isize = r_next;
                var c_check: isize = c_next;

                while (r_check >= 0 and r_check < rows and c_check >= 0 and c_check < cols) {
                    switch (map[@intCast(r_check)][@intCast(c_check)]) {
                        '#' => {
                            break;
                        },
                        '.' => {
                            std.mem.swap(u8, &map[@intCast(r_check)][@intCast(c_check)], &map[@intCast(r_next)][@intCast(c_next)]);
                            rc = r_next;
                            cc = c_next;
                            break;
                        },
                        else => {},
                    }

                    r_check = r_check + directions[dir][0];
                    c_check = c_check + directions[dir][1];
                }
            },
        }
    }

    var out1: usize = 0;
    for (0..rows) |r| {
        for (0..cols) |c| {
            if (map[r][c] == 'O') {
                out1 += 100 * r + c;
            }
        }
    }
    try stdout.print("1: {d}\n", .{out1});

    // part 2
    const seen: [][]bool = try allocator.alloc([]bool, rows);
    var replacement: [][]u8 = try allocator.alloc([]u8, rows);

    for (seen) |*x| x.* = try allocator.alloc(bool, cols * 2);
    for (replacement) |*x| x.* = try allocator.alloc(u8, cols * 2);
    for (data[moves..]) |move| {
        if (move == '\n') continue;

        const dir = getMove(move);
        const r_next: isize = wide_rc + directions[dir][0];
        const c_next: isize = wide_cc + directions[dir][1];

        switch (wide_map[@intCast(r_next)][@intCast(c_next)]) {
            '.' => {
                wide_rc = r_next;
                wide_cc = c_next;
            },
            '#' => {
                continue;
            },
            else => {
                var r_check: isize = wide_rc + directions[dir][0];
                var c_check: isize = wide_cc + directions[dir][1];

                fill2DWith(bool, seen, false);
                fill2DWith(u8, replacement, 0);
                floodfill(r_check, c_check, seen, wide_map, dir);

                outer: for (0..rows) |r| {
                    for (0..cols * 2) |c| {
                        const ir: isize = @intCast(r);
                        const ic: isize = @intCast(c);
                        r_check = @intCast(ir - directions[dir][0]);
                        c_check = @intCast(ic - directions[dir][1]);

                        if (r_check >= 0 and r_check < rows and c_check >= 0 and c_check < cols * 2 and
                            seen[@intCast(r_check)][@intCast(c_check)])
                        {
                            if (wide_map[r][c] == '#') {
                                break :outer;
                            }
                            replacement[r][c] = wide_map[@intCast(r_check)][@intCast(c_check)];
                        } else if (seen[r][c]) {
                            replacement[r][c] = '.';
                        } else {
                            replacement[r][c] = wide_map[r][c];
                        }
                    }
                } else {
                    wide_rc = r_next;
                    wide_cc = c_next;

                    for (0..wide_map.len) |i| {
                        @memcpy(wide_map[i], replacement[i]);
                    }
                }
            },
        }
    }

    var out2: usize = 0;
    for (0..rows) |r| {
        for (0..cols * 2) |c| {
            if (wide_map[r][c] == '[') {
                out2 += 100 * r + c;
            }
        }
    }
    try stdout.print("2: {d}\n", .{out2});
}
