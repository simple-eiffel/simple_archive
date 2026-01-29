# RetentionKeeper - Build Plan

## Phase Overview

| Phase | Deliverable | Effort | Dependencies |
|-------|-------------|--------|--------------|
| Phase 1 | MVP CLI (ingest, search, policy) | 4-5 days | simple_archive, simple_sql, simple_json, simple_hash, simple_datetime, simple_file |
| Phase 2 | Full CLI (hold, disposition, report) | 3-4 days | Phase 1 + simple_csv |
| Phase 3 | Polish (audit, certificates, compliance) | 3-4 days | Phase 2 complete |

---

## Phase 1: MVP

### Objective

Deliver a working compliance archiver that can ingest documents with retention policies, search the archive, and retrieve documents. This MVP proves the core value proposition of policy-driven retention.

### Deliverables

1. **RETKEEPER_CLI** - Command-line interface with ingest/search/retrieve/policy commands
2. **RETKEEPER_POLICY** - Retention policy management
3. **RETKEEPER_ARCHIVER** - Document ingestion and retrieval
4. **RETKEEPER_DATABASE** - SQLite storage for metadata
5. **Basic CLI** - ingest, search, retrieve, policy commands

### Tasks

| Task | Description | Acceptance Criteria |
|------|-------------|---------------------|
| T1.1 | Create project structure and ECF | Project compiles with all dependencies |
| T1.2 | Implement database schema | All tables created, migrations work |
| T1.3 | Implement RETKEEPER_POLICY | Create, list, show, delete policies |
| T1.4 | Implement policy command | CRUD operations for policies |
| T1.5 | Implement RETKEEPER_ARCHIVER.ingest | Archive document with metadata |
| T1.6 | Implement retention calculation | Calculate retention date from policy |
| T1.7 | Implement ingest command | Ingest with policy assignment |
| T1.8 | Implement RETKEEPER_ARCHIVER.search | Query documents by criteria |
| T1.9 | Implement search command | Search by class, policy, date, status |
| T1.10 | Implement RETKEEPER_ARCHIVER.retrieve | Extract document from archive |
| T1.11 | Implement retrieve command | Retrieve with metadata option |
| T1.12 | Write Phase 1 tests | All core operations tested |
| T1.13 | Create sample policies | SEC, HIPAA, General templates |

### Test Cases

| Test | Input | Expected Output |
|------|-------|-----------------|
| Create policy | `retkeeper policy create sec-records --retention 7y` | Policy saved to database |
| List policies | `retkeeper policy list` | All policies shown |
| Ingest document | `retkeeper ingest --policy sec-records invoice.pdf` | Document archived with retention date |
| Search by class | `retkeeper search --class financial` | Matching documents listed |
| Search by date | `retkeeper search --from 2026-01-01` | Documents from date |
| Retrieve document | `retkeeper retrieve doc_001 ./output/` | Document extracted |
| Retention calculation | Ingest with 7y policy | retention_until = ingest_date + 7 years |
| Checksum verification | Retrieve and verify | Checksum matches original |

### Phase 1 Classes

```eiffel
class RETKEEPER_CLI
    -- Command-line interface
feature
    make
    parse_arguments
    execute_ingest
    execute_search
    execute_retrieve
    execute_policy
    format_output
end

class RETKEEPER_POLICY
    -- Retention policy management
feature
    create_policy (name, retention_period, trigger): BOOLEAN
    get_policy (name): detachable RETENTION_POLICY
    list_policies: ARRAYED_LIST [RETENTION_POLICY]
    delete_policy (name): BOOLEAN
    calculate_retention (policy, trigger_date): DATE_TIME
end

class RETKEEPER_ARCHIVER
    -- Document archival operations
feature
    ingest (source, policy, classification): INGEST_RESULT
    search (criteria): ARRAYED_LIST [DOCUMENT_RECORD]
    retrieve (doc_id, destination): BOOLEAN
    verify_integrity (doc_id): BOOLEAN
end

class RETKEEPER_DATABASE
    -- SQLite storage
feature
    setup_schema
    execute (sql): BOOLEAN
    query (sql): ARRAYED_LIST [SQL_ROW]
    -- Specific operations
    save_document (doc): INTEGER
    get_document (id): detachable DOCUMENT_RECORD
    save_policy (policy): INTEGER
    get_policy (name): detachable RETENTION_POLICY
end
```

---

## Phase 2: Full Implementation

### Objective

Add legal hold management, disposition workflow, and compliance reporting to create a complete retention management solution.

### Deliverables

1. **RETKEEPER_HOLD** - Legal hold management
2. **RETKEEPER_DISPOSITION** - Disposition workflow with approvals
3. **RETKEEPER_REPORTER** - Compliance report generation
4. **Full CLI** - hold, disposition, report commands

### Tasks

| Task | Description | Acceptance Criteria |
|------|-------------|---------------------|
| T2.1 | Implement RETKEEPER_HOLD | Create, apply, release legal holds |
| T2.2 | Implement hold command | Manage legal holds via CLI |
| T2.3 | Add hold blocking to disposition | Documents on hold cannot be disposed |
| T2.4 | Implement RETKEEPER_DISPOSITION | Schedule, approve, execute dispositions |
| T2.5 | Implement disposition command | Pending, approve, reject, execute |
| T2.6 | Add disposition certificate | Generate proof of disposition |
| T2.7 | Implement RETKEEPER_REPORTER | Generate compliance reports |
| T2.8 | Implement report command | Various report types |
| T2.9 | Add CSV export for reports | Export to CSV format |
| T2.10 | Implement watch mode for ingest | Monitor directory for new files |
| T2.11 | Write Phase 2 tests | Hold, disposition, reporting tested |

### Test Cases

| Test | Input | Expected Output |
|------|-------|-----------------|
| Create legal hold | `retkeeper hold create smith-v-acme --matter "Case 2026-001"` | Hold created |
| Apply hold to documents | `retkeeper hold apply smith-v-acme --scope "class:financial"` | Documents held |
| Held document blocks disposition | Attempt to dispose held document | Error: Document under hold |
| Release hold | `retkeeper hold release smith-v-acme` | Hold released, documents disposable |
| List pending disposition | `retkeeper disposition pending` | Documents past retention listed |
| Approve disposition | `retkeeper disposition approve doc_001` | Disposition approved |
| Execute disposition | `retkeeper disposition execute` | Approved documents deleted |
| Generate compliance report | `retkeeper report compliance --format csv` | CSV report generated |
| Generate holds report | `retkeeper report holds` | Active holds listed |
| Watch directory | `retkeeper ingest --watch ./incoming/` | New files auto-ingested |

### Phase 2 Classes

```eiffel
class RETKEEPER_HOLD
    -- Legal hold management
feature
    create_hold (name, matter, custodian): INTEGER
    apply_hold (hold_id, document_ids): INTEGER
    apply_hold_by_query (hold_id, search_query): INTEGER
    release_hold (hold_id): BOOLEAN
    is_document_held (doc_id): BOOLEAN
    list_holds: ARRAYED_LIST [LEGAL_HOLD]
end

class RETKEEPER_DISPOSITION
    -- Disposition workflow
feature
    get_pending: ARRAYED_LIST [DOCUMENT_RECORD]
    schedule_disposition (doc_id): BOOLEAN
    approve (doc_id, approver): BOOLEAN
    reject (doc_id, reason): BOOLEAN
    execute_approved: DISPOSITION_RESULT
    generate_certificate (doc_id): STRING
end

class RETKEEPER_REPORTER
    -- Compliance reporting
feature
    compliance_report (from_date, to_date): REPORT_DATA
    retention_report: REPORT_DATA
    holds_report: REPORT_DATA
    disposition_report (from_date, to_date): REPORT_DATA
    export_csv (report, path): BOOLEAN
end
```

---

## Phase 3: Production Polish

### Objective

Harden for production use with comprehensive audit trails, regulatory templates, and compliance features.

### Deliverables

- Complete audit trail with all operations
- Pre-built regulatory policy templates
- Disposition certificates (PDF)
- Email notifications
- Advanced compliance reporting

### Tasks

| Task | Description | Acceptance Criteria |
|------|-------------|---------------------|
| T3.1 | Implement RETKEEPER_AUDITOR | Complete audit trail logging |
| T3.2 | Implement audit command | Query and export audit logs |
| T3.3 | Add audit to all operations | Every operation logged |
| T3.4 | Create regulatory templates | SEC, HIPAA, SOX, GDPR templates |
| T3.5 | Add PDF certificate generation | Disposition certificates as PDF |
| T3.6 | Add email notifications | Alerts for key events |
| T3.7 | Implement chain of custody | Track document access |
| T3.8 | Comprehensive error handling | All errors properly handled |
| T3.9 | Documentation and guides | User guide, compliance guide |
| T3.10 | Release packaging | Windows installer, Linux package |

### Regulatory Templates

| Regulation | Retention Period | Trigger | Notes |
|------------|------------------|---------|-------|
| SEC 17a-4 | 7 years | Creation | Financial records |
| HIPAA | 6 years | Last use | PHI records |
| SOX | 7 years | Fiscal year end | Audit records |
| GDPR | Varies | Purpose end | Personal data |
| General | 3 years | Creation | Business records |

### Edge Cases to Handle

| Scenario | Handling |
|----------|----------|
| Document already archived | Skip with warning |
| Source file locked | Retry or skip |
| Database locked | Retry with backoff |
| Archive corruption | Quarantine, alert |
| Disposition of held document | Block with error |
| Policy applied to existing docs | Recalculate retention |
| Bulk ingest (thousands) | Batch processing, progress |
| Unicode filenames | Proper UTF-8 handling |

---

## ECF Target Structure

```xml
<!-- Library target (reusable) -->
<target name="retentionkeeper">
    <description>RetentionKeeper compliance archiver library</description>
    <root all_classes="true"/>
    <library name="simple_archive" location="..."/>
    <library name="simple_sql" location="..."/>
    <library name="simple_json" location="..."/>
    <library name="simple_hash" location="..."/>
    <library name="simple_datetime" location="..."/>
    <library name="simple_csv" location="..."/>
    <library name="simple_file" location="..."/>
    <cluster name="retentionkeeper" location=".\src\"/>
</target>

<!-- CLI executable target -->
<target name="retentionkeeper_cli" extends="retentionkeeper">
    <description>RetentionKeeper CLI executable</description>
    <root class="RETKEEPER_CLI" feature="make"/>
    <setting name="executable_name" value="retkeeper"/>
</target>

<!-- Test target -->
<target name="retentionkeeper_tests" extends="retentionkeeper">
    <description>RetentionKeeper test suite</description>
    <root class="TEST_APP" feature="make"/>
    <library name="simple_testing" location="$SIMPLE_EIFFEL/simple_testing/simple_testing.ecf"/>
    <cluster name="tests" location=".\tests\"/>
</target>
```

## Build Commands

```bash
# Compile CLI (workbench)
/d/prod/ec.sh -batch -config retentionkeeper.ecf -target retentionkeeper_cli -c_compile

# Compile CLI (finalized)
/d/prod/ec.sh -batch -config retentionkeeper.ecf -target retentionkeeper_cli -finalize -c_compile

# Run tests
/d/prod/ec.sh -batch -config retentionkeeper.ecf -target retentionkeeper_tests -c_compile
./EIFGENs/retentionkeeper_tests/W_code/retkeeper.exe
```

## Success Criteria

| Criterion | Measure | Target |
|-----------|---------|--------|
| Compiles | Zero errors, zero warnings | 100% |
| Tests pass | All tests pass | 100% |
| CLI functional | All commands work | 100% |
| Audit complete | All operations logged | 100% |
| Documentation | User guide complete | Yes |
| Compliance | Passes mock audit | Yes |

## Estimated Total Effort

| Phase | Effort | Cumulative |
|-------|--------|------------|
| Phase 1 (MVP) | 4-5 days | 4-5 days |
| Phase 2 (Full) | 3-4 days | 7-9 days |
| Phase 3 (Polish) | 3-4 days | 10-13 days |

**Total: 10-13 days for production-ready CLI application**
