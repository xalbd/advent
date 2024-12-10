const std = @import("std");

const data = @embedFile("data/day08.txt");

const cols: usize = std.mem.indexOfScalar(u8, data, '\n').?;
const rows: usize = (data.len + 1) / (cols + 1);

fn inBounds(r: i32, c: i32) bool {
    return r >= 0 and r < rows and c >= 0 and c < cols;
}

fn isValid(r: i32, c: i32, delta_r: i32, delta_c: i32, count: i32, seen: [][cols]bool) bool {
    const nr = r + delta_r * count;
    const nc = c + delta_c * count;

    if (inBounds(nr, nc) and !seen[@intCast(nr)][@intCast(nc)]) {
        seen[@intCast(nr)][@intCast(nc)] = true;
        return true;
    }
    return false;
}

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    var has_antinode1: [rows][cols]bool = std.mem.zeroes([rows][cols]bool);
    var has_antinode2: [rows][cols]bool = std.mem.zeroes([rows][cols]bool);

    var out1: usize = 0;
    var out2: usize = 0;
    for (0..rows) |r| {
        for (0..cols) |c| {
            for (0..rows) |r1| {
                for (0..cols) |c1| {
                    if (r1 == r and c1 == c) continue;
                    if (data[r * (cols + 1) + c] == '.') continue;

                    if (data[r * (cols + 1) + c] == data[r1 * (cols + 1) + c1]) {
                        const ir: i32 = @intCast(r);
                        const ic: i32 = @intCast(c);
                        const ir1: i32 = @intCast(r1);
                        const ic1: i32 = @intCast(c1);
                        const delta_r: i32 = ir1 - ir;
                        const delta_c: i32 = ic1 - ic;

                        out1 += if (isValid(ir1, ic1, delta_r, delta_c, 1, &has_antinode1)) 1 else 0;

                        for (0..@max(cols, rows)) |skip| {
                            out2 += if (isValid(ir1, ic1, delta_r, delta_c, @intCast(skip), &has_antinode2)) 1 else 0;
                        }
                    }
                }
            }
        }
    }

    try stdout.print("1: {d}\n", .{out1});
    try stdout.print("2: {d}\n", .{out2});
}
