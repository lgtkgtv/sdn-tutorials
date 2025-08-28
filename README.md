# 🌐 SDN Tutorials

> A comprehensive series of 7 hands-on tutorials covering Software-Defined Networking (SDN) from development basics to AI-driven network operations.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Python 3.8+](https://img.shields.io/badge/python-3.8+-blue.svg)](https://www.python.org/downloads/)
[![Tutorials](https://img.shields.io/badge/tutorials-7-green.svg)](#tutorial-series-overview)

## 🎯 Tutorial Series Overview

### 📚 Complete Learning Path

| Tutorial | Focus Area | Technologies | Status |
|----------|------------|--------------|--------|
| **01** | [Development Environment & Testing](./01_development_environment_testing_framework/) | Python, pytest, Kubernetes, Docker | ✅ Complete |
| **02** | [Infrastructure as Code Foundations](./02_infrastructure_as_code_foundations/) | Terraform, Ansible, Network Automation | ✅ Complete |
| **03** | [SDN Controller Integration](./03_sdn_controller_integration_opendaylight_lighty/) | OpenDaylight, Lighty.io, YANG | 🚧 Coming Soon |
| **04** | [Cloud-Native Network Functions](./04_cloud_native_network_functions_nephio/) | Nephio, Kubernetes CNFs | 🚧 Coming Soon |
| **05** | [Production Network Automation](./05_production_network_automation_onap_kubernetes/) | ONAP, Kubernetes, Production | 🚧 Coming Soon |
| **06** | [Multi-Cloud Network Orchestration](./06_multicloud_network_orchestration_onap_advanced/) | ONAP Advanced, Multi-cloud | 🚧 Coming Soon |
| **07** | [AI-Driven Network Operations](./07_ai_driven_network_operations_essedum_integration/) | AI/ML, Essedum, NetOps | 🚧 Coming Soon |

### 🔥 Tutorial Details

#### 🛠️ Tutorial 01: Development Environment & Testing Framework
**Learn the foundations of SDN development and testing**
- ✅ Python development environment setup  
- ✅ Kubernetes network policy automation
- ✅ Comprehensive testing frameworks
- ✅ Docker container orchestration

#### 🏗️ Tutorial 02: Infrastructure as Code Foundations  
**Master network automation with modern IaC tools**
- ✅ Terraform network provisioning
- ✅ Ansible configuration management
- ✅ Docker network simulation
- ✅ Security scanning and validation

#### 🎛️ Tutorial 03: SDN Controller Integration *(Coming Soon)*
**Deep dive into SDN controller programming**
- 🔄 OpenDaylight controller setup
- 🔄 Lighty.io framework integration  
- 🔄 YANG model development
- 🔄 REST API programming

#### ☁️ Tutorial 04: Cloud-Native Network Functions *(Coming Soon)*
**Build CNFs with Kubernetes and Nephio**
- 🔄 Nephio framework mastery
- 🔄 Kubernetes CNF development
- 🔄 Service mesh integration
- 🔄 Cloud-native patterns

#### 🏭 Tutorial 05: Production Network Automation *(Coming Soon)*
**Scale to production with ONAP and Kubernetes**
- 🔄 ONAP platform deployment
- 🔄 Production-grade workflows
- 🔄 Monitoring and observability
- 🔄 DevOps integration

#### 🌍 Tutorial 06: Multi-Cloud Network Orchestration *(Coming Soon)*
**Advanced ONAP for multi-cloud scenarios**
- 🔄 Cross-cloud orchestration
- 🔄 Advanced ONAP features
- 🔄 Hybrid cloud networking
- 🔄 Global load balancing

#### 🤖 Tutorial 07: AI-Driven Network Operations *(Coming Soon)*
**Apply AI/ML to network operations**
- 🔄 Essedum platform integration
- 🔄 Machine learning for NetOps
- 🔄 Intelligent automation
- 🔄 Predictive analytics

## 🚀 Quick Start

### Option 1: Start with Tutorial 01 (Recommended)
```bash
# Clone the repository
git clone https://github.com/your-username/sdn-tutorials.git
cd sdn-tutorials/01_development_environment_testing_framework

# Run setup (installs dependencies and creates project)
./setup.sh

# Run tests to validate setup
./test.sh

# Clean up when done
./quick_cleanup.sh
```

### Option 2: Jump to Any Tutorial
```bash
cd 02_infrastructure_as_code_foundations  # Or any tutorial 01-07
./setup.sh    # One-command setup
./test.sh     # Comprehensive testing
```

### Option 3: Focused Learning (Standalone Tutorials)
```bash
# Just pytest and YAML processing
cd 01_development_environment_testing_framework/pytest_yaml_tutorial
./run_tutorial.sh

# Just code quality and security tools
cd 01_development_environment_testing_framework/code_quality_security_tools
./run_tutorial.sh
```

## 📋 Prerequisites

| Tool | Version | Purpose |
|------|---------|---------|
| **Docker** | 20.10+ | Container orchestration |
| **Python** | 3.8+ | Development environment |
| **Git** | 2.20+ | Version control |
| **curl** | Latest | Download utilities |

### Optional but Recommended
- **kubectl** - Kubernetes CLI
- **kind/minikube** - Local Kubernetes clusters
- **VS Code** - Development environment

## 📁 Project Structure

```
🌐 sdn-tutorials/
├── 📖 README.md                                          # This file
├── 📄 GIT_SETUP.md                                       # Repository setup guide
├── 
├── 🛠️  01_development_environment_testing_framework/      # Tutorial 01
│   ├── setup.sh                                         # Environment setup
│   ├── test.sh                                          # Run tests
│   ├── cleanup.sh                                       # Interactive cleanup
│   ├── quick_cleanup.sh                                 # Fast cleanup
│   └── 📖 README.md                                     # Tutorial guide
│
├── 🏗️  02_infrastructure_as_code_foundations/             # Tutorial 02  
│   ├── setup.sh                                         # Terraform + Ansible
│   ├── test.sh                                          # IaC validation
│   ├── cleanup.sh                                       # Resource cleanup
│   ├── quick_cleanup.sh                                 # Fast cleanup
│   └── 📖 README.md                                     # IaC guide
│
├── 🎛️  03_sdn_controller_integration_opendaylight_lighty/ # Tutorial 03
├── ☁️  04_cloud_native_network_functions_nephio/         # Tutorial 04
├── 🏭 05_production_network_automation_onap_kubernetes/  # Tutorial 05
├── 🌍 06_multicloud_network_orchestration_onap_advanced/ # Tutorial 06
└── 🤖 07_ai_driven_network_operations_essedum_integration/ # Tutorial 07
```

## 🎓 Learning Approach

### 🎯 **Progressive Complexity**
- Start simple, build advanced concepts gradually
- Each tutorial builds on previous knowledge
- Hands-on practice with real tools

### 🔄 **Consistent Structure**
Every tutorial includes:
- ✅ **setup.sh** - One-command environment setup
- ✅ **test.sh** - Comprehensive validation and testing  
- ✅ **cleanup.sh** - Interactive cleanup with options
- ✅ **quick_cleanup.sh** - Fast, non-interactive cleanup
- ✅ **README.md** - Detailed tutorial guide

### 🛠️ **Production-Ready**
- Industry-standard tools and practices
- Security scanning and validation
- Real-world scenarios and use cases

## 💡 Pro Tips

1. **🔄 Start Fresh**: Use `./quick_cleanup.sh` between tutorial runs
2. **📚 Read First**: Check each tutorial's README.md for specific requirements  
3. **🧪 Test Everything**: Run `./test.sh` to validate your setup
4. **🚨 Troubleshoot**: Check logs in each tutorial's directory
5. **🔧 Customize**: Modify environment variables in setup scripts

## 🤝 Contributing

We welcome contributions! Here's how:

1. **🍴 Fork** the repository
2. **🌟 Create** a feature branch (`git checkout -b feature/amazing-tutorial`)
3. **✨ Commit** your changes (`git commit -m 'Add amazing tutorial'`)
4. **🚀 Push** to the branch (`git push origin feature/amazing-tutorial`)  
5. **📥 Open** a Pull Request

### 🐛 Report Issues
Found a bug? [Open an issue](https://github.com/your-username/sdn-tutorials/issues) with:
- Tutorial name and step where issue occurs
- Error messages and logs
- Your environment details (OS, Docker version, etc.)

## 📜 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **OpenDaylight** community for SDN controller framework
- **ONAP** project for network automation platform  
- **Nephio** team for Kubernetes CNF orchestration
- **Terraform** and **Ansible** communities for IaC tools
- All contributors and tutorial users

---

<div align="center">

**⭐ Star this repo if you find it helpful!**

[🐛 Report Bug](https://github.com/your-username/sdn-tutorials/issues) • [✨ Request Feature](https://github.com/your-username/sdn-tutorials/issues) • [📖 Documentation](https://github.com/your-username/sdn-tutorials/wiki)

</div>