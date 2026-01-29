# ArcVault - Ecosystem Integration

## simple_* Dependencies

### Required Libraries

| Library | Purpose | Integration Point |
|---------|---------|-------------------|
| simple_archive | TAR/ZIP creation and extraction | Core archive operations |
| simple_file | File system operations | Source collection, directory walking |
| simple_hash | Content hashing (SHA-256) | Deduplication tracking, verification |
| simple_json | Config and manifest files | Configuration, manifest generation |
| simple_datetime | Date/time calculations | Retention policy evaluation |
| simple_logger | Audit trail logging | Operation tracking, compliance |

### Optional Libraries

| Library | Purpose | When Needed |
|---------|---------|-------------|
| simple_csv | Export audit reports | When --export to CSV requested |
| simple_email | Notification delivery | When email alerts configured |
| simple_encryption | Archive encryption | When --encrypt option used |
| simple_sql | Advanced audit storage | For enterprise audit requirements |
| simple_cli | Command-line parsing | If more sophisticated CLI needed |

## Integration Patterns

### simple_archive Integration

**Purpose:** Core archive creation and extraction operations

**Usage:**
```eiffel
create_backup (a_sources: ARRAYED_LIST [STRING]; a_dest: STRING)
    -- Create backup archive from source paths
  local
    l_archive: SIMPLE_ARCHIVE
    l_zip: SIMPLE_ZIP
    l_files: ARRAYED_LIST [STRING]
  do
    -- Collect all files from sources
    l_files := collect_files (a_sources)

    if config.archive_format.same_string ("tar") then
      create l_archive.make
      l_archive.create_archive (a_dest, l_files.to_array)
      if attached l_archive.last_error as err then
        last_error := err
      end
    else
      -- ZIP with in-memory manifest
      create l_zip.make
      l_zip.begin_create (a_dest)
      across l_files as f loop
        l_zip.add_entry_from_file (f, f) -- Uses add_entry_from_string internally
      end
      l_zip.end_create
    end
  end
```

**Data flow:** Source files -> File collection -> Archive creation -> Manifest generation

### simple_file Integration

**Purpose:** File system operations for source collection and directory traversal

**Usage:**
```eiffel
collect_files (a_sources: ARRAYED_LIST [STRING]): ARRAYED_LIST [STRING]
    -- Collect all files from source paths
  local
    l_file_utils: SIMPLE_FILE
    l_dir_contents: ARRAYED_LIST [STRING]
  do
    create Result.make (100)
    create l_file_utils.make

    across a_sources as src loop
      if l_file_utils.is_directory (src) then
        l_dir_contents := l_file_utils.recursive_files (src)
        Result.append (l_dir_contents)
      elseif l_file_utils.exists (src) then
        Result.extend (src)
      else
        log_warning ("Source not found: " + src)
      end
    end
  end
```

**Data flow:** Source paths -> Directory traversal -> File list

### simple_hash Integration

**Purpose:** Content hashing for deduplication tracking and verification

**Usage:**
```eiffel
compute_file_hashes (a_files: ARRAYED_LIST [STRING]): HASH_TABLE [STRING, STRING]
    -- Compute SHA-256 hashes for all files
  local
    l_hasher: SIMPLE_HASH
    l_content: STRING
    l_hash: STRING
  do
    create Result.make (a_files.count)
    create l_hasher.make

    across a_files as f loop
      l_content := file_utils.read_file (f)
      l_hash := l_hasher.sha256 (l_content)
      Result.put (l_hash, f)
    end
  end

track_deduplication (a_hashes: HASH_TABLE [STRING, STRING]): DEDUP_REPORT
    -- Track duplicate content across files
  local
    l_seen: HASH_TABLE [ARRAYED_LIST [STRING], STRING]
    l_files: ARRAYED_LIST [STRING]
  do
    create l_seen.make (a_hashes.count)
    create Result.make

    across a_hashes as h loop
      if l_seen.has (h) then
        l_seen.item (h).extend (h.key)
        Result.duplicate_bytes := Result.duplicate_bytes + file_size (h.key)
      else
        create l_files.make (5)
        l_files.extend (h.key)
        l_seen.put (l_files, h)
        Result.unique_bytes := Result.unique_bytes + file_size (h.key)
      end
    end
  end
```

**Data flow:** Files -> Hash computation -> Deduplication tracking -> Storage savings report

### simple_json Integration

**Purpose:** Configuration file parsing and manifest generation

**Usage:**
```eiffel
load_config (a_path: STRING): ARCVAULT_CONFIG
    -- Load configuration from JSON file
  local
    l_json: SIMPLE_JSON
    l_obj: JSON_OBJECT
  do
    create l_json.make
    l_obj := l_json.parse_file (a_path)

    create Result.make
    if attached l_obj.object ("arcvault") as cfg then
      Result.base_path := cfg.string ("storage.base_path")
      Result.archive_format := cfg.string ("storage.archive_format")
      -- ... more fields
    end
  end

generate_manifest (a_backup: BACKUP_INFO): STRING
    -- Generate JSON manifest for backup
  local
    l_json: SIMPLE_JSON
  do
    create l_json.make
    l_json.start_object
    l_json.add_string ("manifest_version", "1.0")
    l_json.add_string ("archive_name", a_backup.name)
    l_json.add_string ("created_at", a_backup.timestamp.out)
    l_json.add_integer ("entry_count", a_backup.entries.count)
    l_json.start_array ("entries")
    across a_backup.entries as e loop
      l_json.start_object
      l_json.add_string ("path", e.path)
      l_json.add_integer ("size", e.size)
      l_json.add_string ("checksum", e.checksum)
      l_json.end_object
    end
    l_json.end_array
    l_json.end_object
    Result := l_json.to_string
  end
```

**Data flow:** Config file -> Parse -> Config object | Backup info -> Serialize -> Manifest JSON

### simple_datetime Integration

**Purpose:** Retention policy date calculations

**Usage:**
```eiffel
evaluate_retention (a_backup: BACKUP_INFO; a_policy: RETENTION_POLICY): BOOLEAN
    -- Should this backup be retained under the policy?
  local
    l_dt: SIMPLE_DATETIME
    l_age_days: INTEGER
    l_is_weekly: BOOLEAN
    l_is_monthly: BOOLEAN
  do
    create l_dt.make
    l_age_days := l_dt.days_between (a_backup.created_date, l_dt.now)

    -- Check absolute max age
    if l_age_days > a_policy.max_age_days then
      Result := False
    elseif l_age_days <= a_policy.keep_daily then
      -- Within daily retention window
      Result := True
    elseif l_age_days <= (a_policy.keep_weekly * 7) then
      -- Check if this is a weekly checkpoint (e.g., Sunday)
      l_is_weekly := l_dt.day_of_week (a_backup.created_date) = 1
      Result := l_is_weekly
    elseif l_age_days <= (a_policy.keep_monthly * 30) then
      -- Check if this is a monthly checkpoint (1st of month)
      l_is_monthly := l_dt.day_of_month (a_backup.created_date) = 1
      Result := l_is_monthly
    else
      -- Yearly: keep Jan 1st backups
      Result := l_dt.day_of_year (a_backup.created_date) = 1
    end
  end
```

**Data flow:** Backup date + Policy rules -> Date math -> Retain/Delete decision

### simple_logger Integration

**Purpose:** Audit trail logging for compliance

**Usage:**
```eiffel
log_backup_operation (a_op: STRING; a_details: BACKUP_INFO)
    -- Log backup operation for audit trail
  local
    l_logger: SIMPLE_LOGGER
  do
    create l_logger.make_with_file (config.audit_log_path)
    l_logger.set_format ("[{timestamp}] [{level}] {message}")

    l_logger.info ("BACKUP_" + a_op + ": " + a_details.name)
    l_logger.info ("  Source paths: " + a_details.sources.out)
    l_logger.info ("  Archive: " + a_details.archive_path)
    l_logger.info ("  Size: " + a_details.size.out + " bytes")
    l_logger.info ("  Entries: " + a_details.entry_count.out)
    l_logger.info ("  Checksum: " + a_details.checksum)
  end
```

**Data flow:** Operation details -> Format -> Log file -> Audit trail

## Dependency Graph

```
arcvault
    |
    +-- simple_archive (required)
    |       |
    |       +-- ISE etar (for TAR)
    |       +-- minizip-ng (for ZIP)
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
    +-- simple_datetime (required)
    |       |
    |       +-- ISE time
    |
    +-- simple_logger (required)
    |       |
    |       +-- simple_file
    |
    +-- simple_csv (optional)
    +-- simple_email (optional)
    +-- simple_encryption (optional)
```

## ECF Configuration

```xml
<?xml version="1.0" encoding="ISO-8859-1"?>
<system xmlns="http://www.eiffel.com/developers/xml/configuration-1-22-0"
    name="arcvault"
    uuid="XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX">

    <target name="arcvault">
        <description>ArcVault backup archive manager library</description>
        <root all_classes="true"/>
        <option warning="warning" syntax="provisional" manifest_array_type="mismatch_warning">
            <assertions precondition="true" postcondition="true" check="true" invariant="true"/>
        </option>

        <setting name="console_application" value="true"/>
        <setting name="total_order_on_reals" value="false"/>
        <setting name="dead_code_removal" value="all"/>

        <!-- simple_* ecosystem dependencies -->
        <library name="simple_archive" location="$SIMPLE_EIFFEL/simple_archive/simple_archive.ecf"/>
        <library name="simple_file" location="$SIMPLE_EIFFEL/simple_file/simple_file.ecf"/>
        <library name="simple_hash" location="$SIMPLE_EIFFEL/simple_hash/simple_hash.ecf"/>
        <library name="simple_json" location="$SIMPLE_EIFFEL/simple_json/simple_json.ecf"/>
        <library name="simple_datetime" location="$SIMPLE_EIFFEL/simple_datetime/simple_datetime.ecf"/>
        <library name="simple_logger" location="$SIMPLE_EIFFEL/simple_logger/simple_logger.ecf"/>

        <!-- ISE base libraries -->
        <library name="base" location="$ISE_LIBRARY/library/base/base.ecf"/>
        <library name="time" location="$ISE_LIBRARY/library/time/time.ecf"/>

        <!-- Application source -->
        <cluster name="arcvault" location=".\src\" recursive="true"/>
    </target>

    <target name="arcvault_cli" extends="arcvault">
        <description>ArcVault CLI executable</description>
        <root class="ARCVAULT_CLI" feature="make"/>
        <setting name="executable_name" value="arcvault"/>
    </target>

    <target name="arcvault_tests" extends="arcvault">
        <description>ArcVault test suite</description>
        <root class="TEST_APP" feature="make"/>
        <library name="simple_testing" location="$SIMPLE_EIFFEL/simple_testing/simple_testing.ecf"/>
        <cluster name="tests" location=".\tests\" recursive="true"/>
    </target>
</system>
```
