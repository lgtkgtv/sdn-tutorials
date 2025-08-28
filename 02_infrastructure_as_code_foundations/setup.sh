#!/bin/bash
# Tutorial 02 - Infrastructure as Code Foundations Setup Script
# Sets up Terraform, Ansible, and network automation tools

set -e

# Color codes for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Configuration
PROJECT_NAME="${PROJECT_NAME:-iac_network_automation}"
TERRAFORM_VERSION="${TERRAFORM_VERSION:-1.6.6}"
ANSIBLE_VERSION="${ANSIBLE_VERSION:-9.1.0}"
VENV_NAME="${VENV_NAME:-venv}"

echo -e "${BLUE}🚀 Starting Tutorial 02: Infrastructure as Code Foundations Setup${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo "📦 Project name: $PROJECT_NAME"
echo "🏗️  Terraform version: $TERRAFORM_VERSION"
echo "🔧 Ansible version: $ANSIBLE_VERSION"
echo ""

# Create project directory
PROJECT_DIR="$(pwd)/$PROJECT_NAME"
if [ -d "$PROJECT_DIR" ]; then
    echo -e "${YELLOW}⚠️  Project directory already exists at $PROJECT_DIR${NC}"
    read -p "Do you want to remove it and start fresh? [y/N]: " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf "$PROJECT_DIR"
    else
        echo -e "${RED}❌ Setup cancelled${NC}"
        exit 1
    fi
fi

echo "📁 Creating project at: $PROJECT_DIR"
mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR"

# Check system dependencies
echo -e "\n${BLUE}📦 Checking system dependencies...${NC}"

check_command() {
    if command -v "$1" >/dev/null 2>&1; then
        echo -e "${GREEN}✅ $1 is installed${NC}"
        return 0
    else
        echo -e "${RED}❌ $1 is not installed${NC}"
        return 1
    fi
}

# Check required commands
MISSING_DEPS=0
for cmd in python3 pip3 git curl unzip; do
    check_command "$cmd" || MISSING_DEPS=1
done

if [ $MISSING_DEPS -eq 1 ]; then
    echo -e "${RED}Please install missing dependencies and try again${NC}"
    exit 1
fi

# Install Terraform
echo -e "\n${BLUE}🏗️  Installing Terraform...${NC}"
if ! command -v terraform >/dev/null 2>&1; then
    OS=$(uname -s | tr '[:upper:]' '[:lower:]')
    ARCH=$(uname -m)
    if [ "$ARCH" = "x86_64" ]; then
        ARCH="amd64"
    fi
    
    TERRAFORM_URL="https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_${OS}_${ARCH}.zip"
    
    mkdir -p "$PROJECT_DIR/bin"
    curl -sL "$TERRAFORM_URL" -o terraform.zip
    unzip -q terraform.zip -d "$PROJECT_DIR/bin"
    rm terraform.zip
    chmod +x "$PROJECT_DIR/bin/terraform"
    export PATH="$PROJECT_DIR/bin:$PATH"
    echo -e "${GREEN}✅ Terraform installed locally${NC}"
else
    echo -e "${GREEN}✅ Terraform already installed system-wide${NC}"
fi

# Setup Python virtual environment
echo -e "\n${BLUE}🐍 Setting up Python virtual environment...${NC}"
python3 -m venv "$VENV_NAME"
source "$VENV_NAME/bin/activate"

# Create requirements.txt
echo -e "\n${BLUE}📚 Creating requirements.txt...${NC}"
cat > requirements.txt << 'EOF'
# Ansible and network automation
ansible==9.1.0
ansible-core>=2.16.0
ansible-lint>=6.22.0
molecule>=6.0.0
molecule-docker>=2.1.0

# Network automation libraries
netmiko>=4.3.0
napalm>=4.1.0
nornir>=3.4.0
nornir-netmiko>=1.0.0
nornir-napalm>=0.4.0
nornir-utils>=0.2.0

# Infrastructure as Code
python-terraform>=0.10.1
pyhcl>=0.4.5
checkov>=3.1.0

# Testing and validation
pytest>=7.4.0
pytest-ansible>=4.1.0
pytest-testinfra>=10.0.0
yamllint>=1.33.0

# Utilities
jinja2>=3.1.0
pyyaml>=6.0
requests>=2.31.0
paramiko>=3.4.0
cryptography>=41.0.0
rich>=13.7.0
click>=8.1.0

# Documentation
mkdocs>=1.5.0
mkdocs-material>=9.5.0
EOF

# Install Python packages
echo -e "\n${BLUE}📦 Installing Python dependencies...${NC}"
pip install --upgrade pip
pip install -r requirements.txt

# Create project structure
echo -e "\n${BLUE}📁 Creating project structure...${NC}"
mkdir -p {terraform,ansible,scripts,tests,docs,inventory}
mkdir -p terraform/{modules,environments/{dev,staging,prod}}
mkdir -p ansible/{playbooks,roles,group_vars,host_vars,templates}
mkdir -p tests/{unit,integration,terraform,ansible}

# Create Terraform main configuration
echo -e "\n${BLUE}🏗️  Creating Terraform configurations...${NC}"
cat > terraform/main.tf << 'EOF'
# Tutorial 02 - Main Terraform Configuration
# Network Infrastructure as Code Example

terraform {
  required_version = ">= 1.6.0"
  
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
  }
}

# Docker provider for container-based network simulation
provider "docker" {}

# Network namespace simulation using Docker networks
module "network_infrastructure" {
  source = "./modules/network"
  
  environment = var.environment
  network_config = var.network_config
}

# Variables
variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "network_config" {
  description = "Network configuration"
  type = object({
    vpc_cidr     = string
    subnet_count = number
    enable_nat   = bool
  })
  default = {
    vpc_cidr     = "10.0.0.0/16"
    subnet_count = 3
    enable_nat   = true
  }
}

# Outputs
output "network_id" {
  description = "Network ID"
  value       = module.network_infrastructure.network_id
}

output "subnet_ids" {
  description = "Subnet IDs"
  value       = module.network_infrastructure.subnet_ids
}
EOF

# Create network module
mkdir -p terraform/modules/network
cat > terraform/modules/network/main.tf << 'EOF'
# Network Module - Simulates network infrastructure using Docker

resource "docker_network" "main" {
  name = "${var.environment}-network"
  
  ipam_config {
    subnet  = var.network_config.vpc_cidr
    gateway = cidrhost(var.network_config.vpc_cidr, 1)
  }
  
  driver = "bridge"
  
  labels {
    label = "environment"
    value = var.environment
  }
  
  labels {
    label = "managed_by"
    value = "terraform"
  }
}

# Create multiple subnets (simulated as Docker networks)
resource "docker_network" "subnets" {
  count = var.network_config.subnet_count
  
  name = "${var.environment}-subnet-${count.index + 1}"
  
  ipam_config {
    subnet = cidrsubnet(var.network_config.vpc_cidr, 8, count.index + 1)
  }
  
  driver = "bridge"
  
  labels {
    label = "environment"
    value = var.environment
  }
  
  labels {
    label = "subnet_index"
    value = count.index + 1
  }
}

# Variables
variable "environment" {
  description = "Environment name"
  type        = string
}

variable "network_config" {
  description = "Network configuration"
  type = object({
    vpc_cidr     = string
    subnet_count = number
    enable_nat   = bool
  })
}

# Outputs
output "network_id" {
  value = docker_network.main.id
}

output "subnet_ids" {
  value = docker_network.subnets[*].id
}
EOF

# Create Ansible inventory
echo -e "\n${BLUE}🔧 Creating Ansible configuration...${NC}"
cat > ansible/ansible.cfg << 'EOF'
[defaults]
inventory = inventory/hosts.yaml
host_key_checking = False
retry_files_enabled = False
stdout_callback = yaml
callback_whitelist = profile_tasks
gathering = smart
fact_caching = jsonfile
fact_caching_connection = /tmp/ansible_cache
fact_caching_timeout = 3600

[inventory]
enable_plugins = yaml, ini, auto

[ssh_connection]
pipelining = True
control_path = /tmp/ansible-ssh-%%h-%%p-%%r
EOF

# Create sample inventory
cat > inventory/hosts.yaml << 'EOF'
all:
  children:
    network_devices:
      hosts:
        router01:
          ansible_host: localhost
          ansible_connection: local
          device_type: router
          interfaces:
            - name: eth0
              ip: 10.0.1.1/24
            - name: eth1
              ip: 10.0.2.1/24
        switch01:
          ansible_host: localhost
          ansible_connection: local
          device_type: switch
          vlans:
            - id: 10
              name: management
            - id: 20
              name: production
    servers:
      hosts:
        web01:
          ansible_host: localhost
          ansible_connection: local
          services:
            - nginx
            - docker
  vars:
    ansible_python_interpreter: /usr/bin/python3
    network_os: linux
EOF

# Create sample Ansible playbook
cat > ansible/playbooks/network_config.yml << 'EOF'
---
# Tutorial 02 - Network Configuration Playbook
- name: Configure Network Infrastructure
  hosts: network_devices
  gather_facts: yes
  
  tasks:
    - name: Display device information
      debug:
        msg: |
          Device: {{ inventory_hostname }}
          Type: {{ device_type }}
          {% if interfaces is defined %}
          Interfaces: {{ interfaces | length }}
          {% endif %}
          {% if vlans is defined %}
          VLANs: {{ vlans | length }}
          {% endif %}
    
    - name: Create configuration backup directory
      file:
        path: "{{ playbook_dir }}/../../backups"
        state: directory
        mode: '0755'
      run_once: true
    
    - name: Generate device configuration
      template:
        src: "{{ device_type }}_config.j2"
        dest: "{{ playbook_dir }}/../../backups/{{ inventory_hostname }}.cfg"
      when: device_type is defined
    
    - name: Validate configuration
      assert:
        that:
          - device_type in ['router', 'switch', 'firewall']
        fail_msg: "Unknown device type: {{ device_type }}"
        success_msg: "Device type {{ device_type }} is valid"
EOF

# Create Jinja2 templates
cat > ansible/templates/router_config.j2 << 'EOF'
! Router Configuration - {{ inventory_hostname }}
! Generated by Ansible - {{ ansible_date_time.iso8601 }}
!
hostname {{ inventory_hostname }}
!
{% for interface in interfaces | default([]) %}
interface {{ interface.name }}
  ip address {{ interface.ip }}
  no shutdown
!
{% endfor %}
!
! End of configuration
EOF

cat > ansible/templates/switch_config.j2 << 'EOF'
! Switch Configuration - {{ inventory_hostname }}
! Generated by Ansible - {{ ansible_date_time.iso8601 }}
!
hostname {{ inventory_hostname }}
!
{% for vlan in vlans | default([]) %}
vlan {{ vlan.id }}
  name {{ vlan.name }}
!
{% endfor %}
!
! End of configuration
EOF

# Create test files
echo -e "\n${BLUE}🧪 Creating test files...${NC}"
cat > tests/test_terraform.py << 'EOF'
"""Tests for Terraform configurations"""
import os
import json
import subprocess
import pytest
from pathlib import Path

class TestTerraformConfig:
    """Test Terraform infrastructure configurations"""
    
    def setup_class(self):
        """Setup test environment"""
        self.terraform_dir = Path(__file__).parent.parent / "terraform"
        os.chdir(self.terraform_dir)
        subprocess.run(["terraform", "init"], check=True, capture_output=True)
    
    def test_terraform_validate(self):
        """Test that Terraform configuration is valid"""
        result = subprocess.run(
            ["terraform", "validate", "-json"],
            capture_output=True,
            text=True
        )
        validation = json.loads(result.stdout)
        assert validation["valid"] is True
        assert len(validation.get("error_count", 0)) == 0
    
    def test_terraform_plan(self):
        """Test that Terraform can create a plan"""
        result = subprocess.run(
            ["terraform", "plan", "-input=false"],
            capture_output=True,
            text=True
        )
        assert result.returncode == 0
        assert "Plan:" in result.stdout or "No changes" in result.stdout
    
    def test_module_structure(self):
        """Test that required modules exist"""
        network_module = self.terraform_dir / "modules" / "network"
        assert network_module.exists()
        assert (network_module / "main.tf").exists()
EOF

cat > tests/test_ansible.py << 'EOF'
"""Tests for Ansible playbooks and roles"""
import subprocess
import yaml
import pytest
from pathlib import Path

class TestAnsibleConfig:
    """Test Ansible configurations and playbooks"""
    
    def setup_class(self):
        """Setup test environment"""
        self.ansible_dir = Path(__file__).parent.parent / "ansible"
        self.inventory_dir = Path(__file__).parent.parent / "inventory"
    
    def test_inventory_syntax(self):
        """Test that inventory file has valid syntax"""
        inventory_file = self.inventory_dir / "hosts.yaml"
        assert inventory_file.exists()
        
        with open(inventory_file) as f:
            inventory = yaml.safe_load(f)
        
        assert "all" in inventory
        assert "children" in inventory["all"]
    
    def test_playbook_syntax(self):
        """Test that playbooks have valid syntax"""
        playbook = self.ansible_dir / "playbooks" / "network_config.yml"
        
        result = subprocess.run(
            ["ansible-playbook", "--syntax-check", str(playbook)],
            capture_output=True,
            text=True
        )
        assert result.returncode == 0
    
    def test_ansible_lint(self):
        """Run ansible-lint on playbooks"""
        playbooks_dir = self.ansible_dir / "playbooks"
        
        result = subprocess.run(
            ["ansible-lint", str(playbooks_dir)],
            capture_output=True,
            text=True
        )
        # ansible-lint returns 0 for success, 2 for violations
        assert result.returncode in [0, 2]
EOF

# Create activation script
echo -e "\n${BLUE}🔧 Creating activation script...${NC}"
cat > activate.sh << 'EOF'
#!/bin/bash
# Activation script for Tutorial 02

# Activate Python virtual environment
if [ -f "venv/bin/activate" ]; then
    source venv/bin/activate
    echo "✅ Python virtual environment activated"
fi

# Add local bin to PATH for Terraform
if [ -d "bin" ]; then
    export PATH="$(pwd)/bin:$PATH"
    echo "✅ Local bin directory added to PATH"
fi

# Set Ansible configuration
export ANSIBLE_CONFIG="$(pwd)/ansible/ansible.cfg"
echo "✅ Ansible configuration set"

# Display status
echo ""
echo "📊 Environment Status:"
echo "  Terraform: $(terraform version -json 2>/dev/null | jq -r '.terraform_version' || echo 'not found')"
echo "  Ansible: $(ansible --version | head -1 || echo 'not found')"
echo "  Python: $(python --version)"
echo ""
echo "🎯 Ready for Infrastructure as Code development!"
EOF
chmod +x activate.sh

# Create Makefile for convenience
echo -e "\n${BLUE}📝 Creating Makefile...${NC}"
cat > Makefile << 'EOF'
.PHONY: help init validate plan apply destroy test clean

help:  ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

init:  ## Initialize Terraform and Ansible
	cd terraform && terraform init
	ansible-galaxy collection install community.general

validate:  ## Validate Terraform and Ansible configurations
	cd terraform && terraform validate
	ansible-playbook --syntax-check ansible/playbooks/*.yml

plan:  ## Run Terraform plan
	cd terraform && terraform plan

apply:  ## Apply Terraform configuration
	cd terraform && terraform apply -auto-approve

destroy:  ## Destroy Terraform resources
	cd terraform && terraform destroy -auto-approve

test:  ## Run all tests
	pytest tests/ -v
	cd terraform && terraform validate
	ansible-lint ansible/playbooks/

ansible-run:  ## Run Ansible playbook
	ansible-playbook -i inventory/hosts.yaml ansible/playbooks/network_config.yml

clean:  ## Clean up generated files
	find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name "*.pyc" -delete
	rm -rf .pytest_cache/
	rm -rf terraform/.terraform/
	rm -f terraform/.terraform.lock.hcl
	rm -f terraform/terraform.tfstate*
EOF

# Create .gitignore
echo -e "\n${BLUE}📄 Creating .gitignore...${NC}"
cat > .gitignore << 'EOF'
# Python
__pycache__/
*.pyc
*.pyo
*.pyd
.Python
*.egg-info/
venv/
.env

# Terraform
*.tfstate
*.tfstate.*
.terraform/
.terraform.lock.hcl
*.tfplan
*.tfvars
override.tf
override.tf.json
*_override.tf
*_override.tf.json

# Ansible
*.retry
ansible.log
/tmp/

# IDE
.vscode/
.idea/
*.swp
*.swo
*~
.DS_Store

# Testing
.pytest_cache/
.coverage
htmlcov/
.tox/
.hypothesis/

# Backups
backups/
*.bak
*.backup
EOF

# Initialize git repository
echo -e "\n${BLUE}🎯 Initializing git repository...${NC}"
git init
git add .
git commit -m "Initial commit - Tutorial 02: Infrastructure as Code Foundations"

# Display summary
echo -e "\n${GREEN}✅ Setup completed successfully!${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "📋 Next steps:"
echo "1. cd $PROJECT_DIR"
echo "2. source activate.sh"
echo "3. make init"
echo "4. make test"
echo ""
echo "📚 Available commands:"
echo "  make help         - Show all available commands"
echo "  make validate     - Validate configurations"
echo "  make plan         - Preview infrastructure changes"
echo "  make apply        - Apply infrastructure changes"
echo "  make ansible-run  - Run Ansible playbooks"
echo "  make test         - Run all tests"
echo ""
echo "🎯 Project created at: $PROJECT_DIR"