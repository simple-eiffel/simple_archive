/* Configuration for minizip-ng in simple_archive */
#ifndef MINIZIP_CONFIG_H
#define MINIZIP_CONFIG_H

/* Windows */
#define _WIN32 1

/* Use zlib for compression */
#define HAVE_ZLIB 1

/* Disable optional features we don't need */
#undef HAVE_BZIP2
#undef HAVE_LZMA
#undef HAVE_ZSTD
#undef HAVE_LIBCOMP
#undef HAVE_PKCRYPT
#undef HAVE_WZAES
#undef HAVE_OPENSSL
#undef HAVE_LIBBSD

/* Use standard zlib (not zlib-ng) */
#undef HAVE_ZLIB_NG

/* Basic settings */
#define MZ_ZIP_NO_SIGNING 1
#define MZ_ZIP_NO_ENCRYPTION 1

#endif
