# PackForge - Ecosystem Integration

## simple_* Dependencies

### Required Libraries

| Library | Purpose | Integration Point |
|---------|---------|-------------------|
| simple_archive | ZIP/TAR package creation | Core packaging operations |
| simple_file | File system operations | File collection, glob matching |
| simple_hash | Checksum computation | SHA-256 for files and packages |
| simple_json | Manifest parsing | JSON manifest format support |
| simple_template | Documentation generation | README, MANIFEST templates |
| simple_uuid | Package identification | Unique build IDs |
| simple_datetime | Timestamps | Build dates, version info |

### Optional Libraries

| Library | Purpose | When Needed |
|---------|---------|-------------|
| simple_yaml | Alternative manifest format | When manifest is YAML |
| simple_encryption | Package signing | When --sign option used |
| simple_cli | Advanced CLI parsing | For complex argument handling |
| simple_diff | Package comparison | For diff command |

## Integration Patterns

### simple_archive Integration

**Purpose:** Create distribution packages in ZIP or TAR format

**Usage:**
```eiffel
build_package (a_files: ARRAYED_LIST [FILE_ENTRY]; a_output: STRING; a_format: STRING)
    -- Assemble files into distribution package
  local
    l_zip: SIMPLE_ZIP
    l_tar: SIMPLE_ARCHIVE
  do
    if a_format.same_string ("zip") then
      create l_zip.make
      l_zip.begin_create (a_output)

      across a_files as entry loop
        -- For text files, use in-memory
        if entry.is_text then
          l_zip.add_entry_from_string (entry.dest_path, entry.content)
        else
          -- For binary, read and add
          l_zip.add_entry_from_string (entry.dest_path, file_utils.read_binary (entry.source_path))
        end
      end

      l_zip.end_create
      if l_zip.has_error then
        last_error := l_zip.last_error
      end
    else
      -- TAR format
      create l_tar.make
      l_tar.create_archive (a_output, a_files.source_paths.to_array)
    end
  end
```

**Data flow:** Collected files -> Format selection -> Archive creation -> Output package

### simple_file Integration

**Purpose:** File collection, glob pattern matching, directory traversal

**Usage:**
```eiffel
collect_files (a_manifest: PACKFORGE_MANIFEST): ARRAYED_LIST [FILE_ENTRY]
    -- Collect all files specified in manifest
  local
    l_file: SIMPLE_FILE
    l_matches: ARRAYED_LIST [STRING]
    l_entry: FILE_ENTRY
  do
    create Result.make (50)
    create l_file.make

    -- Process explicit file entries
    across a_manifest.files as f loop
      if f.source.has ('*') then
        -- Glob pattern
        l_matches := l_file.glob (f.source)
        across l_matches as m loop
          create l_entry.make (m, resolve_dest (f.dest, m))
          Result.extend (l_entry)
        end
      elseif l_file.exists (f.source) then
        create l_entry.make (f.source, f.dest)
        Result.extend (l_entry)
      elseif f.required then
        add_error ("Required file not found: " + f.source)
      end
    end

    -- Process glob patterns
    across a_manifest.glob_patterns as g loop
      l_matches := l_file.glob (g.pattern)
      across l_matches as m loop
        if not is_excluded (m, g.exclude) then
          create l_entry.make (m, resolve_dest (g.dest, m))
          Result.extend (l_entry)
        end
      end
    end
  end
```

**Data flow:** Manifest patterns -> Glob matching -> File list with destinations

### simple_hash Integration

**Purpose:** Compute SHA-256 checksums for verification

**Usage:**
```eiffel
compute_checksums (a_files: ARRAYED_LIST [FILE_ENTRY]): HASH_TABLE [STRING, STRING]
    -- Compute SHA-256 checksums for all files
  local
    l_hasher: SIMPLE_HASH
    l_content: STRING
  do
    create Result.make (a_files.count)
    create l_hasher.make

    across a_files as f loop
      l_content := file_utils.read_binary (f.source_path)
      Result.put (l_hasher.sha256 (l_content), f.dest_path)
    end
  end

generate_checksum_file (a_checksums: HASH_TABLE [STRING, STRING]; a_package_hash: STRING): STRING
    -- Generate CHECKSUMS.txt content
  do
    create Result.make (a_checksums.count * 100)
    Result.append ("PackForge Checksums%N")
    Result.append ("Algorithm: SHA-256%N%N")

    across a_checksums as c loop
      Result.append (c)
      Result.append ("  ")
      Result.append (c.key)
      Result.append ("%N")
    end

    Result.append ("%NPackage: ")
    Result.append (a_package_hash)
    Result.append ("%N")
  end
```

**Data flow:** Files -> SHA-256 computation -> Checksum table -> CHECKSUMS.txt

### simple_json Integration

**Purpose:** Parse manifest files and generate metadata

**Usage:**
```eiffel
load_manifest (a_path: STRING): PACKFORGE_MANIFEST
    -- Load and parse manifest file
  local
    l_json: SIMPLE_JSON
    l_obj: JSON_OBJECT
  do
    create l_json.make
    l_obj := l_json.parse_file (a_path)

    create Result.make
    if attached l_obj.object ("package") as pkg then
      Result.name := pkg.string ("name")
      Result.version := pkg.string ("version")
      Result.description := pkg.string ("description")
    end

    if attached l_obj.array ("files") as files then
      across files as f loop
        if attached {JSON_OBJECT} f as fobj then
          Result.add_file (
            fobj.string ("source"),
            fobj.string ("dest"),
            fobj.boolean ("required")
          )
        end
      end
    end
    -- ... parse other sections
  end
```

**Data flow:** JSON file -> Parse -> Manifest object

### simple_template Integration

**Purpose:** Generate documentation from templates

**Usage:**
```eiffel
generate_readme (a_manifest: PACKFORGE_MANIFEST; a_template: STRING): STRING
    -- Generate README from template
  local
    l_tmpl: SIMPLE_TEMPLATE
    l_vars: HASH_TABLE [STRING, STRING]
  do
    create l_tmpl.make
    create l_vars.make (10)

    -- Set template variables
    l_vars.put (a_manifest.name, "name")
    l_vars.put (a_manifest.version, "version")
    l_vars.put (a_manifest.description, "description")
    l_vars.put (a_manifest.author, "author")
    l_vars.put (a_manifest.license, "license")
    l_vars.put (datetime.now.formatted ("YYYY-MM-DD"), "build_date")

    Result := l_tmpl.render (a_template, l_vars)
  end

generate_manifest_file (a_files: ARRAYED_LIST [FILE_ENTRY]; a_checksums: HASH_TABLE [STRING, STRING]): STRING
    -- Generate MANIFEST.txt
  local
    l_tmpl: SIMPLE_TEMPLATE
  do
    create l_tmpl.make

    -- Use embedded template
    Result := l_tmpl.render (manifest_template, create_manifest_vars (a_files, a_checksums))
  end
```

**Data flow:** Template + Variables -> Render -> Documentation file

### simple_uuid Integration

**Purpose:** Generate unique build identifiers

**Usage:**
```eiffel
create_build_id: STRING
    -- Generate unique build identifier
  local
    l_uuid: SIMPLE_UUID
  do
    create l_uuid.make
    Result := l_uuid.generate_v4
  end
```

**Data flow:** Generate UUID -> Build metadata

### simple_datetime Integration

**Purpose:** Timestamps and version information

**Usage:**
```eiffel
get_build_timestamp: STRING
    -- Get ISO 8601 build timestamp
  local
    l_dt: SIMPLE_DATETIME
  do
    create l_dt.make
    Result := l_dt.now.formatted ("YYYY-MM-DDTHH:mm:ssZ")
  end
```

## Dependency Graph

```
packforge
    |
    +-- simple_archive (required)
    |       |
    |       +-- ISE etar
    |       +-- minizip-ng
    |
    +-- simple_file (required)
    |       |
    |       +-- ISE base
    |
    +-- simple_hash (required)
    |       |
    |       +-- OpenSSL / bcrypt
    |
    +-- simple_json (required)
    |       |
    |       +-- ISE base
    |
    +-- simple_template (required)
    |       |
    |       +-- simple_file
    |
    +-- simple_uuid (required)
    |       |
    |       +-- ISE base
    |
    +-- simple_datetime (required)
    |       |
    |       +-- ISE time
    |
    +-- simple_yaml (optional)
    +-- simple_encryption (optional)
    +-- simple_diff (optional)
```

## ECF Configuration

```xml
<?xml version="1.0" encoding="ISO-8859-1"?>
<system xmlns="http://www.eiffel.com/developers/xml/configuration-1-22-0"
    name="packforge"
    uuid="XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX">

    <target name="packforge">
        <description>PackForge release package builder library</description>
        <root all_classes="true"/>
        <option warning="warning" syntax="provisional" manifest_array_type="mismatch_warning">
            <assertions precondition="true" postcondition="true" check="true" invariant="true"/>
        </option>

        <setting name="console_application" value="true"/>
        <setting name="dead_code_removal" value="all"/>

        <!-- simple_* ecosystem dependencies -->
        <library name="simple_archive" location="$SIMPLE_EIFFEL/simple_archive/simple_archive.ecf"/>
        <library name="simple_file" location="$SIMPLE_EIFFEL/simple_file/simple_file.ecf"/>
        <library name="simple_hash" location="$SIMPLE_EIFFEL/simple_hash/simple_hash.ecf"/>
        <library name="simple_json" location="$SIMPLE_EIFFEL/simple_json/simple_json.ecf"/>
        <library name="simple_template" location="$SIMPLE_EIFFEL/simple_template/simple_template.ecf"/>
        <library name="simple_uuid" location="$SIMPLE_EIFFEL/simple_uuid/simple_uuid.ecf"/>
        <library name="simple_datetime" location="$SIMPLE_EIFFEL/simple_datetime/simple_datetime.ecf"/>

        <!-- ISE base libraries -->
        <library name="base" location="$ISE_LIBRARY/library/base/base.ecf"/>
        <library name="time" location="$ISE_LIBRARY/library/time/time.ecf"/>

        <!-- Application source -->
        <cluster name="packforge" location=".\src\" recursive="true"/>
    </target>

    <target name="packforge_cli" extends="packforge">
        <description>PackForge CLI executable</description>
        <root class="PACKFORGE_CLI" feature="make"/>
        <setting name="executable_name" value="packforge"/>
    </target>

    <target name="packforge_tests" extends="packforge">
        <description>PackForge test suite</description>
        <root class="TEST_APP" feature="make"/>
        <library name="simple_testing" location="$SIMPLE_EIFFEL/simple_testing/simple_testing.ecf"/>
        <cluster name="tests" location=".\tests\" recursive="true"/>
    </target>
</system>
```
