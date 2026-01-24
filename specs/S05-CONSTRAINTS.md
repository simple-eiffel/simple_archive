# S05: CONSTRAINTS

**Library**: simple_archive
**Date**: 2026-01-23
**Status**: BACKWASH (reverse-engineered from implementation)

## Technical Constraints

### TAR Constraints (SIMPLE_ARCHIVE)
- **Filename length**: 100 chars (ustar), longer with extensions
- **No compression**: TAR is uncompressed (use GZIP separately)
- **Block alignment**: 512-byte blocks
- **No random access**: Sequential processing
- **Append limitation**: Adding files recreates archive

### ZIP Constraints (SIMPLE_ZIP)
- **Filename length**: 65535 bytes max
- **Entry size**: 4GB max (ZIP64 not implemented)
- **Compression**: DEFLATE only (stored also available)
- **Password**: Not supported
- **Streaming**: Not supported (need seekable file)

### Memory Constraints
- TAR: Processes entries sequentially
- ZIP in-memory: Content must fit in memory
- Large files: May cause memory pressure

### Platform Constraints
- Windows: Path separators handled
- minizip-ng: Requires C library linkage
- ISE etar: Included with EiffelStudio

## API Constraints

### Error Handling
- Operations set `last_error` on failure
- Check `last_error /= Void` after operations
- `has_error` convenience for ZIP

### File Operations
- Archive path must be writable for create
- Destination must be writable for extract
- Source files must be readable for archival

### State Management
- SIMPLE_ZIP: begin_create/end_create must be paired
- is_creating tracks current state
- Cannot nest create operations

## Performance Constraints

### TAR Performance
| Operation | Complexity | Notes |
|-----------|-----------|-------|
| Create | O(n files) | Sequential writes |
| Extract | O(n files) | Sequential reads |
| List | O(n files) | Full scan needed |
| Add file | O(n files) | Recreates entire archive |

### ZIP Performance
| Operation | Complexity | Notes |
|-----------|-----------|-------|
| Create | O(n files) | Sequential writes |
| Extract entry | O(log n) | Central directory lookup |
| List | O(n files) | Read central directory |
| Locate file | O(n files) | Linear search |

## Compatibility Constraints

- TAR: Compatible with GNU tar, BSD tar
- ZIP: Compatible with standard ZIP tools
- Encoding: UTF-8 filenames preferred
