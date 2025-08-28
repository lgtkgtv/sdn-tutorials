"""
Configuration Manager for Kubernetes NetworkPolicies
Demonstrates YAML processing, validation, and testing patterns
"""
import yaml
import logging
from typing import Dict, List, Optional, Any
from pathlib import Path

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


class ConfigValidationError(Exception):
    """Custom exception for configuration validation errors"""
    pass


class NetworkPolicyConfigManager:
    """
    Manages Kubernetes NetworkPolicy configurations
    Demonstrates pytest, PyYAML, and coverage patterns
    """
    
    def __init__(self):
        self.configs = []
        self.validation_rules = self._setup_validation_rules()
        logger.info("NetworkPolicyConfigManager initialized")
    
    def _setup_validation_rules(self) -> Dict[str, Any]:
        """Setup validation rules for NetworkPolicy YAML"""
        return {
            'required_fields': ['apiVersion', 'kind', 'metadata', 'spec'],
            'api_version': 'networking.k8s.io/v1',
            'kind': 'NetworkPolicy',
            'required_metadata': ['name'],
            'required_spec': ['podSelector'],
            'valid_policy_types': ['Ingress', 'Egress']
        }
    
    def load_config_from_file(self, file_path: str) -> Dict[str, Any]:
        """
        Load YAML configuration from file with error handling
        
        Args:
            file_path: Path to YAML configuration file
            
        Returns:
            Parsed YAML configuration as dictionary
            
        Raises:
            ConfigValidationError: If file cannot be loaded or parsed
        """
        try:
            with open(file_path, 'r') as f:
                config = yaml.safe_load(f)  # Security: Use safe_load
                
            if config is None:
                raise ConfigValidationError(f"Empty configuration file: {file_path}")
                
            logger.info(f"Successfully loaded config from {file_path}")
            return config
            
        except FileNotFoundError:
            raise ConfigValidationError(f"Configuration file not found: {file_path}")
        except yaml.YAMLError as e:
            raise ConfigValidationError(f"Invalid YAML in {file_path}: {e}")
        except Exception as e:
            raise ConfigValidationError(f"Error loading {file_path}: {e}")
    
    def load_multiple_configs(self, file_path: str) -> List[Dict[str, Any]]:
        """
        Load multiple YAML documents from a single file
        
        Args:
            file_path: Path to multi-document YAML file
            
        Returns:
            List of parsed YAML documents
        """
        try:
            with open(file_path, 'r') as f:
                configs = list(yaml.safe_load_all(f))
                
            # Filter out None values (empty documents)
            configs = [config for config in configs if config is not None]
            
            logger.info(f"Loaded {len(configs)} configurations from {file_path}")
            return configs
            
        except Exception as e:
            raise ConfigValidationError(f"Error loading multiple configs: {e}")
    
    def validate_network_policy(self, config: Dict[str, Any]) -> bool:
        """
        Validate NetworkPolicy configuration structure
        
        Args:
            config: NetworkPolicy configuration dictionary
            
        Returns:
            True if valid, raises exception if invalid
            
        Raises:
            ConfigValidationError: If validation fails
        """
        # Check required top-level fields
        missing_fields = []
        for field in self.validation_rules['required_fields']:
            if field not in config:
                missing_fields.append(field)
        
        if missing_fields:
            raise ConfigValidationError(f"Missing required fields: {missing_fields}")
        
        # Validate API version
        if config['apiVersion'] != self.validation_rules['api_version']:
            raise ConfigValidationError(
                f"Invalid apiVersion: {config['apiVersion']}, "
                f"expected: {self.validation_rules['api_version']}"
            )
        
        # Validate kind
        if config['kind'] != self.validation_rules['kind']:
            raise ConfigValidationError(
                f"Invalid kind: {config['kind']}, "
                f"expected: {self.validation_rules['kind']}"
            )
        
        # Validate metadata
        metadata = config['metadata']
        for field in self.validation_rules['required_metadata']:
            if field not in metadata:
                raise ConfigValidationError(f"Missing metadata.{field}")
        
        # Validate spec
        spec = config['spec']
        for field in self.validation_rules['required_spec']:
            if field not in spec:
                raise ConfigValidationError(f"Missing spec.{field}")
        
        # Validate policy types if present
        if 'policyTypes' in spec:
            for policy_type in spec['policyTypes']:
                if policy_type not in self.validation_rules['valid_policy_types']:
                    raise ConfigValidationError(f"Invalid policyType: {policy_type}")
        
        logger.info(f"Validation passed for: {metadata['name']}")
        return True
    
    def generate_basic_policy(self, name: str, namespace: str, 
                            app_label: str) -> Dict[str, Any]:
        """
        Generate a basic NetworkPolicy configuration
        
        Args:
            name: Policy name
            namespace: Kubernetes namespace
            app_label: Application label selector
            
        Returns:
            NetworkPolicy configuration dictionary
        """
        config = {
            'apiVersion': 'networking.k8s.io/v1',
            'kind': 'NetworkPolicy',
            'metadata': {
                'name': name,
                'namespace': namespace,
                'labels': {
                    'generated-by': 'config-manager'
                }
            },
            'spec': {
                'podSelector': {
                    'matchLabels': {
                        'app': app_label
                    }
                },
                'policyTypes': ['Ingress', 'Egress']
            }
        }
        
        logger.info(f"Generated basic policy: {name}")
        return config
    
    def add_ingress_rule(self, config: Dict[str, Any], 
                        from_selectors: List[Dict[str, Any]],
                        ports: Optional[List[Dict[str, Any]]] = None) -> Dict[str, Any]:
        """
        Add ingress rule to NetworkPolicy configuration
        
        Args:
            config: Existing NetworkPolicy configuration
            from_selectors: List of source selectors
            ports: Optional list of port specifications
            
        Returns:
            Updated configuration with ingress rule
        """
        if 'ingress' not in config['spec']:
            config['spec']['ingress'] = []
        
        rule = {'from': from_selectors}
        if ports:
            rule['ports'] = ports
        
        config['spec']['ingress'].append(rule)
        
        # Ensure Ingress is in policyTypes
        if 'Ingress' not in config['spec']['policyTypes']:
            config['spec']['policyTypes'].append('Ingress')
        
        logger.info("Added ingress rule to policy")
        return config
    
    def save_config_to_file(self, config: Dict[str, Any], 
                          file_path: str) -> None:
        """
        Save configuration to YAML file
        
        Args:
            config: Configuration dictionary to save
            file_path: Output file path
        """
        try:
            with open(file_path, 'w') as f:
                yaml.dump(config, f, 
                         default_flow_style=False,
                         sort_keys=False,
                         indent=2)
            
            logger.info(f"Configuration saved to: {file_path}")
            
        except Exception as e:
            raise ConfigValidationError(f"Error saving config: {e}")
    
    def save_multiple_configs(self, configs: List[Dict[str, Any]], 
                            file_path: str) -> None:
        """
        Save multiple configurations to single YAML file
        
        Args:
            configs: List of configuration dictionaries
            file_path: Output file path
        """
        try:
            with open(file_path, 'w') as f:
                yaml.dump_all(configs, f,
                             default_flow_style=False,
                             sort_keys=False,
                             indent=2)
            
            logger.info(f"Saved {len(configs)} configurations to: {file_path}")
            
        except Exception as e:
            raise ConfigValidationError(f"Error saving multiple configs: {e}")
    
    def get_config_summary(self, config: Dict[str, Any]) -> Dict[str, Any]:
        """
        Get summary information about a configuration
        
        Args:
            config: NetworkPolicy configuration
            
        Returns:
            Summary dictionary with key information
        """
        summary = {
            'name': config['metadata']['name'],
            'namespace': config['metadata']['namespace'],
            'app_label': config['spec']['podSelector']['matchLabels']['app'],
            'policy_types': config['spec']['policyTypes'],
            'has_ingress_rules': 'ingress' in config['spec'],
            'has_egress_rules': 'egress' in config['spec']
        }
        
        if 'ingress' in config['spec']:
            summary['ingress_rules_count'] = len(config['spec']['ingress'])
        
        if 'egress' in config['spec']:
            summary['egress_rules_count'] = len(config['spec']['egress'])
        
        return summary