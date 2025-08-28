# Tutorial 02: Infrastructure as Code Foundations

Learn Infrastructure as Code (IaC) principles and network automation using Terraform, Ansible, and modern automation tools.

## Overview

This tutorial teaches you to:
- **Terraform Basics**: Provision and manage network infrastructure as code
- **Ansible Automation**: Configure network devices and services with playbooks
- **Network Simulation**: Use Docker networks to simulate complex topologies
- **Testing & Validation**: Implement testing strategies for IaC
- **Security Scanning**: Apply security best practices to infrastructure code

## Prerequisites

- Docker installed and running
- Python 3.8+ with pip
- Git
- curl and unzip utilities
- Basic understanding of networking concepts
- Familiarity with YAML and command line

## Quick Start

```bash
# 1. Run setup script
./setup.sh

# 2. Enter project directory and activate environment
cd iac_network_automation
source activate.sh

# 3. Initialize tools
make init

# 4. Run tests
./test.sh
```

## Project Structure

```
iac_network_automation/
├── terraform/                    # Terraform configurations
│   ├── main.tf                  # Main infrastructure definition
│   ├── modules/network/         # Network module
│   └── environments/            # Environment-specific configs
├── ansible/                     # Ansible configurations
│   ├── playbooks/              # Automation playbooks
│   ├── roles/                  # Reusable roles
│   ├── templates/              # Jinja2 templates
│   └── ansible.cfg             # Ansible configuration
├── inventory/                   # Host inventories
│   └── hosts.yaml              # Main inventory file
├── tests/                      # Test files
│   ├── test_terraform.py       # Terraform tests
│   └── test_ansible.py         # Ansible tests
├── scripts/                    # Utility scripts
├── Makefile                    # Common operations
└── activate.sh                 # Environment activation
```

## Learning Path

### Phase 1: Terraform Foundations (30 min)
- Infrastructure as Code concepts
- Terraform syntax and providers
- Creating network resources with Docker provider
- State management and planning

### Phase 2: Ansible Automation (30 min)
- Ansible basics and inventory management
- Writing network configuration playbooks
- Using Jinja2 templates for device configs
- Running automation tasks

### Phase 3: Integration & Testing (20 min)
- Combining Terraform and Ansible workflows
- Implementing infrastructure tests
- Security scanning with Checkov
- Validation and linting

### Phase 4: Advanced Topics (20 min)
- Module development and reusability
- Environment management (dev/staging/prod)
- CI/CD pipeline concepts
- Troubleshooting and debugging

## Key Concepts

### Infrastructure as Code (IaC)
- **Declarative approach**: Describe desired state, not steps
- **Version control**: Track infrastructure changes like application code
- **Reproducibility**: Create identical environments reliably
- **Automation**: Reduce manual configuration errors

### Network Automation Benefits
- **Consistency**: Standardized configurations across devices
- **Speed**: Rapid deployment and updates
- **Compliance**: Enforce security and operational policies
- **Scalability**: Manage hundreds of devices efficiently

## Tools and Technologies

- **Terraform 1.6+**: Infrastructure provisioning
- **Ansible 9.0+**: Configuration management
- **Docker**: Network simulation platform
- **Python**: Scripting and test automation
- **Jinja2**: Configuration templating
- **YAML**: Data serialization and configuration
- **Git**: Version control

## Common Operations

```bash
# Initialize environment
make init                       # Initialize Terraform and Ansible

# Validation
make validate                   # Validate all configurations
terraform validate             # Check Terraform syntax
ansible-playbook --syntax-check ansible/playbooks/*.yml

# Infrastructure operations  
make plan                       # Preview infrastructure changes
make apply                      # Apply infrastructure changes
make destroy                    # Remove all infrastructure

# Ansible operations
make ansible-run               # Run network configuration playbook
ansible-playbook -i inventory/hosts.yaml ansible/playbooks/network_config.yml

# Testing
make test                      # Run all tests
pytest tests/ -v               # Run Python tests only
```

## Environment Variables

```bash
# Project configuration
PROJECT_NAME=iac_network_automation    # Project directory name
TERRAFORM_VERSION=1.6.6               # Terraform version to install
ANSIBLE_VERSION=9.1.0                 # Ansible version to install

# Terraform variables (create terraform.tfvars)
environment = "dev"                    # Environment name
network_config = {
  vpc_cidr     = "10.0.0.0/16"        # Network CIDR
  subnet_count = 3                    # Number of subnets
  enable_nat   = true                 # Enable NAT gateway
}
```

## Troubleshooting

### Common Issues

**Terraform init fails:**
```bash
# Clean and reinitialize
rm -rf .terraform .terraform.lock.hcl
terraform init
```

**Docker permission errors:**
```bash
# Add user to docker group (logout/login required)
sudo usermod -aG docker $USER
```

**Ansible connection issues:**
```bash
# Test connectivity
ansible all -m ping
# Check inventory
ansible-inventory --list
```

**Python package conflicts:**
```bash
# Recreate virtual environment
rm -rf venv
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

### Verification Commands

```bash
# Check tool versions
terraform version
ansible --version
docker --version
python --version

# Validate configurations
terraform validate
ansible-lint ansible/playbooks/
yamllint inventory/ ansible/

# Test network connectivity
docker network ls
ansible all --list-hosts
```

## Security Best Practices

- Use Checkov for Terraform security scanning
- Implement least-privilege access policies
- Store secrets in secure credential management
- Regularly update dependencies and base images
- Enable audit logging for infrastructure changes

## Next Steps

After completing this tutorial:

1. **Tutorial 03**: SDN Controller Integration - Learn OpenDaylight and Lighty.io
2. **Advanced IaC**: Explore Terraform modules and complex networking
3. **CI/CD Integration**: Implement automated pipelines
4. **Cloud Providers**: Apply concepts to AWS, Azure, or GCP

## Resources

- [Terraform Documentation](https://developer.hashicorp.com/terraform/docs)
- [Ansible Documentation](https://docs.ansible.com/)
- [Network Automation with Ansible](https://docs.ansible.com/ansible/latest/network/index.html)
- [Docker Networking](https://docs.docker.com/network/)
- [Infrastructure as Code Patterns](https://www.terraform.io/docs/language/index.html)

## Support

- Check the `test_report.md` file generated after running tests
- Review logs in the project directory
- Use `make help` for available commands
- Refer to tool-specific documentation for advanced usage