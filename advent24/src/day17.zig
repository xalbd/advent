const std = @import("std");

const data = @embedFile("data/day17.txt");

const CPU = struct {
    a: usize,
    b: usize,
    c: usize,
    ip: usize = 0,
    instructions: []usize,
    output: *std.ArrayList(usize),

    fn combo(self: CPU, operand: usize) usize {
        return switch (operand) {
            0, 1, 2, 3 => operand,
            4 => self.a,
            5 => self.b,
            6 => self.c,
            else => 0,
        };
    }

    fn run(self: *CPU) !void {
        while (true) {
            if (self.ip >= self.instructions.len) break;
            const opcode = self.instructions[self.ip];
            const operand = self.instructions[self.ip + 1];

            var ip_change: usize = 2;

            switch (opcode) {
                0 => {
                    self.a = self.a / std.math.pow(usize, 2, self.combo(operand));
                },
                1 => {
                    self.b = self.b ^ operand;
                },
                2 => {
                    self.b = (self.combo(operand)) % 8;
                },
                3 => {
                    if (self.a != 0) {
                        self.ip = operand;
                        ip_change = 0;
                    }
                },
                4 => {
                    self.b = self.b ^ self.c;
                },
                5 => {
                    try self.output.append(self.combo(operand) % 8);
                },
                6 => {
                    self.b = self.a / std.math.pow(usize, 2, (self.combo(operand)));
                },
                7 => {
                    self.c = self.a / std.math.pow(usize, 2, (self.combo(operand)));
                },
                else => {},
            }

            self.ip += ip_change;
        }
    }

    fn recurse(self: *CPU, out: *usize, cur: usize) !bool {
        if (cur == self.instructions.len) return true;
        for (0..8) |i| {
            out.* = (out.* << 3) + i;

            self.a = out.*;
            self.b = 0;
            self.c = 0;
            self.ip = 0;
            self.output.clearAndFree();

            try self.run();

            if (std.mem.eql(usize, self.instructions[self.instructions.len - 1 - cur ..], self.output.items[0 .. cur + 1]) and try self.recurse(out, cur + 1)) {
                return true;
            }

            out.* >>= 3;
        }
        return false;
    }
};

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocator = arena.allocator();
    defer _ = arena.deinit();

    var instructions = std.ArrayList(usize).init(allocator);
    var output = std.ArrayList(usize).init(allocator);

    var sections = std.mem.tokenizeAny(u8, data, "Register ABC: Program,\n");
    const a = try std.fmt.parseInt(usize, sections.next().?, 10);
    const b = try std.fmt.parseInt(usize, sections.next().?, 10);
    const c = try std.fmt.parseInt(usize, sections.next().?, 10);
    while (sections.next()) |section| {
        try instructions.append(try std.fmt.parseInt(usize, section, 10));
    }

    var cpu: CPU = .{ .a = a, .b = b, .c = c, .instructions = instructions.items, .output = &output };

    // part 1
    try cpu.run();
    try stdout.print("1: ", .{});
    for (output.items, 0..) |x, i| {
        if (i == output.items.len - 1) {
            try stdout.print("{d}\n", .{x});
        } else {
            try stdout.print("{d},", .{x});
        }
    }

    // part 2
    var out2: usize = 0;
    _ = try cpu.recurse(&out2, 0);
    try stdout.print("2: {d}\n", .{out2});
}
