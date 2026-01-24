# 7S-02: STANDARDS

**Library**: simple_archive
**Date**: 2026-01-23
**Status**: BACKWASH (reverse-engineered from implementation)

## Applicable Standards

### TAR Format

1. **POSIX.1-1988 (ustar)**
   - 512-byte block alignment
   - 100-character filename limit (extended in later formats)
   - Octal encoding for metadata

2. **ISE etar Library**
   - Eiffel wrapper for TAR operations
   - Classes: ARCHIVE, FILE_STORAGE_BACKEND, UNARCHIVER

### ZIP Format

1. **PKZIP APPNOTE**
   - Local file header format
   - Central directory structure
   - Compression methods (stored, deflate)

2. **minizip-ng v4.0.10**
   - Modern minizip implementation
   - Headers: zip.h, unzip.h
   - Functions: zipOpen, zipClose, unzOpen, etc.

### Compression

1. **DEFLATE (RFC 1951)**
   - Default ZIP compression method
   - Z_DEFAULT_COMPRESSION level

## File Format Details

### TAR Structure
```
┌─────────────────────────────────────┐
│ File Header 1 (512 bytes)           │
├─────────────────────────────────────┤
│ File Data 1 (rounded to 512)        │
├─────────────────────────────────────┤
│ File Header 2 (512 bytes)           │
├─────────────────────────────────────┤
│ File Data 2 (rounded to 512)        │
├─────────────────────────────────────┤
│ ... more files ...                  │
├─────────────────────────────────────┤
│ End of Archive (2x 512-byte zeros)  │
└─────────────────────────────────────┘
```

### ZIP Structure
```
┌─────────────────────────────────────┐
│ Local File Header 1                 │
│ File Data 1 (compressed)            │
├─────────────────────────────────────┤
│ Local File Header 2                 │
│ File Data 2 (compressed)            │
├─────────────────────────────────────┤
│ ... more files ...                  │
├─────────────────────────────────────┤
│ Central Directory                   │
├─────────────────────────────────────┤
│ End of Central Directory            │
└─────────────────────────────────────┘
```

## Compliance Notes

- TAR archives are uncompressed (use GZIP separately if needed)
- ZIP uses default deflate compression
- Unicode filenames supported in ZIP (UTF-8)
- Long paths may be truncated in TAR
