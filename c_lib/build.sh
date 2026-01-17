#!/bin/bash
cd /d/prod/simple_archive/c_lib/minizip-ng-4.0.10

VSDIR="/c/Program Files/Microsoft Visual Studio/2022/Community"
MSVC_BIN="$VSDIR/VC/Tools/MSVC/14.44.35207/bin/Hostx64/x64"
MSVC_INC="$VSDIR/VC/Tools/MSVC/14.44.35207/include"
UCRT_INC="/c/Program Files (x86)/Windows Kits/10/Include/10.0.26100.0/ucrt"
UM_INC="/c/Program Files (x86)/Windows Kits/10/Include/10.0.26100.0/um"
SHARED_INC="/c/Program Files (x86)/Windows Kits/10/Include/10.0.26100.0/shared"
ZLIB_INC="/c/Program Files/Eiffel Software/EiffelStudio 25.02 Standard/C_library/zlib"

export PATH="$MSVC_BIN:$PATH"

CFLAGS="/c /O2 /MD /DWIN32 /D_WIN32 /DHAVE_ZLIB /DMZ_ZIP_NO_ENCRYPTION"
INCS="/I. /I\"$MSVC_INC\" /I\"$UCRT_INC\" /I\"$UM_INC\" /I\"$SHARED_INC\" /I\"$ZLIB_INC\""

echo "Compiling minizip-ng..."

cl.exe $CFLAGS $INCS mz_os.c
cl.exe $CFLAGS $INCS mz_os_win32.c  
cl.exe $CFLAGS $INCS mz_strm.c
cl.exe $CFLAGS $INCS mz_strm_buf.c
cl.exe $CFLAGS $INCS mz_strm_mem.c
cl.exe $CFLAGS $INCS mz_strm_os_win32.c
cl.exe $CFLAGS $INCS mz_strm_zlib.c
cl.exe $CFLAGS $INCS mz_crypt.c
cl.exe $CFLAGS $INCS mz_zip.c
cl.exe $CFLAGS $INCS mz_zip_rw.c

cl.exe $CFLAGS $INCS /Icompat compat/ioapi.c
cl.exe $CFLAGS $INCS /Icompat compat/zip.c
cl.exe $CFLAGS $INCS /Icompat compat/unzip.c

echo "Creating static library..."
"$MSVC_BIN/lib.exe" /OUT:minizip.lib *.obj

ls -la minizip.lib
