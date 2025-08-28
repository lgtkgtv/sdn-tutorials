"""
BAD CODE: Vulnerable Dependencies (safety will catch these)
This file demonstrates usage of packages with known security vulnerabilities
"""

# These imports would trigger safety warnings if the vulnerable versions are installed
# Note: We're not actually installing these vulnerable versions for safety

# Example vulnerable packages (hypothetical - versions for demonstration):
# requests==2.6.0  # Has known CVE vulnerabilities
# urllib3==1.21.1  # Has known security issues  
# pillow==2.2.2    # Has known vulnerabilities
# pyyaml==3.12     # Has known deserialization vulnerabilities
# django==1.11.0   # Has known security issues
# flask==0.10.1    # Has known vulnerabilities

"""
When you run 'safety check' it will scan your installed packages against
the safety database and report known vulnerabilities.

Common vulnerability types:
1. Remote Code Execution (RCE)
2. SQL Injection
3. Cross-Site Scripting (XSS)
4. Denial of Service (DoS)
5. Insecure Deserialization
6. Authentication Bypass

Example safety report:
+============================================================================================+
 VULNERABILITY FOUND!
+============================================================================================+
 ID: 25853
 PACKAGE NAME: requests
 INSTALLED VERSION: 2.6.0
 AFFECTED VERSIONS: <2.6.1
 ADVISORY: The requests library through 2.6.0 for Python sends an HTTP Authorization header
           to an http URI upon receiving a same-hostname https-to-http redirect, which makes
           it easier for remote attackers to discover credentials by sniffing the network.
 CVE: CVE-2014-1830
 MORE INFO: https://pyup.io/vulnerabilities/CVE-2014-1830/25853/
+============================================================================================+

To fix: pip install --upgrade requests>=2.6.1
"""

# Example of checking for vulnerable packages in requirements files:
"""
# requirements.txt with vulnerable packages
requests==2.6.0     # Vulnerable - has CVE-2014-1830
django==1.11.0      # Vulnerable - has multiple CVEs
pyyaml==3.12        # Vulnerable - unsafe loading
pillow==2.2.2       # Vulnerable - multiple image processing CVEs
"""

import requests  # If this is an old version, safety will flag it
import yaml      # If this is an old version, safety will flag it

def demonstrate_package_usage():
    """
    This function uses packages that might have vulnerabilities
    depending on the installed versions.
    """
    
    # Using requests - check version
    print(f"Requests version: {requests.__version__}")
    
    # Using yaml - check version  
    print(f"PyYAML version: {yaml.__version__}")
    
    # These usages themselves aren't necessarily bad,
    # but if the underlying packages have vulnerabilities,
    # safety will detect them.

def check_vulnerability_database():
    """
    Safety maintains a database of known vulnerabilities.
    It checks your installed packages against this database.
    """
    print("Run these commands to check for vulnerabilities:")
    print("1. safety check - Check installed packages")
    print("2. safety check --json - Get JSON output")
    print("3. safety check -r requirements.txt - Check requirements file")
    print("4. safety check --db - Update vulnerability database")

if __name__ == "__main__":
    print("Checking package versions...")
    demonstrate_package_usage()
    print("\nTo check for vulnerabilities, run:")
    print("safety check")
    check_vulnerability_database()