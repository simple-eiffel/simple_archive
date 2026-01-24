# S03: CONTRACTS

**Library**: simple_archive
**Date**: 2026-01-23
**Status**: BACKWASH (reverse-engineered from implementation)

## SIMPLE_ARCHIVE Contracts

### Feature: create_archive
```eiffel
create_archive (a_archive_path: STRING; a_files: ARRAY [STRING])
    require
        archive_path_not_empty: not a_archive_path.is_empty
        files_not_empty: not a_files.is_empty
    ensure
        error_or_files_added: last_error /= Void or files_added > 0
```

### Feature: extract_archive
```eiffel
extract_archive (a_archive_path: STRING; a_destination: STRING)
    require
        archive_path_not_empty: not a_archive_path.is_empty
        destination_not_empty: not a_destination.is_empty
```

### Feature: extract_file
```eiffel
extract_file (a_archive_path: STRING; a_file_name: STRING; a_destination: STRING)
    require
        archive_path_not_empty: not a_archive_path.is_empty
        file_name_not_empty: not a_file_name.is_empty
        destination_not_empty: not a_destination.is_empty
```

### Feature: list_archive
```eiffel
list_archive (a_archive_path: STRING): ARRAYED_LIST [STRING]
    require
        archive_path_not_empty: not a_archive_path.is_empty
    ensure
        result_not_void: Result /= Void
```

### Feature: archive_contains
```eiffel
archive_contains (a_archive_path: STRING; a_file_name: STRING): BOOLEAN
    require
        archive_path_not_empty: not a_archive_path.is_empty
        file_name_not_empty: not a_file_name.is_empty
```

### Feature: is_valid_archive
```eiffel
is_valid_archive (a_archive_path: STRING): BOOLEAN
    require
        archive_path_not_empty: not a_archive_path.is_empty
```

## SIMPLE_ZIP Contracts

### Feature: begin_create
```eiffel
begin_create (a_archive_path: STRING)
    require
        archive_path_not_empty: not a_archive_path.is_empty
        not_already_creating: not is_creating
    ensure
        creating_or_error: is_creating or has_error
```

### Feature: add_entry_from_string
```eiffel
add_entry_from_string (a_entry_name: STRING; a_content: STRING)
    require
        is_creating: is_creating
        entry_name_not_empty: not a_entry_name.is_empty
        content_not_void: a_content /= Void
```

### Feature: end_create
```eiffel
end_create
    require
        is_creating: is_creating
    ensure
        not_creating: not is_creating
```

### Feature: list_archive
```eiffel
list_archive (a_archive_path: STRING): ARRAYED_LIST [STRING]
    require
        archive_path_not_empty: not a_archive_path.is_empty
    ensure
        result_not_void: Result /= Void
```

### Feature: extract_entry
```eiffel
extract_entry (a_archive_path: STRING; a_entry_name: STRING): detachable STRING
    require
        archive_path_not_empty: not a_archive_path.is_empty
        entry_name_not_empty: not a_entry_name.is_empty
```
