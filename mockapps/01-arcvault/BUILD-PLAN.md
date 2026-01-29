# ArcVault - Build Plan

## Phase Overview

| Phase | Deliverable | Effort | Dependencies |
|-------|-------------|--------|--------------|
| Phase 1 | MVP CLI (backup/restore/list) | 3-4 days | simple_archive, simple_file, simple_json |
| Phase 2 | Full CLI (policy, verify, audit) | 3-4 days | Phase 1 + simple_hash, simple_datetime, simple_logger |
| Phase 3 | Polish (docs, edge cases, performance) | 2-3 days | Phase 2 complete |

---

## Phase 1: MVP

### Objective

Deliver a working backup archive manager that can create versioned backups, restore from archives, and list available backups. This MVP proves the core value proposition.

### Deliverables

1. **ARCVAULT_CLI** - Command-line interface with backup/restore/list commands
2. **ARCVAULT_ENGINE** - Core backup and restore operations
3. **ARCVAULT_CONFIG** - JSON configuration loading
4. **ARCVAULT_MANIFEST** - Basic manifest generation
5. **Basic CLI** - backup, restore, list, config commands

### Tasks

| Task | Description | Acceptance Criteria |
|------|-------------|---------------------|
| T1.1 | Create project structure and ECF | Project compiles with all dependencies |
| T1.2 | Implement ARCVAULT_CONFIG | Load/save JSON config, validate required fields |
| T1.3 | Implement ARCVAULT_ENGINE.create_backup | Create ZIP/TAR from source paths |
| T1.4 | Implement ARCVAULT_ENGINE.restore_backup | Extract archive to destination |
| T1.5 | Implement ARCVAULT_MANIFEST | Generate JSON manifest with entries |
| T1.6 | Implement ARCVAULT_CLI command parsing | Parse backup/restore/list/config commands |
| T1.7 | Implement version numbering | Auto-increment version for same backup name |
| T1.8 | Add text and JSON output formatting | --output text|json works for all commands |
| T1.9 | Write Phase 1 tests | All core operations have test coverage |
| T1.10 | Create sample config and README | User can start with examples |

### Test Cases

| Test | Input | Expected Output |
|------|-------|-----------------|
| Create backup from files | `arcvault backup --name test file1.txt file2.txt` | Archive created, manifest generated |
| Create backup from directory | `arcvault backup --name docs ./docs/` | All files in directory archived |
| List backups | `arcvault list` | All backups shown with dates, sizes |
| Restore full archive | `arcvault restore test_001.zip ./restore/` | All files extracted to destination |
| Restore specific file | `arcvault restore test_001.zip --file config.txt ./` | Single file extracted |
| Version increment | Create 3 backups with same name | Names: test_001, test_002, test_003 |
| JSON output | `arcvault list --output json` | Valid JSON array of backups |
| Config load | `arcvault --config custom.json backup ...` | Uses custom configuration |

### Phase 1 Classes

```eiffel
class ARCVAULT_CLI
    -- Command-line interface
feature
    make
    parse_arguments
    execute_command
    format_output
end

class ARCVAULT_ENGINE
    -- Core backup operations
feature
    create_backup (sources, destination, options): BACKUP_RESULT
    restore_backup (archive, destination, options): RESTORE_RESULT
    list_backups (pattern): ARRAYED_LIST [BACKUP_INFO]
end

class ARCVAULT_CONFIG
    -- Configuration management
feature
    load (path): BOOLEAN
    save (path): BOOLEAN
    base_path: STRING
    archive_format: STRING
    -- ... other settings
end

class ARCVAULT_MANIFEST
    -- Manifest generation
feature
    generate (backup_info): STRING
    parse (json_string): MANIFEST_DATA
    verify (archive, manifest): BOOLEAN
end
```

---

## Phase 2: Full Implementation

### Objective

Add retention policies, verification, deduplication tracking, and audit logging to create a complete backup management solution.

### Deliverables

1. **ARCVAULT_POLICY** - Retention policy engine with GFS (Grandfather-Father-Son)
2. **ARCVAULT_DEDUP** - Content-aware deduplication tracking
3. **ARCVAULT_AUDITOR** - Audit trail logging and reporting
4. **ARCVAULT_VERIFIER** - Archive integrity verification
5. **Full CLI** - policy, cleanup, verify, audit commands

### Tasks

| Task | Description | Acceptance Criteria |
|------|-------------|---------------------|
| T2.1 | Implement ARCVAULT_POLICY | Define, evaluate, apply retention policies |
| T2.2 | Implement policy commands | Create, list, show, delete policies |
| T2.3 | Implement cleanup command | Apply policies, show dry-run, confirm deletion |
| T2.4 | Implement ARCVAULT_DEDUP | Hash files, track duplicates, report savings |
| T2.5 | Add dedup tracking to backup | Compute hashes, include in manifest |
| T2.6 | Implement ARCVAULT_VERIFIER | Verify archive integrity against manifest |
| T2.7 | Implement verify command | Quick check, checksum verify, manifest verify |
| T2.8 | Implement ARCVAULT_AUDITOR | Log all operations with timestamps |
| T2.9 | Implement audit command | Query logs, filter, export to CSV |
| T2.10 | Add status command | Show backup health, policy status, storage usage |
| T2.11 | Write Phase 2 tests | Policy, dedup, audit operations tested |

### Test Cases

| Test | Input | Expected Output |
|------|-------|-----------------|
| Create policy | `arcvault policy create default --keep-daily 7 --keep-weekly 4` | Policy saved |
| List policies | `arcvault policy list` | All policies displayed |
| Dry-run cleanup | `arcvault cleanup --dry-run` | Shows what would be deleted |
| Execute cleanup | `arcvault cleanup --policy default` | Old backups removed per policy |
| Verify archive | `arcvault verify backup_001.zip` | Integrity check passes/fails |
| Verify with manifest | `arcvault verify backup_001.zip --manifest` | Checksum verification |
| View audit log | `arcvault audit --from 2026-01-01` | Operations listed with details |
| Export audit | `arcvault audit --export audit.csv` | CSV file created |
| Dedup report | `arcvault backup --name test ./data/` | Shows duplicate detection stats |
| Status overview | `arcvault status` | Backup count, storage used, policy compliance |

### Phase 2 Classes

```eiffel
class ARCVAULT_POLICY
    -- Retention policy management
feature
    create_policy (name, rules): BOOLEAN
    evaluate (backup, policy): BOOLEAN  -- Keep or delete?
    apply (policy): CLEANUP_RESULT
    list_policies: ARRAYED_LIST [POLICY_INFO]
end

class ARCVAULT_DEDUP
    -- Deduplication tracking
feature
    compute_hashes (files): HASH_TABLE [STRING, STRING]
    find_duplicates (hashes): ARRAYED_LIST [DUPLICATE_GROUP]
    generate_report (backup): DEDUP_REPORT
end

class ARCVAULT_VERIFIER
    -- Archive verification
feature
    quick_verify (archive): BOOLEAN
    checksum_verify (archive): VERIFICATION_RESULT
    manifest_verify (archive, manifest): VERIFICATION_RESULT
end

class ARCVAULT_AUDITOR
    -- Audit trail
feature
    log_operation (op_type, details)
    query (from_date, to_date, op_filter): ARRAYED_LIST [AUDIT_ENTRY]
    export_csv (entries, path): BOOLEAN
end
```

---

## Phase 3: Production Polish

### Objective

Harden the application for production use with comprehensive error handling, documentation, and performance optimization.

### Deliverables

- Error handling hardening
- Help documentation
- Configuration validation
- Performance optimization
- Edge case handling
- Installation documentation

### Tasks

| Task | Description | Acceptance Criteria |
|------|-------------|---------------------|
| T3.1 | Comprehensive error messages | All errors have actionable messages |
| T3.2 | Input validation hardening | Invalid inputs caught with helpful errors |
| T3.3 | Progress indicators | Long operations show progress |
| T3.4 | Signal handling | Ctrl+C gracefully aborts, cleans up temp files |
| T3.5 | Large file handling | Test with multi-GB archives |
| T3.6 | Performance profiling | Identify and fix bottlenecks |
| T3.7 | Complete help text | All commands have --help with examples |
| T3.8 | README and quick start | User can install and use in 5 minutes |
| T3.9 | Man page generation | Unix man page available |
| T3.10 | Release packaging | Windows installer, Linux package |

### Edge Cases to Handle

| Scenario | Handling |
|----------|----------|
| Source file deleted during backup | Log warning, continue with remaining files |
| Disk full during archive creation | Abort cleanly, remove partial archive |
| Archive file locked | Retry with backoff, then error |
| Symbolic links in source | Follow links or skip (configurable) |
| Very long file paths | Handle Windows MAX_PATH limitations |
| Unicode filenames | Proper UTF-8 handling throughout |
| Empty directories | Include in archive (configurable) |
| Permission denied on restore | Log error, continue with other files |

---

## ECF Target Structure

```xml
<!-- Library target (reusable) -->
<target name="arcvault">
    <description>ArcVault backup manager library</description>
    <root all_classes="true"/>
    <library name="simple_archive" location="..."/>
    <library name="simple_file" location="..."/>
    <library name="simple_hash" location="..."/>
    <library name="simple_json" location="..."/>
    <library name="simple_datetime" location="..."/>
    <library name="simple_logger" location="..."/>
    <cluster name="arcvault" location=".\src\"/>
</target>

<!-- CLI executable target -->
<target name="arcvault_cli" extends="arcvault">
    <description>ArcVault CLI executable</description>
    <root class="ARCVAULT_CLI" feature="make"/>
    <setting name="executable_name" value="arcvault"/>
</target>

<!-- Test target -->
<target name="arcvault_tests" extends="arcvault">
    <description>ArcVault test suite</description>
    <root class="TEST_APP" feature="make"/>
    <library name="simple_testing" location="$SIMPLE_EIFFEL/simple_testing/simple_testing.ecf"/>
    <cluster name="tests" location=".\tests\"/>
</target>
```

## Build Commands

```bash
# Compile CLI (workbench)
/d/prod/ec.sh -batch -config arcvault.ecf -target arcvault_cli -c_compile

# Compile CLI (finalized)
/d/prod/ec.sh -batch -config arcvault.ecf -target arcvault_cli -finalize -c_compile

# Run tests
/d/prod/ec.sh -batch -config arcvault.ecf -target arcvault_tests -c_compile
./EIFGENs/arcvault_tests/W_code/arcvault.exe

# Run finalized tests
/d/prod/ec.sh -batch -config arcvault.ecf -target arcvault_tests -finalize -c_compile
./EIFGENs/arcvault_tests/F_code/arcvault.exe
```

## Success Criteria

| Criterion | Measure | Target |
|-----------|---------|--------|
| Compiles | Zero errors, zero warnings | 100% |
| Tests pass | All tests pass | 100% |
| CLI functional | All commands work | 100% |
| Documentation | README complete, help text | Yes |
| Performance | 1GB backup in < 60 seconds | Yes |
| Error handling | All edge cases handled | 100% |

## Estimated Total Effort

| Phase | Effort | Cumulative |
|-------|--------|------------|
| Phase 1 (MVP) | 3-4 days | 3-4 days |
| Phase 2 (Full) | 3-4 days | 6-8 days |
| Phase 3 (Polish) | 2-3 days | 8-11 days |

**Total: 8-11 days for production-ready CLI application**
