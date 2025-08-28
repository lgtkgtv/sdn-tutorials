"""
BAD CODE: Style and PEP 8 Violations (flake8 will catch these)
This file intentionally violates Python style guidelines
"""

import os,sys,json # E401: Multiple imports on one line
import requests   # F401: Imported but unused
from typing import Dict,List # E401: Multiple imports on one line


# E302: Expected 2 blank lines, found 1
class BadlyFormattedClass:
    def __init__(self,name,age): # E211: Whitespace before '('
        self.name=name # E225: Missing whitespace around operator
        self.age =age  # E225: Missing whitespace around operator
    
    def get_info(self ):  # E201: Whitespace after '('
        return f"{self.name} is {self.age} years old"
        
    def process_data(self,data):
        # E501: Line too long (>79 characters)
        very_long_variable_name_that_exceeds_line_length = "This line is way too long and violates PEP 8 guidelines for maximum line length"
        
        if(data): # E711: Comparison to True should be 'if cond is True:' 
            return True
        else:
            return False # This could be simplified

# E305: Expected 2 blank lines after class
def badly_formatted_function( x,y ):  # E201, E202: Bad spacing
    # W291: Trailing whitespace   
    result=x+y  # E225: Missing whitespace
    return result


def function_with_bad_naming():
    # E741: Ambiguous variable names
    l = [1, 2, 3]  # 'l' looks like '1'
    O = 0          # 'O' looks like '0'
    I = 1          # 'I' looks like '1'
    
    # E712: Comparison to False/True
    if l == True:
        pass
    
    # E713: Test for membership should be 'not in'
    if not "item" in l:
        pass
    
    # E714: Test for object identity should be 'is not'  
    if not l is None:
        pass

def function_with_unused_variables():
    # F841: Local variable assigned but never used
    unused_variable = "This is never used"
    another_unused = calculate_something()
    
    used_variable = "This is used"
    return used_variable

def calculate_something():
    return 42

# E261: At least two spaces before inline comment
x=1# Bad comment spacing

# W292: No newline at end of file (this will be at the end)

def function_with_complexity_issues():
    """Function with high cyclomatic complexity (C901)"""
    data = get_data()
    
    # Too many nested conditions and branches
    if data:
        if data.get('type') == 'A':
            if data.get('status') == 'active':
                if data.get('priority') == 'high':
                    if data.get('category') == 'urgent':
                        return process_urgent_high_priority_a()
                    else:
                        return process_high_priority_a()
                elif data.get('priority') == 'medium':
                    return process_medium_priority_a()
                else:
                    return process_low_priority_a()
            else:
                return process_inactive_a()
        elif data.get('type') == 'B':
            if data.get('status') == 'active':
                return process_active_b()
            else:
                return process_inactive_b()
        elif data.get('type') == 'C':
            return process_c()
    else:
        return handle_no_data()

def get_data():
    return {'type': 'A', 'status': 'active', 'priority': 'high'}

def process_urgent_high_priority_a(): return "urgent_high_a"
def process_high_priority_a(): return "high_a"  
def process_medium_priority_a(): return "medium_a"
def process_low_priority_a(): return "low_a"
def process_inactive_a(): return "inactive_a"
def process_active_b(): return "active_b"
def process_inactive_b(): return "inactive_b"
def process_c(): return "c"
def handle_no_data(): return "no_data"

# E265: Block comment should start with '# '
#This comment has no space after #

# Multiple violations in one function
def multiple_violations(a,b,c):# E261: inline comment spacing
    #E265: block comment spacing
    if a==b:# E225: operator spacing, E261: inline comment
        return c+1 # E225: operator spacing
    elif a>b:# E225, E261
        return c-1# E225, E261
    else :# E203: whitespace before ':'
        return c*2# E225, E261
        
        
        
# W391: Blank line at end of file (these extra lines)