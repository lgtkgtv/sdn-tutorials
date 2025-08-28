"""
Step 5: pytest-cov Integration & Coverage Analysis
Learn how to measure and analyze test coverage for YAML processing code

Run this step: pytest examples/step5_coverage.py -v --cov=../src --cov-report=term-missing
"""
import pytest
import yaml
import tempfile
import os
from pathlib import Path

# Add src to path for imports
import sys
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'src'))

from config_manager import NetworkPolicyConfigManager, ConfigValidationError


class CoverageExample:
    """Example class to demonstrate coverage testing patterns"""
    
    def __init__(self):
        self.processed_configs = []
        self.error_count = 0
        self.success_count = 0
    
    def process_config(self, config_data):
        """Process a configuration with various code paths"""
        try:
            if not config_data:
                raise ValueError("Empty configuration")
            
            if not isinstance(config_data, dict):
                raise TypeError("Configuration must be a dictionary")
            
            # Check for required fields
            if 'kind' not in config_data:
                self.error_count += 1
                return False
            
            # Process different kinds
            if config_data['kind'] == 'NetworkPolicy':
                return self._process_network_policy(config_data)
            elif config_data['kind'] == 'ConfigMap':
                return self._process_config_map(config_data)
            else:
                # This path tests coverage of unknown kinds
                self.error_count += 1
                return False
                
        except (ValueError, TypeError) as e:
            self.error_count += 1
            return False
    
    def _process_network_policy(self, config):
        """Private method for network policy processing"""
        if 'spec' not in config:
            self.error_count += 1
            return False
        
        if 'podSelector' not in config['spec']:
            self.error_count += 1
            return False
        
        # Success path
        self.processed_configs.append(config)
        self.success_count += 1
        return True
    
    def _process_config_map(self, config):
        """Private method for config map processing"""
        if 'data' not in config:
            self.error_count += 1
            return False
        
        # Success path for ConfigMap
        self.processed_configs.append(config)
        self.success_count += 1
        return True
    
    def get_stats(self):
        """Return processing statistics"""
        total = self.success_count + self.error_count
        if total == 0:
            return {'success_rate': 0, 'total': 0}
        
        return {
            'success_rate': (self.success_count / total) * 100,
            'total': total,
            'successes': self.success_count,
            'errors': self.error_count
        }
    
    def reset_stats(self):
        """Reset all statistics"""
        self.processed_configs.clear()
        self.error_count = 0
        self.success_count = 0


@pytest.fixture
def coverage_processor():
    """Fixture providing a fresh coverage example processor"""
    return CoverageExample()


@pytest.fixture
def network_policy_config():
    """Fixture providing a valid NetworkPolicy config"""
    return {
        'apiVersion': 'networking.k8s.io/v1',
        'kind': 'NetworkPolicy',
        'metadata': {'name': 'test-policy'},
        'spec': {
            'podSelector': {'matchLabels': {'app': 'web'}},
            'policyTypes': ['Ingress']
        }
    }


@pytest.fixture
def config_map_config():
    """Fixture providing a valid ConfigMap config"""
    return {
        'apiVersion': 'v1',
        'kind': 'ConfigMap',
        'metadata': {'name': 'test-config'},
        'data': {
            'key1': 'value1',
            'key2': 'value2'
        }
    }


def test_successful_network_policy_processing(coverage_processor, network_policy_config):
    """Test successful processing of NetworkPolicy - covers success paths"""
    result = coverage_processor.process_config(network_policy_config)
    
    assert result is True
    assert coverage_processor.success_count == 1
    assert coverage_processor.error_count == 0
    assert len(coverage_processor.processed_configs) == 1


def test_successful_config_map_processing(coverage_processor, config_map_config):
    """Test successful processing of ConfigMap - covers ConfigMap branch"""
    result = coverage_processor.process_config(config_map_config)
    
    assert result is True
    assert coverage_processor.success_count == 1
    assert coverage_processor.error_count == 0
    assert len(coverage_processor.processed_configs) == 1


def test_empty_config_error_handling(coverage_processor):
    """Test error handling for empty config - covers ValueError branch"""
    result = coverage_processor.process_config(None)
    
    assert result is False
    assert coverage_processor.error_count == 1
    assert coverage_processor.success_count == 0


def test_invalid_type_error_handling(coverage_processor):
    """Test error handling for invalid types - covers TypeError branch"""
    invalid_configs = [
        "not a dict",
        123,
        ["list", "instead", "of", "dict"]
    ]
    
    for invalid_config in invalid_configs:
        result = coverage_processor.process_config(invalid_config)
        assert result is False
    
    assert coverage_processor.error_count == 3
    assert coverage_processor.success_count == 0


def test_missing_kind_field(coverage_processor):
    """Test handling of missing kind field - covers missing kind branch"""
    config_no_kind = {
        'apiVersion': 'v1',
        'metadata': {'name': 'test'}
        # Missing 'kind' field
    }
    
    result = coverage_processor.process_config(config_no_kind)
    
    assert result is False
    assert coverage_processor.error_count == 1


def test_unknown_kind_handling(coverage_processor):
    """Test handling of unknown kind - covers unknown kind branch"""
    unknown_kind_config = {
        'apiVersion': 'apps/v1',
        'kind': 'Deployment',  # Unknown kind for our processor
        'metadata': {'name': 'test-deployment'}
    }
    
    result = coverage_processor.process_config(unknown_kind_config)
    
    assert result is False
    assert coverage_processor.error_count == 1


def test_network_policy_missing_spec(coverage_processor):
    """Test NetworkPolicy without spec - covers NetworkPolicy error branch"""
    config_no_spec = {
        'apiVersion': 'networking.k8s.io/v1',
        'kind': 'NetworkPolicy',
        'metadata': {'name': 'test-policy'}
        # Missing 'spec' field
    }
    
    result = coverage_processor.process_config(config_no_spec)
    
    assert result is False
    assert coverage_processor.error_count == 1


def test_network_policy_missing_pod_selector(coverage_processor):
    """Test NetworkPolicy without podSelector - covers podSelector error branch"""
    config_no_selector = {
        'apiVersion': 'networking.k8s.io/v1',
        'kind': 'NetworkPolicy',
        'metadata': {'name': 'test-policy'},
        'spec': {
            'policyTypes': ['Ingress']
            # Missing 'podSelector'
        }
    }
    
    result = coverage_processor.process_config(config_no_selector)
    
    assert result is False
    assert coverage_processor.error_count == 1


def test_config_map_missing_data(coverage_processor):
    """Test ConfigMap without data - covers ConfigMap error branch"""
    config_no_data = {
        'apiVersion': 'v1',
        'kind': 'ConfigMap',
        'metadata': {'name': 'test-config'}
        # Missing 'data' field
    }
    
    result = coverage_processor.process_config(config_no_data)
    
    assert result is False
    assert coverage_processor.error_count == 1


def test_statistics_calculation(coverage_processor, network_policy_config):
    """Test statistics calculation - covers stats methods"""
    # Initially no stats
    initial_stats = coverage_processor.get_stats()
    assert initial_stats['success_rate'] == 0
    assert initial_stats['total'] == 0
    
    # Process some configs
    coverage_processor.process_config(network_policy_config)  # Success
    coverage_processor.process_config(None)  # Error
    coverage_processor.process_config({'kind': 'Unknown'})  # Error
    
    stats = coverage_processor.get_stats()
    assert stats['total'] == 3
    assert stats['successes'] == 1
    assert stats['errors'] == 2
    assert stats['success_rate'] == pytest.approx(33.33, rel=0.01)


def test_reset_functionality(coverage_processor, network_policy_config):
    """Test reset functionality - covers reset method"""
    # Process some data
    coverage_processor.process_config(network_policy_config)
    assert coverage_processor.success_count == 1
    assert len(coverage_processor.processed_configs) == 1
    
    # Reset
    coverage_processor.reset_stats()
    
    # Verify reset
    assert coverage_processor.success_count == 0
    assert coverage_processor.error_count == 0
    assert len(coverage_processor.processed_configs) == 0
    
    stats = coverage_processor.get_stats()
    assert stats['success_rate'] == 0
    assert stats['total'] == 0


def test_manager_coverage_integration():
    """Test coverage with NetworkPolicyConfigManager integration"""
    manager = NetworkPolicyConfigManager()
    
    # Test various manager methods to ensure coverage
    
    # Generate policy
    policy1 = manager.generate_basic_policy('policy1', 'default', 'web')
    assert manager.validate_network_policy(policy1) is True
    
    # Add ingress rule
    from_selectors = [{'podSelector': {'matchLabels': {'app': 'frontend'}}}]
    ports = [{'protocol': 'TCP', 'port': 8080}]
    policy1 = manager.add_ingress_rule(policy1, from_selectors, ports)
    
    # Test file operations
    with tempfile.NamedTemporaryFile(mode='w', suffix='.yaml', delete=False) as f:
        temp_file = f.name
    
    try:
        # Save and load
        manager.save_config_to_file(policy1, temp_file)
        loaded_policy = manager.load_config_from_file(temp_file)
        assert loaded_policy == policy1
        
        # Get summary
        summary = manager.get_config_summary(loaded_policy)
        assert summary['has_ingress_rules'] is True
        assert summary['ingress_rules_count'] == 1
        
    finally:
        os.unlink(temp_file)


def test_comprehensive_coverage_scenario():
    """Comprehensive test to maximize code coverage"""
    processor = CoverageExample()
    manager = NetworkPolicyConfigManager()
    
    # Test all branches and paths
    test_cases = [
        # Valid NetworkPolicy
        {
            'apiVersion': 'networking.k8s.io/v1',
            'kind': 'NetworkPolicy',
            'metadata': {'name': 'valid-np'},
            'spec': {'podSelector': {'matchLabels': {'app': 'web'}}}
        },
        # Valid ConfigMap
        {
            'apiVersion': 'v1',
            'kind': 'ConfigMap',
            'metadata': {'name': 'valid-cm'},
            'data': {'key': 'value'}
        },
        # Invalid: empty
        None,
        # Invalid: wrong type
        "string instead of dict",
        # Invalid: missing kind
        {'apiVersion': 'v1', 'metadata': {'name': 'no-kind'}},
        # Invalid: unknown kind
        {'apiVersion': 'v1', 'kind': 'Unknown', 'metadata': {'name': 'unknown'}},
        # Invalid: NetworkPolicy missing spec
        {'apiVersion': 'networking.k8s.io/v1', 'kind': 'NetworkPolicy', 'metadata': {'name': 'no-spec'}},
        # Invalid: NetworkPolicy missing podSelector
        {'apiVersion': 'networking.k8s.io/v1', 'kind': 'NetworkPolicy', 'metadata': {'name': 'no-selector'}, 'spec': {}},
        # Invalid: ConfigMap missing data
        {'apiVersion': 'v1', 'kind': 'ConfigMap', 'metadata': {'name': 'no-data'}},
    ]
    
    results = []
    for i, test_case in enumerate(test_cases):
        result = processor.process_config(test_case)
        results.append(result)
        print(f"Test case {i+1}: {'✅ PASS' if result else '❌ FAIL'}")
    
    # Verify expected results
    expected_successes = 2  # Only the first two should succeed
    expected_failures = len(test_cases) - expected_successes
    
    actual_successes = sum(results)
    actual_failures = len(results) - actual_successes
    
    assert actual_successes == expected_successes
    assert actual_failures == expected_failures
    
    # Test stats
    stats = processor.get_stats()
    assert stats['successes'] == expected_successes
    assert stats['errors'] == expected_failures


def test_file_coverage_operations():
    """Test file operations to ensure coverage of file handling code"""
    manager = NetworkPolicyConfigManager()
    
    # Test multiple config file operations
    configs = [
        manager.generate_basic_policy(f'policy-{i}', f'ns-{i}', f'app-{i}')
        for i in range(3)
    ]
    
    with tempfile.NamedTemporaryFile(mode='w', suffix='.yaml', delete=False) as f:
        multi_file = f.name
    
    try:
        # Test save_multiple_configs
        manager.save_multiple_configs(configs, multi_file)
        
        # Test load_multiple_configs
        loaded_configs = manager.load_multiple_configs(multi_file)
        assert len(loaded_configs) == 3
        
        # Validate each loaded config
        for config in loaded_configs:
            assert manager.validate_network_policy(config) is True
            summary = manager.get_config_summary(config)
            assert summary['has_ingress_rules'] is False
            
    finally:
        os.unlink(multi_file)


def test_error_handling_coverage():
    """Test error handling paths to ensure coverage"""
    manager = NetworkPolicyConfigManager()
    
    # Test file not found error
    with pytest.raises(ConfigValidationError) as exc_info:
        manager.load_config_from_file('/nonexistent/file.yaml')
    assert 'not found' in str(exc_info.value)
    
    # Test invalid YAML file
    with tempfile.NamedTemporaryFile(mode='w', suffix='.yaml', delete=False) as f:
        f.write('invalid: yaml: content: [unclosed')
        invalid_file = f.name
    
    try:
        with pytest.raises(ConfigValidationError) as exc_info:
            manager.load_config_from_file(invalid_file)
        assert 'Invalid YAML' in str(exc_info.value)
    finally:
        os.unlink(invalid_file)
    
    # Test empty file
    with tempfile.NamedTemporaryFile(mode='w', suffix='.yaml', delete=False) as f:
        f.write('')  # Empty file
        empty_file = f.name
    
    try:
        with pytest.raises(ConfigValidationError) as exc_info:
            manager.load_config_from_file(empty_file)
        assert 'Empty configuration' in str(exc_info.value)
    finally:
        os.unlink(empty_file)


if __name__ == "__main__":
    # Run tests with coverage when script is executed directly
    print("Running tests with coverage analysis...")
    pytest.main([
        __file__, 
        '-v', 
        '--cov=../src',
        '--cov-report=term-missing',
        '--cov-report=html:../coverage_html',
        '--cov-branch'
    ])
    
    print("\n" + "="*50)
    print("Step 5 Complete: pytest-cov Integration & Coverage")
    print("="*50)
    print("Key concepts learned:")
    print("✅ Running tests with coverage measurement (--cov)")
    print("✅ Coverage reporting options (term-missing, html)")
    print("✅ Branch coverage analysis (--cov-branch)")
    print("✅ Writing tests to maximize coverage")
    print("✅ Testing all code paths and branches")
    print("✅ Error handling coverage")
    print("✅ Integration testing with coverage")
    print("✅ Coverage-driven test design")
    print("\nCoverage reports generated:")
    print("📊 Terminal: Shown above with missing lines")
    print("📁 HTML: Available in ../coverage_html/index.html")
    print("\nNext: Run 'pytest examples/step6_integration.py -v'")
    print("="*50)