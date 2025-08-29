#!/bin/bash
# Tutorial 05 - Quick Cleanup Script
# Fast, non-interactive cleanup of ONAP production environment

set -e

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

PROJECT_NAME="${PROJECT_NAME:-onap_workspace}"
ONAP_NAMESPACE="${ONAP_NAMESPACE:-onap}"
MONITORING_NAMESPACE="${MONITORING_NAMESPACE:-monitoring}"

echo -e "${BLUE}🧹 Tutorial 05: Quick Cleanup${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Remove test deployments and namespaces
echo -e "${YELLOW}🗑️  Removing test deployments...${NC}"
kubectl delete deployment test-cnf -n test-vnf-ns 2>/dev/null || true
kubectl delete namespace test-vnf-ns 2>/dev/null || true
kubectl delete configmap test-service-instance 2>/dev/null || true

# Remove ONAP platform
if kubectl get namespace $ONAP_NAMESPACE >/dev/null 2>&1; then
    echo -e "${YELLOW}🎛️  Removing ONAP platform...${NC}"
    kubectl delete namespace $ONAP_NAMESPACE --timeout=300s &
    ONAP_PID=$!
fi

# Remove monitoring stack
if kubectl get namespace $MONITORING_NAMESPACE >/dev/null 2>&1; then
    echo -e "${YELLOW}📊 Removing monitoring stack...${NC}"
    kubectl delete namespace $MONITORING_NAMESPACE --timeout=300s &
    MONITORING_PID=$!
fi

# Remove Helm releases
echo -e "${YELLOW}📦 Removing Helm releases...${NC}"
helm list -A -q 2>/dev/null | grep -E "(cassandra|mariadb|prometheus|grafana)" | while read release; do
    release_ns=$(helm list -A | grep "^$release" | awk '{print $2}')
    helm uninstall "$release" -n "$release_ns" 2>/dev/null || true
done

# Wait for namespace deletions to complete
if [ ! -z "$ONAP_PID" ]; then
    wait $ONAP_PID 2>/dev/null || true
fi

if [ ! -z "$MONITORING_PID" ]; then
    wait $MONITORING_PID 2>/dev/null || true
fi

# Remove project directory and artifacts
echo -e "${YELLOW}📁 Removing project directory...${NC}"
rm -rf "$PROJECT_NAME" 2>/dev/null || true

# Remove test artifacts
echo -e "${YELLOW}🗑️  Removing test artifacts...${NC}"
rm -f /tmp/test-service-instance.yaml 2>/dev/null || true
rm -f /tmp/test-cnf-deployment.yaml 2>/dev/null || true
rm -f /tmp/test-policy.yaml 2>/dev/null || true
rm -f /tmp/e2e_test.py 2>/dev/null || true
rm -f /tmp/bandit_results*.json 2>/dev/null || true

# Clean up Kubernetes resources
echo -e "${YELLOW}☸️ Cleaning Kubernetes resources...${NC}"
kubectl get pvc --all-namespaces | grep -E "(onap|monitoring)" | awk '{print $2 " -n " $1}' | xargs -r kubectl delete pvc 2>/dev/null || true
kubectl delete configmap -l tutorial=onap --all-namespaces 2>/dev/null || true

# Clean up Docker resources (ONAP-specific)
echo -e "${YELLOW}🐳 Cleaning ONAP Docker images...${NC}"
docker images | grep -E "(onap|openecomp)" | awk '{print $3}' | tail -n +2 | xargs -r docker rmi -f 2>/dev/null || true

# System cleanup
echo -e "${YELLOW}🔧 System cleanup...${NC}"
rm -rf /tmp/onap-* 2>/dev/null || true
rm -rf /tmp/helm-* 2>/dev/null || true

echo -e "${GREEN}✅ Quick cleanup completed!${NC}"
echo ""
echo -e "All ONAP production environment resources cleaned up:"
echo -e "  🎛️  ONAP platform removed"
echo -e "  📊 Monitoring stack removed"
echo -e "  📦 Helm releases cleaned"
echo -e "  📁 Project directory deleted"
echo -e "  🗂️  Test artifacts removed"
echo -e "  ☸️ Kubernetes resources cleaned"
echo -e "  🐳 Docker images cleaned"
echo ""
echo -e "Ready for fresh tutorial run with ${BLUE}./setup.sh${NC}"

# Final verification
echo ""
echo -e "${BLUE}🔍 Final Status Check:${NC}"
echo -e "  • ONAP namespace: $(kubectl get namespace $ONAP_NAMESPACE >/dev/null 2>&1 && echo -e "${YELLOW}Still removing...${NC}" || echo -e "${GREEN}Removed${NC}")"
echo -e "  • Monitoring namespace: $(kubectl get namespace $MONITORING_NAMESPACE >/dev/null 2>&1 && echo -e "${YELLOW}Still removing...${NC}" || echo -e "${GREEN}Removed${NC}")"
echo -e "  • Helm releases: $(helm list -A -q 2>/dev/null | grep -c -E "(cassandra|mariadb|prometheus|grafana|onap)" || echo "0") remaining"
echo -e "  • Project directory: $([ -d "$PROJECT_NAME" ] && echo -e "${RED}Still present${NC}" || echo -e "${GREEN}Removed${NC}")"

if kubectl get namespace $ONAP_NAMESPACE >/dev/null 2>&1 || kubectl get namespace $MONITORING_NAMESPACE >/dev/null 2>&1; then
    echo ""
    echo -e "${YELLOW}⏳ Note: Namespace deletion may take a few more minutes to complete.${NC}"
    echo -e "Monitor with: ${BLUE}watch kubectl get namespaces${NC}"
fi