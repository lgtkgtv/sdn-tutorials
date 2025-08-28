#!/bin/bash

# Python Code Quality Tools Interactive Tutorial Runner
# Comprehensive learning experience for bandit, safety, flake8, black, isort, and mypy

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Unicode symbols
CHECK="✅"
CROSS="❌"
ROCKET="🚀"
SHIELD="🛡️"
GEAR="⚙️"
MICROSCOPE="🔬"
CHART="📊"
WRENCH="🔧"
HAMMER="🔨"
SPARKLES="✨"
FIRE="🔥"
TARGET="🎯"

print_header() {
    echo -e "${PURPLE}===========================================${NC}"
    echo -e "${WHITE}  $1${NC}"
    echo -e "${PURPLE}===========================================${NC}"
}

print_step() {
    echo -e "\n${BLUE}${GEAR} $1${NC}"
}

print_success() {
    echo -e "${GREEN}${CHECK} $1${NC}"
}

print_error() {
    echo -e "${RED}${CROSS} $1${NC}"
}

print_info() {
    echo -e "${CYAN}ℹ️  $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

wait_for_user() {
    echo -e "\n${YELLOW}Press Enter to continue...${NC}"
    read -r
}

check_requirements() {
    print_step "Checking requirements..."
    
    # Check if python3 is available
    if ! command -v python3 &> /dev/null; then
        print_error "python3 is required but not installed"
        exit 1
    fi
    
    # Check if pip is available
    if ! command -v pip3 &> /dev/null; then
        print_error "pip3 is required but not installed"
        exit 1
    fi
    
    print_success "Python3 and pip3 are available"
}

setup_virtual_environment() {
    print_step "Setting up virtual environment..."
    
    if [ ! -d "venv" ]; then
        echo "Creating virtual environment..."
        python3 -m venv venv
        print_success "Virtual environment created"
    else
        print_info "Virtual environment already exists"
    fi
    
    echo "Activating virtual environment..."
    source venv/bin/activate
    
    echo "Installing Python code quality tools..."
    pip install --quiet --upgrade pip
    pip install --quiet bandit safety flake8 black isort mypy
    pip install --quiet flake8-bugbear flake8-docstrings flake8-naming
    pip install --quiet types-requests vulture
    
    print_success "All tools installed: bandit, safety, flake8, black, isort, mypy"
}

run_tool_demo() {
    local tool_name=$1
    local step_file=$2
    local description=$3
    local demo_commands="$4"
    
    print_header "🔧 $tool_name Demo"
    echo -e "${WHITE}$description${NC}\n"
    
    print_info "Demo file: $step_file"
    
    echo -e "\n${CYAN}Running $tool_name analysis...${NC}"
    
    # Split commands by '|' and run each
    IFS='|' read -ra COMMANDS <<< "$demo_commands"
    for cmd in "${COMMANDS[@]}"; do
        cmd=$(echo "$cmd" | xargs)  # Trim whitespace
        echo -e "\n${YELLOW}Command: $cmd${NC}"
        
        # Run the command and capture both stdout and stderr
        if eval "$cmd" 2>&1; then
            print_success "Command completed successfully"
        else
            print_warning "Command completed with issues (expected for demo)"
        fi
    done
    
    wait_for_user
}

demonstrate_bad_code() {
    print_header "💀 Bad Code Examples"
    echo -e "${WHITE}Let's examine intentionally bad code that our tools will catch!${NC}\n"
    
    bad_files=(
        "bad_code/security_issues.py:Security Vulnerabilities"
        "bad_code/style_violations.py:Style and PEP 8 Violations"  
        "bad_code/formatting_issues.py:Formatting Inconsistencies"
        "bad_code/import_disorder.py:Import Organization Issues"
        "bad_code/type_issues.py:Type Annotation Problems"
    )
    
    for file_info in "${bad_files[@]}"; do
        IFS=':' read -r file_path description <<< "$file_info"
        echo -e "\n${RED}📄 $description${NC}"
        echo -e "${CYAN}File: $file_path${NC}"
        
        if [ -f "$file_path" ]; then
            echo "First 10 lines:"
            head -10 "$file_path" | nl
            echo "..."
        else
            print_warning "File not found: $file_path"
        fi
    done
    
    wait_for_user
}

run_comprehensive_analysis() {
    print_header "🔍 Comprehensive Code Analysis"
    echo -e "${WHITE}Running all tools on our bad code examples${NC}\n"
    
    # Create reports directory
    mkdir -p reports
    
    tools=(
        "bandit:Security Analysis:bandit bad_code/ -f json -o reports/bandit_report.json | bandit bad_code/ -ll"
        "safety:Vulnerability Scanning:safety check --json --output reports/safety_report.json | safety check"
        "flake8:Style Checking:flake8 bad_code/ --output-file=reports/flake8_report.txt | flake8 bad_code/ --statistics"
        "black:Code Formatting:black --diff bad_code/ | echo 'Black would reformat all files'"
        "isort:Import Organization:isort --diff bad_code/ | echo 'isort would reorganize all imports'"
        "mypy:Type Checking:mypy bad_code/ --ignore-missing-imports | echo 'mypy found type issues'"
    )
    
    for tool_info in "${tools[@]}"; do
        IFS=':' read -r tool_name description commands <<< "$tool_info"
        
        echo -e "\n${BLUE}${WRENCH} Running $tool_name - $description${NC}"
        
        IFS='|' read -ra CMDS <<< "$commands"
        for cmd in "${CMDS[@]}"; do
            cmd=$(echo "$cmd" | xargs)
            echo -e "${YELLOW}➤ $cmd${NC}"
            
            if eval "$cmd" 2>/dev/null || true; then
                print_info "Analysis completed"
            fi
        done
    done
    
    print_success "Comprehensive analysis complete! Check the reports/ directory."
    wait_for_user
}

fix_code_demonstration() {
    print_header "🔧 Code Fixing Demonstration"
    echo -e "${WHITE}Let's see how these tools can automatically fix issues!${NC}\n"
    
    # Create temporary copies for demonstration
    echo "Creating temporary files for demonstration..."
    cp -r bad_code/ demo_fixes/ 2>/dev/null || true
    
    fixes=(
        "black:Code Formatting:black demo_fixes/"
        "isort:Import Organization:isort demo_fixes/"
    )
    
    for fix_info in "${fixes[@]}"; do
        IFS=':' read -r tool_name description command <<< "$fix_info"
        
        echo -e "\n${GREEN}${HAMMER} $tool_name - $description${NC}"
        echo -e "${YELLOW}Command: $command${NC}"
        
        # Show before
        echo -e "\n${CYAN}Before fixing:${NC}"
        head -15 "demo_fixes/formatting_issues.py" 2>/dev/null || echo "File not found"
        
        # Apply fix
        eval "$command" 2>/dev/null || true
        
        # Show after
        echo -e "\n${CYAN}After fixing:${NC}"
        head -15 "demo_fixes/formatting_issues.py" 2>/dev/null || echo "File not found"
        
        wait_for_user
    done
    
    # Cleanup
    rm -rf demo_fixes/ 2>/dev/null || true
}

create_sample_project() {
    print_header "🏗️ Sample Project Setup"
    echo -e "${WHITE}Creating a sample project with proper tool configurations${NC}\n"
    
    # Create sample project structure
    mkdir -p sample_project/{src,tests,docs}
    
    # Create sample Python files
    cat > sample_project/src/calculator.py << 'EOF'
"""A simple calculator module."""

from typing import Union

Number = Union[int, float]

def add(a: Number, b: Number) -> Number:
    """Add two numbers."""
    return a + b

def divide(a: Number, b: Number) -> Number:
    """Divide two numbers."""
    if b == 0:
        raise ValueError("Cannot divide by zero")
    return a / b
EOF
    
    cat > sample_project/tests/test_calculator.py << 'EOF'
"""Tests for calculator module."""

import pytest
from src.calculator import add, divide

def test_add():
    """Test addition."""
    assert add(2, 3) == 5
    assert add(-1, 1) == 0

def test_divide():
    """Test division."""
    assert divide(10, 2) == 5
    assert divide(7, 2) == 3.5

def test_divide_by_zero():
    """Test division by zero."""
    with pytest.raises(ValueError):
        divide(5, 0)
EOF
    
    # Create configuration files
    cat > sample_project/pyproject.toml << 'EOF'
[tool.black]
line-length = 88
target-version = ['py38']

[tool.isort]
profile = "black"
multi_line_output = 3
line_length = 88

[tool.mypy]
python_version = "3.8"
warn_return_any = true
warn_unused_configs = true
disallow_untyped_defs = true

[tool.bandit]
exclude_dirs = ["tests"]
EOF
    
    cat > sample_project/.flake8 << 'EOF'
[flake8]
max-line-length = 88
extend-ignore = E203, W503
exclude = venv, .venv, __pycache__
EOF
    
    print_success "Sample project created in sample_project/"
    
    echo -e "\n${CYAN}Running tools on sample project:${NC}"
    
    cd sample_project
    
    # Run tools on sample project
    tools=(
        "flake8 src/ tests/"
        "black --check src/ tests/"
        "isort --check-only src/ tests/"
        "mypy src/"
        "bandit -r src/"
    )
    
    for tool in "${tools[@]}"; do
        echo -e "\n${YELLOW}➤ $tool${NC}"
        if eval "$tool" 2>/dev/null; then
            print_success "No issues found"
        else
            print_info "Issues found (expected for demo)"
        fi
    done
    
    cd ..
    wait_for_user
}

show_integration_examples() {
    print_header "🔗 Integration Examples"
    echo -e "${WHITE}How to integrate these tools into your development workflow${NC}\n"
    
    integrations=(
        "Pre-commit Hooks:.pre-commit-config.yaml"
        "GitHub Actions:.github/workflows/quality.yml" 
        "Makefile:Makefile"
        "VS Code Settings:.vscode/settings.json"
        "tox Configuration:tox.ini"
    )
    
    for integration in "${integrations[@]}"; do
        IFS=':' read -r name filename <<< "$integration"
        
        echo -e "\n${BLUE}${GEAR} $name${NC}"
        echo -e "${CYAN}File: $filename${NC}"
        
        case $name in
            "Pre-commit Hooks")
                cat << 'EOF'
repos:
  - repo: https://github.com/psf/black
    rev: 23.1.0
    hooks:
      - id: black
  - repo: https://github.com/pycqa/isort
    rev: 5.12.0
    hooks:
      - id: isort
        args: ["--profile", "black"]
  - repo: https://github.com/pyCQA/flake8
    rev: 6.0.0
    hooks:
      - id: flake8
  - repo: https://github.com/PyCQA/bandit
    rev: 1.7.4
    hooks:
      - id: bandit
EOF
                ;;
            "GitHub Actions")
                cat << 'EOF'
name: Code Quality
on: [push, pull_request]
jobs:
  quality:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    - name: Set up Python
      uses: actions/setup-python@v2
      with:
        python-version: 3.9
    - name: Install tools
      run: pip install black isort flake8 mypy bandit safety
    - name: Run quality checks
      run: |
        black --check .
        isort --check-only .
        flake8 .
        mypy .
        bandit -r .
        safety check
EOF
                ;;
            "Makefile")
                cat << 'EOF'
.PHONY: format lint type-check security test quality

format:
	black .
	isort .

lint:
	flake8 .

type-check:
	mypy .

security:
	bandit -r .
	safety check

test:
	pytest tests/

quality: format lint type-check security test
	@echo "All quality checks passed!"
EOF
                ;;
            "VS Code Settings")
                cat << 'EOF'
{
    "python.formatting.provider": "black",
    "python.linting.flake8Enabled": true,
    "python.linting.mypyEnabled": true,
    "python.sortImports.provider": "isort",
    "python.sortImports.args": ["--profile", "black"],
    "editor.formatOnSave": true,
    "editor.codeActionsOnSave": {
        "source.organizeImports": true
    }
}
EOF
                ;;
            "tox Configuration")
                cat << 'EOF'
[testenv:quality]
deps = black isort flake8 mypy bandit safety
commands = 
    black --check .
    isort --check-only .
    flake8 .
    mypy .
    bandit -r .
    safety check
EOF
                ;;
        esac
    done
    
    wait_for_user
}

show_best_practices() {
    print_header "🎯 Best Practices & Recommendations"
    echo -e "${WHITE}Expert tips for using Python code quality tools effectively${NC}\n"
    
    practices=(
        "Start Gradually:Don't enable all strict options at once|Introduce tools one at a time|Focus on fixing existing issues first"
        "Configuration:Use consistent configuration across team|Store configs in version control|Document team standards"
        "Automation:Set up pre-commit hooks|Integrate with CI/CD pipelines|Automate what can be automated"
        "Team Adoption:Provide training and documentation|Start with less strict settings|Get team buy-in before enforcement"
        "Tool Combination:Use Black + isort for formatting|Combine flake8 with Black-compatible settings|Use mypy for gradual typing"
        "Maintenance:Keep tools updated regularly|Review and adjust configurations|Monitor for new security vulnerabilities"
    )
    
    for practice in "${practices[@]}"; do
        IFS=':' read -r title details <<< "$practice"
        
        echo -e "\n${GREEN}${TARGET} $title${NC}"
        IFS='|' read -ra ITEMS <<< "$details"
        for item in "${ITEMS[@]}"; do
            echo -e "  • $item"
        done
    done
    
    echo -e "\n${YELLOW}${SPARKLES} Golden Rules:${NC}"
    echo -e "  🔑 Consistency is more important than personal preferences"
    echo -e "  🔑 Automate formatting, discuss logic and design in reviews" 
    echo -e "  🔑 Fix security issues immediately, style issues can wait"
    echo -e "  🔑 Type hints improve code documentation and catch errors"
    echo -e "  🔑 Regular updates prevent security vulnerabilities"
    
    wait_for_user
}

create_cheat_sheet() {
    print_header "📋 Quick Reference Cheat Sheet"
    echo -e "${WHITE}Essential commands for each tool${NC}\n"
    
    mkdir -p reports
    
    cat > reports/cheat_sheet.md << 'EOF'
# Python Code Quality Tools - Quick Reference

## 🛡️ Bandit (Security)
```bash
bandit file.py                    # Basic security scan
bandit -r project/                # Recursive scan
bandit -f json file.py            # JSON output
bandit -ll file.py                # Low confidence + low severity
bandit -s B101,B102 file.py       # Skip specific tests
```

## 🔍 Safety (Vulnerabilities)
```bash
safety check                      # Check installed packages
safety check -r requirements.txt # Check requirements file
safety check --json              # JSON output
safety check --ignore 12345      # Ignore specific vulnerability
```

## 📏 Flake8 (Style)
```bash
flake8 file.py                    # Basic style check
flake8 --statistics file.py       # Show statistics
flake8 --show-source file.py      # Show source code
flake8 --max-line-length=88 .     # Set line length
```

## 🎨 Black (Formatting)
```bash
black file.py                     # Format file
black --diff file.py              # Show changes
black --check file.py             # Check only (no changes)
black --line-length 100 file.py   # Set line length
```

## 📚 isort (Imports)
```bash
isort file.py                     # Sort imports
isort --diff file.py              # Show changes
isort --check-only file.py        # Check only
isort --profile black file.py     # Use Black profile
```

## 🎯 MyPy (Types)
```bash
mypy file.py                      # Type check
mypy --strict file.py             # Strict mode
mypy --ignore-missing-imports .   # Ignore missing stubs
mypy --install-types file.py      # Install type stubs
```

## 🔧 Combined Workflows
```bash
# Format and organize
black . && isort .

# Full quality check
flake8 . && mypy . && bandit -r . && safety check

# Pre-commit setup
pre-commit install
pre-commit run --all-files
```
EOF
    
    print_success "Cheat sheet created: reports/cheat_sheet.md"
    
    echo -e "\n${CYAN}Quick reference created! Here are the essential commands:${NC}"
    
    tools=(
        "bandit:🛡️ :bandit -r . (security scan)"
        "safety:🔍:safety check (vulnerability scan)"
        "flake8:📏:flake8 . (style check)"
        "black:🎨:black . (format code)"
        "isort:📚:isort . (organize imports)" 
        "mypy:🎯:mypy . (type check)"
    )
    
    for tool_info in "${tools[@]}"; do
        IFS=':' read -r tool icon command <<< "$tool_info"
        echo -e "  ${icon} ${YELLOW}$tool${NC}: $command"
    done
    
    wait_for_user
}

final_challenge() {
    print_header "🎮 Final Challenge: Fix the Code!"
    echo -e "${WHITE}Time to put your knowledge to the test!${NC}\n"
    
    # Create a file with multiple issues
    cat > challenge_code.py << 'EOF'
import os,sys
import requests
from typing import List,Dict
from collections import defaultdict


def process_data(data,options=None):
    if options==None:options={}
    
    result=[]
    for item in data:
        if item in options:result.append(options[item])
        else:result.append(item)
    return result

class User:
    def __init__(self,name,age):
        self.name=name
        self.age=age
    def get_info( self ):
        return f"{self.name} is {self.age} years old"

def unsafe_function():
    password="secretpassword123"
    cmd = f"ls {input('Enter directory: ')}"
    os.system(cmd)
    return password

if __name__=="__main__":
    users=[User("John",30),User("Jane",25)]
    for user in users:print(user.get_info())
EOF
    
    echo -e "${YELLOW}Challenge file created: challenge_code.py${NC}"
    echo -e "${CYAN}This file has multiple issues. Let's see what the tools find:${NC}\n"
    
    # Run tools on challenge file
    echo -e "${RED}🛡️  Security Issues (bandit):${NC}"
    bandit challenge_code.py 2>/dev/null || print_warning "Security issues found!"
    
    echo -e "\n${RED}📏 Style Issues (flake8):${NC}"
    flake8 challenge_code.py 2>/dev/null || print_warning "Style issues found!"
    
    echo -e "\n${BLUE}Now let's fix them step by step:${NC}"
    
    # Fix formatting
    echo -e "\n${GREEN}1. Fixing formatting with Black...${NC}"
    black challenge_code.py 2>/dev/null
    print_success "Formatting fixed!"
    
    # Fix imports
    echo -e "\n${GREEN}2. Organizing imports with isort...${NC}"
    isort challenge_code.py 2>/dev/null
    print_success "Imports organized!"
    
    echo -e "\n${CYAN}Here's the formatted code:${NC}"
    cat challenge_code.py
    
    echo -e "\n${YELLOW}Note: Security and logic issues still need manual fixing!${NC}"
    echo -e "${CYAN}Black and isort fixed formatting and imports, but you still need to:${NC}"
    echo -e "  • Remove hardcoded password"
    echo -e "  • Fix command injection vulnerability"
    echo -e "  • Add proper type annotations"
    echo -e "  • Handle None values safely"
    
    # Cleanup
    rm -f challenge_code.py
    
    wait_for_user
}

main() {
    clear
    print_header "${ROCKET} Python Code Quality Tools Tutorial"
    echo -e "${WHITE}Master the essential tools for writing secure, maintainable Python code!${NC}"
    echo -e "${CYAN}Tools covered: bandit, safety, flake8, black, isort, mypy${NC}\n"
    
    echo -e "${BLUE}What you'll learn:${NC}"
    echo -e "  ${SHIELD} Security analysis with bandit"
    echo -e "  🔍 Vulnerability scanning with safety"  
    echo -e "  📏 Code style with flake8"
    echo -e "  🎨 Automatic formatting with black"
    echo -e "  📚 Import organization with isort"
    echo -e "  🎯 Type checking with mypy"
    
    wait_for_user
    
    # Check requirements and setup
    check_requirements
    setup_virtual_environment
    
    # Activate environment for the rest of the script
    source venv/bin/activate
    
    # Show bad code examples
    demonstrate_bad_code
    
    # Run individual tool demos
    run_tool_demo "Bandit" "examples/step1_bandit_security.py" \
        "Security vulnerability scanner" \
        "python examples/step1_bandit_security.py | bandit examples/step1_bandit_security.py"
    
    run_tool_demo "Safety" "examples/step2_safety_vulnerabilities.py" \
        "Dependency vulnerability scanner" \
        "python examples/step2_safety_vulnerabilities.py | safety check"
    
    run_tool_demo "Flake8" "examples/step3_flake8_style.py" \
        "Code style and quality checker" \
        "python examples/step3_flake8_style.py | flake8 examples/step3_flake8_style.py --statistics"
    
    run_tool_demo "Black" "examples/step4_black_formatting.py" \
        "Automatic code formatter" \
        "python examples/step4_black_formatting.py | black --diff examples/step4_black_formatting.py"
    
    run_tool_demo "isort" "examples/step5_isort_imports.py" \
        "Import statement organizer" \
        "python examples/step5_isort_imports.py | isort --diff examples/step5_isort_imports.py"
    
    run_tool_demo "MyPy" "examples/step6_mypy_types.py" \
        "Static type checker" \
        "python examples/step6_mypy_types.py | mypy examples/step6_mypy_types.py --ignore-missing-imports"
    
    # Comprehensive analysis
    run_comprehensive_analysis
    
    # Code fixing demonstration
    fix_code_demonstration
    
    # Sample project
    create_sample_project
    
    # Integration examples
    show_integration_examples
    
    # Best practices
    show_best_practices
    
    # Create cheat sheet
    create_cheat_sheet
    
    # Final challenge
    final_challenge
    
    # Completion
    print_header "${SPARKLES} Tutorial Complete!"
    echo -e "${GREEN}Congratulations! You've mastered Python code quality tools:${NC}"
    echo -e "  ${SHIELD} ${GREEN}Bandit - Security vulnerability detection${NC}"
    echo -e "  🔍 ${GREEN}Safety - Dependency vulnerability scanning${NC}"
    echo -e "  📏 ${GREEN}Flake8 - Code style and quality checking${NC}"
    echo -e "  🎨 ${GREEN}Black - Automatic code formatting${NC}"
    echo -e "  📚 ${GREEN}isort - Import organization${NC}"
    echo -e "  🎯 ${GREEN}MyPy - Static type checking${NC}"
    
    echo -e "\n${YELLOW}📚 Resources Created:${NC}"
    echo -e "  📄 Reports directory with analysis results"
    echo -e "  📋 Quick reference cheat sheet"
    echo -e "  🏗️  Sample project with configurations"
    echo -e "  💡 Integration examples for your workflow"
    
    echo -e "\n${PURPLE}🎯 Next Steps:${NC}"
    echo -e "  • Set up pre-commit hooks in your projects"
    echo -e "  • Configure these tools in your IDE"
    echo -e "  • Add quality checks to your CI/CD pipeline"
    echo -e "  • Start with gradual adoption in existing projects"
    echo -e "  • Keep tools updated for latest security patches"
    
    echo -e "\n${GREEN}Happy coding with high-quality, secure Python! ${FIRE}${NC}"
}

# Run main function
main "$@"