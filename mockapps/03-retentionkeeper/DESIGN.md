# RetentionKeeper - Technical Design

## Architecture

### Component Overview

```
+-------------------------------------------------------------+
|                     RetentionKeeper                          |
+-------------------------------------------------------------+
|  CLI Interface Layer                                         |
|    - Argument parsing                                        |
|    - Command routing                                         |
|    - Interactive prompts (dispositions)                      |
|    - Output formatting (text, json, csv)                     |
+-------------------------------------------------------------+
|  Policy Engine Layer                                         |
|    - Policy definition and evaluation                        |
|    - Document classification                                 |
|    - Retention calculation                                   |
|    - Legal hold management                                   |
+-------------------------------------------------------------+
|  Archive Management Layer                                    |
|    - Document ingestion                                      |
|    - Archive creation and organization                       |
|    - Search and retrieval                                    |
|    - Disposition workflow                                    |
+-------------------------------------------------------------+
|  Data & Audit Layer                                          |
|    - Policy database (simple_sql)                            |
|    - Audit trail logging                                     |
|    - Compliance reporting                                    |
|    - Document fingerprinting                                 |
+-------------------------------------------------------------+
|  Integration Layer                                           |
|    - Archive operations (simple_archive)                     |
|    - File handling (simple_file)                             |
|    - Metadata (simple_json)                                  |
|    - Dates (simple_datetime)                                 |
+-------------------------------------------------------------+
```

### Class Design

| Class | Responsibility | Key Features |
|-------|----------------|--------------|
| RETKEEPER_CLI | Command-line interface | parse_args, execute, format_output |
| RETKEEPER_POLICY | Retention policy definition | load, evaluate, calculate_retention_date |
| RETKEEPER_CLASSIFIER | Document classification | classify, detect_type, extract_metadata |
| RETKEEPER_ARCHIVER | Document archival operations | ingest, archive, retrieve, search |
| RETKEEPER_HOLD | Legal hold management | create_hold, apply_hold, release_hold |
| RETKEEPER_DISPOSITION | Disposition workflow | schedule, approve, execute, certify |
| RETKEEPER_AUDITOR | Audit trail and reporting | log_event, generate_report, export |
| RETKEEPER_DATABASE | Policy and metadata storage | queries via simple_sql |

### Command Structure

```bash
retkeeper <command> [options] [arguments]

Commands:
  ingest        Ingest documents into the archive
  search        Search archived documents
  retrieve      Retrieve documents from archive
  policy        Manage retention policies
  hold          Manage legal holds
  disposition   Manage document disposition
  report        Generate compliance reports
  audit         View and export audit logs
  config        Manage configuration

Ingest Command:
  retkeeper ingest [options] <source> [<source>...]
    --policy POLICY      Apply retention policy
    --class CLASS        Document classification
    --metadata FILE      Metadata file (JSON)
    --recursive          Process directories recursively
    --watch              Watch directory for new files

Search Command:
  retkeeper search [options] <query>
    --class CLASS        Filter by classification
    --policy POLICY      Filter by policy
    --from DATE          Documents from date
    --to DATE            Documents to date
    --status STATUS      Filter by status (active|held|pending|disposed)
    --limit N            Limit results

Retrieve Command:
  retkeeper retrieve [options] <document-id> [<destination>]
    --export             Export for legal discovery
    --include-metadata   Include metadata JSON
    --chain-of-custody   Generate chain of custody

Policy Command:
  retkeeper policy <subcommand> [options]
    list                 List all policies
    show POLICY          Show policy details
    create POLICY        Create new policy
    import FILE          Import policies from file
    export FILE          Export policies to file
    --name NAME          Policy name
    --retention PERIOD   Retention period (e.g., 7y, 6m, 90d)
    --trigger EVENT      Retention trigger (creation|modification|custom)
    --class CLASS        Document classes covered
    --regulation REG     Regulatory basis (SEC, HIPAA, etc.)

Hold Command:
  retkeeper hold <subcommand> [options]
    create NAME          Create new legal hold
    apply HOLD DOC-ID    Apply hold to document
    release HOLD         Release legal hold
    list                 List active holds
    --matter MATTER      Legal matter reference
    --custodian NAME     Custodian name
    --scope QUERY        Documents to hold (search query)

Disposition Command:
  retkeeper disposition [options]
    pending              Show documents pending disposition
    approve ID           Approve disposition
    reject ID            Reject disposition
    execute              Execute approved dispositions
    certificate ID       Generate disposition certificate
    --dry-run            Show what would be disposed
    --batch FILE         Batch approve from file

Report Command:
  retkeeper report [options] <report-type>
    compliance           Overall compliance status
    retention            Retention schedule summary
    holds                Active legal holds
    disposition          Disposition activity
    audit-trail          Audit trail summary
    --from DATE          Report period start
    --to DATE            Report period end
    --format text|csv|pdf Output format
    --output FILE        Output file

Global Options:
  --config FILE          Configuration file
  --database FILE        Database file
  --output FORMAT        Output format (text|json|csv)
  --verbose              Verbose output
  --help                 Show help
  --version              Show version
```

### Data Model

```
+------------------+     +------------------+     +------------------+
|     DOCUMENT     |     |      POLICY      |     |   LEGAL_HOLD     |
+------------------+     +------------------+     +------------------+
| id (PK)          |     | id (PK)          |     | id (PK)          |
| original_path    |     | name             |     | name             |
| archive_path     |     | description      |     | matter           |
| classification   |---->| retention_period |     | custodian        |
| policy_id (FK)   |     | trigger_event    |     | scope_query      |
| ingested_at      |     | regulation       |     | created_at       |
| retention_until  |     | created_at       |     | released_at      |
| status           |     | active           |     | active           |
| checksum         |     +------------------+     +------------------+
| metadata (JSON)  |            ^                        |
+------------------+            |                        |
        |                       |                        |
        v                       |                        v
+------------------+     +------------------+     +------------------+
|   AUDIT_LOG      |     | DOCUMENT_POLICY  |     |  DOCUMENT_HOLD   |
+------------------+     +------------------+     +------------------+
| id (PK)          |     | document_id (FK) |     | document_id (FK) |
| timestamp        |     | policy_id (FK)   |     | hold_id (FK)     |
| event_type       |     +------------------+     | applied_at       |
| document_id (FK) |                              +------------------+
| user             |
| details (JSON)   |     +------------------+
+------------------+     |   DISPOSITION    |
                         +------------------+
                         | id (PK)          |
                         | document_id (FK) |
                         | scheduled_at     |
                         | approved_by      |
                         | approved_at      |
                         | executed_at      |
                         | certificate      |
                         +------------------+
```

### Retention Policy Format

```json
{
  "policy": {
    "name": "sec-financial-records",
    "description": "SEC Rule 17a-4 financial records retention",
    "regulation": "SEC 17a-4",
    "retention": {
      "period": "7y",
      "trigger": "creation",
      "extensions": [
        {"condition": "under_audit", "extend": "until_cleared"},
        {"condition": "litigation_hold", "extend": "indefinite"}
      ]
    },
    "classification": {
      "types": ["financial-statement", "trade-record", "correspondence"],
      "patterns": ["*.xlsx", "*.pdf", "trade_*.csv"],
      "metadata_rules": [
        {"field": "department", "equals": "finance"}
      ]
    },
    "disposition": {
      "requires_approval": true,
      "approvers": ["compliance_officer", "legal_counsel"],
      "certificate_required": true,
      "notification": ["records_manager@company.com"]
    }
  }
}
```

### Archive Structure

```
/archive/
├── 2026/
│   ├── 01/
│   │   ├── financial/
│   │   │   ├── doc_001.zip       # Archived document
│   │   │   ├── doc_001.meta.json # Metadata
│   │   │   └── doc_001.audit.log # Document audit trail
│   │   └── hr/
│   │       └── ...
│   └── 02/
│       └── ...
├── holds/
│   └── smith-v-acme/
│       └── ... (symlinks to held documents)
├── pending-disposition/
│   └── ...
└── certificates/
    └── disp_2026_001.pdf
```

### Error Handling

| Error Type | Handling | User Message |
|------------|----------|--------------|
| Policy not found | Abort | "Error: Policy not found: {name}" |
| Document on hold | Prevent disposition | "Error: Document under legal hold: {hold_name}" |
| Retention not expired | Prevent disposition | "Error: Retention period not expired until {date}" |
| Database error | Log and abort | "Error: Database error: {details}" |
| Archive corrupt | Log, quarantine | "Error: Archive verification failed. Document quarantined." |
| Permission denied | Report | "Error: Insufficient permissions for {operation}" |

## GUI/TUI Future Path

**CLI foundation enables:**
- Scheduled jobs via cron/Task Scheduler
- Integration with document management systems
- Scripted bulk operations
- JSON output for dashboards

**TUI possibilities:**
- Policy editor with rule builder
- Document browser with metadata
- Disposition approval workflow
- Audit log viewer

**GUI possibilities:**
- Retention calendar visualization
- Policy compliance dashboard
- Legal hold management portal
- Compliance report generator
