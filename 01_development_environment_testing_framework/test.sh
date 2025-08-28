#!/bin/bash
# Tutorial 1 - Real System Test Script (Improved)
set -e

# Environment variables
PROJECT_ROOT="${PROJECT_ROOT:-$(pwd)}"
PROJECT_NAME="${PROJECT_NAME:-sdn-everything}"
VENV_NAME="${VENV_NAME:-venv}"
CLUSTER_NAME="${CLUSTER_NAME:-tutorial-cluster}"

echo "🧪 Running Tutorial 1 Real System Tests..."
echo "📁 Project root: $PROJECT_ROOT"

# Navigate to project directory
if [ -d "$PROJECT_ROOT/$PROJECT_NAME" ]; then
    cd "$PROJECT_ROOT/$PROJECT_NAME"
else
    echo "❌ Project directory not found at $PROJECT_ROOT/$PROJECT_NAME"
    echo "   Run the setup script first"
    exit 1
fi

# Activate virtual environment
if [ -f "$VENV_NAME/bin/activate" ]; then
    source "$VENV_NAME/bin/activate"
    echo "🐍 Virtual environment activated"
else
    echo "❌ Virtual environment not found"
    echo "   Run the setup script first"
    exit 1
fi

# Set PYTHONPATH
export PYTHONPATH="$(pwd)/src:$PYTHONPATH"

# Verify project structure exists
echo "📁 Verifying project structure..."
for dir in src tests infrastructure ansible config; do
    if [ ! -d "$dir" ]; then
        echo "❌ Directory $dir not found"
        exit 1
    fi
done
echo "✅ Project structure verified"

# Create Python implementation
echo "🐍 Creating NetworkPolicyGenerator implementation..."
cat > src/network_policies.py << 'PYEOF'
"""
Network Policy Generator for Kubernetes
Implements test-driven, modular network policy creation
"""
import yaml
import json
import logging
from typing import Dict, List, Optional
from pathlib import Path

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


class NetworkPolicyGenerator:
    """Generate Kubernetes NetworkPolicy resources with validation"""
    
    def __init__(self):
        self.policies = []
        logger.info("NetworkPolicyGenerator initialized")
    
    def create_isolation_policy(self, 
                              namespace: str,
                              app_label: str,
                              allowed_ingress: Optional[List[Dict]] = None,
                              allowed_egress: Optional[List[Dict]] = None) -> Dict:
        """
        Generate NetworkPolicy for application isolation
        
        Args:
            namespace: Target Kubernetes namespace
            app_label: Application label selector
            allowed_ingress: List of allowed ingress rules
            allowed_egress: List of allowed egress rules
            
        Returns:
            NetworkPolicy dictionary ready for kubectl apply
        """
        logger.info(f"Creating isolation policy for {app_label} in {namespace}")
        
        policy = {
            'apiVersion': 'networking.k8s.io/v1',
            'kind': 'NetworkPolicy',
            'metadata': {
                'name': f'{app_label}-isolation-policy',
                'namespace': namespace,
                'labels': {
                    'generated-by': 'sdn-tutorial',
                    'app': app_label
                }
            },
            'spec': {
                'podSelector': {
                    'matchLabels': {'app': app_label}
                },
                'policyTypes': []
            }
        }
        
        if allowed_ingress is not None:
            policy['spec']['policyTypes'].append('Ingress')
            policy['spec']['ingress'] = allowed_ingress
            logger.info(f"Added {len(allowed_ingress)} ingress rules")
        
        if allowed_egress is not None:
            policy['spec']['policyTypes'].append('Egress')
            policy['spec']['egress'] = allowed_egress
            logger.info(f"Added {len(allowed_egress)} egress rules")
        
        # Default deny if no rules specified
        if not policy['spec']['policyTypes']:
            policy['spec']['policyTypes'] = ['Ingress', 'Egress']
            logger.info("Applied default deny-all policy")
        
        # Validate before adding
        if not self.validate_policy(policy):
            raise ValueError(f"Generated policy for {app_label} failed validation")
        
        self.policies.append(policy)
        logger.info(f"Successfully created policy: {policy['metadata']['name']}")
        return policy
    
    def create_microservice_policy(self, namespace: str, service_name: str, 
                                 allowed_services: List[str], 
                                 ports: List[int] = None) -> Dict:
        """Create policy for microservice communication"""
        ports = ports or [80, 8080, 443]
        
        ingress_rules = [{
            'from': [{'podSelector': {'matchLabels': {'app': svc}}} 
                    for svc in allowed_services],
            'ports': [{'protocol': 'TCP', 'port': port} for port in ports]
        }]
        
        # Allow DNS egress
        egress_rules = [{
            'to': [],
            'ports': [{'protocol': 'UDP', 'port': 53}]
        }]
        
        return self.create_isolation_policy(
            namespace, service_name, ingress_rules, egress_rules
        )
    
    def validate_policy(self, policy: Dict) -> bool:
        """Validate NetworkPolicy structure and content"""
        try:
            required_fields = ['apiVersion', 'kind', 'metadata', 'spec']
            if not all(field in policy for field in required_fields):
                logger.error("Missing required fields in policy")
                return False
            
            # Validate API version
            if policy['apiVersion'] != 'networking.k8s.io/v1':
                logger.error(f"Invalid API version: {policy['apiVersion']}")
                return False
            
            # Validate kind
            if policy['kind'] != 'NetworkPolicy':
                logger.error(f"Invalid kind: {policy['kind']}")
                return False
            
            # Validate metadata
            if not policy['metadata'].get('name'):
                logger.error("Policy missing name in metadata")
                return False
            
            # Validate spec
            spec = policy['spec']
            if 'podSelector' not in spec:
                logger.error("Policy missing podSelector in spec")
                return False
            
            if 'policyTypes' not in spec:
                logger.error("Policy missing policyTypes in spec")
                return False
            
            # Validate policy types
            valid_types = ['Ingress', 'Egress']
            for policy_type in spec['policyTypes']:
                if policy_type not in valid_types:
                    logger.error(f"Invalid policy type: {policy_type}")
                    return False
            
            logger.debug(f"Policy validation passed: {policy['metadata']['name']}")
            return True
            
        except Exception as e:
            logger.error(f"Policy validation error: {e}")
            return False
    
    def export_policies(self, output_file: str = 'network-policies.yaml'):
        """Export all policies to YAML file"""
        if not self.policies:
            logger.warning("No policies to export")
            return
        
        output_path = Path(output_file)
        
        try:
            with open(output_path, 'w') as f:
                yaml.dump_all(self.policies, f, default_flow_style=False, 
                             sort_keys=False, indent=2)
            
            logger.info(f"Exported {len(self.policies)} policies to {output_path}")
            
        except Exception as e:
            logger.error(f"Failed to export policies: {e}")
            raise
    
    def get_policy_summary(self) -> Dict:
        """Get summary of generated policies"""
        return {
            'total_policies': len(self.policies),
            'policy_names': [p['metadata']['name'] for p in self.policies],
            'namespaces': list(set(p['metadata']['namespace'] for p in self.policies)),
            'apps': list(set(p['metadata']['labels'].get('app', 'unknown') 
                           for p in self.policies))
        }


def main():
    """Main function for testing the implementation"""
    logger.info("Starting NetworkPolicyGenerator test")
    
    # Initialize generator
    generator = NetworkPolicyGenerator()
    
    # Create test policies
    logger.info("Creating test policies...")
    
    # Basic isolation policy
    policy1 = generator.create_isolation_policy('production', 'web-app')
    
    # Policy with ingress rules
    policy2 = generator.create_isolation_policy(
        'staging', 'api-service', 
        allowed_ingress=[{
            'from': [{'podSelector': {'matchLabels': {'app': 'frontend'}}}],
            'ports': [{'protocol': 'TCP', 'port': 8080}]
        }]
    )
    
    # Microservice policy
    policy3 = generator.create_microservice_policy(
        'production', 'payment-service', 
        allowed_services=['order-service', 'user-service'],
        ports=[8080, 9090]
    )
    
    # Validate all policies
    logger.info("Validating policies...")
    for i, policy in enumerate(generator.policies, 1):
        if not generator.validate_policy(policy):
            raise AssertionError(f"Policy {i} validation failed")
    
    # Export policies
    generator.export_policies('network-policies.yaml')
    
    # Print summary
    summary = generator.get_policy_summary()
    logger.info(f"Test completed successfully!")
    logger.info(f"Generated policies: {json.dumps(summary, indent=2)}")
    
    return generator


if __name__ == "__main__":
    generator = main()
PYEOF

# Create comprehensive test suite
echo "🧪 Creating comprehensive test suite..."
cat > tests/test_network_automation.py << 'TESTEOF'
"""
Comprehensive test suite for SDN Tutorial 1
Tests network policy generation and validation
"""
import pytest
import sys
import os
import yaml
import tempfile
from pathlib import Path

# Add src directory to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'src'))

from network_policies import NetworkPolicyGenerator


class TestNetworkPolicyGenerator:
    """Test suite for NetworkPolicyGenerator class"""
    
    @pytest.fixture
    def generator(self):
        """Fixture to provide fresh generator instance"""
        return NetworkPolicyGenerator()
    
    def test_basic_policy_creation(self, generator):
        """Test basic network policy creation"""
        policy = generator.create_isolation_policy('test-ns', 'test-app')
        
        assert policy['apiVersion'] == 'networking.k8s.io/v1'
        assert policy['kind'] == 'NetworkPolicy'
        assert policy['metadata']['name'] == 'test-app-isolation-policy'
        assert policy['metadata']['namespace'] == 'test-ns'
        assert policy['spec']['podSelector']['matchLabels']['app'] == 'test-app'
    
    def test_policy_validation(self, generator):
        """Test policy structure validation"""
        policy = generator.create_isolation_policy('test', 'app')
        assert generator.validate_policy(policy) is True
        
        # Test invalid policy
        invalid_policy = {'kind': 'Service'}  # Missing required fields
        assert generator.validate_policy(invalid_policy) is False
    
    def test_ingress_rules(self, generator):
        """Test policy with ingress rules"""
        ingress_rules = [{
            'from': [{'podSelector': {'matchLabels': {'app': 'frontend'}}}],
            'ports': [{'protocol': 'TCP', 'port': 8080}]
        }]
        
        policy = generator.create_isolation_policy(
            'prod', 'api', allowed_ingress=ingress_rules
        )
        
        assert 'Ingress' in policy['spec']['policyTypes']
        assert policy['spec']['ingress'] == ingress_rules
    
    def test_egress_rules(self, generator):
        """Test policy with egress rules"""
        egress_rules = [{
            'to': [],
            'ports': [{'protocol': 'UDP', 'port': 53}]
        }]
        
        policy = generator.create_isolation_policy(
            'prod', 'api', allowed_egress=egress_rules
        )
        
        assert 'Egress' in policy['spec']['policyTypes']
        assert policy['spec']['egress'] == egress_rules
    
    def test_microservice_policy(self, generator):
        """Test microservice policy creation"""
        policy = generator.create_microservice_policy(
            'production', 'payment-service',
            allowed_services=['order-service', 'user-service'],
            ports=[8080, 9090]
        )
        
        assert policy['metadata']['name'] == 'payment-service-isolation-policy'
        assert 'Ingress' in policy['spec']['policyTypes']
        assert 'Egress' in policy['spec']['policyTypes']
        
        # Check ingress rules
        ingress = policy['spec']['ingress'][0]
        assert len(ingress['from']) == 2
        assert len(ingress['ports']) == 2
        
        # Check egress rules (DNS)
        egress = policy['spec']['egress'][0]
        assert egress['ports'][0]['port'] == 53
    
    def test_policy_export(self, generator):
        """Test policy export functionality"""
        # Create test policies
        generator.create_isolation_policy('export-test', 'app1')
        generator.create_isolation_policy('export-test', 'app2')
        
        # Test export
        with tempfile.NamedTemporaryFile(suffix='.yaml', delete=False) as f:
            generator.export_policies(f.name)
            
            # Verify file was created and contains valid YAML
            assert Path(f.name).exists()
            
            with open(f.name, 'r') as yaml_file:
                policies = list(yaml.safe_load_all(yaml_file))
                assert len(policies) == 2
                assert all(p['kind'] == 'NetworkPolicy' for p in policies)
        
        os.unlink(f.name)
    
    def test_policy_summary(self, generator):
        """Test policy summary functionality"""
        generator.create_isolation_policy('ns1', 'app1')
        generator.create_isolation_policy('ns2', 'app2')
        
        summary = generator.get_policy_summary()
        
        assert summary['total_policies'] == 2
        assert len(summary['policy_names']) == 2
        assert 'ns1' in summary['namespaces']
        assert 'ns2' in summary['namespaces']
    
    def test_default_deny_policy(self, generator):
        """Test default deny-all policy creation"""
        policy = generator.create_isolation_policy('secure-ns', 'secure-app')
        
        # Should have both Ingress and Egress policy types (default deny)
        assert 'Ingress' in policy['spec']['policyTypes']
        assert 'Egress' in policy['spec']['policyTypes']
        
        # Should not have explicit ingress/egress rules (deny all)
        assert 'ingress' not in policy['spec']
        assert 'egress' not in policy['spec']


class TestIntegration:
    """Integration tests for the complete workflow"""
    
    def test_complete_workflow(self):
        """Test complete policy generation workflow"""
        generator = NetworkPolicyGenerator()
        
        # Create multiple policies
        policies_created = []
        
        # Web application stack
        web_policy = generator.create_isolation_policy(
            'production', 'web-frontend',
            allowed_ingress=[{
                'from': [],  # Allow from anywhere
                'ports': [{'protocol': 'TCP', 'port': 80}]
            }]
        )
        policies_created.append(web_policy)
        
        # API service
        api_policy = generator.create_microservice_policy(
            'production', 'api-backend',
            allowed_services=['web-frontend'],
            ports=[8080]
        )
        policies_created.append(api_policy)
        
        # Database
        db_policy = generator.create_isolation_policy(
            'production', 'database',
            allowed_ingress=[{
                'from': [{'podSelector': {'matchLabels': {'app': 'api-backend'}}}],
                'ports': [{'protocol': 'TCP', 'port': 5432}]
            }]
        )
        policies_created.append(db_policy)
        
        # Validate all policies
        for policy in policies_created:
            assert generator.validate_policy(policy)
        
        # Test export
        with tempfile.NamedTemporaryFile(suffix='.yaml', delete=False) as f:
            generator.export_policies(f.name)
            
            # Verify exported file
            with open(f.name, 'r') as yaml_file:
                exported_policies = list(yaml.safe_load_all(yaml_file))
                assert len(exported_policies) == len(policies_created)
        
        os.unlink(f.name)
        
        # Test summary
        summary = generator.get_policy_summary()
        assert summary['total_policies'] == len(policies_created)
        assert 'production' in summary['namespaces']


if __name__ == "__main__":
    pytest.main([__file__, "-v", "--tb=short"])
TESTEOF

# Run the Python implementation test
echo "🚀 Running Python implementation..."
python src/network_policies.py

echo ""
echo "🧪 Running comprehensive pytest suite..."
pytest tests/ -v --tb=short

if [ $? -eq 0 ]; then
    echo "✅ All Python tests passed!"
else
    echo "❌ Some Python tests failed"
    exit 1
fi

echo ""
echo "🛡️ Running security scan..."
bandit -r src/ -f json -o bandit-report.json || true
if [ -f bandit-report.json ]; then
    echo "📊 Security scan completed - report saved to bandit-report.json"
    # Check if there are any high severity issues
    high_issues=$(jq '.results | map(select(.issue_severity == "HIGH")) | length' bandit-report.json 2>/dev/null || echo "0")
    if [ "$high_issues" -gt "0" ]; then
        echo "⚠️  $high_issues high severity security issues found"
    else
        echo "✅ No high severity security issues found"
    fi
fi

echo ""
echo "📊 Running code quality checks..."
black --check src/ tests/ || echo "ℹ️  Run 'black src/ tests/' to format code"
flake8 src/ tests/ --max-line-length=88 --extend-ignore=E203,W503 || echo "ℹ️  Code style suggestions available"

echo ""
echo "☸️ Testing Kubernetes integration..."

# Check if kind cluster exists
if ! kind get clusters 2>/dev/null | grep -q "$CLUSTER_NAME"; then
    echo "🎪 Creating kind cluster: $CLUSTER_NAME"
    
    cat > kind-config.yaml << 'KINDEOF'
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  extraPortMappings:
  - containerPort: 30080
    hostPort: 8080
  - containerPort: 30443
    hostPort: 8443
networking:
  disableDefaultCNI: false
  podSubnet: "10.244.0.0/16"
KINDEOF
    
    kind create cluster --name "$CLUSTER_NAME" --config kind-config.yaml
    
    echo "⏳ Waiting for cluster to be ready..."
    kubectl wait --for=condition=Ready nodes --all --timeout=300s
    
    echo "✅ Kubernetes cluster ready"
else
    echo "✅ Using existing kind cluster: $CLUSTER_NAME"
    kubectl config use-context "kind-$CLUSTER_NAME"
fi

echo ""
echo "📋 Testing network policy deployment..."
if [ -f network-policies.yaml ]; then
    echo "🔍 Validating generated policies..."
    kubectl apply -f network-policies.yaml --dry-run=client -o yaml > /dev/null
    echo "✅ Network policies are valid Kubernetes resources"
    
    # Create required namespaces
    echo "📦 Creating required namespaces..."
    kubectl create namespace production --dry-run=client -o yaml | kubectl apply -f -
    kubectl create namespace staging --dry-run=client -o yaml | kubectl apply -f -
    echo "✅ Namespaces created"
    
    # Apply policies to cluster
    kubectl apply -f network-policies.yaml
    echo "✅ Network policies deployed to cluster"
    
    # Verify policies exist
    policy_count=$(kubectl get networkpolicies --all-namespaces --no-headers | wc -l)
    echo "📊 $policy_count network policies active in cluster"
    
else
    echo "⚠️  network-policies.yaml not found"
fi

echo ""
echo "🚀 Test deployment complete!"