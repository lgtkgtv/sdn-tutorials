# Tutorial 01: Development Environment & Testing Framework

> **Target Audience**: Senior software developers familiar with Docker containers, with limited Kubernetes/KIND/Helm experience

## 🎯 Learning Objectives

By completing this tutorial, you will:
- **Master Kubernetes Network Policies** - Understand pod-to-pod communication control
- **KIND (Kubernetes in Docker)** - Run local Kubernetes clusters for development
- **pytest Framework** - Build robust test suites for infrastructure code
- **YAML Configuration** - Generate and validate Kubernetes manifests
- **Security Testing** - Implement security scanning in development workflows

## 🏗️ Tutorial Architecture

```
Tutorial 01 Components:
┌─────────────────────────────────────────────────────────────┐
│ NetworkPolicyGenerator (Python Class)                      │
│ ├── create_isolation_policy()     # Basic pod isolation    │
│ ├── create_microservice_policy()  # Service-to-service     │
│ ├── validate_policy()             # YAML validation        │
│ └── export_policies()             # Generate manifests     │
└─────────────────────────────────────────────────────────────┘
                               ↓
┌─────────────────────────────────────────────────────────────┐
│ KIND Cluster (Kubernetes in Docker)                        │
│ ├── Control Plane Node (containerized)                     │
│ ├── Network Policies Deployed                              │
│ └── Namespaces: production, staging                        │
└─────────────────────────────────────────────────────────────┘
                               ↓
┌─────────────────────────────────────────────────────────────┐
│ Test Suite (pytest + coverage)                             │
│ ├── Unit Tests: Policy creation & validation               │
│ ├── Integration Tests: KIND cluster deployment             │
│ └── Security Tests: Bandit scanning                        │
└─────────────────────────────────────────────────────────────┘
```

## 🚀 Quick Start

```bash
# 1. Run setup (creates project + installs tools)
./setup.sh

# 2. Navigate to project and activate environment  
cd sdn-everything
source activate.sh

# 3. Run comprehensive tests
cd ..
./test.sh

# 4. Clean up resources
./quick_cleanup.sh
```

## 📋 What Gets Created

The setup creates a complete project structure:

```
01_development_environment_testing_framework/
├── sdn-everything/               # Main project directory
│   ├── src/
│   │   └── network_policies.py  # Core NetworkPolicy generator
│   ├── tests/
│   │   └── test_network_automation.py # Complete test suite
│   ├── venv/                     # Python virtual environment
│   ├── requirements.txt          # Python dependencies
│   └── activate.sh               # Environment activation script
├── docs/                         # Documentation guides
│   ├── PYTEST_YAML_COVERAGE_GUIDE.md # Testing trinity guide
│   └── PYTHON_TOOLS_GUIDE.md     # Code quality tools guide
├── examples/                     # Interactive demonstrations
│   ├── demo_bad_code.py          # Code with violations
│   ├── demo_good_code.py         # Fixed best practices
│   └── run_tools_demo.sh         # Interactive tool demo
├── setup.sh                     # Tutorial setup script
├── test.sh                      # Comprehensive test runner
└── README.md                    # This guide
```

## 🧪 Test Suite Breakdown

### Phase 1: Python Unit Tests (9 tests)

#### 1. **test_basic_policy_creation**
**What it tests**: Core NetworkPolicy YAML generation
```python
# Creates basic isolation policy
policy = generator.create_isolation_policy('test-ns', 'test-app')
# Validates: apiVersion, kind, metadata, namespace, pod selectors
```
**Key validation**: Ensures generated YAML matches Kubernetes NetworkPolicy spec

#### 2. **test_policy_validation** 
**What it tests**: YAML structure validation against Kubernetes API
```python
# Tests both valid and invalid policy structures
assert generator.validate_policy(valid_policy) is True
assert generator.validate_policy(invalid_policy) is False
```
**Key validation**: Prevents deployment of malformed network policies

#### 3. **test_ingress_rules**
**What it tests**: Incoming traffic rules (who can connect TO this pod)
```python
ingress_rules = [{
    'from': [{'podSelector': {'matchLabels': {'app': 'frontend'}}}],
    'ports': [{'protocol': 'TCP', 'port': 8080}]
}]
```
**Real-world scenario**: Frontend pods connecting to API pods on port 8080

#### 4. **test_egress_rules**
**What it tests**: Outgoing traffic rules (what this pod can connect TO)  
```python
egress_rules = [{
    'to': [],  # DNS anywhere
    'ports': [{'protocol': 'UDP', 'port': 53}]
}]
```
**Real-world scenario**: Allowing DNS resolution while blocking other outbound traffic

#### 5. **test_microservice_policy**
**What it tests**: Complex service-to-service communication patterns
```python
policy = generator.create_microservice_policy(
    'production', 'payment-service',
    allowed_services=['order-service', 'user-service'],
    ports=[8080, 9090]
)
```
**Real-world scenario**: Payment service accepting connections only from order/user services

#### 6. **test_policy_export**
**What it tests**: YAML file generation for kubectl deployment
```python
generator.export_policies('output.yaml')
# Validates: File creation, valid YAML syntax, multiple policies in one file
```
**Key validation**: Generated files can be directly applied with `kubectl apply -f`

#### 7. **test_policy_summary**
**What it tests**: Policy management and overview generation
```python
summary = generator.get_policy_summary()
# Returns: total_policies, policy_names, namespaces, apps
```
**Real-world scenario**: Dashboard or reporting on deployed network security

#### 8. **test_default_deny_policy**
**What it tests**: Zero-trust security implementation
```python
# Creates policy that denies ALL traffic by default
assert 'Ingress' in policy['spec']['policyTypes']
assert 'Egress' in policy['spec']['policyTypes'] 
assert 'ingress' not in policy['spec']  # No explicit allow rules
```
**Security implication**: Implements "deny all, allow specific" security model

#### 9. **test_complete_workflow**
**What it tests**: End-to-end realistic microservices scenario
```python
# Creates: web-frontend → api-backend → database
# Validates: Three-tier architecture with proper isolation
```

### Phase 2: Kubernetes Integration Tests

#### **KIND Cluster Creation**
```bash
kind create cluster --name tutorial-cluster
# Creates: Single-node Kubernetes cluster in Docker container
# Network: Bridge network allowing kubectl access
```
**Docker Context**: Similar to `docker run` but for entire Kubernetes cluster

#### **Namespace Creation & Policy Deployment**
```bash
kubectl create namespace production
kubectl create namespace staging
kubectl apply -f network-policies.yaml
```
**Validation**: 3 NetworkPolicy resources deployed across namespaces

### Phase 3: Security & Code Quality

#### **Bandit Security Scanning**
- **Scans for**: Hardcoded secrets, insecure functions, SQL injection risks
- **Output**: JSON report with security findings
- **Integration**: Fails CI/CD if high-severity issues found

#### **Code Quality Checks**
- **Black**: Python code formatting
- **Flake8**: Style guide enforcement (PEP 8)
- **Coverage**: Test coverage measurement

## 🔧 Key Kubernetes Concepts for Docker Users

### NetworkPolicy vs Docker Networks

| Docker Networks | Kubernetes NetworkPolicy |
|-----------------|---------------------------|
| `docker network create` | NetworkPolicy YAML manifest |
| Container-to-container | Pod-to-pod communication |
| Bridge/Overlay networks | CNI (Container Network Interface) |
| `--link` deprecated | Label selectors + rules |

### KIND (Kubernetes in Docker)

**Think of KIND as**: `docker-compose` but for entire Kubernetes clusters

```bash
# Similar concept to docker-compose up
kind create cluster --name tutorial-cluster

# Similar to docker ps (but for Kubernetes nodes)  
kubectl get nodes

# Similar to docker exec (but for Kubernetes pods)
kubectl exec -it <pod-name> -- /bin/bash
```

**Key Difference**: KIND runs Kubernetes control plane components (API server, etcd, scheduler) inside Docker containers, giving you a real Kubernetes API to work with.

## 📊 Test Results Interpretation

### ✅ Success Indicators
```
================================ 9 passed in 0.03s ============================
✅ All Python tests passed!
✅ No high severity security issues found
✅ Network policies deployed to cluster
📊 3 network policies active in cluster
```

### ❌ Common Failure Scenarios

**KIND cluster issues**:
```bash
# Problem: Docker not running
Error: failed to create cluster: docker not available

# Solution: Start Docker daemon
sudo systemctl start docker
```

**NetworkPolicy deployment failures**:
```bash
# Problem: Namespaces don't exist  
Error: namespaces "production" not found

# Solution: Script now auto-creates namespaces before deployment
```

## 🎯 Real-World Applications

### Scenario 1: E-commerce Microservices
```python
# Frontend can only talk to API gateway
frontend_policy = create_isolation_policy('web', 'frontend', 
    allowed_egress=[{'to': [{'podSelector': {'matchLabels': {'app': 'api-gateway'}}}]}]
)

# Payment service isolated from direct frontend access
payment_policy = create_isolation_policy('payments', 'payment-service',
    allowed_ingress=[{'from': [{'podSelector': {'matchLabels': {'app': 'order-service'}}}]}]
)
```

### Scenario 2: Multi-tenant SaaS Platform
```python
# Tenant isolation using namespace-based policies
tenant_a_policy = create_isolation_policy('tenant-a', 'app',
    # Can only communicate within tenant-a namespace
    allowed_ingress=[{'from': [{'namespaceSelector': {'matchLabels': {'tenant': 'a'}}}]}]
)
```

## 🛠️ Environment Details

**Python Environment**: Virtual environment with pinned dependencies
**Kubernetes Version**: Latest stable (via KIND)
**Container Runtime**: Docker (KIND uses Docker containers as nodes)
**Test Framework**: pytest with coverage reporting
**Security Tools**: Bandit for Python security scanning

## 🚨 Troubleshooting

### Docker Permission Issues
```bash
# Add user to docker group (requires logout/login)
sudo usermod -aG docker $USER
```

### Kubernetes Context Issues
```bash
# Verify KIND cluster context
kubectl config current-context
# Should show: kind-tutorial-cluster
```

### Python Import Issues
```bash
# Verify virtual environment activation
which python
# Should show: /path/to/sdn-everything/venv/bin/python
```

## 🎯 Next Steps

After mastering Tutorial 01:
1. **Tutorial 02**: Infrastructure as Code with Terraform + Ansible
2. **Kubernetes Deep Dive**: Explore Service Mesh (Istio) for advanced traffic management
3. **Production Deployment**: Apply NetworkPolicies in real clusters
4. **Security Hardening**: Implement Pod Security Standards + Network Segmentation

## 📚 Tutorial Documentation

### 📖 Deep Dive Guides
- **[Testing Trinity Guide](./docs/PYTEST_YAML_COVERAGE_GUIDE.md)** - Complete guide to pytest, PyYAML, and pytest-cov
- **[Python Tools Arsenal](./docs/PYTHON_TOOLS_GUIDE.md)** - Comprehensive guide to bandit, safety, flake8, black, isort, mypy

### 🛠️ Interactive Examples
- **[Tools Demonstration](./examples/)** - Hands-on examples showing all tools in action
  - `demo_bad_code.py` - Code with intentional violations
  - `demo_good_code.py` - Fixed version following best practices  
  - `run_tools_demo.sh` - Interactive script to run all tools

```bash
# Try the interactive demo
cd examples/
./run_tools_demo.sh
```

## 📚 External Resources

- [Kubernetes NetworkPolicy Documentation](https://kubernetes.io/docs/concepts/services-networking/network-policies/)
- [KIND Local Development Guide](https://kind.sigs.k8s.io/docs/user/quick-start/)
- [pytest Best Practices](https://docs.pytest.org/en/stable/goodpractices.html)
- [Container Network Security](https://kubernetes.io/docs/concepts/security/)