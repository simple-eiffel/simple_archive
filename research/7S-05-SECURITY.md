# 7S-05: SECURITY

**Library**: simple_archive
**Date**: 2026-01-23
**Status**: BACKWASH (reverse-engineered from implementation)

## Security Considerations

### Path Traversal (Zip Slip)

1. **Risk**: Malicious archive with "../" in filenames
   - Could write outside extraction directory
   - Classic archive extraction vulnerability

2. **Mitigation**:
   - SIMPLE_ZIP extracts to specified directory
   - ISE etar handles path validation
   - Application should validate extracted paths

3. **Recommendation**:
   - Always extract to dedicated directory
   - Verify extraction results
   - Don't extract untrusted archives without validation

### Archive Bombs (Zip Bombs)

1. **Risk**: Small archive expands to huge size
   - Denial of service via disk exhaustion
   - Memory exhaustion with in-memory extraction

2. **Mitigation**:
   - Check uncompressed size before extraction
   - Limit extraction to reasonable sizes
   - Monitor disk space during extraction

3. **Current Implementation**:
   - No built-in protection
   - Application responsibility to check sizes

### Filename Encoding

1. **Risk**: Non-UTF8 filenames causing issues
   - Path injection via encoding tricks
   - Display issues

2. **Mitigation**:
   - minizip-ng uses UTF-8
   - Validate filenames before use

### Symlink Attacks

1. **Risk**: Archive contains symlinks to sensitive files
   - TAR supports symlinks
   - Could overwrite system files

2. **Mitigation**:
   - ISE etar handles symlinks appropriately
   - Don't extract as root/admin
   - Validate symlink targets

## Secure Usage Guidelines

1. **Extract to isolated directory**
2. **Validate archive source** before processing
3. **Check entry counts and sizes** before extraction
4. **Don't run as elevated user** when extracting untrusted archives
5. **Verify extracted file paths** don't escape destination

## Threat Summary

| Threat | Severity | Mitigation Status |
|--------|----------|-------------------|
| Path traversal | High | Partial (directory-based) |
| Archive bombs | Medium | Application responsibility |
| Filename encoding | Low | UTF-8 support |
| Symlink attacks | Medium | OS-level handling |
