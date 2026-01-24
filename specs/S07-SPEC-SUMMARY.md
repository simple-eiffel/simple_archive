# S07: SPECIFICATION SUMMARY

**Library**: simple_archive
**Date**: 2026-01-23
**Status**: BACKWASH (reverse-engineered from implementation)

## Executive Summary

simple_archive provides TAR and ZIP archive manipulation for Eiffel applications through two main classes: SIMPLE_ARCHIVE for TAR files using ISE etar, and SIMPLE_ZIP for ZIP files using minizip-ng inline C.

## Key Classes

| Class | Purpose | LOC |
|-------|---------|-----|
| SIMPLE_ARCHIVE | TAR operations | 267 |
| SIMPLE_ZIP | ZIP operations | 315 |
| Support classes | Helpers | 150 |

## Core Capabilities

### SIMPLE_ARCHIVE (TAR)
- Create archives from file lists
- Archive directories recursively
- Extract full archives
- Extract specific files
- List contents

### SIMPLE_ZIP (ZIP)
- Create ZIP with compression
- In-memory content addition
- Extract specific entries as strings
- List contents
- Validate archives

## Contract Summary

- 5 preconditions on SIMPLE_ARCHIVE features
- 5 preconditions on SIMPLE_ZIP features
- 3 postconditions ensuring valid results
- State management for ZIP creation

## Dependencies

| Dependency | Type | Purpose |
|------------|------|---------|
| ISE etar | Eiffel | TAR operations |
| minizip-ng | C library | ZIP operations |
| EiffelBase | Eiffel | Standard library |

## Quality Attributes

| Attribute | Implementation |
|-----------|----------------|
| Simplicity | Clear, focused API |
| Reliability | Error handling via last_error |
| Portability | Standard formats (TAR, ZIP) |
| Extensibility | Separate classes for formats |

## Limitations

1. No TAR compression (GZIP separate)
2. No ZIP encryption
3. No ZIP64 (4GB limit)
4. No streaming operations
5. Adding to TAR recreates archive
