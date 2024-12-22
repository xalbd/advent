const std = @import("std");

const data = @embedFile("data/day22.txt");

fn mix(secret: isize, value: isize) isize {
    return secret ^ value;
}

fn prune(secret: isize) isize {
    return @mod(secret, 16777216);
}

fn next(secret: isize) isize {
    var out = secret;
    out = prune(mix(out, out * 64));
    out = prune(mix(out, @divTrunc(out, 32)));
    out = prune(mix(out, out * 2048));

    return out;
}

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocator = arena.allocator();
    defer _ = arena.deinit();

    // part 1
    var out1: isize = 0;
    var bananas = std.AutoHashMap(struct { isize, isize, isize, isize }, isize).init(allocator);

    var change_sequence = std.ArrayList(isize).init(allocator);
    var banana_sequence = std.ArrayList(isize).init(allocator);
    var changes_to_bananas = std.AutoHashMap(struct { isize, isize, isize, isize }, isize).init(allocator);

    var secrets = std.mem.splitScalar(u8, data, '\n');
    while (secrets.next()) |initial| {
        var secret = try std.fmt.parseInt(isize, initial, 10);
        banana_sequence.clearRetainingCapacity();
        change_sequence.clearRetainingCapacity();
        changes_to_bananas.clearRetainingCapacity();

        for (0..2000) |_| {
            const next_secret = next(secret);
            try change_sequence.append(@mod(next_secret, 10) - @mod(secret, 10));
            try banana_sequence.append(@mod(next_secret, 10));
            secret = next_secret;
        }

        out1 += secret;

        for (0..2000 - 4) |i| {
            const changes = .{ change_sequence.items[i], change_sequence.items[i + 1], change_sequence.items[i + 2], change_sequence.items[i + 3] };
            if (!changes_to_bananas.contains(changes)) {
                try changes_to_bananas.put(changes, banana_sequence.items[i + 3]);
            }
        }

        var it = changes_to_bananas.iterator();
        while (it.next()) |x| {
            const old_banana = bananas.get(x.key_ptr.*) orelse 0;
            try bananas.put(x.key_ptr.*, old_banana + x.value_ptr.*);
        }
    }
    try stdout.print("1: {d}\n", .{out1});

    // part 2
    var out2: isize = 0;
    var it = bananas.valueIterator();
    while (it.next()) |banana| {
        out2 = @max(out2, banana.*);
    }
    try stdout.print("2: {d}\n", .{out2});
}
