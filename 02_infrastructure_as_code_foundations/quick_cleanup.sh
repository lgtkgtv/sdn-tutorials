#!/bin/bash
# Tutorial 02 - Quick Cleanup Script (Non-interactive)
# Removes all Infrastructure as Code resources without prompts

set -e

# Configuration
PROJECT_NAME="${PROJECT_NAME:-iac_network_automation}"
VENV_NAME="${VENV_NAME:-venv}"

echo "🧹 Tutorial 02: Quick cleanup started..."
echo "📁 Project: $PROJECT_NAME"

# Check if project exists
if [ ! -d "$PROJECT_NAME" ]; then
    echo "⚠️  Project directory not found"
    exit 0
fi

cd "$PROJECT_NAME"
echo "✅ Found project directory"

# 1. Destroy Terraform resources
echo "🏗️  Cleaning up Terraform resources..."
if [ -f "terraform/terraform.tfstate" ]; then
    cd terraform
    terraform destroy -auto-approve >/dev/null 2>&1 || true
    cd ..
    echo "✅ Terraform resources destroyed"
fi

# Remove Terraform files
rm -rf terraform/.terraform terraform/.terraform.lock.hcl
rm -f terraform/terraform.tfstate* terraform/tfplan
echo "✅ Terraform state and cache removed"

# 2. Clean up Docker networks
echo "🐳 Cleaning up Docker resources..."
if command -v docker >/dev/null 2>&1; then
    # Remove networks created by this tutorial
    docker network ls --filter "label=managed_by=terraform" --format "{{.Name}}" | xargs -r docker network rm 2>/dev/null || true
    echo "✅ Docker networks removed"
else
    echo "ℹ️  Docker not available"
fi

# 3. Remove Python virtual environment
echo "🐍 Cleaning up Python environment..."
if [ -d "$VENV_NAME" ]; then
    rm -rf "$VENV_NAME"
    echo "✅ Virtual environment removed"
else
    echo "ℹ️  No virtual environment found"
fi

# 4. Remove generated files
echo "📄 Cleaning up generated files..."
rm -rf backups __pycache__ .pytest_cache .coverage htmlcov test_report.md
find . -type f -name "*.pyc" -delete 2>/dev/null || true
find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
echo "✅ Generated files removed"

# 5. Remove bin directory (local Terraform installation)
if [ -d "bin" ]; then
    rm -rf bin
    echo "✅ Local binaries removed"
fi

echo ""
echo "✅ Quick cleanup completed!"
echo "📁 Project source code preserved at: $(pwd)"
echo ""
echo "💡 To restart the tutorial:"
echo "   1. cd .."
echo "   2. ./setup.sh"
echo "   3. cd $PROJECT_NAME"
echo "   4. source activate.sh"
echo ""
echo "🗑️  To remove everything including source code:"
echo "   cd .. && rm -rf $PROJECT_NAME"