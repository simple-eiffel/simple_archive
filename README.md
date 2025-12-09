# SIMPLE_ARCHIVE

Simple file archiving with tar and zip support, wrapping the ISE compression library.

## Features

- Create tar archives from files or directories
- Create zip archives with compression
- Extract archives to specified locations
- Stream-friendly API
- Integration with SIMPLE_COMPRESSION for advanced compression

## Installation

Add to your ECF file:

```xml
<library name="simple_archive" location="$SIMPLE_ARCHIVE/simple_archive.ecf"/>
```

Set the environment variable:
```
SIMPLE_ARCHIVE=/path/to/simple_archive
```

## Quick Start

```eiffel
local
    archive: SIMPLE_ARCHIVE
do
    create archive.make

    -- Create a tar archive
    archive.create_tar ("backup.tar", << "file1.txt", "file2.txt" >>)

    -- Create a zip archive
    archive.create_zip ("backup.zip", << "documents/", "images/" >>)

    -- Extract an archive
    archive.extract ("backup.zip", "output_folder/")
end
```

## API Overview

### SIMPLE_ARCHIVE

| Feature | Description |
|---------|-------------|
| `create_tar` | Create tar archive from files |
| `create_zip` | Create zip archive from files |
| `extract` | Extract archive to directory |
| `list_contents` | List files in archive |

## Documentation

- [API Documentation](https://simple-eiffel.github.io/simple_archive/)

## Dependencies

- simple_compression

## License

MIT License - see LICENSE file for details.

## Author

Larry Rix
