"""
Comprehensive test suite for NetworkPolicyConfigManager
Demonstrates pytest, PyYAML, and coverage patterns
"""
import pytest
import yaml
import tempfile
import os
from pathlib import Path
from unittest.mock import patch, mock_open

# Add src to path for imports
import sys
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'src'))

from config_manager import NetworkPolicyConfigManager, ConfigValidationError


class TestNetworkPolicyConfigManager:
    """Test suite for NetworkPolicyConfigManager class"""
    
    @pytest.fixture
    def manager(self):
        """Fixture to provide fresh manager instance for each test"""
        return NetworkPolicyConfigManager()
    
    @pytest.fixture
    def valid_policy(self):
        """Fixture providing a valid NetworkPolicy configuration"""
        return {
            'apiVersion': 'networking.k8s.io/v1',
            'kind': 'NetworkPolicy',
            'metadata': {
                'name': 'test-policy',
                'namespace': 'test'
            },
            'spec': {
                'podSelector': {
                    'matchLabels': {'app': 'test-app'}
                },
                'policyTypes': ['Ingress']
            }
        }
    
    @pytest.fixture
    def sample_config_file(self, valid_policy):
        """Fixture creating a temporary YAML config file"""
        with tempfile.NamedTemporaryFile(mode='w', suffix='.yaml', delete=False) as f:
            yaml.dump(valid_policy, f)
            temp_file = f.name
        
        yield temp_file  # Provide filename to test
        
        # Cleanup after test
        os.unlink(temp_file)
    
    def test_manager_initialization(self, manager):
        """Test that manager initializes correctly"""
        assert manager.configs == []
        assert 'required_fields' in manager.validation_rules
        assert manager.validation_rules['api_version'] == 'networking.k8s.io/v1'
        assert manager.validation_rules['kind'] == 'NetworkPolicy'
    
    def test_load_config_from_file_success(self, manager, sample_config_file):
        """Test successful loading of valid YAML configuration"""
        config = manager.load_config_from_file(sample_config_file)
        
        assert config['kind'] == 'NetworkPolicy'
        assert config['metadata']['name'] == 'test-policy'
        assert config['spec']['podSelector']['matchLabels']['app'] == 'test-app'
    
    def test_load_config_file_not_found(self, manager):
        """Test handling of non-existent configuration file"""
        with pytest.raises(ConfigValidationError) as exc_info:
            manager.load_config_from_file('non_existent_file.yaml')
        
        assert 'not found' in str(exc_info.value)
    
    def test_load_config_invalid_yaml(self, manager):
        """Test handling of invalid YAML syntax"""
        with tempfile.NamedTemporaryFile(mode='w', suffix='.yaml', delete=False) as f:
            f.write('invalid: yaml: content: [unclosed')
            invalid_file = f.name
        
        try:
            with pytest.raises(ConfigValidationError) as exc_info:
                manager.load_config_from_file(invalid_file)
            
            assert 'Invalid YAML' in str(exc_info.value)
        finally:
            os.unlink(invalid_file)
    
    def test_load_config_empty_file(self, manager):
        """Test handling of empty YAML file"""
        with tempfile.NamedTemporaryFile(mode='w', suffix='.yaml', delete=False) as f:
            f.write('')  # Empty file
            empty_file = f.name
        
        try:
            with pytest.raises(ConfigValidationError) as exc_info:
                manager.load_config_from_file(empty_file)
            
            assert 'Empty configuration' in str(exc_info.value)
        finally:
            os.unlink(empty_file)
    
    def test_load_multiple_configs(self, manager):
        """Test loading multiple YAML documents from single file"""
        configs = [
            {'apiVersion': 'v1', 'kind': 'ConfigMap', 'metadata': {'name': 'config1'}},
            {'apiVersion': 'v1', 'kind': 'Secret', 'metadata': {'name': 'secret1'}}
        ]
        
        with tempfile.NamedTemporaryFile(mode='w', suffix='.yaml', delete=False) as f:
            yaml.dump_all(configs, f)
            multi_file = f.name
        
        try:
            loaded_configs = manager.load_multiple_configs(multi_file)
            
            assert len(loaded_configs) == 2
            assert loaded_configs[0]['kind'] == 'ConfigMap'
            assert loaded_configs[1]['kind'] == 'Secret'
        finally:
            os.unlink(multi_file)
    
    def test_validate_network_policy_valid(self, manager, valid_policy):
        """Test validation of correct NetworkPolicy configuration"""
        assert manager.validate_network_policy(valid_policy) is True
    
    def test_validate_network_policy_missing_fields(self, manager):
        """Test validation failure for missing required fields"""
        invalid_config = {
            'apiVersion': 'networking.k8s.io/v1',
            'kind': 'NetworkPolicy'
            # Missing metadata and spec
        }
        
        with pytest.raises(ConfigValidationError) as exc_info:
            manager.validate_network_policy(invalid_config)
        
        assert 'Missing required fields' in str(exc_info.value)
        assert 'metadata' in str(exc_info.value)
        assert 'spec' in str(exc_info.value)
    
    def test_validate_network_policy_wrong_api_version(self, manager, valid_policy):
        """Test validation failure for incorrect API version"""
        valid_policy['apiVersion'] = 'apps/v1'
        
        with pytest.raises(ConfigValidationError) as exc_info:
            manager.validate_network_policy(valid_policy)
        
        assert 'Invalid apiVersion' in str(exc_info.value)
    
    def test_validate_network_policy_wrong_kind(self, manager, valid_policy):
        """Test validation failure for incorrect kind"""
        valid_policy['kind'] = 'Deployment'
        
        with pytest.raises(ConfigValidationError) as exc_info:
            manager.validate_network_policy(valid_policy)
        
        assert 'Invalid kind' in str(exc_info.value)
    
    def test_validate_network_policy_missing_metadata_name(self, manager, valid_policy):
        """Test validation failure for missing metadata.name"""
        del valid_policy['metadata']['name']
        
        with pytest.raises(ConfigValidationError) as exc_info:
            manager.validate_network_policy(valid_policy)
        
        assert 'Missing metadata.name' in str(exc_info.value)
    
    def test_validate_network_policy_missing_pod_selector(self, manager, valid_policy):
        """Test validation failure for missing podSelector"""
        del valid_policy['spec']['podSelector']
        
        with pytest.raises(ConfigValidationError) as exc_info:
            manager.validate_network_policy(valid_policy)
        
        assert 'Missing spec.podSelector' in str(exc_info.value)
    
    def test_validate_network_policy_invalid_policy_type(self, manager, valid_policy):
        """Test validation failure for invalid policy type"""
        valid_policy['spec']['policyTypes'] = ['InvalidType']
        
        with pytest.raises(ConfigValidationError) as exc_info:
            manager.validate_network_policy(valid_policy)
        
        assert 'Invalid policyType: InvalidType' in str(exc_info.value)
    
    def test_generate_basic_policy(self, manager):
        """Test generation of basic NetworkPolicy configuration"""
        policy = manager.generate_basic_policy('my-policy', 'production', 'web-app')
        
        assert policy['apiVersion'] == 'networking.k8s.io/v1'
        assert policy['kind'] == 'NetworkPolicy'
        assert policy['metadata']['name'] == 'my-policy'
        assert policy['metadata']['namespace'] == 'production'
        assert policy['spec']['podSelector']['matchLabels']['app'] == 'web-app'
        assert policy['spec']['policyTypes'] == ['Ingress', 'Egress']
        
        # Verify it passes validation
        assert manager.validate_network_policy(policy) is True
    
    def test_add_ingress_rule_new_rule(self, manager, valid_policy):
        """Test adding ingress rule to policy without existing ingress"""
        from_selectors = [{'podSelector': {'matchLabels': {'app': 'frontend'}}}]
        ports = [{'protocol': 'TCP', 'port': 8080}]
        
        updated_policy = manager.add_ingress_rule(valid_policy, from_selectors, ports)
        
        assert 'ingress' in updated_policy['spec']
        assert len(updated_policy['spec']['ingress']) == 1
        assert updated_policy['spec']['ingress'][0]['from'] == from_selectors
        assert updated_policy['spec']['ingress'][0]['ports'] == ports
        assert 'Ingress' in updated_policy['spec']['policyTypes']
    
    def test_add_ingress_rule_existing_rules(self, manager, valid_policy):
        """Test adding ingress rule to policy with existing ingress rules"""
        # Add first rule
        valid_policy['spec']['ingress'] = [{'from': [{'podSelector': {'matchLabels': {'app': 'existing'}}}]}]
        
        # Add second rule
        from_selectors = [{'podSelector': {'matchLabels': {'app': 'new-app'}}}]
        updated_policy = manager.add_ingress_rule(valid_policy, from_selectors)
        
        assert len(updated_policy['spec']['ingress']) == 2
        assert updated_policy['spec']['ingress'][1]['from'] == from_selectors
    
    def test_add_ingress_rule_without_ports(self, manager, valid_policy):
        """Test adding ingress rule without port specifications"""
        from_selectors = [{'podSelector': {'matchLabels': {'app': 'any-port-app'}}}]
        
        updated_policy = manager.add_ingress_rule(valid_policy, from_selectors)
        
        ingress_rule = updated_policy['spec']['ingress'][0]
        assert 'ports' not in ingress_rule
        assert ingress_rule['from'] == from_selectors
    
    def test_save_config_to_file(self, manager, valid_policy):
        """Test saving configuration to YAML file"""
        with tempfile.NamedTemporaryFile(mode='w', suffix='.yaml', delete=False) as f:
            output_file = f.name
        
        try:
            manager.save_config_to_file(valid_policy, output_file)
            
            # Verify file was created and contains valid YAML
            assert os.path.exists(output_file)
            
            with open(output_file, 'r') as f:
                loaded_config = yaml.safe_load(f)
            
            assert loaded_config == valid_policy
        finally:
            if os.path.exists(output_file):
                os.unlink(output_file)
    
    def test_save_multiple_configs(self, manager):
        """Test saving multiple configurations to single file"""
        configs = [
            manager.generate_basic_policy('policy1', 'ns1', 'app1'),
            manager.generate_basic_policy('policy2', 'ns2', 'app2')
        ]
        
        with tempfile.NamedTemporaryFile(mode='w', suffix='.yaml', delete=False) as f:
            output_file = f.name
        
        try:
            manager.save_multiple_configs(configs, output_file)
            
            # Verify file contains multiple documents
            loaded_configs = manager.load_multiple_configs(output_file)
            
            assert len(loaded_configs) == 2
            assert loaded_configs[0]['metadata']['name'] == 'policy1'
            assert loaded_configs[1]['metadata']['name'] == 'policy2'
        finally:
            if os.path.exists(output_file):
                os.unlink(output_file)
    
    def test_get_config_summary_basic(self, manager, valid_policy):
        """Test getting summary of basic configuration"""
        summary = manager.get_config_summary(valid_policy)
        
        assert summary['name'] == 'test-policy'
        assert summary['namespace'] == 'test'
        assert summary['app_label'] == 'test-app'
        assert summary['policy_types'] == ['Ingress']
        assert summary['has_ingress_rules'] is False
        assert summary['has_egress_rules'] is False
    
    def test_get_config_summary_with_rules(self, manager, valid_policy):
        """Test getting summary of configuration with ingress/egress rules"""
        # Add ingress rules
        valid_policy['spec']['ingress'] = [
            {'from': [{'podSelector': {'matchLabels': {'app': 'app1'}}}]},
            {'from': [{'podSelector': {'matchLabels': {'app': 'app2'}}}]}
        ]
        
        # Add egress rules
        valid_policy['spec']['egress'] = [
            {'to': [{'podSelector': {'matchLabels': {'app': 'db'}}}]}
        ]
        valid_policy['spec']['policyTypes'].append('Egress')
        
        summary = manager.get_config_summary(valid_policy)
        
        assert summary['has_ingress_rules'] is True
        assert summary['has_egress_rules'] is True
        assert summary['ingress_rules_count'] == 2
        assert summary['egress_rules_count'] == 1
    
    @pytest.mark.parametrize("policy_name,namespace,app_label", [
        ("web-policy", "production", "web-app"),
        ("api-policy", "staging", "api-service"),
        ("db-policy", "database", "postgres")
    ])
    def test_generate_basic_policy_parametrized(self, manager, policy_name, namespace, app_label):
        """Test basic policy generation with different parameters"""
        policy = manager.generate_basic_policy(policy_name, namespace, app_label)
        
        assert policy['metadata']['name'] == policy_name
        assert policy['metadata']['namespace'] == namespace
        assert policy['spec']['podSelector']['matchLabels']['app'] == app_label
        assert manager.validate_network_policy(policy) is True


class TestConfigManagerIntegration:
    """Integration tests demonstrating real-world usage patterns"""
    
    @pytest.fixture
    def manager(self):
        return NetworkPolicyConfigManager()
    
    def test_complete_workflow(self, manager):
        """Test complete workflow: generate, validate, save, load"""
        # Step 1: Generate policy
        policy = manager.generate_basic_policy('integration-test', 'test-ns', 'test-app')
        
        # Step 2: Add ingress rule
        from_selectors = [{'podSelector': {'matchLabels': {'app': 'client'}}}]
        ports = [{'protocol': 'TCP', 'port': 8080}]
        policy = manager.add_ingress_rule(policy, from_selectors, ports)
        
        # Step 3: Validate
        assert manager.validate_network_policy(policy) is True
        
        # Step 4: Save to file
        with tempfile.NamedTemporaryFile(mode='w', suffix='.yaml', delete=False) as f:
            output_file = f.name
        
        try:
            manager.save_config_to_file(policy, output_file)
            
            # Step 5: Load from file and verify
            loaded_policy = manager.load_config_from_file(output_file)
            
            assert loaded_policy == policy
            assert manager.validate_network_policy(loaded_policy) is True
            
            # Step 6: Get summary
            summary = manager.get_config_summary(loaded_policy)
            assert summary['has_ingress_rules'] is True
            assert summary['ingress_rules_count'] == 1
            
        finally:
            if os.path.exists(output_file):
                os.unlink(output_file)
    
    def test_multi_policy_workflow(self, manager):
        """Test workflow with multiple policies"""
        # Generate multiple policies
        policies = []
        for i in range(3):
            policy = manager.generate_basic_policy(
                f'policy-{i}', f'namespace-{i}', f'app-{i}'
            )
            policies.append(policy)
        
        # Save all policies to single file
        with tempfile.NamedTemporaryFile(mode='w', suffix='.yaml', delete=False) as f:
            output_file = f.name
        
        try:
            manager.save_multiple_configs(policies, output_file)
            
            # Load and validate all policies
            loaded_policies = manager.load_multiple_configs(output_file)
            
            assert len(loaded_policies) == 3
            
            for i, policy in enumerate(loaded_policies):
                assert policy['metadata']['name'] == f'policy-{i}'
                assert manager.validate_network_policy(policy) is True
                
        finally:
            if os.path.exists(output_file):
                os.unlink(output_file)


class TestErrorHandling:
    """Test suite focused on error handling and edge cases"""
    
    @pytest.fixture
    def manager(self):
        return NetworkPolicyConfigManager()
    
    @pytest.fixture
    def valid_policy(self):
        """Fixture providing a valid NetworkPolicy configuration"""
        return {
            'apiVersion': 'networking.k8s.io/v1',
            'kind': 'NetworkPolicy',
            'metadata': {
                'name': 'test-policy',
                'namespace': 'test'
            },
            'spec': {
                'podSelector': {
                    'matchLabels': {'app': 'test-app'}
                },
                'policyTypes': ['Ingress']
            }
        }
    
    def test_file_permission_error(self, manager, valid_policy):
        """Test handling of file permission errors"""
        # Try to save to a directory that doesn't exist
        invalid_path = '/nonexistent/directory/config.yaml'
        
        with pytest.raises(ConfigValidationError) as exc_info:
            manager.save_config_to_file(valid_policy, invalid_path)
        
        assert 'Error saving config' in str(exc_info.value)
    
    @patch('builtins.open', mock_open(read_data='corrupted: yaml: data: ['))
    def test_yaml_parsing_exception(self, manager):
        """Test handling of YAML parsing exceptions with mocking"""
        with pytest.raises(ConfigValidationError) as exc_info:
            manager.load_config_from_file('mocked_file.yaml')
        
        assert 'Invalid YAML' in str(exc_info.value)
    
    def test_validation_with_none_values(self, manager):
        """Test validation handling of None values in configuration"""
        config_with_none = {
            'apiVersion': 'networking.k8s.io/v1',
            'kind': 'NetworkPolicy',
            'metadata': None,  # None value should cause error
            'spec': {
                'podSelector': {'matchLabels': {'app': 'test'}}
            }
        }
        
        with pytest.raises((ConfigValidationError, AttributeError, TypeError)):
            manager.validate_network_policy(config_with_none)