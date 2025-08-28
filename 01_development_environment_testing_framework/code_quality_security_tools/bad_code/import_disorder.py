"""
BAD CODE: Import Disorder (isort will fix these)
This file has poorly organized imports that violate PEP 8 import ordering
"""

# BAD: Imports are completely out of order and mixed up
from typing import Dict, List
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
from typing import Optional, Union, Any
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
from unittest import TestCase
import pytest
from unittest.mock import Mock, patch

# BAD: Local imports mixed with third-party
from my_local_module import helper_function
import numpy as np
from my_package.submodule import MyClass
import pandas as pd
from . import local_utils
from ..parent_module import parent_function

# BAD: Unused imports
import unused_module1
from unused_module2 import unused_function
import another_unused_module

# BAD: Imports inside functions (should be at module level)
def process_data():
    import json  # Should be at top
    from datetime import datetime  # Should be at top
    
    return json.dumps({'timestamp': datetime.now().isoformat()})

# BAD: Star imports (discouraged)
from os import *
from sys import *

# BAD: Multiple imports from same module on different lines
from typing import Dict
from typing import List
from typing import Optional
from typing import Union

# BAD: Very long import lines
from very.long.module.name.that.goes.on.forever.and.violates.line.length import some_function, another_function, yet_another_function, and_one_more

"""
Correct import order according to PEP 8:
1. Standard library imports
2. Related third party imports  
3. Local application/library specific imports

Within each group, imports should be:
- Alphabetically sorted
- import statements before from statements
- Each import on a separate line
"""

@dataclass
class User:
    name: str
    email: str
    age: int

class APIClient:
    def __init__(self, base_url: str):
        self.base_url = base_url
        self.session = requests.Session()
    
    def get_data(self) -> Dict[str, Any]:
        response = self.session.get(f"{self.base_url}/data")
        return response.json()

def main():
    logging.basicConfig(level=logging.INFO)
    
    # Using various imported modules
    user = User("John", "john@example.com", 30)
    client = APIClient("https://api.example.com")
    
    data = client.get_data()
    print(f"User: {user.name}, Data: {data}")

if __name__ == "__main__":
    print("This file has messy imports!")
    print("Run 'isort import_disorder.py' to organize them properly.")
    print("Or 'isort import_disorder.py --diff' to see what would change.")
    main()