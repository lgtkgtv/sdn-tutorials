#!/bin/bash
# SDN Tutorial 1 - Quick Cleanup Script
# Removes common resources without prompts (use with caution)

set -e

# Environment variables
PROJECT_ROOT="${PROJECT_ROOT:-$(pwd)}"
PROJECT_NAME="${PROJECT_NAME:-sdn-everything}"
VENV_NAME="${VENV_NAME:-venv}"
CLUSTER_NAME="${CLUSTER_NAME:-tutorial-cluster}"

echo "🧹 Quick cleanup started..."
echo "📁 Project: $PROJECT_ROOT/$PROJECT_NAME"

# Navigate to project directory
if [ -d "$PROJECT_ROOT/$PROJECT_NAME" ]; then
    cd "$PROJECT_ROOT/$PROJECT_NAME"
    echo "✅ Found project directory"
else
    echo "⚠️  Project directory not found"
    exit 1
fi

# 1. Stop and remove kind cluster
echo "🎪 Cleaning up Kubernetes cluster..."
if kind get clusters 2>/dev/null | grep -q "$CLUSTER_NAME"; then
    kind delete cluster --name "$CLUSTER_NAME"
    echo "✅ Cluster removed"
else
    echo "ℹ️  No cluster found"
fi

# 2. Clean up virtual environment
echo "🐍 Cleaning up virtual environment..."
if [ -d "$VENV_NAME" ]; then
    rm -rf "$VENV_NAME"
    echo "✅ Virtual environment removed"
else
    echo "ℹ️  No virtual environment found"
fi

# 3. Remove generated files
echo "📄 Cleaning up generated files..."
rm -rf .pytest_cache/ htmlcov/ src/__pycache__/ tests/__pycache__/
rm -f network-policies.yaml test-deployment.yaml kind-config.yaml
rm -f bandit-report.json .coverage *.log
echo "✅ Generated files removed"

# 4. Clean up Docker containers (tutorial-related only)
echo "🐳 Cleaning up Docker containers..."
if command -v docker >/dev/null 2>&1; then
    # Stop tutorial-related containers
    docker ps -a --filter "name=sdn" --filter "name=tutorial" --filter "name=odl" --format "{{.Names}}" | xargs -r docker stop 2>/dev/null || true
    docker ps -a --filter "name=sdn" --filter "name=tutorial" --filter "name=odl" --format "{{.Names}}" | xargs -r docker rm 2>/dev/null || true
    
    # Remove dangling images
    docker image prune -f >/dev/null 2>&1 || true
    echo "✅ Docker cleanup completed"
else
    echo "ℹ️  Docker not available"
fi

echo ""
echo "✅ Quick cleanup completed!"
echo "📁 Project source code preserved at: $(pwd)"
echo "🔄 To restart: source activate.sh (after running setup again)"