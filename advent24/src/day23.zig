const std = @import("std");

const data = @embedFile("data/day23.txt");

const t: usize = 't' - 'a';
const a: usize = 'a';
const N: usize = 26 * 26;

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocator = arena.allocator();
    defer _ = arena.deinit();

    var connections: [N][N]bool = std.mem.zeroes([N][N]bool);
    for (0..N) |i| {
        connections[i][i] = true;
    }

    var sections = std.mem.splitScalar(u8, data, '\n');
    while (sections.next()) |connection| {
        const node_1: usize = (connection[0] - a) * 26 + connection[1] - a;
        const node_2: usize = (connection[3] - a) * 26 + connection[4] - a;

        connections[node_1][node_2] = true;
        connections[node_2][node_1] = true;
    }

    // part 1
    var out1: usize = 0;
    for (0..N) |i| {
        for (i + 1..N) |j| {
            for (j + 1..N) |k| {
                if (i == j or j == k or i == k) continue;

                if (connections[i][j] and connections[i][k] and connections[j][k]) {
                    if (i / 26 == t or j / 26 == t or k / 26 == t) out1 += 1;
                }
            }
        }
    }
    try stdout.print("1: {d}\n", .{out1});

    // part 2
    var largest_party: usize = 0;
    var neighbors = std.ArrayList(usize).init(allocator);

    var out2 = std.ArrayList(u8).init(allocator);
    for (0..N) |root| {
        neighbors.clearRetainingCapacity();

        for (0..N) |i| {
            if (connections[root][i]) {
                try neighbors.append(i);
            }
        }

        const count = neighbors.items.len;
        var mask = try allocator.create(std.bit_set.IntegerBitSet(64));
        for (0..std.math.pow(usize, 2, count)) |mask_val| {
            mask.mask = mask_val;

            outer: for (0..count) |idx1| {
                for (idx1 + 1..count) |idx2| {
                    if (mask.isSet(idx1) and mask.isSet(idx2) and
                        !connections[neighbors.items[idx1]][neighbors.items[idx2]])
                    {
                        break :outer;
                    }
                }
            } else {
                if (mask.count() > largest_party) {
                    largest_party = mask.count();
                    out2.clearAndFree();

                    for (neighbors.items, 0..) |n, idx| {
                        if (mask.isSet(idx)) {
                            try out2.append(@intCast('a' + n / 26));
                            try out2.append(@intCast('a' + n % 26));
                            if (idx < count - 1) {
                                try out2.append(',');
                            }
                        }
                    }
                }
            }
        }
    }
    try stdout.print("2: {s}\n", .{out2.items});
}
