"""
Step 6: Complete Workflow Integration
Comprehensive integration tests demonstrating real-world pytest + YAML + coverage workflows

Run this step: pytest examples/step6_integration.py -v --cov=../src --cov-report=term-missing --cov-branch
"""
import pytest
import yaml
import tempfile
import os
import json
from pathlib import Path
from unittest.mock import patch, mock_open, MagicMock

# Add src to path for imports
import sys
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'src'))

from config_manager import NetworkPolicyConfigManager, ConfigValidationError


class NetworkPolicyWorkflow:
    """Complete workflow class integrating all concepts from previous steps"""
    
    def __init__(self, base_directory=None):
        self.manager = NetworkPolicyConfigManager()
        self.base_directory = base_directory or tempfile.mkdtemp()
        self.processed_policies = []
        self.validation_errors = []
        self.operation_log = []
    
    def create_policy_from_template(self, template_name, policy_name, namespace, app_label):
        """Create a policy from a predefined template"""
        templates = {
            'web-frontend': {
                'policyTypes': ['Ingress'],
                'ingress_rules': [
                    {
                        'from_selectors': [{}],  # Allow from all
                        'ports': [{'protocol': 'TCP', 'port': 80}, {'protocol': 'TCP', 'port': 443}]
                    }
                ]
            },
            'api-service': {
                'policyTypes': ['Ingress', 'Egress'],
                'ingress_rules': [
                    {
                        'from_selectors': [{'podSelector': {'matchLabels': {'app': 'frontend'}}}],
                        'ports': [{'protocol': 'TCP', 'port': 8080}]
                    }
                ],
                'egress_rules': [
                    {
                        'to_selectors': [{'podSelector': {'matchLabels': {'app': 'database'}}}],
                        'ports': [{'protocol': 'TCP', 'port': 5432}]
                    }
                ]
            },
            'database': {
                'policyTypes': ['Ingress'],
                'ingress_rules': [
                    {
                        'from_selectors': [{'podSelector': {'matchLabels': {'app': 'api'}}}],
                        'ports': [{'protocol': 'TCP', 'port': 5432}]
                    }
                ]
            }
        }
        
        if template_name not in templates:
            raise ValueError(f"Unknown template: {template_name}")
        
        self.operation_log.append(f"Creating policy {policy_name} from template {template_name}")
        
        # Generate base policy
        policy = self.manager.generate_basic_policy(policy_name, namespace, app_label)
        template = templates[template_name]
        
        # Apply template modifications
        policy['spec']['policyTypes'] = template['policyTypes']
        
        # Add ingress rules if specified
        if 'ingress_rules' in template:
            for rule in template['ingress_rules']:
                policy = self.manager.add_ingress_rule(
                    policy, 
                    rule['from_selectors'],
                    rule.get('ports')
                )
        
        # Add egress rules if specified (simplified implementation)
        if 'egress_rules' in template:
            if 'egress' not in policy['spec']:
                policy['spec']['egress'] = []
            
            for rule in template['egress_rules']:
                egress_rule = {'to': rule['to_selectors']}
                if 'ports' in rule:
                    egress_rule['ports'] = rule['ports']
                policy['spec']['egress'].append(egress_rule)
        
        return policy
    
    def validate_and_process_policy(self, policy):
        """Validate a policy and add it to processed list if valid"""
        try:
            if self.manager.validate_network_policy(policy):
                self.processed_policies.append(policy)
                self.operation_log.append(f"Validated and processed policy: {policy['metadata']['name']}")
                return True
        except ConfigValidationError as e:
            self.validation_errors.append((policy.get('metadata', {}).get('name', 'unknown'), str(e)))
            self.operation_log.append(f"Validation failed for policy: {e}")
            return False
    
    def batch_process_policies(self, policy_specs):
        """Process multiple policies from specifications"""
        results = []
        
        for spec in policy_specs:
            try:
                if 'template' in spec:
                    policy = self.create_policy_from_template(
                        spec['template'], spec['name'], spec['namespace'], spec['app']
                    )
                else:
                    policy = self.manager.generate_basic_policy(
                        spec['name'], spec['namespace'], spec['app']
                    )
                
                success = self.validate_and_process_policy(policy)
                results.append((spec['name'], success, policy if success else None))
                
            except Exception as e:
                self.validation_errors.append((spec['name'], str(e)))
                results.append((spec['name'], False, None))
        
        return results
    
    def save_policies_to_directory(self, directory=None):
        """Save all processed policies to individual files in a directory"""
        if directory is None:
            directory = os.path.join(self.base_directory, 'policies')
        
        os.makedirs(directory, exist_ok=True)
        
        saved_files = []
        for policy in self.processed_policies:
            filename = f"{policy['metadata']['name']}.yaml"
            filepath = os.path.join(directory, filename)
            
            self.manager.save_config_to_file(policy, filepath)
            saved_files.append(filepath)
            self.operation_log.append(f"Saved policy to {filepath}")
        
        return saved_files
    
    def create_policy_bundle(self, bundle_filename):
        """Create a single file containing all processed policies"""
        bundle_path = os.path.join(self.base_directory, bundle_filename)
        
        if self.processed_policies:
            self.manager.save_multiple_configs(self.processed_policies, bundle_path)
            self.operation_log.append(f"Created policy bundle: {bundle_path}")
        
        return bundle_path
    
    def generate_report(self):
        """Generate a comprehensive report of the workflow"""
        return {
            'total_policies': len(self.processed_policies),
            'validation_errors': len(self.validation_errors),
            'success_rate': (
                len(self.processed_policies) / 
                (len(self.processed_policies) + len(self.validation_errors)) * 100
                if (len(self.processed_policies) + len(self.validation_errors)) > 0 else 0
            ),
            'processed_policies': [
                {
                    'name': p['metadata']['name'],
                    'namespace': p['metadata']['namespace'],
                    'app': p['spec']['podSelector']['matchLabels'].get('app', 'unknown'),
                    'policy_types': p['spec'].get('policyTypes', []),
                    'has_ingress': 'ingress' in p['spec'],
                    'has_egress': 'egress' in p['spec']
                }
                for p in self.processed_policies
            ],
            'errors': [{'policy': name, 'error': error} for name, error in self.validation_errors],
            'operation_log': self.operation_log
        }


# Integration test fixtures
@pytest.fixture
def workflow():
    """Fixture providing a fresh workflow instance"""
    return NetworkPolicyWorkflow()


@pytest.fixture
def sample_policy_specs():
    """Fixture providing sample policy specifications"""
    return [
        {'name': 'frontend-policy', 'namespace': 'web', 'app': 'frontend', 'template': 'web-frontend'},
        {'name': 'api-policy', 'namespace': 'api', 'app': 'api-service', 'template': 'api-service'},
        {'name': 'db-policy', 'namespace': 'data', 'app': 'postgres', 'template': 'database'},
        {'name': 'simple-policy', 'namespace': 'default', 'app': 'simple-app'},  # No template
    ]


@pytest.fixture
def temp_workspace():
    """Fixture providing a temporary workspace directory"""
    temp_dir = tempfile.mkdtemp()
    yield temp_dir
    
    # Cleanup
    import shutil
    shutil.rmtree(temp_dir, ignore_errors=True)


class TestNetworkPolicyWorkflowIntegration:
    """Integration tests for the complete workflow"""
    
    def test_complete_workflow_success_path(self, workflow, sample_policy_specs):
        """Test the complete happy path workflow"""
        # Step 1: Batch process policies
        results = workflow.batch_process_policies(sample_policy_specs)
        
        # Verify all policies were processed successfully
        assert len(results) == 4
        successful_results = [r for r in results if r[1]]  # r[1] is success flag
        assert len(successful_results) == 4
        
        # Step 2: Verify policies are in processed list
        assert len(workflow.processed_policies) == 4
        assert len(workflow.validation_errors) == 0
        
        # Step 3: Save policies to directory
        saved_files = workflow.save_policies_to_directory()
        assert len(saved_files) == 4
        
        # Verify files exist and contain valid YAML
        for filepath in saved_files:
            assert os.path.exists(filepath)
            
            with open(filepath, 'r') as f:
                loaded_policy = yaml.safe_load(f)
            
            assert workflow.manager.validate_network_policy(loaded_policy) is True
        
        # Step 4: Create policy bundle
        bundle_path = workflow.create_policy_bundle('complete_bundle.yaml')
        assert os.path.exists(bundle_path)
        
        # Verify bundle contains all policies
        loaded_policies = workflow.manager.load_multiple_configs(bundle_path)
        assert len(loaded_policies) == 4
        
        # Step 5: Generate and verify report
        report = workflow.generate_report()
        assert report['total_policies'] == 4
        assert report['validation_errors'] == 0
        assert report['success_rate'] == 100.0
        assert len(report['processed_policies']) == 4
        assert len(report['errors']) == 0
        
        # Verify report details
        frontend_policy = next(p for p in report['processed_policies'] if p['name'] == 'frontend-policy')
        assert frontend_policy['namespace'] == 'web'
        assert frontend_policy['app'] == 'frontend'
        assert 'Ingress' in frontend_policy['policy_types']
        assert frontend_policy['has_ingress'] is True
    
    def test_workflow_with_validation_errors(self, workflow):
        """Test workflow handling of validation errors"""
        invalid_specs = [
            {'name': 'valid-policy', 'namespace': 'test', 'app': 'test-app'},
            {'name': 'invalid-template', 'namespace': 'test', 'app': 'invalid', 'template': 'nonexistent1'},
            {'name': 'unknown-template', 'namespace': 'test', 'app': 'test', 'template': 'nonexistent2'},
        ]
        
        results = workflow.batch_process_policies(invalid_specs)
        
        # Should have one success and two failures
        successful = sum(1 for _, success, _ in results if success)
        failed = len(results) - successful
        
        assert successful == 1
        assert failed == 2
        assert len(workflow.validation_errors) == 2
        assert len(workflow.processed_policies) == 1
        
        # Generate report and verify error tracking
        report = workflow.generate_report()
        assert report['total_policies'] == 1
        assert report['validation_errors'] == 2
        assert report['success_rate'] == pytest.approx(33.33, rel=0.01)
    
    def test_template_based_policy_creation(self, workflow):
        """Test policy creation from different templates"""
        test_cases = [
            ('web-frontend', 'frontend-test', 'web', 'frontend-app'),
            ('api-service', 'api-test', 'api', 'api-app'),
            ('database', 'db-test', 'data', 'db-app'),
        ]
        
        for template, name, namespace, app in test_cases:
            policy = workflow.create_policy_from_template(template, name, namespace, app)
            
            # Verify basic structure
            assert policy['metadata']['name'] == name
            assert policy['metadata']['namespace'] == namespace
            assert policy['spec']['podSelector']['matchLabels']['app'] == app
            
            # Verify template-specific characteristics
            if template == 'web-frontend':
                assert policy['spec']['policyTypes'] == ['Ingress']
                assert 'ingress' in policy['spec']
                assert len(policy['spec']['ingress']) == 1
                
                ports = policy['spec']['ingress'][0]['ports']
                assert {'protocol': 'TCP', 'port': 80} in ports
                assert {'protocol': 'TCP', 'port': 443} in ports
            
            elif template == 'api-service':
                assert 'Ingress' in policy['spec']['policyTypes']
                assert 'Egress' in policy['spec']['policyTypes']
                assert 'ingress' in policy['spec']
                assert 'egress' in policy['spec']
            
            elif template == 'database':
                assert policy['spec']['policyTypes'] == ['Ingress']
                assert 'ingress' in policy['spec']
                
                # Check database-specific ingress rule
                ingress_rule = policy['spec']['ingress'][0]
                assert ingress_rule['ports'] == [{'protocol': 'TCP', 'port': 5432}]
            
            # Verify policy is valid
            assert workflow.manager.validate_network_policy(policy) is True
    
    def test_file_operations_integration(self, workflow, temp_workspace):
        """Test comprehensive file operations"""
        # Create some policies
        specs = [
            {'name': 'file-test-1', 'namespace': 'test', 'app': 'app1', 'template': 'web-frontend'},
            {'name': 'file-test-2', 'namespace': 'test', 'app': 'app2', 'template': 'database'},
        ]
        
        workflow.batch_process_policies(specs)
        
        # Test saving to custom directory
        custom_dir = os.path.join(temp_workspace, 'custom_policies')
        saved_files = workflow.save_policies_to_directory(custom_dir)
        
        assert len(saved_files) == 2
        assert all(f.startswith(custom_dir) for f in saved_files)
        assert all(os.path.exists(f) for f in saved_files)
        
        # Test bundle creation in custom location
        bundle_path = os.path.join(temp_workspace, 'custom_bundle.yaml')
        workflow.create_policy_bundle('custom_bundle.yaml')
        
        # Load and verify bundle
        bundle_policies = workflow.manager.load_multiple_configs(
            os.path.join(workflow.base_directory, 'custom_bundle.yaml')
        )
        assert len(bundle_policies) == 2
        
        # Cross-verify: policies saved individually should match bundle
        individual_policies = []
        for saved_file in saved_files:
            policy = workflow.manager.load_config_from_file(saved_file)
            individual_policies.append(policy)
        
        # Sort both lists by name for comparison
        bundle_sorted = sorted(bundle_policies, key=lambda p: p['metadata']['name'])
        individual_sorted = sorted(individual_policies, key=lambda p: p['metadata']['name'])
        
        assert bundle_sorted == individual_sorted
    
    def test_error_handling_and_recovery(self, workflow):
        """Test error handling and recovery scenarios"""
        # Test invalid template
        with pytest.raises(ValueError) as exc_info:
            workflow.create_policy_from_template('nonexistent', 'test', 'test', 'test')
        assert "Unknown template" in str(exc_info.value)
        
        # Test mixed valid and invalid specs
        mixed_specs = [
            {'name': 'valid-1', 'namespace': 'test', 'app': 'app1'},
            {'name': 'valid-2', 'namespace': 'test', 'app': 'app2', 'template': 'web-frontend'},
            {'name': 'invalid-template', 'namespace': 'test', 'app': 'app3', 'template': 'nonexistent'},
        ]
        
        results = workflow.batch_process_policies(mixed_specs)
        
        # Should have 2 successes, 1 failure
        successes = [r for r in results if r[1]]
        failures = [r for r in results if not r[1]]
        
        assert len(successes) == 2
        assert len(failures) == 1
        assert len(workflow.processed_policies) == 2
        assert len(workflow.validation_errors) == 1
        
        # Verify workflow can continue after errors
        additional_specs = [{'name': 'recovery-policy', 'namespace': 'test', 'app': 'recovery'}]
        additional_results = workflow.batch_process_policies(additional_specs)
        
        assert len(additional_results) == 1
        assert additional_results[0][1] is True  # Should succeed
        assert len(workflow.processed_policies) == 3  # Now have 3 total
    
    def test_comprehensive_report_generation(self, workflow):
        """Test detailed report generation with various scenarios"""
        # Create diverse set of policies
        diverse_specs = [
            {'name': 'frontend-app', 'namespace': 'web', 'app': 'frontend', 'template': 'web-frontend'},
            {'name': 'api-app', 'namespace': 'api', 'app': 'api', 'template': 'api-service'},
            {'name': 'simple-app', 'namespace': 'default', 'app': 'simple'},
            {'name': 'invalid-app', 'namespace': 'test', 'app': '', 'template': 'invalid-template'},  # Will fail
        ]
        
        results = workflow.batch_process_policies(diverse_specs)
        report = workflow.generate_report()
        
        # Verify comprehensive report structure
        assert 'total_policies' in report
        assert 'validation_errors' in report
        assert 'success_rate' in report
        assert 'processed_policies' in report
        assert 'errors' in report
        assert 'operation_log' in report
        
        # Verify report accuracy
        assert report['total_policies'] == 3  # 3 successful
        assert report['validation_errors'] == 1  # 1 failed
        assert report['success_rate'] == 75.0  # 3/4 = 75%
        
        # Verify processed policies details
        processed = report['processed_policies']
        assert len(processed) == 3
        
        # Check specific policy details
        frontend_policy = next(p for p in processed if p['name'] == 'frontend-app')
        assert frontend_policy['namespace'] == 'web'
        assert frontend_policy['app'] == 'frontend'
        assert frontend_policy['has_ingress'] is True
        assert frontend_policy['has_egress'] is False
        
        api_policy = next(p for p in processed if p['name'] == 'api-app')
        assert api_policy['has_ingress'] is True
        assert api_policy['has_egress'] is True
        
        # Verify error tracking
        assert len(report['errors']) == 1
        assert report['errors'][0]['policy'] == 'invalid-app'
        
        # Verify operation log is comprehensive
        assert len(report['operation_log']) > 0
        assert any('Creating policy' in log for log in report['operation_log'])
        assert any('Validated and processed' in log for log in report['operation_log'])


@pytest.mark.integration
class TestRealWorldScenarios:
    """Real-world scenario tests"""
    
    def test_microservices_architecture_policies(self, workflow):
        """Test creating policies for a complete microservices architecture"""
        microservices_specs = [
            {'name': 'api-gateway', 'namespace': 'gateway', 'app': 'nginx', 'template': 'web-frontend'},
            {'name': 'user-service', 'namespace': 'services', 'app': 'user-svc', 'template': 'api-service'},
            {'name': 'order-service', 'namespace': 'services', 'app': 'order-svc', 'template': 'api-service'},
            {'name': 'payment-service', 'namespace': 'services', 'app': 'payment-svc', 'template': 'api-service'},
            {'name': 'user-db', 'namespace': 'databases', 'app': 'user-postgres', 'template': 'database'},
            {'name': 'order-db', 'namespace': 'databases', 'app': 'order-postgres', 'template': 'database'},
            {'name': 'redis-cache', 'namespace': 'cache', 'app': 'redis'},
        ]
        
        results = workflow.batch_process_policies(microservices_specs)
        
        # All should succeed
        assert all(success for _, success, _ in results)
        assert len(workflow.processed_policies) == 7
        
        # Create comprehensive bundle
        bundle_path = workflow.create_policy_bundle('microservices_policies.yaml')
        
        # Verify bundle
        policies = workflow.manager.load_multiple_configs(bundle_path)
        assert len(policies) == 7
        
        # Verify each policy is valid
        for policy in policies:
            assert workflow.manager.validate_network_policy(policy) is True
        
        # Generate architecture report
        report = workflow.generate_report()
        assert report['success_rate'] == 100.0
        
        # Verify namespace distribution
        namespaces = set(p['namespace'] for p in report['processed_policies'])
        expected_namespaces = {'gateway', 'services', 'databases', 'cache'}
        assert namespaces == expected_namespaces
    
    def test_development_to_production_workflow(self, temp_workspace):
        """Test workflow simulating development to production deployment"""
        # Create separate workflows for dev and prod to demonstrate isolation
        dev_workflow = NetworkPolicyWorkflow(temp_workspace)
        prod_workflow = NetworkPolicyWorkflow(temp_workspace)
        
        # Development environment policies
        dev_specs = [
            {'name': 'dev-frontend', 'namespace': 'dev', 'app': 'frontend', 'template': 'web-frontend'},
            {'name': 'dev-api', 'namespace': 'dev', 'app': 'api', 'template': 'api-service'},
        ]
        
        # Process dev policies
        dev_workflow.batch_process_policies(dev_specs)
        dev_bundle = dev_workflow.create_policy_bundle('dev_policies.yaml')
        
        # Production environment policies (similar but different namespace)
        prod_specs = [
            {'name': 'prod-frontend', 'namespace': 'prod', 'app': 'frontend', 'template': 'web-frontend'},
            {'name': 'prod-api', 'namespace': 'prod', 'app': 'api', 'template': 'api-service'},
        ]
        
        # Process prod policies
        prod_workflow.batch_process_policies(prod_specs)
        prod_bundle = prod_workflow.create_policy_bundle('prod_policies.yaml')
        
        # Verify both environments
        dev_policies = dev_workflow.manager.load_multiple_configs(dev_bundle)
        prod_policies = prod_workflow.manager.load_multiple_configs(prod_bundle)
        
        # Should have 2 policies each
        assert len(dev_workflow.processed_policies) == 2
        assert len(prod_workflow.processed_policies) == 2
        
        # Verify namespace separation
        dev_namespaces = {p['metadata']['namespace'] for p in dev_policies}
        prod_namespaces = {p['metadata']['namespace'] for p in prod_policies}
        
        assert dev_namespaces == {'dev'}
        assert prod_namespaces == {'prod'}
        
        # Generate final reports
        dev_report = dev_workflow.generate_report()
        prod_report = prod_workflow.generate_report()
        
        # Verify environment distribution in reports
        dev_report_namespaces = set(p['namespace'] for p in dev_report['processed_policies'])
        prod_report_namespaces = set(p['namespace'] for p in prod_report['processed_policies'])
        
        assert dev_report_namespaces == {'dev'}
        assert prod_report_namespaces == {'prod'}


if __name__ == "__main__":
    # Run comprehensive integration tests with coverage
    print("Running comprehensive integration tests with coverage...")
    pytest.main([
        __file__, 
        '-v', 
        '--cov=../src',
        '--cov-report=term-missing',
        '--cov-report=html:../coverage_html_integration',
        '--cov-branch',
        '-m', 'not slow'  # Skip slow tests unless explicitly requested
    ])
    
    print("\n" + "="*50)
    print("Step 6 Complete: Complete Workflow Integration")
    print("="*50)
    print("Key concepts learned:")
    print("✅ End-to-end workflow integration testing")
    print("✅ Complex fixture management and setup")
    print("✅ Template-based configuration generation")
    print("✅ Batch processing and error handling")
    print("✅ File operations and workspace management")
    print("✅ Comprehensive reporting and logging")
    print("✅ Real-world scenario simulation")
    print("✅ Multi-environment workflow testing")
    print("✅ Integration test organization")
    print("✅ Coverage analysis for complex workflows")
    print("\n📚 Tutorial Complete!")
    print("="*50)
    print("You've mastered:")
    print("🔬 pytest fundamentals and advanced patterns")
    print("📝 YAML processing and validation")
    print("📊 Code coverage analysis and reporting")
    print("🔧 Fixture design and dependency injection")
    print("🧪 Integration testing strategies")
    print("🏗️  Real-world workflow simulation")
    print("\n🎯 Next Steps:")
    print("• Apply these patterns to your own projects")
    print("• Explore pytest plugins and extensions")  
    print("• Implement CI/CD integration with coverage")
    print("• Build domain-specific testing frameworks")
    print("="*50)