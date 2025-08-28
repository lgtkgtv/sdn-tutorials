"""
Step 2: pytest Fixtures & Setup
Learn how to create reusable test components and manage test data

Run this step: pytest examples/step2_fixtures.py -v
"""
import pytest
import tempfile
import os
from pathlib import Path


# Basic fixture - returns a value
@pytest.fixture
def sample_config():
    """Fixture providing sample NetworkPolicy configuration"""
    return {
        'apiVersion': 'networking.k8s.io/v1',
        'kind': 'NetworkPolicy',
        'metadata': {
            'name': 'sample-policy',
            'namespace': 'test'
        },
        'spec': {
            'podSelector': {
                'matchLabels': {'app': 'web'}
            },
            'policyTypes': ['Ingress']
        }
    }


# Fixture with setup and teardown
@pytest.fixture
def temp_directory():
    """Fixture that creates and cleans up a temporary directory"""
    # Setup: Create temporary directory
    temp_dir = tempfile.mkdtemp()
    
    yield temp_dir  # Provide the directory to the test
    
    # Teardown: Clean up after test
    import shutil
    shutil.rmtree(temp_dir)


# Fixture that depends on another fixture
@pytest.fixture
def config_file(sample_config, temp_directory):
    """Fixture that creates a temporary config file"""
    import yaml
    
    file_path = os.path.join(temp_directory, 'config.yaml')
    with open(file_path, 'w') as f:
        yaml.dump(sample_config, f)
    
    return file_path


# Parametrized fixture - runs test multiple times with different data
@pytest.fixture(params=[
    'web-app',
    'api-service', 
    'database'
])
def app_name(request):
    """Fixture providing different application names"""
    return request.param


# Scope fixtures - shared across multiple tests
@pytest.fixture(scope='module')
def shared_data():
    """Module-scoped fixture - created once per test file"""
    print("\n🔧 Setting up shared data (once per module)")
    return {'counter': 0, 'shared_resource': 'expensive_to_create'}


@pytest.fixture(scope='function')  # Default scope
def fresh_data():
    """Function-scoped fixture - created for each test"""
    print("\n🔧 Creating fresh data (for each test)")
    return {'test_id': 'unique_per_test'}


# Test using basic fixture
def test_config_structure(sample_config):
    """Test that uses the sample_config fixture"""
    assert sample_config['kind'] == 'NetworkPolicy'
    assert sample_config['metadata']['name'] == 'sample-policy'
    assert 'podSelector' in sample_config['spec']


# Test using multiple fixtures
def test_config_file_creation(sample_config, config_file):
    """Test that uses both sample_config and config_file fixtures"""
    # Verify file was created
    assert os.path.exists(config_file)
    
    # Verify file contains our config
    import yaml
    with open(config_file, 'r') as f:
        loaded_config = yaml.safe_load(f)
    
    assert loaded_config == sample_config


# Test using parametrized fixture - runs 3 times
def test_app_policy_generation(app_name, sample_config):
    """Test runs once for each app_name parameter"""
    # Modify the sample config with the app name
    sample_config['metadata']['name'] = f'{app_name}-policy'
    sample_config['spec']['podSelector']['matchLabels']['app'] = app_name
    
    assert sample_config['metadata']['name'].endswith('-policy')
    assert sample_config['spec']['podSelector']['matchLabels']['app'] == app_name
    
    print(f"✅ Tested policy for app: {app_name}")


# Tests demonstrating fixture scopes
def test_shared_data_first(shared_data, fresh_data):
    """First test using scoped fixtures"""
    shared_data['counter'] += 1
    fresh_data['test_name'] = 'first_test'
    
    assert shared_data['counter'] == 1
    assert fresh_data['test_name'] == 'first_test'
    print(f"First test: counter={shared_data['counter']}")


def test_shared_data_second(shared_data, fresh_data):
    """Second test using scoped fixtures"""
    shared_data['counter'] += 1
    fresh_data['test_name'] = 'second_test'
    
    assert shared_data['counter'] == 2  # Shared data persists
    assert fresh_data['test_name'] == 'second_test'  # Fresh data is new
    print(f"Second test: counter={shared_data['counter']}")


# Fixture with error handling
@pytest.fixture
def risky_resource():
    """Fixture demonstrating error handling in setup/teardown"""
    resource = None
    try:
        # Simulate resource creation that might fail
        resource = {'status': 'created', 'data': 'important_data'}
        yield resource
    except Exception as e:
        print(f"Error in fixture: {e}")
        raise
    finally:
        # Always clean up, even if test fails
        if resource:
            resource['status'] = 'cleaned_up'
            print("🧹 Resource cleaned up in fixture teardown")


def test_risky_resource_usage(risky_resource):
    """Test using a fixture that has error handling"""
    assert risky_resource['status'] == 'created'
    assert risky_resource['data'] == 'important_data'
    
    # Even if this test fails, fixture teardown will run
    assert len(risky_resource) == 2


# Autouse fixture - runs automatically for every test
@pytest.fixture(autouse=True)
def test_logger():
    """Fixture that automatically runs for every test"""
    print("\n📋 Auto-logging: Test is starting...")
    yield
    print("📋 Auto-logging: Test is finished!")


# Class-based test with fixtures
class TestWithFixtures:
    """Test class demonstrating fixture usage"""
    
    @pytest.fixture(autouse=True)
    def setup_method(self):
        """Fixture that runs before each test method in this class"""
        print("\n🔧 Class setup: Preparing test environment")
        self.test_data = {'initialized': True}
    
    def test_method_one(self, sample_config):
        """Test method using fixture and class setup"""
        assert self.test_data['initialized'] is True
        assert sample_config['kind'] == 'NetworkPolicy'
    
    def test_method_two(self, temp_directory):
        """Another test method in the same class"""
        assert self.test_data['initialized'] is True
        assert os.path.exists(temp_directory)


# Advanced fixture with factory pattern
@pytest.fixture
def policy_factory(temp_directory):
    """Fixture that returns a factory function"""
    created_files = []
    
    def create_policy(name, namespace='default', app='web'):
        """Factory function to create policy configs"""
        import yaml
        
        policy = {
            'apiVersion': 'networking.k8s.io/v1',
            'kind': 'NetworkPolicy',
            'metadata': {'name': name, 'namespace': namespace},
            'spec': {
                'podSelector': {'matchLabels': {'app': app}},
                'policyTypes': ['Ingress']
            }
        }
        
        file_path = os.path.join(temp_directory, f'{name}.yaml')
        with open(file_path, 'w') as f:
            yaml.dump(policy, f)
        
        created_files.append(file_path)
        return file_path
    
    yield create_policy  # Return the factory function
    
    # Cleanup all created files
    for file_path in created_files:
        if os.path.exists(file_path):
            os.unlink(file_path)
    print(f"🧹 Cleaned up {len(created_files)} policy files")


def test_policy_factory_usage(policy_factory):
    """Test using the policy factory fixture"""
    # Create multiple policies using the factory
    web_policy = policy_factory('web-policy', 'production', 'web-app')
    api_policy = policy_factory('api-policy', 'staging', 'api-service')
    
    # Verify both files were created
    assert os.path.exists(web_policy)
    assert os.path.exists(api_policy)
    
    # Verify content is different
    import yaml
    with open(web_policy) as f:
        web_config = yaml.safe_load(f)
    with open(api_policy) as f:
        api_config = yaml.safe_load(f)
    
    assert web_config['metadata']['name'] == 'web-policy'
    assert api_config['metadata']['name'] == 'api-policy'
    assert web_config['metadata']['namespace'] == 'production'
    assert api_config['metadata']['namespace'] == 'staging'


if __name__ == "__main__":
    # Run tests when script is executed directly
    pytest.main([__file__, '-v', '-s'])  # -s shows print statements
    
    print("\n" + "="*50)
    print("Step 2 Complete: pytest Fixtures & Setup")
    print("="*50)
    print("Key concepts learned:")
    print("✅ Basic fixtures with @pytest.fixture")
    print("✅ Setup and teardown with yield")
    print("✅ Fixture dependencies (fixtures using other fixtures)")
    print("✅ Parametrized fixtures (multiple test runs)")
    print("✅ Fixture scopes (function, module, session)")
    print("✅ Autouse fixtures (run automatically)")
    print("✅ Factory pattern fixtures")
    print("✅ Error handling in fixtures")
    print("\nNext: Run 'pytest examples/step3_yaml_basics.py -v'")
    print("="*50)