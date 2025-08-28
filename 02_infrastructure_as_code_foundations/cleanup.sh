#!/bin/bash
# Tutorial 02 - Interactive Cleanup Script
# Safely removes Infrastructure as Code resources with confirmation

set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
PROJECT_NAME="${PROJECT_NAME:-iac_network_automation}"
VENV_NAME="${VENV_NAME:-venv}"

echo -e "${BLUE}🧹 Tutorial 02: Infrastructure as Code Cleanup${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
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
        * ) return 1;;
    esac
}

# Check if project exists
if [ ! -d "$PROJECT_NAME" ]; then
    echo -e "${YELLOW}⚠️  Project directory not found: $PROJECT_NAME${NC}"
    echo "Nothing to clean up."
    exit 0
fi

cd "$PROJECT_NAME"
echo "📁 Project location: $(pwd)"
echo ""

echo -e "${BLUE}=== CLEANUP OPTIONS ===${NC}"
echo ""

# 1. Terraform resources
echo -e "${YELLOW}1. Terraform Resources${NC}"
if [ -d "terraform/.terraform" ]; then
    echo "   🏗️  Found Terraform state and providers"
    
    # Check for deployed resources
    if [ -f "terraform/terraform.tfstate" ]; then
        resource_count=$(terraform -chdir=terraform show -json 2>/dev/null | jq '.values.root_module.resources | length' 2>/dev/null || echo "0")
        if [ "$resource_count" != "0" ]; then
            echo -e "   ${YELLOW}⚠️  WARNING: $resource_count active resources found${NC}"
            
            if confirm "   Destroy all Terraform resources?" "y"; then
                echo "   🔄 Destroying Terraform resources..."
                cd terraform
                terraform destroy -auto-approve
                cd ..
                echo -e "   ${GREEN}✅ Terraform resources destroyed${NC}"
            else
                echo -e "   ${BLUE}⏭️  Keeping Terraform resources${NC}"
            fi
        fi
    fi
    
    if confirm "   Remove Terraform state and cache?" "y"; then
        rm -rf terraform/.terraform terraform/.terraform.lock.hcl
        rm -f terraform/terraform.tfstate* terraform/tfplan
        echo -e "   ${GREEN}✅ Terraform cache cleaned${NC}"
    fi
else
    echo "   ℹ️  No Terraform resources found"
fi

echo ""

# 2. Docker resources
echo -e "${YELLOW}2. Docker Resources${NC}"
if command -v docker >/dev/null 2>&1; then
    # Check for tutorial networks
    networks=$(docker network ls --filter "label=managed_by=terraform" --format "{{.Name}}" 2>/dev/null | head -5)
    if [ -n "$networks" ]; then
        echo "   🐳 Found Docker networks created by this tutorial:"
        echo "$networks" | sed 's/^/     - /'
        
        if confirm "   Remove these Docker networks?" "y"; then
            echo "$networks" | xargs -r docker network rm 2>/dev/null || true
            echo -e "   ${GREEN}✅ Docker networks removed${NC}"
        else
            echo -e "   ${BLUE}⏭️  Keeping Docker networks${NC}"
        fi
    else
        echo "   ℹ️  No tutorial Docker networks found"
    fi
else
    echo "   ℹ️  Docker not available"
fi

echo ""

# 3. Python virtual environment
echo -e "${YELLOW}3. Python Virtual Environment${NC}"
if [ -d "$VENV_NAME" ]; then
    size=$(du -sh "$VENV_NAME" 2>/dev/null | cut -f1)
    echo "   🐍 Found virtual environment: $VENV_NAME ($size)"
    
    if confirm "   Remove Python virtual environment?" "y"; then
        rm -rf "$VENV_NAME"
        echo -e "   ${GREEN}✅ Virtual environment removed${NC}"
    else
        echo -e "   ${BLUE}⏭️  Keeping virtual environment${NC}"
    fi
else
    echo "   ℹ️  No virtual environment found"
fi

echo ""

# 4. Generated files and cache
echo -e "${YELLOW}4. Generated Files and Cache${NC}"
echo "   📄 Checking for generated files..."

generated_items=(
    "backups"
    "__pycache__"
    ".pytest_cache"
    "*.pyc"
    "test_report.md"
    ".coverage"
    "htmlcov"
)

found_items=()
for item in "${generated_items[@]}"; do
    if compgen -G "$item" >/dev/null 2>&1 || [ -d "$item" ]; then
        found_items+=("$item")
    fi
done

if [ ${#found_items[@]} -gt 0 ]; then
    echo "   Found items to clean:"
    printf '     - %s\n' "${found_items[@]}"
    
    if confirm "   Remove generated files and cache?" "y"; then
        rm -rf backups __pycache__ .pytest_cache .coverage htmlcov test_report.md
        find . -type f -name "*.pyc" -delete 2>/dev/null || true
        find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
        echo -e "   ${GREEN}✅ Generated files removed${NC}"
    else
        echo -e "   ${BLUE}⏭️  Keeping generated files${NC}"
    fi
else
    echo "   ℹ️  No generated files found"
fi

echo ""

# 5. Git repository
echo -e "${YELLOW}5. Git Repository${NC}"
if [ -d ".git" ]; then
    echo "   📚 Found git repository"
    
    if confirm "   Remove git repository?" "n"; then
        rm -rf .git
        echo -e "   ${GREEN}✅ Git repository removed${NC}"
    else
        echo -e "   ${BLUE}⏭️  Keeping git repository${NC}"
    fi
else
    echo "   ℹ️  No git repository found"
fi

echo ""

# 6. Complete project removal
echo -e "${YELLOW}6. Complete Project Removal${NC}"
echo -e "   ${RED}⚠️  WARNING: This will delete everything!${NC}"
echo "   Project directory: $(pwd)"

if confirm "   Delete entire project directory?" "n"; then
    cd ..
    rm -rf "$PROJECT_NAME"
    echo -e "   ${GREEN}✅ Project directory removed${NC}"
    echo ""
    echo -e "${GREEN}✅ Complete cleanup finished!${NC}"
    exit 0
else
    echo -e "   ${BLUE}⏭️  Project directory preserved${NC}"
fi

echo ""
echo -e "${BLUE}=== CLEANUP SUMMARY ===${NC}"
echo ""

# Check what remains
if [ -d "terraform/.terraform" ] || [ -f "terraform/terraform.tfstate" ]; then
    echo "⚠️  Terraform resources may still exist"
fi

if [ -d "$VENV_NAME" ]; then
    echo "📦 Python virtual environment preserved"
fi

if [ -d ".git" ]; then
    echo "📚 Git repository preserved"
fi

echo ""
echo -e "${GREEN}✅ Cleanup completed!${NC}"
echo ""
echo "📁 Project location: $(pwd)"
echo ""
echo "💡 To completely remove everything, run:"
echo "   cd .. && rm -rf $PROJECT_NAME"
echo ""