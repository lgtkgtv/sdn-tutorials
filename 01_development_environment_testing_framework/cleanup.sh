#!/bin/bash
# SDN Tutorial 1 - Comprehensive Cleanup Script
# Safely removes all tutorial resources with confirmation prompts

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Environment variables
PROJECT_ROOT="${PROJECT_ROOT:-$(pwd)}"
PROJECT_NAME="${PROJECT_NAME:-sdn-everything}"
VENV_NAME="${VENV_NAME:-venv}"
CLUSTER_NAME="${CLUSTER_NAME:-tutorial-cluster}"

echo -e "${BLUE}🧹 SDN Tutorial Cleanup Script${NC}"
echo -e "${BLUE}================================${NC}"
echo ""
echo "This script will help you clean up tutorial resources."
echo "You can choose what to remove:"
echo ""
echo "📁 Project location: $PROJECT_ROOT/$PROJECT_NAME"
echo "🐍 Virtual environment: $VENV_NAME"
echo "☸️  Kubernetes cluster: $CLUSTER_NAME"
echo ""

# Function to ask for confirmation
confirm() {
    local prompt="$1"
    local default="${2:-n}"
    
    if [ "$default" = "y" ]; then
        prompt="$prompt [Y/n]: "
    else
        prompt="$prompt [y/N]: "
    fi
    
    while true; do
        read -p "$prompt" answer
        case "$answer" in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            "" ) 
                if [ "$default" = "y" ]; then
                    return 0
                else
                    return 1
                fi
                ;;
            * ) echo "Please answer yes or no.";;
        esac
    done
}

# Function to check if project directory exists
check_project_dir() {
    if [ -d "$PROJECT_ROOT/$PROJECT_NAME" ]; then
        return 0
    else
        echo -e "${YELLOW}⚠️  Project directory not found at $PROJECT_ROOT/$PROJECT_NAME${NC}"
        return 1
    fi
}

# Navigate to project directory if it exists
if check_project_dir; then
    cd "$PROJECT_ROOT/$PROJECT_NAME"
    echo -e "${GREEN}📁 Found project directory${NC}"
else
    echo -e "${RED}❌ Project directory not found. Some cleanup operations may be limited.${NC}"
fi

echo ""
echo -e "${BLUE}=== CLEANUP OPTIONS ===${NC}"

# 1. Clean up Kubernetes cluster
echo ""
echo -e "${YELLOW}1. Kubernetes Cluster Cleanup${NC}"
if kind get clusters 2>/dev/null | grep -q "$CLUSTER_NAME"; then
    echo -e "   ☸️  Found kind cluster: ${GREEN}$CLUSTER_NAME${NC}"
    
    # Show what's in the cluster
    echo "   📊 Current cluster resources:"
    kubectl config use-context "kind-$CLUSTER_NAME" 2>/dev/null || true
    kubectl get namespaces 2>/dev/null | grep -E "(production|staging)" | head -5 || echo "   📋 No tutorial namespaces found"
    kubectl get networkpolicies --all-namespaces 2>/dev/null | wc -l | xargs echo "   🛡️ Network policies:"
    
    if confirm "   Delete Kubernetes cluster '$CLUSTER_NAME'?"; then
        echo -e "   🎪 ${YELLOW}Deleting kind cluster...${NC}"
        kind delete cluster --name "$CLUSTER_NAME"
        echo -e "   ✅ ${GREEN}Cluster deleted successfully${NC}"
    else
        echo -e "   ⏭️  ${BLUE}Keeping Kubernetes cluster${NC}"
    fi
else
    echo -e "   ℹ️  No kind cluster named '$CLUSTER_NAME' found"
fi

# 2. Clean up Docker containers and images
echo ""
echo -e "${YELLOW}2. Docker Cleanup${NC}"
if command -v docker >/dev/null 2>&1; then
    # Check for tutorial-related containers
    TUTORIAL_CONTAINERS=$(docker ps -a --filter "name=sdn" --filter "name=tutorial" --filter "name=odl" --format "{{.Names}}" 2>/dev/null || true)
    
    if [ -n "$TUTORIAL_CONTAINERS" ]; then
        echo -e "   🐳 Found tutorial-related containers:"
        echo "$TUTORIAL_CONTAINERS" | sed 's/^/     - /'
        
        if confirm "   Stop and remove these containers?"; then
            echo "$TUTORIAL_CONTAINERS" | xargs -r docker stop 2>/dev/null || true
            echo "$TUTORIAL_CONTAINERS" | xargs -r docker rm 2>/dev/null || true
            echo -e "   ✅ ${GREEN}Containers removed${NC}"
        fi
    else
        echo -e "   ℹ️  No tutorial-related containers found"
    fi
    
    # Check for unused images
    UNUSED_IMAGES=$(docker images --filter "dangling=true" -q 2>/dev/null | wc -l)
    if [ "$UNUSED_IMAGES" -gt "0" ]; then
        echo -e "   📦 Found $UNUSED_IMAGES dangling Docker images"
        if confirm "   Remove dangling Docker images?"; then
            docker image prune -f
            echo -e "   ✅ ${GREEN}Dangling images removed${NC}"
        fi
    fi
    
    # Check for tutorial-specific images
    TUTORIAL_IMAGES=$(docker images --filter "reference=*sdn*" --filter "reference=*tutorial*" --filter "reference=opendaylight*" -q 2>/dev/null || true)
    if [ -n "$TUTORIAL_IMAGES" ]; then
        echo -e "   🖼️  Found tutorial-related images"
        if confirm "   Remove tutorial-related Docker images?"; then
            echo "$TUTORIAL_IMAGES" | xargs -r docker rmi 2>/dev/null || true
            echo -e "   ✅ ${GREEN}Tutorial images removed${NC}"
        fi
    fi
else
    echo -e "   ℹ️  Docker not available"
fi

# 3. Clean up Python virtual environment
echo ""
echo -e "${YELLOW}3. Python Virtual Environment${NC}"
if [ -d "$VENV_NAME" ]; then
    VENV_SIZE=$(du -sh "$VENV_NAME" 2>/dev/null | cut -f1)
    echo -e "   🐍 Found virtual environment: ${GREEN}$VENV_NAME${NC} ($VENV_SIZE)"
    
    if confirm "   Remove Python virtual environment?"; then
        rm -rf "$VENV_NAME"
        echo -e "   ✅ ${GREEN}Virtual environment removed${NC}"
    else
        echo -e "   ⏭️  ${BLUE}Keeping virtual environment${NC}"
    fi
else
    echo -e "   ℹ️  No virtual environment found at $VENV_NAME"
fi

# 4. Clean up generated files
echo ""
echo -e "${YELLOW}4. Generated Files and Cache${NC}"
GENERATED_FILES=(
    "network-policies.yaml"
    "test-deployment.yaml" 
    "kind-config.yaml"
    "bandit-report.json"
    ".coverage"
    "htmlcov/"
    ".pytest_cache/"
    "src/__pycache__/"
    "tests/__pycache__/"
    "*.log"
)

echo -e "   📄 Checking for generated files..."
FILES_TO_REMOVE=()
for file in "${GENERATED_FILES[@]}"; do
    if [ -e "$file" ] || [ -d "$file" ]; then
        FILES_TO_REMOVE+=("$file")
    fi
done

if [ ${#FILES_TO_REMOVE[@]} -gt 0 ]; then
    echo -e "   📋 Found files to remove:"
    printf '     - %s\n' "${FILES_TO_REMOVE[@]}"
    
    if confirm "   Remove generated files and cache?"; then
        for file in "${FILES_TO_REMOVE[@]}"; do
            rm -rf "$file" 2>/dev/null || true
        done
        echo -e "   ✅ ${GREEN}Generated files removed${NC}"
    fi
else
    echo -e "   ℹ️  No generated files found"
fi

# 5. Project source code (DANGEROUS - ask twice)
echo ""
echo -e "${YELLOW}5. Project Source Code${NC}"
if [ -d "src" ] || [ -d "tests" ]; then
    echo -e "   ⚠️  ${RED}WARNING: This will delete your source code!${NC}"
    echo -e "   📁 Found directories: src/, tests/, infrastructure/, etc."
    echo ""
    echo -e "   ${RED}⚠️  DANGER ZONE: Complete project removal${NC}"
    
    if confirm "   Are you ABSOLUTELY SURE you want to remove ALL source code?" "n"; then
        echo ""
        echo -e "   ${RED}⚠️  FINAL WARNING: This cannot be undone!${NC}"
        echo -e "   📁 About to delete: $PROJECT_ROOT/$PROJECT_NAME"
        
        if confirm "   Type 'yes' to confirm complete project deletion" "n"; then
            cd "$PROJECT_ROOT"
            rm -rf "$PROJECT_NAME"
            echo -e "   ✅ ${GREEN}Complete project removed${NC}"
            echo -e "   📁 Current directory: $(pwd)"
            PROJECT_DELETED=true
        else
            echo -e "   🛑 ${BLUE}Project deletion cancelled${NC}"
        fi
    else
        echo -e "   🛑 ${BLUE}Source code preserved${NC}"
    fi
else
    echo -e "   ℹ️  No source directories found"
fi

echo ""
echo -e "${GREEN}=== CLEANUP SUMMARY ===${NC}"
echo -e "${GREEN}✅ Cleanup completed!${NC}"
echo ""

if [ "$PROJECT_DELETED" = "true" ]; then
    echo -e "${YELLOW}📁 Project completely removed from: $PROJECT_ROOT/$PROJECT_NAME${NC}"
else
    echo -e "${BLUE}📁 Project preserved at: $PROJECT_ROOT/$PROJECT_NAME${NC}"
    echo ""
    echo -e "${BLUE}📋 To restart the tutorial:${NC}"
    echo "   cd $PROJECT_ROOT/$PROJECT_NAME"
    echo "   source activate.sh  # (if virtual env was preserved)"
    echo "   make status         # Check what needs to be recreated"
fi

echo ""
echo -e "${GREEN}🎉 Tutorial cleanup finished!${NC}"