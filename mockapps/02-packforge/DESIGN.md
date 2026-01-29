# PackForge - Technical Design

## Architecture

### Component Overview

```
+-------------------------------------------------------------+
|                        PackForge                             |
+-------------------------------------------------------------+
|  CLI Interface Layer                                         |
|    - Argument parsing                                        |
|    - Command routing                                         |
|    - Progress reporting                                      |
|    - Output formatting (text, json)                          |
+-------------------------------------------------------------+
|  Business Logic Layer                                        |
|    - Manifest parsing and validation                         |
|    - File collection and verification                        |
|    - Package assembly                                        |
|    - Documentation generation                                |
+-------------------------------------------------------------+
|  Integration Layer                                           |
|    - Archive creation (simple_archive)                       |
|    - Checksum computation (simple_hash)                      |
|    - Template processing (simple_template)                   |
|    - File operations (simple_file)                           |
|    - Manifest handling (simple_json/simple_yaml)             |
+-------------------------------------------------------------+
```

### Class Design

| Class | Responsibility | Key Features |
|-------|----------------|--------------|
| PACKFORGE_CLI | Command-line interface | parse_args, execute, report_progress |
| PACKFORGE_MANIFEST | Manifest loading and validation | load, validate, resolve_paths |
| PACKFORGE_COLLECTOR | File collection and verification | collect_files, verify_existence, check_versions |
| PACKFORGE_BUILDER | Package assembly | assemble, compress, generate_checksums |
| PACKFORGE_DOCUMENTER | Documentation generation | generate_readme, generate_manifest, generate_changelog |
| PACKFORGE_SIGNER | Package signing (optional) | sign_package, verify_signature |
| PACKFORGE_CONFIG | Global configuration | load_config, validate_config |

### Command Structure

```bash
packforge <command> [options] [arguments]

Commands:
  build         Build a package from manifest
  validate      Validate manifest without building
  verify        Verify an existing package
  init          Create a new manifest template
  inspect       Inspect package contents
  diff          Compare two packages
  sign          Sign a package (enterprise)
  checksums     Generate/verify checksums file

Build Command:
  packforge build [options] [manifest]
    --manifest FILE      Manifest file (default: packforge.json)
    --output DIR         Output directory (default: ./dist)
    --format zip|tar     Package format (default: zip)
    --name NAME          Override package name
    --version VERSION    Override version
    --no-docs            Skip documentation generation
    --no-checksums       Skip checksum generation
    --sign KEY           Sign with specified key

Validate Command:
  packforge validate [options] [manifest]
    --strict             Fail on warnings
    --check-versions     Verify version numbers in files

Verify Command:
  packforge verify [options] <package>
    --manifest FILE      Verify against specific manifest
    --checksums FILE     Verify against checksums file
    --signature FILE     Verify signature

Init Command:
  packforge init [options] [directory]
    --type exe|lib|data  Package type template
    --name NAME          Project name
    --version VERSION    Initial version

Inspect Command:
  packforge inspect [options] <package>
    --list               List all files
    --metadata           Show package metadata
    --checksums          Show file checksums

Diff Command:
  packforge diff [options] <package1> <package2>
    --files              Show file differences
    --content            Show content differences

Global Options:
  --config FILE          Configuration file
  --verbose              Verbose output
  --quiet                Minimal output
  --json                 JSON output format
  --help                 Show help
  --version              Show version
```

### Manifest Format

```json
{
  "$schema": "packforge-manifest-1.0.json",
  "package": {
    "name": "myapp",
    "version": "1.2.3",
    "description": "My Application",
    "author": "Company Name",
    "license": "MIT"
  },
  "build": {
    "format": "zip",
    "compression": 9,
    "output_pattern": "{name}-{version}-{platform}"
  },
  "files": [
    {
      "source": "build/release/myapp.exe",
      "dest": "myapp.exe",
      "required": true
    },
    {
      "source": "config/default.json",
      "dest": "config/default.json",
      "required": true
    },
    {
      "source": "docs/*.md",
      "dest": "docs/",
      "required": false
    },
    {
      "source": "LICENSE",
      "dest": "LICENSE",
      "required": true
    }
  ],
  "glob_patterns": [
    {
      "pattern": "assets/**/*",
      "dest": "assets/",
      "exclude": ["*.psd", "*.sketch"]
    }
  ],
  "documentation": {
    "readme": {
      "template": "templates/README.md.tmpl",
      "dest": "README.md"
    },
    "changelog": {
      "source": "CHANGELOG.md",
      "dest": "CHANGELOG.md"
    },
    "manifest": {
      "generate": true,
      "dest": "MANIFEST.txt"
    }
  },
  "checksums": {
    "generate": true,
    "algorithm": "sha256",
    "dest": "CHECKSUMS.txt"
  },
  "validation": {
    "min_files": 5,
    "max_size_mb": 100,
    "required_files": ["myapp.exe", "LICENSE"],
    "version_check": {
      "file": "myapp.exe",
      "pattern": "ProductVersion=(\\d+\\.\\d+\\.\\d+)"
    }
  },
  "hooks": {
    "pre_build": "scripts/pre-package.sh",
    "post_build": "scripts/post-package.sh"
  }
}
```

### Data Flow

```
Manifest --> Parse --> Validate --> Collect Files --> Verify
                                         |
                                         v
                          Generate Docs --> Assemble --> Compress --> Checksum --> Sign
                                                                         |
                                                                         v
                                                                    Package + Metadata
```

### Output Structure

```
dist/
├── myapp-1.2.3-windows.zip          # Main package
├── myapp-1.2.3-windows.zip.sha256   # Package checksum
├── myapp-1.2.3-windows.zip.sig      # Package signature (if signed)
└── myapp-1.2.3-windows/             # Unpacked view (optional)
    ├── myapp.exe
    ├── config/
    │   └── default.json
    ├── docs/
    │   └── *.md
    ├── assets/
    │   └── ...
    ├── LICENSE
    ├── README.md
    ├── CHANGELOG.md
    ├── MANIFEST.txt
    └── CHECKSUMS.txt
```

### MANIFEST.txt Format

```
PackForge Manifest
==================
Package: myapp
Version: 1.2.3
Built: 2026-01-24T10:30:00Z
Builder: packforge/1.0

Files:
------
myapp.exe                     SHA256: abc123...
config/default.json           SHA256: def456...
docs/quickstart.md            SHA256: ghi789...
assets/logo.png               SHA256: jkl012...
LICENSE                       SHA256: mno345...
README.md                     SHA256: pqr678...
CHANGELOG.md                  SHA256: stu901...

Total files: 7
Total size: 15,234,567 bytes

Package checksum: SHA256:xyz789...
```

### Error Handling

| Error Type | Handling | User Message |
|------------|----------|--------------|
| Manifest not found | Abort | "Error: Manifest not found: {path}" |
| Required file missing | Abort with list | "Error: Required files missing: {list}" |
| Version mismatch | Abort or warn | "Error: Version in myapp.exe (1.2.2) doesn't match manifest (1.2.3)" |
| Template error | Abort with line | "Error: Template error at line {n}: {details}" |
| Output exists | Prompt or overwrite | "Warning: Output exists. Use --force to overwrite" |
| Checksum mismatch | Abort | "Error: Checksum verification failed for {file}" |

## GUI/TUI Future Path

**CLI foundation enables:**
- All operations scriptable
- JSON output for tooling integration
- Exit codes for CI/CD
- Progress streams for monitoring

**TUI possibilities:**
- Interactive manifest editor
- File tree selection
- Build progress visualization
- Diff viewer

**GUI possibilities:**
- Visual manifest designer
- Drag-and-drop file selection
- Package comparison tool
- Release workflow designer
