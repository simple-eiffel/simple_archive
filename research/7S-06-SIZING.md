# 7S-06: SIZING

**Library**: simple_archive
**Date**: 2026-01-23
**Status**: BACKWASH (reverse-engineered from implementation)

## Implementation Size

### Class Count

| Category | Classes | LOC (approx) |
|----------|---------|--------------|
| Core | 2 | 530 |
| Support | 2 | 150 |
| Testing | 2 | 100 |
| **Total** | **6** | **780** |

### Core Classes
- SIMPLE_ARCHIVE: 267 lines (TAR operations)
- SIMPLE_ZIP: 315 lines (ZIP operations with inline C)

### Support Classes
- SIMPLE_ARCHIVE_ENTRY: ~50 lines
- SELECTIVE_FILE_UNARCHIVER: ~50 lines
- LISTING_UNARCHIVER: ~50 lines

## Feature Count

### SIMPLE_ARCHIVE (TAR)
| Feature | Count |
|---------|-------|
| Creation | 3 (file-based, directory, add file) |
| Extraction | 2 (full, selective) |
| Listing | 3 (list, contains, count) |
| Validation | 1 (is_valid_archive) |

### SIMPLE_ZIP (ZIP)
| Feature | Count |
|---------|-------|
| Creation | 4 (begin, add_entry, end, is_creating) |
| Extraction | 2 (extract_entry, full extract planned) |
| Listing | 3 (list, contains, is_valid) |

## Complexity Assessment

| Feature | Complexity | Notes |
|---------|-----------|-------|
| TAR creation | Low | ISE etar does heavy lifting |
| TAR extraction | Low | ISE etar handles |
| ZIP creation | Medium | Inline C with minizip |
| ZIP extraction | Medium | Inline C with minizip |
| In-memory ZIP | Medium | Pointer/memory management |
| Listing | Low | Simple iteration |

## External Dependencies

| Dependency | Type | Size Impact |
|------------|------|-------------|
| ISE etar | Eiffel | Included with ES |
| minizip-ng | C library | ~500KB compiled |
| zlib | C library | ~200KB (shared) |

## Development Effort

| Phase | Effort | Status |
|-------|--------|--------|
| TAR wrapper | 1 day | Complete |
| ZIP inline C | 2 days | Complete |
| Listing support | 0.5 day | Complete |
| Testing | 0.5 day | Complete |
| **Total** | **~4 days** | **Complete** |

## Resource Requirements

- Compile time: < 3 seconds
- Runtime memory: Proportional to archive size
- Disk: Extraction needs space for uncompressed data
- External: minizip-ng library files
