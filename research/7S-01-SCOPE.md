# 7S-01: SCOPE

**Library**: simple_archive
**Date**: 2026-01-23
**Status**: BACKWASH (reverse-engineered from implementation)

## Problem Domain

Archive file manipulation for Eiffel applications, providing unified access to TAR and ZIP archive formats. The library enables creating, extracting, listing, and modifying archive files through a simple API.

## Target Users

1. **Eiffel developers** needing file archival
2. **Backup/deployment systems** packaging files
3. **Build tools** creating distribution packages
4. **Data processing** extracting archived data
5. **XLSX handlers** (ZIP-based Office formats)

## Primary Use Cases

1. Create TAR archives from files/directories
2. Create ZIP archives with compression
3. Extract archives to directories
4. Extract specific files from archives
5. List archive contents
6. Add files to existing archives
7. In-memory ZIP manipulation (for XLSX)

## Boundaries

### In Scope
- TAR archive creation and extraction
- ZIP archive creation and extraction
- Archive content listing
- Selective file extraction
- Directory archival
- In-memory ZIP operations
- ZIP compression (deflate)

### Out of Scope
- GZIP/BZIP2 compression (TAR only, uncompressed)
- RAR, 7z, other formats
- Archive encryption
- Split/multi-volume archives
- Archive repair

## Dependencies

- EiffelBase: Standard library
- ISE etar library: TAR operations
- minizip-ng (v4.0.10): ZIP operations (inline C)
