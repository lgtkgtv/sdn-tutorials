#!/bin/bash
# Tutorial 05 - Interactive Cleanup Script
# Interactive cleanup with options for ONAP production environment

set -e

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
PURPLE='\033[0;35m'
NC='\033[0m'

PROJECT_NAME="${PROJECT_NAME:-onap_workspace}"
ONAP_NAMESPACE="${ONAP_NAMESPACE:-onap}"
MONITORING_NAMESPACE="${MONITORING_NAMESPACE:-monitoring}"

echo -e "${BLUE}🧹 Tutorial 05: Interactive Cleanup${NC}"
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

echo -e "This script will help you clean up Tutorial 05 ONAP production environment."
echo -e "You can choose what to clean up and what to keep."
echo ""

# Check what exists
ONAP_NS_EXISTS=false
MONITORING_NS_EXISTS=false
PROJECT_EXISTS=false
TEST_ARTIFACTS_EXIST=false
HELM_RELEASES=()

if kubectl get namespace $ONAP_NAMESPACE >/dev/null 2>&1; then
    ONAP_NS_EXISTS=true
fi

if kubectl get namespace $MONITORING_NAMESPACE >/dev/null 2>&1; then
    MONITORING_NS_EXISTS=true
fi

if [ -d "$PROJECT_NAME" ]; then
    PROJECT_EXISTS=true
fi

# Get helm releases
mapfile -t HELM_RELEASES < <(helm list -A -q 2>/dev/null | grep -E "(cassandra|mariadb|prometheus|grafana|onap)")

if [ -f "/tmp/test-service-instance.yaml" ] || [ -f "/tmp/test-cnf-deployment.yaml" ] || [ -d "/tmp/bandit_results" ]; then
    TEST_ARTIFACTS_EXIST=true
fi

# Show current status
echo -e "${PURPLE}Current Status:${NC}"

if [ "$ONAP_NS_EXISTS" = true ]; then
    onap_pod_count=$(kubectl get pods -n $ONAP_NAMESPACE --no-headers 2>/dev/null | wc -l)
    onap_running_pods=$(kubectl get pods -n $ONAP_NAMESPACE --field-selector=status.phase=Running --no-headers 2>/dev/null | wc -l)
    echo -e "  🎛️  ONAP Namespace: ${GREEN}$onap_running_pods/$onap_pod_count pods running${NC}"
else
    echo -e "  🎛️  ONAP Namespace: ${RED}Not found${NC}"
fi

if [ "$MONITORING_NS_EXISTS" = true ]; then
    monitoring_pod_count=$(kubectl get pods -n $MONITORING_NAMESPACE --no-headers 2>/dev/null | wc -l)
    echo -e "  📊 Monitoring Stack: ${GREEN}$monitoring_pod_count components${NC}"
else
    echo -e "  📊 Monitoring Stack: ${RED}Not found${NC}"
fi

echo -e "  📦 Helm Releases: $([ ${#HELM_RELEASES[@]} -gt 0 ] && echo -e "${YELLOW}${#HELM_RELEASES[@]} found${NC}" || echo -e "${GREEN}None${NC}")"
echo -e "  📁 Project Directory: $([ "$PROJECT_EXISTS" = true ] && echo -e "${GREEN}Exists${NC}" || echo -e "${RED}Not found${NC}")"
echo -e "  🗂️  Test Artifacts: $([ "$TEST_ARTIFACTS_EXIST" = true ] && echo -e "${YELLOW}Present${NC}" || echo -e "${GREEN}Clean${NC}")"
echo ""

# Clean up ONAP platform
if [ "$ONAP_NS_EXISTS" = true ]; then
    echo -e "${PURPLE}ONAP Platform Components:${NC}"
    kubectl get pods -n $ONAP_NAMESPACE --no-headers 2>/dev/null | head -10 | sed 's/^/  /'
    if [ $(kubectl get pods -n $ONAP_NAMESPACE --no-headers 2>/dev/null | wc -l) -gt 10 ]; then
        echo -e "  ... and $(($(kubectl get pods -n $ONAP_NAMESPACE --no-headers 2>/dev/null | wc -l) - 10)) more"
    fi
    echo ""
    
    if ask_yes_no "Remove ONAP platform and all network services?" "y"; then
        echo -e "${YELLOW}🗑️  Removing ONAP service instances...${NC}"
        
        # Delete test CNF deployments
        kubectl delete deployment test-cnf -n test-vnf-ns 2>/dev/null || true
        kubectl delete namespace test-vnf-ns 2>/dev/null || true
        
        # Delete test service instances
        kubectl delete configmap test-service-instance 2>/dev/null || true
        
        echo -e "${YELLOW}🎪 Removing ONAP namespace...${NC}"
        kubectl delete namespace $ONAP_NAMESPACE --timeout=300s
        echo -e "${GREEN}✅ ONAP platform removed${NC}"
    fi
fi

# Clean up monitoring stack
if [ "$MONITORING_NS_EXISTS" = true ]; then
    echo ""
    echo -e "${PURPLE}Monitoring Stack:${NC}"
    kubectl get pods -n $MONITORING_NAMESPACE --no-headers 2>/dev/null | sed 's/^/  /'
    
    if ask_yes_no "Remove monitoring stack (Prometheus, Grafana)?" "y"; then
        echo -e "${YELLOW}📊 Removing monitoring components...${NC}"
        kubectl delete namespace $MONITORING_NAMESPACE --timeout=300s
        echo -e "${GREEN}✅ Monitoring stack removed${NC}"
    fi
fi

# Clean up Helm releases
if [ ${#HELM_RELEASES[@]} -gt 0 ]; then
    echo ""
    echo -e "${PURPLE}Helm Releases Found:${NC}"
    for release in "${HELM_RELEASES[@]}"; do
        echo -e "  📦 $release"
    done
    
    if ask_yes_no "Remove all Helm releases?" "y"; then
        for release in "${HELM_RELEASES[@]}"; do
            echo -e "${YELLOW}📦 Removing Helm release: $release${NC}"
            # Get namespace for the release
            release_ns=$(helm list -A | grep "^$release" | awk '{print $2}')
            helm uninstall "$release" -n "$release_ns" 2>/dev/null || true
        done
        echo -e "${GREEN}✅ Helm releases removed${NC}"
    fi
fi

# Remove project directory
if [ "$PROJECT_EXISTS" = true ]; then
    echo ""
    echo -e "${PURPLE}Project Directory Options:${NC}"
    echo -e "  📁 Current project: $PROJECT_NAME"
    
    if [ -d "$PROJECT_NAME/venv" ]; then
        echo -e "  🐍 Contains Python virtual environment"
    fi
    
    if [ -d "$PROJECT_NAME/onap-helm-charts" ]; then
        echo -e "  📦 Contains ONAP Helm charts and configurations"
    fi
    
    if [ -d "$PROJECT_NAME/python-automation" ]; then
        echo -e "  🔧 Contains Python automation scripts"
    fi
    
    if [ -d "$PROJECT_NAME/service-models" ]; then
        echo -e "  🎨 Contains ONAP service models"
    fi
    
    if [ -d "$PROJECT_NAME/monitoring-dashboards" ]; then
        echo -e "  📊 Contains Grafana dashboards"
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
        
        if [ -d "$PROJECT_NAME/bin" ] && ask_yes_no "Remove locally installed tools?" "n"; then
            rm -rf "$PROJECT_NAME/bin"
            echo -e "${GREEN}✅ Local tools removed${NC}"
        fi
        
        if [ -d "$PROJECT_NAME/logs" ] && ask_yes_no "Remove log files?" "y"; then
            rm -rf "$PROJECT_NAME/logs"
            mkdir -p "$PROJECT_NAME/logs"
            echo -e "${GREEN}✅ Log files cleaned${NC}"
        fi
    fi
fi

# Clean up test artifacts and temporary files
if [ "$TEST_ARTIFACTS_EXIST" = true ]; then
    if ask_yes_no "Remove test artifacts and temporary files?" "y"; then
        echo -e "${YELLOW}🗑️  Removing artifacts...${NC}"
        rm -f /tmp/test-service-instance.yaml 2>/dev/null || true
        rm -f /tmp/test-cnf-deployment.yaml 2>/dev/null || true
        rm -f /tmp/test-policy.yaml 2>/dev/null || true
        rm -f /tmp/e2e_test.py 2>/dev/null || true
        rm -f /tmp/bandit_results*.json 2>/dev/null || true
        echo -e "${GREEN}✅ Test artifacts cleaned${NC}"
    fi
fi

# Kubernetes cleanup
echo ""
if ask_yes_no "Clean up Kubernetes resources (PVCs, ConfigMaps)?" "y"; then
    echo -e "${YELLOW}☸️ Cleaning Kubernetes resources...${NC}"
    
    # Remove PVCs from deleted namespaces
    kubectl get pvc --all-namespaces | grep -E "(onap|monitoring)" | awk '{print $2 " -n " $1}' | xargs -r kubectl delete pvc 2>/dev/null || true
    
    # Clean up any leftover ConfigMaps
    kubectl delete configmap -l tutorial=onap --all-namespaces 2>/dev/null || true
    
    echo -e "${GREEN}✅ Kubernetes cleanup completed${NC}"
fi

# Docker cleanup (for local Kubernetes)
echo ""
if ask_yes_no "Clean up Docker resources (images, volumes)?" "n"; then
    echo -e "${YELLOW}🐳 Cleaning Docker resources...${NC}"
    
    # Remove ONAP-related images
    if docker images | grep -E "(onap|openecomp)" | grep -q .; then
        docker images | grep -E "(onap|openecomp)" | awk '{print $3}' | tail -n +2 | xargs -r docker rmi -f 2>/dev/null || true
        echo -e "  ✅ ONAP Docker images removed"
    fi
    
    # Remove unused volumes
    if ask_yes_no "Prune unused Docker volumes?" "n"; then
        docker volume prune -f
        echo -e "  ✅ Docker volumes pruned"
    fi
    
    echo -e "${GREEN}✅ Docker cleanup completed${NC}"
fi

# System-level cleanup
echo ""
if ask_yes_no "Perform system-level cleanup?" "n"; then
    echo -e "${YELLOW}🔧 System cleanup...${NC}"
    
    # Clean up temporary directories
    rm -rf /tmp/onap-* 2>/dev/null || true
    rm -rf /tmp/helm-* 2>/dev/null || true
    
    # Clean up Helm cache
    helm repo update >/dev/null 2>&1 || true
    
    echo -e "${GREEN}✅ System cleanup completed${NC}"
fi

# Final summary
echo ""
echo -e "${BLUE}🏁 Cleanup Summary${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Check final status
FINAL_ONAP_NS=$(kubectl get namespace $ONAP_NAMESPACE >/dev/null 2>&1 && echo "Present" || echo "Removed")
FINAL_MONITORING_NS=$(kubectl get namespace $MONITORING_NAMESPACE >/dev/null 2>&1 && echo "Present" || echo "Removed")
FINAL_PROJECT=$([ -d "$PROJECT_NAME" ] && echo "Present" || echo "Removed")
FINAL_HELM_COUNT=$(helm list -A -q 2>/dev/null | grep -c -E "(cassandra|mariadb|prometheus|grafana|onap)" || echo "0")

echo -e "  🎛️  ONAP Platform: $FINAL_ONAP_NS"
echo -e "  📊 Monitoring Stack: $FINAL_MONITORING_NS"
echo -e "  📦 Helm Releases: $FINAL_HELM_COUNT remaining"
echo -e "  📁 Project: $FINAL_PROJECT"
echo ""

if [ "$FINAL_PROJECT" = "Removed" ] && [ "$FINAL_ONAP_NS" = "Removed" ] && [ "$FINAL_MONITORING_NS" = "Removed" ]; then
    echo -e "${GREEN}✅ Complete cleanup - ready for fresh tutorial run with ./setup.sh${NC}"
elif [ "$FINAL_ONAP_NS" = "Removed" ]; then
    echo -e "${BLUE}ℹ️  Project preserved, ONAP removed - use ./setup.sh to reinitialize${NC}"
else
    echo -e "${BLUE}ℹ️  Some resources preserved - use ./test.sh to continue working${NC}"
fi

echo -e "\n${GREEN}🧹 Interactive cleanup completed!${NC}"
echo ""
echo -e "Useful commands for monitoring:"
echo -e "  • Check namespaces: ${BLUE}kubectl get namespaces${NC}"
echo -e "  • List Helm releases: ${BLUE}helm list -A${NC}"
echo -e "  • Check persistent volumes: ${BLUE}kubectl get pv${NC}"
echo -e "  • Monitor cleanup: ${BLUE}watch kubectl get all --all-namespaces${NC}"