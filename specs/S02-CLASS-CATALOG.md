# S02: CLASS CATALOG

**Library**: simple_archive
**Date**: 2026-01-23
**Status**: BACKWASH (reverse-engineered from implementation)

## Core Classes

### SIMPLE_ARCHIVE
**Purpose**: TAR archive manipulation wrapper
**Inherits**: None
**Key Features**:
- `create_archive (path, files)`: Create TAR from file list
- `create_archive_from_directory (path, dir)`: Archive directory
- `add_file_to_archive (path, file)`: Add to existing archive
- `extract_archive (path, destination)`: Extract all files
- `extract_file (path, filename, dest)`: Extract specific file
- `list_archive (path)`: Get entry list
- `archive_contains (path, filename)`: Check for file
- `is_valid_archive (path)`: Validate TAR format
- `last_error`: Error message
- `files_added`, `files_extracted`: Operation counters

### SIMPLE_ZIP
**Purpose**: ZIP archive manipulation with minizip-ng
**Inherits**: None
**Key Features**:
- `begin_create (path)`: Start creating ZIP
- `add_entry_from_string (name, content)`: Add in-memory entry
- `end_create`: Finish and close ZIP
- `is_creating`: Currently creating?
- `list_archive (path)`: Get entry names
- `extract_entry (path, name)`: Extract to string
- `archive_contains (path, name)`: Check for entry
- `is_valid_archive (path)`: Validate ZIP format
- `last_error`, `has_error`: Error handling
- `files_added`, `files_extracted`: Counters

## Support Classes

### SIMPLE_ARCHIVE_ENTRY
**Purpose**: Metadata for archive entries
**Inherits**: None
**Key Features**:
- Entry name, size, modification time
- Used in listing operations

### LISTING_UNARCHIVER
**Purpose**: TAR listing helper (ISE etar pattern)
**Inherits**: UNARCHIVER (from etar)
**Key Features**:
- Collects entry names during unarchive
- Passed to ARCHIVE.add_unarchiver

### SELECTIVE_FILE_UNARCHIVER
**Purpose**: Extract specific file from TAR
**Inherits**: UNARCHIVER (from etar)
**Key Features**:
- Matches target filename
- Extracts to specified destination
- `file_extracted`: Success flag
