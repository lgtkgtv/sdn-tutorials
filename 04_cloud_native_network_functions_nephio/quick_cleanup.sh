#!/bin/bash
# Tutorial 04 - Quick Cleanup Script
# Fast, non-interactive cleanup of Nephio CNF environment

set -e

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

PROJECT_NAME="${PROJECT_NAME:-nephio_cnf_workspace}"

echo -e "${BLUE}🧹 Tutorial 04: Quick Cleanup${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Stop and remove Nephio management cluster
if kind get clusters 2>/dev/null | grep -q "nephio-management"; then
    echo -e "${YELLOW}🎪 Removing Nephio management cluster...${NC}"
    kind delete cluster --name nephio-management
fi

# Stop and remove any workload clusters
for cluster in $(kind get clusters 2>/dev/null | grep -E "edge-cluster|regional-cluster"); do
    echo -e "${YELLOW}🎪 Removing workload cluster: $cluster${NC}"
    kind delete cluster --name "$cluster"
done

# Remove runtime artifacts
echo -e "${YELLOW}🗑️  Removing runtime artifacts...${NC}"
rm -rf "$PROJECT_NAME" 2>/dev/null || true
rm -f /tmp/test-cnf-deployment.yaml 2>/dev/null || true
rm -f /tmp/bandit_results.json 2>/dev/null || true

# Clean up any remaining CNF-related containers
echo -e "${YELLOW}🐳 Cleaning up CNF containers...${NC}"
docker ps -a --filter "label=io.x-k8s.kind.role" --format "{{.ID}}" | xargs -r docker rm -f 2>/dev/null || true

# Clean up Docker networks created by kind
echo -e "${YELLOW}🔗 Cleaning up Docker networks...${NC}"
docker network ls --filter "name=kind" --format "{{.ID}}" | xargs -r docker network rm 2>/dev/null || true

# Clean up kubectl contexts
echo -e "${YELLOW}⚙️  Cleaning up kubectl contexts...${NC}"
kubectl config delete-context kind-nephio-management 2>/dev/null || true
kubectl config delete-context kind-edge-cluster-01 2>/dev/null || true

echo -e "${GREEN}✅ Quick cleanup completed!${NC}"
echo ""
echo -e "All Nephio CNF resources cleaned up:"
echo -e "  ☸️  Kubernetes clusters removed"
echo -e "  🐳 Docker containers cleaned"
echo -e "  🔗 Docker networks cleaned"  
echo -e "  📁 Runtime artifacts deleted"
echo -e "  ⚙️  kubectl contexts cleaned"
echo ""
echo -e "Ready for fresh tutorial run with ${BLUE}./setup.sh${NC}"