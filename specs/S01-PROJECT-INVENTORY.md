# S01: PROJECT INVENTORY

**Library**: simple_archive
**Date**: 2026-01-23
**Status**: BACKWASH (reverse-engineered from implementation)

## Project Structure

```
simple_archive/
├── simple_archive.ecf          # Library configuration
├── src/
│   ├── simple_archive.e        # TAR archive operations
│   ├── simple_zip.e            # ZIP archive operations (inline C)
│   ├── simple_archive_entry.e  # Archive entry metadata
│   ├── listing_unarchiver.e    # TAR listing helper
│   └── selective_file_unarchiver.e  # Selective extraction
├── testing/
│   ├── test_app.e              # Test application root
│   └── lib_tests.e             # Test suite
├── research/                   # This directory
└── specs/                      # Specification directory
```

## File Count Summary

| Category | Files |
|----------|-------|
| Core source | 5 |
| Test files | 2 |
| Configuration | 1 |
| **Total** | **8** |

## External Dependencies

### Eiffel Libraries
- EiffelBase (standard library)
- ISE etar (TAR archive support)

### C Libraries
- minizip-ng v4.0.10 (ZIP support)
  - zip.h, unzip.h headers
  - zlib for compression

## Build Requirements

### For TAR (SIMPLE_ARCHIVE)
- EiffelStudio with etar library
- No additional configuration

### For ZIP (SIMPLE_ZIP)
- minizip-ng compiled library
- Include path for zip.h, unzip.h
- Link with minizip library
