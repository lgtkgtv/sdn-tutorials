#!/bin/bash
# Tutorial 04 - Interactive Cleanup Script
# Interactive cleanup with options for Nephio CNF environment

set -e

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
PURPLE='\033[0;35m'
NC='\033[0m'

PROJECT_NAME="${PROJECT_NAME:-nephio_cnf_workspace}"

echo -e "${BLUE}🧹 Tutorial 04: Interactive Cleanup${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Function to ask yes/no questions
ask_yes_no() {
    local question="$1"
    local default="${2:-n}"
    local response
    
    if [ "$default" = "y" ]; then
        echo -n -e "${YELLOW}$question [Y/n]: ${NC}"
    else
        echo -n -e "${YELLOW}$question [y/N]: ${NC}"
    fi
    
    read -n 1 response
    echo
    
    if [ -z "$response" ]; then
        response="$default"
    fi
    
    case "$response" in
        [yY]) return 0 ;;
        [nN]) return 1 ;;
        *) 
            echo -e "${RED}Please answer y or n${NC}"
            ask_yes_no "$question" "$default"
            ;;
    esac
}

echo -e "This script will help you clean up Tutorial 04 Nephio CNF resources."
echo -e "You can choose what to clean up and what to keep."
echo ""

# Check what exists
MGMT_CLUSTER_EXISTS=false
WORKLOAD_CLUSTERS=()
PROJECT_EXISTS=false
ARTIFACTS_EXIST=false

if kind get clusters 2>/dev/null | grep -q "nephio-management"; then
    MGMT_CLUSTER_EXISTS=true
fi

for cluster in $(kind get clusters 2>/dev/null | grep -E "edge-cluster|regional-cluster"); do
    WORKLOAD_CLUSTERS+=("$cluster")
done

if [ -d "$PROJECT_NAME" ]; then
    PROJECT_EXISTS=true
fi

if [ -f "/tmp/test-cnf-deployment.yaml" ] || [ -f "/tmp/bandit_results.json" ]; then
    ARTIFACTS_EXIST=true
fi

# Show current status
echo -e "${PURPLE}Current Status:${NC}"
echo -e "  ☸️  Management Cluster: $([ "$MGMT_CLUSTER_EXISTS" = true ] && echo -e "${GREEN}Running${NC}" || echo -e "${RED}Not found${NC}")"
echo -e "  🏭 Workload Clusters: $([ ${#WORKLOAD_CLUSTERS[@]} -gt 0 ] && echo -e "${GREEN}${#WORKLOAD_CLUSTERS[@]} active${NC}" || echo -e "${RED}None${NC}")"
echo -e "  📁 Project Directory: $([ "$PROJECT_EXISTS" = true ] && echo -e "${GREEN}Exists${NC}" || echo -e "${RED}Not found${NC}")"
echo -e "  🗂️  Runtime Artifacts: $([ "$ARTIFACTS_EXIST" = true ] && echo -e "${YELLOW}Present${NC}" || echo -e "${GREEN}Clean${NC}")"
echo ""

# Clean up Kubernetes clusters
if [ "$MGMT_CLUSTER_EXISTS" = true ]; then
    echo -e "${PURPLE}Nephio Management Cluster:${NC}"
    kubectl config use-context kind-nephio-management 2>/dev/null || true
    if kubectl get nodes >/dev/null 2>&1; then
        node_count=$(kubectl get nodes --no-headers | wc -l)
        cnf_count=$(kubectl get cnfdeployments -A --no-headers 2>/dev/null | wc -l || echo "0")
        echo -e "  📊 Nodes: $node_count"
        echo -e "  🎛️  CNF Deployments: $cnf_count"
    fi
    
    if ask_yes_no "Remove Nephio management cluster?" "y"; then
        echo -e "${YELLOW}🎪 Removing management cluster...${NC}"
        kind delete cluster --name nephio-management
        echo -e "${GREEN}✅ Management cluster removed${NC}"
    fi
fi

if [ ${#WORKLOAD_CLUSTERS[@]} -gt 0 ]; then
    echo ""
    echo -e "${PURPLE}Workload Clusters Found:${NC}"
    for cluster in "${WORKLOAD_CLUSTERS[@]}"; do
        echo -e "  🏭 $cluster"
    done
    
    if ask_yes_no "Remove all workload clusters?" "y"; then
        for cluster in "${WORKLOAD_CLUSTERS[@]}"; do
            echo -e "${YELLOW}🎪 Removing cluster: $cluster${NC}"
            kind delete cluster --name "$cluster"
        done
        echo -e "${GREEN}✅ Workload clusters removed${NC}"
    fi
fi

# Clean up kubectl contexts
echo ""
if ask_yes_no "Clean up kubectl contexts?" "y"; then
    echo -e "${YELLOW}⚙️  Cleaning kubectl contexts...${NC}"
    kubectl config delete-context kind-nephio-management 2>/dev/null || true
    kubectl config delete-context kind-edge-cluster-01 2>/dev/null || true
    for cluster in "${WORKLOAD_CLUSTERS[@]}"; do
        kubectl config delete-context "kind-$cluster" 2>/dev/null || true
    done
    echo -e "${GREEN}✅ kubectl contexts cleaned${NC}"
fi

# Remove project directory
if [ "$PROJECT_EXISTS" = true ]; then
    echo ""
    echo -e "${PURPLE}Project Directory Options:${NC}"
    echo -e "  📁 Current project: $PROJECT_NAME"
    
    if [ -d "$PROJECT_NAME/venv" ]; then
        echo -e "  🐍 Contains Python virtual environment"
    fi
    
    if [ -d "$PROJECT_NAME/cnf-packages" ]; then
        echo -e "  📦 Contains CNF packages and configurations"
    fi
    
    if [ -d "$PROJECT_NAME/nephio" ]; then
        echo -e "  ☸️  Contains Nephio cluster configurations"
    fi
    
    if [ -d "$PROJECT_NAME/python-operators" ]; then
        echo -e "  🐍 Contains Python CNF operators"
    fi
    
    echo ""
    if ask_yes_no "Remove entire project directory?" "n"; then
        rm -rf "$PROJECT_NAME"
        echo -e "${GREEN}✅ Project directory removed${NC}"
    else
        # Offer selective cleanup
        echo ""
        echo -e "${PURPLE}Selective Cleanup Options:${NC}"
        
        if [ -d "$PROJECT_NAME/venv" ] && ask_yes_no "Remove Python virtual environment only?" "n"; then
            rm -rf "$PROJECT_NAME/venv"
            echo -e "${GREEN}✅ Virtual environment removed${NC}"
        fi
        
        if [ -d "$PROJECT_NAME/bin" ] && ask_yes_no "Remove locally installed tools (kubectl, kind, kpt)?" "n"; then
            rm -rf "$PROJECT_NAME/bin"
            echo -e "${GREEN}✅ Local tools removed${NC}"
        fi
    fi
fi

# Clean up runtime artifacts
if [ "$ARTIFACTS_EXIST" = true ]; then
    if ask_yes_no "Remove runtime artifacts and test files?" "y"; then
        echo -e "${YELLOW}🗑️  Removing artifacts...${NC}"
        rm -f /tmp/test-cnf-deployment.yaml 2>/dev/null || true
        rm -f /tmp/bandit_results.json 2>/dev/null || true
        echo -e "${GREEN}✅ Runtime artifacts cleaned${NC}"
    fi
fi

# Docker cleanup
echo ""
if ask_yes_no "Clean up Docker resources (containers, networks)?" "y"; then
    echo -e "${YELLOW}🐳 Cleaning Docker resources...${NC}"
    
    # Remove kind-related containers
    if docker ps -a --filter "label=io.x-k8s.kind.role" --format "{{.ID}}" | grep -q .; then
        docker ps -a --filter "label=io.x-k8s.kind.role" --format "{{.ID}}" | xargs docker rm -f 2>/dev/null || true
        echo -e "  ✅ Kind containers removed"
    fi
    
    # Remove kind networks
    if docker network ls --filter "name=kind" --format "{{.ID}}" | grep -q .; then
        docker network ls --filter "name=kind" --format "{{.ID}}" | xargs docker network rm 2>/dev/null || true
        echo -e "  ✅ Kind networks removed"
    fi
    
    # Prune unused Docker resources
    if ask_yes_no "Prune unused Docker images and volumes?" "n"; then
        docker system prune -f
        echo -e "  ✅ Docker system pruned"
    fi
    
    echo -e "${GREEN}✅ Docker cleanup completed${NC}"
fi

# System-level cleanup
echo ""
if ask_yes_no "Perform additional system cleanup?" "n"; then
    echo -e "${YELLOW}🔧 System cleanup...${NC}"
    
    # Clean up any leftover CNI networks
    if command -v ip >/dev/null 2>&1; then
        for bridge in $(ip link show type bridge | grep -o 'kind-[^:]*' 2>/dev/null); do
            sudo ip link delete "$bridge" 2>/dev/null || true
        done
        echo -e "  ✅ Network interfaces cleaned"
    fi
    
    # Clean up temporary directories
    rm -rf /tmp/kind-* 2>/dev/null || true
    rm -rf /tmp/nephio-* 2>/dev/null || true
    echo -e "  ✅ Temporary directories cleaned"
    
    echo -e "${GREEN}✅ System cleanup completed${NC}"
fi

# Final summary
echo ""
echo -e "${BLUE}🏁 Cleanup Summary${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Check final status
FINAL_CLUSTERS=$(kind get clusters 2>/dev/null | grep -c -E "(nephio|edge|regional)" || echo "0")
FINAL_PROJECT=$([ -d "$PROJECT_NAME" ] && echo "Present" || echo "Removed")
FINAL_ARTIFACTS=$([ -f "/tmp/test-cnf-deployment.yaml" ] && echo "Present" || echo "Clean")

echo -e "  ☸️  Active Clusters: $FINAL_CLUSTERS"
echo -e "  📁 Project: $FINAL_PROJECT"
echo -e "  🗂️  Artifacts: $FINAL_ARTIFACTS"
echo ""

if [ "$FINAL_PROJECT" = "Removed" ] && [ "$FINAL_CLUSTERS" = "0" ]; then
    echo -e "${GREEN}✅ Complete cleanup - ready for fresh tutorial run with ./setup.sh${NC}"
elif [ "$FINAL_CLUSTERS" = "0" ]; then
    echo -e "${BLUE}ℹ️  Project preserved, clusters removed - use ./setup.sh to reinitialize clusters${NC}"
else
    echo -e "${BLUE}ℹ️  Some resources preserved - use ./test.sh to continue working${NC}"
fi

echo -e "\n${GREEN}🧹 Interactive cleanup completed!${NC}"