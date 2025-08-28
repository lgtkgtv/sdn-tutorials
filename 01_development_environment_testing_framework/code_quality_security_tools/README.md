# Python Code Quality & Security Tools Tutorial

🛡️ **Master the essential Python code quality and security tools for secure, maintainable, and professional code**

## 📋 Overview

This comprehensive tutorial teaches you to use Python's most important code quality tools:

- **🛡️ Bandit**: Security vulnerability scanner
- **🔍 Safety**: Dependency vulnerability checker  
- **📏 Flake8**: Code style and quality checker
- **🎨 Black**: Automatic code formatter
- **📚 isort**: Import statement organizer
- **🎯 MyPy**: Static type checker

Perfect for developers who want to write secure, well-formatted, and maintainable Python code that follows industry best practices.

## 🎯 Learning Objectives

By completing this tutorial, you will master:

✅ **Security Analysis**
- Identify security vulnerabilities with bandit
- Scan for vulnerable dependencies with safety
- Implement secure coding patterns
- Handle secrets and sensitive data properly

✅ **Code Style & Quality**
- Enforce PEP 8 style guidelines with flake8
- Automatically format code with black
- Organize imports consistently with isort
- Configure tools for team consistency

✅ **Type Safety**
- Add type annotations with mypy
- Catch type errors before runtime
- Use advanced typing features
- Implement gradual typing strategies

✅ **Workflow Integration**
- Set up pre-commit hooks
- Configure CI/CD pipelines
- Integrate with IDEs and editors
- Automate quality checks

## 🚀 Quick Start

### Interactive Tutorial (Recommended)

Run the comprehensive interactive tutorial:

```bash
./run_tutorial.sh
```

The script will:
- Set up virtual environment automatically
- Install all required tools
- Guide you through each tool with examples
- Show before/after code transformations
- Provide hands-on exercises
- Create configuration templates

### Manual Execution

If you prefer step-by-step manual execution:

1. **Setup Environment**
   ```bash
   python3 -m venv venv
   source venv/bin/activate
   pip install bandit safety flake8 black isort mypy
   ```

2. **Run Tutorial Steps**
   ```bash
   # Step 1: Security Analysis
   python examples/step1_bandit_security.py
   bandit examples/step1_bandit_security.py
   
   # Step 2: Vulnerability Scanning  
   python examples/step2_safety_vulnerabilities.py
   safety check
   
   # Step 3: Style Checking
   python examples/step3_flake8_style.py
   flake8 examples/step3_flake8_style.py
   
   # Step 4: Code Formatting
   python examples/step4_black_formatting.py
   black --diff examples/step4_black_formatting.py
   
   # Step 5: Import Organization
   python examples/step5_isort_imports.py
   isort --diff examples/step5_isort_imports.py
   
   # Step 6: Type Checking
   python examples/step6_mypy_types.py
   mypy examples/step6_mypy_types.py
   ```

3. **Analyze Bad Code Examples**
   ```bash
   # See what issues each tool finds
   bandit bad_code/security_issues.py
   flake8 bad_code/style_violations.py
   black --diff bad_code/formatting_issues.py
   isort --diff bad_code/import_disorder.py
   mypy bad_code/type_issues.py
   ```

## 📁 Project Structure

```
code_quality_security_tools/
├── README.md                     # This comprehensive guide
├── run_tutorial.sh              # Interactive tutorial runner
├── requirements.txt             # Tool dependencies
│
├── examples/                    # Step-by-step tutorials
│   ├── step1_bandit_security.py   # Security analysis
│   ├── step2_safety_vulnerabilities.py # Vulnerability scanning
│   ├── step3_flake8_style.py      # Style checking
│   ├── step4_black_formatting.py  # Code formatting
│   ├── step5_isort_imports.py     # Import organization
│   └── step6_mypy_types.py        # Type checking
│
├── bad_code/                    # Intentionally problematic code
│   ├── security_issues.py        # Security vulnerabilities
│   ├── vulnerable_dependencies.py # Dependency issues
│   ├── style_violations.py       # PEP 8 violations
│   ├── formatting_issues.py      # Formatting problems
│   ├── import_disorder.py        # Import organization issues
│   └── type_issues.py            # Type annotation problems
│
├── good_code/                   # Fixed/secure examples
│   └── secure_patterns.py        # Security best practices
│
├── demonstrations/              # Interactive examples
├── reports/                     # Generated analysis reports
└── sample_project/              # Example project setup
```

## 🔧 Tool Deep Dive

### 🛡️ Bandit - Security Analysis

Bandit scans Python code for common security issues:

```bash
# Basic security scan
bandit file.py

# Recursive scan with JSON output
bandit -r project/ -f json

# Skip specific tests
bandit -s B101,B102 file.py
```

**Common Issues Detected:**
- Hardcoded passwords and secrets
- SQL injection vulnerabilities
- Shell injection risks
- Insecure random number generation
- Weak cryptographic practices
- Unsafe deserialization

### 🔍 Safety - Vulnerability Scanning

Safety checks your dependencies against known security vulnerabilities:

```bash
# Check installed packages
safety check

# Check requirements file
safety check -r requirements.txt

# JSON output for automation
safety check --json
```

**Key Features:**
- Scans against PyUp.io vulnerability database
- Checks for CVE vulnerabilities
- Integrates with CI/CD pipelines
- Provides detailed remediation advice

### 📏 Flake8 - Style & Quality Checking

Flake8 enforces PEP 8 style guidelines and catches programming errors:

```bash
# Basic style check
flake8 file.py

# With statistics and source display
flake8 --statistics --show-source file.py

# Custom line length
flake8 --max-line-length=88 project/
```

**What it Catches:**
- PEP 8 style violations
- Unused imports and variables
- Syntax errors and typos
- Complexity issues
- Naming convention problems

### 🎨 Black - Code Formatting

Black automatically formats Python code with zero configuration:

```bash
# Format code in-place
black file.py

# Show what would change
black --diff file.py

# Check if formatting needed
black --check file.py
```

**Benefits:**
- Consistent formatting across teams
- No configuration debates
- Saves time in code reviews
- Integrates with all editors

### 📚 isort - Import Organization

isort automatically organizes and sorts import statements:

```bash
# Sort imports
isort file.py

# Show changes
isort --diff file.py

# Use with Black
isort --profile black file.py
```

**Organization Rules:**
1. Standard library imports
2. Third-party imports
3. Local application imports
4. Alphabetical sorting within groups

### 🎯 MyPy - Type Checking

MyPy performs static type checking to catch errors before runtime:

```bash
# Basic type checking
mypy file.py

# Strict mode
mypy --strict file.py

# Ignore missing imports
mypy --ignore-missing-imports project/
```

**Benefits:**
- Catch type errors early
- Improve code documentation
- Better IDE support
- Easier refactoring

## 🔧 Configuration Examples

### Combined Configuration (pyproject.toml)

```toml
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
disallow_untyped_defs = true

[tool.bandit]
exclude_dirs = ["tests"]
skips = ["B101"]
```

### Flake8 Configuration (.flake8)

```ini
[flake8]
max-line-length = 88
extend-ignore = E203, W503
exclude = venv, .venv, __pycache__
per-file-ignores = __init__.py:F401
```

## 🔗 Integration Examples

### Pre-commit Hooks

```yaml
# .pre-commit-config.yaml
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
  
  - repo: https://github.com/pycqa/flake8
    rev: 6.0.0
    hooks:
      - id: flake8
  
  - repo: https://github.com/PyCQA/bandit
    rev: 1.7.4
    hooks:
      - id: bandit
```

### GitHub Actions

```yaml
# .github/workflows/quality.yml
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
      run: pip install bandit safety flake8 black isort mypy
    - name: Security check
      run: bandit -r .
    - name: Vulnerability check
      run: safety check
    - name: Style check
      run: flake8 .
    - name: Format check
      run: black --check .
    - name: Import check
      run: isort --check-only .
    - name: Type check
      run: mypy .
```

### Makefile

```makefile
.PHONY: format lint security type-check quality

format:
	black .
	isort .

lint:
	flake8 .

security:
	bandit -r .
	safety check

type-check:
	mypy .

quality: format lint security type-check
	@echo "All quality checks passed!"
```

## 🎓 Best Practices

### 🚀 Getting Started
- **Start gradually**: Don't enable all strict options at once
- **Team adoption**: Get team buy-in before enforcing rules
- **Documentation**: Document your team's standards
- **Training**: Provide training on tools and practices

### ⚙️ Configuration
- **Consistency**: Use same configuration across all projects
- **Version control**: Store configurations in version control
- **Profiles**: Use tool profiles (e.g., isort's "black" profile)
- **Compatibility**: Ensure tools work well together

### 🔄 Automation
- **Pre-commit hooks**: Catch issues before commits
- **CI/CD integration**: Fail builds on quality issues
- **IDE integration**: Enable tools in development environment
- **Automated fixes**: Let tools fix what they can automatically

### 🛡️ Security
- **Regular updates**: Keep tools updated for latest security patches
- **Immediate fixes**: Address security vulnerabilities immediately
- **Dependency scanning**: Regularly scan dependencies
- **Secret management**: Never commit secrets to code

## 🎯 Advanced Usage

### Custom Flake8 Plugins

```bash
# Install useful plugins
pip install flake8-bugbear flake8-docstrings flake8-naming

# Use in configuration
[flake8]
select = E,W,F,C,B,D,N
```

### MyPy Advanced Features

```python
# Type aliases
UserId = int
UserData = Dict[str, Union[str, int]]

# Generics
T = TypeVar('T')
class Container(Generic[T]):
    def __init__(self, value: T) -> None:
        self._value = value

# Protocols
class Drawable(Protocol):
    def draw(self) -> str: ...
```

### Bandit Custom Rules

```python
# .bandit
{
    "exclude_dirs": ["tests/", "venv/"],
    "skips": ["B101", "B601"],
    "tests": ["B201", "B301"]
}
```

## 🏆 Expert Tips

### 🔥 Pro Tips
- **Black + isort combo**: Use `isort --profile black` for perfect compatibility
- **Incremental adoption**: Start with formatting tools, add type checking later
- **Custom error codes**: Use `# noqa: E501` to ignore specific violations
- **Tool order**: Run isort → black → flake8 → mypy → bandit
- **IDE integration**: Set up tools in your editor for real-time feedback

### 🎯 Common Pitfalls
- **Over-configuration**: Keep configurations simple and consistent
- **Ignoring security**: Don't disable security checks without good reason
- **Type annotation overuse**: Start simple, add complexity gradually
- **Team resistance**: Introduce tools gradually with team input
- **CI/CD bottlenecks**: Optimize tool runs for fast feedback

## 🛠️ Requirements

- Python 3.7+
- pip or conda for package management

### Core Tools
```bash
pip install bandit safety flake8 black isort mypy
```

### Optional Plugins
```bash
pip install flake8-bugbear flake8-docstrings flake8-naming
pip install types-requests types-PyYAML  # MyPy stub packages
```

## 📚 Additional Resources

- [Bandit Documentation](https://bandit.readthedocs.io/)
- [Safety Documentation](https://pyup.io/safety/)
- [Flake8 Documentation](https://flake8.pycqa.org/)
- [Black Documentation](https://black.readthedocs.io/)
- [isort Documentation](https://pycqa.github.io/isort/)
- [MyPy Documentation](https://mypy.readthedocs.io/)

## 🤝 Contributing

This tutorial is designed to be self-contained and comprehensive. To improve or extend:

1. Follow existing patterns and examples
2. Test all code examples thoroughly
3. Update documentation for any changes
4. Ensure compatibility across tool versions

## 📄 License

Educational material provided for learning purposes. Feel free to use, modify, and distribute.

---

**Ready to write better Python code?** 🐍✨

Run `./run_tutorial.sh` to begin your journey to Python code quality mastery!
