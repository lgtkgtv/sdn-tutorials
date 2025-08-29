#!/bin/bash
# Tutorial 03 - Quick Cleanup Script
# Fast, non-interactive cleanup of SDN controller environment

set -e

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

PROJECT_NAME="${PROJECT_NAME:-sdn_controller_workspace}"

echo -e "${BLUE}🧹 Tutorial 03: Quick Cleanup${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Stop OpenDaylight controller
if [ -f "/tmp/odl_controller.pid" ]; then
    echo -e "${YELLOW}🛑 Stopping OpenDaylight controller...${NC}"
    PID=$(cat /tmp/odl_controller.pid)
    if ps -p $PID > /dev/null 2>&1; then
        kill $PID 2>/dev/null || true
        sleep 5
        kill -9 $PID 2>/dev/null || true
    fi
    rm -f /tmp/odl_controller.pid
fi

# Kill any remaining controller processes
pkill -f "karaf" 2>/dev/null || true
pkill -f "opendaylight" 2>/dev/null || true

# Stop any running Mininet networks
echo -e "${YELLOW}🔗 Cleaning up Mininet...${NC}"
sudo mn -c 2>/dev/null || true

# Clean up Open vSwitch bridges
sudo ovs-vsctl --if-exists del-br s1 2>/dev/null || true
sudo ovs-vsctl --if-exists del-br s2 2>/dev/null || true  
sudo ovs-vsctl --if-exists del-br s3 2>/dev/null || true
sudo ovs-vsctl --if-exists del-br s4 2>/dev/null || true

# Remove runtime artifacts
echo -e "${YELLOW}🗑️  Removing runtime artifacts...${NC}"
rm -rf "$PROJECT_NAME" 2>/dev/null || true
rm -f /tmp/odl_startup.log /tmp/yang_validation.out /tmp/restconf_test.log 2>/dev/null || true
rm -f /tmp/mininet_test.log /tmp/pytest_results.log /tmp/bandit_results.json 2>/dev/null || true
rm -f /tmp/simple_topo_test.py 2>/dev/null || true

# Clean up any remaining network namespaces
for ns in $(ip netns list 2>/dev/null | awk '{print $1}'); do
    if [[ $ns =~ ^(h[0-9]+|web|db)$ ]]; then
        sudo ip netns delete $ns 2>/dev/null || true
    fi
done

echo -e "${GREEN}✅ Quick cleanup completed!${NC}"
echo ""
echo -e "All SDN controller resources cleaned up:"
echo -e "  🎛️  OpenDaylight controller stopped"
echo -e "  🔗 Mininet networks cleaned"
echo -e "  🔀 Open vSwitch bridges removed"
echo -e "  📁 Runtime artifacts deleted"
echo ""
echo -e "Ready for fresh tutorial run with ${BLUE}./setup.sh${NC}"