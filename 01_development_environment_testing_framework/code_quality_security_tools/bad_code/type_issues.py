"""
BAD CODE: Type Issues (mypy will catch these)
This file contains type errors and missing type annotations
"""

from typing import List, Dict, Optional, Union, Any
import json

# BAD: Missing type annotations
def calculate_area(length, width):
    return length * width

# BAD: Incorrect return type
def get_users() -> List[str]:
    # Returns dict but annotated as List[str]
    return [{"name": "John", "age": 30}, {"name": "Jane", "age": 25}]

# BAD: Type mismatch in assignment
def process_numbers():
    numbers: List[int] = [1, 2, 3, 4, 5]
    numbers = "not a list"  # Type error: str assigned to List[int]
    return numbers

# BAD: Calling method that doesn't exist
def access_invalid_attribute():
    text: str = "hello world"
    return text.append("!")  # str has no append method

# BAD: Wrong argument types
def add_numbers(a: int, b: int) -> int:
    return a + b

def call_with_wrong_types():
    result = add_numbers("5", "10")  # Passing strings instead of ints
    return result

# BAD: Optional type handling
def get_user_name(user_id: int) -> str:
    user = find_user(user_id)  # Returns Optional[Dict]
    return user["name"]  # Possible None access

def find_user(user_id: int) -> Optional[Dict[str, Any]]:
    if user_id > 0:
        return {"name": "John", "age": 30}
    return None

# BAD: Incompatible types in operations
def mixed_operations():
    name: str = "John"
    age: int = 30
    result = name + age  # Can't add str and int
    return result

# BAD: List type mismatches
def process_data(items: List[str]) -> List[int]:
    # Returns List[str] but annotated as List[int]
    return [item.upper() for item in items]

# BAD: Dictionary key errors
def access_dict_keys():
    data: Dict[str, int] = {"count": 5, "total": 100}
    # Using wrong key types
    value = data[123]  # Dict expects str keys, not int
    return value

# BAD: Class attribute errors
class User:
    def __init__(self, name: str, age: int):
        self.name = name
        self.age = age
    
    def get_info(self) -> str:
        return f"{self.name} is {self.age} years old"

def access_nonexistent_attribute():
    user = User("John", 30)
    # Accessing attribute that doesn't exist
    return user.email  # User has no email attribute

# BAD: Function with Any type (too broad)
def process_anything(data: Any) -> Any:
    # This defeats the purpose of type checking
    return data.some_method().another_method()[0].value

# BAD: Inconsistent return types
def get_result(success: bool) -> str:
    if success:
        return "Success message"
    else:
        return 404  # Returns int instead of str

# BAD: Mutating immutable types
def modify_tuple():
    data: tuple = (1, 2, 3)
    data[0] = 5  # Tuples are immutable
    return data

# BAD: Wrong container types
def process_items():
    items: List[str] = ("a", "b", "c")  # Tuple assigned to List
    return len(items)

# BAD: Incompatible comparison types
def compare_values():
    text: str = "hello"
    number: int = 5
    return text > number  # Can't compare str and int

# BAD: Missing import for type hints
def process_json_data(data: json.JSONEncoder) -> json.JSONDecoder:
    # Using json types without proper import
    encoder = json.JSONEncoder()
    decoder = json.JSONDecoder()
    return decoder

# BAD: Generic type without parameters
def create_list() -> List:  # Should be List[T] 
    return [1, 2, 3]

# BAD: Calling function with wrong number of arguments
def requires_two_args(x: int, y: int) -> int:
    return x + y

def call_with_wrong_arg_count():
    result1 = requires_two_args(5)  # Missing second argument
    result2 = requires_two_args(5, 10, 15)  # Too many arguments
    return result1, result2

# BAD: None checks without proper Optional handling
def unsafe_none_handling(value: Optional[str]) -> str:
    return value.upper()  # value might be None

# BAD: Circular type references without proper imports
class Node:
    def __init__(self, value: int, next_node: Node = None):  # Forward reference error
        self.value = value
        self.next = next_node

# BAD: Protocol violations
from typing import Protocol

class Drawable(Protocol):
    def draw(self) -> None: ...

class Circle:
    def __init__(self, radius: float):
        self.radius = radius
    
    # Missing draw method - doesn't implement Protocol

def render_shape(shape: Drawable):
    shape.draw()

def create_invalid_drawable():
    circle = Circle(5.0)
    render_shape(circle)  # Circle doesn't implement Drawable protocol

if __name__ == "__main__":
    print("This file has many type errors!")
    print("Run 'mypy type_issues.py' to see all the problems.")
    print("mypy will help you catch these before runtime!")