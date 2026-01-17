@echo off
REM Build minizip-ng as static library for simple_archive

call "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat"

cd /d D:\prod\simple_archive\c_lib\minizip-ng-4.0.10

set ZLIB_INC=C:\Program Files\Eiffel Software\EiffelStudio 25.02 Standard\C_library\zlib
set ZLIB_LIB=C:\Program Files\Eiffel Software\EiffelStudio 25.02 Standard\studio\spec\win64\lib\msc_vc140

set CFLAGS=/c /O2 /MD /DWIN32 /D_WIN32 /DHAVE_ZLIB /DMZ_ZIP_NO_ENCRYPTION /I. /I"%ZLIB_INC%"

REM Compile core files
cl %CFLAGS% mz_os.c
cl %CFLAGS% mz_os_win32.c
cl %CFLAGS% mz_strm.c
cl %CFLAGS% mz_strm_buf.c
cl %CFLAGS% mz_strm_mem.c
cl %CFLAGS% mz_strm_os_win32.c
cl %CFLAGS% mz_strm_zlib.c
cl %CFLAGS% mz_crypt.c
cl %CFLAGS% mz_zip.c
cl %CFLAGS% mz_zip_rw.c

REM Compile compat layer
cl %CFLAGS% /Icompat compat\ioapi.c
cl %CFLAGS% /Icompat compat\zip.c
cl %CFLAGS% /Icompat compat\unzip.c

REM Create static library
lib /OUT:minizip.lib mz_os.obj mz_os_win32.obj mz_strm.obj mz_strm_buf.obj mz_strm_mem.obj mz_strm_os_win32.obj mz_strm_zlib.obj mz_crypt.obj mz_zip.obj mz_zip_rw.obj ioapi.obj zip.obj unzip.obj

echo.
echo Build complete! minizip.lib created.
dir minizip.lib
