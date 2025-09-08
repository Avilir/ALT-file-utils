#!/bin/bash

# Script to help setup PyPI credentials
# Usage: ./setup_pypi_creds.sh

set -e  # Exit on error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}PyPI Credentials Setup Helper${NC}"
echo -e "${BLUE}==============================${NC}"
echo ""

echo -e "${YELLOW}This script helps you set up credentials for publishing to PyPI/TestPyPI.${NC}"
echo ""

echo "Choose your preferred method:"
echo "1. Use API tokens (recommended)"
echo "2. Use username/password"
echo "3. Set environment variables"
echo "4. Create .pypirc file"
echo "5. Show current configuration"
read -p "Enter choice (1-5): " choice

case $choice in
    1)
        echo -e "${GREEN}Using API Tokens (Recommended)${NC}"
        echo ""
        echo "1. Go to https://test.pypi.org/manage/account/token/ for TestPyPI"
        echo "   or https://pypi.org/manage/account/token/ for PyPI"
        echo "2. Create a new API token"
        echo "3. When uploading, use:"
        echo "   Username: __token__"
        echo "   Password: <your-token-including-pypi-prefix>"
        echo ""
        read -p "Would you like to set these as environment variables? (y/n): " set_env
        if [ "$set_env" = "y" ]; then
            read -p "Enter your token: " token
            echo "export TWINE_USERNAME=__token__" >> ~/.bashrc
            echo "export TWINE_PASSWORD=$token" >> ~/.bashrc
            echo -e "${GREEN}Added to ~/.bashrc. Run 'source ~/.bashrc' to activate.${NC}"
        fi
        ;;
    
    2)
        echo -e "${GREEN}Using Username/Password${NC}"
        echo ""
        read -p "Enter your PyPI/TestPyPI username: " username
        echo "export TWINE_USERNAME=$username" >> ~/.bashrc
        echo -e "${YELLOW}For security, set TWINE_PASSWORD manually:${NC}"
        echo "export TWINE_PASSWORD=your-password"
        ;;
    
    3)
        echo -e "${GREEN}Setting Environment Variables${NC}"
        echo ""
        echo "Add these to your ~/.bashrc or ~/.zshrc:"
        echo ""
        echo "# For API token:"
        echo "export TWINE_USERNAME=__token__"
        echo "export TWINE_PASSWORD=pypi-your-token-here"
        echo ""
        echo "# OR for username/password:"
        echo "export TWINE_USERNAME=your-username"
        echo "export TWINE_PASSWORD=your-password"
        echo ""
        echo "Then run: source ~/.bashrc"
        ;;
    
    4)
        echo -e "${GREEN}Creating .pypirc File${NC}"
        echo ""
        PYPIRC_FILE="$HOME/.pypirc"
        
        if [ -f "$PYPIRC_FILE" ]; then
            echo -e "${YELLOW}Warning: $PYPIRC_FILE already exists!${NC}"
            read -p "Overwrite? (y/n): " overwrite
            if [ "$overwrite" != "y" ]; then
                exit 0
            fi
        fi
        
        cat > "$PYPIRC_FILE" << 'EOF'
[distutils]
index-servers =
    pypi
    testpypi

[pypi]
repository = https://upload.pypi.org/legacy/
username = __token__
password = # Add your PyPI token here (including pypi- prefix)

[testpypi]
repository = https://test.pypi.org/legacy/
username = __token__
password = # Add your TestPyPI token here (including pypi- prefix)
EOF
        
        chmod 600 "$PYPIRC_FILE"
        echo -e "${GREEN}Created $PYPIRC_FILE${NC}"
        echo -e "${YELLOW}Edit this file and add your tokens!${NC}"
        ;;
    
    5)
        echo -e "${GREEN}Current Configuration${NC}"
        echo ""
        echo "Environment variables:"
        echo "TWINE_USERNAME: ${TWINE_USERNAME:-not set}"
        echo "TWINE_PASSWORD: ${TWINE_PASSWORD:+[set but hidden]}"
        echo ""
        echo ".pypirc file:"
        if [ -f "$HOME/.pypirc" ]; then
            echo -e "${GREEN}Found at $HOME/.pypirc${NC}"
            ls -la "$HOME/.pypirc"
        else
            echo -e "${YELLOW}Not found${NC}"
        fi
        ;;
    
    *)
        echo -e "${RED}Invalid choice${NC}"
        exit 1
        ;;
esac

echo ""
echo -e "${BLUE}Tips:${NC}"
echo "- API tokens are more secure than passwords"
echo "- Never commit credentials to version control"
echo "- Use different tokens for PyPI and TestPyPI"
echo "- Tokens can be scoped to specific projects"
