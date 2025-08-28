"""
Step 1: Bandit Security Analysis
Learn how to identify and fix security vulnerabilities in Python code

Run: bandit examples/step1_bandit_security.py
"""

import subprocess
import hashlib
import os
import tempfile
from typing import List, Optional


def demonstrate_security_issues():
    """
    This function contains some security issues for demonstration.
    Run bandit on this file to see them detected.
    """
    
    # ISSUE: Hardcoded password (B105)
    # This will be flagged by bandit
    api_key = "sk-1234567890abcdef"  # Never hardcode secrets!
    
    print("Security demonstration - DO NOT use these patterns in production!")
    return api_key


def demonstrate_secure_patterns():
    """
    This function shows secure alternatives to common vulnerabilities.
    """
    
    # SECURE: Use environment variables for secrets
    api_key = os.environ.get('API_KEY')
    if not api_key:
        raise ValueError("API_KEY environment variable not set")
    
    return api_key


def unsafe_subprocess_example(user_command: str):
    """
    UNSAFE: This function has a shell injection vulnerability
    Bandit will flag this as B602 (subprocess_popen_with_shell_equals_true)
    """
    # DON'T DO THIS - shell=True with user input is dangerous
    result = subprocess.run(user_command, shell=True, capture_output=True)
    return result.stdout.decode()


def safe_subprocess_example(command_args: List[str]):
    """
    SECURE: Safe subprocess execution
    """
    # DO THIS - use list of arguments, no shell=True
    try:
        result = subprocess.run(
            command_args,
            shell=False,
            capture_output=True,
            text=True,
            timeout=30,
            check=True
        )
        return result.stdout
    except subprocess.CalledProcessError as e:
        print(f"Command failed: {e}")
        return None
    except subprocess.TimeoutExpired:
        print("Command timed out")
        return None


def weak_hashing_example(password: str) -> str:
    """
    INSECURE: Using MD5 for password hashing
    Bandit will flag this as B303 (blacklist_calls)
    """
    # DON'T DO THIS - MD5 is cryptographically broken
    return hashlib.md5(password.encode()).hexdigest()


def secure_hashing_example(password: str) -> str:
    """
    SECURE: Using strong hashing for passwords
    """
    # DO THIS - use bcrypt, scrypt, or argon2
    import bcrypt
    
    salt = bcrypt.gensalt()
    hashed = bcrypt.hashpw(password.encode('utf-8'), salt)
    return hashed.decode('utf-8')


def insecure_temp_file():
    """
    INSECURE: Creating temp file with weak permissions
    Bandit may flag this depending on configuration
    """
    # DON'T DO THIS - creates world-readable temp file
    fd, path = tempfile.mkstemp()
    os.chmod(path, 0o777)  # Too permissive!
    return path


def secure_temp_file():
    """
    SECURE: Creating temp file with proper permissions
    """
    # DO THIS - create with secure permissions
    fd, path = tempfile.mkstemp()
    os.chmod(path, 0o600)  # Owner read/write only
    return path


def demonstrate_sql_injection_risk():
    """
    This would be flagged if we had actual SQL execution.
    Shows the pattern bandit looks for.
    """
    import sqlite3
    
    # INSECURE: String formatting in SQL (would be B608 if executed)
    user_id = "1 OR 1=1"  # Simulated malicious input
    query = f"SELECT * FROM users WHERE id = {user_id}"
    
    print(f"DANGEROUS QUERY: {query}")
    print("This pattern would allow SQL injection!")
    
    # SECURE: Use parameterized queries
    safe_query = "SELECT * FROM users WHERE id = ?"
    print(f"SAFE QUERY: {safe_query} with parameter: {user_id}")


def demonstrate_random_security():
    """
    Shows the difference between regular random and cryptographically secure random
    """
    import random
    import secrets
    
    # INSECURE: Using random for security purposes (B311)
    weak_token = random.randint(1000, 9999)
    print(f"Weak token: {weak_token}")
    
    # SECURE: Using secrets module for cryptographic purposes
    strong_token = secrets.randbelow(9000) + 1000
    secure_token = secrets.token_urlsafe(32)
    print(f"Strong token: {strong_token}")
    print(f"Secure token: {secure_token}")


def analyze_this_file():
    """
    Function to help users analyze this file with bandit
    """
    print("To analyze this file with bandit:")
    print("1. Basic scan: bandit step1_bandit_security.py")
    print("2. Verbose output: bandit -v step1_bandit_security.py")
    print("3. JSON format: bandit -f json step1_bandit_security.py")
    print("4. Skip specific tests: bandit -s B105 step1_bandit_security.py")
    print("5. Confidence levels: bandit -i step1_bandit_security.py")


def bandit_configuration_example():
    """
    Shows how to configure bandit for your project
    """
    bandit_config = """
# .bandit configuration file
[bandit]
exclude_dirs = ['tests', 'venv', '.venv']
skips = ['B101', 'B601']  # Skip assert_used and shell_injection_process_popen
severity = medium

# Custom test configurations
[bandit.blacklist_imports]
bad_import_sets = [
    {'imports': ['pickle'], 'level': 'ERROR', 'message': 'Use JSON instead of pickle'}
]
"""
    
    print("Example .bandit configuration:")
    print(bandit_config)


def security_best_practices():
    """
    General security best practices that bandit helps enforce
    """
    practices = [
        "1. Never hardcode secrets, passwords, or API keys",
        "2. Use parameterized queries for database operations",
        "3. Avoid shell=True in subprocess calls",
        "4. Use cryptographically secure random for security purposes",
        "5. Set proper file permissions on sensitive files",
        "6. Use strong cryptographic algorithms (avoid MD5, SHA1)",
        "7. Validate and sanitize all user inputs",
        "8. Use try-except blocks for specific exceptions",
        "9. Be cautious with pickle and eval() functions",
        "10. Regularly update dependencies to patch vulnerabilities"
    ]
    
    print("Security Best Practices:")
    for practice in practices:
        print(f"  {practice}")


if __name__ == "__main__":
    print("=" * 60)
    print("Step 1: Bandit Security Analysis Tutorial")
    print("=" * 60)
    
    print("\n🔒 Analyzing security patterns...")
    
    # Demonstrate secure vs insecure patterns
    try:
        # This will use the hardcoded API key (security issue)
        key1 = demonstrate_security_issues()
        print(f"Got API key: {key1[:10]}... (from hardcoded source)")
    except Exception as e:
        print(f"Error: {e}")
    
    # Show random number generation
    print("\n🎲 Random number generation:")
    demonstrate_random_security()
    
    # Show SQL injection risks
    print("\n💉 SQL Injection demonstration:")
    demonstrate_sql_injection_risk()
    
    # Show analysis commands
    print("\n🔍 How to analyze this file:")
    analyze_this_file()
    
    # Show best practices
    print("\n✅ Security Best Practices:")
    security_best_practices()
    
    print("\n" + "=" * 60)
    print("Run 'bandit examples/step1_bandit_security.py' to see issues!")
    print("=" * 60)