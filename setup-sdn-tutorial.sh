#!/bin/bash
# Tutorial 1 - Ubuntu System Setup Script (Improved)
set -e

# Environment variables
PROJECT_ROOT="${PROJECT_ROOT:-$(pwd)}"
PROJECT_NAME="${PROJECT_NAME:-sdn-everything}"
VENV_NAME="${VENV_NAME:-venv}"

echo "🚀 Starting SDN Tutorial 1 Setup..."
echo "📁 Project root: $PROJECT_ROOT"
echo "📦 Project name: $PROJECT_NAME"

# Create project directory
PROJECT_DIR="$PROJECT_ROOT/$PROJECT_NAME"
echo "📁 Creating project at: $PROJECT_DIR"
mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR"

# Update system (only if needed packages are missing)
echo "📦 Checking system dependencies..."
MISSING_PACKAGES=()
command -v python3 >/dev/null || MISSING_PACKAGES+=(python3)
command -v pip3 >/dev/null || MISSING_PACKAGES+=(python3-pip)
dpkg -l | grep -q python3-venv || MISSING_PACKAGES+=(python3-venv)
command -v git >/dev/null || MISSING_PACKAGES+=(git)
command -v curl >/dev/null || MISSING_PACKAGES+=(curl)
command -v wget >/dev/null || MISSING_PACKAGES+=(wget)

if [ ${#MISSING_PACKAGES[@]} -gt 0 ]; then
    echo "📦 Installing missing packages: ${MISSING_PACKAGES[*]}"
    sudo apt-get update -y
    sudo apt-get install -y "${MISSING_PACKAGES[@]}"
fi

# Install Docker (if not present)
if ! command -v docker &> /dev/null; then
    echo "🐳 Installing Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker ${USER}
    rm get-docker.sh
    echo "⚠️  Docker installed. Please log out and back in to use Docker without sudo"
    DOCKER_RESTART_NEEDED=true
fi

# Install kubectl (if not present)
if ! command -v kubectl &> /dev/null; then
    echo "☸️  Installing kubectl..."
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    rm kubectl
fi

# Install kind (if not present)
if ! command -v kind &> /dev/null; then
    echo "🎪 Installing kind..."
    if [ $(uname -m) = "x86_64" ]; then
        curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
    elif [ $(uname -m) = "aarch64" ]; then
        curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-arm64
    fi
    chmod +x ./kind
    sudo mv ./kind /usr/local/bin/kind
fi

# Install Helm (if not present)
if ! command -v helm &> /dev/null; then
    echo "⛵ Installing Helm..."
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
fi

# Create Python virtual environment
echo "🐍 Setting up Python virtual environment..."
if [ ! -d "$VENV_NAME" ]; then
    python3 -m venv "$VENV_NAME"
fi

# Activate virtual environment
source "$VENV_NAME/bin/activate"

# Create requirements.txt
echo "📚 Creating requirements.txt..."
cat > requirements.txt << 'EOF'
pytest>=7.0.0
pytest-cov>=4.0.0
pyyaml>=6.0
kubernetes>=27.2.0
docker>=6.0.0
requests>=2.31.0
bandit[toml]>=1.7.0
safety>=2.3.0
black>=23.0.0
flake8>=6.0.0
isort>=5.12.0
mypy>=1.5.0
EOF

# Install Python dependencies
echo "📦 Installing Python dependencies..."
pip install --upgrade pip
pip install -r requirements.txt

# Create project structure
echo "📁 Creating project structure..."
mkdir -p {src,tests,infrastructure/modules/k8s-cluster,ansible/playbooks,config,.github/workflows,docs,scripts}

# Create .gitignore
echo "📄 Creating .gitignore..."
cat > .gitignore << 'EOF'
# Virtual environment
venv/
.venv/

# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
*.egg-info/
.installed.cfg
*.egg

# Testing
.pytest_cache/
.coverage
htmlcov/
.tox/
.cache
nosetests.xml
coverage.xml
*.cover
.hypothesis/

# IDEs
.vscode/
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# Project specific
network-policies.yaml
kind-config.yaml
*.log

# Secrets
*.key
*.pem
secrets/
EOF

# Create environment configuration
echo "⚙️  Creating environment configuration..."
cat > .env.example << 'EOF'
# Project Configuration
PROJECT_ROOT=/path/to/your/project
PROJECT_NAME=sdn-everything
VENV_NAME=venv

# Kubernetes Configuration
CLUSTER_NAME=tutorial-cluster
NAMESPACE=default

# Development Configuration
DEBUG=true
LOG_LEVEL=INFO
EOF

# Create activation script
echo "🔧 Creating activation script..."
cat > activate.sh << 'EOF'
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
EOF

chmod +x activate.sh

# Verification
echo ""
echo "🔍 Verifying installation..."
echo "Docker version:" $(docker --version 2>/dev/null || echo "Not available (restart required)")
echo "Kubectl version:" $(kubectl version --client --short 2>/dev/null || echo "Installation issue")
echo "Kind version:" $(kind --version 2>/dev/null || echo "Installation issue")
echo "Helm version:" $(helm version --short 2>/dev/null || echo "Installation issue")
echo "Python version:" $(python --version 2>/dev/null || echo "Installation issue")

echo ""
echo "✅ Setup completed successfully!"
echo ""
echo "📋 Next steps:"
if [ "$DOCKER_RESTART_NEEDED" = "true" ]; then
    echo "1. ⚠️  Log out and back in (for Docker group membership)"
    echo "2. cd $PROJECT_DIR"
    echo "3. source activate.sh"
    echo "4. Run the test script"
else
    echo "1. cd $PROJECT_DIR"
    echo "2. source activate.sh"
    echo "3. Run the test script"
fi
echo ""
echo "🎯 Project created at: $PROJECT_DIR"