#!/bin/bash
# Tutorial 03 - Interactive Cleanup Script
# Interactive cleanup with options for SDN controller environment

set -e

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
PURPLE='\033[0;35m'
NC='\033[0m'

PROJECT_NAME="${PROJECT_NAME:-sdn_controller_workspace}"

echo -e "${BLUE}🧹 Tutorial 03: Interactive Cleanup${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
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

echo -e "This script will help you clean up Tutorial 03 resources."
echo -e "You can choose what to clean up and what to keep."
echo ""

# Check what exists
CONTROLLER_RUNNING=false
MININET_RUNNING=false
PROJECT_EXISTS=false
ARTIFACTS_EXIST=false

if [ -f "/tmp/odl_controller.pid" ] && ps -p $(cat /tmp/odl_controller.pid) > /dev/null 2>&1; then
    CONTROLLER_RUNNING=true
fi

if pgrep -f "mininet" > /dev/null 2>&1; then
    MININET_RUNNING=true
fi

if [ -d "$PROJECT_NAME" ]; then
    PROJECT_EXISTS=true
fi

if [ -f "/tmp/odl_startup.log" ] || [ -f "/tmp/yang_validation.out" ] || [ -f "/tmp/restconf_test.log" ]; then
    ARTIFACTS_EXIST=true
fi

# Show current status
echo -e "${PURPLE}Current Status:${NC}"
echo -e "  🎛️  OpenDaylight Controller: $([ "$CONTROLLER_RUNNING" = true ] && echo -e "${GREEN}Running${NC}" || echo -e "${RED}Stopped${NC}")"
echo -e "  🔗 Mininet Networks: $([ "$MININET_RUNNING" = true ] && echo -e "${GREEN}Active${NC}" || echo -e "${RED}Inactive${NC}")"
echo -e "  📁 Project Directory: $([ "$PROJECT_EXISTS" = true ] && echo -e "${GREEN}Exists${NC}" || echo -e "${RED}Not found${NC}")"
echo -e "  🗂️  Runtime Artifacts: $([ "$ARTIFACTS_EXIST" = true ] && echo -e "${YELLOW}Present${NC}" || echo -e "${GREEN}Clean${NC}")"
echo ""

# Clean up running processes
if [ "$CONTROLLER_RUNNING" = true ]; then
    if ask_yes_no "Stop OpenDaylight controller?" "y"; then
        echo -e "${YELLOW}🛑 Stopping OpenDaylight controller...${NC}"
        PID=$(cat /tmp/odl_controller.pid)
        kill $PID 2>/dev/null || true
        
        echo -n "Waiting for graceful shutdown"
        for i in {1..10}; do
            if ! ps -p $PID > /dev/null 2>&1; then
                echo -e " ${GREEN}✅${NC}"
                break
            fi
            echo -n "."
            sleep 1
        done
        
        # Force kill if needed
        if ps -p $PID > /dev/null 2>&1; then
            echo -e "\n${YELLOW}Force stopping controller...${NC}"
            kill -9 $PID 2>/dev/null || true
        fi
        
        rm -f /tmp/odl_controller.pid
    fi
fi

# Clean up any remaining controller processes
if pgrep -f "karaf" > /dev/null 2>&1; then
    if ask_yes_no "Kill any remaining Karaf/controller processes?" "y"; then
        pkill -f "karaf" 2>/dev/null || true
        pkill -f "opendaylight" 2>/dev/null || true
        echo -e "${GREEN}✅ Controller processes cleaned${NC}"
    fi
fi

# Clean up Mininet
if [ "$MININET_RUNNING" = true ] || sudo ovs-vsctl show 2>/dev/null | grep -q "Bridge"; then
    if ask_yes_no "Clean up Mininet networks and Open vSwitch?" "y"; then
        echo -e "${YELLOW}🔗 Cleaning up Mininet...${NC}"
        sudo mn -c 2>/dev/null || true
        
        # Clean up specific bridges if they exist
        for bridge in s1 s2 s3 s4; do
            sudo ovs-vsctl --if-exists del-br $bridge 2>/dev/null || true
        done
        
        echo -e "${GREEN}✅ Network cleanup completed${NC}"
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
    
    if [ -d "$PROJECT_NAME/opendaylight" ]; then
        echo -e "  🎛️  Contains OpenDaylight installation (~500MB)"
    fi
    
    if [ -d "$PROJECT_NAME/yang-models" ]; then
        echo -e "  📋 Contains custom YANG models"
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
        
        if [ -d "$PROJECT_NAME/opendaylight" ] && ask_yes_no "Remove OpenDaylight installation?" "n"; then
            rm -rf "$PROJECT_NAME/opendaylight"
            echo -e "${GREEN}✅ OpenDaylight installation removed${NC}"
        fi
    fi
fi

# Clean up runtime artifacts
if [ "$ARTIFACTS_EXIST" = true ]; then
    if ask_yes_no "Remove runtime artifacts and log files?" "y"; then
        echo -e "${YELLOW}🗑️  Removing artifacts...${NC}"
        rm -f /tmp/odl_startup.log /tmp/yang_validation.out /tmp/restconf_test.log 2>/dev/null || true
        rm -f /tmp/mininet_test.log /tmp/pytest_results.log /tmp/bandit_results.json 2>/dev/null || true
        rm -f /tmp/simple_topo_test.py 2>/dev/null || true
        echo -e "${GREEN}✅ Runtime artifacts cleaned${NC}"
    fi
fi

# System-level cleanup
echo ""
if ask_yes_no "Perform system-level network cleanup?" "n"; then
    echo -e "${YELLOW}🔧 System network cleanup...${NC}"
    
    # Clean up network namespaces created by Mininet
    for ns in $(ip netns list 2>/dev/null | awk '{print $1}'); do
        if [[ $ns =~ ^(h[0-9]+|web|db|s[0-9]+)$ ]]; then
            sudo ip netns delete $ns 2>/dev/null || true
        fi
    done
    
    # Reset any custom iptables rules (be careful!)
    if ask_yes_no "Reset iptables rules? (This might affect other services)" "n"; then
        sudo iptables -F 2>/dev/null || true
        sudo iptables -t nat -F 2>/dev/null || true
    fi
    
    echo -e "${GREEN}✅ System cleanup completed${NC}"
fi

# Final summary
echo ""
echo -e "${BLUE}🏁 Cleanup Summary${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Check final status
FINAL_CONTROLLER=$([ -f "/tmp/odl_controller.pid" ] && ps -p $(cat /tmp/odl_controller.pid) > /dev/null 2>&1 && echo "Running" || echo "Stopped")
FINAL_PROJECT=$([ -d "$PROJECT_NAME" ] && echo "Present" || echo "Removed")
FINAL_ARTIFACTS=$([ -f "/tmp/odl_startup.log" ] && echo "Present" || echo "Clean")

echo -e "  🎛️  Controller: $FINAL_CONTROLLER"
echo -e "  📁 Project: $FINAL_PROJECT"
echo -e "  🗂️  Artifacts: $FINAL_ARTIFACTS"
echo ""

if [ "$FINAL_PROJECT" = "Removed" ]; then
    echo -e "${GREEN}✅ Ready for fresh tutorial run with ./setup.sh${NC}"
else
    echo -e "${BLUE}ℹ️  Project preserved. Use ./test.sh to run tests${NC}"
fi

echo -e "\n${GREEN}🧹 Interactive cleanup completed!${NC}"