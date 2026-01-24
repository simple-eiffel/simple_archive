# S06: BOUNDARIES

**Library**: simple_archive
**Date**: 2026-01-23
**Status**: BACKWASH (reverse-engineered from implementation)

## System Boundaries

### Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                      Eiffel Application                          │
├─────────────────────────────────────────────────────────────────┤
│                       simple_archive                             │
│                                                                  │
│  ┌────────────────────────┐    ┌────────────────────────────┐  │
│  │    SIMPLE_ARCHIVE      │    │       SIMPLE_ZIP           │  │
│  │    (TAR operations)    │    │    (ZIP operations)        │  │
│  │                        │    │                            │  │
│  │ - create_archive       │    │ - begin_create             │  │
│  │ - extract_archive      │    │ - add_entry_from_string    │  │
│  │ - list_archive         │    │ - end_create               │  │
│  └───────────┬────────────┘    │ - extract_entry            │  │
│              │                  │ - list_archive             │  │
│              │                  └───────────┬────────────────┘  │
│              │                              │                    │
└──────────────┼──────────────────────────────┼────────────────────┘
               │                              │
               ▼                              ▼
┌──────────────────────────┐    ┌──────────────────────────────┐
│       ISE etar           │    │       minizip-ng             │
│  (Eiffel TAR library)    │    │     (C ZIP library)         │
│                          │    │                              │
│  ARCHIVE                 │    │  zipOpen, zipClose           │
│  FILE_STORAGE_BACKEND    │    │  unzOpen, unzClose          │
│  UNARCHIVER              │    │  etc.                        │
└──────────────────────────┘    └──────────────────────────────┘
               │                              │
               ▼                              ▼
┌──────────────────────────────────────────────────────────────────┐
│                        File System                                │
│                   (TAR and ZIP files)                            │
└──────────────────────────────────────────────────────────────────┘
```

## Interface Boundaries

### Public API
- SIMPLE_ARCHIVE: All features
- SIMPLE_ZIP: All features

### Internal (Implementation)
- ISE etar classes: Used internally
- C externals: Inline C in SIMPLE_ZIP
- Helper unarchivers: LISTING_UNARCHIVER, SELECTIVE_FILE_UNARCHIVER

## Data Flow

### Archive Creation
```
Files/Content → SIMPLE_ARCHIVE/ZIP → TAR/ZIP file
```

### Archive Extraction
```
TAR/ZIP file → SIMPLE_ARCHIVE/ZIP → Files/Strings
```

### Archive Listing
```
TAR/ZIP file → SIMPLE_ARCHIVE/ZIP → ARRAYED_LIST [STRING]
```

## Integration Points

### simple_xlsx
- Uses SIMPLE_ZIP.extract_entry for reading
- Uses SIMPLE_ZIP.begin_create/add_entry_from_string for writing
- In-memory ZIP manipulation for XLSX format

### Application Code
- Direct use for backup/packaging
- File distribution systems
- Data import/export
