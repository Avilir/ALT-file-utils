#!/bin/bash

# Script to test package installation from PyPI or TestPyPI
# Usage: ./test_install.sh [test|prod]

set -e  # Exit on error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default to test PyPI
TARGET=${1:-test}

# Validate target
if [ "$TARGET" != "test" ] && [ "$TARGET" != "prod" ]; then
    echo -e "${RED}Error: Invalid target '$TARGET'. Use 'test' or 'prod'${NC}"
    exit 1
fi

# Create temporary directory for testing
TEST_DIR=$(mktemp -d -t alt-file-utils-test-XXXXXX)
echo -e "${GREEN}Creating test environment in: $TEST_DIR${NC}"

# Change to test directory
cd "$TEST_DIR"

# Create virtual environment
echo -e "${BLUE}Creating fresh virtual environment...${NC}"
python3 -m venv test_venv
source test_venv/bin/activate

# Upgrade pip
pip install --upgrade pip

# Install package
if [ "$TARGET" = "test" ]; then
    echo -e "${YELLOW}Installing from TestPyPI...${NC}"
    pip install --index-url https://test.pypi.org/simple/ --extra-index-url https://pypi.org/simple/ ALT-file-utils
else
    echo -e "${YELLOW}Installing from PyPI...${NC}"
    pip install ALT-file-utils
fi

# Show installed version
echo -e "${GREEN}Installed version:${NC}"
pip show ALT-file-utils

# Create test script
echo -e "${BLUE}Creating test script...${NC}"
cat > test_package.py << 'EOF'
#!/usr/bin/env python3
"""Test ALT-file-utils package functionality."""

import sys
import tempfile
from pathlib import Path

try:
    # Test imports
    print("Testing imports...")
    from alt_file_utils import (
        atomic_write,
        safe_json_dump,
        safe_json_load,
        safe_file_write,
        safe_file_read,
        temporary_directory,
        ensure_directory,
        __version__
    )
    print(f"✓ Successfully imported ALT-file-utils version {__version__}")
    
    # Test atomic write
    print("\nTesting atomic write...")
    with tempfile.TemporaryDirectory() as temp_dir:
        test_file = Path(temp_dir) / "test.txt"
        with atomic_write(test_file) as f:
            f.write("Hello from ALT-file-utils!")
        assert test_file.exists()
        assert test_file.read_text() == "Hello from ALT-file-utils!"
        print("✓ Atomic write works correctly")
    
    # Test JSON operations
    print("\nTesting JSON operations...")
    with tempfile.TemporaryDirectory() as temp_dir:
        json_file = Path(temp_dir) / "test.json"
        test_data = {"name": "ALT-file-utils", "version": __version__, "test": True}
        safe_json_dump(test_data, json_file)
        loaded_data = safe_json_load(json_file)
        assert loaded_data == test_data
        print("✓ JSON operations work correctly")
    
    # Test safe file operations
    print("\nTesting safe file operations...")
    with tempfile.TemporaryDirectory() as temp_dir:
        file_path = Path(temp_dir) / "data.txt"
        safe_file_write("Test content", file_path)
        content = safe_file_read(file_path)
        assert content == "Test content"
        print("✓ Safe file operations work correctly")
    
    # Test directory operations
    print("\nTesting directory operations...")
    with tempfile.TemporaryDirectory() as temp_dir:
        nested_dir = Path(temp_dir) / "level1" / "level2" / "level3"
        created_dir = ensure_directory(nested_dir)
        assert created_dir.exists()
        assert created_dir.is_dir()
        print("✓ Directory operations work correctly")
    
    # Test temporary directory
    print("\nTesting temporary directory...")
    temp_path = None
    with temporary_directory(prefix="alt_test_") as temp_dir:
        temp_path = temp_dir
        assert temp_dir.exists()
        assert "alt_test_" in temp_dir.name
        (temp_dir / "test.txt").write_text("temp file")
    assert not temp_path.exists()  # Should be cleaned up
    print("✓ Temporary directory works correctly")
    
    print("\n" + "="*50)
    print("✅ All tests passed! ALT-file-utils is working correctly.")
    print("="*50)
    
except Exception as e:
    print(f"\n❌ Test failed: {e}")
    import traceback
    traceback.print_exc()
    sys.exit(1)
EOF

# Run test script
echo -e "${BLUE}Running functionality tests...${NC}"
python test_package.py

# Cleanup
deactivate
cd ..
rm -rf "$TEST_DIR"

echo -e "${GREEN}✓ Test completed successfully!${NC}"
