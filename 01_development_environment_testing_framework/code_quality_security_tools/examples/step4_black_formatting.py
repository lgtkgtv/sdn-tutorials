"""
Step 4: Black - Code Formatting
Learn how Black automatically formats your Python code for consistency

Run: black --diff examples/step4_black_formatting.py
Run: black examples/step4_black_formatting.py
"""

# This file intentionally has inconsistent formatting
# Black will reformat it automatically

import os,sys,json
from typing import List,Dict,Optional
import requests
from pathlib import Path
import re

# Inconsistent string quotes
name='John'
message="Hello world"
doc_string='''Multi
line string'''

# Inconsistent spacing
result=x+y*z if 'x' in globals() and 'y' in globals() and 'z' in globals() else 0
another_result = a   +    b if 'a' in globals() and 'b' in globals() else 0

# Function definitions with inconsistent spacing
def function1(x,y,z):
    return x+y+z

def function2( x, y, z ):
    return x + y + z

def function3(
    very_long_parameter_name,
    another_long_parameter_name,
    third_parameter
):
    return very_long_parameter_name + another_long_parameter_name + third_parameter

# Inconsistent dictionary formatting
user={'name':'John','age':30,'city':'New York','occupation':'Developer'}

user2 = {
    'name': 'Jane',
    'age'  : 25,
    'city':'Boston',
    'occupation' : 'Designer'
}

user3 = { 'name' : 'Bob' , 'age' : 35 , 'city' : 'Chicago' }

# List formatting issues
numbers=[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15]
names = ['Alice',  'Bob',   'Charlie',    'David']
mixed_list = [
    1, 'two', 3.0,
    True,
        False,
    None, {'key': 'value'}
]

# Function calls with inconsistent formatting
result1=some_function(arg1,arg2,arg3)
result2 = some_function( arg1 , arg2 , arg3 )
result3 = some_function(
    very_long_argument_name,
        another_long_argument,
    third_argument
)

def some_function(arg1, arg2, arg3):
    return f"{arg1}-{arg2}-{arg3}"

# Long lines that need wrapping
very_long_function_call_that_exceeds_line_length = some_other_function(argument1, argument2, argument3, argument4, argument5, argument6, argument7, argument8)

def some_other_function(*args):
    return "-".join(str(arg) for arg in args)

# Conditionals with bad formatting
if name=='John':print("Hello John")
if name == 'Jane': print( "Hello Jane" )
if name == 'Bob' :
    print("Hello Bob")

# Multiple conditions
if   name == 'Alice'   and   age > 18   or   city == 'Boston':
    do_something()

def do_something():
    print("Doing something...")

# Class definitions
class BadlyFormattedClass:
    def __init__(self,name,age):
        self.name=name
        self.age=age
        
    def get_info( self ):
        return f"{self.name} ({self.age})"
    
    def process_data(self,data,options={}):
        if not data:return None
        
        result=[]
        for item in data:
            if item in options:result.append(options[item])
            else:result.append(item)
        return result

# Lambda functions with inconsistent formatting
square=lambda x:x*x
add = lambda x, y : x + y
multiply = lambda x,y: x*y

# Comprehensions
squares=[x*x for x in range(10) if x%2==0]
evens = [ x for x in range( 20 ) if x % 2 == 0 ]
dictionary={ x: x**2 for x in range(5) if x>2}

# Exception handling
try:
    risky_operation()
except Exception as e:handle_error(e)
except   ValueError   as   ve  :
    handle_value_error(ve)

def risky_operation():
    raise ValueError("Something went wrong")

def handle_error(e):
    print(f"Error: {e}")

def handle_value_error(ve):
    print(f"Value error: {ve}")

# Imports that should be organized
from collections import defaultdict,Counter
import subprocess
from datetime import datetime,timedelta

# Trailing commas inconsistency
data_without_trailing_comma = [
    'item1',
    'item2',
    'item3'
]

data_with_trailing_comma = [
    'item1',
    'item2', 
    'item3',
]

config = {
    'host': 'localhost',
    'port': 5432,
    'ssl': True
}

# String concatenation and formatting
message = "Hello " + \
          "world " + \
          "from " + \
          "Python"

formatted_string = "User: %s, Age: %d, City: %s" % (name, 30, 'Boston')

# Complex expressions
complex_calculation = (
    (a * b + c / d) ** 2 if 'a' in globals() and 'b' in globals() 
    and 'c' in globals() and 'd' in globals() else 0
) - (
    x * y - z if 'x' in globals() and 'y' in globals() 
    and 'z' in globals() else 1
)

def demonstrate_black_features():
    """Show what Black does automatically"""
    
    features = {
        "String Quotes": "Normalizes to double quotes",
        "Line Length": "Wraps long lines (default 88 chars)",
        "Indentation": "Uses 4 spaces consistently", 
        "Trailing Commas": "Adds them in multi-line structures",
        "Whitespace": "Consistent spacing around operators",
        "Function Calls": "Formats arguments consistently",
        "Collections": "Formats lists, dicts, sets consistently",
        "Imports": "Basic import formatting (use isort for full sorting)"
    }
    
    print("Black automatically handles:")
    for feature, description in features.items():
        print(f"  • {feature}: {description}")


def black_configuration():
    """Show Black configuration options"""
    
    config_examples = {
        "pyproject.toml": """
[tool.black]
line-length = 88
target-version = ['py38']
include = '\\.pyi?$'
exclude = '''
/(
    \\.eggs
  | \\.git
  | \\.venv
  | _build
  | build
  | dist
  | migrations
)/
'''
""",
        
        "Command line options": """
# Basic formatting
black file.py

# Check what would change (don't modify)
black --diff file.py

# Format entire project
black .

# Specify line length
black --line-length 100 file.py

# Target specific Python version
black --target-version py38 file.py

# Quiet mode (less output)
black --quiet file.py

# Verbose mode (more output)
black --verbose file.py
"""
    }
    
    print("\nBlack Configuration:")
    for name, config in config_examples.items():
        print(f"\n{name}:")
        print(config)


def black_vs_other_formatters():
    """Compare Black with other Python formatters"""
    
    comparison = {
        "Black": {
            "Philosophy": "Uncompromising, minimal configuration",
            "Line Length": "88 characters default",
            "Style": "Opinionated, consistent",
            "Speed": "Very fast",
            "Configuration": "Minimal options"
        },
        "autopep8": {
            "Philosophy": "Fix PEP 8 violations",
            "Line Length": "79 characters default",
            "Style": "Conservative, PEP 8 focused",
            "Speed": "Moderate",
            "Configuration": "Many options"
        },
        "yapf": {
            "Philosophy": "Configurable formatting",
            "Line Length": "80 characters default",
            "Style": "Highly configurable",
            "Speed": "Slower",
            "Configuration": "Extensive options"
        }
    }
    
    print("\nFormatter Comparison:")
    for formatter, features in comparison.items():
        print(f"\n{formatter}:")
        for feature, description in features.items():
            print(f"  {feature}: {description}")


def integration_examples():
    """Show how to integrate Black into development workflow"""
    
    integrations = {
        "Pre-commit hook": """
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/psf/black
    rev: 23.1.0
    hooks:
      - id: black
        language_version: python3.8
""",
        
        "GitHub Actions": """
# .github/workflows/format.yml
name: Format Code
on: [push, pull_request]
jobs:
  format:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    - name: Set up Python
      uses: actions/setup-python@v2
      with:
        python-version: 3.8
    - name: Install Black
      run: pip install black
    - name: Check formatting
      run: black --check --diff .
""",
        
        "VS Code settings": """
{
    "python.formatting.provider": "black",
    "python.formatting.blackArgs": ["--line-length=88"],
    "editor.formatOnSave": true,
    "[python]": {
        "editor.formatOnSave": true
    }
}
""",
        
        "Vim/Neovim": """
\" Install vim-black plugin
\" Add to .vimrc or init.vim:
autocmd BufWritePre *.py execute ':Black'

\" Or use with ALE:
let g:ale_fixers = {
\\   'python': ['black'],
\\}
let g:ale_fix_on_save = 1
""",
        
        "Makefile": """
.PHONY: format format-check
format:
\tblack .

format-check:
\tblack --check --diff .

# Combined with other tools
quality: format-check lint test
\techo "All quality checks passed"
"""
    }
    
    print("\nIntegration Examples:")
    for name, config in integrations.items():
        print(f"\n{name}:")
        print(config)


def black_with_other_tools():
    """Show how Black works with other code quality tools"""
    
    tool_configs = {
        "flake8": """
# .flake8 or setup.cfg
[flake8]
max-line-length = 88
extend-ignore = E203, W503
""",
        
        "isort": """
# pyproject.toml
[tool.isort]
profile = "black"
multi_line_output = 3
include_trailing_comma = true
force_grid_wrap = 0
use_parentheses = true
ensure_newline_before_comments = true
line_length = 88
""",
        
        "mypy": """
# mypy.ini
[mypy]
python_version = 3.8
warn_return_any = True
warn_unused_configs = True
disallow_untyped_defs = True
""",
        
        "pre-commit combined": """
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
        additional_dependencies: [flake8-bugbear]
"""
    }
    
    print("\nTool Integration Configurations:")
    for tool, config in tool_configs.items():
        print(f"\n{tool}:")
        print(config)


def before_after_example():
    """Show before/after formatting example"""
    
    before = '''
def badly_formatted_function(x,y,z,a=None,b=None,c=None):
    if x>0 and y>0:result=x+y*z
    else:result=0
    return result

data={'key1':'value1','key2':'value2','key3':'value3','key4':'value4'}
list_data=[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20]
'''
    
    after = '''
def badly_formatted_function(x, y, z, a=None, b=None, c=None):
    if x > 0 and y > 0:
        result = x + y * z
    else:
        result = 0
    return result


data = {
    "key1": "value1",
    "key2": "value2", 
    "key3": "value3",
    "key4": "value4",
}
list_data = [
    1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20
]
'''
    
    print("\nBefore/After Example:")
    print("\nBEFORE (badly formatted):")
    print(before)
    print("\nAFTER (Black formatted):")
    print(after)


if __name__=="__main__":
    print("="*60)
    print("Step 4: Black - Code Formatting")
    print("="*60)
    
    print("\n🎨 Black Features:")
    demonstrate_black_features()
    
    print("\n⚙️ Configuration:")
    black_configuration()
    
    print("\n🔍 Formatter Comparison:")
    black_vs_other_formatters()
    
    print("\n🔗 Integration:")
    integration_examples()
    
    print("\n🤝 Tool Compatibility:")
    black_with_other_tools()
    
    print("\n📝 Before/After:")
    before_after_example()
    
    print("\n"+"="*60)
    print("Try these commands:")
    print("  black --diff examples/step4_black_formatting.py")
    print("  black examples/step4_black_formatting.py")
    print("="*60)