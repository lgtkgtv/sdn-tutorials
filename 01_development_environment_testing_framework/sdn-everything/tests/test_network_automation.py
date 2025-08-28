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
