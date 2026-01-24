# 7S-04: SIMPLE-STAR INTEGRATION

**Library**: simple_archive
**Date**: 2026-01-23
**Status**: BACKWASH (reverse-engineered from implementation)

## Ecosystem Dependencies

### External Libraries

1. **ISE etar (EiffelStudio)**
   - Purpose: TAR archive operations
   - Classes: ARCHIVE, FILE_STORAGE_BACKEND
   - Included with EiffelStudio

2. **minizip-ng**
   - Purpose: ZIP archive operations
   - Version: 4.0.10
   - Headers: zip.h, unzip.h
   - Requires: C compilation

### No simple_* Dependencies

simple_archive has no dependencies on other simple_* libraries. It is a foundational library that other libraries depend on.

## Libraries Using simple_archive

1. **simple_xlsx**
   - Uses: SIMPLE_ZIP for XLSX file manipulation
   - Pattern: In-memory ZIP operations
   - Methods: begin_create, add_entry_from_string, extract_entry

2. **Build/deployment tools**
   - Uses: Both TAR and ZIP for packaging
   - Pattern: create_archive, create_archive_from_directory

## Integration Patterns

### XLSX Manipulation (with simple_xlsx)

```eiffel
-- Reading XLSX (ZIP-based)
zip.extract_entry ("document.xlsx", "xl/worksheets/sheet1.xml")

-- Writing XLSX (in-memory)
zip.begin_create ("output.xlsx")
zip.add_entry_from_string ("xl/worksheets/sheet1.xml", sheet_xml)
zip.add_entry_from_string ("[Content_Types].xml", content_types)
zip.end_create
```

### Backup System

```eiffel
archive: SIMPLE_ARCHIVE
create archive.make
archive.create_archive_from_directory ("backup.tar", "/data/to/backup")
```

### Distribution Package

```eiffel
zip: SIMPLE_ZIP
create zip.make
zip.begin_create ("release-1.0.zip")
-- Add files...
zip.end_create
```

## Namespace Conventions

- SIMPLE_ARCHIVE: TAR operations
- SIMPLE_ZIP: ZIP operations
- Supporting classes: SIMPLE_ARCHIVE_ENTRY, etc.
- No conflicts with other simple_* libraries
