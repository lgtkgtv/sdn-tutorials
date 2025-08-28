# pytest + PyYAML + pytest-cov Tutorial

🧪 **Comprehensive standalone tutorial for mastering pytest, YAML processing, and code coverage analysis**

## 📋 Overview

This tutorial provides hands-on experience with Python's most essential testing and configuration tools:
- **pytest**: Modern Python testing framework
- **PyYAML**: YAML parsing and processing
- **pytest-cov**: Code coverage analysis and reporting

Perfect for developers who want to build robust, well-tested applications with proper configuration management.

## 🎯 Learning Objectives

By completing this tutorial, you will master:

✅ **pytest Fundamentals**
- Test functions, assertions, and test discovery
- Fixtures for setup, teardown, and data management  
- Parametrized tests and test organization
- Exception testing and test markers

✅ **YAML Processing**
- Loading and parsing YAML configurations
- Working with complex nested structures
- Multiple document handling
- Custom formatting and validation

✅ **Code Coverage Analysis**
- Measuring test coverage with pytest-cov
- Branch coverage and missing line detection
- HTML and terminal reporting
- Coverage-driven test design

✅ **Integration Patterns**
- Real-world workflow testing
- File operations and error handling
- Template-based configuration generation
- Comprehensive test suite organization

## 🚀 Quick Start

### Interactive Tutorial (Recommended)

Run the interactive tutorial script for a guided experience:

```bash
./run_tutorial.sh
```

The script will:
- Check requirements and setup virtual environment
- Guide you through each step with explanations
- Run tests with coverage analysis
- Provide interactive exercises
- Generate comprehensive reports

### Manual Execution

If you prefer to run steps manually:

1. **Setup Environment**
   ```bash
   python3 -m venv venv
   source venv/bin/activate
   pip install pytest pytest-cov pyyaml
   ```

2. **Run Tutorial Steps**
   ```bash
   # Step 1: pytest Basics
   pytest examples/step1_basic_pytest.py -v
   
   # Step 2: Fixtures & Setup
   pytest examples/step2_fixtures.py -v
   
   # Step 3: YAML Processing
   pytest examples/step3_yaml_basics.py -v
   
   # Step 4: Configuration Validation
   pytest examples/step4_yaml_validation.py -v
   
   # Step 5: Coverage Analysis
   pytest examples/step5_coverage.py -v --cov=src --cov-report=term-missing
   
   # Step 6: Integration Testing
   pytest examples/step6_integration.py -v --cov=src --cov-branch
   ```

3. **Run Complete Test Suite with Coverage**
   ```bash
   pytest tests/ examples/ --cov=src --cov-report=term-missing --cov-report=html:coverage_html --cov-branch
   ```

## 📁 Project Structure

```
pytest_yaml_tutorial/
├── README.md                    # This file
├── run_tutorial.sh             # Interactive tutorial runner
├── requirements.txt            # Python dependencies
│
├── src/                        # Source code
│   └── config_manager.py       # NetworkPolicy configuration manager
│
├── tests/                      # Test suite
│   └── test_config_manager.py  # Comprehensive tests
│
├── examples/                   # Step-by-step tutorial
│   ├── step1_basic_pytest.py   # pytest fundamentals
│   ├── step2_fixtures.py       # Fixtures and setup/teardown
│   ├── step3_yaml_basics.py    # YAML processing basics
│   ├── step4_yaml_validation.py # Configuration validation
│   ├── step5_coverage.py       # Coverage analysis
│   └── step6_integration.py    # Complete workflow integration
│
└── sample_configs/             # Sample YAML files
    ├── valid_config.yaml       # Valid NetworkPolicy
    ├── invalid_config.yaml     # Invalid configuration
    └── multiple_policies.yaml  # Multiple documents
```

## 🔧 Tutorial Steps

### Step 1: pytest Basics (step1_basic_pytest.py)
- Basic test functions and assertions
- Different assertion types and patterns
- Exception testing with pytest.raises()
- Test markers (@pytest.mark.skip, @pytest.mark.xfail)

### Step 2: Fixtures & Setup (step2_fixtures.py)  
- Creating and using fixtures
- Setup and teardown with yield
- Fixture dependencies and scopes
- Parametrized fixtures for multiple test runs
- Autouse fixtures and class-based testing

### Step 3: YAML Processing (step3_yaml_basics.py)
- Loading YAML data with yaml.safe_load()
- Working with different YAML data types
- Parsing complex Kubernetes-style configurations
- File operations and multiple documents
- Custom formatting and advanced features

### Step 4: Configuration Validation (step4_yaml_validation.py)
- Creating custom validation classes
- Validating required fields and data types
- Descriptive error messages and handling
- Parametrized validation tests
- Integration with real configuration managers

### Step 5: Coverage Analysis (step5_coverage.py)
- Running tests with pytest-cov
- Understanding coverage reports
- Branch coverage analysis
- Writing tests to maximize coverage
- Coverage-driven development patterns

### Step 6: Integration Testing (step6_integration.py)
- End-to-end workflow testing
- Complex fixture management
- Template-based configuration generation
- Real-world scenario simulation
- Comprehensive reporting and logging

## 📊 Coverage Analysis

The tutorial includes comprehensive coverage analysis tools:

```bash
# Terminal coverage report
pytest --cov=src --cov-report=term-missing

# HTML coverage report
pytest --cov=src --cov-report=html:coverage_html

# Branch coverage analysis
pytest --cov=src --cov-branch

# Combined reporting
pytest --cov=src --cov-report=term-missing --cov-report=html:coverage_html --cov-branch
```

## 🛠️ Requirements

- Python 3.7+
- pytest
- pytest-cov  
- PyYAML

Install with:
```bash
pip install pytest pytest-cov pyyaml
```

## 📚 Additional Resources

- [pytest Documentation](https://docs.pytest.org/)
- [PyYAML Documentation](https://pyyaml.org/wiki/PyYAMLDocumentation)
- [pytest-cov Documentation](https://pytest-cov.readthedocs.io/)
- [YAML Specification](https://yaml.org/spec/)

---

**Happy Testing!** 🧪✨

Run `./run_tutorial.sh` to begin your journey into professional Python testing and YAML configuration management!
