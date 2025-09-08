# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2025-09-05

### Added
- Initial release
- Atomic file writing with `atomic_write` context manager
- Retry decorator for transient failures
- Safe file operations: read, write, copy, delete
- JSON support with `safe_json_dump` and `safe_json_load`
- YAML support with `safe_yaml_dump` and `safe_yaml_load`
- TOML reading support with `safe_toml_load`
- Temporary directory context manager
- File size and lock checking utilities
- Comprehensive error handling with specific exception types
- Full type hints and py.typed marker
- Cross-platform compatibility
