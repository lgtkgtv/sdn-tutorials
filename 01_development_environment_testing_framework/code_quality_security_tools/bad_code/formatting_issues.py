"""
BAD CODE: Formatting Issues (black will fix these)
This file has inconsistent formatting that black will clean up
"""

# Inconsistent string quotes
name='John'
message="Hello world"
doc_string='''This is a
multiline string'''

# Inconsistent spacing around operators
result=x+y*z
another_result = a   +    b
complex_calc=( x + y ) * ( a - b )

# Inconsistent function definitions
def function1(x,y,z):
    return x+y+z

def function2( x, y, z ):
    return x + y + z

def function3(
    x,
    y,
    z
):
    return x + y + z

# Inconsistent dictionary formatting
user={'name':'John','age':30,'city':'New York'}

user2 = {
    'name': 'Jane',
    'age'  : 25,
    'city':'Boston'
}

user3 = { 'name' : 'Bob' , 'age' : 35 , 'city' : 'Chicago' }

# Inconsistent list formatting
numbers=[1,2,3,4,5,6,7,8,9,10]
names = ['Alice',  'Bob',   'Charlie']
mixed_list = [
    1, 'two', 3.0,
    True,
        False,
    None
]

# Inconsistent function calls
result1=function(arg1,arg2,arg3)
result2 = function( arg1 , arg2 , arg3 )
result3 = function(
    arg1,
        arg2,
    arg3
)

# Long lines that should be wrapped
very_long_function_call_with_many_arguments = some_function(argument1, argument2, argument3, argument4, argument5, argument6, argument7)

# Inconsistent conditional formatting
if x==5:print("five")
if x == 5: print( "five" )
if x == 5 :
    print("five")

if   condition1   and   condition2   or   condition3:
    do_something()

# Inconsistent class definition
class MyClass:
    def __init__(self,name):
        self.name=name
    def get_name( self ):
        return self.name

class   AnotherClass  :
    def __init__( self, name, age ):
        self.name = name
        self.age=age

# Inconsistent lambda formatting
square=lambda x:x*x
add = lambda x, y : x + y
multiply = lambda x,y: x*y

# Inconsistent comprehensions
squares=[x*x for x in range(10)]
evens = [ x for x in range( 20 ) if x % 2 == 0 ]
dictionary={ x: x**2 for x in range(5)}

# Inconsistent exception handling
try:
    risky_operation()
except Exception as e:
    handle_error(e)
except   ValueError   as   ve  :
    handle_value_error(ve)

# Inconsistent imports (black will sort these too)
import sys,os
from typing import List,Dict,Optional
import json
from pathlib import Path
import re

# Functions that black will reformat
def messy_function(param1,param2,param3="default",*args,**kwargs):
    """This function has messy formatting"""
    
    if param1 is not None and param2>0:
        result=process_data(param1,param2)
        return result
    elif param3=="special":
        return special_processing(*args,**kwargs)
    else:
        return None

def process_data(x,y):
    return x*y+10

def special_processing(*args,**kwargs):
    return "special"

# Trailing commas inconsistency
data = [
    'item1',
    'item2',
    'item3'  # Missing trailing comma
]

config = {
    'host': 'localhost',
    'port': 5432,
    'ssl': True,  # Has trailing comma
}

# String concatenation that could be formatted better
message = "Hello " + \
          "world " + \
          "from " + \
          "Python"

# This file will look completely different after running black!
if __name__=="__main__":
    print("Run 'black formatting_issues.py' to see the magic!")