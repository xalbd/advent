const std = @import("std");

const data = @embedFile("data/day09.txt");

const Block = struct {
    id: isize,
    len: isize,
};

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    // part 1
    var sim = std.ArrayList(isize).init(allocator);
    defer sim.deinit();

    var blocks = std.ArrayList(Block).init(allocator);
    defer blocks.deinit();

    var block_index: isize = 0;
    var isFile: bool = true;
    for (data) |block| {
        const len: usize = block - '0';
        for (0..len) |_| {
            try sim.append(if (isFile) block_index else -1);
        }

        try blocks.append(.{ .id = if (isFile) block_index else -1, .len = @intCast(len) });

        if (isFile) block_index += 1;
        isFile = !isFile;
    }

    var l: usize = 0;
    var r: usize = sim.items.len - 1;
    while (l < r) {
        if (sim.items[r] == -1) {
            r -= 1;
        } else if (sim.items[l] == -1) {
            std.mem.swap(isize, &sim.items[l], &sim.items[r]);
            l += 1;
            r -= 1;
        } else {
            l += 1;
        }
    }

    var out1: isize = 0;
    for (sim.items, 0..) |id, idx| {
        if (id == -1) break;

        const iidx: isize = @intCast(idx);
        out1 += id * iidx;
    }
    try stdout.print("1: {d}\n", .{out1});

    // part 2
    var cur: usize = blocks.items.len - 1;
    while (cur > 0) : (cur -= 1) {
        if (blocks.items[cur].id == -1) continue;

        var candidate: usize = 0;
        while (candidate < cur) : (candidate += 1) {
            if (blocks.items[candidate].id == -1 and blocks.items[candidate].len >= blocks.items[cur].len) {
                const modified_space: Block = .{ .id = -1, .len = blocks.items[candidate].len - blocks.items[cur].len };

                blocks.items[candidate] = blocks.items[cur];
                blocks.items[cur].id = -1;
                try blocks.insert(candidate + 1, modified_space);

                cur += 1;
                break;
            }
        }
    }

    var out2: isize = 0;
    var loc: isize = 0;
    for (blocks.items) |block| {
        if (block.id != -1) {
            out2 += block.id * @divFloor(block.len * (loc + loc + block.len - 1), 2);
        }

        loc += block.len;
    }

    try stdout.print("2: {d}\n", .{out2});
}
