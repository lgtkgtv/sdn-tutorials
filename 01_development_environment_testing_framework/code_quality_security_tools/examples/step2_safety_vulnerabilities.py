"""
Step 2: Safety - Vulnerability Scanning
Learn how to identify vulnerable dependencies and keep your project secure

Run: safety check
Run: safety check --json
Run: safety check -r requirements.txt
"""

import sys
import pkg_resources
from typing import List, Dict, Any
import json
import subprocess


def get_installed_packages() -> List[Dict[str, str]]:
    """
    Get list of installed packages and their versions
    """
    packages = []
    for dist in pkg_resources.working_set:
        packages.append({
            'name': dist.project_name,
            'version': dist.version
        })
    return sorted(packages, key=lambda x: x['name'])


def demonstrate_safety_commands():
    """
    Demonstrate various safety command options
    """
    commands = {
        "Basic scan": "safety check",
        "JSON output": "safety check --json",
        "Scan requirements file": "safety check -r requirements.txt",
        "Full report": "safety check --full-report",
        "Ignore specific vulns": "safety check --ignore 12345",
        "Update database": "safety check --db",
        "Scan specific packages": "safety check --packages requests==2.6.0",
        "Exit on vulnerabilities": "safety check --exit-code",
    }
    
    print("Safety Command Examples:")
    for description, command in commands.items():
        print(f"  {description}: {command}")


def check_common_vulnerable_packages():
    """
    Check for commonly vulnerable package patterns
    """
    # These are examples of packages that have had vulnerabilities
    commonly_vulnerable = {
        'requests': {
            'vulnerable_versions': ['< 2.6.1', '< 2.20.0'],
            'issues': ['CVE-2014-1830: HTTP redirect vulnerability', 
                      'CVE-2018-18074: Credential exposure']
        },
        'urllib3': {
            'vulnerable_versions': ['< 1.24.2', '< 1.25.9'],
            'issues': ['CVE-2019-11324: Certificate validation bypass',
                      'CVE-2020-26137: CRLF injection']
        },
        'pyyaml': {
            'vulnerable_versions': ['< 4.2b1'],
            'issues': ['CVE-2017-18342: Unsafe loading allows code execution']
        },
        'pillow': {
            'vulnerable_versions': ['< 6.2.0', '< 8.1.1'],
            'issues': ['Multiple image processing vulnerabilities']
        },
        'django': {
            'vulnerable_versions': ['< 2.2.13', '< 3.0.7'],
            'issues': ['SQL injection, XSS, and other web vulnerabilities']
        }
    }
    
    print("\nCommonly Vulnerable Packages (Examples):")
    for package, info in commonly_vulnerable.items():
        print(f"\n📦 {package}:")
        print(f"   Vulnerable versions: {', '.join(info['vulnerable_versions'])}")
        print(f"   Common issues:")
        for issue in info['issues']:
            print(f"     - {issue}")


def demonstrate_requirements_scanning():
    """
    Show how to scan requirements files for vulnerabilities
    """
    # Example vulnerable requirements.txt content
    vulnerable_requirements = """
# Example requirements.txt with known vulnerabilities
requests==2.6.0          # CVE-2014-1830
django==1.11.0           # Multiple CVEs
pyyaml==3.12            # CVE-2017-18342  
pillow==2.2.2           # Multiple image processing CVEs
urllib3==1.21.1         # Certificate validation issues
flask==0.10.1           # Security vulnerabilities
jinja2==2.8             # XSS vulnerabilities
werkzeug==0.11          # Debug mode vulnerabilities
"""
    
    print("\nExample Vulnerable Requirements File:")
    print(vulnerable_requirements)
    
    # Show how to create a requirements file from current environment
    print("To create requirements.txt from current environment:")
    print("  pip freeze > requirements.txt")
    print("  safety check -r requirements.txt")


def analyze_safety_output():
    """
    Explain how to read and understand safety output
    """
    example_output = """
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
"""
    
    print("\nExample Safety Output:")
    print(example_output)
    
    print("Understanding the output:")
    print("  - ID: Unique identifier for the vulnerability")
    print("  - PACKAGE NAME: The vulnerable package")
    print("  - INSTALLED VERSION: Your currently installed version")
    print("  - AFFECTED VERSIONS: Versions that have this vulnerability")
    print("  - ADVISORY: Description of the vulnerability")
    print("  - CVE: Common Vulnerabilities and Exposures identifier")
    print("  - MORE INFO: Link to detailed information")


def demonstrate_json_output():
    """
    Show how to work with safety JSON output
    """
    example_json = {
        "vulnerabilities": [
            {
                "advisory": "The requests library has a vulnerability...",
                "cve": "CVE-2014-1830",
                "id": "25853",
                "specs": ["<2.6.1"],
                "v": "<2.6.1"
            }
        ],
        "packages": [
            {
                "package": "requests",
                "installed": "2.6.0",
                "vulnerable": True,
                "vulns": ["25853"]
            }
        ]
    }
    
    print("\nExample JSON Output Structure:")
    print(json.dumps(example_json, indent=2))
    
    print("\nProcessing JSON output in Python:")
    code = '''
import json
import subprocess

# Run safety check and get JSON output
result = subprocess.run(['safety', 'check', '--json'], 
                       capture_output=True, text=True)
data = json.loads(result.stdout)

# Process vulnerabilities
for vuln in data.get('vulnerabilities', []):
    print(f"Vulnerability: {vuln['id']}")
    print(f"Advisory: {vuln['advisory']}")
    print(f"CVE: {vuln.get('cve', 'N/A')}")
'''
    print(code)


def safety_in_ci_cd():
    """
    Show how to integrate safety into CI/CD pipelines
    """
    ci_examples = {
        "GitHub Actions": """
# .github/workflows/security.yml
name: Security Check
on: [push, pull_request]
jobs:
  security:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    - name: Set up Python
      uses: actions/setup-python@v2
      with:
        python-version: 3.9
    - name: Install safety
      run: pip install safety
    - name: Run safety check
      run: safety check --exit-code
""",
        
        "GitLab CI": """
# .gitlab-ci.yml
security_check:
  stage: test
  image: python:3.9
  script:
    - pip install safety
    - safety check --exit-code
  only:
    - branches
""",
        
        "Docker": """
# Dockerfile
FROM python:3.9
COPY requirements.txt .
RUN pip install safety && \
    safety check -r requirements.txt --exit-code
RUN pip install -r requirements.txt
""",
        
        "Pre-commit Hook": """
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/Lucas-C/pre-commit-hooks-safety
    rev: v1.3.0
    hooks:
      - id: python-safety-dependencies-check
"""
    }
    
    print("\nCI/CD Integration Examples:")
    for platform, config in ci_examples.items():
        print(f"\n{platform}:")
        print(config)


def vulnerability_response_workflow():
    """
    Show how to respond when vulnerabilities are found
    """
    workflow = [
        "1. 🔍 IDENTIFY: Run safety check to find vulnerabilities",
        "2. 📊 ASSESS: Review the severity and impact of each vulnerability",
        "3. 🔧 PRIORITIZE: Address high-severity vulnerabilities first",
        "4. ⬆️  UPDATE: Upgrade packages to safe versions",
        "5. 🧪 TEST: Run tests to ensure updates don't break functionality",
        "6. 📝 DOCUMENT: Record changes and vulnerability fixes",
        "7. 🔄 MONITOR: Set up automated scanning for future vulnerabilities"
    ]
    
    print("\nVulnerability Response Workflow:")
    for step in workflow:
        print(f"  {step}")
    
    example_commands = [
        "# Step 1: Identify vulnerabilities",
        "safety check --json > vulnerabilities.json",
        "",
        "# Step 4: Update specific package",
        "pip install --upgrade requests>=2.6.1",
        "",
        "# Step 5: Test after updates", 
        "python -m pytest tests/",
        "",
        "# Step 6: Update requirements",
        "pip freeze > requirements.txt",
        "",
        "# Step 7: Verify fixes",
        "safety check"
    ]
    
    print("\nExample Commands:")
    for cmd in example_commands:
        print(f"  {cmd}")


def security_monitoring_best_practices():
    """
    Best practices for ongoing security monitoring
    """
    practices = [
        "🔄 Automate vulnerability scanning in CI/CD",
        "📅 Schedule regular dependency updates",
        "🎯 Use dependabot or similar automated tools",
        "📋 Maintain an inventory of all dependencies",
        "🔔 Set up security alerts and notifications",
        "📈 Monitor security advisories for your technologies",
        "🧪 Test updates in staging before production",
        "📚 Keep security documentation up to date",
        "👥 Train team members on security practices",
        "🔒 Implement defense in depth strategies"
    ]
    
    print("\nSecurity Monitoring Best Practices:")
    for practice in practices:
        print(f"  {practice}")


def create_safety_config():
    """
    Show how to create safety configuration files
    """
    config_examples = {
        ".safety-policy.yml": """
# Safety policy configuration
security:
  # Ignore specific vulnerabilities (use with caution)
  ignore-vulnerabilities:
    - 12345  # Vulnerability ID to ignore
    - 67890  # Another vulnerability to ignore
  
  # Continue on vulnerabilities (don't fail CI)
  continue-on-vulnerability-error: false
  
  # Alert thresholds
  alert-threshold: medium
""",
        
        "pyproject.toml": """
[tool.safety]
# Ignore specific vulnerabilities
ignore = ["12345", "67890"]

# Set alert threshold
alert_threshold = "medium"

# Continue on errors
continue_on_error = false
"""
    }
    
    print("\nSafety Configuration Examples:")
    for filename, config in config_examples.items():
        print(f"\n{filename}:")
        print(config)


if __name__ == "__main__":
    print("=" * 60)
    print("Step 2: Safety - Vulnerability Scanning Tutorial")
    print("=" * 60)
    
    print("\n📦 Installed packages:")
    packages = get_installed_packages()
    for pkg in packages[:10]:  # Show first 10
        print(f"  {pkg['name']} == {pkg['version']}")
    print(f"  ... and {len(packages) - 10} more packages")
    
    print("\n🛡️ Safety Commands:")
    demonstrate_safety_commands()
    
    check_common_vulnerable_packages()
    
    print("\n📄 Requirements File Scanning:")
    demonstrate_requirements_scanning()
    
    print("\n📊 Understanding Safety Output:")
    analyze_safety_output()
    
    print("\n🔧 JSON Output Processing:")
    demonstrate_json_output()
    
    print("\n🚀 CI/CD Integration:")
    safety_in_ci_cd()
    
    print("\n🔄 Vulnerability Response:")
    vulnerability_response_workflow()
    
    print("\n⚡ Best Practices:")
    security_monitoring_best_practices()
    
    print("\n⚙️ Configuration:")
    create_safety_config()
    
    print("\n" + "=" * 60)
    print("Run 'safety check' to scan your current environment!")
    print("=" * 60)