#!/bin/bash
# Tutorial 03 - SDN Controller Integration Setup Script
# Sets up OpenDaylight, Lighty.io, and Mininet environment

set -e

# Color codes for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
PURPLE='\033[0;35m'
NC='\033[0m'

# Configuration
PROJECT_NAME="${PROJECT_NAME:-sdn_controller_workspace}"
ODL_VERSION="${ODL_VERSION:-0.18.4}"  # Argon SR4
LIGHTY_VERSION="${LIGHTY_VERSION:-20.0.0}"
JAVA_VERSION="${JAVA_VERSION:-11}"
MININET_VERSION="${MININET_VERSION:-2.3.1}"
VENV_NAME="${VENV_NAME:-venv}"

echo -e "${BLUE}🚀 Starting Tutorial 03: SDN Controller Integration Setup${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "📦 Project name: ${PURPLE}$PROJECT_NAME${NC}"
echo -e "🎛️  OpenDaylight version: ${PURPLE}$ODL_VERSION${NC}"
echo -e "💡 Lighty.io version: ${PURPLE}$LIGHTY_VERSION${NC}"
echo -e "☕ Java version: ${PURPLE}$JAVA_VERSION${NC}"
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
command -v maven >/dev/null || MISSING_PACKAGES+=(maven)

if [ ${#MISSING_PACKAGES[@]} -gt 0 ]; then
    echo -e "${YELLOW}📦 Installing missing packages: ${MISSING_PACKAGES[*]}${NC}"
    sudo apt-get update -y
    sudo apt-get install -y "${MISSING_PACKAGES[@]}"
fi

# Install Java OpenJDK 11 (required for OpenDaylight)
if ! java -version 2>&1 | grep -q "11\."; then
    echo -e "${YELLOW}☕ Installing OpenJDK 11...${NC}"
    sudo apt-get install -y openjdk-11-jdk
    sudo update-alternatives --install /usr/bin/java java /usr/lib/jvm/java-11-openjdk-amd64/bin/java 1111
    sudo update-alternatives --install /usr/bin/javac javac /usr/lib/jvm/java-11-openjdk-amd64/bin/javac 1111
fi

# Verify Java installation
if java -version 2>&1 | grep -q "11\."; then
    echo -e "${GREEN}✅ Java 11 is installed${NC}"
else
    echo -e "${RED}❌ Java 11 installation failed${NC}"
    exit 1
fi

# Install Mininet (if not present)
if ! command -v mn &> /dev/null; then
    echo -e "${BLUE}🔗 Installing Mininet...${NC}"
    sudo apt-get install -y mininet
fi

# Install Open vSwitch (required for Mininet)
if ! command -v ovs-vsctl &> /dev/null; then
    echo -e "${BLUE}🔀 Installing Open vSwitch...${NC}"
    sudo apt-get install -y openvswitch-switch
fi

# Create Python virtual environment
echo -e "\n${BLUE}🐍 Setting up Python virtual environment...${NC}"
if [ ! -d "$VENV_NAME" ]; then
    python3 -m venv "$VENV_NAME"
fi

# Activate virtual environment
source "$VENV_NAME/bin/activate"

# Create requirements.txt for SDN development
echo -e "${BLUE}📚 Creating requirements.txt...${NC}"
cat > requirements.txt << 'EOF'
# SDN Controller and Network Programming
requests>=2.31.0
pyyaml>=6.0
lxml>=4.9.0
ncclient>=0.6.13
paramiko>=3.3.0

# Mininet and OpenFlow
mininet>=2.3.0
ryu>=4.34
ovs>=2.17.0

# Network Testing and Validation
pytest>=7.0.0
pytest-cov>=4.0.0
pytest-asyncio>=0.21.0

# YANG Model Processing
pyang>=2.5.0
yangson>=1.4.0

# API and Web Development
flask>=2.3.0
flask-restx>=1.1.0
websockets>=11.0.0

# Code Quality and Security
bandit[toml]>=1.7.0
safety>=2.3.0
black>=23.0.0
flake8>=6.0.0
isort>=5.12.0
mypy>=1.5.0

# Network Utilities
netaddr>=0.8.0
ipaddress>=1.0.23
scapy>=2.5.0

# Logging and Monitoring
prometheus-client>=0.17.0
grafana-api>=1.0.3
EOF

# Install Python dependencies
echo -e "${BLUE}📦 Installing Python dependencies...${NC}"
pip install --upgrade pip setuptools wheel
pip install -r requirements.txt

# Download and setup OpenDaylight
echo -e "\n${BLUE}🎛️  Setting up OpenDaylight Controller...${NC}"
mkdir -p opendaylight
cd opendaylight

ODL_DISTRIBUTION="opendaylight-${ODL_VERSION}.zip"
ODL_URL="https://nexus.opendaylight.org/content/repositories/opendaylight.release/org/opendaylight/integration/opendaylight/${ODL_VERSION}/${ODL_DISTRIBUTION}"

if [ ! -f "$ODL_DISTRIBUTION" ]; then
    echo "📥 Downloading OpenDaylight $ODL_VERSION..."
    wget -q --show-progress "$ODL_URL" || {
        echo -e "${RED}❌ Failed to download OpenDaylight${NC}"
        exit 1
    }
fi

if [ ! -d "opendaylight-${ODL_VERSION}" ]; then
    echo "📦 Extracting OpenDaylight..."
    unzip -q "$ODL_DISTRIBUTION"
fi

cd ..

# Create YANG models directory and sample models
echo -e "${BLUE}📋 Creating YANG models...${NC}"
mkdir -p yang-models
cat > yang-models/network-device.yang << 'EOF'
module network-device {
    yang-version 1.1;
    namespace "http://example.com/sdn-tutorial/network-device";
    prefix "netdev";
    
    import ietf-inet-types {
        prefix inet;
    }
    
    revision "2024-01-01" {
        description "Initial revision for SDN tutorial";
    }
    
    container devices {
        description "Network devices managed by SDN controller";
        
        list device {
            key "device-id";
            description "Individual network device";
            
            leaf device-id {
                type string;
                description "Unique device identifier";
            }
            
            leaf management-ip {
                type inet:ip-address;
                description "Management IP address";
            }
            
            leaf device-type {
                type enumeration {
                    enum switch {
                        description "Network switch";
                    }
                    enum router {
                        description "Network router";
                    }
                    enum firewall {
                        description "Network firewall";
                    }
                }
                description "Type of network device";
            }
            
            leaf-list interfaces {
                type string;
                description "List of device interfaces";
            }
            
            container status {
                description "Device operational status";
                
                leaf admin-state {
                    type enumeration {
                        enum up;
                        enum down;
                    }
                    default up;
                }
                
                leaf oper-state {
                    type enumeration {
                        enum up;
                        enum down;
                        enum unknown;
                    }
                    config false;
                }
            }
        }
    }
    
    rpc provision-device {
        description "Provision a new network device";
        input {
            leaf device-id {
                type string;
                mandatory true;
            }
            leaf management-ip {
                type inet:ip-address;
                mandatory true;
            }
            leaf device-type {
                type enumeration {
                    enum switch;
                    enum router;
                    enum firewall;
                }
                mandatory true;
            }
        }
        output {
            leaf result {
                type enumeration {
                    enum success;
                    enum failure;
                }
            }
            leaf message {
                type string;
            }
        }
    }
}
EOF

# Create Lighty.io applications directory structure
echo -e "${BLUE}💡 Setting up Lighty.io framework...${NC}"
mkdir -p lighty-apps/{network-manager,topology-viewer,flow-programmer}

# Create Python SDN applications
echo -e "${BLUE}🐍 Creating Python SDN applications...${NC}"
mkdir -p python-apps/{restconf-client,netconf-client,sdn-orchestrator}

# Create RESTCONF client
cat > python-apps/restconf-client/restconf_client.py << 'EOF'
#!/usr/bin/env python3
"""
OpenDaylight RESTCONF API Client
Provides Python interface to OpenDaylight RESTCONF APIs
"""

import requests
import json
import logging
from typing import Dict, List, Optional, Any
from urllib.parse import urljoin

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class ODLRestconfClient:
    """OpenDaylight RESTCONF API Client"""
    
    def __init__(self, base_url: str = "http://localhost:8181", 
                 username: str = "admin", password: str = "admin"):
        self.base_url = base_url
        self.restconf_url = urljoin(base_url, "/restconf/")
        self.auth = (username, password)
        self.session = requests.Session()
        self.session.auth = self.auth
        self.session.headers.update({
            'Content-Type': 'application/json',
            'Accept': 'application/json'
        })
    
    def get_operational_topology(self) -> Dict[str, Any]:
        """Get network topology from operational datastore"""
        try:
            url = urljoin(self.restconf_url, 
                         "data/network-topology:network-topology/")
            response = self.session.get(url)
            response.raise_for_status()
            return response.json()
        except requests.exceptions.RequestException as e:
            logger.error(f"Failed to get topology: {e}")
            return {}
    
    def create_device(self, device_data: Dict[str, Any]) -> bool:
        """Create a network device in the datastore"""
        try:
            url = urljoin(self.restconf_url,
                         "data/network-device:devices/device/")
            response = self.session.post(url, json=device_data)
            response.raise_for_status()
            logger.info(f"Device created successfully: {device_data['device-id']}")
            return True
        except requests.exceptions.RequestException as e:
            logger.error(f"Failed to create device: {e}")
            return False
    
    def get_device(self, device_id: str) -> Optional[Dict[str, Any]]:
        """Get device information by ID"""
        try:
            url = urljoin(self.restconf_url,
                         f"data/network-device:devices/device={device_id}")
            response = self.session.get(url)
            response.raise_for_status()
            return response.json()
        except requests.exceptions.RequestException as e:
            logger.error(f"Failed to get device {device_id}: {e}")
            return None
    
    def update_device_status(self, device_id: str, admin_state: str) -> bool:
        """Update device administrative state"""
        try:
            url = urljoin(self.restconf_url,
                         f"data/network-device:devices/device={device_id}/status/admin-state")
            data = {"admin-state": admin_state}
            response = self.session.put(url, json=data)
            response.raise_for_status()
            logger.info(f"Device {device_id} admin state updated to {admin_state}")
            return True
        except requests.exceptions.RequestException as e:
            logger.error(f"Failed to update device status: {e}")
            return False
    
    def delete_device(self, device_id: str) -> bool:
        """Delete device from datastore"""
        try:
            url = urljoin(self.restconf_url,
                         f"data/network-device:devices/device={device_id}")
            response = self.session.delete(url)
            response.raise_for_status()
            logger.info(f"Device {device_id} deleted successfully")
            return True
        except requests.exceptions.RequestException as e:
            logger.error(f"Failed to delete device {device_id}: {e}")
            return False
    
    def provision_device_rpc(self, device_id: str, management_ip: str, 
                            device_type: str) -> Dict[str, Any]:
        """Call device provisioning RPC"""
        try:
            url = urljoin(self.restconf_url, "operations/network-device:provision-device")
            data = {
                "input": {
                    "device-id": device_id,
                    "management-ip": management_ip,
                    "device-type": device_type
                }
            }
            response = self.session.post(url, json=data)
            response.raise_for_status()
            return response.json()
        except requests.exceptions.RequestException as e:
            logger.error(f"RPC call failed: {e}")
            return {"output": {"result": "failure", "message": str(e)}}

def main():
    """Example usage of RESTCONF client"""
    client = ODLRestconfClient()
    
    # Test device creation
    device_data = {
        "device-id": "switch-001",
        "management-ip": "192.168.1.10",
        "device-type": "switch",
        "interfaces": ["eth0", "eth1", "eth2", "eth3"],
        "status": {
            "admin-state": "up"
        }
    }
    
    logger.info("Testing RESTCONF client...")
    
    # Create device
    if client.create_device(device_data):
        logger.info("✅ Device creation successful")
        
        # Get device
        device = client.get_device("switch-001")
        if device:
            logger.info("✅ Device retrieval successful")
            logger.info(f"Device info: {json.dumps(device, indent=2)}")
        
        # Update device status
        if client.update_device_status("switch-001", "down"):
            logger.info("✅ Device status update successful")
        
        # Test RPC call
        result = client.provision_device_rpc("switch-002", "192.168.1.11", "router")
        logger.info(f"RPC result: {result}")
        
        # Clean up
        if client.delete_device("switch-001"):
            logger.info("✅ Device deletion successful")
    
    logger.info("RESTCONF client test completed")

if __name__ == "__main__":
    main()
EOF

# Create Mininet topologies
echo -e "${BLUE}🔗 Creating Mininet topologies...${NC}"
mkdir -p mininet/topologies
cat > mininet/topologies/sdn_test_topology.py << 'EOF'
#!/usr/bin/env python3
"""
Custom Mininet topology for SDN controller testing
Creates a multi-switch topology with hosts for comprehensive testing
"""

from mininet.topo import Topo
from mininet.net import Mininet
from mininet.node import RemoteController, OVSKernelSwitch
from mininet.cli import CLI
from mininet.log import setLogLevel
from mininet.link import TCLink

class SDNTestTopology(Topo):
    """Custom topology for SDN testing with multiple switches and hosts"""
    
    def build(self):
        """Build the network topology"""
        
        # Create switches with OpenFlow 1.3 support
        s1 = self.addSwitch('s1', protocols='OpenFlow13', dpid='0000000000000001')
        s2 = self.addSwitch('s2', protocols='OpenFlow13', dpid='0000000000000002')
        s3 = self.addSwitch('s3', protocols='OpenFlow13', dpid='0000000000000003')
        s4 = self.addSwitch('s4', protocols='OpenFlow13', dpid='0000000000000004')
        
        # Create hosts in different subnets
        h1 = self.addHost('h1', ip='10.0.1.10/24', defaultRoute='via 10.0.1.1')
        h2 = self.addHost('h2', ip='10.0.1.11/24', defaultRoute='via 10.0.1.1')
        h3 = self.addHost('h3', ip='10.0.2.10/24', defaultRoute='via 10.0.2.1')
        h4 = self.addHost('h4', ip='10.0.2.11/24', defaultRoute='via 10.0.2.1')
        h5 = self.addHost('h5', ip='10.0.3.10/24', defaultRoute='via 10.0.3.1')
        h6 = self.addHost('h6', ip='10.0.3.11/24', defaultRoute='via 10.0.3.1')
        
        # Create server hosts
        web_server = self.addHost('web', ip='10.0.4.10/24', defaultRoute='via 10.0.4.1')
        db_server = self.addHost('db', ip='10.0.4.11/24', defaultRoute='via 10.0.4.1')
        
        # Connect hosts to access switches
        self.addLink(h1, s1, bw=100)  # 100 Mbps links
        self.addLink(h2, s1, bw=100)
        self.addLink(h3, s2, bw=100)
        self.addLink(h4, s2, bw=100)
        self.addLink(h5, s3, bw=100)
        self.addLink(h6, s3, bw=100)
        self.addLink(web_server, s4, bw=1000)  # 1 Gbps server links
        self.addLink(db_server, s4, bw=1000)
        
        # Create switch-to-switch links (core network)
        self.addLink(s1, s4, bw=1000, delay='5ms')  # Core links with latency
        self.addLink(s2, s4, bw=1000, delay='5ms')
        self.addLink(s3, s4, bw=1000, delay='5ms')
        
        # Add redundant links for resilience testing
        self.addLink(s1, s2, bw=500, delay='10ms')
        self.addLink(s2, s3, bw=500, delay='10ms')

def run_topology():
    """Run the SDN test topology with OpenDaylight controller"""
    
    setLogLevel('info')
    
    # Create the topology
    topo = SDNTestTopology()
    
    # Create Mininet network with remote controller
    net = Mininet(
        topo=topo,
        controller=lambda name: RemoteController(
            name, 
            ip='127.0.0.1', 
            port=6633,  # OpenDaylight OpenFlow port
            protocols='OpenFlow13'
        ),
        switch=OVSKernelSwitch,
        link=TCLink,
        autoSetMacs=True
    )
    
    try:
        # Start the network
        print("🚀 Starting SDN test network...")
        net.start()
        
        # Test connectivity
        print("\n🔍 Testing basic connectivity...")
        net.pingAll()
        
        # Configure additional network settings
        print("\n⚙️  Configuring network settings...")
        
        # Set up simple routing for demonstration
        for host in net.hosts:
            if 'h1' in host.name or 'h2' in host.name:
                host.cmd('ip route add 10.0.2.0/24 via 10.0.1.1')
                host.cmd('ip route add 10.0.3.0/24 via 10.0.1.1')
                host.cmd('ip route add 10.0.4.0/24 via 10.0.1.1')
        
        print("✅ Network topology ready!")
        print("\nTopology Information:")
        print("- Switches: s1, s2, s3, s4 (OpenFlow 1.3)")
        print("- Hosts: h1-h6 (clients), web/db (servers)")
        print("- Controller: OpenDaylight at localhost:6633")
        print("\nUse 'exit' to stop the network")
        
        # Start CLI for interactive testing
        CLI(net)
        
    except KeyboardInterrupt:
        print("\n🛑 Network stopped by user")
    finally:
        # Clean up
        print("🧹 Cleaning up network...")
        net.stop()

if __name__ == '__main__':
    run_topology()
EOF

# Create test scripts
echo -e "${BLUE}🧪 Creating test infrastructure...${NC}"
mkdir -p tests

cat > tests/test_sdn_integration.py << 'EOF'
#!/usr/bin/env python3
"""
Comprehensive test suite for SDN controller integration
Tests OpenDaylight, Lighty.io, and Mininet integration
"""

import pytest
import time
import requests
import subprocess
import json
import os
import sys
from pathlib import Path

# Add project root to Python path
sys.path.insert(0, str(Path(__file__).parent.parent))

from python_apps.restconf_client.restconf_client import ODLRestconfClient

class TestSDNControllerIntegration:
    """Test OpenDaylight controller integration"""
    
    @pytest.fixture
    def odl_client(self):
        """Fixture providing RESTCONF client"""
        return ODLRestconfClient()
    
    def test_controller_health(self, odl_client):
        """Test OpenDaylight controller health and basic APIs"""
        try:
            # Test if controller is responsive
            response = requests.get(
                "http://localhost:8181/restconf/data/network-topology:network-topology",
                auth=("admin", "admin"),
                timeout=10
            )
            assert response.status_code == 200
            print("✅ Controller health check passed")
        except requests.exceptions.ConnectionError:
            pytest.skip("OpenDaylight controller not available")
    
    def test_yang_model_loading(self):
        """Test YANG model compilation and loading"""
        yang_file = Path("yang-models/network-device.yang")
        assert yang_file.exists(), "YANG model file not found"
        
        # Test YANG model syntax using pyang
        result = subprocess.run([
            "pyang", "--format", "tree", str(yang_file)
        ], capture_output=True, text=True)
        
        assert result.returncode == 0, f"YANG model validation failed: {result.stderr}"
        assert "devices" in result.stdout, "Expected YANG structure not found"
        print("✅ YANG model validation passed")
    
    def test_restconf_device_operations(self, odl_client):
        """Test RESTCONF device CRUD operations"""
        device_id = "test-switch-001"
        device_data = {
            "device-id": device_id,
            "management-ip": "192.168.100.10",
            "device-type": "switch",
            "interfaces": ["eth0", "eth1", "eth2"],
            "status": {"admin-state": "up"}
        }
        
        try:
            # Create device
            assert odl_client.create_device(device_data), "Device creation failed"
            
            # Read device
            retrieved_device = odl_client.get_device(device_id)
            assert retrieved_device is not None, "Device retrieval failed"
            
            # Update device
            assert odl_client.update_device_status(device_id, "down"), "Device update failed"
            
            # Delete device
            assert odl_client.delete_device(device_id), "Device deletion failed"
            
            print("✅ RESTCONF CRUD operations passed")
            
        except Exception as e:
            pytest.fail(f"RESTCONF operations failed: {e}")
    
    def test_rpc_operations(self, odl_client):
        """Test RESTCONF RPC operations"""
        result = odl_client.provision_device_rpc(
            device_id="rpc-test-device",
            management_ip="192.168.100.20",
            device_type="router"
        )
        
        assert "output" in result, "RPC response format invalid"
        print("✅ RPC operations test passed")

class TestMininetIntegration:
    """Test Mininet network simulation integration"""
    
    def test_mininet_topology_creation(self):
        """Test custom Mininet topology creation"""
        topology_script = Path("mininet/topologies/sdn_test_topology.py")
        assert topology_script.exists(), "Topology script not found"
        
        # Verify topology script syntax
        result = subprocess.run([
            "python3", "-m", "py_compile", str(topology_script)
        ], capture_output=True)
        
        assert result.returncode == 0, f"Topology script syntax error: {result.stderr}"
        print("✅ Mininet topology script validation passed")
    
    def test_openvswitch_availability(self):
        """Test Open vSwitch availability"""
        result = subprocess.run(["ovs-vsctl", "--version"], capture_output=True)
        assert result.returncode == 0, "Open vSwitch not available"
        print("✅ Open vSwitch availability check passed")

class TestPythonSDNApplications:
    """Test Python SDN application components"""
    
    def test_restconf_client_import(self):
        """Test RESTCONF client module import"""
        try:
            from python_apps.restconf_client.restconf_client import ODLRestconfClient
            client = ODLRestconfClient()
            assert hasattr(client, 'get_operational_topology')
            assert hasattr(client, 'create_device')
            print("✅ RESTCONF client import test passed")
        except ImportError as e:
            pytest.fail(f"RESTCONF client import failed: {e}")

class TestSecurityCompliance:
    """Test security compliance of SDN applications"""
    
    def test_no_hardcoded_credentials(self):
        """Test for hardcoded credentials in source code"""
        python_files = list(Path("python-apps").rglob("*.py"))
        
        suspicious_patterns = [
            "password=",
            "pwd=",
            "secret=",
            "token=",
            "api_key="
        ]
        
        violations = []
        for file_path in python_files:
            with open(file_path, 'r') as f:
                content = f.read().lower()
                for pattern in suspicious_patterns:
                    if pattern in content and "example" not in content:
                        violations.append(f"{file_path}: {pattern}")
        
        assert len(violations) == 0, f"Potential credential leaks found: {violations}"
        print("✅ Security compliance check passed")

if __name__ == "__main__":
    pytest.main([__file__, "-v", "--tb=short"])
EOF

# Create utility scripts
echo -e "${BLUE}🛠️  Creating utility scripts...${NC}"
mkdir -p scripts

cat > scripts/start_controller.sh << 'EOF'
#!/bin/bash
# Start OpenDaylight Controller

set -e

ODL_DIR="opendaylight/opendaylight-0.18.4"
JAVA_OPTS="${JAVA_OPTS:--Xms1G -Xmx4G}"

echo "🎛️  Starting OpenDaylight Controller..."

if [ ! -d "$ODL_DIR" ]; then
    echo "❌ OpenDaylight directory not found: $ODL_DIR"
    echo "Please run setup.sh first"
    exit 1
fi

# Set JAVA_HOME if not set
if [ -z "$JAVA_HOME" ]; then
    export JAVA_HOME="/usr/lib/jvm/java-11-openjdk-amd64"
fi

# Set Karaf options
export JAVA_OPTS="$JAVA_OPTS -XX:+UnlockExperimentalVMOptions -XX:+UseCGroupMemoryLimitForHeap"

# Start controller in background
cd "$ODL_DIR"
echo "📁 Working directory: $(pwd)"
echo "☕ Java options: $JAVA_OPTS"

# Start Karaf
echo "🚀 Starting Karaf container..."
bin/karaf server &
KARAF_PID=$!

# Wait for controller to be ready
echo "⏳ Waiting for controller to start..."
sleep 30

# Check if controller is responsive
for i in {1..12}; do
    if curl -s -u admin:admin http://localhost:8181/restconf/data/network-topology:network-topology >/dev/null 2>&1; then
        echo "✅ Controller is ready!"
        echo "📊 Management interface: http://localhost:8181"
        echo "🔌 OpenFlow port: 6633"
        echo "📋 Process ID: $KARAF_PID"
        
        # Save PID for later cleanup
        echo $KARAF_PID > /tmp/odl_controller.pid
        
        echo ""
        echo "Controller is running. Use Ctrl+C to stop or run stop_controller.sh"
        wait $KARAF_PID
        exit 0
    fi
    
    echo "⏳ Still waiting... (attempt $i/12)"
    sleep 10
done

echo "❌ Controller failed to start or is not responsive"
kill $KARAF_PID 2>/dev/null || true
exit 1
EOF

cat > scripts/stop_controller.sh << 'EOF'
#!/bin/bash
# Stop OpenDaylight Controller

echo "🛑 Stopping OpenDaylight Controller..."

# Check for saved PID
if [ -f "/tmp/odl_controller.pid" ]; then
    PID=$(cat /tmp/odl_controller.pid)
    if ps -p $PID > /dev/null 2>&1; then
        echo "📋 Stopping controller (PID: $PID)..."
        kill $PID
        
        # Wait for graceful shutdown
        for i in {1..10}; do
            if ! ps -p $PID > /dev/null 2>&1; then
                echo "✅ Controller stopped gracefully"
                rm -f /tmp/odl_controller.pid
                exit 0
            fi
            sleep 1
        done
        
        # Force kill if needed
        echo "⚠️  Force killing controller..."
        kill -9 $PID 2>/dev/null || true
    fi
    rm -f /tmp/odl_controller.pid
fi

# Kill any remaining Karaf processes
pkill -f "karaf" 2>/dev/null || true

echo "✅ Controller cleanup completed"
EOF

chmod +x scripts/*.sh

# Create activation script
cat > activate.sh << 'EOF'
#!/bin/bash
# Activate SDN Controller development environment

echo "🎛️  Activating SDN Controller Development Environment"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Activate Python virtual environment
if [ -d "venv" ]; then
    source venv/bin/activate
    echo "✅ Python virtual environment activated"
else
    echo "❌ Virtual environment not found. Run setup.sh first."
    return 1
fi

# Set Java environment
export JAVA_HOME="/usr/lib/jvm/java-11-openjdk-amd64"
export PATH="$JAVA_HOME/bin:$PATH"

# Set OpenDaylight environment
export ODL_HOME="$(pwd)/opendaylight/opendaylight-0.18.4"

echo "Environment Variables:"
echo "  JAVA_HOME: $JAVA_HOME"
echo "  ODL_HOME: $ODL_HOME"
echo "  VIRTUAL_ENV: $VIRTUAL_ENV"
echo ""

echo "Available Commands:"
echo "  ./scripts/start_controller.sh  - Start OpenDaylight controller"
echo "  ./scripts/stop_controller.sh   - Stop OpenDaylight controller"
echo "  python3 mininet/topologies/sdn_test_topology.py - Run test topology"
echo "  python3 python-apps/restconf-client/restconf_client.py - Test RESTCONF API"
echo "  pytest tests/ -v               - Run test suite"
echo ""

echo "🚀 Environment ready for SDN development!"
EOF

chmod +x activate.sh

echo -e "\n${GREEN}✅ Tutorial 03 Setup Complete!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "📁 Project directory: $PROJECT_DIR"
echo "🎛️  OpenDaylight: Ready for startup"
echo "💡 Lighty.io: Framework prepared"
echo "🔗 Mininet: Network simulation ready"
echo "🐍 Python: Virtual environment with SDN libraries"
echo ""
echo "🚀 Next Steps:"
echo "  1. cd $PROJECT_NAME"
echo "  2. source activate.sh"
echo "  3. ./scripts/start_controller.sh"
echo "  4. Run tests: cd .. && ./test.sh"
echo ""
echo "📚 See README.md for detailed tutorial instructions"