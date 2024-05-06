const std = @import("std");
const cstd = @cImport(@cInclude("stdlib.h"));

reg_a: u8,
reg_b: u8,
reg_c: u8,
reg_d: u8,
reg_e: u8,
reg_h: u8,
reg_l: u8,
sp: u16,
pc: u16,
zero_flag: u1,
sub_flag: u1,
half_flag: u1,
carry_flag: u1,
opcode: u8,
memory: [8000]u8,
const Flags = enum { zero, carry, subtraction, half_carry };

const Self = @This();

pub fn init(self: *Self) !void {
    self.reg_a = @as(u8, 0);
    self.reg_b = @as(u8, 0);
    self.reg_c = @as(u8, 0);
    self.reg_d = @as(u8, 0);
    self.reg_e = @as(u8, 0);
    self.reg_h = @as(u8, 0);
    self.reg_l = @as(u8, 0);
    self.sp = @as(u16, 0);
    self.pc = @as(u16, 0);
    self.zero_flag = false;
    self.half_flag = false;
    self.sub_flag = false;
    self.carry_flag = false;
    self.opcode = @as(u8, 0);
    for (&self.memory) |*b| {
        b.* = 0;
    }
}

fn increment_pc(self: *Self) void {
    self.pc += 1;
}

fn set_bit(n: u8, pos: u8) void {
    n |= (1 << pos);
}

fn clear_bit(n: u8, pos: u8) void {
    n |= (0 << pos);
}

pub fn cycle(self: *Self) !void {
    self.opcode = self.memory[self.pc] << 8 | self.memory[self.pc + 1];
    switch (self.opcode) {
        0x00 => {
            //nothing
        },
        0x01 => {
            self.reg_c = self.memory[self.pc];
            self.increment_pc();
            self.reg_b = self.memory[self.pc];
            self.increment_pc();
        },
        0x02 => {
            var bc = self.get_bc();
            self.memory[bc] = self.reg_a;
            self.increment_pc();
        },
        0x03 => {
            // inc bc
            var bc = self.get_bc();
            bc += 1;
            self.set_bc(bc);
            self.increment_pc();
        },
        0x04 => {
            // inc r8 (b)
            self.reg_b += 1;
            self.zero_flag = (self.reg_b == 0);
            self.sub_flag = 0;
            self.half_flag = ((self.reg_b & 0x0F) == 0x00);
            self.increment_pc();
        },
        0x05 => {
            // dec r8 (b)
            self.reg_b -= 1;
            self.zero_flag = (self.reg_b == 0);
            self.sub_flag = 1;
            self.half_flag = ((self.reg_b & 0x0F) == 0x0F);
            self.increment_pc();
        },
        0x06 => {
            // ld immediate byte into b
            self.reg_b = self.memory[self.pc + 1];
            self.increment_pc();
        },
        0x07 => {
            //rlca
            self.carry_flag = if ((self.reg_a & 0x01) == 0x00) 0 else 1;
            self.reg_a = (self.reg_a << 0x01) | (self.reg_a >> 0x07);
            self.sub_flag = 0;
            self.half_flag = 0;
            self.zero_flag = 0;
            self.increment_pc();
        },
        0x08 => {},
        else => {
            @panic("Not a valid opcode!");
        },
    }
}

fn adc_a_r8(self: *Self, r8: u8) void {
    var nn = self.reg_a + r8 + self.carry_flag;
    self.zero_flag = ((nn & 0xFF) == 0x00);
    self.sub_flag = 0;
    self.half_flag = if ((self.reg_a ^ r8 ^ nn) & 0x10) 1 else 0;
    self.carry_flag = if (nn & 0xFF00) 1 else 0;
    self.reg_a = nn & 0xFF;
}

fn get_bc(self: *Self) u16 {
    return @as(u16, @as(u16, (self.reg_b)) << 8) | self.reg_c;
}

fn set_bc(self: *Self, value: u16) void {
    self.reg_b = @as(u8, @truncate((value & 0xFF00) >> 8));
    self.reg_c = @as(u8, @truncate(value & 0xFF));
}

test "bcRegisterTests demo" {
    var test_allocator = std.testing.allocator;
    var test_cpu = try test_allocator.create(Self);
    defer test_allocator.destroy(test_cpu);
    try test_cpu.init();
    try std.testing.expectEqual(@as(u16, 0x0000), test_cpu.*.get_bc());
    test_cpu.*.set_bc(@as(u16, 0x0110));
    try std.testing.expectEqual(@as(u16, 0x0110), test_cpu.*.get_bc());
}

fn get_de(self: *Self) u16 {
    return @as(u16, @as(u16, (self.reg_d)) << 8) | self.reg_e;
}

fn set_de(self: *Self, value: u16) void {
    self.reg_d = @as(u8, @truncate((value & 0xFF00) >> 8));
    self.reg_e = @as(u8, @truncate(value & 0xFF));
}

test "deRegisterTests demo" {
    var test_allocator = std.testing.allocator;
    var test_cpu = try test_allocator.create(Self);
    defer test_allocator.destroy(test_cpu);
    try test_cpu.init();
    try std.testing.expectEqual(@as(u16, 0), test_cpu.*.get_de());
    test_cpu.*.set_de(@as(u16, 0x0110));
    try std.testing.expectEqual(@as(u16, 0x0110), test_cpu.*.get_de());
}

fn get_hl(self: *Self) u16 {
    return @as(u16, (self.reg_h) << u8(8)) | @as(u16, self.reg_l);
}

fn set_hl(self: *Self, value: u16) void {
    self.reg_h = @as(u8, ((value & 0xFF00) >> 8));
    self.reg_l = @as(u8, (value & 0xFF));
}
