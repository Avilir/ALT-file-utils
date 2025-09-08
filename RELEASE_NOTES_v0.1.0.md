# ALT-file-utils v0.1.0

🎉 **First Public Release!**

ALT-file-utils is now available on PyPI! This package provides robust file I/O utilities with atomic writes, retries, and comprehensive error handling for Python applications.

## Installation

```bash
pip install ALT-file-utils
```

## Key Features

### 🔒 Atomic File Operations
- Prevent data corruption during writes
- Automatic cleanup on failures
- Cross-platform compatibility

### 🔄 Retry Mechanism
- Configurable retry attempts
- Exponential backoff
- Custom exception handling

### 📁 Safe File Operations
- `safe_file_read()` - Read with error handling
- `safe_file_write()` - Write with atomic operations
- `safe_copy()` - Copy with verification
- `safe_delete()` - Delete with existence checks

### 📊 Format Support
- JSON operations with `safe_json_dump/load`
- YAML operations with `safe_yaml_dump/load`
- TOML reading with `safe_toml_load`

### 🛠️ Utilities
- `ensure_directory()` - Create directories safely
- `temporary_directory()` - Managed temp directories
- `get_file_size()` - Get file size with error handling
- `is_file_locked()` - Check file lock status

## Documentation

- **GitHub Wiki**: https://github.com/Avilir/ALT-file-utils/wiki
- **API Reference**: https://github.com/Avilir/ALT-file-utils/wiki/API-Reference
- **Usage Guide**: https://github.com/Avilir/ALT-file-utils/wiki/Usage-Guide
- **Use Cases**: https://github.com/Avilir/ALT-file-utils/wiki/Use-Cases

## Example Usage

```python
from alt_file_utils import atomic_write, safe_json_dump, retry_on_failure

# Atomic write prevents corruption
with atomic_write('config.json', 'w') as f:
    safe_json_dump({'key': 'value'}, f)

# Retry operations on failure
@retry_on_failure(max_attempts=3)
def flaky_operation():
    # Your code here
    pass
```

## Project Stats

- **Lines of Code**: 498
- **Test Coverage**: 86%
- **Tests**: 42
- **Documentation**: 4,500+ lines

## Requirements

- Python 3.8+
- PyYAML >= 5.4
- tomli (for Python < 3.11)

## Links

- **PyPI**: https://pypi.org/project/ALT-file-utils/
- **GitHub**: https://github.com/Avilir/ALT-file-utils
- **Issues**: https://github.com/Avilir/ALT-file-utils/issues

## Credits

This package was extracted and enhanced from the `pytest-perf-monitor` project, making these robust file utilities available to the wider Python community.

## License

MIT License - see LICENSE file for details.

---

**Full Changelog**: https://github.com/Avilir/ALT-file-utils/commits/v0.1.0
