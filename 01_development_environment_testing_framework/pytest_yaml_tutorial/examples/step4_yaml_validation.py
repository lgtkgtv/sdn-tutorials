"""
Step 4: YAML Configuration Validation Patterns
Learn how to validate YAML configurations with custom rules and error handling

Run this step: pytest examples/step4_yaml_validation.py -v
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


class ConfigValidator:
    """Example validator class for demonstration"""
    
    def __init__(self):
        self.required_fields = ['apiVersion', 'kind', 'metadata', 'spec']
        self.valid_api_versions = ['networking.k8s.io/v1', 'networking.k8s.io/v1beta1']
        self.valid_kinds = ['NetworkPolicy']
        self.valid_policy_types = ['Ingress', 'Egress']
    
    def validate_basic_structure(self, config):
        """Validate basic YAML structure"""
        if not isinstance(config, dict):
            raise ConfigValidationError("Configuration must be a dictionary")
        
        missing_fields = [field for field in self.required_fields if field not in config]
        if missing_fields:
            raise ConfigValidationError(f"Missing required fields: {missing_fields}")
        
        return True
    
    def validate_api_version(self, config):
        """Validate API version field"""
        api_version = config.get('apiVersion')
        if api_version not in self.valid_api_versions:
            raise ConfigValidationError(
                f"Invalid apiVersion '{api_version}'. Must be one of: {self.valid_api_versions}"
            )
        return True
    
    def validate_kind(self, config):
        """Validate kind field"""
        kind = config.get('kind')
        if kind not in self.valid_kinds:
            raise ConfigValidationError(f"Invalid kind '{kind}'. Must be one of: {self.valid_kinds}")
        return True
    
    def validate_metadata(self, config):
        """Validate metadata section"""
        metadata = config.get('metadata', {})
        
        if not isinstance(metadata, dict):
            raise ConfigValidationError("metadata must be a dictionary")
        
        if 'name' not in metadata:
            raise ConfigValidationError("metadata.name is required")
        
        name = metadata['name']
        if not isinstance(name, str) or not name.strip():
            raise ConfigValidationError("metadata.name must be a non-empty string")
        
        # Validate Kubernetes naming conventions
        if not all(c.isalnum() or c in '-.' for c in name):
            raise ConfigValidationError("metadata.name contains invalid characters")
        
        if name.startswith('-') or name.endswith('-'):
            raise ConfigValidationError("metadata.name cannot start or end with '-'")
        
        return True
    
    def validate_spec(self, config):
        """Validate spec section"""
        spec = config.get('spec', {})
        
        if not isinstance(spec, dict):
            raise ConfigValidationError("spec must be a dictionary")
        
        # Validate podSelector
        if 'podSelector' not in spec:
            raise ConfigValidationError("spec.podSelector is required")
        
        pod_selector = spec['podSelector']
        if not isinstance(pod_selector, dict):
            raise ConfigValidationError("spec.podSelector must be a dictionary")
        
        # Validate policyTypes if present
        if 'policyTypes' in spec:
            policy_types = spec['policyTypes']
            if not isinstance(policy_types, list):
                raise ConfigValidationError("spec.policyTypes must be a list")
            
            invalid_types = [pt for pt in policy_types if pt not in self.valid_policy_types]
            if invalid_types:
                raise ConfigValidationError(f"Invalid policyTypes: {invalid_types}")
        
        return True


@pytest.fixture
def validator():
    """Fixture providing a config validator instance"""
    return ConfigValidator()


@pytest.fixture
def valid_config():
    """Fixture providing a valid NetworkPolicy configuration"""
    return {
        'apiVersion': 'networking.k8s.io/v1',
        'kind': 'NetworkPolicy',
        'metadata': {
            'name': 'test-policy',
            'namespace': 'production'
        },
        'spec': {
            'podSelector': {
                'matchLabels': {'app': 'web'}
            },
            'policyTypes': ['Ingress']
        }
    }


def test_valid_config_passes_validation(validator, valid_config):
    """Test that a valid configuration passes all validation checks"""
    assert validator.validate_basic_structure(valid_config) is True
    assert validator.validate_api_version(valid_config) is True
    assert validator.validate_kind(valid_config) is True
    assert validator.validate_metadata(valid_config) is True
    assert validator.validate_spec(valid_config) is True


def test_missing_required_fields_validation(validator):
    """Test validation of missing required fields"""
    incomplete_configs = [
        {},  # Empty config
        {'apiVersion': 'networking.k8s.io/v1'},  # Missing kind, metadata, spec
        {'apiVersion': 'networking.k8s.io/v1', 'kind': 'NetworkPolicy'},  # Missing metadata, spec
    ]
    
    for config in incomplete_configs:
        with pytest.raises(ConfigValidationError) as exc_info:
            validator.validate_basic_structure(config)
        
        assert "Missing required fields" in str(exc_info.value)


def test_invalid_api_version_validation(validator, valid_config):
    """Test validation of invalid API versions"""
    import copy
    
    invalid_versions = [
        'v1',
        'apps/v1', 
        'networking.k8s.io/v2',
        'invalid-version',
        None,
        123
    ]
    
    for invalid_version in invalid_versions:
        invalid_config = copy.deepcopy(valid_config)
        invalid_config['apiVersion'] = invalid_version
        
        with pytest.raises(ConfigValidationError) as exc_info:
            validator.validate_api_version(invalid_config)
        
        assert "Invalid apiVersion" in str(exc_info.value)


def test_invalid_kind_validation(validator, valid_config):
    """Test validation of invalid kind values"""
    import copy
    
    invalid_kinds = [
        'Deployment',
        'Service',
        'ConfigMap',
        'networkpolicy',  # Wrong case
        None,
        123
    ]
    
    for invalid_kind in invalid_kinds:
        invalid_config = copy.deepcopy(valid_config)
        invalid_config['kind'] = invalid_kind
        
        with pytest.raises(ConfigValidationError) as exc_info:
            validator.validate_kind(invalid_config)
        
        assert "Invalid kind" in str(exc_info.value)


def test_metadata_validation_errors(validator, valid_config):
    """Test various metadata validation errors"""
    import copy
    
    # Test missing name
    config_no_name = copy.deepcopy(valid_config)
    config_no_name['metadata'] = {'namespace': 'test'}
    
    with pytest.raises(ConfigValidationError) as exc_info:
        validator.validate_metadata(config_no_name)
    
    assert "metadata.name is required" in str(exc_info.value)
    
    # Test empty name
    config_empty_name = copy.deepcopy(valid_config)
    config_empty_name['metadata']['name'] = ''
    
    with pytest.raises(ConfigValidationError):
        validator.validate_metadata(config_empty_name)
    
    # Test invalid characters
    config_invalid_chars = copy.deepcopy(valid_config)
    config_invalid_chars['metadata']['name'] = 'test_policy!'
    
    with pytest.raises(ConfigValidationError):
        validator.validate_metadata(config_invalid_chars)
    
    # Test name starting/ending with dash
    config_dash_start = copy.deepcopy(valid_config)
    config_dash_start['metadata']['name'] = '-test-policy'
    
    with pytest.raises(ConfigValidationError):
        validator.validate_metadata(config_dash_start)


def test_spec_validation_errors(validator, valid_config):
    """Test various spec section validation errors"""
    import copy
    
    # Test missing podSelector
    config_no_selector = copy.deepcopy(valid_config)
    del config_no_selector['spec']['podSelector']
    
    with pytest.raises(ConfigValidationError) as exc_info:
        validator.validate_spec(config_no_selector)
    
    assert "spec.podSelector is required" in str(exc_info.value)
    
    # Test invalid policyTypes
    config_invalid_policy = copy.deepcopy(valid_config)
    config_invalid_policy['spec']['policyTypes'] = ['InvalidType', 'AnotherInvalid']
    
    with pytest.raises(ConfigValidationError) as exc_info:
        validator.validate_spec(config_invalid_policy)
    
    assert "Invalid policyTypes" in str(exc_info.value)


def test_file_validation_workflow():
    """Test complete file validation workflow"""
    # Create valid YAML file
    valid_data = {
        'apiVersion': 'networking.k8s.io/v1',
        'kind': 'NetworkPolicy',
        'metadata': {'name': 'file-test-policy'},
        'spec': {'podSelector': {'matchLabels': {'app': 'test'}}}
    }
    
    with tempfile.NamedTemporaryFile(mode='w', suffix='.yaml', delete=False) as f:
        yaml.dump(valid_data, f)
        valid_file = f.name
    
    try:
        # Load and validate
        with open(valid_file, 'r') as f:
            config = yaml.safe_load(f)
        
        validator = ConfigValidator()
        assert validator.validate_basic_structure(config) is True
        assert validator.validate_metadata(config) is True
        assert validator.validate_spec(config) is True
        
    finally:
        os.unlink(valid_file)


def test_manager_validation_integration():
    """Test integration with NetworkPolicyConfigManager"""
    manager = NetworkPolicyConfigManager()
    
    # Test valid policy
    valid_policy = manager.generate_basic_policy('test-policy', 'default', 'web')
    assert manager.validate_network_policy(valid_policy) is True
    
    # Test invalid policy
    invalid_policy = valid_policy.copy()
    invalid_policy['kind'] = 'InvalidKind'
    
    with pytest.raises(ConfigValidationError):
        manager.validate_network_policy(invalid_policy)


def test_batch_validation():
    """Test validating multiple configurations in batch"""
    manager = NetworkPolicyConfigManager()
    
    configs = [
        manager.generate_basic_policy(f'policy-{i}', 'default', f'app-{i}')
        for i in range(5)
    ]
    
    # Add one invalid config
    invalid_config = configs[0].copy()
    invalid_config['apiVersion'] = 'invalid'
    configs.append(invalid_config)
    
    validation_results = []
    
    for i, config in enumerate(configs):
        try:
            is_valid = manager.validate_network_policy(config)
            validation_results.append((i, True, None))
        except ConfigValidationError as e:
            validation_results.append((i, False, str(e)))
    
    # Check results
    valid_count = sum(1 for _, is_valid, _ in validation_results if is_valid)
    invalid_count = len(validation_results) - valid_count
    
    assert valid_count == 5  # First 5 should be valid
    assert invalid_count == 1  # Last one should be invalid
    
    # Check the invalid one
    last_result = validation_results[-1]
    assert last_result[1] is False  # Not valid
    assert "Invalid apiVersion" in last_result[2]  # Error message


@pytest.fixture
def sample_config_files():
    """Fixture that creates temporary config files for testing"""
    files = {}
    
    # Valid config
    valid_config = {
        'apiVersion': 'networking.k8s.io/v1',
        'kind': 'NetworkPolicy',
        'metadata': {'name': 'valid-policy'},
        'spec': {'podSelector': {'matchLabels': {'app': 'test'}}}
    }
    
    # Invalid config (missing spec)
    invalid_config = {
        'apiVersion': 'networking.k8s.io/v1',
        'kind': 'NetworkPolicy',
        'metadata': {'name': 'invalid-policy'}
    }
    
    # Create files
    for name, config in [('valid', valid_config), ('invalid', invalid_config)]:
        with tempfile.NamedTemporaryFile(mode='w', suffix='.yaml', delete=False) as f:
            yaml.dump(config, f)
            files[name] = f.name
    
    yield files
    
    # Cleanup
    for file_path in files.values():
        if os.path.exists(file_path):
            os.unlink(file_path)


def test_file_validation_with_fixture(sample_config_files):
    """Test file validation using fixture"""
    manager = NetworkPolicyConfigManager()
    
    # Test valid file
    valid_config = manager.load_config_from_file(sample_config_files['valid'])
    assert manager.validate_network_policy(valid_config) is True
    
    # Test invalid file
    with pytest.raises(ConfigValidationError):
        invalid_config = manager.load_config_from_file(sample_config_files['invalid'])
        manager.validate_network_policy(invalid_config)


def test_validation_error_messages():
    """Test that validation error messages are descriptive"""
    validator = ConfigValidator()
    
    test_cases = [
        ({}, "Missing required fields"),
        ({'apiVersion': 'invalid'}, "Invalid apiVersion"),
        ({'apiVersion': 'networking.k8s.io/v1', 'kind': 'Invalid'}, "Invalid kind"),
        ({'apiVersion': 'networking.k8s.io/v1', 'kind': 'NetworkPolicy', 'metadata': {}}, "metadata.name is required"),
    ]
    
    for config, expected_message in test_cases:
        with pytest.raises(ConfigValidationError) as exc_info:
            if 'apiVersion' not in config:
                validator.validate_basic_structure(config)
            elif 'kind' not in config:
                validator.validate_api_version(config)
            elif config.get('kind') == 'Invalid':
                validator.validate_kind(config)
            else:
                validator.validate_metadata(config)
        
        assert expected_message in str(exc_info.value)


@pytest.mark.parametrize("invalid_name", [
    "",           # Empty
    "   ",        # Whitespace only
    "test_name",  # Underscore
    "test!name",  # Exclamation
    "-testname",  # Starts with dash
    "testname-",  # Ends with dash
    "Test Name",  # Space
    "123-name",   # Valid (numbers are OK)
])
def test_name_validation_parametrized(validator, valid_config, invalid_name):
    """Parametrized test for various invalid names"""
    import copy
    
    config = copy.deepcopy(valid_config)
    config['metadata']['name'] = invalid_name
    
    if invalid_name == "123-name":
        # This should be valid
        assert validator.validate_metadata(config) is True
    else:
        # These should be invalid
        with pytest.raises(ConfigValidationError):
            validator.validate_metadata(config)


def test_complex_validation_scenario():
    """Test a complex validation scenario with multiple issues"""
    complex_config = {
        'apiVersion': 'networking.k8s.io/v1',
        'kind': 'NetworkPolicy',
        'metadata': {
            'name': 'complex-policy',
            'namespace': 'production',
            'labels': {
                'app': 'web',
                'version': 'v1.0'
            }
        },
        'spec': {
            'podSelector': {
                'matchLabels': {'app': 'web'}
            },
            'policyTypes': ['Ingress', 'Egress'],
            'ingress': [
                {
                    'from': [
                        {
                            'podSelector': {
                                'matchLabels': {'app': 'frontend'}
                            }
                        }
                    ],
                    'ports': [
                        {'protocol': 'TCP', 'port': 8080}
                    ]
                }
            ],
            'egress': [
                {
                    'to': [
                        {
                            'podSelector': {
                                'matchLabels': {'app': 'database'}
                            }
                        }
                    ],
                    'ports': [
                        {'protocol': 'TCP', 'port': 5432}
                    ]
                }
            ]
        }
    }
    
    # This should be completely valid
    manager = NetworkPolicyConfigManager()
    assert manager.validate_network_policy(complex_config) is True
    
    # Test modifying various parts to make them invalid
    invalid_versions = [
        ('apiVersion', 'invalid-version'),
        ('kind', 'InvalidKind'),
    ]
    
    for field, invalid_value in invalid_versions:
        test_config = complex_config.copy()
        test_config[field] = invalid_value
        
        with pytest.raises(ConfigValidationError):
            manager.validate_network_policy(test_config)


if __name__ == "__main__":
    # Run tests when script is executed directly
    pytest.main([__file__, '-v', '-s'])
    
    print("\n" + "="*50)
    print("Step 4 Complete: YAML Configuration Validation")
    print("="*50)
    print("Key concepts learned:")
    print("✅ Creating custom validation classes and methods")
    print("✅ Validating required fields and data types")
    print("✅ Handling validation errors with descriptive messages")
    print("✅ Testing validation rules with parametrized tests")
    print("✅ File-based validation workflows")
    print("✅ Batch validation of multiple configurations")
    print("✅ Integration testing with real manager classes")
    print("✅ Complex validation scenarios")
    print("\nNext: Run 'pytest examples/step5_coverage.py -v'")
    print("="*50)