# POSIX build of minizip-ng for simple_archive (macOS and Linux).
# Windows uses build_minizip.py. Usage: make -C c_lib
# Same source set and options as Windows, with the POSIX OS layer and the
# system zlib. Writes ../lib/posix/libminizip.a.

CC ?= cc
AR ?= ar
CFLAGS ?= -O2 -fPIC
DEFINES = -DHAVE_ZLIB -DZLIB_COMPAT -DMZ_ZIP_NO_ENCRYPTION -DHAVE_STDINT_H -DHAVE_INTTYPES_H
SRC = minizip-ng-4.0.10
OUT = ../lib/posix
SOURCES = mz_os.c mz_os_posix.c mz_strm.c mz_strm_buf.c mz_strm_mem.c mz_strm_os_posix.c \
	mz_strm_zlib.c mz_crypt.c mz_zip.c mz_zip_rw.c compat/ioapi.c compat/zip.c compat/unzip.c
OBJECTS = $(addprefix $(OUT)/obj/,$(notdir $(SOURCES:.c=.o)))

vpath %.c $(SRC) $(SRC)/compat

$(OUT)/libminizip.a: $(OBJECTS)
	$(AR) rcs $@ $(OBJECTS)

$(OUT)/obj/%.o: %.c
	@mkdir -p $(OUT)/obj
	$(CC) $(CFLAGS) $(DEFINES) -I$(SRC) -I$(SRC)/compat -c $< -o $@

clean:
	rm -rf $(OUT)

.PHONY: clean
