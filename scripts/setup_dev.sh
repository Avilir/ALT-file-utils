#!/bin/bash

# Development setup script for ALT-file-utils
# Usage: ./setup_dev.sh

set -e  # Exit on error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Setting up ALT-file-utils development environment...${NC}"

# Check Python version
echo -e "${YELLOW}Checking Python version...${NC}"
python3 --version

# Create virtual environment if it doesn't exist
if [ ! -d "venv" ]; then
    echo -e "${GREEN}Creating virtual environment...${NC}"
    python3 -m venv venv
else
    echo -e "${YELLOW}Virtual environment already exists${NC}"
fi

# Activate virtual environment
echo -e "${GREEN}Activating virtual environment...${NC}"
source venv/bin/activate

# Upgrade pip
echo -e "${GREEN}Upgrading pip...${NC}"
pip install --upgrade pip

# Install development dependencies
echo -e "${GREEN}Installing development dependencies...${NC}"
pip install -r requirements-dev.txt

# Install package in editable mode
echo -e "${GREEN}Installing package in editable mode...${NC}"
pip install -e .

# Install pre-commit hooks
if command -v pre-commit &> /dev/null; then
    echo -e "${GREEN}Installing pre-commit hooks...${NC}"
    pre-commit install
else
    echo -e "${YELLOW}pre-commit not found, skipping hook installation${NC}"
fi

# Run initial checks
echo -e "${BLUE}Running initial quality checks...${NC}"

# Linting
echo -e "${YELLOW}Running linting...${NC}"
ruff check . || echo -e "${YELLOW}Some linting issues found${NC}"

# Type checking
echo -e "${YELLOW}Running type checks...${NC}"
mypy src || echo -e "${YELLOW}Some type issues found${NC}"

# Run tests
echo -e "${YELLOW}Running tests...${NC}"
pytest || echo -e "${YELLOW}Some tests failed${NC}"

echo -e "${GREEN}✓ Development environment setup complete!${NC}"
echo -e "${BLUE}To activate the environment in the future, run:${NC}"
echo -e "  source venv/bin/activate"
echo -e "${BLUE}Available make commands:${NC}"
echo -e "  make test         - Run tests"
echo -e "  make lint         - Run linting"
echo -e "  make format       - Format code"
echo -e "  make type-check   - Run type checking"
echo -e "  make build        - Build package"
echo -e "  make publish-test - Publish to TestPyPI"
