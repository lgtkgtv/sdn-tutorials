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
