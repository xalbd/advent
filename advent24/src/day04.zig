const std = @import("std");

const data = @embedFile("data/day04.txt");

const cols: usize = std.mem.indexOfScalar(u8, data, '\n').?;
const rows: usize = (data.len + 1) / (cols + 1);
const diffs: [3]i32 = .{ -1, 0, 1 };

fn getChar(r: isize, c: isize) u8 {
    const ru: usize = @intCast(r);
    const cu: usize = @intCast(c);

    return data[ru * (cols + 1) + cu];
}

fn inBounds(r: isize, c: isize) bool {
    return r >= 0 and r < rows and c >= 0 and c < cols;
}

fn xmasAt(r: isize, c: isize) u32 {
    var out: u32 = 0;
    for (diffs) |rd| {
        for (diffs) |cd| {
            var cr = r;
            var cc = c;

            for ("XMAS") |ch| {
                if (!inBounds(cr, cc) or getChar(cr, cc) != ch) break;

                cr += rd;
                cc += cd;
            } else {
                out += 1;
            }
        }
    }

    return out;
}

fn inBoundsOffset(r: isize, c: isize) bool {
    return r >= 1 and r < rows - 1 and c >= 1 and c < cols - 1;
}

fn x_masAt(r: isize, c: isize) u32 {
    if (!inBoundsOffset(r, c) or getChar(r, c) != 'A') return 0;

    const chs: [4]u8 = .{ getChar(r - 1, c - 1), getChar(r + 1, c + 1), getChar(r - 1, c + 1), getChar(r + 1, c - 1) };
    return if (std.mem.indexOf(u8, "MSMS SMSM MSSM SMMS", &chs) != null) 1 else 0;
}

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    var out1: u32 = 0;
    var out2: u32 = 0;
    for (0..rows) |r| {
        for (0..cols) |c| {
            out1 += xmasAt(@intCast(r), @intCast(c));
            out2 += x_masAt(@intCast(r), @intCast(c));
        }
    }

    try stdout.print("1: {d}\n", .{out1});
    try stdout.print("2: {d}\n", .{out2});
}
