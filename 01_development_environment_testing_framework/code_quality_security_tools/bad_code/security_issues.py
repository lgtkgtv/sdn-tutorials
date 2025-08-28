"""
BAD CODE: Security Issues (bandit will catch these)
This file contains intentional security vulnerabilities for educational purposes
DO NOT USE THESE PATTERNS IN PRODUCTION CODE!
"""

# BAD: Using exec() with user input (B102)
def execute_user_command(user_input):
    exec(user_input)  # NEVER do this!

# BAD: Using eval() with user input (B307)
def calculate_expression(expression):
    return eval(expression)  # Dangerous!

# BAD: SQL injection vulnerability (B608)
import sqlite3
def get_user_data(user_id):
    conn = sqlite3.connect('database.db')
    cursor = conn.cursor()
    # String formatting in SQL queries is dangerous
    query = f"SELECT * FROM users WHERE id = {user_id}"
    cursor.execute(query)
    return cursor.fetchall()

# BAD: Hardcoded password (B105)
DATABASE_PASSWORD = "secretpassword123"  # Never hardcode secrets!

# BAD: Using shell=True with subprocess (B602)
import subprocess
def run_command(cmd):
    subprocess.run(cmd, shell=True)  # Dangerous shell injection

# BAD: Insecure temporary file creation (B108)
import tempfile
import os
def create_temp_file():
    # Creates file with world-readable permissions
    fd, path = tempfile.mkstemp()
    os.chmod(path, 0o777)  # Too permissive!
    return path

# BAD: Using assert for security checks (B101)
def validate_user(user):
    assert user.is_admin, "User must be admin"  # Assertions can be disabled!

# BAD: Weak cryptographic key (B105)
SECRET_KEY = "1234567890"  # Weak key

# BAD: Using pickle with untrusted data (B301)
import pickle
def load_user_data(data):
    return pickle.loads(data)  # Unsafe deserialization

# BAD: Binding to all interfaces (B104)
import socket
def start_server():
    server = socket.socket()
    server.bind(('0.0.0.0', 8080))  # Binds to all interfaces

# BAD: Try-except with bare except (B110)
def risky_operation():
    try:
        dangerous_function()
    except:  # Too broad exception handling
        pass

# BAD: Random number generation for security (B311)
import random
def generate_token():
    return random.randint(1000, 9999)  # Not cryptographically secure

# BAD: Input function usage (B322)
def get_user_input():
    return input("Enter command: ")  # Can be dangerous in some contexts

# BAD: Weak SSL/TLS configuration
import ssl
def create_ssl_context():
    context = ssl.create_default_context()
    context.check_hostname = False  # Disables hostname checking
    context.verify_mode = ssl.CERT_NONE  # Disables certificate verification
    return context

# BAD: Using md5 for passwords (B303)
import hashlib
def hash_password(password):
    return hashlib.md5(password.encode()).hexdigest()  # Weak hashing

if __name__ == "__main__":
    print("This file demonstrates BAD security practices!")
    print("Run 'bandit security_issues.py' to see all the issues.")