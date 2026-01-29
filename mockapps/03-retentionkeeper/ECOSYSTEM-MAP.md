# RetentionKeeper - Ecosystem Integration

## simple_* Dependencies

### Required Libraries

| Library | Purpose | Integration Point |
|---------|---------|-------------------|
| simple_archive | Document archiving (ZIP) | Archive creation and extraction |
| simple_sql | Policy database, audit logs | SQLite storage for all metadata |
| simple_json | Configuration, metadata | Policy definitions, document metadata |
| simple_hash | Document fingerprinting | SHA-256 for document integrity |
| simple_datetime | Retention calculations | Date arithmetic for retention periods |
| simple_csv | Report generation | Compliance reports export |
| simple_file | File operations | Document collection and management |

### Optional Libraries

| Library | Purpose | When Needed |
|---------|---------|-------------|
| simple_pdf | Certificate generation | For disposition certificates |
| simple_email | Notifications | When alerts configured |
| simple_encryption | Archive encryption | For sensitive documents |
| simple_logger | Enhanced logging | For detailed audit trails |

## Integration Patterns

### simple_archive Integration

**Purpose:** Archive documents for long-term storage with compression

**Usage:**
```eiffel
archive_document (a_source: STRING; a_archive_path: STRING; a_metadata: DOCUMENT_METADATA)
    -- Archive a document with metadata
  local
    l_zip: SIMPLE_ZIP
    l_meta_json: STRING
  do
    create l_zip.make

    -- Create archive with document and metadata
    l_zip.begin_create (a_archive_path)

    -- Add original document
    l_zip.add_entry_from_string ("document" + file_extension (a_source), file_utils.read_binary (a_source))

    -- Add metadata as JSON
    l_meta_json := json_utils.serialize (a_metadata)
    l_zip.add_entry_from_string ("metadata.json", l_meta_json)

    -- Add checksum file
    l_zip.add_entry_from_string ("checksum.txt", compute_checksum (a_source))

    l_zip.end_create

    if l_zip.has_error then
      last_error := l_zip.last_error
    end
  end

retrieve_document (a_archive_path: STRING; a_dest: STRING): BOOLEAN
    -- Retrieve document from archive
  local
    l_zip: SIMPLE_ZIP
    l_content: detachable STRING
  do
    create l_zip.make

    if l_zip.is_valid_archive (a_archive_path) then
      -- Get the document entry (find first non-metadata file)
      across l_zip.list_archive (a_archive_path) as entry loop
        if not entry.same_string ("metadata.json") and not entry.same_string ("checksum.txt") then
          l_content := l_zip.extract_entry (a_archive_path, entry)
          if attached l_content then
            file_utils.write_binary (a_dest, l_content)
            Result := True
          end
        end
      end
    end
  end
```

**Data flow:** Source document + metadata -> ZIP archive -> Storage

### simple_sql Integration

**Purpose:** Store policies, documents, audit logs, and manage relationships

**Usage:**
```eiffel
setup_database
    -- Initialize database schema
  local
    l_sql: SIMPLE_SQL
  do
    create l_sql.make (database_path)

    -- Create tables
    l_sql.execute ("CREATE TABLE IF NOT EXISTS policies (
      id INTEGER PRIMARY KEY,
      name TEXT UNIQUE NOT NULL,
      description TEXT,
      retention_period TEXT NOT NULL,
      trigger_event TEXT DEFAULT 'creation',
      regulation TEXT,
      created_at TEXT DEFAULT CURRENT_TIMESTAMP,
      active INTEGER DEFAULT 1
    )")

    l_sql.execute ("CREATE TABLE IF NOT EXISTS documents (
      id INTEGER PRIMARY KEY,
      original_path TEXT NOT NULL,
      archive_path TEXT NOT NULL,
      classification TEXT,
      policy_id INTEGER REFERENCES policies(id),
      ingested_at TEXT DEFAULT CURRENT_TIMESTAMP,
      retention_until TEXT,
      status TEXT DEFAULT 'active',
      checksum TEXT NOT NULL,
      metadata TEXT
    )")

    l_sql.execute ("CREATE TABLE IF NOT EXISTS audit_log (
      id INTEGER PRIMARY KEY,
      timestamp TEXT DEFAULT CURRENT_TIMESTAMP,
      event_type TEXT NOT NULL,
      document_id INTEGER REFERENCES documents(id),
      user_name TEXT,
      details TEXT
    )")

    l_sql.execute ("CREATE TABLE IF NOT EXISTS legal_holds (
      id INTEGER PRIMARY KEY,
      name TEXT UNIQUE NOT NULL,
      matter TEXT,
      custodian TEXT,
      scope_query TEXT,
      created_at TEXT DEFAULT CURRENT_TIMESTAMP,
      released_at TEXT,
      active INTEGER DEFAULT 1
    )")

    l_sql.close
  end

get_documents_for_disposition: ARRAYED_LIST [DOCUMENT_RECORD]
    -- Get documents past retention with no active hold
  local
    l_sql: SIMPLE_SQL
    l_rows: ARRAYED_LIST [SQL_ROW]
  do
    create Result.make (100)
    create l_sql.make (database_path)

    l_rows := l_sql.query ("
      SELECT d.* FROM documents d
      WHERE d.retention_until <= date('now')
        AND d.status = 'active'
        AND NOT EXISTS (
          SELECT 1 FROM document_holds dh
          JOIN legal_holds h ON dh.hold_id = h.id
          WHERE dh.document_id = d.id AND h.active = 1
        )
      ORDER BY d.retention_until
    ")

    across l_rows as row loop
      Result.extend (row_to_document (row))
    end

    l_sql.close
  end

log_audit_event (a_event: STRING; a_doc_id: INTEGER; a_details: STRING)
    -- Record audit trail entry
  local
    l_sql: SIMPLE_SQL
  do
    create l_sql.make (database_path)

    l_sql.execute_with_params (
      "INSERT INTO audit_log (event_type, document_id, user_name, details) VALUES (?, ?, ?, ?)",
      <<a_event, a_doc_id, current_user, a_details>>
    )

    l_sql.close
  end
```

**Data flow:** Operations -> SQL statements -> SQLite database -> Query results

### simple_json Integration

**Purpose:** Policy definitions, document metadata, configuration

**Usage:**
```eiffel
load_policy (a_path: STRING): RETENTION_POLICY
    -- Load policy from JSON file
  local
    l_json: SIMPLE_JSON
    l_obj: JSON_OBJECT
  do
    create l_json.make
    l_obj := l_json.parse_file (a_path)

    create Result.make
    if attached l_obj.object ("policy") as p then
      Result.name := p.string ("name")
      Result.description := p.string ("description")
      Result.regulation := p.string ("regulation")

      if attached p.object ("retention") as r then
        Result.retention_period := parse_period (r.string ("period"))
        Result.trigger_event := r.string ("trigger")
      end
    end
  end

serialize_metadata (a_doc: DOCUMENT_RECORD): STRING
    -- Serialize document metadata to JSON
  local
    l_json: SIMPLE_JSON
  do
    create l_json.make
    l_json.start_object
    l_json.add_string ("original_path", a_doc.original_path)
    l_json.add_string ("classification", a_doc.classification)
    l_json.add_string ("ingested_at", a_doc.ingested_at.formatted_out ("yyyy-mm-dd hh:mi:ss"))
    l_json.add_string ("retention_until", a_doc.retention_until.formatted_out ("yyyy-mm-dd"))
    l_json.add_string ("checksum", a_doc.checksum)
    if attached a_doc.custom_metadata as meta then
      l_json.add_object ("custom", meta)
    end
    l_json.end_object
    Result := l_json.to_string
  end
```

**Data flow:** JSON file -> Parse -> Policy/Metadata object | Object -> Serialize -> JSON string

### simple_hash Integration

**Purpose:** Document fingerprinting for integrity verification

**Usage:**
```eiffel
compute_document_checksum (a_path: STRING): STRING
    -- Compute SHA-256 checksum of document
  local
    l_hasher: SIMPLE_HASH
    l_content: STRING
  do
    create l_hasher.make
    l_content := file_utils.read_binary (a_path)
    Result := l_hasher.sha256 (l_content)
  end

verify_document_integrity (a_doc: DOCUMENT_RECORD): BOOLEAN
    -- Verify document hasn't been modified
  local
    l_zip: SIMPLE_ZIP
    l_content: detachable STRING
    l_current_hash: STRING
  do
    create l_zip.make
    l_content := l_zip.extract_entry (a_doc.archive_path, "document" + a_doc.extension)

    if attached l_content then
      l_current_hash := compute_hash (l_content)
      Result := l_current_hash.same_string (a_doc.checksum)

      if not Result then
        log_audit_event ("INTEGRITY_FAILURE", a_doc.id, "Checksum mismatch: expected " + a_doc.checksum + ", got " + l_current_hash)
      end
    end
  end
```

**Data flow:** Document content -> SHA-256 -> Checksum string

### simple_datetime Integration

**Purpose:** Retention period calculations

**Usage:**
```eiffel
calculate_retention_date (a_trigger_date: DATE_TIME; a_period: RETENTION_PERIOD): DATE_TIME
    -- Calculate when retention expires
  local
    l_dt: SIMPLE_DATETIME
  do
    create l_dt.make_from_datetime (a_trigger_date)

    inspect a_period.unit
    when "y" then
      Result := l_dt.add_years (a_period.value)
    when "m" then
      Result := l_dt.add_months (a_period.value)
    when "d" then
      Result := l_dt.add_days (a_period.value)
    end
  end

parse_period (a_period_string: STRING): RETENTION_PERIOD
    -- Parse "7y", "6m", "90d" format
  local
    l_value: INTEGER
    l_unit: STRING
  do
    create Result.make
    l_unit := a_period_string.substring (a_period_string.count, a_period_string.count)
    l_value := a_period_string.substring (1, a_period_string.count - 1).to_integer
    Result.value := l_value
    Result.unit := l_unit
  end
```

**Data flow:** Trigger date + Period -> Date calculation -> Retention end date

### simple_csv Integration

**Purpose:** Generate compliance reports in CSV format

**Usage:**
```eiffel
generate_compliance_report (a_from: DATE; a_to: DATE; a_output: STRING)
    -- Generate CSV compliance report
  local
    l_csv: SIMPLE_CSV
    l_docs: ARRAYED_LIST [DOCUMENT_RECORD]
  do
    create l_csv.make
    l_csv.set_headers (<<"Document ID", "Original Path", "Classification", "Policy", "Ingested", "Retention Until", "Status">>)

    l_docs := get_documents_in_period (a_from, a_to)

    across l_docs as d loop
      l_csv.add_row (<<
        d.id.out,
        d.original_path,
        d.classification,
        d.policy_name,
        d.ingested_at.formatted_out ("yyyy-mm-dd"),
        d.retention_until.formatted_out ("yyyy-mm-dd"),
        d.status
      >>)
    end

    l_csv.write_file (a_output)
  end
```

**Data flow:** Query results -> CSV formatting -> Report file

## Dependency Graph

```
retentionkeeper
    |
    +-- simple_archive (required)
    |       |
    |       +-- ISE etar
    |       +-- minizip-ng
    |
    +-- simple_sql (required)
    |       |
    |       +-- SQLite
    |
    +-- simple_json (required)
    |       |
    |       +-- ISE base
    |
    +-- simple_hash (required)
    |       |
    |       +-- OpenSSL / bcrypt
    |
    +-- simple_datetime (required)
    |       |
    |       +-- ISE time
    |
    +-- simple_csv (required)
    |       |
    |       +-- ISE base
    |
    +-- simple_file (required)
    |       |
    |       +-- ISE base
    |
    +-- simple_pdf (optional)
    +-- simple_email (optional)
    +-- simple_encryption (optional)
```

## ECF Configuration

```xml
<?xml version="1.0" encoding="ISO-8859-1"?>
<system xmlns="http://www.eiffel.com/developers/xml/configuration-1-22-0"
    name="retentionkeeper"
    uuid="XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX">

    <target name="retentionkeeper">
        <description>RetentionKeeper compliance archiver library</description>
        <root all_classes="true"/>
        <option warning="warning" syntax="provisional" manifest_array_type="mismatch_warning">
            <assertions precondition="true" postcondition="true" check="true" invariant="true"/>
        </option>

        <setting name="console_application" value="true"/>
        <setting name="dead_code_removal" value="all"/>

        <!-- simple_* ecosystem dependencies -->
        <library name="simple_archive" location="$SIMPLE_EIFFEL/simple_archive/simple_archive.ecf"/>
        <library name="simple_sql" location="$SIMPLE_EIFFEL/simple_sql/simple_sql.ecf"/>
        <library name="simple_json" location="$SIMPLE_EIFFEL/simple_json/simple_json.ecf"/>
        <library name="simple_hash" location="$SIMPLE_EIFFEL/simple_hash/simple_hash.ecf"/>
        <library name="simple_datetime" location="$SIMPLE_EIFFEL/simple_datetime/simple_datetime.ecf"/>
        <library name="simple_csv" location="$SIMPLE_EIFFEL/simple_csv/simple_csv.ecf"/>
        <library name="simple_file" location="$SIMPLE_EIFFEL/simple_file/simple_file.ecf"/>

        <!-- ISE base libraries -->
        <library name="base" location="$ISE_LIBRARY/library/base/base.ecf"/>
        <library name="time" location="$ISE_LIBRARY/library/time/time.ecf"/>

        <!-- Application source -->
        <cluster name="retentionkeeper" location=".\src\" recursive="true"/>
    </target>

    <target name="retentionkeeper_cli" extends="retentionkeeper">
        <description>RetentionKeeper CLI executable</description>
        <root class="RETKEEPER_CLI" feature="make"/>
        <setting name="executable_name" value="retkeeper"/>
    </target>

    <target name="retentionkeeper_tests" extends="retentionkeeper">
        <description>RetentionKeeper test suite</description>
        <root class="TEST_APP" feature="make"/>
        <library name="simple_testing" location="$SIMPLE_EIFFEL/simple_testing/simple_testing.ecf"/>
        <cluster name="tests" location=".\tests\" recursive="true"/>
    </target>
</system>
```
