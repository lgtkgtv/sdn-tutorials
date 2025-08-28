"""
Step 5: isort - Import Organization
Learn how isort automatically organizes and sorts your Python imports

Run: isort --diff examples/step5_isort_imports.py
Run: isort examples/step5_isort_imports.py
"""

# This file has intentionally disorganized imports
# isort will reorganize them according to PEP 8 standards

# BAD: Imports are completely mixed up and out of order
from typing import Dict, List, Optional
import sys
from pathlib import Path
import os
from collections import defaultdict, Counter
import json
from datetime import datetime, timedelta
import requests
from urllib.parse import urlparse
import sqlite3
from flask import Flask, request, jsonify
import re
from dataclasses import dataclass
import subprocess
from enum import Enum
import tempfile
from abc import ABC, abstractmethod
import logging
from concurrent.futures import ThreadPoolExecutor
import threading
from queue import Queue
import asyncio
from typing import Union, Any
import hashlib
from contextlib import contextmanager
import shutil
from functools import lru_cache, wraps
import time
import uuid
from io import StringIO
import csv
from email.mime.text import MIMEText
import smtplib
from configparser import ConfigParser
import argparse

# BAD: Third-party mixed with local imports
from my_local_module import helper_function
import numpy as np
from my_package.submodule import MyClass
import pandas as pd
from . import local_utils
from ..parent_module import parent_function

# BAD: Unused imports that should be removed
import unused_module1
from unused_module2 import unused_function

# BAD: Star imports (discouraged, but isort will organize them)
from os import *


def demonstrate_import_organization():
    """Show how isort organizes imports"""
    
    organization_rules = {
        "Standard Library": [
            "Built-in modules like os, sys, json",
            "Standard library modules",
            "Sorted alphabetically"
        ],
        "Third Party": [
            "External packages like requests, numpy",
            "Installed via pip/conda",
            "Sorted alphabetically"
        ],
        "Local/First Party": [
            "Your own modules and packages",
            "Relative imports",
            "Sorted alphabetically"
        ]
    }
    
    print("Import Organization (PEP 8 Style):")
    for category, rules in organization_rules.items():
        print(f"\n{category}:")
        for rule in rules:
            print(f"  • {rule}")


def show_isort_profiles():
    """Demonstrate different isort profiles"""
    
    profiles = {
        "black": "Compatible with Black formatter",
        "google": "Google style guide",
        "open_stack": "OpenStack style guide", 
        "pycharm": "PyCharm IDE style",
        "pep8": "Strict PEP 8 style",
        "django": "Django project style",
        "hanging_indent": "Hanging indent style"
    }
    
    print("\nIsort Profiles:")
    for profile, description in profiles.items():
        print(f"  {profile}: {description}")
    
    print("\nUsage:")
    print("  isort --profile black file.py")
    print("  isort --profile google file.py")


def demonstrate_configuration():
    """Show isort configuration options"""
    
    config_examples = {
        ".isort.cfg": """
[settings]
profile = black
multi_line_output = 3
line_length = 88
include_trailing_comma = True
force_grid_wrap = 0
use_parentheses = True
ensure_newline_before_comments = True
known_first_party = myapp,mypackage
known_third_party = requests,numpy,pandas
skip = migrations,venv,.venv
""",
        
        "pyproject.toml": """
[tool.isort]
profile = "black"
multi_line_output = 3
line_length = 88
include_trailing_comma = true
force_grid_wrap = 0
use_parentheses = true
ensure_newline_before_comments = true
known_first_party = ["myapp", "mypackage"]
known_third_party = ["requests", "numpy", "pandas"]
skip = ["migrations", "venv", ".venv"]
""",
        
        "setup.cfg": """
[isort]
profile = black
multi_line_output = 3
line_length = 88
include_trailing_comma = True
force_grid_wrap = 0
use_parentheses = True
ensure_newline_before_comments = True
known_first_party = myapp,mypackage
sections = FUTURE,STDLIB,THIRDPARTY,FIRSTPARTY,LOCALFOLDER
"""
    }
    
    print("\nConfiguration Examples:")
    for filename, config in config_examples.items():
        print(f"\n{filename}:")
        print(config)


def show_multi_line_output_styles():
    """Demonstrate different multi-line import styles"""
    
    styles = {
        "Style 0 (Grid)": """
from third_party import (alpha, bravo, charlie, delta,
                         echo, foxtrot, golf, hotel)
""",
        
        "Style 1 (Grouped)": """
from third_party import (alpha, bravo, charlie, delta, echo,
                         foxtrot, golf, hotel)
""",
        
        "Style 2 (Hanging Indent)": """
from third_party import \\
    alpha, bravo, charlie, delta, echo, foxtrot, golf, hotel
""",
        
        "Style 3 (Vertical Hanging Indent)": """
from third_party import (
    alpha,
    bravo,
    charlie,
    delta,
    echo,
    foxtrot,
    golf,
    hotel
)
""",
        
        "Style 4 (Hanging Grid Grouped)": """
from third_party import (
    alpha, bravo, charlie, delta,
    echo, foxtrot, golf, hotel
)
""",
        
        "Style 5 (No Line Wrap)": """
from third_party import alpha, bravo, charlie, delta, echo, foxtrot, golf, hotel
"""
    }
    
    print("\nMulti-line Import Styles:")
    for style, example in styles.items():
        print(f"\n{style}:")
        print(example.strip())


def command_line_examples():
    """Show various isort command line options"""
    
    commands = {
        "Basic Operations": [
            "isort file.py  # Sort imports in file",
            "isort .  # Sort imports in all Python files",
            "isort --diff file.py  # Show what would change",
            "isort --check-only file.py  # Check if sorted (exit code)"
        ],
        
        "Configuration": [
            "isort --profile black file.py  # Use Black profile",
            "isort --line-length 100 file.py  # Set line length",
            "isort --multi-line 3 file.py  # Set multi-line style",
            "isort --trailing-comma file.py  # Add trailing commas"
        ],
        
        "Output Control": [
            "isort --quiet file.py  # Quiet mode",
            "isort --verbose file.py  # Verbose output",
            "isort --atomic file.py  # Atomic file operations",
            "isort --stdout file.py  # Print to stdout"
        ],
        
        "Filtering": [
            "isort --skip __init__.py  # Skip specific files",
            "isort --filter-files  # Filter out untracked files",
            "isort --gitignore  # Respect .gitignore",
            "isort --extend-skip venv  # Additional skip patterns"
        ]
    }
    
    print("\nCommand Line Examples:")
    for category, command_list in commands.items():
        print(f"\n{category}:")
        for command in command_list:
            print(f"  {command}")


def integration_examples():
    """Show integration with other tools and workflows"""
    
    integrations = {
        "Pre-commit hook": """
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/pycqa/isort
    rev: 5.12.0
    hooks:
      - id: isort
        args: ["--profile", "black", "--filter-files"]
""",
        
        "GitHub Actions": """
# .github/workflows/imports.yml
name: Check Import Order
on: [push, pull_request]
jobs:
  imports:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    - name: Set up Python
      uses: actions/setup-python@v2
      with:
        python-version: 3.9
    - name: Install isort
      run: pip install isort
    - name: Check import order
      run: isort --check-only --diff .
""",
        
        "VS Code settings": """
{
    "python.sortImports.provider": "isort",
    "python.sortImports.args": ["--profile", "black"],
    "editor.codeActionsOnSave": {
        "source.organizeImports": true
    }
}
""",
        
        "Combined with Black": """
# Makefile
.PHONY: format
format:
\tisort .
\tblack .
\t
format-check:
\tisort --check-only --diff .
\tblack --check --diff .
""",
        
        "tox configuration": """
# tox.ini
[testenv:format]
deps = 
    isort
    black
commands = 
    isort {posargs:.}
    black {posargs:.}
    
[testenv:format-check]
deps = 
    isort
    black
commands = 
    isort --check-only --diff {posargs:.}
    black --check --diff {posargs:.}
"""
    }
    
    print("\nIntegration Examples:")
    for name, config in integrations.items():
        print(f"\n{name}:")
        print(config)


def advanced_features():
    """Show advanced isort features"""
    
    features = {
        "Force Single Line": """
# Before
from mypackage import alpha, bravo, charlie

# After (with --force-single-line)
from mypackage import alpha
from mypackage import bravo
from mypackage import charlie
""",
        
        "Force Grid Wrap": """
# Before
from mypackage import alpha, bravo

# After (with --force-grid-wrap=2)
from mypackage import (
    alpha,
    bravo
)
""",
        
        "Add Imports": """
# Command: isort --add-import "from __future__ import annotations"
# Adds the import to all files
""",
        
        "Remove Imports": """
# Command: isort --rm-import "from typing import Dict"  
# Removes the import from all files
""",
        
        "Known Sections": """
[tool.isort]
known_first_party = ["myproject"]
known_third_party = ["requests", "numpy"] 
known_django = ["django"]
known_pytest = ["pytest", "pytest_django"]
sections = ["FUTURE", "STDLIB", "DJANGO", "THIRDPARTY", "PYTEST", "FIRSTPARTY", "LOCALFOLDER"]
"""
    }
    
    print("\nAdvanced Features:")
    for feature, example in features.items():
        print(f"\n{feature}:")
        print(example.strip())


def troubleshooting():
    """Common isort issues and solutions"""
    
    issues = {
        "Import not recognized as third-party": {
            "problem": "Package appears in wrong section",
            "solution": "Add to known_third_party in config"
        },
        
        "Conflicts with Black": {
            "problem": "isort and Black disagree on formatting",
            "solution": "Use isort profile 'black'"
        },
        
        "Skip certain files": {
            "problem": "Need to ignore specific files",
            "solution": "Use skip or extend-skip in config"
        },
        
        "Long import lines": {
            "problem": "Imports exceed line length",
            "solution": "Adjust multi_line_output and line_length"
        },
        
        "Import order changes unexpectedly": {
            "problem": "isort reorganizes imports differently",
            "solution": "Check and configure sections order"
        }
    }
    
    print("\nTroubleshooting:")
    for issue, details in issues.items():
        print(f"\n{issue}:")
        print(f"  Problem: {details['problem']}")
        print(f"  Solution: {details['solution']}")


def before_after_example():
    """Show before/after import organization"""
    
    before = '''# Disorganized imports
from typing import Dict
import sys
from pathlib import Path
import os
import requests
from my_module import helper
from collections import defaultdict
import json
from . import local_utils
import numpy as np
'''
    
    after = '''# Organized imports (isort with black profile)
import json
import os
import sys
from collections import defaultdict
from pathlib import Path
from typing import Dict

import numpy as np
import requests

from my_module import helper

from . import local_utils
'''
    
    print("\nBefore/After Example:")
    print("\nBEFORE (disorganized):")
    print(before.strip())
    print("\nAFTER (isort organized):")
    print(after.strip())


# Some example usage of the imports to avoid unused import warnings
def example_usage():
    """Example function using some of the imports"""
    
    # Use some standard library imports
    current_time = datetime.now()
    temp_dir = tempfile.mkdtemp()
    
    # Use some data structures
    counter = Counter([1, 2, 2, 3, 3, 3])
    default_dict = defaultdict(list)
    
    # Use some third-party (if available)
    try:
        import requests
        response = requests.get('https://httpbin.org/json')
        data = response.json()
    except ImportError:
        data = {'status': 'requests not available'}
    
    return {
        'time': current_time.isoformat(),
        'temp_dir': temp_dir,
        'counter': dict(counter),
        'data': data
    }


if __name__ == "__main__":
    print("=" * 60)
    print("Step 5: isort - Import Organization")
    print("=" * 60)
    
    print("\n📚 Import Organization:")
    demonstrate_import_organization()
    
    print("\n🎨 Profiles:")
    show_isort_profiles()
    
    print("\n⚙️ Configuration:")
    demonstrate_configuration()
    
    print("\n📝 Multi-line Styles:")
    show_multi_line_output_styles()
    
    print("\n💻 Command Line:")
    command_line_examples()
    
    print("\n🔗 Integration:")
    integration_examples()
    
    print("\n🚀 Advanced Features:")
    advanced_features()
    
    print("\n🔧 Troubleshooting:")
    troubleshooting()
    
    print("\n📋 Before/After:")
    before_after_example()
    
    # Show example usage
    print("\n🧪 Testing imports:")
    result = example_usage()
    print(f"Example result: {result['time'][:19]}")
    
    print("\n" + "=" * 60)
    print("Try these commands:")
    print("  isort --diff examples/step5_isort_imports.py")
    print("  isort --profile black examples/step5_isort_imports.py")
    print("=" * 60)