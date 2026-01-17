#!/usr/bin/env python3
"""Build minizip-ng as static library"""
import subprocess
import os
import glob

os.chdir(r"D:\prod\simple_archive\c_lib\minizip-ng-4.0.10")

# Visual Studio paths
VS_ROOT = r"C:\Program Files\Microsoft Visual Studio\2022\Community"
MSVC_VER = "14.44.35207"
MSVC_BIN = fr"{VS_ROOT}\VC\Tools\MSVC\{MSVC_VER}\bin\Hostx64\x64"
MSVC_INC = fr"{VS_ROOT}\VC\Tools\MSVC\{MSVC_VER}\include"
UCRT_INC = r"C:\Program Files (x86)\Windows Kits\10\Include\10.0.26100.0\ucrt"
UM_INC = r"C:\Program Files (x86)\Windows Kits\10\Include\10.0.26100.0\um"
SHARED_INC = r"C:\Program Files (x86)\Windows Kits\10\Include\10.0.26100.0\shared"
ZLIB_INC = r"C:\Program Files\Eiffel Software\EiffelStudio 25.02 Standard\C_library\zlib"

CL = fr"{MSVC_BIN}\cl.exe"
LIB = fr"{MSVC_BIN}\lib.exe"

SOURCES = [
    "mz_os.c",
    "mz_os_win32.c",
    "mz_strm.c",
    "mz_strm_buf.c",
    "mz_strm_mem.c",
    "mz_strm_os_win32.c",
    "mz_strm_zlib.c",
    "mz_crypt.c",
    "mz_zip.c",
    "mz_zip_rw.c",
    r"compat\ioapi.c",
    r"compat\zip.c",
    r"compat\unzip.c",
]

# Added ZLIB_COMPAT to use standard zlib.h instead of zlib-ng.h
# Use /MT for static CRT to match EiffelStudio
CFLAGS = ["/c", "/O2", "/MT", "/DWIN32", "/D_WIN32", "/DHAVE_ZLIB", "/DZLIB_COMPAT", "/DMZ_ZIP_NO_ENCRYPTION"]
INCLUDES = [f"/I{d}" for d in [".", MSVC_INC, UCRT_INC, UM_INC, SHARED_INC, ZLIB_INC, "compat"]]

print("Compiling minizip-ng files...")
for src in SOURCES:
    cmd = [CL] + CFLAGS + INCLUDES + [src]
    print(f"  {os.path.basename(src)}")
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode != 0:
        print(f"ERROR compiling {src}:")
        print("STDOUT:", result.stdout)
        print("STDERR:", result.stderr)
        exit(1)

print("\nCreating static library...")
objs = glob.glob("*.obj")
cmd = [LIB, "/OUT:minizip.lib"] + objs
result = subprocess.run(cmd, capture_output=True, text=True)
if result.returncode != 0:
    print("ERROR creating library:")
    print(result.stderr)
    exit(1)

# Check result
if os.path.exists("minizip.lib"):
    size = os.path.getsize("minizip.lib")
    print(f"\nSUCCESS: minizip.lib created ({size:,} bytes)")
else:
    print("FAILED: minizip.lib not created")
    exit(1)
