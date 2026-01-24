# 7S-03: SOLUTIONS

**Library**: simple_archive
**Date**: 2026-01-23
**Status**: BACKWASH (reverse-engineered from implementation)

## Existing Solutions Comparison

### Archive Libraries

| Solution | Pros | Cons |
|----------|------|------|
| libarchive | Many formats | C library, complex |
| zlib | Standard, fast | ZIP only structure |
| minizip | Simple ZIP API | Aging codebase |
| minizip-ng | Modern, maintained | Still C library |
| ISE etar | Eiffel native | TAR only |

### Language-Specific

| Solution | Language | Pros | Cons |
|----------|----------|------|------|
| zipfile | Python | Built-in | Python only |
| Archive::Zip | Perl | Full-featured | Perl only |
| JSZip | JavaScript | Browser support | JS only |
| SharpZipLib | .NET | Full .NET | .NET only |

### Eiffel Ecosystem

- ISE etar: TAR-only, part of EiffelStudio
- No comprehensive archive library before simple_archive

## Why Build simple_archive?

1. **Unified API**: Single interface for TAR and ZIP
2. **Simple Operations**: create, extract, list as one-liners
3. **Eiffel Integration**: Works with simple_* ecosystem
4. **XLSX Support**: In-memory ZIP for Office formats
5. **Error Handling**: Proper last_error reporting

## Design Decisions

1. **Separate Classes**: SIMPLE_ARCHIVE (TAR) and SIMPLE_ZIP (ZIP)
   - Different underlying libraries
   - Different feature sets
   - Clear separation of concerns

2. **ISE etar Wrapper**: SIMPLE_ARCHIVE uses native Eiffel TAR
   - No C dependencies for TAR
   - Leverages existing EiffelStudio code

3. **minizip-ng for ZIP**: SIMPLE_ZIP uses inline C
   - Modern, maintained library
   - Full ZIP format support
   - In-memory operations possible

4. **Streaming vs In-Memory**: Both supported for ZIP
   - File-based for large archives
   - In-memory for XLSX manipulation

5. **Error Pattern**: last_error attribute
   - Operations set last_error on failure
   - Consistent with simple_* ecosystem
