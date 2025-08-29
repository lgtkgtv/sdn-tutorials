#!/bin/bash
# Tutorial 04 - Cloud-Native Network Functions with Nephio Setup Script
# Sets up Nephio platform and CNF development environment

set -e

# Color codes for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
PURPLE='\033[0;35m'
NC='\033[0m'

# Configuration
PROJECT_NAME="${PROJECT_NAME:-nephio_cnf_workspace}"
NEPHIO_VERSION="${NEPHIO_VERSION:-v1.0.1}"
KUBERNETES_VERSION="${KUBERNETES_VERSION:-1.28.0}"
KIND_VERSION="${KIND_VERSION:-0.20.0}"
KPT_VERSION="${KPT_VERSION:-1.0.0-beta.17}"
VENV_NAME="${VENV_NAME:-venv}"

echo -e "${BLUE}🚀 Starting Tutorial 04: Cloud-Native Network Functions with Nephio Setup${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "📦 Project name: ${PURPLE}$PROJECT_NAME${NC}"
echo -e "☸️  Nephio version: ${PURPLE}$NEPHIO_VERSION${NC}"
echo -e "🎛️  Kubernetes version: ${PURPLE}$KUBERNETES_VERSION${NC}"
echo -e "🔧 kpt version: ${PURPLE}$KPT_VERSION${NC}"
echo ""

# Create project directory
PROJECT_DIR="$(pwd)/$PROJECT_NAME"
if [ -d "$PROJECT_DIR" ]; then
    echo -e "${YELLOW}⚠️  Project directory already exists at $PROJECT_DIR${NC}"
    read -p "Do you want to remove it and start fresh? [y/N]: " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf "$PROJECT_DIR"
    else
        echo -e "${RED}❌ Setup cancelled${NC}"
        exit 1
    fi
fi

echo "📁 Creating project at: $PROJECT_DIR"
mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR"

# Check system dependencies
echo -e "\n${BLUE}📦 Checking system dependencies...${NC}"

check_command() {
    if command -v "$1" >/dev/null 2>&1; then
        echo -e "${GREEN}✅ $1 is installed${NC}"
        return 0
    else
        echo -e "${RED}❌ $1 is not installed${NC}"
        return 1
    fi
}

# System packages check
MISSING_PACKAGES=()
command -v python3 >/dev/null || MISSING_PACKAGES+=(python3)
command -v pip3 >/dev/null || MISSING_PACKAGES+=(python3-pip)
dpkg -l | grep -q python3-venv || MISSING_PACKAGES+=(python3-venv)
command -v git >/dev/null || MISSING_PACKAGES+=(git)
command -v curl >/dev/null || MISSING_PACKAGES+=(curl)
command -v wget >/dev/null || MISSING_PACKAGES+=(wget)
command -v unzip >/dev/null || MISSING_PACKAGES+=(unzip)
command -v jq >/dev/null || MISSING_PACKAGES+=(jq)

if [ ${#MISSING_PACKAGES[@]} -gt 0 ]; then
    echo -e "${YELLOW}📦 Some packages are missing: ${MISSING_PACKAGES[*]}${NC}"
    echo -e "Please install them using: ${BLUE}sudo apt-get install ${MISSING_PACKAGES[*]}${NC}"
    echo -e "Continuing with available tools..."
fi

# Install Docker (if not present and user has sudo access)
if ! command -v docker &> /dev/null; then
    echo -e "${YELLOW}🐳 Docker not found. Please install Docker to run Kubernetes clusters${NC}"
    echo -e "Installation guide: ${BLUE}https://docs.docker.com/engine/install/${NC}"
fi

# Install kubectl (if not present)
if ! command -v kubectl &> /dev/null; then
    echo -e "${BLUE}☸️  Installing kubectl...${NC}"
    KUBECTL_URL="https://dl.k8s.io/release/v${KUBERNETES_VERSION}/bin/linux/amd64/kubectl"
    mkdir -p bin
    curl -L "$KUBECTL_URL" -o bin/kubectl
    chmod +x bin/kubectl
    export PATH="$(pwd)/bin:$PATH"
    echo "export PATH=\"$(pwd)/bin:\$PATH\"" >> activate.sh
    echo -e "${GREEN}✅ kubectl installed locally${NC}"
else
    echo -e "${GREEN}✅ kubectl is available${NC}"
fi

# Install kind (if not present)
if ! command -v kind &> /dev/null; then
    echo -e "${BLUE}🎪 Installing kind...${NC}"
    mkdir -p bin
    if [ $(uname -m) = "x86_64" ]; then
        curl -Lo bin/kind https://kind.sigs.k8s.io/dl/v${KIND_VERSION}/kind-linux-amd64
    elif [ $(uname -m) = "aarch64" ]; then
        curl -Lo bin/kind https://kind.sigs.k8s.io/dl/v${KIND_VERSION}/kind-linux-arm64
    fi
    chmod +x bin/kind
    export PATH="$(pwd)/bin:$PATH"
    echo -e "${GREEN}✅ kind installed locally${NC}"
else
    echo -e "${GREEN}✅ kind is available${NC}"
fi

# Install kpt (Kubernetes package management tool)
if ! command -v kpt &> /dev/null; then
    echo -e "${BLUE}📦 Installing kpt...${NC}"
    mkdir -p bin
    KPT_URL="https://github.com/GoogleContainerTools/kpt/releases/download/v${KPT_VERSION}/kpt_linux_amd64"
    curl -L "$KPT_URL" -o bin/kpt
    chmod +x bin/kpt
    export PATH="$(pwd)/bin:$PATH"
    echo -e "${GREEN}✅ kpt installed locally${NC}"
else
    echo -e "${GREEN}✅ kpt is available${NC}"
fi

# Create Python virtual environment
echo -e "\n${BLUE}🐍 Setting up Python virtual environment...${NC}"
if [ ! -d "$VENV_NAME" ]; then
    python3 -m venv "$VENV_NAME"
fi

# Activate virtual environment
source "$VENV_NAME/bin/activate"

# Create requirements.txt for CNF development
echo -e "${BLUE}📚 Creating requirements.txt...${NC}"
cat > requirements.txt << 'EOF'
# Kubernetes and Cloud-Native Development
kubernetes>=27.2.0
pyyaml>=6.0
jinja2>=3.1.0
jsonschema>=4.17.0

# Nephio and CNF Management
kpt-functions>=0.1.0
git-python>=1.0.3

# Network Function Development
flask>=2.3.0
flask-restx>=1.1.0
celery>=5.3.0
redis>=4.5.0

# Service Mesh and Observability
istio-client>=0.1.0
prometheus-client>=0.17.0
jaeger-client>=4.8.0
opentelemetry-api>=1.20.0
opentelemetry-sdk>=1.20.0

# Testing and Quality
pytest>=7.0.0
pytest-cov>=4.0.0
pytest-asyncio>=0.21.0
pytest-kubernetes>=1.1.0
pytest-bdd>=6.1.0

# Code Quality and Security
bandit[toml]>=1.7.0
safety>=2.3.0
black>=23.0.0
flake8>=6.0.0
isort>=5.12.0
mypy>=1.5.0

# Network and Telco Utilities
scapy>=2.5.0
dpkt>=1.9.8
netaddr>=0.8.0
pyroute2>=0.7.0

# Data Processing and Analytics
pandas>=2.0.0
numpy>=1.24.0
matplotlib>=3.7.0
pydantic>=2.0.0
EOF

# Install Python dependencies
echo -e "${BLUE}📦 Installing Python dependencies...${NC}"
pip install --upgrade pip setuptools wheel
pip install -r requirements.txt

# Create Nephio platform directory structure
echo -e "\n${BLUE}☸️  Setting up Nephio platform structure...${NC}"

# Create management cluster configuration
mkdir -p nephio/management-cluster
cat > nephio/management-cluster/cluster-config.yaml << 'EOF'
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: nephio-management
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "nephio.org/cluster-role=management"
  extraPortMappings:
  - containerPort: 30080
    hostPort: 8080
    protocol: TCP
  - containerPort: 30443
    hostPort: 8443
    protocol: TCP
- role: worker
  labels:
    nephio.org/node-type: workload
networking:
  apiServerAddress: "127.0.0.1"
  apiServerPort: 6443
  podSubnet: "10.244.0.0/16"
  serviceSubnet: "10.96.0.0/12"
EOF

# Create workload cluster configurations
mkdir -p nephio/workload-clusters
cat > nephio/workload-clusters/edge-cluster.yaml << 'EOF'
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: edge-cluster-01
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "nephio.org/cluster-role=edge,nephio.org/location=edge-site-1"
- role: worker
  labels:
    nephio.org/node-type: cnf-workload
    nephio.org/capabilities: low-latency,sr-iov
networking:
  podSubnet: "10.245.0.0/16"
  serviceSubnet: "10.97.0.0/12"
EOF

# Create CNF package directory structure
echo -e "${BLUE}📦 Creating CNF package structure...${NC}"
mkdir -p cnf-packages/5g-core/{amf,smf,upf}
mkdir -p cnf-packages/broadband/{vbng,vcpe}
mkdir -p cnf-packages/observability/{monitoring,logging}

# Create 5G AMF CNF package
cat > cnf-packages/5g-core/amf/kptfile << 'EOF'
apiVersion: kpt.dev/v1
kind: Kptfile
metadata:
  name: 5g-amf-cnf
  annotations:
    config.kubernetes.io/local-config: "true"
info:
  description: 5G Access and Mobility Management Function (AMF) CNF
  keywords:
  - 5g
  - core
  - amf
  - cnf
  site: https://nephio.org
upstream:
  type: git
  git:
    repo: https://github.com/nephio-project/cnf-packages
    directory: /5g-core/amf
    ref: main
  updateStrategy: resource-merge
pipeline:
  mutators:
  - image: gcr.io/kpt-fn/apply-replacements:v0.1.1
    configPath: replacements.yaml
  validators:
  - image: gcr.io/kpt-fn/kubeval:v0.3.0
EOF

# Create AMF deployment manifest
cat > cnf-packages/5g-core/amf/deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: amf-cnf
  labels:
    cnf.nephio.org/type: 5g-core
    cnf.nephio.org/function: amf
    app.kubernetes.io/name: amf
    app.kubernetes.io/component: 5g-core
spec:
  replicas: 2
  selector:
    matchLabels:
      app: amf
      cnf.nephio.org/function: amf
  template:
    metadata:
      labels:
        app: amf
        cnf.nephio.org/function: amf
        cnf.nephio.org/type: 5g-core
    spec:
      containers:
      - name: amf
        image: nephio.io/5g-core/amf:v1.4.0
        ports:
        - containerPort: 8080
          name: sbi
          protocol: TCP
        - containerPort: 38412
          name: n2-interface
          protocol: SCTP
        env:
        - name: AMF_CONFIG_PATH
          value: "/etc/amf/config.yaml"
        - name: LOG_LEVEL
          value: "INFO"
        volumeMounts:
        - name: config
          mountPath: /etc/amf
        - name: certs
          mountPath: /etc/ssl/certs
        resources:
          requests:
            memory: "512Mi"
            cpu: "250m"
          limits:
            memory: "1Gi"  
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /ready
            port: 8080
          initialDelaySeconds: 10
          periodSeconds: 5
      volumes:
      - name: config
        configMap:
          name: amf-config
      - name: certs
        secret:
          secretName: amf-certs
      nodeSelector:
        nephio.org/node-type: cnf-workload
      tolerations:
      - key: "cnf-workload"
        operator: "Equal"
        value: "true"
        effect: "NoSchedule"
EOF

# Create AMF service
cat > cnf-packages/5g-core/amf/service.yaml << 'EOF'
apiVersion: v1
kind: Service
metadata:
  name: amf-service
  labels:
    cnf.nephio.org/function: amf
    app.kubernetes.io/name: amf
spec:
  type: ClusterIP
  ports:
  - name: sbi
    port: 8080
    targetPort: 8080
    protocol: TCP
  - name: n2
    port: 38412
    targetPort: 38412
    protocol: SCTP
  selector:
    app: amf
    cnf.nephio.org/function: amf
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: amf-config
data:
  config.yaml: |
    amf:
      sbi:
        scheme: https
        registerIPv4: amf-service
        bindingIPv4: 0.0.0.0
        port: 8080
      serviceNameList:
        - namf-comm
        - namf-evts
        - namf-mt
        - namf-loc
        - namf-oam
      servedGuamiList:
        - plmnId:
            mcc: 208
            mnc: 93
          amfId: cafe00
      supportTaiList:
        - plmnId:
            mcc: 208
            mnc: 93
          tac: 1
      plmnSupportList:
        - plmnId:
            mcc: 208
            mnc: 93
          snssaiList:
            - sst: 1
              sd: "010203"
            - sst: 1
              sd: "112233"
EOF

# Create GitOps repository structure
echo -e "${BLUE}📋 Creating GitOps repository structure...${NC}"
mkdir -p gitops-repos/{cluster-configs,network-functions,policies}

# Create cluster configuration
cat > gitops-repos/cluster-configs/management-cluster.yaml << 'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: cluster-config
  namespace: nephio-system
data:
  cluster.yaml: |
    apiVersion: infra.nephio.org/v1alpha1
    kind: WorkloadCluster
    metadata:
      name: nephio-management
    spec:
      clusterName: nephio-management
      cni: kindnet
      masterIPs:
      - 172.18.0.2
      provider: kind
EOF

# Create Python CNF operators
echo -e "${BLUE}🐍 Creating Python CNF operators...${NC}"
mkdir -p python-operators/{cnf-lifecycle,network-topology,intent-engine}

# CNF Lifecycle Operator
cat > python-operators/cnf-lifecycle/cnf_operator.py << 'EOF'
#!/usr/bin/env python3
"""
CNF Lifecycle Management Operator
Manages the lifecycle of Cloud-Native Network Functions
"""

import asyncio
import logging
from typing import Dict, Any, Optional
from kubernetes import client, config, watch
from kubernetes.client import ApiException
import kopf
import yaml

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Load Kubernetes configuration
try:
    config.load_incluster_config()
except config.ConfigException:
    config.load_kube_config()

v1 = client.CoreV1Api()
apps_v1 = client.AppsV1Api()
custom_api = client.CustomObjectsApi()

@kopf.on.create('cnf.nephio.org', 'v1alpha1', 'cnfdeployments')
async def create_cnf_deployment(body, spec, meta, **kwargs):
    """Handle CNF deployment creation"""
    name = meta['name']
    namespace = meta['namespace']
    
    logger.info(f"Creating CNF deployment: {name} in namespace {namespace}")
    
    try:
        # Extract CNF specification
        cnf_type = spec.get('cnfType')
        cnf_version = spec.get('version', 'latest')
        placement = spec.get('placement', {})
        resources = spec.get('resources', {})
        
        # Create deployment based on CNF type
        deployment = create_cnf_deployment_manifest(
            name=name,
            namespace=namespace,
            cnf_type=cnf_type,
            version=cnf_version,
            placement=placement,
            resources=resources
        )
        
        # Apply deployment
        apps_v1.create_namespaced_deployment(
            namespace=namespace,
            body=deployment
        )
        
        # Create service
        service = create_cnf_service_manifest(
            name=name,
            namespace=namespace,
            cnf_type=cnf_type
        )
        
        v1.create_namespaced_service(
            namespace=namespace,
            body=service
        )
        
        # Update CNF status
        await update_cnf_status(name, namespace, 'Deployed')
        
        logger.info(f"Successfully created CNF deployment: {name}")
        
    except ApiException as e:
        logger.error(f"Failed to create CNF deployment {name}: {e}")
        await update_cnf_status(name, namespace, 'Failed', str(e))
        raise kopf.PermanentError(f"Failed to create CNF: {e}")

@kopf.on.update('cnf.nephio.org', 'v1alpha1', 'cnfdeployments')
async def update_cnf_deployment(body, spec, meta, old, new, diff, **kwargs):
    """Handle CNF deployment updates"""
    name = meta['name']
    namespace = meta['namespace']
    
    logger.info(f"Updating CNF deployment: {name}")
    
    try:
        # Handle scaling
        old_replicas = old.get('spec', {}).get('replicas', 1)
        new_replicas = new.get('spec', {}).get('replicas', 1)
        
        if old_replicas != new_replicas:
            logger.info(f"Scaling CNF {name} from {old_replicas} to {new_replicas}")
            
            # Update deployment replicas
            deployment = apps_v1.read_namespaced_deployment(
                name=f"{name}-deployment",
                namespace=namespace
            )
            deployment.spec.replicas = new_replicas
            
            apps_v1.patch_namespaced_deployment(
                name=f"{name}-deployment",
                namespace=namespace,
                body=deployment
            )
            
            await update_cnf_status(name, namespace, 'Scaling')
        
        # Handle configuration updates
        old_config = old.get('spec', {}).get('configuration', {})
        new_config = new.get('spec', {}).get('configuration', {})
        
        if old_config != new_config:
            logger.info(f"Updating CNF {name} configuration")
            await update_cnf_configuration(name, namespace, new_config)
        
        await update_cnf_status(name, namespace, 'Updated')
        
    except ApiException as e:
        logger.error(f"Failed to update CNF deployment {name}: {e}")
        raise kopf.TemporaryError(f"Update failed: {e}", delay=30)

@kopf.on.delete('cnf.nephio.org', 'v1alpha1', 'cnfdeployments')
async def delete_cnf_deployment(body, spec, meta, **kwargs):
    """Handle CNF deployment deletion"""
    name = meta['name']
    namespace = meta['namespace']
    
    logger.info(f"Deleting CNF deployment: {name}")
    
    try:
        # Delete deployment
        apps_v1.delete_namespaced_deployment(
            name=f"{name}-deployment",
            namespace=namespace
        )
        
        # Delete service
        v1.delete_namespaced_service(
            name=f"{name}-service",
            namespace=namespace
        )
        
        logger.info(f"Successfully deleted CNF deployment: {name}")
        
    except ApiException as e:
        if e.status != 404:  # Ignore not found errors
            logger.error(f"Failed to delete CNF deployment {name}: {e}")
            raise kopf.TemporaryError(f"Deletion failed: {e}", delay=10)

def create_cnf_deployment_manifest(name: str, namespace: str, 
                                 cnf_type: str, version: str,
                                 placement: Dict, resources: Dict) -> client.V1Deployment:
    """Create Kubernetes deployment manifest for CNF"""
    
    # CNF image mapping
    cnf_images = {
        'amf': f'nephio.io/5g-core/amf:{version}',
        'smf': f'nephio.io/5g-core/smf:{version}',
        'upf': f'nephio.io/5g-core/upf:{version}',
        'vbng': f'nephio.io/broadband/vbng:{version}',
        'vcpe': f'nephio.io/broadband/vcpe:{version}'
    }
    
    image = cnf_images.get(cnf_type, f'nephio.io/{cnf_type}:{version}')
    
    # Container configuration
    container = client.V1Container(
        name=cnf_type,
        image=image,
        ports=[client.V1ContainerPort(container_port=8080)],
        resources=client.V1ResourceRequirements(
            requests=resources.get('requests', {'cpu': '250m', 'memory': '512Mi'}),
            limits=resources.get('limits', {'cpu': '500m', 'memory': '1Gi'})
        ),
        env=[
            client.V1EnvVar(name='CNF_TYPE', value=cnf_type),
            client.V1EnvVar(name='LOG_LEVEL', value='INFO')
        ]
    )
    
    # Pod template
    pod_template = client.V1PodTemplateSpec(
        metadata=client.V1ObjectMeta(
            labels={'app': name, 'cnf-type': cnf_type}
        ),
        spec=client.V1PodSpec(
            containers=[container],
            node_selector=placement.get('nodeSelector', {}),
            tolerations=[
                client.V1Toleration(
                    key='cnf-workload',
                    operator='Equal',
                    value='true',
                    effect='NoSchedule'
                )
            ]
        )
    )
    
    # Deployment
    deployment = client.V1Deployment(
        api_version='apps/v1',
        kind='Deployment',
        metadata=client.V1ObjectMeta(
            name=f'{name}-deployment',
            namespace=namespace,
            labels={'app': name, 'cnf-type': cnf_type}
        ),
        spec=client.V1DeploymentSpec(
            replicas=placement.get('replicas', 1),
            selector=client.V1LabelSelector(
                match_labels={'app': name}
            ),
            template=pod_template
        )
    )
    
    return deployment

def create_cnf_service_manifest(name: str, namespace: str, 
                               cnf_type: str) -> client.V1Service:
    """Create Kubernetes service manifest for CNF"""
    
    service = client.V1Service(
        api_version='v1',
        kind='Service',
        metadata=client.V1ObjectMeta(
            name=f'{name}-service',
            namespace=namespace,
            labels={'app': name, 'cnf-type': cnf_type}
        ),
        spec=client.V1ServiceSpec(
            selector={'app': name},
            ports=[
                client.V1ServicePort(
                    port=8080,
                    target_port=8080,
                    name='http'
                )
            ],
            type='ClusterIP'
        )
    )
    
    return service

async def update_cnf_status(name: str, namespace: str, status: str, 
                          message: str = ''):
    """Update CNF deployment status"""
    try:
        # Update status in custom resource
        patch = {
            'status': {
                'phase': status,
                'message': message,
                'lastUpdated': asyncio.get_event_loop().time()
            }
        }
        
        custom_api.patch_namespaced_custom_object_status(
            group='cnf.nephio.org',
            version='v1alpha1',
            namespace=namespace,
            plural='cnfdeployments',
            name=name,
            body=patch
        )
        
    except ApiException as e:
        logger.error(f"Failed to update CNF status: {e}")

async def update_cnf_configuration(name: str, namespace: str, 
                                 configuration: Dict):
    """Update CNF configuration"""
    try:
        # Create or update ConfigMap with new configuration
        config_map = client.V1ConfigMap(
            metadata=client.V1ObjectMeta(
                name=f'{name}-config',
                namespace=namespace
            ),
            data={
                'config.yaml': yaml.dump(configuration)
            }
        )
        
        try:
            v1.replace_namespaced_config_map(
                name=f'{name}-config',
                namespace=namespace,
                body=config_map
            )
        except ApiException as e:
            if e.status == 404:
                v1.create_namespaced_config_map(
                    namespace=namespace,
                    body=config_map
                )
            else:
                raise
        
        # Restart deployment to pick up new configuration
        apps_v1.patch_namespaced_deployment(
            name=f'{name}-deployment',
            namespace=namespace,
            body={
                'spec': {
                    'template': {
                        'metadata': {
                            'annotations': {
                                'kubectl.kubernetes.io/restartedAt': 
                                    asyncio.get_event_loop().time()
                            }
                        }
                    }
                }
            }
        )
        
    except ApiException as e:
        logger.error(f"Failed to update CNF configuration: {e}")
        raise

if __name__ == '__main__':
    logger.info("Starting CNF Lifecycle Operator")
    kopf.run()
EOF

# Create utility scripts
echo -e "${BLUE}🛠️  Creating utility scripts...${NC}"
mkdir -p scripts

# Nephio initialization script
cat > scripts/init_nephio.sh << 'EOF'
#!/bin/bash
# Initialize Nephio Management Platform

set -e

echo "🚀 Initializing Nephio Management Platform..."

# Create management cluster
if ! kind get clusters | grep -q "nephio-management"; then
    echo "📦 Creating management cluster..."
    kind create cluster --config nephio/management-cluster/cluster-config.yaml
    
    # Wait for cluster to be ready
    kubectl wait --for=condition=ready node --all --timeout=300s
    echo "✅ Management cluster ready"
else
    echo "✅ Management cluster already exists"
fi

# Install Nephio components (simulated - would normally use official manifests)
echo "⚙️  Installing Nephio components..."

# Create Nephio namespace
kubectl create namespace nephio-system --dry-run=client -o yaml | kubectl apply -f -

# Create Porch CRDs (simplified version)
kubectl apply -f - << 'YAML'
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: repositories.porch.kpt.dev
spec:
  group: porch.kpt.dev
  versions:
  - name: v1alpha1
    served: true
    storage: true
    schema:
      openAPIV3Schema:
        type: object
        properties:
          spec:
            type: object
            properties:
              git:
                type: object
                properties:
                  repo:
                    type: string
                  branch:
                    type: string
              type:
                type: string
          status:
            type: object
  scope: Namespaced
  names:
    plural: repositories
    singular: repository
    kind: Repository
YAML

# Create CNF deployment CRD
kubectl apply -f - << 'YAML'
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: cnfdeployments.cnf.nephio.org
spec:
  group: cnf.nephio.org
  versions:
  - name: v1alpha1
    served: true
    storage: true
    schema:
      openAPIV3Schema:
        type: object
        properties:
          spec:
            type: object
            properties:
              cnfType:
                type: string
              version:
                type: string
              replicas:
                type: integer
              placement:
                type: object
              resources:
                type: object
              configuration:
                type: object
          status:
            type: object
            properties:
              phase:
                type: string
              message:
                type: string
              lastUpdated:
                type: number
  scope: Namespaced
  names:
    plural: cnfdeployments
    singular: cnfdeployment
    kind: CNFDeployment
YAML

echo "✅ Nephio platform initialized"
echo "🌐 Access cluster: kubectl cluster-info --context kind-nephio-management"
EOF

chmod +x scripts/*.sh

# Create activation script
cat > activate.sh << 'EOF'
#!/bin/bash
# Activate Nephio CNF Development Environment

echo "☸️  Activating Nephio CNF Development Environment"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Activate Python virtual environment
if [ -d "venv" ]; then
    source venv/bin/activate
    echo "✅ Python virtual environment activated"
else
    echo "❌ Virtual environment not found. Run setup.sh first."
    return 1
fi

# Add local bin to PATH
export PATH="$(pwd)/bin:$PATH"

# Set Kubernetes context if management cluster exists
if kind get clusters 2>/dev/null | grep -q "nephio-management"; then
    kubectl config use-context kind-nephio-management
    echo "✅ Switched to nephio-management cluster context"
fi

echo ""
echo "Environment Variables:"
echo "  KUBECONFIG: ${KUBECONFIG:-default}"
echo "  PATH: includes local bin directory"
echo "  VIRTUAL_ENV: $VIRTUAL_ENV"
echo ""

echo "Available Commands:"
echo "  ./scripts/init_nephio.sh        - Initialize Nephio platform"
echo "  kubectl get cnfdeployments       - List CNF deployments"
echo "  kind get clusters               - List Kubernetes clusters"
echo "  pytest tests/ -v               - Run test suite"
echo ""

echo "🚀 Environment ready for CNF development!"
EOF

chmod +x activate.sh

echo -e "\n${GREEN}✅ Tutorial 04 Setup Complete!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "📁 Project directory: $PROJECT_DIR"
echo "☸️  Nephio platform: Ready for initialization"
echo "📦 CNF packages: 5G core, broadband functions prepared"
echo "🐍 Python operators: CNF lifecycle management ready"
echo "🎛️  GitOps: Repository structure created"
echo ""
echo "🚀 Next Steps:"
echo "  1. cd $PROJECT_NAME"
echo "  2. source activate.sh"
echo "  3. ./scripts/init_nephio.sh"
echo "  4. Run tests: cd .. && ./test.sh"
echo ""
echo "📚 See README.md for detailed tutorial instructions"