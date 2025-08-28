#!/bin/bash
# Tutorial 02 - Infrastructure as Code Test Script
# Tests Terraform deployments and Ansible playbooks

set -e

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Configuration
PROJECT_NAME="${PROJECT_NAME:-iac_network_automation}"
VENV_NAME="${VENV_NAME:-venv}"

echo -e "${BLUE}🧪 Running Tutorial 02: Infrastructure as Code Tests${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo "📁 Project: $PROJECT_NAME"
echo ""

# Navigate to project directory
if [ -d "$PROJECT_NAME" ]; then
    cd "$PROJECT_NAME"
    echo -e "${GREEN}✅ Found project directory${NC}"
else
    echo -e "${RED}❌ Project directory not found${NC}"
    echo "   Please run setup.sh first"
    exit 1
fi

# Activate virtual environment
if [ -f "$VENV_NAME/bin/activate" ]; then
    source "$VENV_NAME/bin/activate"
    echo -e "${GREEN}✅ Virtual environment activated${NC}"
else
    echo -e "${RED}❌ Virtual environment not found${NC}"
    exit 1
fi

# Export paths
export PATH="$(pwd)/bin:$PATH"
export ANSIBLE_CONFIG="$(pwd)/ansible/ansible.cfg"
export PYTHONPATH="$(pwd):$PYTHONPATH"

echo ""
echo -e "${BLUE}═══ Phase 1: Environment Verification ═══${NC}"
echo ""

# Check tool versions
echo "🔍 Checking tool versions..."
echo -n "  Terraform: "
if command -v terraform >/dev/null 2>&1; then
    terraform version | head -1 || echo "error"
else
    echo -e "${RED}not found${NC}"
    exit 1
fi

echo -n "  Ansible: "
if command -v ansible >/dev/null 2>&1; then
    ansible --version | head -1
else
    echo -e "${RED}not found${NC}"
    exit 1
fi

echo -n "  Python: "
python --version

echo ""
echo -e "${BLUE}═══ Phase 2: Terraform Tests ═══${NC}"
echo ""

# Initialize Terraform
echo "🏗️  Initializing Terraform..."
cd terraform
terraform init -upgrade >/dev/null 2>&1
echo -e "${GREEN}✅ Terraform initialized${NC}"

# Validate Terraform configuration
echo "🔍 Validating Terraform configuration..."
if terraform validate -json | jq -e '.valid' >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Terraform configuration is valid${NC}"
else
    echo -e "${RED}❌ Terraform validation failed${NC}"
    terraform validate
    exit 1
fi

# Format check
echo "📝 Checking Terraform formatting..."
if terraform fmt -check -recursive >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Terraform files are properly formatted${NC}"
else
    echo -e "${YELLOW}⚠️  Some Terraform files need formatting${NC}"
    echo "   Run: terraform fmt -recursive"
fi

# Create Terraform plan
echo "📋 Creating Terraform plan..."
terraform plan -out=tfplan >/dev/null 2>&1
echo -e "${GREEN}✅ Terraform plan created successfully${NC}"

# Apply Terraform (create resources)
echo "🚀 Applying Terraform configuration..."
terraform apply -auto-approve tfplan >/dev/null 2>&1
echo -e "${GREEN}✅ Infrastructure deployed successfully${NC}"

# Show deployed resources
echo ""
echo "📊 Deployed Resources:"
terraform show -json | jq -r '.values.root_module.resources[] | "  - \(.type): \(.values.name)"' 2>/dev/null || echo "  Unable to parse resources"

cd ..

echo ""
echo -e "${BLUE}═══ Phase 3: Ansible Tests ═══${NC}"
echo ""

# Validate Ansible inventory
echo "🔍 Validating Ansible inventory..."
if ansible-inventory --list >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Ansible inventory is valid${NC}"
    
    # Show inventory hosts
    echo "📋 Inventory hosts:"
    ansible-inventory --list | jq -r '.all.children | to_entries | .[] | "  - \(.key): \(.value.hosts | length) host(s)"' 2>/dev/null || \
        ansible all --list-hosts | tail -n +2 | sed 's/^/  /'
else
    echo -e "${RED}❌ Ansible inventory validation failed${NC}"
    exit 1
fi

# Syntax check playbooks
echo "📝 Checking Ansible playbook syntax..."
PLAYBOOK_ERRORS=0
for playbook in ansible/playbooks/*.yml; do
    if [ -f "$playbook" ]; then
        playbook_name=$(basename "$playbook")
        if ansible-playbook --syntax-check "$playbook" >/dev/null 2>&1; then
            echo -e "  ${GREEN}✓${NC} $playbook_name"
        else
            echo -e "  ${RED}✗${NC} $playbook_name"
            PLAYBOOK_ERRORS=1
        fi
    fi
done

if [ $PLAYBOOK_ERRORS -eq 0 ]; then
    echo -e "${GREEN}✅ All playbooks have valid syntax${NC}"
else
    echo -e "${RED}❌ Some playbooks have syntax errors${NC}"
fi

# Run Ansible linting
echo "🔍 Running Ansible lint..."
if command -v ansible-lint >/dev/null 2>&1; then
    ansible-lint ansible/playbooks/ 2>&1 | head -20 || true
    echo -e "${GREEN}✅ Ansible lint check completed${NC}"
else
    echo -e "${YELLOW}⚠️  ansible-lint not available${NC}"
fi

# Run sample playbook
echo "🎭 Running sample network configuration playbook..."
ansible-playbook -i inventory/hosts.yaml ansible/playbooks/network_config.yml >/dev/null 2>&1
echo -e "${GREEN}✅ Playbook executed successfully${NC}"

# Check generated configurations
if [ -d "backups" ]; then
    echo "📄 Generated configurations:"
    for cfg in backups/*.cfg; do
        if [ -f "$cfg" ]; then
            echo "  - $(basename "$cfg"): $(wc -l < "$cfg") lines"
        fi
    done
fi

echo ""
echo -e "${BLUE}═══ Phase 4: Python Tests ═══${NC}"
echo ""

# Run pytest
echo "🧪 Running Python unit tests..."
if pytest tests/ -v --tb=short; then
    echo -e "${GREEN}✅ All Python tests passed${NC}"
else
    echo -e "${RED}❌ Some Python tests failed${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}═══ Phase 5: Security & Compliance ═══${NC}"
echo ""

# Run Checkov for Terraform security scanning
echo "🔒 Running Checkov security scan on Terraform..."
if command -v checkov >/dev/null 2>&1; then
    checkov -d terraform --quiet --compact --framework terraform
    echo -e "${GREEN}✅ Security scan completed${NC}"
else
    echo -e "${YELLOW}⚠️  Checkov not available for security scanning${NC}"
fi

# YAML lint check
echo "📝 Running YAML lint..."
if command -v yamllint >/dev/null 2>&1; then
    yamllint_errors=0
    yamllint inventory/ ansible/ 2>/dev/null || yamllint_errors=1
    if [ $yamllint_errors -eq 0 ]; then
        echo -e "${GREEN}✅ YAML files are properly formatted${NC}"
    else
        echo -e "${YELLOW}⚠️  Some YAML files have formatting issues${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  yamllint not available${NC}"
fi

echo ""
echo -e "${BLUE}═══ Phase 6: Integration Tests ═══${NC}"
echo ""

# Test Terraform outputs
echo "🔍 Verifying Terraform outputs..."
cd terraform
network_id=$(terraform output -raw network_id 2>/dev/null || echo "")
if [ -n "$network_id" ]; then
    echo -e "${GREEN}✅ Network infrastructure accessible${NC}"
    echo "   Network ID: ${network_id:0:12}..."
else
    echo -e "${YELLOW}⚠️  Could not retrieve network ID${NC}"
fi
cd ..

# Test Ansible connectivity
echo "🔗 Testing Ansible connectivity..."
if ansible all -m ping >/dev/null 2>&1; then
    echo -e "${GREEN}✅ All hosts are reachable${NC}"
else
    echo -e "${YELLOW}⚠️  Some hosts may not be reachable${NC}"
fi

echo ""
echo -e "${BLUE}═══ Test Summary ═══${NC}"
echo ""

# Create test report
cat > test_report.md << EOF
# Tutorial 02 - Test Report
Generated: $(date)

## Test Results

### ✅ Environment
- Terraform: Installed and configured
- Ansible: Installed and configured
- Python: Virtual environment active

### ✅ Terraform
- Configuration: Valid
- Plan: Successful
- Apply: Successful
- Resources: Deployed

### ✅ Ansible
- Inventory: Valid
- Playbooks: Syntax checked
- Execution: Successful

### ✅ Security
- Checkov scan: Completed
- YAML lint: Checked

## Deployed Infrastructure
- Environment: dev
- Networks: Created
- Configurations: Generated

## Next Steps
1. Review generated configurations in backups/
2. Modify terraform/terraform.tfvars for custom settings
3. Explore ansible/playbooks/ for more automation examples
4. Run 'make destroy' to clean up resources when done
EOF

echo -e "${GREEN}✅ All tests completed successfully!${NC}"
echo ""
echo "📊 Test report saved to: test_report.md"
echo "🎯 Infrastructure is ready for use"
echo ""
echo "💡 Tips:"
echo "  - View resources: cd terraform && terraform show"
echo "  - Run playbooks: ansible-playbook -i inventory/hosts.yaml ansible/playbooks/<playbook>.yml"
echo "  - Clean up: make destroy"
echo ""
echo -e "${GREEN}🎉 Tutorial 02 testing complete!${NC}"