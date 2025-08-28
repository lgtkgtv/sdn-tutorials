"""
Step 1: pytest Basics
Learn fundamental pytest concepts and patterns

Run this step: pytest examples/step1_basic_pytest.py -v
"""
import pytest


# Basic test function
def test_basic_assertion():
    """Most basic test - just assert something True"""
    assert True


def test_math_operations():
    """Test basic math operations with assertions"""
    # Simple equality
    assert 2 + 2 == 4
    
    # Different assertion types
    assert 10 > 5
    assert 'hello' in 'hello world'
    assert [1, 2, 3] == [1, 2, 3]


def test_string_operations():
    """Test string manipulations"""
    text = "Hello, World!"
    
    assert text.startswith("Hello")
    assert text.endswith("World!")
    assert len(text) == 13
    assert text.lower() == "hello, world!"


def test_list_operations():
    """Test list operations and membership"""
    numbers = [1, 2, 3, 4, 5]
    
    assert 3 in numbers
    assert len(numbers) == 5
    assert numbers[0] == 1
    assert numbers[-1] == 5


def test_dictionary_operations():
    """Test dictionary access and validation"""
    config = {
        'host': 'localhost',
        'port': 5432,
        'database': 'testdb'
    }
    
    assert config['host'] == 'localhost'
    assert config['port'] == 5432
    assert 'database' in config
    assert len(config) == 3


# Test that expects an exception
def test_exception_handling():
    """Test that proper exceptions are raised"""
    with pytest.raises(ZeroDivisionError):
        result = 1 / 0
    
    with pytest.raises(KeyError):
        config = {'host': 'localhost'}
        missing_value = config['missing_key']
    
    with pytest.raises(ValueError):
        int('not-a-number')


# Test with multiple assertions
def test_yaml_like_structure():
    """Test a structure similar to YAML/Kubernetes config"""
    network_policy = {
        'apiVersion': 'networking.k8s.io/v1',
        'kind': 'NetworkPolicy',
        'metadata': {
            'name': 'test-policy',
            'namespace': 'default'
        },
        'spec': {
            'podSelector': {
                'matchLabels': {
                    'app': 'web'
                }
            }
        }
    }
    
    # Test nested structure access
    assert network_policy['kind'] == 'NetworkPolicy'
    assert network_policy['metadata']['name'] == 'test-policy'
    assert network_policy['spec']['podSelector']['matchLabels']['app'] == 'web'
    
    # Test key existence
    assert 'apiVersion' in network_policy
    assert 'metadata' in network_policy
    assert 'spec' in network_policy


# Test that demonstrates pytest's detailed failure output
def test_detailed_failure_example():
    """This test will show pytest's detailed failure output"""
    expected_config = {
        'host': 'localhost',
        'port': 5432,
        'ssl': True
    }
    
    actual_config = {
        'host': 'localhost', 
        'port': 5432,
        'ssl': True
    }
    
    assert actual_config == expected_config


# Skip a test conditionally
@pytest.mark.skip(reason="Demonstrating skip functionality")
def test_skipped_example():
    """This test will be skipped"""
    assert False  # This won't run


# Mark a test as expected to fail
@pytest.mark.xfail(reason="Demonstrating expected failure")
def test_expected_failure():
    """This test is expected to fail"""
    assert 1 == 2  # This will fail but pytest expects it


if __name__ == "__main__":
    # Run tests when script is executed directly
    pytest.main([__file__, '-v'])
    
    print("\n" + "="*50)
    print("Step 1 Complete: pytest Basics")
    print("="*50)
    print("Key concepts learned:")
    print("✅ Basic test functions (start with 'test_')")
    print("✅ Assert statements for validation") 
    print("✅ Exception testing with pytest.raises()")
    print("✅ Dictionary and list assertions")
    print("✅ Nested structure validation")
    print("✅ Test markers (@pytest.mark.skip, @pytest.mark.xfail)")
    print("\nNext: Run 'pytest examples/step2_fixtures.py -v'")
    print("="*50)