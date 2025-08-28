#!/bin/bash
# Activation script for SDN Tutorial environment

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Set PROJECT_ROOT to the script directory
export PROJECT_ROOT="$SCRIPT_DIR"
export PROJECT_NAME="${PROJECT_NAME:-sdn-everything}"
export VENV_NAME="${VENV_NAME:-venv}"

echo "🚀 Activating SDN Tutorial environment..."
echo "📁 Project root: $PROJECT_ROOT"

# Activate Python virtual environment
if [ -f "$PROJECT_ROOT/$VENV_NAME/bin/activate" ]; then
    source "$PROJECT_ROOT/$VENV_NAME/bin/activate"
    echo "🐍 Python virtual environment activated"
else
    echo "⚠️  Virtual environment not found at $PROJECT_ROOT/$VENV_NAME"
    echo "   Run the setup script first"
    return 1
fi

# Add project src to PYTHONPATH
export PYTHONPATH="$PROJECT_ROOT/src:$PYTHONPATH"

# Set up kubectl context (if kind cluster exists)
if kind get clusters 2>/dev/null | grep -q "${CLUSTER_NAME:-tutorial-cluster}"; then
    kubectl config use-context "kind-${CLUSTER_NAME:-tutorial-cluster}"
    echo "☸️  Kubectl context set to kind-${CLUSTER_NAME:-tutorial-cluster}"
fi

echo "✅ Environment activated!"
echo ""
echo "Available commands:"
echo "  make test          # Run tests"
echo "  make security      # Security scan"
echo "  make format        # Format code"
echo "  make k8s-setup     # Setup Kubernetes"
echo "  make clean         # Clean up"
