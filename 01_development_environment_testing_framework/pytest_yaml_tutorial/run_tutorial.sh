#!/bin/bash

# pytest + PyYAML + pytest-cov Interactive Tutorial Runner
# Standalone interactive learning experience for pytest, YAML processing, and coverage analysis

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
BOOK="📚"
GEAR="⚙️"
MICROSCOPE="🔬"
CHART="📊"
WRENCH="🔧"

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
    
    echo "Installing dependencies..."
    pip install --quiet pytest pytest-cov pyyaml
    
    print_success "Dependencies installed: pytest, pytest-cov, pyyaml"
}

run_step() {
    local step_num=$1
    local step_name=$2
    local step_file=$3
    local description=$4
    
    print_header "Step $step_num: $step_name"
    echo -e "${WHITE}$description${NC}\n"
    
    # Show step file location
    print_info "Running: examples/$step_file"
    
    # Run the step
    echo -e "\n${CYAN}Executing pytest with verbose output...${NC}"
    if pytest "examples/$step_file" -v; then
        print_success "Step $step_num completed successfully!"
    else
        print_error "Step $step_num failed. Please check the output above."
        exit 1
    fi
    
    # If it's a step that demonstrates direct execution
    if [[ "$step_file" =~ step[1-6]_.* ]]; then
        echo -e "\n${YELLOW}You can also run this step directly:${NC}"
        echo -e "${CYAN}python examples/$step_file${NC}\n"
        
        print_info "Running direct execution for demonstration..."
        python "examples/$step_file" 2>/dev/null || true  # Don't fail on direct execution issues
    fi
    
    wait_for_user
}

run_coverage_demo() {
    print_header "Coverage Analysis Demonstration"
    echo -e "${WHITE}Let's see how pytest-cov works with our code!${NC}\n"
    
    print_step "Running tests with coverage analysis..."
    
    echo -e "${CYAN}Command: pytest tests/ examples/ --cov=src --cov-report=term-missing --cov-branch${NC}\n"
    
    if pytest tests/ examples/ --cov=src --cov-report=term-missing --cov-branch --cov-report=html:coverage_html; then
        print_success "Coverage analysis completed!"
        
        echo -e "\n${YELLOW}Coverage reports generated:${NC}"
        print_info "Terminal report: Shown above with missing lines highlighted"
        print_info "HTML report: coverage_html/index.html"
        
        if command -v open &> /dev/null; then
            echo -e "\n${YELLOW}Would you like to open the HTML coverage report? (y/n)${NC}"
            read -r response
            if [[ "$response" =~ ^[Yy]$ ]]; then
                open coverage_html/index.html
                print_success "HTML coverage report opened in browser"
            fi
        fi
    else
        print_error "Coverage analysis failed"
        exit 1
    fi
    
    wait_for_user
}

run_interactive_demo() {
    print_header "Interactive pytest Demo"
    echo -e "${WHITE}Let's explore pytest interactively!${NC}\n"
    
    print_info "You can run individual test files with various options:"
    echo -e "${CYAN}Basic run:${NC} pytest examples/step1_basic_pytest.py"
    echo -e "${CYAN}Verbose:${NC} pytest examples/step1_basic_pytest.py -v"
    echo -e "${CYAN}Show output:${NC} pytest examples/step1_basic_pytest.py -v -s"
    echo -e "${CYAN}Stop on first failure:${NC} pytest examples/step1_basic_pytest.py -x"
    echo -e "${CYAN}Run specific test:${NC} pytest examples/step1_basic_pytest.py::test_math_operations"
    
    echo -e "\n${YELLOW}Try running a command yourself:${NC}"
    echo -e "${CYAN}Enter a pytest command (or press Enter to skip):${NC}"
    read -r user_command
    
    if [ ! -z "$user_command" ]; then
        echo -e "\n${BLUE}Executing: $user_command${NC}"
        eval "$user_command" || print_warning "Command failed, but continuing tutorial..."
    fi
    
    wait_for_user
}

show_project_structure() {
    print_header "Project Structure Overview"
    echo -e "${WHITE}Here's what we've built together:${NC}\n"
    
    if command -v tree &> /dev/null; then
        tree -I '__pycache__|*.pyc|venv|coverage_html' || ls -la
    else
        echo -e "${YELLOW}Project structure:${NC}"
        find . -type f -name "*.py" -o -name "*.yaml" -o -name "*.md" | grep -v __pycache__ | sort
    fi
    
    echo -e "\n${CYAN}Key directories:${NC}"
    print_info "src/ - Main source code (NetworkPolicyConfigManager)"
    print_info "tests/ - Test suite for the source code"
    print_info "examples/ - Step-by-step tutorial examples"
    print_info "sample_configs/ - Sample YAML configuration files"
    
    wait_for_user
}

run_final_challenge() {
    print_header "Final Challenge: Create Your Own Test"
    echo -e "${WHITE}Now it's your turn! Let's create a simple test together.${NC}\n"
    
    echo -e "${YELLOW}We'll create a test for a simple calculator function.${NC}"
    
    # Create a simple module to test
    cat > temp_calculator.py << EOF
def add(a, b):
    return a + b

def subtract(a, b):
    return a - b

def multiply(a, b):
    return a * b

def divide(a, b):
    if b == 0:
        raise ValueError("Cannot divide by zero")
    return a / b
EOF
    
    # Create a test file
    cat > temp_test_calculator.py << EOF
import pytest
from temp_calculator import add, subtract, multiply, divide

def test_add():
    assert add(2, 3) == 5
    assert add(-1, 1) == 0
    assert add(0, 0) == 0

def test_subtract():
    assert subtract(5, 3) == 2
    assert subtract(0, 0) == 0
    assert subtract(-1, -1) == 0

def test_multiply():
    assert multiply(3, 4) == 12
    assert multiply(0, 5) == 0
    assert multiply(-2, 3) == -6

def test_divide():
    assert divide(6, 2) == 3
    assert divide(5, 2) == 2.5
    
def test_divide_by_zero():
    with pytest.raises(ValueError) as exc_info:
        divide(10, 0)
    assert "Cannot divide by zero" in str(exc_info.value)

@pytest.mark.parametrize("a,b,expected", [
    (2, 3, 5),
    (0, 0, 0),
    (-1, 1, 0),
    (100, 200, 300)
])
def test_add_parametrized(a, b, expected):
    assert add(a, b) == expected
EOF
    
    echo -e "${CYAN}Created calculator example with tests!${NC}\n"
    
    print_info "Running the calculator tests..."
    if pytest temp_test_calculator.py -v; then
        print_success "All tests passed!"
    else
        print_error "Some tests failed, but that's okay - it's part of learning!"
    fi
    
    echo -e "\n${YELLOW}Running with coverage:${NC}"
    pytest temp_test_calculator.py --cov=temp_calculator --cov-report=term-missing
    
    echo -e "\n${GREEN}Congratulations! You've created and run your own pytest tests!${NC}"
    
    # Cleanup
    rm -f temp_calculator.py temp_test_calculator.py .coverage
    rm -rf __pycache__
    
    wait_for_user
}

main() {
    clear
    print_header "${ROCKET} pytest + PyYAML + pytest-cov Interactive Tutorial"
    echo -e "${WHITE}Welcome to the comprehensive testing and YAML processing tutorial!${NC}"
    echo -e "${CYAN}This tutorial will guide you through:${NC}"
    echo -e "  ${MICROSCOPE} pytest fundamentals and advanced patterns"
    echo -e "  ${BOOK} YAML processing and validation"
    echo -e "  ${CHART} Code coverage analysis and reporting"
    echo -e "  ${WRENCH} Real-world integration testing"
    
    wait_for_user
    
    # Check requirements
    check_requirements
    
    # Setup virtual environment
    setup_virtual_environment
    
    # Activate virtual environment for the rest of the script
    source venv/bin/activate
    
    # Show project structure
    show_project_structure
    
    # Run tutorial steps
    run_step "1" "pytest Basics" "step1_basic_pytest.py" \
        "Learn fundamental pytest concepts, assertions, and test patterns."
    
    run_step "2" "Fixtures & Setup" "step2_fixtures.py" \
        "Master pytest fixtures for reusable test components and data management."
    
    run_step "3" "YAML Processing Fundamentals" "step3_yaml_basics.py" \
        "Understand YAML parsing, data types, and file operations with PyYAML."
    
    run_step "4" "Configuration Validation" "step4_yaml_validation.py" \
        "Learn to validate YAML configurations with custom rules and error handling."
    
    run_step "5" "Coverage Analysis" "step5_coverage.py" \
        "Explore pytest-cov for measuring and analyzing test coverage."
    
    run_step "6" "Workflow Integration" "step6_integration.py" \
        "Put it all together with comprehensive integration testing patterns."
    
    # Run coverage demonstration
    run_coverage_demo
    
    # Interactive demo
    run_interactive_demo
    
    # Final challenge
    run_final_challenge
    
    # Completion
    print_header "${CHECK} Tutorial Complete!"
    echo -e "${GREEN}Congratulations! You've mastered:${NC}"
    echo -e "  ${CHECK} pytest fundamentals and advanced patterns"
    echo -e "  ${CHECK} YAML processing and validation"
    echo -e "  ${CHECK} Code coverage analysis and reporting"
    echo -e "  ${CHECK} Fixture design and dependency injection"
    echo -e "  ${CHECK} Integration testing strategies"
    echo -e "  ${CHECK} Real-world workflow simulation"
    
    echo -e "\n${YELLOW}${BOOK} Additional Resources:${NC}"
    echo -e "  ${CYAN}pytest documentation:${NC} https://docs.pytest.org/"
    echo -e "  ${CYAN}PyYAML documentation:${NC} https://pyyaml.org/wiki/PyYAMLDocumentation"
    echo -e "  ${CYAN}pytest-cov documentation:${NC} https://pytest-cov.readthedocs.io/"
    
    echo -e "\n${PURPLE}${ROCKET} Next Steps:${NC}"
    echo -e "  • Apply these patterns to your own projects"
    echo -e "  • Explore pytest plugins and extensions"
    echo -e "  • Implement CI/CD integration with coverage"
    echo -e "  • Build domain-specific testing frameworks"
    
    echo -e "\n${GREEN}Happy testing! ${MICROSCOPE}${NC}"
}

# Run main function
main "$@"