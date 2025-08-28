"""
GOOD CODE: Secure Patterns (bandit-compliant)
This file demonstrates secure coding practices that avoid common vulnerabilities
"""

import hashlib
import secrets
import sqlite3
import subprocess
import tempfile
import os
from pathlib import Path
from cryptography.fernet import Fernet
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2HMAC
import base64
import ssl
import pickle
import logging

# GOOD: Use parameterized queries to prevent SQL injection
def get_user_data_secure(user_id: int):
    """Secure database query using parameterized statements"""
    conn = sqlite3.connect('database.db')
    cursor = conn.cursor()
    # Use parameterized queries to prevent SQL injection
    cursor.execute("SELECT * FROM users WHERE id = ?", (user_id,))
    result = cursor.fetchall()
    conn.close()
    return result

# GOOD: Environment variables for sensitive data
def get_database_credentials():
    """Secure way to handle credentials using environment variables"""
    password = os.environ.get('DATABASE_PASSWORD')
    if not password:
        raise ValueError("DATABASE_PASSWORD environment variable not set")
    return password

# GOOD: Secure subprocess execution
def run_command_secure(cmd_args: list):
    """Secure subprocess execution without shell injection risks"""
    # Use list format instead of string, avoid shell=True
    try:
        result = subprocess.run(
            cmd_args,  # Pass as list, not string
            shell=False,  # Never use shell=True with user input
            capture_output=True,
            text=True,
            timeout=30,  # Add timeout
            check=True  # Raise exception on non-zero exit
        )
        return result.stdout
    except subprocess.TimeoutExpired:
        logging.error("Command timed out")
        raise
    except subprocess.CalledProcessError as e:
        logging.error(f"Command failed: {e}")
        raise

# GOOD: Secure temporary file creation
def create_secure_temp_file():
    """Create temporary file with secure permissions"""
    # Use secure file creation
    fd, path = tempfile.mkstemp()
    try:
        # Set restrictive permissions (owner only)
        os.chmod(path, 0o600)
        
        # Work with the file
        with os.fdopen(fd, 'w') as temp_file:
            temp_file.write("Secure temporary data")
        
        return path
    except Exception:
        # Clean up on error
        try:
            os.unlink(path)
        except OSError:
            pass
        raise

# GOOD: Proper validation instead of assertions
class UserValidator:
    """Secure user validation using proper checks, not assertions"""
    
    @staticmethod
    def validate_admin_user(user):
        """Proper validation that can't be bypassed"""
        if not hasattr(user, 'is_admin'):
            raise ValueError("User object missing is_admin attribute")
        
        if not user.is_admin:
            raise PermissionError("User must be admin to perform this action")
        
        return True

# GOOD: Strong cryptographic key generation
def generate_secure_key():
    """Generate a cryptographically secure key"""
    return Fernet.generate_key()

def derive_key_from_password(password: bytes, salt: bytes = None) -> bytes:
    """Derive a key from password using PBKDF2"""
    if salt is None:
        salt = os.urandom(16)
    
    kdf = PBKDF2HMAC(
        algorithm=hashes.SHA256(),
        length=32,
        salt=salt,
        iterations=100000,  # High iteration count
    )
    key = base64.urlsafe_b64encode(kdf.derive(password))
    return key

# GOOD: Secure data serialization
class SecureDataHandler:
    """Secure data serialization without pickle vulnerabilities"""
    
    @staticmethod
    def serialize_data(data):
        """Use JSON instead of pickle for untrusted data"""
        import json
        try:
            return json.dumps(data)
        except TypeError as e:
            logging.error(f"Data not JSON serializable: {e}")
            raise
    
    @staticmethod
    def deserialize_data(data: str):
        """Safe deserialization using JSON"""
        import json
        try:
            return json.loads(data)
        except json.JSONDecodeError as e:
            logging.error(f"Invalid JSON data: {e}")
            raise

# GOOD: Secure network binding
def start_secure_server(host='127.0.0.1', port=8080):
    """Start server binding only to specified interface"""
    import socket
    
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    
    # Bind to specific interface, not all interfaces
    server.bind((host, port))
    server.listen(5)
    
    logging.info(f"Server started on {host}:{port}")
    return server

# GOOD: Specific exception handling
def safe_operation():
    """Proper exception handling with specific exception types"""
    try:
        result = risky_function()
        return result
    except ValueError as e:
        logging.error(f"Value error in risky_function: {e}")
        return None
    except ConnectionError as e:
        logging.error(f"Connection error: {e}")
        return None
    except Exception as e:
        logging.error(f"Unexpected error: {e}")
        raise  # Re-raise for unknown errors

def risky_function():
    """Dummy function that might raise exceptions"""
    return "success"

# GOOD: Cryptographically secure random generation
def generate_secure_token(length: int = 32) -> str:
    """Generate cryptographically secure random token"""
    return secrets.token_urlsafe(length)

def generate_secure_number(min_val: int = 1000, max_val: int = 9999) -> int:
    """Generate cryptographically secure random number"""
    return secrets.randbelow(max_val - min_val + 1) + min_val

# GOOD: Secure input handling
def get_user_input_secure(prompt: str, allowed_chars: str = None) -> str:
    """Secure input handling with validation"""
    user_input = input(prompt).strip()
    
    # Validate input
    if not user_input:
        raise ValueError("Input cannot be empty")
    
    if len(user_input) > 1000:  # Prevent very long inputs
        raise ValueError("Input too long")
    
    if allowed_chars and not all(c in allowed_chars for c in user_input):
        raise ValueError("Input contains invalid characters")
    
    return user_input

# GOOD: Secure SSL/TLS configuration
def create_secure_ssl_context():
    """Create secure SSL context with proper verification"""
    context = ssl.create_default_context()
    
    # Enable hostname checking
    context.check_hostname = True
    
    # Require certificate verification
    context.verify_mode = ssl.CERT_REQUIRED
    
    # Use strong ciphers only
    context.set_ciphers('ECDHE+AESGCM:ECDHE+CHACHA20:DHE+AESGCM:DHE+CHACHA20:!aNULL:!MD5:!DSS')
    
    # Set minimum TLS version
    context.minimum_version = ssl.TLSVersion.TLSv1_2
    
    return context

# GOOD: Secure password hashing
def hash_password_secure(password: str) -> str:
    """Secure password hashing using modern algorithms"""
    from argon2 import PasswordHasher
    
    ph = PasswordHasher()
    return ph.hash(password)

def verify_password_secure(hashed_password: str, password: str) -> bool:
    """Verify password against secure hash"""
    from argon2 import PasswordHasher
    from argon2.exceptions import VerifyMismatchError
    
    ph = PasswordHasher()
    try:
        ph.verify(hashed_password, password)
        return True
    except VerifyMismatchError:
        return False

# GOOD: Secure file permissions
def create_secure_config_file(config_data: dict, file_path: str):
    """Create configuration file with secure permissions"""
    import json
    
    # Create file with restrictive permissions
    flags = os.O_WRONLY | os.O_CREAT | os.O_EXCL  # Fail if exists
    fd = os.open(file_path, flags, 0o600)  # Owner read/write only
    
    try:
        with os.fdopen(fd, 'w') as f:
            json.dump(config_data, f, indent=2)
    except Exception:
        # Clean up on error
        try:
            os.unlink(file_path)
        except OSError:
            pass
        raise

# GOOD: Logging sensitive information safely
def log_user_action(user_id: int, action: str, sensitive_data: str = None):
    """Log user actions without exposing sensitive data"""
    # Never log sensitive data directly
    if sensitive_data:
        # Log only hash or sanitized version
        data_hash = hashlib.sha256(sensitive_data.encode()).hexdigest()
        logging.info(f"User {user_id} performed {action} (data hash: {data_hash[:8]}...)")
    else:
        logging.info(f"User {user_id} performed {action}")

if __name__ == "__main__":
    print("This file demonstrates secure coding practices!")
    print("Run 'bandit secure_patterns.py' to verify security.")
    
    # Demonstrate secure practices
    try:
        token = generate_secure_token()
        print(f"Generated secure token: {token[:10]}...")
        
        # Secure random number
        number = generate_secure_number()
        print(f"Secure random number: {number}")
        
    except Exception as e:
        logging.error(f"Error in demonstration: {e}")