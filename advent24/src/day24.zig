const std = @import("std");

const data = @embedFile("data/day24.txt");

const Rule = struct { one: [3]u8, two: [3]u8, op: u8, result: [3]u8 };

fn checkRule(x: [3]u8, y: [3]u8, x1: [3]u8, y1: [3]u8) bool {
    return (std.mem.eql(u8, &x, &x1) and std.mem.eql(u8, &y, &y1)) or (std.mem.eql(u8, &y, &x1) and std.mem.eql(u8, &x, &y1));
}

fn verifyAdder(bit: usize, carry: [3]u8, rules: *std.ArrayList(Rule)) ?[3]u8 {
    const x_id: [3]u8 = .{ 'x', @intCast('0' + (bit / 10)), @intCast('0' + (bit % 10)) };
    const y_id: [3]u8 = .{ 'y', @intCast('0' + (bit / 10)), @intCast('0' + (bit % 10)) };
    const z_id: [3]u8 = .{ 'z', @intCast('0' + (bit / 10)), @intCast('0' + (bit % 10)) };

    var xor1: ?[3]u8 = null;
    var and1: ?[3]u8 = null;
    for (rules.items) |r| {
        if (checkRule(r.one, r.two, x_id, y_id)) {
            if (r.op == 'X') {
                xor1 = r.result;
            } else if (r.op == 'A') {
                and1 = r.result;
            }
        }
    }

    var and2: ?[3]u8 = null;
    for (rules.items) |r| {
        if (checkRule(r.one, r.two, xor1.?, carry)) {
            if (r.op == 'X') {
                if (!std.mem.eql(u8, &r.result, &z_id)) return null;
            } else if (r.op == 'A') {
                and2 = r.result;
            }
        }
    }
    if (and2 == null) return null;

    for (rules.items) |r| {
        if (checkRule(r.one, r.two, and1.?, and2.?)) {
            if (r.op == 'O') {
                return r.result;
            }
        }
    }

    return null;
}

fn verifyWholeAdder(rules: *std.ArrayList(Rule)) usize {
    var carry: ?[3]u8 = undefined;
    for (rules.items) |r| {
        if (checkRule("x00".*, "y00".*, r.one, r.two) and r.op == 'A') {
            carry = r.result;
            break;
        }
    }

    for (1..45) |z| {
        carry = verifyAdder(z, carry.?, rules);
        if (carry == null) return z;
    }

    return if (std.mem.eql(u8, &carry.?, "z45")) 45 else 0;
}

fn sortWires(_: void, x: [3]u8, y: [3]u8) bool {
    return std.mem.order(u8, &x, &y).compare(std.math.CompareOperator.lt);
}

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocator = arena.allocator();
    defer _ = arena.deinit();

    // part 1
    var wires = std.AutoHashMap([3]u8, bool).init(allocator);

    const split_loc = std.mem.indexOf(u8, data, "\n\n").?;
    var initial_sections = std.mem.splitScalar(u8, data[0..split_loc], '\n');
    while (initial_sections.next()) |section| {
        try wires.put(.{ section[0], section[1], section[2] }, section[5] == '1');
    }

    var rules = std.ArrayList(Rule).init(allocator);
    var rule_sections = std.mem.splitScalar(u8, data[split_loc + 2 ..], '\n');
    while (rule_sections.next()) |section| {
        var segments = std.mem.tokenizeAny(u8, section, " ->");
        var segment = segments.next().?;

        var r: Rule = undefined;
        @memcpy(&r.one, segment);
        segment = segments.next().?;
        r.op = segment[0];
        segment = segments.next().?;
        @memcpy(&r.two, segment);
        segment = segments.next().?;
        @memcpy(&r.result, segment);

        try rules.append(r);
    }

    var out1 = std.bit_set.IntegerBitSet(64).initEmpty();
    while (true) {
        var ok = true;
        for (rules.items) |r| {
            if (!wires.contains(r.result) and wires.contains(r.one) and wires.contains(r.two)) {
                const one = wires.get(r.one).?;
                const two = wires.get(r.two).?;
                const bit = switch (r.op) {
                    'A' => one and two,
                    'O' => one or two,
                    'X' => (one and !two) or (!one and two),
                    else => unreachable,
                };

                try wires.put(r.result, bit);
                ok = false;

                if (r.result[0] == 'z') {
                    out1.setValue(try std.fmt.parseInt(usize, r.result[1..], 10), bit);
                }
            }
        }

        if (ok) break;
    }
    try stdout.print("1: {d}\n", .{out1.mask});

    // part 2
    var wire_list = std.ArrayList([3]u8).init(allocator);
    var it = wires.keyIterator();
    while (it.next()) |w| {
        if (w[0] != 'x' and w[0] != 'y') try wire_list.append(w.*);
    }

    var best_bit = verifyWholeAdder(&rules);
    var out2 = std.ArrayList([3]u8).init(allocator);
    while (best_bit != 45) {
        outer: for (rules.items, 0..) |*a, i| {
            for (rules.items[i + 1 ..]) |*b| {
                std.mem.swap([3]u8, &a.result, &b.result);

                const reached = verifyWholeAdder(&rules);
                if (reached > best_bit) {
                    best_bit = reached;
                    try out2.append(a.result);
                    try out2.append(b.result);
                    break :outer;
                }

                std.mem.swap([3]u8, &a.result, &b.result);
            }
        }
    }

    std.mem.sort([3]u8, out2.items, {}, sortWires);
    try stdout.print("2: ", .{});
    for (out2.items, 0..) |n, i| {
        try stdout.print("{s}", .{n});

        if (i == out2.items.len - 1) {
            try stdout.print("\n", .{});
        } else {
            try stdout.print(",", .{});
        }
    }
}
