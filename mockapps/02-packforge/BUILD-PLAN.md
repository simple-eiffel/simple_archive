# PackForge - Build Plan

## Phase Overview

| Phase | Deliverable | Effort | Dependencies |
|-------|-------------|--------|--------------|
| Phase 1 | MVP CLI (build, validate, init) | 3-4 days | simple_archive, simple_file, simple_json, simple_hash |
| Phase 2 | Full CLI (verify, inspect, diff, checksums) | 2-3 days | Phase 1 + simple_template, simple_uuid, simple_datetime |
| Phase 3 | Polish (docs, signing, performance) | 2-3 days | Phase 2 complete |

---

## Phase 1: MVP

### Objective

Deliver a working package builder that can read a manifest, collect files, validate them, and create a distribution package with checksums. This MVP proves the core value proposition of reproducible, verifiable packages.

### Deliverables

1. **PACKFORGE_CLI** - Command-line interface with build/validate/init commands
2. **PACKFORGE_MANIFEST** - JSON manifest parsing and validation
3. **PACKFORGE_COLLECTOR** - File collection with glob support
4. **PACKFORGE_BUILDER** - Package assembly and compression
5. **Basic CLI** - build, validate, init commands

### Tasks

| Task | Description | Acceptance Criteria |
|------|-------------|---------------------|
| T1.1 | Create project structure and ECF | Project compiles with all dependencies |
| T1.2 | Implement PACKFORGE_MANIFEST | Parse JSON manifest, validate structure |
| T1.3 | Implement PACKFORGE_COLLECTOR | Collect files from patterns, verify existence |
| T1.4 | Implement PACKFORGE_BUILDER | Create ZIP/TAR from collected files |
| T1.5 | Implement checksum generation | SHA-256 for all files + package |
| T1.6 | Implement PACKFORGE_CLI parsing | Parse build/validate/init commands |
| T1.7 | Implement init command | Generate manifest template |
| T1.8 | Add CHECKSUMS.txt generation | Standard checksum file format |
| T1.9 | Write Phase 1 tests | All core operations have test coverage |
| T1.10 | Create sample manifests | Examples for exe, lib, data packages |

### Test Cases

| Test | Input | Expected Output |
|------|-------|-----------------|
| Parse manifest | Valid packforge.json | Manifest object with all fields |
| Validate manifest | Manifest with missing required file | Validation error reported |
| Collect files | Manifest with globs | All matching files collected |
| Build package | Valid manifest + files | ZIP/TAR created with correct contents |
| Generate checksums | Built package | CHECKSUMS.txt with SHA-256 hashes |
| Init template | `packforge init --type exe` | packforge.json template created |
| Missing file error | Manifest references nonexistent file | Clear error message |
| JSON output | `packforge build --json` | JSON build report |

### Phase 1 Classes

```eiffel
class PACKFORGE_CLI
    -- Command-line interface
feature
    make
    parse_arguments
    execute_build
    execute_validate
    execute_init
    format_output
end

class PACKFORGE_MANIFEST
    -- Manifest parsing and validation
feature
    load (path: STRING): BOOLEAN
    validate: VALIDATION_RESULT
    name, version, description: STRING
    files: ARRAYED_LIST [FILE_SPEC]
    glob_patterns: ARRAYED_LIST [GLOB_SPEC]
end

class PACKFORGE_COLLECTOR
    -- File collection
feature
    collect (manifest: PACKFORGE_MANIFEST): ARRAYED_LIST [FILE_ENTRY]
    verify_all_exist: BOOLEAN
    missing_files: ARRAYED_LIST [STRING]
end

class PACKFORGE_BUILDER
    -- Package creation
feature
    build (files: ARRAYED_LIST [FILE_ENTRY]; output: STRING; format: STRING): BUILD_RESULT
    compute_checksums: HASH_TABLE [STRING, STRING]
    generate_checksum_file: STRING
end
```

---

## Phase 2: Full Implementation

### Objective

Add verification, inspection, diff comparison, and documentation generation to create a complete package building solution.

### Deliverables

1. **PACKFORGE_VERIFIER** - Package verification against manifest/checksums
2. **PACKFORGE_INSPECTOR** - Package content inspection
3. **PACKFORGE_DIFFER** - Package comparison
4. **PACKFORGE_DOCUMENTER** - Documentation generation from templates
5. **Full CLI** - verify, inspect, diff, checksums commands

### Tasks

| Task | Description | Acceptance Criteria |
|------|-------------|---------------------|
| T2.1 | Implement PACKFORGE_VERIFIER | Verify package against manifest |
| T2.2 | Implement verify command | Checksum and content verification |
| T2.3 | Implement PACKFORGE_INSPECTOR | List package contents with metadata |
| T2.4 | Implement inspect command | List, metadata, checksums modes |
| T2.5 | Implement PACKFORGE_DIFFER | Compare two packages |
| T2.6 | Implement diff command | File list and content comparison |
| T2.7 | Implement PACKFORGE_DOCUMENTER | Template-based doc generation |
| T2.8 | Add README generation | Generate from template |
| T2.9 | Add MANIFEST.txt generation | Generate file manifest |
| T2.10 | Implement checksums command | Standalone checksum operations |
| T2.11 | Write Phase 2 tests | Verification and inspection tested |

### Test Cases

| Test | Input | Expected Output |
|------|-------|-----------------|
| Verify valid package | Package + matching checksums | Verification passes |
| Verify corrupted package | Package with modified file | Verification fails with details |
| Inspect package | `packforge inspect pkg.zip` | File list with sizes |
| Inspect checksums | `packforge inspect --checksums pkg.zip` | All file checksums |
| Diff packages | Two different versions | List of changed files |
| Generate README | Template + manifest | Rendered README.md |
| Generate MANIFEST.txt | Built package | Complete manifest file |
| Checksums generate | `packforge checksums generate ./dist` | CHECKSUMS.txt created |
| Checksums verify | `packforge checksums verify CHECKSUMS.txt` | Pass/fail for each file |

### Phase 2 Classes

```eiffel
class PACKFORGE_VERIFIER
    -- Package verification
feature
    verify_checksums (package: STRING; checksums: STRING): VERIFICATION_RESULT
    verify_manifest (package: STRING; manifest: STRING): VERIFICATION_RESULT
    verify_contents (package: STRING): VERIFICATION_RESULT
end

class PACKFORGE_INSPECTOR
    -- Package inspection
feature
    list_contents (package: STRING): ARRAYED_LIST [ENTRY_INFO]
    get_metadata (package: STRING): PACKAGE_METADATA
    get_checksums (package: STRING): HASH_TABLE [STRING, STRING]
end

class PACKFORGE_DIFFER
    -- Package comparison
feature
    compare_files (pkg1, pkg2: STRING): DIFF_RESULT
    compare_content (pkg1, pkg2: STRING): ARRAYED_LIST [CONTENT_DIFF]
end

class PACKFORGE_DOCUMENTER
    -- Documentation generation
feature
    generate_readme (manifest: PACKFORGE_MANIFEST; template: STRING): STRING
    generate_manifest_file (files: ARRAYED_LIST [FILE_ENTRY]; checksums: HASH_TABLE [STRING, STRING]): STRING
    generate_changelog (source: STRING): STRING
end
```

---

## Phase 3: Production Polish

### Objective

Harden for production use with signing support, comprehensive error handling, and documentation.

### Deliverables

- Package signing (enterprise feature)
- Error handling hardening
- Progress reporting
- Complete documentation
- Performance optimization

### Tasks

| Task | Description | Acceptance Criteria |
|------|-------------|---------------------|
| T3.1 | Implement PACKFORGE_SIGNER | Sign packages with keys |
| T3.2 | Implement sign command | Create and verify signatures |
| T3.3 | Add progress reporting | Long operations show progress |
| T3.4 | Comprehensive error messages | All errors have actionable messages |
| T3.5 | Large package handling | Test with 1GB+ packages |
| T3.6 | Performance profiling | Identify and fix bottlenecks |
| T3.7 | Complete help text | All commands have --help with examples |
| T3.8 | README and quick start | User can start in 5 minutes |
| T3.9 | CI/CD integration examples | GitHub Actions, GitLab CI examples |
| T3.10 | Release packaging | Windows installer, Linux package |

### Edge Cases to Handle

| Scenario | Handling |
|----------|----------|
| File changes during build | Detect and warn, option to fail |
| Very long file paths | Handle Windows MAX_PATH |
| Unicode filenames | Proper UTF-8 handling |
| Binary vs text detection | Correct handling for both |
| Symlinks in sources | Follow or skip (configurable) |
| Empty directories | Include in package (configurable) |
| Manifest syntax errors | Clear error with line number |
| Template errors | Show template line and error |

---

## ECF Target Structure

```xml
<!-- Library target (reusable) -->
<target name="packforge">
    <description>PackForge package builder library</description>
    <root all_classes="true"/>
    <library name="simple_archive" location="..."/>
    <library name="simple_file" location="..."/>
    <library name="simple_hash" location="..."/>
    <library name="simple_json" location="..."/>
    <library name="simple_template" location="..."/>
    <library name="simple_uuid" location="..."/>
    <library name="simple_datetime" location="..."/>
    <cluster name="packforge" location=".\src\"/>
</target>

<!-- CLI executable target -->
<target name="packforge_cli" extends="packforge">
    <description>PackForge CLI executable</description>
    <root class="PACKFORGE_CLI" feature="make"/>
    <setting name="executable_name" value="packforge"/>
</target>

<!-- Test target -->
<target name="packforge_tests" extends="packforge">
    <description>PackForge test suite</description>
    <root class="TEST_APP" feature="make"/>
    <library name="simple_testing" location="$SIMPLE_EIFFEL/simple_testing/simple_testing.ecf"/>
    <cluster name="tests" location=".\tests\"/>
</target>
```

## Build Commands

```bash
# Compile CLI (workbench)
/d/prod/ec.sh -batch -config packforge.ecf -target packforge_cli -c_compile

# Compile CLI (finalized)
/d/prod/ec.sh -batch -config packforge.ecf -target packforge_cli -finalize -c_compile

# Run tests
/d/prod/ec.sh -batch -config packforge.ecf -target packforge_tests -c_compile
./EIFGENs/packforge_tests/W_code/packforge.exe
```

## Success Criteria

| Criterion | Measure | Target |
|-----------|---------|--------|
| Compiles | Zero errors, zero warnings | 100% |
| Tests pass | All tests pass | 100% |
| Reproducible | Same inputs = identical package | 100% |
| CLI functional | All commands work | 100% |
| Documentation | README complete, examples | Yes |
| Performance | 100MB package in < 30 seconds | Yes |

## Estimated Total Effort

| Phase | Effort | Cumulative |
|-------|--------|------------|
| Phase 1 (MVP) | 3-4 days | 3-4 days |
| Phase 2 (Full) | 2-3 days | 5-7 days |
| Phase 3 (Polish) | 2-3 days | 7-10 days |

**Total: 7-10 days for production-ready CLI application**
