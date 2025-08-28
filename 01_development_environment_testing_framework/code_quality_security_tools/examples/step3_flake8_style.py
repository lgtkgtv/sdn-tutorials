"""
Step 3: Flake8 - Style and Quality Checking
Learn how to enforce Python code style and catch common programming errors

Run: flake8 examples/step3_flake8_style.py
Run: flake8 examples/step3_flake8_style.py --statistics
Run: flake8 examples/step3_flake8_style.py --show-source
"""

import os,sys # E401: multiple imports on one line
import requests  # F401: imported but unused
from typing import List,Dict # E401: multiple imports on one line


# E302: expected 2 blank lines, found 1
class FlakeStyleDemo:
    """Demonstrate various flake8 style issues"""
    
    def __init__(self,name): # E211: whitespace before '('
        self.name=name # E225: missing whitespace around operator
    
    def get_info(self ):  # E201: whitespace after '('
        return f"Name: {self.name}"

# Missing blank line before function (E302)
def demonstrate_common_issues():
    """Show the most common flake8 violations"""
    
    # E501: line too long (over 79 characters by default)
    very_long_variable_name = "This is a very long string that exceeds the default line length limit and will trigger E501"
    
    # E302: expected 2 blank lines after class definition
    
    # E711: comparison to True should be 'if cond is True:'
    if very_long_variable_name == True:
        pass
    
    # E712: comparison to False should be 'if cond is False:'
    if very_long_variable_name == False:
        pass
    
    # E713: test for membership should be 'not in'
    if not "test" in very_long_variable_name:
        pass
    
    # E714: test for object identity should be 'is not'
    if not very_long_variable_name is None:
        pass


def show_whitespace_issues():
    """Demonstrate whitespace-related violations"""
    
    # E201: whitespace after '('
    result = function_call( arg1, arg2 )
    
    # E202: whitespace before ')'  
    another_result = function_call(arg1, arg2 )
    
    # E203: whitespace before ':'
    my_dict = {'key' : 'value'}
    
    # E225: missing whitespace around operator
    x=1+2*3
    y= 4+5
    z =6+7
    
    # E226: missing whitespace around arithmetic operator
    result=x+y*z
    
    # E261: at least two spaces before inline comment
    x = 1# This comment needs more spaces
    
    return result


def function_call(arg1, arg2):
    """Helper function for demonstrations"""
    return arg1 + arg2


def demonstrate_import_issues():
    """Show import-related violations"""
    
    # F401: imported but unused (requests at top)
    # The unused import will be flagged
    
    # E402: module level import not at top of file
    import json  # This should be at the top
    
    return json.dumps({"status": "ok"})


def show_complexity_issues():
    """Function with high cyclomatic complexity (C901)"""
    
    # This function has too many branches and will trigger complexity warnings
    data = get_some_data()
    
    if data:
        if data.get('type') == 'A':
            if data.get('subtype') == '1':
                if data.get('status') == 'active':
                    if data.get('priority') == 'high':
                        return handle_a1_active_high()
                    else:
                        return handle_a1_active_normal()
                else:
                    return handle_a1_inactive()
            else:
                return handle_a_other()
        elif data.get('type') == 'B':
            if data.get('status') == 'active':
                return handle_b_active()
            else:
                return handle_b_inactive()
        else:
            return handle_unknown_type()
    else:
        return handle_no_data()


def get_some_data():
    return {'type': 'A', 'subtype': '1', 'status': 'active', 'priority': 'high'}


def handle_a1_active_high(): return "a1_active_high"
def handle_a1_active_normal(): return "a1_active_normal"
def handle_a1_inactive(): return "a1_inactive"
def handle_a_other(): return "a_other"
def handle_b_active(): return "b_active"
def handle_b_inactive(): return "b_inactive"
def handle_unknown_type(): return "unknown"
def handle_no_data(): return "no_data"


def show_variable_naming_issues():
    """Demonstrate variable naming problems"""
    
    # E741: ambiguous variable name
    l = [1, 2, 3]  # 'l' looks like '1'
    O = 0          # 'O' looks like '0'  
    I = 1          # 'I' looks like '1'
    
    # F841: local variable is assigned to but never used
    unused_variable = "This variable is never used"
    
    # Use some variables to avoid more F841 errors
    result = len(l) + O + I
    return result


def demonstrate_configuration_options():
    """Show how to configure flake8"""
    
    config_examples = {
        "setup.cfg": """
[flake8]
max-line-length = 88
exclude = 
    .git,
    __pycache__,
    venv,
    .venv,
    migrations
ignore = 
    E203,  # whitespace before ':'
    W503,  # line break before binary operator
select = E,W,F,C
max-complexity = 10
per-file-ignores =
    __init__.py:F401
    tests/*:F401,F811
""",
        
        ".flake8": """
[flake8]
max-line-length = 88
extend-ignore = E203, W503
exclude = venv, .venv, __pycache__
max-complexity = 10
""",
        
        "pyproject.toml": """
[tool.flake8]
max-line-length = 88
extend-ignore = ["E203", "W503"]
exclude = ["venv", ".venv", "__pycache__"]
max-complexity = 10
"""
    }
    
    print("Flake8 Configuration Examples:")
    for filename, config in config_examples.items():
        print(f"\n{filename}:")
        print(config)


def explain_error_codes():
    """Explain common flake8 error codes"""
    
    error_codes = {
        "E": "PEP 8 Style Errors",
        "E1": "Indentation errors",
        "E2": "Whitespace errors", 
        "E3": "Blank line errors",
        "E4": "Import errors",
        "E5": "Line length errors",
        "E7": "Statement errors",
        "E9": "Runtime errors",
        
        "W": "PEP 8 Style Warnings",
        "W1": "Indentation warnings",
        "W2": "Whitespace warnings",
        "W3": "Blank line warnings",
        "W5": "Line length warnings",
        "W6": "Deprecation warnings",
        
        "F": "PyFlakes Errors",
        "F4": "Import errors",
        "F6": "Variable/name errors", 
        "F8": "Unused variables",
        
        "C": "McCabe Complexity",
        "C9": "Complexity errors",
        
        "N": "Naming Conventions (with flake8-naming)",
        "B": "Bugbear (with flake8-bugbear)",
    }
    
    print("\nFlake8 Error Code Categories:")
    for code, description in error_codes.items():
        print(f"  {code}: {description}")


def show_common_fixes():
    """Show how to fix common flake8 issues"""
    
    fixes = {
        "E401 - Multiple imports": {
            "bad": "import os, sys",
            "good": "import os\nimport sys"
        },
        
        "E225 - Missing whitespace around operator": {
            "bad": "x=1+2",
            "good": "x = 1 + 2"
        },
        
        "E302 - Expected 2 blank lines": {
            "bad": "class MyClass:\n    pass\ndef my_function():\n    pass",
            "good": "class MyClass:\n    pass\n\n\ndef my_function():\n    pass"
        },
        
        "E501 - Line too long": {
            "bad": "very_long_function_call(arg1, arg2, arg3, arg4, arg5, arg6)",
            "good": "very_long_function_call(\n    arg1, arg2, arg3,\n    arg4, arg5, arg6\n)"
        },
        
        "F401 - Unused import": {
            "bad": "import unused_module\nprint('hello')",
            "good": "print('hello')"
        }
    }
    
    print("\nCommon Fixes:")
    for issue, examples in fixes.items():
        print(f"\n{issue}:")
        print(f"  ❌ Bad:  {examples['bad']}")
        print(f"  ✅ Good: {examples['good']}")


def flake8_plugins():
    """Show useful flake8 plugins"""
    
    plugins = {
        "flake8-bugbear": "Find likely bugs and design problems",
        "flake8-docstrings": "Check docstring conventions",
        "flake8-import-order": "Check import order",
        "flake8-naming": "Check naming conventions",
        "flake8-type-checking": "Handle type checking imports",
        "flake8-comprehensions": "Improve list/dict/set comprehensions",
        "flake8-simplify": "Suggest simplifications",
        "flake8-bandit": "Security linting (alternative to bandit)",
        "flake8-pytest-style": "Check pytest style",
        "flake8-annotations": "Check type annotations"
    }
    
    print("\nUseful Flake8 Plugins:")
    for plugin, description in plugins.items():
        print(f"  {plugin}: {description}")
    
    print("\nInstallation:")
    print("  pip install flake8-bugbear flake8-docstrings flake8-naming")


def integration_examples():
    """Show how to integrate flake8 into development workflow"""
    
    integrations = {
        "Pre-commit hook": """
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/PyCQA/flake8
    rev: 6.0.0
    hooks:
      - id: flake8
        additional_dependencies: [flake8-bugbear, flake8-docstrings]
""",
        
        "GitHub Actions": """
# .github/workflows/lint.yml
name: Lint
on: [push, pull_request]
jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    - name: Set up Python
      uses: actions/setup-python@v2
      with:
        python-version: 3.9
    - name: Install flake8
      run: pip install flake8
    - name: Run flake8
      run: flake8 .
""",
        
        "VS Code settings": """
{
    "python.linting.flake8Enabled": true,
    "python.linting.enabled": true,
    "python.linting.flake8Args": ["--max-line-length=88"]
}
""",
        
        "Makefile": """
.PHONY: lint
lint:
\tflake8 src tests
\t
check: lint
\techo "Code quality checks passed"
"""
    }
    
    print("\nIntegration Examples:")
    for name, config in integrations.items():
        print(f"\n{name}:")
        print(config)


# E265: block comment should start with '# '
#This comment violates E265

# W291: trailing whitespace (imagine spaces at end of next line)
trailing_space_line = "This line has trailing whitespace"   

if __name__ == "__main__":
    print("=" * 60)
    print("Step 3: Flake8 - Style and Quality Checking")
    print("=" * 60)
    
    print("\n🔍 Demonstrating common flake8 violations...")
    
    # These function calls will demonstrate the issues
    demonstrate_common_issues()
    show_whitespace_issues() 
    demonstrate_import_issues()
    show_variable_naming_issues()
    
    print("\n📚 Error Codes:")
    explain_error_codes()
    
    print("\n🔧 Common Fixes:")
    show_common_fixes()
    
    print("\n⚙️ Configuration:")
    demonstrate_configuration_options()
    
    print("\n🧩 Plugins:")
    flake8_plugins()
    
    print("\n🔗 Integration:")
    integration_examples()
    
    print("\n" + "=" * 60)
    print("Run 'flake8 examples/step3_flake8_style.py' to see issues!")
    print("Try: flake8 examples/step3_flake8_style.py --statistics")
    print("=" * 60)

# W292: no newline at end of file (this file will end without newline)