#!/bin/bash
# Tutorial 05 Setup Script - Production Network Automation with ONAP & Kubernetes
# Comprehensive ONAP platform deployment and network automation setup

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
TIMEOUT=600

echo -e "${BLUE}🚀 Setting up Tutorial 05: Production Network Automation${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "🏗️  Platform: ONAP (Open Network Automation Platform)"
echo -e "☸️  Infrastructure: Kubernetes"
echo -e "📦 Components: SDC, SO, SDNC, APPC, DCAE, Policy, CLAMP"
echo -e "⏱️  Estimated setup time: 15-20 minutes"
echo ""

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to wait for deployment
wait_for_deployment() {
    local namespace=$1
    local deployment=$2
    local timeout=${3:-300}
    
    echo -e "${YELLOW}⏳ Waiting for deployment $deployment in namespace $namespace...${NC}"
    if kubectl wait --for=condition=available --timeout=${timeout}s deployment/$deployment -n $namespace >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Deployment $deployment is ready${NC}"
        return 0
    else
        echo -e "${RED}❌ Deployment $deployment failed to become ready${NC}"
        return 1
    fi
}

# Function to wait for pod
wait_for_pod() {
    local namespace=$1
    local label=$2
    local timeout=${3:-300}
    
    echo -e "${YELLOW}⏳ Waiting for pod with label $label in namespace $namespace...${NC}"
    if kubectl wait --for=condition=ready --timeout=${timeout}s pod -l $label -n $namespace >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Pod with label $label is ready${NC}"
        return 0
    else
        echo -e "${RED}❌ Pod with label $label failed to become ready${NC}"
        return 1
    fi
}

# Phase 1: Environment Preparation
echo -e "${PURPLE}📋 Phase 1: Environment Preparation${NC}"

# Check prerequisites
echo -e "${YELLOW}🔍 Checking prerequisites...${NC}"

if ! command_exists kubectl; then
    echo -e "${RED}❌ kubectl not found${NC}"
    exit 1
fi

if ! command_exists helm; then
    echo -e "${RED}❌ helm not found${NC}"
    exit 1
fi

if ! command_exists docker; then
    echo -e "${RED}❌ docker not found${NC}"
    exit 1
fi

# Check Kubernetes cluster
if ! kubectl cluster-info >/dev/null 2>&1; then
    echo -e "${RED}❌ No Kubernetes cluster available${NC}"
    echo "Please ensure you have a running Kubernetes cluster"
    exit 1
fi

echo -e "${GREEN}✅ Prerequisites verified${NC}"

# Create project directory
if [ -d "$PROJECT_NAME" ]; then
    echo -e "${YELLOW}⚠️  Project directory $PROJECT_NAME already exists${NC}"
    read -p "Do you want to continue? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
else
    mkdir -p "$PROJECT_NAME"
fi

cd "$PROJECT_NAME"

# Create directory structure
echo -e "${YELLOW}📁 Creating project structure...${NC}"
mkdir -p {bin,venv,onap-helm-charts,service-models,python-automation,policy-models,monitoring-dashboards,integration-adapters,scripts,configs,logs,docs}

# Phase 2: Python Environment Setup
echo -e "\n${PURPLE}🐍 Phase 2: Python Environment Setup${NC}"

if [ ! -d "venv" ]; then
    echo -e "${YELLOW}Creating Python virtual environment...${NC}"
    python3 -m venv venv
fi

source venv/bin/activate

# Install Python dependencies
echo -e "${YELLOW}📦 Installing Python dependencies...${NC}"
pip install --upgrade pip setuptools wheel

cat > requirements.txt << 'EOF'
# ONAP Integration and Automation
requests>=2.28.0
pyyaml>=6.0
jinja2>=3.1.0
kubernetes>=24.2.0
openstack-sdk>=0.103.0

# Network Automation
netaddr>=0.8.0
paramiko>=2.11.0
napalm>=4.0.0
nornir>=3.3.0

# API and Web Framework
flask>=2.2.0
fastapi>=0.85.0
uvicorn>=0.18.0

# Data Processing and Analytics
pandas>=1.5.0
numpy>=1.23.0
matplotlib>=3.6.0
elasticsearch>=8.4.0

# Monitoring and Observability
prometheus-client>=0.14.0
grafana-api>=1.0.3

# Testing and Quality
pytest>=7.1.0
pytest-asyncio>=0.19.0
black>=22.8.0
flake8>=5.0.0
bandit>=1.7.0

# Development and Debugging
ipython>=8.5.0
jupyter>=1.0.0
EOF

pip install -r requirements.txt

echo -e "${GREEN}✅ Python environment configured${NC}"

# Phase 3: Kubernetes and Helm Setup
echo -e "\n${PURPLE}☸️ Phase 3: Kubernetes and Helm Setup${NC}"

# Add Helm repositories
echo -e "${YELLOW}📦 Adding Helm repositories...${NC}"
helm repo add onap https://nexus3.onap.org/repository/onap-helm-release/ || true
helm repo add bitnami https://charts.bitnami.com/bitnami || true
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts || true
helm repo add grafana https://grafana.github.io/helm-charts || true
helm repo update

# Create ONAP namespace
echo -e "${YELLOW}🏷️  Creating ONAP namespace...${NC}"
kubectl create namespace $ONAP_NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

# Phase 4: ONAP Platform Deployment
echo -e "\n${PURPLE}🎛️ Phase 4: ONAP Platform Deployment${NC}"

# Create simplified ONAP values file for development/demo
cat > configs/onap-values.yaml << 'EOF'
# ONAP Simplified Configuration for Tutorial
global:
  nodePortPrefix: 302
  nodePortPrefixExt: 304
  repository: nexus3.onap.org:10001
  repositorySecret: docker-registry-key
  pullPolicy: IfNotPresent
  persistence:
    mountPath: /dockerdata-nfs

# Core ONAP Components for Tutorial
aaf:
  enabled: false
  
aai:
  enabled: true
  replicaCount: 1
  
appc:
  enabled: true
  replicaCount: 1
  
clamp:
  enabled: true
  replicaCount: 1
  
dcaegen2:
  enabled: true
  
dmaap:
  enabled: true
  
msb:
  enabled: true
  
multicloud:
  enabled: false
  
nbi:
  enabled: true
  
oof:
  enabled: false
  
policy:
  enabled: true
  replicaCount: 1
  
portal:
  enabled: true
  replicaCount: 1
  
robot:
  enabled: true
  
sdc:
  enabled: true
  replicaCount: 1
  
sdnc:
  enabled: true
  replicaCount: 1
  
so:
  enabled: true
  replicaCount: 1
  
uui:
  enabled: false
  
vfc:
  enabled: false
  
vid:
  enabled: true
  replicaCount: 1

# Resource limits for tutorial environment
resources:
  small:
    limits:
      cpu: 1
      memory: 4Gi
    requests:
      cpu: 500m
      memory: 1Gi
  large:
    limits:
      cpu: 2
      memory: 8Gi
    requests:
      cpu: 1
      memory: 2Gi
EOF

# Deploy core infrastructure components first
echo -e "${YELLOW}🎯 Deploying core infrastructure components...${NC}"

# Deploy Cassandra for ONAP data persistence
cat > configs/cassandra-values.yaml << 'EOF'
replicaCount: 1
image:
  tag: 3.11.4
persistence:
  enabled: true
  size: 10Gi
resources:
  limits:
    cpu: 1
    memory: 4Gi
  requests:
    cpu: 500m
    memory: 2Gi
EOF

helm upgrade --install cassandra bitnami/cassandra -n $ONAP_NAMESPACE -f configs/cassandra-values.yaml --wait --timeout=10m

# Deploy MariaDB for ONAP databases
cat > configs/mariadb-values.yaml << 'EOF'
auth:
  rootPassword: "secretpassword"
  database: "onap"
  username: "onap"
  password: "onap"
primary:
  persistence:
    enabled: true
    size: 10Gi
  resources:
    limits:
      cpu: 1
      memory: 2Gi
    requests:
      cpu: 500m
      memory: 1Gi
EOF

helm upgrade --install mariadb bitnami/mariadb -n $ONAP_NAMESPACE -f configs/mariadb-values.yaml --wait --timeout=10m

# Phase 5: ONAP Service Models and Templates
echo -e "\n${PURPLE}📋 Phase 5: Service Models and Templates${NC}"

echo -e "${YELLOW}🎨 Creating VNF service models...${NC}"

# Create vFirewall service model
cat > service-models/vfirewall-service-model.yaml << 'EOF'
tosca_definitions_version: tosca_simple_yaml_1_1

metadata:
  template_name: vFirewall
  template_author: ONAP Tutorial
  template_version: 1.0.0

description: Virtual Firewall Network Service

imports:
  - onap_dm.yaml

topology_template:
  node_templates:
    VL_public:
      type: tosca.nodes.nfv.VnfVirtualLink
      properties:
        connectivity_type:
          layer_protocols: [ipv4]
        vl_profile:
          max_bitrate_requirements:
            root: 1000000
            leaf: 1000000
          min_bitrate_requirements:
            root: 1000000
            leaf: 1000000

    VL_private:
      type: tosca.nodes.nfv.VnfVirtualLink
      properties:
        connectivity_type:
          layer_protocols: [ipv4]
        vl_profile:
          max_bitrate_requirements:
            root: 1000000
            leaf: 1000000

    vFirewall_VNF:
      type: tosca.nodes.nfv.VNF
      properties:
        descriptor_id: vFirewall_VNF
        descriptor_version: 1.0.0
        provider: Generic
        product_name: vFirewall
        software_version: 1.0.0
        product_info_name: vFirewall
        product_info_description: Virtual Firewall VNF
        vnfm_info: [generic-vnfm]
        localization_languages: [en_US]
        default_localization_language: en_US
      requirements:
        - virtual_link: VL_public
        - virtual_link: VL_private

  groups:
    vFirewall_VNF_group:
      type: tosca.groups.nfv.PlacementGroup
      members: [vFirewall_VNF]

  policies:
    - scaling_policy:
        type: tosca.policies.nfv.ScalingAspects
        targets: [vFirewall_VNF]
        properties:
          aspects:
            firewall_aspect:
              name: firewall_aspect
              description: Scale firewall instances
              max_scale_level: 5
              step_deltas:
                - delta_1
EOF

# Create 5G network slice service model
cat > service-models/5g-slice-service-model.yaml << 'EOF'
tosca_definitions_version: tosca_simple_yaml_1_1

metadata:
  template_name: 5G_Network_Slice
  template_author: ONAP Tutorial
  template_version: 1.0.0

description: 5G Network Slice Service Template

topology_template:
  inputs:
    slice_type:
      type: string
      default: eMBB
      constraints:
        - valid_values: [eMBB, URLLC, mMTC]
    
    sla_latency:
      type: integer
      default: 10
      description: Maximum latency in milliseconds
    
    sla_throughput:
      type: integer
      default: 1000
      description: Minimum throughput in Mbps

  node_templates:
    AMF_CNF:
      type: tosca.nodes.nfv.VNF
      properties:
        descriptor_id: amf_cnf
        vnfm_info: [k8s-vnfm]
        localization_languages: [en_US]

    SMF_CNF:
      type: tosca.nodes.nfv.VNF
      properties:
        descriptor_id: smf_cnf
        vnfm_info: [k8s-vnfm]

    UPF_CNF:
      type: tosca.nodes.nfv.VNF
      properties:
        descriptor_id: upf_cnf
        vnfm_info: [k8s-vnfm]

    NetworkSlice:
      type: org.onap.resource.abstract.nodes.NetworkSlice
      properties:
        slice_type: { get_input: slice_type }
        sla:
          latency: { get_input: sla_latency }
          throughput: { get_input: sla_throughput }
          availability: 99.99
      requirements:
        - amf: AMF_CNF
        - smf: SMF_CNF
        - upf: UPF_CNF

  policies:
    - slice_sla_policy:
        type: tosca.policies.nfv.SecurityGroupRule
        targets: [NetworkSlice]
        properties:
          description: SLA enforcement for network slice
EOF

echo -e "${GREEN}✅ Service models created${NC}"

# Phase 6: Python Automation Scripts
echo -e "\n${PURPLE}🔧 Phase 6: Python Automation Scripts${NC}"

echo -e "${YELLOW}🐍 Creating ONAP automation scripts...${NC}"

# ONAP API client
cat > python-automation/onap_client.py << 'EOF'
#!/usr/bin/env python3
"""
ONAP API Client - Tutorial 05
Comprehensive client for interacting with ONAP platform components
"""

import requests
import json
import time
import logging
from typing import Dict, Any, List, Optional
from urllib.parse import urljoin
import yaml
import base64

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)


class ONAPClient:
    """Main ONAP platform client"""
    
    def __init__(self, base_url: str, username: str = "demo", password: str = "demo123456!"):
        self.base_url = base_url
        self.username = username
        self.password = password
        self.session = requests.Session()
        self.session.auth = (username, password)
        self.session.verify = False
        
        # ONAP component endpoints
        self.endpoints = {
            'aai': f"{base_url}:30233/aai/v21",
            'sdc': f"{base_url}:30206/sdc1/feProxy/rest",
            'so': f"{base_url}:30277/onap/so/infra",
            'sdnc': f"{base_url}:30202/restconf",
            'policy': f"{base_url}:30219/policy/api/v1",
            'dcae': f"{base_url}:30418",
            'clamp': f"{base_url}:30258/restservices/clds/v2",
            'vid': f"{base_url}:30200/vid/api"
        }
        
        logger.info(f"Initialized ONAP client for {base_url}")

    def get_health_status(self) -> Dict[str, Any]:
        """Get health status of all ONAP components"""
        status = {}
        
        for component, endpoint in self.endpoints.items():
            try:
                response = self.session.get(f"{endpoint}/healthcheck", timeout=10)
                status[component] = {
                    "status": "healthy" if response.status_code == 200 else "unhealthy",
                    "status_code": response.status_code,
                    "response_time": response.elapsed.total_seconds()
                }
            except Exception as e:
                status[component] = {
                    "status": "unreachable",
                    "error": str(e)
                }
                
        return status


class SDCClient:
    """Service Design and Creation (SDC) client"""
    
    def __init__(self, onap_client: ONAPClient):
        self.client = onap_client
        self.base_url = onap_client.endpoints['sdc']
    
    def create_vsp(self, vsp_data: Dict[str, Any]) -> Optional[str]:
        """Create Vendor Software Product"""
        try:
            url = f"{self.base_url}/v1.0/vendor-software-products"
            response = self.client.session.post(url, json=vsp_data)
            
            if response.status_code == 200:
                result = response.json()
                vsp_id = result.get('itemId')
                logger.info(f"Created VSP with ID: {vsp_id}")
                return vsp_id
            else:
                logger.error(f"Failed to create VSP: {response.status_code}")
                return None
                
        except Exception as e:
            logger.error(f"Error creating VSP: {e}")
            return None
    
    def create_vf(self, vf_data: Dict[str, Any]) -> Optional[str]:
        """Create Virtual Function"""
        try:
            url = f"{self.base_url}/v1.0/catalog/resources"
            response = self.client.session.post(url, json=vf_data)
            
            if response.status_code == 201:
                result = response.json()
                vf_id = result.get('uniqueId')
                logger.info(f"Created VF with ID: {vf_id}")
                return vf_id
            else:
                logger.error(f"Failed to create VF: {response.status_code}")
                return None
                
        except Exception as e:
            logger.error(f"Error creating VF: {e}")
            return None

    def create_service(self, service_data: Dict[str, Any]) -> Optional[str]:
        """Create Service"""
        try:
            url = f"{self.base_url}/v1.0/catalog/services"
            response = self.client.session.post(url, json=service_data)
            
            if response.status_code == 201:
                result = response.json()
                service_id = result.get('uniqueId')
                logger.info(f"Created Service with ID: {service_id}")
                return service_id
            else:
                logger.error(f"Failed to create Service: {response.status_code}")
                return None
                
        except Exception as e:
            logger.error(f"Error creating Service: {e}")
            return None


class SOClient:
    """Service Orchestrator (SO) client"""
    
    def __init__(self, onap_client: ONAPClient):
        self.client = onap_client
        self.base_url = onap_client.endpoints['so']
    
    def create_service_instance(self, service_data: Dict[str, Any]) -> Optional[str]:
        """Create service instance"""
        try:
            url = f"{self.base_url}/serviceInstantiation/v7/serviceInstances"
            response = self.client.session.post(url, json=service_data)
            
            if response.status_code == 202:
                result = response.json()
                request_id = result.get('requestReferences', {}).get('requestId')
                logger.info(f"Service instantiation request created: {request_id}")
                return request_id
            else:
                logger.error(f"Failed to create service instance: {response.status_code}")
                return None
                
        except Exception as e:
            logger.error(f"Error creating service instance: {e}")
            return None
    
    def get_orchestration_request_status(self, request_id: str) -> Optional[Dict[str, Any]]:
        """Get orchestration request status"""
        try:
            url = f"{self.base_url}/orchestrationRequests/v7/{request_id}"
            response = self.client.session.get(url)
            
            if response.status_code == 200:
                return response.json()
            else:
                logger.error(f"Failed to get request status: {response.status_code}")
                return None
                
        except Exception as e:
            logger.error(f"Error getting request status: {e}")
            return None


class PolicyClient:
    """Policy Framework client"""
    
    def __init__(self, onap_client: ONAPClient):
        self.client = onap_client
        self.base_url = onap_client.endpoints['policy']
    
    def create_policy_type(self, policy_type_data: Dict[str, Any]) -> bool:
        """Create policy type"""
        try:
            url = f"{self.base_url}/policytypes"
            response = self.client.session.post(url, json=policy_type_data)
            
            if response.status_code in [200, 201]:
                logger.info("Policy type created successfully")
                return True
            else:
                logger.error(f"Failed to create policy type: {response.status_code}")
                return False
                
        except Exception as e:
            logger.error(f"Error creating policy type: {e}")
            return False
    
    def create_policy(self, policy_data: Dict[str, Any]) -> bool:
        """Create policy"""
        try:
            policy_type_id = policy_data.get('policy_type_id', 'onap.policies.operational.common.Apex')
            url = f"{self.base_url}/policytypes/{policy_type_id}/policies"
            response = self.client.session.post(url, json=policy_data)
            
            if response.status_code in [200, 201]:
                logger.info("Policy created successfully")
                return True
            else:
                logger.error(f"Failed to create policy: {response.status_code}")
                return False
                
        except Exception as e:
            logger.error(f"Error creating policy: {e}")
            return False


class DCAAEClient:
    """Data Collection, Analytics & Events client"""
    
    def __init__(self, onap_client: ONAPClient):
        self.client = onap_client
        self.base_url = onap_client.endpoints['dcae']
    
    def deploy_microservice(self, ms_data: Dict[str, Any]) -> Optional[str]:
        """Deploy DCAE microservice"""
        try:
            url = f"{self.base_url}/dcae-deployments/v1/deployments"
            response = self.client.session.post(url, json=ms_data)
            
            if response.status_code == 202:
                result = response.json()
                deployment_id = result.get('deploymentId')
                logger.info(f"DCAE microservice deployment started: {deployment_id}")
                return deployment_id
            else:
                logger.error(f"Failed to deploy microservice: {response.status_code}")
                return None
                
        except Exception as e:
            logger.error(f"Error deploying microservice: {e}")
            return None


def main():
    """Main function for testing ONAP client"""
    # Initialize ONAP client
    onap_client = ONAPClient("http://localhost")
    
    # Test health status
    print("=== ONAP Platform Health Check ===")
    health_status = onap_client.get_health_status()
    
    for component, status in health_status.items():
        status_icon = "✅" if status.get("status") == "healthy" else "❌"
        print(f"{status_icon} {component.upper()}: {status.get('status', 'unknown')}")
    
    # Example: Create a simple VNF service
    print("\n=== SDC Service Creation Example ===")
    sdc_client = SDCClient(onap_client)
    
    vf_data = {
        "name": "vFirewall_VF",
        "description": "Virtual Firewall VF for Tutorial 05",
        "resourceType": "VF",
        "category": "Network L2-3",
        "subcategory": "Firewall",
        "vendorName": "Tutorial",
        "vendorRelease": "1.0",
        "contactId": "demo",
        "icon": "firewall"
    }
    
    vf_id = sdc_client.create_vf(vf_data)
    if vf_id:
        print(f"✅ VF created successfully with ID: {vf_id}")
    else:
        print("❌ Failed to create VF")


if __name__ == "__main__":
    main()
EOF

# Service deployment automation
cat > python-automation/deploy_vfirewall.py << 'EOF'
#!/usr/bin/env python3
"""
vFirewall Service Deployment - Tutorial 05
Automated deployment of vFirewall service using ONAP
"""

import asyncio
import logging
from onap_client import ONAPClient, SDCClient, SOClient
import yaml
import time
from typing import Dict, Any

logger = logging.getLogger(__name__)


class VFirewallDeployment:
    """Automated vFirewall service deployment"""
    
    def __init__(self, onap_base_url: str):
        self.onap_client = ONAPClient(onap_base_url)
        self.sdc_client = SDCClient(self.onap_client)
        self.so_client = SOClient(self.onap_client)
    
    async def deploy_service(self) -> bool:
        """Deploy complete vFirewall service"""
        logger.info("Starting vFirewall service deployment")
        
        # Step 1: Create VNF package in SDC
        vsp_data = {
            "name": "vFirewall_VSP",
            "description": "Virtual Firewall Vendor Software Product",
            "category": "Network Layer 2-3",
            "subCategory": "Firewall",
            "licensingData": {
                "featureGroups": [],
                "licenseAgreement": ""
            },
            "vendorName": "Tutorial Vendor"
        }
        
        vsp_id = self.sdc_client.create_vsp(vsp_data)
        if not vsp_id:
            logger.error("Failed to create VSP")
            return False
        
        # Step 2: Create VF
        vf_data = {
            "name": "vFirewall_VF",
            "description": "Virtual Firewall VF",
            "resourceType": "VF",
            "category": "Network L2-3",
            "subcategory": "Firewall",
            "vendorName": "Tutorial",
            "vendorRelease": "1.0",
            "contactId": "demo",
            "icon": "firewall"
        }
        
        vf_id = self.sdc_client.create_vf(vf_data)
        if not vf_id:
            logger.error("Failed to create VF")
            return False
        
        # Step 3: Create Service
        service_data = {
            "name": "vFirewall_Service",
            "description": "Virtual Firewall Network Service",
            "category": "Network Service",
            "instantiationType": "A-la-carte",
            "serviceType": "NetworkService",
            "serviceRole": "NetworkService",
            "contactId": "demo",
            "icon": "network_l_2-3"
        }
        
        service_id = self.sdc_client.create_service(service_data)
        if not service_id:
            logger.error("Failed to create Service")
            return False
        
        # Step 4: Service instantiation via SO
        instantiation_data = {
            "requestDetails": {
                "modelInfo": {
                    "modelType": "service",
                    "modelInvariantId": service_id,
                    "modelVersionId": service_id,
                    "modelName": "vFirewall_Service",
                    "modelVersion": "1.0"
                },
                "requestInfo": {
                    "instanceName": "vFirewall_Instance_001",
                    "source": "VID",
                    "suppressRollback": False,
                    "requestorId": "demo"
                },
                "subscriberInfo": {
                    "globalSubscriberId": "Demonstration",
                    "subscriberName": "Demonstration"
                },
                "requestParameters": {
                    "subscriptionServiceType": "vFW",
                    "userParams": [
                        {
                            "name": "vfirewall_name_0",
                            "value": "vFirewall-Demo"
                        }
                    ],
                    "aLaCarte": False
                }
            }
        }
        
        request_id = self.so_client.create_service_instance(instantiation_data)
        if not request_id:
            logger.error("Failed to create service instance")
            return False
        
        # Step 5: Monitor deployment
        logger.info(f"Monitoring deployment progress (Request ID: {request_id})")
        for attempt in range(30):  # 15 minutes timeout
            time.sleep(30)
            status = self.so_client.get_orchestration_request_status(request_id)
            
            if status:
                request_status = status.get('request', {}).get('requestStatus', {}).get('requestState')
                logger.info(f"Deployment status: {request_status}")
                
                if request_status == "COMPLETE":
                    logger.info("✅ vFirewall service deployed successfully")
                    return True
                elif request_status in ["FAILED", "ROLLED_BACK"]:
                    logger.error("❌ vFirewall service deployment failed")
                    return False
        
        logger.warning("⏰ Deployment timeout")
        return False


async def main():
    """Main deployment function"""
    print("🚀 Starting vFirewall Service Deployment")
    print("=" * 50)
    
    deployment = VFirewallDeployment("http://localhost")
    
    try:
        success = await deployment.deploy_service()
        if success:
            print("\n✅ vFirewall service deployment completed successfully!")
            print("\nNext steps:")
            print("1. Access VID portal: http://localhost:30200/vid/welcome.htm")
            print("2. Monitor deployment in SO: http://localhost:30277")
            print("3. Check A&AI inventory: http://localhost:30233/aai/ui/")
        else:
            print("\n❌ vFirewall service deployment failed!")
            print("Check ONAP logs for more details.")
            
    except Exception as e:
        logger.error(f"Deployment error: {e}")
        print(f"\n❌ Deployment error: {e}")


if __name__ == "__main__":
    asyncio.run(main())
EOF

# Policy automation script
cat > python-automation/policy_automation.py << 'EOF'
#!/usr/bin/env python3
"""
ONAP Policy Automation - Tutorial 05
Automated policy creation and management
"""

import logging
from onap_client import ONAPClient, PolicyClient
from typing import Dict, Any, List
import json
import time

logger = logging.getLogger(__name__)


class PolicyAutomation:
    """ONAP Policy Framework automation"""
    
    def __init__(self, onap_base_url: str):
        self.onap_client = ONAPClient(onap_base_url)
        self.policy_client = PolicyClient(self.onap_client)
    
    def create_scaling_policy(self) -> bool:
        """Create VNF auto-scaling policy"""
        policy_data = {
            "tosca_definitions_version": "tosca_simple_yaml_1_1",
            "policies": [
                {
                    "vFirewall.AutoScaling": {
                        "type": "onap.policies.operational.common.Apex",
                        "version": "1.0.0",
                        "properties": {
                            "engineServiceParameters": {
                                "name": "vFirewallAutoScaling",
                                "version": "1.0.0",
                                "id": 101,
                                "instanceCount": 1,
                                "deploymentPort": 12345,
                                "policyModelFileName": "vFirewallAutoScalingPolicyModel.json"
                            },
                            "eventOutputParameters": {
                                "producer": {
                                    "carrierTechnology": "RESTCLIENT",
                                    "parameterClassName": "org.onap.policy.apex.plugins.event.carrier.restclient.RestClientCarrierTechnologyParameters",
                                    "parameters": {
                                        "url": "http://message-router:3904/events/POLICY-CL-MGT"
                                    }
                                }
                            },
                            "eventInputParameters": {
                                "consumer": {
                                    "carrierTechnology": "RESTCLIENT",
                                    "parameterClassName": "org.onap.policy.apex.plugins.event.carrier.restclient.RestClientCarrierTechnologyParameters",
                                    "parameters": {
                                        "url": "http://message-router:3904/events/unauthenticated.DCAE_CL_OUTPUT/cg1/c1?timeout=30000"
                                    }
                                }
                            }
                        }
                    }
                }
            ]
        }
        
        return self.policy_client.create_policy(policy_data)
    
    def create_monitoring_policy(self) -> bool:
        """Create monitoring policy"""
        policy_data = {
            "tosca_definitions_version": "tosca_simple_yaml_1_1",
            "policies": [
                {
                    "vFirewall.Monitoring": {
                        "type": "onap.policies.monitoring.tcagen2",
                        "version": "1.0.0",
                        "properties": {
                            "tca_policy": {
                                "domain": "measurementsForVfScaling",
                                "metricsPerEventName": [
                                    {
                                        "eventName": "vPacketLoss",
                                        "controlLoopSchemaType": "VM",
                                        "policyScope": "DCAE",
                                        "policyName": "vFirewall.Monitoring",
                                        "policyVersion": "v0.0.1",
                                        "thresholds": [
                                            {
                                                "closedLoopControlName": "vFirewall.AutoScaling",
                                                "version": "1.0.2",
                                                "fieldPath": "$.event.measurementsForVfScalingFields.vNicPerformanceArray[*].receivedTotalPacketsDelta",
                                                "thresholdValue": 300,
                                                "direction": "LESS_OR_EQUAL",
                                                "severity": "MAJOR",
                                                "closedLoopEventStatus": "ONSET"
                                            }
                                        ]
                                    }
                                ]
                            }
                        }
                    }
                }
            ]
        }
        
        return self.policy_client.create_policy(policy_data)
    
    def create_guard_policy(self) -> bool:
        """Create guard policy for scaling limits"""
        policy_data = {
            "tosca_definitions_version": "tosca_simple_yaml_1_1",
            "policies": [
                {
                    "vFirewall.GuardPolicy": {
                        "type": "onap.policies.controlloop.guard.common.FrequencyLimiter",
                        "version": "1.0.0",
                        "properties": {
                            "actor": "SO",
                            "recipe": "scaleOut",
                            "targets": ".*",
                            "clname": "vFirewall.AutoScaling",
                            "limit": 5,
                            "timeWindow": 10,
                            "timeUnits": "minute"
                        }
                    }
                }
            ]
        }
        
        return self.policy_client.create_policy(policy_data)
    
    def deploy_all_policies(self) -> bool:
        """Deploy all policies"""
        logger.info("Creating vFirewall scaling policy...")
        if not self.create_scaling_policy():
            logger.error("Failed to create scaling policy")
            return False
        
        logger.info("Creating monitoring policy...")
        if not self.create_monitoring_policy():
            logger.error("Failed to create monitoring policy")
            return False
        
        logger.info("Creating guard policy...")
        if not self.create_guard_policy():
            logger.error("Failed to create guard policy")
            return False
        
        logger.info("All policies created successfully")
        return True


def main():
    """Main policy automation function"""
    print("🛡️  ONAP Policy Automation")
    print("=" * 30)
    
    automation = PolicyAutomation("http://localhost")
    
    try:
        if automation.deploy_all_policies():
            print("✅ All policies deployed successfully!")
            print("\nPolicies created:")
            print("- vFirewall Auto-scaling Policy")
            print("- Performance Monitoring Policy")
            print("- Scaling Guard Policy")
            print("\nAccess Policy GUI: http://localhost:30219/onap/policy/gui/")
        else:
            print("❌ Policy deployment failed!")
            
    except Exception as e:
        logger.error(f"Policy automation error: {e}")
        print(f"❌ Error: {e}")


if __name__ == "__main__":
    main()
EOF

echo -e "${GREEN}✅ Python automation scripts created${NC}"

# Phase 7: Monitoring and Observability Setup
echo -e "\n${PURPLE}📊 Phase 7: Monitoring and Observability${NC}"

echo -e "${YELLOW}🔍 Setting up monitoring stack...${NC}"

# Deploy Prometheus for metrics collection
cat > configs/prometheus-values.yaml << 'EOF'
server:
  service:
    type: NodePort
    nodePort: 30900
  persistentVolume:
    enabled: true
    size: 10Gi
  retention: "15d"

alertmanager:
  service:
    type: NodePort
    nodePort: 30901
  persistentVolume:
    enabled: true
    size: 2Gi

serverFiles:
  prometheus.yml:
    global:
      scrape_interval: 30s
      evaluation_interval: 30s
    
    scrape_configs:
      - job_name: 'onap-components'
        kubernetes_sd_configs:
          - role: endpoints
            namespaces:
              names:
                - onap
        relabel_configs:
          - source_labels: [__meta_kubernetes_service_name]
            action: keep
            regex: '.*-metrics'
EOF

helm upgrade --install prometheus prometheus-community/prometheus -n monitoring --create-namespace -f configs/prometheus-values.yaml

# Deploy Grafana for visualization
cat > configs/grafana-values.yaml << 'EOF'
service:
  type: NodePort
  nodePort: 30300

admin:
  existingSecret: ""
  userKey: admin-user
  passwordKey: admin-password

adminPassword: "admin123"

persistence:
  enabled: true
  size: 10Gi

datasources:
  datasources.yaml:
    apiVersion: 1
    datasources:
    - name: Prometheus
      type: prometheus
      url: http://prometheus-server:80
      access: proxy
      isDefault: true

dashboardProviders:
  dashboardproviders.yaml:
    apiVersion: 1
    providers:
    - name: 'onap-dashboards'
      orgId: 1
      folder: 'ONAP'
      type: file
      disableDeletion: false
      updateIntervalSeconds: 10
      options:
        path: /var/lib/grafana/dashboards/onap
EOF

helm upgrade --install grafana grafana/grafana -n monitoring -f configs/grafana-values.yaml

# Create ONAP monitoring dashboard
cat > monitoring-dashboards/onap-overview.json << 'EOF'
{
  "dashboard": {
    "id": null,
    "title": "ONAP Platform Overview",
    "tags": ["onap", "overview"],
    "style": "dark",
    "timezone": "browser",
    "panels": [
      {
        "id": 1,
        "title": "ONAP Component Health",
        "type": "stat",
        "targets": [
          {
            "expr": "up{job=\"onap-components\"}",
            "legendFormat": "{{service}}"
          }
        ],
        "fieldConfig": {
          "defaults": {
            "color": {
              "mode": "thresholds"
            },
            "thresholds": {
              "steps": [
                {"color": "red", "value": 0},
                {"color": "green", "value": 1}
              ]
            }
          }
        },
        "gridPos": {"h": 8, "w": 12, "x": 0, "y": 0}
      },
      {
        "id": 2,
        "title": "Service Instantiation Rate",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(onap_so_service_instantiations_total[5m])",
            "legendFormat": "Instantiations/min"
          }
        ],
        "gridPos": {"h": 8, "w": 12, "x": 12, "y": 0}
      }
    ],
    "time": {"from": "now-1h", "to": "now"},
    "refresh": "30s"
  }
}
EOF

echo -e "${GREEN}✅ Monitoring setup completed${NC}"

# Phase 8: Integration Adapters
echo -e "\n${PURPLE}🔌 Phase 8: Integration Adapters${NC}"

cat > integration-adapters/legacy_vnfm_adapter.py << 'EOF'
#!/usr/bin/env python3
"""
Legacy VNFM Integration Adapter - Tutorial 05
Adapter for integrating with existing VNF Managers
"""

import logging
import requests
from typing import Dict, Any, Optional
import json
from abc import ABC, abstractmethod

logger = logging.getLogger(__name__)


class VNFMAdapter(ABC):
    """Abstract base class for VNFM adapters"""
    
    @abstractmethod
    def instantiate_vnf(self, vnf_data: Dict[str, Any]) -> Optional[str]:
        """Instantiate VNF"""
        pass
    
    @abstractmethod
    def terminate_vnf(self, vnf_instance_id: str) -> bool:
        """Terminate VNF"""
        pass
    
    @abstractmethod
    def get_vnf_status(self, vnf_instance_id: str) -> Optional[Dict[str, Any]]:
        """Get VNF status"""
        pass


class OpenStackVNFMAdapter(VNFMAdapter):
    """OpenStack-based VNFM adapter"""
    
    def __init__(self, endpoint: str, auth_data: Dict[str, str]):
        self.endpoint = endpoint
        self.auth_data = auth_data
        self.session = requests.Session()
        self.token = None
        self._authenticate()
    
    def _authenticate(self):
        """Authenticate with OpenStack"""
        auth_url = f"{self.endpoint}/identity/v3/auth/tokens"
        auth_payload = {
            "auth": {
                "identity": {
                    "methods": ["password"],
                    "password": {
                        "user": {
                            "name": self.auth_data['username'],
                            "domain": {"name": "default"},
                            "password": self.auth_data['password']
                        }
                    }
                },
                "scope": {
                    "project": {
                        "name": self.auth_data['project'],
                        "domain": {"name": "default"}
                    }
                }
            }
        }
        
        response = self.session.post(auth_url, json=auth_payload)
        if response.status_code == 201:
            self.token = response.headers.get('X-Subject-Token')
            self.session.headers.update({'X-Auth-Token': self.token})
            logger.info("Successfully authenticated with OpenStack")
        else:
            logger.error(f"Authentication failed: {response.status_code}")
    
    def instantiate_vnf(self, vnf_data: Dict[str, Any]) -> Optional[str]:
        """Instantiate VNF using Heat templates"""
        try:
            heat_url = f"{self.endpoint}/orchestration/v1/{self.auth_data['project']}/stacks"
            
            stack_data = {
                "stack_name": vnf_data['name'],
                "template": vnf_data['heat_template'],
                "parameters": vnf_data.get('parameters', {}),
                "timeout_mins": 60
            }
            
            response = self.session.post(heat_url, json=stack_data)
            
            if response.status_code == 201:
                result = response.json()
                stack_id = result['stack']['id']
                logger.info(f"VNF instantiation started: {stack_id}")
                return stack_id
            else:
                logger.error(f"VNF instantiation failed: {response.status_code}")
                return None
                
        except Exception as e:
            logger.error(f"Error instantiating VNF: {e}")
            return None
    
    def terminate_vnf(self, vnf_instance_id: str) -> bool:
        """Terminate VNF by deleting Heat stack"""
        try:
            heat_url = f"{self.endpoint}/orchestration/v1/{self.auth_data['project']}/stacks/{vnf_instance_id}"
            response = self.session.delete(heat_url)
            
            if response.status_code == 204:
                logger.info(f"VNF termination started: {vnf_instance_id}")
                return True
            else:
                logger.error(f"VNF termination failed: {response.status_code}")
                return False
                
        except Exception as e:
            logger.error(f"Error terminating VNF: {e}")
            return False
    
    def get_vnf_status(self, vnf_instance_id: str) -> Optional[Dict[str, Any]]:
        """Get VNF status from Heat stack"""
        try:
            heat_url = f"{self.endpoint}/orchestration/v1/{self.auth_data['project']}/stacks/{vnf_instance_id}"
            response = self.session.get(heat_url)
            
            if response.status_code == 200:
                return response.json()
            else:
                logger.error(f"Failed to get VNF status: {response.status_code}")
                return None
                
        except Exception as e:
            logger.error(f"Error getting VNF status: {e}")
            return None


class KubernetesVNFMAdapter(VNFMAdapter):
    """Kubernetes-based CNF adapter"""
    
    def __init__(self, kubeconfig_path: str = None):
        try:
            from kubernetes import client, config
            
            if kubeconfig_path:
                config.load_kube_config(config_file=kubeconfig_path)
            else:
                config.load_incluster_config()
            
            self.k8s_apps = client.AppsV1Api()
            self.k8s_core = client.CoreV1Api()
            logger.info("Kubernetes VNFM adapter initialized")
            
        except Exception as e:
            logger.error(f"Failed to initialize Kubernetes adapter: {e}")
            raise
    
    def instantiate_vnf(self, vnf_data: Dict[str, Any]) -> Optional[str]:
        """Deploy CNF as Kubernetes deployment"""
        try:
            deployment_manifest = {
                "apiVersion": "apps/v1",
                "kind": "Deployment",
                "metadata": {
                    "name": vnf_data['name'],
                    "namespace": vnf_data.get('namespace', 'default')
                },
                "spec": {
                    "replicas": vnf_data.get('replicas', 1),
                    "selector": {
                        "matchLabels": {
                            "app": vnf_data['name']
                        }
                    },
                    "template": {
                        "metadata": {
                            "labels": {
                                "app": vnf_data['name']
                            }
                        },
                        "spec": {
                            "containers": [{
                                "name": vnf_data['name'],
                                "image": vnf_data['image'],
                                "ports": vnf_data.get('ports', []),
                                "env": vnf_data.get('env', [])
                            }]
                        }
                    }
                }
            }
            
            namespace = vnf_data.get('namespace', 'default')
            response = self.k8s_apps.create_namespaced_deployment(
                namespace=namespace,
                body=deployment_manifest
            )
            
            logger.info(f"CNF deployed: {response.metadata.name}")
            return response.metadata.uid
            
        except Exception as e:
            logger.error(f"Error deploying CNF: {e}")
            return None
    
    def terminate_vnf(self, vnf_instance_id: str) -> bool:
        """Delete CNF deployment"""
        # Implementation would require mapping instance ID to deployment name
        # This is simplified for tutorial purposes
        logger.info(f"CNF termination requested: {vnf_instance_id}")
        return True
    
    def get_vnf_status(self, vnf_instance_id: str) -> Optional[Dict[str, Any]]:
        """Get CNF deployment status"""
        # Implementation would require mapping instance ID to deployment
        # This is simplified for tutorial purposes
        return {"status": "ACTIVE", "instance_id": vnf_instance_id}


def main():
    """Test VNFM adapters"""
    print("🔌 VNFM Integration Adapter Test")
    print("=" * 35)
    
    # Test Kubernetes adapter
    try:
        k8s_adapter = KubernetesVNFMAdapter()
        
        cnf_data = {
            "name": "test-cnf",
            "image": "nginx:latest",
            "replicas": 1,
            "namespace": "default"
        }
        
        instance_id = k8s_adapter.instantiate_vnf(cnf_data)
        if instance_id:
            print(f"✅ CNF deployed with ID: {instance_id}")
            
            status = k8s_adapter.get_vnf_status(instance_id)
            print(f"📊 CNF Status: {status}")
        
    except Exception as e:
        print(f"❌ Kubernetes adapter test failed: {e}")


if __name__ == "__main__":
    main()
EOF

echo -e "${GREEN}✅ Integration adapters created${NC}"

# Create initialization script
cat > scripts/init_onap.sh << 'EOF'
#!/bin/bash
# ONAP Initialization Script

set -e

echo "🚀 Initializing ONAP platform..."

# Wait for core components to be ready
kubectl wait --for=condition=ready pod -l app=cassandra -n onap --timeout=300s
kubectl wait --for=condition=ready pod -l app=mariadb -n onap --timeout=300s

# Initialize ONAP databases
kubectl exec -it -n onap $(kubectl get pods -n onap -l app=cassandra -o jsonpath='{.items[0].metadata.name}') -- cqlsh -e "
CREATE KEYSPACE IF NOT EXISTS onap WITH REPLICATION = {'class': 'SimpleStrategy', 'replication_factor': 1};
USE onap;
CREATE TABLE IF NOT EXISTS services (id UUID PRIMARY KEY, name TEXT, status TEXT, created TIMESTAMP);
"

echo "✅ ONAP platform initialized"
EOF

chmod +x scripts/init_onap.sh

# Create final setup script
cat > scripts/verify_setup.py << 'EOF'
#!/usr/bin/env python3
"""Setup verification script"""

import subprocess
import sys
import time

def check_kubernetes():
    """Check Kubernetes cluster"""
    try:
        result = subprocess.run(['kubectl', 'cluster-info'], 
                              capture_output=True, text=True, timeout=10)
        return result.returncode == 0
    except:
        return False

def check_onap_pods():
    """Check ONAP pods"""
    try:
        result = subprocess.run(['kubectl', 'get', 'pods', '-n', 'onap'], 
                              capture_output=True, text=True, timeout=10)
        if result.returncode == 0:
            lines = result.stdout.strip().split('\n')[1:]  # Skip header
            total_pods = len(lines)
            running_pods = sum(1 for line in lines if 'Running' in line)
            return total_pods, running_pods
        return 0, 0
    except:
        return 0, 0

def main():
    print("🔍 Verifying ONAP setup...")
    
    if not check_kubernetes():
        print("❌ Kubernetes cluster not accessible")
        sys.exit(1)
    
    print("✅ Kubernetes cluster accessible")
    
    total_pods, running_pods = check_onap_pods()
    print(f"📊 ONAP Pods: {running_pods}/{total_pods} running")
    
    if running_pods > 0:
        print("✅ ONAP setup verification completed")
        print("\nAccess points:")
        print("- ONAP Portal: http://localhost:30215/ONAPPORTAL/login.htm")
        print("- Grafana: http://localhost:30300 (admin/admin123)")
        print("- Prometheus: http://localhost:30900")
    else:
        print("⚠️  ONAP pods not yet ready. This is normal during initial setup.")

if __name__ == "__main__":
    main()
EOF

chmod +x scripts/verify_setup.py

cd ..

echo -e "\n${BLUE}📊 Setup Summary${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Project structure created${NC}"
echo -e "${GREEN}✅ Python environment configured${NC}"  
echo -e "${GREEN}✅ Kubernetes and Helm repositories added${NC}"
echo -e "${GREEN}✅ Core infrastructure deployed${NC}"
echo -e "${GREEN}✅ Service models and templates created${NC}"
echo -e "${GREEN}✅ Python automation scripts created${NC}"
echo -e "${GREEN}✅ Monitoring stack deployed${NC}"
echo -e "${GREEN}✅ Integration adapters created${NC}"
echo ""
echo -e "${PURPLE}🎯 Next Steps:${NC}"
echo -e "1. Initialize ONAP: ${BLUE}cd $PROJECT_NAME && ./scripts/init_onap.sh${NC}"
echo -e "2. Verify setup: ${BLUE}python3 scripts/verify_setup.py${NC}"
echo -e "3. Deploy vFirewall: ${BLUE}python3 python-automation/deploy_vfirewall.py${NC}"
echo -e "4. Run tests: ${BLUE}./test.sh${NC}"
echo ""
echo -e "${GREEN}🚀 Tutorial 05 setup completed successfully!${NC}"