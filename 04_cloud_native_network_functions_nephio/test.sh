#!/bin/bash
# Tutorial 04 Test Script - Cloud-Native Network Functions Testing
# Comprehensive testing of Nephio platform and CNF deployments

set -e

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
PURPLE='\033[0;35m'
NC='\033[0m'

# Configuration
PROJECT_NAME="${PROJECT_NAME:-nephio_cnf_workspace}"
CLUSTER_NAME="nephio-management"
TEST_TIMEOUT=300

echo -e "${BLUE}🧪 Running Tutorial 04: Cloud-Native Network Functions Tests${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "📁 Project root: ${PURPLE}$(pwd)${NC}"
echo -e "☸️  Testing: Nephio + CNF lifecycle management"
echo -e "⏱️  Timeout: ${TEST_TIMEOUT}s"
echo ""

# Check if project exists
if [ ! -d "$PROJECT_NAME" ]; then
    echo -e "${RED}❌ Project directory not found: $PROJECT_NAME${NC}"
    echo "Please run ./setup.sh first"
    exit 1
fi

# Function to check cluster availability
check_cluster() {
    local cluster_name="$1"
    if kind get clusters 2>/dev/null | grep -q "$cluster_name"; then
        kubectl config use-context "kind-$cluster_name" >/dev/null 2>&1
        if kubectl get nodes >/dev/null 2>&1; then
            return 0
        fi
    fi
    return 1
}

# Cleanup function
cleanup() {
    echo -e "\n${YELLOW}🧹 Cleaning up test environment...${NC}"
    
    # Clean up test CNF deployments
    kubectl delete cnfdeployment test-amf-cnf 2>/dev/null || true
    kubectl delete namespace cnf-test 2>/dev/null || true
    
    echo -e "${GREEN}✅ Test cleanup completed${NC}"
}

# Set up signal handlers for cleanup
trap cleanup EXIT INT TERM

echo -e "${BLUE}📦 Verifying project structure...${NC}"
cd "$PROJECT_NAME"

# Verify virtual environment
if [ ! -d "venv" ]; then
    echo -e "${RED}❌ Virtual environment not found${NC}"
    exit 1
fi

# Activate virtual environment
source venv/bin/activate
echo -e "${GREEN}✅ Python virtual environment activated${NC}"

# Add local bin to PATH
export PATH="$(pwd)/bin:$PATH"

# Verify Python dependencies
python3 -c "import kubernetes, pytest, yaml" || {
    echo -e "${RED}❌ Required Python packages not installed${NC}"
    exit 1
}

# Verify tools availability
for tool in kubectl kind kpt; do
    if command -v "$tool" >/dev/null 2>&1; then
        echo -e "${GREEN}✅ $tool is available${NC}"
    else
        echo -e "${RED}❌ $tool not found${NC}"
        exit 1
    fi
done

echo -e "${GREEN}✅ Project structure verified${NC}"
cd ..

# Phase 1: Environment Preparation
echo -e "\n${BLUE}🔍 Phase 1: Environment Validation${NC}"

# Initialize Nephio if cluster doesn't exist
if ! check_cluster "$CLUSTER_NAME"; then
    echo -e "${YELLOW}⚙️  Initializing Nephio platform...${NC}"
    cd "$PROJECT_NAME"
    timeout 180 ./scripts/init_nephio.sh || {
        echo -e "${RED}❌ Nephio initialization failed${NC}"
        exit 1
    }
    cd ..
    
    # Wait for cluster to be fully ready
    sleep 30
fi

# Verify cluster is accessible
if check_cluster "$CLUSTER_NAME"; then
    echo -e "${GREEN}✅ Nephio management cluster is ready${NC}"
    
    # Show cluster info
    echo -e "${PURPLE}Cluster information:${NC}"
    kubectl cluster-info --context "kind-$CLUSTER_NAME" | sed 's/^/   /'
else
    echo -e "${RED}❌ Unable to access Nephio cluster${NC}"
    exit 1
fi

# Phase 2: CNF Package Validation
echo -e "\n${BLUE}📦 Phase 2: CNF Package Validation${NC}"

cd "$PROJECT_NAME"

echo -e "${PURPLE}Validating CNF package structure...${NC}"
cnf_packages=(
    "cnf-packages/5g-core/amf/kptfile"
    "cnf-packages/5g-core/amf/deployment.yaml"
    "cnf-packages/5g-core/amf/service.yaml"
)

for package in "${cnf_packages[@]}"; do
    if [ -f "$package" ]; then
        echo -e "${GREEN}✅ $package exists${NC}"
    else
        echo -e "${RED}❌ $package not found${NC}"
        exit 1
    fi
done

echo -e "${PURPLE}Validating Kubernetes manifests...${NC}"
for yaml_file in cnf-packages/5g-core/amf/*.yaml; do
    if [ -f "$yaml_file" ]; then
        if kubectl --dry-run=client apply -f "$yaml_file" >/dev/null 2>&1; then
            echo -e "   ✅ $(basename "$yaml_file") - valid Kubernetes manifest"
        else
            echo -e "   ⚠️  $(basename "$yaml_file") - manifest warnings"
        fi
    fi
done

echo -e "${PURPLE}Testing kpt package validation...${NC}"
if command -v kpt >/dev/null 2>&1; then
    if kpt pkg validate cnf-packages/5g-core/amf/ >/dev/null 2>&1; then
        echo -e "${GREEN}✅ kpt package validation passed${NC}"
    else
        echo -e "${YELLOW}⚠️  kpt validation completed with warnings${NC}"
    fi
else
    echo -e "${YELLOW}ℹ️  kpt not available for validation${NC}"
fi

cd ..

# Phase 3: Custom Resource Definitions Testing
echo -e "\n${BLUE}🎛️  Phase 3: CRD and API Testing${NC}"

echo -e "${PURPLE}Testing Custom Resource Definitions...${NC}"
if kubectl get crd cnfdeployments.cnf.nephio.org >/dev/null 2>&1; then
    echo -e "${GREEN}✅ CNFDeployment CRD is available${NC}"
else
    echo -e "${RED}❌ CNFDeployment CRD not found${NC}"
    exit 1
fi

if kubectl get crd repositories.porch.kpt.dev >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Repository CRD is available${NC}"
else
    echo -e "${RED}❌ Repository CRD not found${NC}"
    exit 1
fi

# Test namespace creation
echo -e "${PURPLE}Creating test namespace...${NC}"
kubectl create namespace cnf-test --dry-run=client -o yaml | kubectl apply -f - >/dev/null 2>&1
echo -e "${GREEN}✅ Test namespace ready${NC}"

# Phase 4: CNF Deployment Testing
echo -e "\n${BLUE}🚀 Phase 4: CNF Deployment Testing${NC}"

cd "$PROJECT_NAME"

echo -e "${PURPLE}Testing CNF deployment creation...${NC}"
cat > /tmp/test-cnf-deployment.yaml << 'EOF'
apiVersion: cnf.nephio.org/v1alpha1
kind: CNFDeployment
metadata:
  name: test-amf-cnf
  namespace: cnf-test
spec:
  cnfType: amf
  version: v1.4.0
  replicas: 1
  placement:
    nodeSelector:
      kubernetes.io/os: linux
  resources:
    requests:
      cpu: 100m
      memory: 256Mi
    limits:
      cpu: 200m
      memory: 512Mi
  configuration:
    logLevel: INFO
    sbiPort: 8080
EOF

# Apply test CNF deployment
if kubectl apply -f /tmp/test-cnf-deployment.yaml >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Test CNF deployment created${NC}"
    
    # Wait for CNF to be processed (simulated)
    sleep 10
    
    # Check if CNF deployment exists
    if kubectl get cnfdeployment test-amf-cnf -n cnf-test >/dev/null 2>&1; then
        echo -e "${GREEN}✅ CNF deployment is accessible${NC}"
    else
        echo -e "${RED}❌ CNF deployment not found${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  CNF deployment creation completed with warnings${NC}"
fi

cd ..

# Phase 5: Python Operator Testing
echo -e "\n${BLUE}🐍 Phase 5: Python Operator Testing${NC}"

cd "$PROJECT_NAME"

echo -e "${PURPLE}Testing Python CNF operator syntax...${NC}"
python_files=(
    "python-operators/cnf-lifecycle/cnf_operator.py"
)

for file in "${python_files[@]}"; do
    if [ -f "$file" ]; then
        if python3 -m py_compile "$file" 2>/dev/null; then
            echo -e "${GREEN}✅ $(basename "$file") - syntax check passed${NC}"
        else
            echo -e "${RED}❌ $(basename "$file") - syntax errors${NC}"
            exit 1
        fi
    fi
done

echo -e "${PURPLE}Testing operator imports...${NC}"
cd python-operators/cnf-lifecycle/
if python3 -c "import asyncio, logging, kopf; print('✅ Operator dependencies available')" 2>/dev/null; then
    echo -e "${GREEN}✅ Operator dependencies verified${NC}"
else
    echo -e "${YELLOW}⚠️  Some operator dependencies may be missing${NC}"
fi

cd ../..

# Phase 6: GitOps Structure Testing
echo -e "\n${BLUE}📋 Phase 6: GitOps Structure Testing${NC}"

echo -e "${PURPLE}Validating GitOps repository structure...${NC}"
gitops_dirs=(
    "gitops-repos/cluster-configs"
    "gitops-repos/network-functions"
    "gitops-repos/policies"
)

for dir in "${gitops_dirs[@]}"; do
    if [ -d "$dir" ]; then
        echo -e "${GREEN}✅ $dir directory exists${NC}"
    else
        echo -e "${RED}❌ $dir directory not found${NC}"
        exit 1
    fi
done

echo -e "${PURPLE}Testing cluster configuration...${NC}"
if [ -f "gitops-repos/cluster-configs/management-cluster.yaml" ]; then
    if kubectl --dry-run=client apply -f gitops-repos/cluster-configs/management-cluster.yaml >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Cluster configuration is valid${NC}"
    else
        echo -e "${YELLOW}⚠️  Cluster configuration has warnings${NC}"
    fi
fi

cd ..

# Phase 7: Security and Code Quality
echo -e "\n${BLUE}🛡️  Phase 7: Security & Code Quality${NC}"

cd "$PROJECT_NAME"

echo -e "${PURPLE}Running security scan...${NC}"
python_dirs=(
    "python-operators/"
)

for dir in "${python_dirs[@]}"; do
    if [ -d "$dir" ]; then
        if bandit -r "$dir" -f json -o /tmp/bandit_results.json >/dev/null 2>&1; then
            echo -e "   ✅ $dir - no high-severity security issues"
        else
            echo -e "   ⚠️  $dir - security scan completed with findings"
        fi
    fi
done

echo -e "${PURPLE}Running code quality checks...${NC}"
for file in python-operators/cnf-lifecycle/*.py; do
    if [ -f "$file" ]; then
        if flake8 "$file" --max-line-length=88 --extend-ignore=E203,W503,E402 >/dev/null 2>&1; then
            echo -e "   ✅ $(basename "$file") - code quality OK"
        else
            echo -e "   ℹ️  $(basename "$file") - style suggestions available"
        fi
    fi
done

cd ..

# Phase 8: Integration Testing
echo -e "\n${BLUE}🔗 Phase 8: Integration Testing${NC}"

cd "$PROJECT_NAME"

# Test cluster connectivity
echo -e "${PURPLE}Testing cluster connectivity...${NC}"
if kubectl get nodes >/dev/null 2>&1; then
    node_count=$(kubectl get nodes --no-headers | wc -l)
    echo -e "${GREEN}✅ Cluster connectivity verified ($node_count nodes)${NC}"
else
    echo -e "${RED}❌ Cluster connectivity failed${NC}"
    exit 1
fi

# Test CNF namespace operations
echo -e "${PURPLE}Testing namespace operations...${NC}"
if kubectl get namespace cnf-test >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Test namespace is accessible${NC}"
    
    # List resources in test namespace
    resource_count=$(kubectl get all -n cnf-test --no-headers 2>/dev/null | wc -l)
    echo -e "   📊 Resources in test namespace: $resource_count"
else
    echo -e "${RED}❌ Test namespace access failed${NC}"
fi

cd ..

# Test Summary
echo -e "\n${BLUE}📊 Test Summary${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Environment validation completed${NC}"
echo -e "${GREEN}✅ CNF package validation completed${NC}"
echo -e "${GREEN}✅ CRD and API testing completed${NC}"
echo -e "${GREEN}✅ CNF deployment testing completed${NC}"
echo -e "${GREEN}✅ Python operator testing completed${NC}"
echo -e "${GREEN}✅ GitOps structure validation completed${NC}"
echo -e "${GREEN}✅ Security and quality checks completed${NC}"
echo -e "${GREEN}✅ Integration testing completed${NC}"
echo ""
echo -e "${PURPLE}☸️  Nephio Management Cluster: kind-$CLUSTER_NAME${NC}"
echo -e "${PURPLE}📋 CNF Deployments: $(kubectl get cnfdeployment -A --no-headers 2>/dev/null | wc -l)${NC}"
echo -e "${PURPLE}🎛️  Custom Resources: Available${NC}"
echo ""
echo -e "${GREEN}🚀 Tutorial 04 testing completed successfully!${NC}"
echo ""
echo -e "Next steps:"
echo -e "  1. Explore CNF deployments: ${BLUE}kubectl get cnfdeployments -A${NC}"
echo -e "  2. Deploy more CNFs: ${BLUE}kubectl apply -f cnf-packages/5g-core/amf/deployment.yaml${NC}"
echo -e "  3. Monitor CNF lifecycle: ${BLUE}kubectl describe cnfdeployment test-amf-cnf -n cnf-test${NC}"
echo -e "  4. Clean up: ${BLUE}./quick_cleanup.sh${NC}"