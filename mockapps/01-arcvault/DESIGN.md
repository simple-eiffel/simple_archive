# ArcVault - Technical Design

## Architecture

### Component Overview

```
+-------------------------------------------------------------+
|                        ArcVault                              |
+-------------------------------------------------------------+
|  CLI Interface Layer                                         |
|    - Argument parsing (simple_cli)                           |
|    - Command routing                                         |
|    - Output formatting (text, json, csv)                     |
+-------------------------------------------------------------+
|  Business Logic Layer                                        |
|    - Backup job orchestration                                |
|    - Version management                                      |
|    - Retention policy engine                                 |
|    - Deduplication tracker                                   |
+-------------------------------------------------------------+
|  Data Layer                                                  |
|    - Archive operations (simple_archive)                     |
|    - File system access (simple_file)                        |
|    - Manifest storage (simple_json)                          |
|    - Audit logging (simple_logger)                           |
+-------------------------------------------------------------+
|  Integration Layer                                           |
|    - Content hashing (simple_hash)                           |
|    - Date calculations (simple_datetime)                     |
|    - Configuration (simple_json)                             |
+-------------------------------------------------------------+
```

### Class Design

| Class | Responsibility | Key Features |
|-------|----------------|--------------|
| ARCVAULT_CLI | Command-line interface | parse_args, route_command, format_output |
| ARCVAULT_ENGINE | Core backup orchestration | create_backup, restore_backup, verify_backup |
| ARCVAULT_CONFIG | Configuration management | load_config, validate_config, save_config |
| ARCVAULT_POLICY | Retention policy engine | evaluate_retention, apply_policy, schedule_cleanup |
| ARCVAULT_MANIFEST | Archive manifest management | create_manifest, verify_manifest, update_manifest |
| ARCVAULT_DEDUP | Deduplication tracker | compute_hashes, track_duplicates, report_savings |
| ARCVAULT_AUDITOR | Audit trail management | log_operation, generate_report, export_audit |
| ARCVAULT_VERSION | Version management | increment_version, list_versions, get_latest |

### Command Structure

```bash
arcvault <command> [options] [arguments]

Commands:
  backup        Create a new backup archive
  restore       Restore files from a backup archive
  list          List backup archives and their contents
  verify        Verify archive integrity
  policy        Manage retention policies
  cleanup       Apply retention policies and remove old backups
  audit         View and export audit logs
  config        Manage configuration
  status        Show backup status and statistics

Backup Command:
  arcvault backup [options] <source> [<source>...]
    --name NAME           Backup name/identifier
    --dest DIR            Destination directory for archives
    --format tar|zip      Archive format (default: zip)
    --manifest            Generate manifest file
    --verify              Verify after creation
    --retention POLICY    Apply retention policy name

Restore Command:
  arcvault restore [options] <archive> [<destination>]
    --file FILE           Extract specific file only
    --list                List contents without extracting
    --verify              Verify before extraction

List Command:
  arcvault list [options] [<pattern>]
    --versions            Show version history
    --size                Include size information
    --date                Include date information
    --format text|json    Output format

Verify Command:
  arcvault verify [options] <archive>
    --manifest            Verify against manifest
    --checksum            Verify content checksums
    --quick               Quick validation only

Policy Command:
  arcvault policy <subcommand> [options]
    list                  List all policies
    show POLICY           Show policy details
    create POLICY         Create new policy
    delete POLICY         Delete policy
    --keep-daily N        Keep N daily backups
    --keep-weekly N       Keep N weekly backups
    --keep-monthly N      Keep N monthly backups
    --keep-yearly N       Keep N yearly backups
    --max-age DAYS        Maximum retention in days

Cleanup Command:
  arcvault cleanup [options]
    --dry-run             Show what would be deleted
    --policy POLICY       Use specific policy
    --force               Skip confirmation

Audit Command:
  arcvault audit [options]
    --from DATE           Start date for audit
    --to DATE             End date for audit
    --operation OP        Filter by operation type
    --export FILE         Export to CSV file

Global Options:
  --config FILE          Configuration file path
  --output FORMAT        Output format (text|json|csv)
  --verbose              Verbose output
  --quiet                Suppress non-error output
  --help                 Show help
  --version              Show version
```

### Data Flow

```
Source Files --> Collect --> Hash --> Archive --> Store --> Log
                    |          |         |          |        |
                    v          v         v          v        v
              Validation  Dedup     Manifest   Version   Audit
                          Check      Gen       Tracking  Trail
```

### Configuration Schema

```json
{
  "arcvault": {
    "version": "1.0",
    "storage": {
      "base_path": "/backups",
      "archive_format": "zip",
      "compression_level": 6
    },
    "versioning": {
      "enabled": true,
      "max_versions": 100,
      "naming_pattern": "{name}_{date}_{version}"
    },
    "deduplication": {
      "enabled": true,
      "algorithm": "sha256",
      "track_only": true
    },
    "policies": {
      "default": {
        "keep_daily": 7,
        "keep_weekly": 4,
        "keep_monthly": 12,
        "keep_yearly": 3,
        "max_age_days": 1095
      }
    },
    "audit": {
      "enabled": true,
      "log_path": "/var/log/arcvault",
      "retention_days": 365
    },
    "notifications": {
      "on_failure": true,
      "on_cleanup": true
    }
  }
}
```

### Manifest File Format

```json
{
  "manifest_version": "1.0",
  "archive_name": "server-backup_2026-01-24_001",
  "archive_path": "/backups/server-backup_2026-01-24_001.zip",
  "created_at": "2026-01-24T10:30:00Z",
  "created_by": "arcvault/1.0",
  "source_paths": ["/etc", "/var/www"],
  "archive_checksum": "sha256:abc123...",
  "archive_size_bytes": 1048576,
  "entry_count": 150,
  "entries": [
    {
      "path": "etc/nginx/nginx.conf",
      "size": 2048,
      "checksum": "sha256:def456...",
      "modified": "2026-01-20T15:00:00Z"
    }
  ],
  "deduplication": {
    "total_source_bytes": 2097152,
    "unique_bytes": 1048576,
    "duplicate_bytes": 1048576,
    "savings_percent": 50.0
  }
}
```

### Error Handling

| Error Type | Handling | User Message |
|------------|----------|--------------|
| Source not found | Abort with list of missing | "Error: Source path not found: {path}" |
| Destination full | Abort with space info | "Error: Insufficient space ({needed} needed, {available} available)" |
| Archive corrupt | Report and suggest recovery | "Error: Archive verification failed. Run 'arcvault verify --repair'" |
| Permission denied | Report specific path | "Error: Permission denied: {path}" |
| Policy violation | Warn but continue | "Warning: Archive exceeds policy limits" |
| Config invalid | List validation errors | "Error: Configuration invalid: {details}" |

## GUI/TUI Future Path

**CLI foundation enables:**
- All operations available via CLI commands
- JSON output mode for programmatic access
- Exit codes for script integration
- Streaming output for progress monitoring

**TUI possibilities:**
- Interactive backup job configuration
- Real-time backup progress display
- Archive browser with content preview
- Retention calendar visualization

**GUI possibilities:**
- Backup scheduler with calendar interface
- Storage usage dashboard
- Version timeline viewer
- Policy editor with visual rules
