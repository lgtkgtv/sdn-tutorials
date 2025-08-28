"""
Step 3: YAML Processing Fundamentals
Learn how to work with YAML configurations in tests

Run this step: pytest examples/step3_yaml_basics.py -v
"""
import pytest
import yaml
import tempfile
import os
from io import StringIO


# Test basic YAML loading
def test_basic_yaml_loading():
    """Test loading simple YAML data"""
    yaml_content = """
    name: test-app
    version: 1.0
    enabled: true
    """
    
    data = yaml.safe_load(yaml_content)
    
    assert data['name'] == 'test-app'
    assert data['version'] == 1.0
    assert data['enabled'] is True


def test_yaml_data_types():
    """Test different YAML data types"""
    yaml_content = """
    # Different data types in YAML
    string_value: "hello world"
    integer_value: 42
    float_value: 3.14
    boolean_true: true
    boolean_false: false
    null_value: null
    list_value:
      - item1
      - item2
      - item3
    nested_dict:
      key1: value1
      key2: value2
    """
    
    data = yaml.safe_load(yaml_content)
    
    # Test data types
    assert isinstance(data['string_value'], str)
    assert isinstance(data['integer_value'], int)
    assert isinstance(data['float_value'], float)
    assert isinstance(data['boolean_true'], bool)
    assert isinstance(data['boolean_false'], bool)
    assert data['null_value'] is None
    assert isinstance(data['list_value'], list)
    assert isinstance(data['nested_dict'], dict)
    
    # Test values
    assert data['string_value'] == "hello world"
    assert data['integer_value'] == 42
    assert data['float_value'] == 3.14
    assert data['boolean_true'] is True
    assert data['boolean_false'] is False
    assert len(data['list_value']) == 3
    assert data['list_value'][0] == 'item1'
    assert data['nested_dict']['key1'] == 'value1'


def test_kubernetes_yaml_structure():
    """Test parsing Kubernetes-style YAML"""
    k8s_yaml = """
    apiVersion: networking.k8s.io/v1
    kind: NetworkPolicy
    metadata:
      name: test-policy
      namespace: production
      labels:
        app: web
        environment: prod
    spec:
      podSelector:
        matchLabels:
          app: web
      policyTypes:
        - Ingress
        - Egress
      ingress:
        - from:
          - podSelector:
              matchLabels:
                app: frontend
          ports:
          - protocol: TCP
            port: 8080
    """
    
    config = yaml.safe_load(k8s_yaml)
    
    # Test top-level fields
    assert config['apiVersion'] == 'networking.k8s.io/v1'
    assert config['kind'] == 'NetworkPolicy'
    
    # Test metadata structure
    metadata = config['metadata']
    assert metadata['name'] == 'test-policy'
    assert metadata['namespace'] == 'production'
    assert metadata['labels']['app'] == 'web'
    assert metadata['labels']['environment'] == 'prod'
    
    # Test spec structure
    spec = config['spec']
    assert spec['podSelector']['matchLabels']['app'] == 'web'
    assert 'Ingress' in spec['policyTypes']
    assert 'Egress' in spec['policyTypes']
    
    # Test ingress rules
    ingress_rule = spec['ingress'][0]
    from_selector = ingress_rule['from'][0]
    assert from_selector['podSelector']['matchLabels']['app'] == 'frontend'
    
    port_rule = ingress_rule['ports'][0]
    assert port_rule['protocol'] == 'TCP'
    assert port_rule['port'] == 8080


def test_yaml_file_operations():
    """Test reading and writing YAML files"""
    test_data = {
        'application': {
            'name': 'test-app',
            'version': '2.1.0',
            'features': ['auth', 'logging', 'monitoring']
        },
        'database': {
            'host': 'localhost',
            'port': 5432,
            'ssl': True
        }
    }
    
    # Create temporary file
    with tempfile.NamedTemporaryFile(mode='w', suffix='.yaml', delete=False) as f:
        yaml.dump(test_data, f, default_flow_style=False)
        temp_file = f.name
    
    try:
        # Read back from file
        with open(temp_file, 'r') as f:
            loaded_data = yaml.safe_load(f)
        
        # Verify data integrity
        assert loaded_data == test_data
        assert loaded_data['application']['name'] == 'test-app'
        assert loaded_data['application']['features'] == ['auth', 'logging', 'monitoring']
        assert loaded_data['database']['port'] == 5432
        
    finally:
        # Cleanup
        os.unlink(temp_file)


def test_multiple_yaml_documents():
    """Test handling multiple YAML documents in one file"""
    multi_yaml = """
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  app.properties: |
    debug=true
    port=8080
---
apiVersion: v1
kind: Secret
metadata:
  name: app-secret
type: Opaque
data:
  username: YWRtaW4=  # base64 encoded 'admin'
  password: cGFzc3dvcmQ=  # base64 encoded 'password'
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: myapp
"""
    
    # Load all documents
    documents = list(yaml.safe_load_all(multi_yaml))
    
    assert len(documents) == 3
    
    # Test ConfigMap
    config_map = documents[0]
    assert config_map['kind'] == 'ConfigMap'
    assert config_map['metadata']['name'] == 'app-config'
    assert 'debug=true' in config_map['data']['app.properties']
    
    # Test Secret
    secret = documents[1]
    assert secret['kind'] == 'Secret'
    assert secret['metadata']['name'] == 'app-secret'
    assert secret['type'] == 'Opaque'
    assert secret['data']['username'] == 'YWRtaW4='
    
    # Test Deployment
    deployment = documents[2]
    assert deployment['kind'] == 'Deployment'
    assert deployment['metadata']['name'] == 'app-deployment'
    assert deployment['spec']['replicas'] == 3


def test_yaml_error_handling():
    """Test handling of invalid YAML content"""
    
    # Test invalid YAML syntax
    invalid_yaml = """
    name: test
    invalid: yaml: content: [unclosed
    """
    
    with pytest.raises(yaml.YAMLError):
        yaml.safe_load(invalid_yaml)
    
    # Test more complex invalid structure
    invalid_structure = """
    valid_start: true
    nested:
      key1: value1
    invalid_indent:
     wrong_indent: value
    """
    
    # This might not raise an error but produces unexpected structure
    try:
        result = yaml.safe_load(invalid_structure)
        # Verify the unexpected behavior
        assert 'invalid_indent' in result
    except yaml.YAMLError:
        # Or it might raise an error, which is also valid
        pass


def test_yaml_custom_formatting():
    """Test custom YAML formatting options"""
    test_data = {
        'long_list': [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
        'nested': {
            'level1': {
                'level2': {
                    'value': 'deep nested value'
                }
            }
        }
    }
    
    # Test different formatting styles
    compact_yaml = yaml.dump(test_data, default_flow_style=True)
    readable_yaml = yaml.dump(test_data, default_flow_style=False, indent=2)
    
    # Both should produce equivalent data when loaded
    compact_data = yaml.safe_load(compact_yaml)
    readable_data = yaml.safe_load(readable_yaml)
    
    assert compact_data == test_data
    assert readable_data == test_data
    assert compact_data == readable_data
    
    # Test custom formatting
    custom_yaml = yaml.dump(
        test_data, 
        default_flow_style=False,
        indent=4,
        width=80,
        allow_unicode=True
    )
    
    custom_data = yaml.safe_load(custom_yaml)
    assert custom_data == test_data


@pytest.fixture
def sample_yaml_data():
    """Fixture providing sample YAML data for testing"""
    return {
        'metadata': {
            'name': 'sample-service',
            'labels': {
                'app': 'web',
                'version': 'v1.2.3'
            }
        },
        'spec': {
            'ports': [
                {'name': 'http', 'port': 80, 'protocol': 'TCP'},
                {'name': 'https', 'port': 443, 'protocol': 'TCP'}
            ],
            'selector': {
                'app': 'web'
            }
        }
    }


def test_yaml_fixture_usage(sample_yaml_data):
    """Test using YAML data from fixtures"""
    # Convert to YAML string and back
    yaml_string = yaml.dump(sample_yaml_data, default_flow_style=False)
    reloaded_data = yaml.safe_load(yaml_string)
    
    assert reloaded_data == sample_yaml_data
    
    # Test specific values
    assert reloaded_data['metadata']['name'] == 'sample-service'
    assert reloaded_data['metadata']['labels']['version'] == 'v1.2.3'
    assert len(reloaded_data['spec']['ports']) == 2
    assert reloaded_data['spec']['ports'][0]['name'] == 'http'
    assert reloaded_data['spec']['ports'][1]['port'] == 443


def test_yaml_merge_operations():
    """Test merging YAML configurations"""
    base_config = {
        'metadata': {
            'name': 'base-service',
            'labels': {
                'app': 'web'
            }
        },
        'spec': {
            'replicas': 1
        }
    }
    
    override_config = {
        'metadata': {
            'labels': {
                'version': 'v2.0',
                'environment': 'production'
            }
        },
        'spec': {
            'replicas': 3,
            'strategy': 'RollingUpdate'
        }
    }
    
    # Simple merge (shallow)
    merged = {**base_config, **override_config}
    
    # The shallow merge overwrites nested dicts completely
    assert merged['metadata']['labels'] == {'version': 'v2.0', 'environment': 'production'}
    assert 'app' not in merged['metadata']['labels']  # Lost in shallow merge
    
    # Deep merge function
    def deep_merge(base, override):
        result = base.copy()
        for key, value in override.items():
            if key in result and isinstance(result[key], dict) and isinstance(value, dict):
                result[key] = deep_merge(result[key], value)
            else:
                result[key] = value
        return result
    
    deep_merged = deep_merge(base_config, override_config)
    
    # Deep merge preserves nested values
    assert deep_merged['metadata']['labels']['app'] == 'web'  # Preserved
    assert deep_merged['metadata']['labels']['version'] == 'v2.0'  # Added
    assert deep_merged['metadata']['labels']['environment'] == 'production'  # Added
    assert deep_merged['spec']['replicas'] == 3  # Overridden
    assert deep_merged['spec']['strategy'] == 'RollingUpdate'  # Added


# Advanced YAML features
def test_yaml_anchors_and_aliases():
    """Test YAML anchors and aliases (advanced feature)"""
    yaml_with_anchors = """
    # Define anchor
    default_labels: &default_labels
      app: web
      team: platform
      
    # Use aliases
    service1:
      metadata:
        name: frontend
        labels:
          <<: *default_labels
          component: frontend
          
    service2:
      metadata:
        name: backend
        labels:
          <<: *default_labels
          component: backend
    """
    
    data = yaml.safe_load(yaml_with_anchors)
    
    # Both services should have the default labels plus their own
    service1_labels = data['service1']['metadata']['labels']
    service2_labels = data['service2']['metadata']['labels']
    
    # Check default labels are present in both
    assert service1_labels['app'] == 'web'
    assert service1_labels['team'] == 'platform'
    assert service2_labels['app'] == 'web'
    assert service2_labels['team'] == 'platform'
    
    # Check specific labels
    assert service1_labels['component'] == 'frontend'
    assert service2_labels['component'] == 'backend'


if __name__ == "__main__":
    # Run tests when script is executed directly
    pytest.main([__file__, '-v', '-s'])
    
    print("\n" + "="*50)
    print("Step 3 Complete: YAML Processing Fundamentals")
    print("="*50)
    print("Key concepts learned:")
    print("✅ Loading YAML data with yaml.safe_load()")
    print("✅ Working with different YAML data types")
    print("✅ Parsing complex Kubernetes-style configurations")
    print("✅ Reading from and writing to YAML files")
    print("✅ Handling multiple YAML documents")
    print("✅ Error handling for invalid YAML")
    print("✅ Custom YAML formatting options")
    print("✅ Merging YAML configurations")
    print("✅ Advanced features: anchors and aliases")
    print("\nNext: Run 'pytest examples/step4_yaml_validation.py -v'")
    print("="*50)