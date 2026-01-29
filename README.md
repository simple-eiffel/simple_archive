<p align="center">
  <img src="https://raw.githubusercontent.com/simple-eiffel/.github/main/profile/assets/logo.svg" alt="simple_ library logo" width="400">
</p>

# simple_archive

**[Documentation](https://simple-eiffel.github.io/simple_archive/)** | **[GitHub](https://github.com/simple-eiffel/simple_archive)**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Eiffel](https://img.shields.io/badge/Eiffel-25.02-blue.svg)](https://www.eiffel.org/)
[![Design by Contract](https://img.shields.io/badge/DbC-enforced-orange.svg)]()

File archiving library with TAR and ZIP support using minizip-ng.

Part of the [Simple Eiffel](https://github.com/simple-eiffel) ecosystem.

## Status

**Production** - TAR via ISE compression, ZIP via minizip-ng 4.0.10

## Overview

SIMPLE_ARCHIVE provides Eiffel applications with file archiving capabilities. SIMPLE_TAR wraps ISE's compression library for TAR archives. SIMPLE_ZIP uses minizip-ng 4.0.10 (May 2025) for modern ZIP support with in-memory operations ideal for XLSX file handling.

## Features

- **TAR Archives** - Create and extract TAR archives via ISE compression
- **ZIP Archives** - Create and extract ZIP archives via minizip-ng
- **In-Memory Operations** - Build archives from string content (no temp files)
- **Archive Listing** - List contents without extraction
- **Entry Extraction** - Extract specific entries as strings
- **Design by Contract** - Full preconditions, postconditions, invariants
- **Void Safe** - Fully void-safe implementation

## Installation

1. Set the ecosystem environment variable (one-time setup for all simple_* libraries):
```bash
export SIMPLE_EIFFEL=D:\prod
```

2. Add to your ECF:
```xml
<library name="simple_archive" location="$SIMPLE_EIFFEL/simple_archive/simple_archive.ecf"/>
```

## Quick Start

### Creating a ZIP Archive

```eiffel
local
    zip: SIMPLE_ZIP
do
    create zip.make

    -- Create archive with in-memory content
    zip.begin_create ("output.zip")
    zip.add_entry_from_string ("path/in/zip.xml", xml_content)
    zip.add_entry_from_string ("another/file.txt", text_content)
    zip.end_create

    if zip.has_error then
        print ("Error: " + zip.last_error)
    end
end
```

### Extracting from ZIP

```eiffel
local
    zip: SIMPLE_ZIP
    content: detachable STRING
do
    create zip.make

    -- Check if valid archive
    if zip.is_valid_archive ("input.zip") then
        -- Extract specific entry
        content := zip.extract_entry ("input.zip", "path/in/zip.xml")

        -- List all entries
        across zip.list_archive ("input.zip") as entry loop
            print (entry)
        end
    end
end
```

## API Reference

### SIMPLE_ZIP

| Feature | Description |
|---------|-------------|
| `make` | Create ZIP helper |
| `begin_create (path)` | Start creating new ZIP archive |
| `add_entry_from_string (name, content)` | Add entry with string content |
| `end_create` | Finalize and write ZIP file |
| `list_archive (path)` | List all entries in archive |
| `extract_entry (path, name)` | Extract entry content as string |
| `archive_contains (path, name)` | Check if archive contains entry |
| `is_valid_archive (path)` | Check if file is valid ZIP |
| `has_error` | Check if last operation failed |
| `last_error` | Error message from last operation |

### SIMPLE_TAR

| Feature | Description |
|---------|-------------|
| `create_archive (path, files)` | Create TAR from files |
| `extract_archive (path, dest)` | Extract TAR to directory |
| `list_archive (path)` | List TAR contents |

## Dependencies

- simple_compression (ISE library, for TAR support)
- minizip-ng 4.0.10 (bundled, for ZIP support)
- zlib (ISE library, compression backend)

## License

MIT License - Copyright (c) 2024-2025, Larry Rix
