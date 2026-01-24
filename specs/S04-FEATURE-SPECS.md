# S04: FEATURE SPECIFICATIONS

**Library**: simple_archive
**Date**: 2026-01-23
**Status**: BACKWASH (reverse-engineered from implementation)

## SIMPLE_ARCHIVE Features (TAR)

### create_archive (path, files)
**Purpose**: Create TAR archive containing specified files
**Behavior**:
1. Creates FILE_STORAGE_BACKEND with path
2. Opens ARCHIVE for writing
3. Adds each file via add_location
4. Finalizes archive
**Updates**: files_added, last_error

### create_archive_from_directory (path, directory)
**Purpose**: Create TAR containing all directory contents
**Behavior**:
1. Lists directory entries (excluding . and ..)
2. Builds file list with full paths
3. Calls create_archive with file list
**Updates**: files_added, last_error

### add_file_to_archive (path, file)
**Purpose**: Add file to existing TAR
**Behavior**:
1. Lists current archive contents
2. Adds new file to list
3. Recreates archive (TAR limitation)
**Note**: Not efficient for large archives

### extract_archive (path, destination)
**Purpose**: Extract all TAR contents
**Behavior**:
1. Creates destination directory if needed
2. Changes working directory to destination
3. Opens archive with FILE_UNARCHIVER and DIRECTORY_UNARCHIVER
4. Unarchives all entries
5. Restores working directory
**Updates**: files_extracted, last_error

### extract_file (path, filename, destination)
**Purpose**: Extract single file from TAR
**Behavior**:
1. Creates SELECTIVE_FILE_UNARCHIVER for target
2. Processes archive
3. Unarchiver extracts matching file
**Updates**: files_extracted (0 or 1), last_error

### list_archive (path): ARRAYED_LIST [STRING]
**Purpose**: Get names of all entries
**Behavior**:
1. Creates LISTING_UNARCHIVER to collect names
2. Processes archive
3. Returns collected entry list

## SIMPLE_ZIP Features (ZIP)

### begin_create (path)
**Purpose**: Start creating new ZIP file
**Behavior**:
1. Opens ZIP file with zipOpen (C)
2. Stores handle in current_zip
**C Call**: `zipOpen(path, APPEND_STATUS_CREATE)`

### add_entry_from_string (name, content)
**Purpose**: Add in-memory content as ZIP entry
**Behavior**:
1. Opens new file in ZIP (zipOpenNewFileInZip)
2. Writes content (zipWriteInFileInZip)
3. Closes file in ZIP (zipCloseFileInZip)
**Compression**: Z_DEFLATED, Z_DEFAULT_COMPRESSION

### end_create
**Purpose**: Finalize and close ZIP
**Behavior**: Calls zipClose
**Effect**: ZIP file ready for reading

### list_archive (path): ARRAYED_LIST [STRING]
**Purpose**: Get entry names from ZIP
**Behavior**:
1. Opens ZIP (unzOpen)
2. Iterates entries (unzGoToFirstFile, unzGoToNextFile)
3. Gets filename for each (unzGetCurrentFileInfo)
4. Closes ZIP (unzClose)

### extract_entry (path, name): detachable STRING
**Purpose**: Extract specific entry as string
**Behavior**:
1. Opens ZIP and locates file (unzLocateFile)
2. Gets file info for size
3. Opens file (unzOpenCurrentFile)
4. Reads content (unzReadCurrentFile)
5. Closes and returns content
