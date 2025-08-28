"""
Step 6: mypy - Type Checking
Learn how mypy helps catch type errors and improve code reliability

Run: mypy examples/step6_mypy_types.py
Run: mypy --strict examples/step6_mypy_types.py
"""

from typing import List, Dict, Optional, Union, Any, Callable, TypeVar, Generic
from typing import Protocol, Literal, Final, ClassVar
from abc import ABC, abstractmethod
import json


# GOOD: Proper type annotations
def calculate_area(length: float, width: float) -> float:
    """Calculate area with proper type annotations"""
    return length * width


# BAD: Missing type annotations (mypy will complain in strict mode)
def calculate_volume(length, width, height):
    return length * width * height


# GOOD: Function with optional parameter
def greet_user(name: str, title: Optional[str] = None) -> str:
    """Greet user with optional title"""
    if title:
        return f"Hello, {title} {name}!"
    return f"Hello, {name}!"


# BAD: Type mismatch - returns wrong type
def get_user_count() -> str:
    """This function claims to return str but returns int"""
    return 42  # Type error: Expected str, got int


# GOOD: Proper list typing
def process_numbers(numbers: List[int]) -> List[int]:
    """Process a list of integers"""
    return [n * 2 for n in numbers]


# BAD: Using wrong types
def bad_list_processing(numbers: List[str]) -> List[int]:
    """This has type mismatches"""
    # Type error: List[str] items don't have mathematical operations
    return [n * 2 for n in numbers]  # str * int gives str, not int


# GOOD: Dictionary typing
def get_user_info(user_id: int) -> Dict[str, Union[str, int]]:
    """Get user information with proper typing"""
    return {
        "name": "John Doe",
        "age": 30,
        "email": "john@example.com"
    }


# BAD: Accessing possibly None value
def unsafe_none_handling(user_data: Optional[Dict[str, str]]) -> str:
    """Unsafe handling of Optional type"""
    # Type error: user_data might be None
    return user_data["name"]  # Potential AttributeError


# GOOD: Safe None handling
def safe_none_handling(user_data: Optional[Dict[str, str]]) -> str:
    """Safe handling of Optional type"""
    if user_data is None:
        return "Unknown"
    return user_data.get("name", "Anonymous")


# BAD: Inconsistent return types
def inconsistent_return(success: bool) -> str:
    """Function with inconsistent return types"""
    if success:
        return "Success message"
    else:
        return 404  # Type error: Expected str, got int


# GOOD: Consistent return types
def consistent_return(success: bool) -> str:
    """Function with consistent return types"""
    if success:
        return "Success message"
    else:
        return "Error: Operation failed"


# Demonstrate Union types
def process_id(user_id: Union[int, str]) -> str:
    """Process user ID that can be int or str"""
    if isinstance(user_id, int):
        return f"User #{user_id}"
    return f"User {user_id}"


# Demonstrate Generic types
T = TypeVar('T')

class Container(Generic[T]):
    """Generic container class"""
    
    def __init__(self, value: T) -> None:
        self._value = value
    
    def get(self) -> T:
        return self._value
    
    def set(self, value: T) -> None:
        self._value = value


# Demonstrate Protocol (structural typing)
class Drawable(Protocol):
    """Protocol for drawable objects"""
    
    def draw(self) -> str:
        ...


class Circle:
    """Circle class implementing Drawable protocol"""
    
    def __init__(self, radius: float) -> None:
        self.radius = radius
    
    def draw(self) -> str:
        return f"Drawing circle with radius {self.radius}"


class Rectangle:
    """Rectangle class implementing Drawable protocol"""
    
    def __init__(self, width: float, height: float) -> None:
        self.width = width
        self.height = height
    
    def draw(self) -> str:
        return f"Drawing rectangle {self.width}x{self.height}"


def render_shape(shape: Drawable) -> str:
    """Render any drawable shape"""
    return shape.draw()


# BAD: Class not implementing protocol
class Triangle:
    """Triangle class NOT implementing Drawable protocol"""
    
    def __init__(self, base: float, height: float) -> None:
        self.base = base
        self.height = height
    
    # Missing draw() method - Protocol violation


# Demonstrate Literal types
def set_log_level(level: Literal["DEBUG", "INFO", "WARNING", "ERROR"]) -> None:
    """Set log level with restricted string values"""
    print(f"Log level set to {level}")


# Demonstrate Final and ClassVar
class Configuration:
    """Configuration class with Final and ClassVar"""
    
    API_VERSION: Final[str] = "v1.0"  # Cannot be changed
    instance_count: ClassVar[int] = 0  # Class variable
    
    def __init__(self, name: str) -> None:
        self.name = name
        Configuration.instance_count += 1


# Demonstrate callable types
def apply_operation(numbers: List[int], operation: Callable[[int], int]) -> List[int]:
    """Apply operation to each number"""
    return [operation(n) for n in numbers]


def square(x: int) -> int:
    return x * x


# BAD: Calling method that doesn't exist
def method_error_demo() -> None:
    """Demonstrate method error"""
    text: str = "hello"
    # Type error: str has no append method
    text.append(" world")  # Should be: text += " world"


# GOOD: Abstract base class
class Animal(ABC):
    """Abstract animal class"""
    
    def __init__(self, name: str) -> None:
        self.name = name
    
    @abstractmethod
    def make_sound(self) -> str:
        """Make animal sound"""
        pass


class Dog(Animal):
    """Dog implementation"""
    
    def make_sound(self) -> str:
        return "Woof!"


class Cat(Animal):
    """Cat implementation"""
    
    def make_sound(self) -> str:
        return "Meow!"


# BAD: Missing abstract method implementation
class Fish(Animal):
    """Fish missing abstract method implementation"""
    
    def swim(self) -> str:
        return "Swimming..."
    
    # Missing make_sound() implementation


def demonstrate_mypy_features():
    """Show key mypy features"""
    
    features = {
        "Static Type Checking": "Catch type errors before runtime",
        "Gradual Typing": "Add types incrementally to existing code",
        "Type Inference": "Infer types when not explicitly annotated",
        "Generic Support": "Support for generic types and type variables",
        "Protocol Support": "Structural typing with protocols",
        "Union Types": "Handle multiple possible types",
        "Optional Types": "Explicit handling of None values",
        "Literal Types": "Restrict values to specific literals",
        "Final Types": "Prevent reassignment of variables",
        "Abstract Base Classes": "Enforce interface contracts"
    }
    
    print("MyPy Key Features:")
    for feature, description in features.items():
        print(f"  • {feature}: {description}")


def mypy_configuration():
    """Show mypy configuration options"""
    
    config_examples = {
        "mypy.ini": """
[mypy]
python_version = 3.8
warn_return_any = True
warn_unused_configs = True
disallow_untyped_defs = True
disallow_incomplete_defs = True
check_untyped_defs = True
disallow_untyped_decorators = True
no_implicit_optional = True
warn_redundant_casts = True
warn_unused_ignores = True
warn_no_return = True
warn_unreachable = True
strict_equality = True

# Per-module options
[mypy-requests.*]
ignore_missing_imports = True

[mypy-numpy.*]
ignore_missing_imports = True
""",
        
        "pyproject.toml": """
[tool.mypy]
python_version = "3.8"
warn_return_any = true
warn_unused_configs = true
disallow_untyped_defs = true
disallow_incomplete_defs = true
check_untyped_defs = true
disallow_untyped_decorators = true
no_implicit_optional = true
warn_redundant_casts = true
warn_unused_ignores = true
warn_no_return = true
warn_unreachable = true
strict_equality = true

[[tool.mypy.overrides]]
module = ["requests.*", "numpy.*"]
ignore_missing_imports = true
""",
        
        "Command Line": """
# Basic type checking
mypy file.py

# Strict mode (enables most checks)
mypy --strict file.py

# Check entire package
mypy mypackage/

# Ignore missing imports
mypy --ignore-missing-imports file.py

# Show error codes
mypy --show-error-codes file.py

# Generate HTML report
mypy --html-report mypy-report/ mypackage/

# Install missing stub packages
mypy --install-types file.py
"""
    }
    
    print("\nMyPy Configuration:")
    for name, config in config_examples.items():
        print(f"\n{name}:")
        print(config)


def common_type_errors():
    """Show common mypy error patterns and fixes"""
    
    errors = {
        "error: Function is missing a return type annotation": {
            "bad": "def get_data():",
            "good": "def get_data() -> Dict[str, Any]:",
            "code": "return_value"
        },
        
        "error: Argument has incompatible type": {
            "bad": 'add_numbers("5", "10")  # strings to int function',
            "good": "add_numbers(5, 10)  # correct types",
            "code": "arg_type"
        },
        
        "error: Item has no attribute": {
            "bad": 'text: str = "hello"\ntext.append("world")',
            "good": 'text: str = "hello"\ntext += "world"',
            "code": "attr_defined"
        },
        
        "error: Incompatible return value type": {
            "bad": "def get_name() -> str:\n    return 42",
            "good": "def get_name() -> str:\n    return 'John'",
            "code": "return_type"
        },
        
        "error: Argument of type 'None' cannot be assigned": {
            "bad": "def process(data: Optional[str]) -> str:\n    return data.upper()",
            "good": "def process(data: Optional[str]) -> str:\n    return data.upper() if data else ''",
            "code": "assignment"
        }
    }
    
    print("\nCommon Type Errors and Fixes:")
    for error, details in errors.items():
        print(f"\n{error}:")
        print(f"  ❌ Bad:  {details['bad']}")
        print(f"  ✅ Good: {details['good']}")
        print(f"  Code: {details['code']}")


def advanced_typing_patterns():
    """Show advanced typing patterns"""
    
    patterns = {
        "Type Aliases": """
# Create readable type aliases
UserId = int
UserData = Dict[str, Union[str, int]]
Coordinates = tuple[float, float]

def get_user(user_id: UserId) -> UserData:
    return {"name": "John", "age": 30}
""",
        
        "Overloads": """
from typing import overload

@overload
def process(data: str) -> str: ...

@overload  
def process(data: int) -> int: ...

def process(data: Union[str, int]) -> Union[str, int]:
    if isinstance(data, str):
        return data.upper()
    return data * 2
""",
        
        "TypedDict": """
from typing_extensions import TypedDict

class UserInfo(TypedDict):
    name: str
    age: int
    email: str

def process_user(user: UserInfo) -> str:
    return f"{user['name']} ({user['age']})"
""",
        
        "Callback Protocols": """
class Validator(Protocol):
    def __call__(self, value: str) -> bool: ...

def validate_input(value: str, validator: Validator) -> bool:
    return validator(value)
"""
    }
    
    print("\nAdvanced Typing Patterns:")
    for pattern, example in patterns.items():
        print(f"\n{pattern}:")
        print(example.strip())


def integration_examples():
    """Show mypy integration with development workflow"""
    
    integrations = {
        "Pre-commit hook": """
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/pre-commit/mirrors-mypy
    rev: v1.0.0
    hooks:
      - id: mypy
        additional_dependencies: [types-requests]
""",
        
        "GitHub Actions": """
# .github/workflows/type-check.yml
name: Type Check
on: [push, pull_request]
jobs:
  type-check:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    - name: Set up Python
      uses: actions/setup-python@v2
      with:
        python-version: 3.9
    - name: Install mypy
      run: pip install mypy
    - name: Type check
      run: mypy .
""",
        
        "VS Code": """
{
    "python.linting.mypyEnabled": true,
    "python.linting.enabled": true,
    "python.linting.mypyArgs": [
        "--ignore-missing-imports",
        "--show-error-codes"
    ]
}
""",
        
        "tox": """
# tox.ini
[testenv:type-check]
deps = mypy
commands = mypy src/
"""
    }
    
    print("\nIntegration Examples:")
    for name, config in integrations.items():
        print(f"\n{name}:")
        print(config)


def type_stubs_and_third_party():
    """Information about type stubs and third-party packages"""
    
    stub_info = {
        "What are stubs?": "Files with type information for libraries",
        "Installation": "pip install types-requests types-redis",
        "Typeshed": "Repository of stubs for standard library",
        "Stub packages": "types-* packages on PyPI"
    }
    
    common_stubs = [
        "types-requests",
        "types-redis", 
        "types-PyYAML",
        "types-python-dateutil",
        "types-beautifulsoup4",
        "types-Pillow",
        "types-setuptools"
    ]
    
    print("\nType Stubs Information:")
    for concept, description in stub_info.items():
        print(f"  {concept}: {description}")
    
    print("\nCommon Stub Packages:")
    for stub in common_stubs:
        print(f"  {stub}")
    
    print("\nInstall stubs automatically:")
    print("  mypy --install-types file.py")


def demo_function_calls():
    """Demonstrate the functions with proper types"""
    
    try:
        # Good examples
        area = calculate_area(10.0, 5.0)
        greeting = greet_user("Alice", "Dr.")
        numbers = process_numbers([1, 2, 3, 4])
        user_info = get_user_info(123)
        
        # Container example
        string_container: Container[str] = Container("Hello")
        int_container: Container[int] = Container(42)
        
        # Protocol example
        circle = Circle(5.0)
        rectangle = Rectangle(10.0, 3.0)
        
        shapes: List[Drawable] = [circle, rectangle]
        for shape in shapes:
            print(render_shape(shape))
        
        # Callable example
        squared_numbers = apply_operation([1, 2, 3, 4], square)
        
        # Animal example
        dog = Dog("Buddy")
        cat = Cat("Whiskers")
        
        animals: List[Animal] = [dog, cat]
        for animal in animals:
            print(f"{animal.name}: {animal.make_sound()}")
        
        print("✅ All properly typed examples work!")
        
    except Exception as e:
        print(f"Error in demo: {e}")


if __name__ == "__main__":
    print("=" * 60)
    print("Step 6: mypy - Type Checking")
    print("=" * 60)
    
    print("\n🎯 MyPy Features:")
    demonstrate_mypy_features()
    
    print("\n⚙️ Configuration:")
    mypy_configuration()
    
    print("\n🐛 Common Errors:")
    common_type_errors()
    
    print("\n🚀 Advanced Patterns:")
    advanced_typing_patterns()
    
    print("\n🔗 Integration:")
    integration_examples()
    
    print("\n📚 Type Stubs:")
    type_stubs_and_third_party()
    
    print("\n🧪 Demo:")
    demo_function_calls()
    
    print("\n" + "=" * 60)
    print("Try these commands:")
    print("  mypy examples/step6_mypy_types.py")
    print("  mypy --strict examples/step6_mypy_types.py")
    print("  mypy --show-error-codes examples/step6_mypy_types.py")
    print("=" * 60)