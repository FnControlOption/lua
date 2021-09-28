usingnamespace @cImport({
  @cDefine("LUA_ZIG", "1");
  @cInclude("lzio.h");
});

// #define getlock(l)	cast(struct L_EXTRA*, lua_getextraspace(l))
// inline fn getlock(l: ?*lua_State) *L_EXTRA {
//   return @ptrCast(*L_EXTRA, lua_getextraspace(l));
// }

// #define lua_unlock(l)   lua_assert(--(*getlock(l)->plock) == 0)
// inline fn lua_unlock(l: ?*lua_State) void {
//   var lock = getlock(l);
//   lock.plock -= 1;
//   lua_assert(lock.plock == 0);
// }

pub export fn luaZ_fill(z: *ZIO) c_int {
  var L: ?*lua_State = z.L;
  _ = if (__builtin_expect(@bitCast(c_long, @as(c_long, @boolToInt(!((blk: {
    const ref = &@ptrCast([*c]struct_L_EXTRA, @alignCast(@import("std").meta.alignment(struct_L_EXTRA), @ptrCast(?*c_void, @ptrCast([*c]u8, @alignCast(@import("std").meta.alignment(u8), L)) - @sizeOf(struct_L_EXTRA)))).*.plock.?.*;
    ref.* -= 1;
    break :blk ref.*;
  }) == @as(c_int, 0))))), @bitCast(c_long, @as(c_long, @as(c_int, 0)))) != 0) __assert_rtn("luaZ_fill", "lzio.c", @as(c_int, 27), "--(*((struct L_EXTRA*)(((void *)((char *)(L) - sizeof(struct L_EXTRA)))))->plock) == 0") else @as(c_int, 0);
  var size: usize = undefined;
  var buff: ?[*]const u8 = z.reader.?(L, z.data, &size);
  _ = if (__builtin_expect(@bitCast(c_long, @as(c_long, @boolToInt(!((blk: {
    const ref = &@ptrCast([*c]struct_L_EXTRA, @alignCast(@import("std").meta.alignment(struct_L_EXTRA), @ptrCast(?*c_void, @ptrCast([*c]u8, @alignCast(@import("std").meta.alignment(u8), L)) - @sizeOf(struct_L_EXTRA)))).*.plock.?.*;
    const tmp = ref.*;
    ref.* += 1;
    break :blk tmp;
  }) == @as(c_int, 0))))), @bitCast(c_long, @as(c_long, @as(c_int, 0)))) != 0) __assert_rtn("luaZ_fill", "lzio.c", @as(c_int, 29), "(*((struct L_EXTRA*)(((void *)((char *)(L) - sizeof(struct L_EXTRA)))))->plock)++ == 0") else @as(c_int, 0);
  if (buff == null or size == 0)
    return EOZ;
  z.n = size - 1;
  z.p = buff;
  defer z.p += 1;
  return cast(u8, z.p.*);
}

pub export fn luaZ_init(L: ?*lua_State, z: *ZIO, reader: lua_Reader, data: ?*c_void) void {
  z.L = L;
  z.reader = reader;
  z.data = data;
  z.n = 0;
  z.p = null;
}


// --------------------------------------------------------------- read --- //
pub export fn luaZ_read(z: *ZIO, arg_b: ?*c_void, arg_n: usize) usize {
  var b = arg_b;
  var n = arg_n;
  while (n != 0) {
    if (z.n == 0) {  // no bytes in buffer?
      if (luaZ_fill(z) == EOZ)  // try to read more
        return n  // no more input; return number of missing bytes
      else {
        z.n += 1;  // luaZ_fill consumed first byte; put it back
        z.p -= 1;
      }
    }
    var m: usize = if (n <= z.n) n else z.n;  // min. between n and z->n
    @memcpy(@ptrCast([*]u8, b), z.p, m);
    z.n -= m;
    z.p += m;
    b = @ptrCast(?*c_void, @ptrCast([*]u8, b) + m);
    n -= m;
  }
  return 0;
}
