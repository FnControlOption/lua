const Builder = @import("std").build.Builder;

const cflags = &.{"-DLUA_USE_MACOSX", "-DLUA_USER_H=\"ltests.h\""};

pub fn build(b: *Builder) void {
    const target = b.standardTargetOptions(.{});
    const mode = b.standardReleaseOptions();

    const lib = b.addStaticLibrary("lua", null);
    lib.setTarget(target);
    lib.setBuildMode(mode);
    lib.addCSourceFiles(libCSourceFiles(), cflags);
    lib.install();

    const exe = b.addExecutable("lua", null);
    exe.setTarget(target);
    exe.setBuildMode(mode);
    exe.addCSourceFile("lua.c", cflags);
    exe.linkLibrary(lib);
    exe.install();
}

fn libCSourceFiles() []const []const u8 {
    return &.{
        "lapi.c",
        "lcode.c",
        "lctype.c",
        "ldebug.c",
        "ldo.c",
        "ldump.c",
        "lfunc.c",
        "lgc.c",
        "llex.c",
        "lmem.c",
        "lobject.c",
        "lopcodes.c",
        "lparser.c",
        "lstate.c",
        "lstring.c",
        "ltable.c",
        "ltm.c",
        "lundump.c",
        "lvm.c",
        "lzio.c",
        "ltests.c",
        "lauxlib.c",
        "lbaselib.c",
        "ldblib.c",
        "liolib.c",
        "lmathlib.c",
        "loslib.c",
        "ltablib.c",
        "lstrlib.c",
        "lutf8lib.c",
        "loadlib.c",
        "lcorolib.c",
        "linit.c",
    };
}
