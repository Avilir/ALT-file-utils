.PHONY: help setup test lint format type-check build clean install-dev all publish-test publish-prod

# Default target
all: lint type-check test

help:
	@echo "Available targets:"
	@echo "  setup        - Set up development environment"
	@echo "  test         - Run all tests with coverage"
	@echo "  lint         - Run code linting"
	@echo "  format       - Auto-format code"
	@echo "  type-check   - Run type checking with mypy"
	@echo "  build        - Build source and wheel distributions"
	@echo "  clean        - Clean build artifacts"
	@echo "  install-dev  - Install package in development mode"
	@echo "  publish-test - Publish to TestPyPI"
	@echo "  publish-prod - Publish to production PyPI"
	@echo "  all          - Run lint, type-check, and test"

setup:
	@echo "Setting up development environment..."
	python3 -m venv venv
	. venv/bin/activate && pip install --upgrade pip
	. venv/bin/activate && pip install -r requirements-dev.txt
	. venv/bin/activate && pip install -e .
	. venv/bin/activate && pre-commit install
	@echo "Development environment ready! Run 'source venv/bin/activate' to activate."

test:
	@echo "Running tests with coverage..."
	. venv/bin/activate && python -m pytest

lint:
	@echo "Running linting..."
	. venv/bin/activate && ruff check .

format:
	@echo "Formatting code..."
	. venv/bin/activate && ruff format .
	. venv/bin/activate && black .

type-check:
	@echo "Running type checks..."
	. venv/bin/activate && mypy src

build: clean
	@echo "Building distributions..."
	. venv/bin/activate && python -m build
	@echo "Distributions built in dist/"

clean:
	@echo "Cleaning build artifacts..."
	rm -rf build/
	rm -rf dist/
	rm -rf *.egg-info
	rm -rf src/*.egg-info
	find . -type d -name __pycache__ -exec rm -rf {} +
	find . -type f -name "*.pyc" -delete
	find . -type f -name ".coverage" -delete
	rm -rf htmlcov/
	rm -rf .pytest_cache/
	rm -rf .mypy_cache/
	rm -rf .ruff_cache/

install-dev:
	@echo "Installing package in development mode..."
	. venv/bin/activate && pip install -e .

publish-test: build
	@echo "Publishing to TestPyPI..."
	./scripts/publish_pypi.sh test

publish-prod: build
	@echo "Publishing to production PyPI..."
	./scripts/publish_pypi.sh prod
