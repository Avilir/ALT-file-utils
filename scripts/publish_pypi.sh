#!/bin/bash

# Script to publish package to PyPI (test or production)
# Usage: ./publish_pypi.sh [test|prod]
#
# This script handles:
# - Virtual environment activation
# - Distribution file validation
# - Credentials via environment variables or interactive prompt
# - Keyring issues on Linux systems
# - Safety confirmation for production releases

set -e  # Exit on error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script configuration
PACKAGE_NAME="ALT-file-utils"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Change to project root
cd "$PROJECT_ROOT"

# Check if virtual environment is activated
if [[ -z "$VIRTUAL_ENV" ]]; then
    echo -e "${YELLOW}Virtual environment not activated. Activating...${NC}"
    if [ -f "venv/bin/activate" ]; then
        source venv/bin/activate
    else
        echo -e "${RED}Error: Virtual environment not found at venv/${NC}"
        echo "Please run: python -m venv venv && source venv/bin/activate"
        exit 1
    fi
fi

# Check if twine is installed
if ! command -v twine &> /dev/null; then
    echo -e "${YELLOW}twine not found. Installing...${NC}"
    pip install twine
fi

# Check command line argument
if [ $# -eq 0 ]; then
    echo -e "${RED}Error: Please specify 'test' or 'prod' as argument${NC}"
    echo "Usage: $0 [test|prod]"
    echo "  test - Publish to TestPyPI"
    echo "  prod - Publish to PyPI (production)"
    exit 1
fi

TARGET=$1

# Validate target
if [ "$TARGET" != "test" ] && [ "$TARGET" != "prod" ]; then
    echo -e "${RED}Error: Invalid target '$TARGET'. Use 'test' or 'prod'${NC}"
    exit 1
fi

# Check if distribution files exist
if [ ! -d "dist" ] || [ -z "$(ls -A dist 2>/dev/null)" ]; then
    echo -e "${RED}Error: No distribution files found in dist/${NC}"
    echo "Run 'make build' first to create distribution files"
    exit 1
fi

# Check distribution files
echo -e "${GREEN}Checking distribution files...${NC}"
twine check dist/*

# Count files to upload
FILE_COUNT=$(ls -1 dist/* 2>/dev/null | wc -l)
echo -e "${BLUE}Found $FILE_COUNT distribution file(s)${NC}"

# Set repository configuration based on target
if [ "$TARGET" = "test" ]; then
    REPO_NAME="testpypi"
    REPO_DISPLAY="TestPyPI"
    echo -e "${YELLOW}Publishing to TestPyPI...${NC}"
else
    REPO_NAME="pypi"
    REPO_DISPLAY="PyPI (Production)"
    echo -e "${YELLOW}Publishing to PyPI (Production)...${NC}"
fi

# Show what will be uploaded
echo -e "${GREEN}Files to upload:${NC}"
ls -la dist/

# Get package version from dist files
VERSION=$(ls dist/*.whl 2>/dev/null | head -1 | sed -E 's/.*-([0-9]+\.[0-9]+\.[0-9]+[^-]*)-.*$/\1/')
if [ -n "$VERSION" ]; then
    echo -e "${BLUE}Package version: $VERSION${NC}"
fi

# Confirm before publishing to production
if [ "$TARGET" = "prod" ]; then
    echo ""
    echo -e "${YELLOW}⚠️  WARNING: You are about to publish to production PyPI!${NC}"
    echo -e "${YELLOW}   This action cannot be undone. The version $VERSION will be permanently registered.${NC}"
    echo ""
    read -p "Type 'yes' to confirm production release: " confirm
    if [ "$confirm" != "yes" ]; then
        echo -e "${RED}Publishing cancelled${NC}"
        exit 0
    fi
fi

# Disable keyring to avoid SecretService errors on Linux
export PYTHON_KEYRING_BACKEND=keyring.backends.null.Keyring

# Check for credentials
echo ""
if [ -n "$TWINE_USERNAME" ] && [ -n "$TWINE_PASSWORD" ]; then
    echo -e "${GREEN}Using credentials from environment variables${NC}"
else
    echo -e "${BLUE}Credentials setup:${NC}"
    echo -e "${YELLOW}1. For API tokens (recommended):${NC}"
    echo "   - Username: __token__"
    echo "   - Password: <your-api-token>"
    echo ""
    echo -e "${YELLOW}2. For username/password:${NC}"
    echo "   - Username: <your-pypi-username>"
    echo "   - Password: <your-pypi-password>"
    echo ""
    if [ "$TARGET" = "test" ]; then
        echo -e "${YELLOW}Note: Use your test.pypi.org credentials${NC}"
    else
        echo -e "${YELLOW}Note: Use your pypi.org credentials${NC}"
    fi
    echo ""
fi

# Upload to PyPI
echo -e "${GREEN}Uploading to $REPO_DISPLAY...${NC}"

# Use repository name which automatically uses the correct URL from .pypirc or defaults
if ! twine upload --repository "$REPO_NAME" dist/* --verbose; then
    echo ""
    echo -e "${RED}Upload failed!${NC}"
    echo ""
    echo -e "${YELLOW}Troubleshooting tips:${NC}"
    echo "1. Check your credentials (username/password or API token)"
    echo "2. For API tokens, ensure username is '__token__'"
    echo "3. Verify your account has upload permissions"
    echo "4. Check if this version already exists on $REPO_DISPLAY"
    echo ""
    if [ "$TARGET" = "test" ]; then
        echo "5. Create account at: https://test.pypi.org/account/register/"
        echo "6. Generate API token at: https://test.pypi.org/manage/account/token/"
    else
        echo "5. Create account at: https://pypi.org/account/register/"
        echo "6. Generate API token at: https://pypi.org/manage/account/token/"
    fi
    exit 1
fi

echo ""
echo -e "${GREEN}✅ Successfully published $PACKAGE_NAME $VERSION to $REPO_DISPLAY!${NC}"
echo ""

# Show installation instructions
if [ "$TARGET" = "test" ]; then
    echo -e "${GREEN}To install from TestPyPI:${NC}"
    echo "pip install --index-url https://test.pypi.org/simple/ --extra-index-url https://pypi.org/simple/ $PACKAGE_NAME"
    echo ""
    echo -e "${BLUE}View package at: https://test.pypi.org/project/$PACKAGE_NAME/${NC}"
else
    echo -e "${GREEN}To install from PyPI:${NC}"
    echo "pip install $PACKAGE_NAME"
    echo ""
    echo -e "${BLUE}View package at: https://pypi.org/project/$PACKAGE_NAME/${NC}"
fi

echo ""
echo -e "${GREEN}Next steps:${NC}"
if [ "$TARGET" = "test" ]; then
    echo "1. Test installation: ./scripts/test_install.sh test"
    echo "2. If everything works, publish to production: make publish-prod"
else
    echo "1. Create a Git tag: git tag -a v$VERSION -m 'Release version $VERSION'"
    echo "2. Push tag: git push origin v$VERSION"
    echo "3. Create GitHub release with changelog"
fi
