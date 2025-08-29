# Tutorial 05: Production Network Automation with ONAP & Kubernetes

## Overview

This tutorial demonstrates production-grade network automation using the Open Network Automation Platform (ONAP) deployed on Kubernetes. You'll learn to build, deploy, and manage enterprise network services with ONAP's microservices architecture.

## Learning Objectives

By completing this tutorial, you will:

1. **Deploy ONAP Platform**: Set up a production-ready ONAP deployment on Kubernetes
2. **Design Network Services**: Create VNF/CNF service models using the Service Design and Creation (SDC) component
3. **Orchestrate Service Lifecycle**: Use SO (Service Orchestrator) for automated service provisioning
4. **Implement Policy Management**: Configure policy-driven automation with Policy Framework
5. **Monitor and Analyze**: Utilize DCAE (Data Collection, Analytics & Events) for network insights
6. **Automate Operations**: Build closed-loop automation with CLAMP and CDS
7. **Integrate with Legacy Systems**: Connect ONAP with existing network management platforms

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                    ONAP Production Platform                     │
├─────────────────────┬───────────────────┬───────────────────────┤
│   Design Time       │   Runtime         │   Analytics & Policy  │
│                     │                   │                       │
│  ┌─────────────┐   │  ┌─────────────┐  │  ┌─────────────────┐  │
│  │     SDC     │   │  │     SO      │  │  │      DCAE       │  │
│  │ (Service    │   │  │ (Service    │  │  │ (Data Collection│  │
│  │  Design)    │   │  │Orchestrator)│  │  │ & Analytics)    │  │
│  └─────────────┘   │  └─────────────┘  │  └─────────────────┘  │
│                     │                   │                       │
│  ┌─────────────┐   │  ┌─────────────┐  │  ┌─────────────────┐  │
│  │    VID      │   │  │    SDNC     │  │  │     Policy      │  │
│  │ (Virtual    │   │  │ (SDN        │  │  │   Framework     │  │
│  │Infrastructure│   │  │Controller)  │  │  └─────────────────┘  │
│  │  Deployment)│   │  └─────────────┘  │                       │
│  └─────────────┘   │                   │  ┌─────────────────┐  │
│                     │  ┌─────────────┐  │  │     CLAMP       │  │
│  ┌─────────────┐   │  │    APPC     │  │  │ (Control Loop   │  │
│  │    CDS      │   │  │(Application │  │  │ Automation      │  │
│  │(Controller  │   │  │Controller)  │  │  │ Management)     │  │
│  │Design Studio)│   │  └─────────────┘  │  └─────────────────┘  │
│  └─────────────┘   │                   │                       │
└─────────────────────┴───────────────────┴───────────────────────┘
                              │
        ┌─────────────────────────────────────────────────┐
        │           Kubernetes Infrastructure              │
        │                                                 │
        │  ┌──────────┐ ┌──────────┐ ┌──────────────────┐ │
        │  │  ONAP    │ │   CNF    │ │    External      │ │
        │  │Services  │ │Workloads │ │   Integrations   │ │
        │  └──────────┘ └──────────┘ └──────────────────┘ │
        └─────────────────────────────────────────────────┘
```

## Real-World Applications

This tutorial simulates production scenarios including:

- **Enterprise Network Automation**: Large-scale VNF/CNF deployment and lifecycle management
- **5G Network Slicing**: Dynamic slice creation and management using ONAP orchestration
- **Hybrid Cloud Networking**: Multi-cloud network service orchestration
- **Intent-Based Networking**: Policy-driven network automation and optimization
- **Telecom Service Provider Operations**: End-to-end service lifecycle automation

## Prerequisites

- Kubernetes cluster (minimum 8 cores, 32GB RAM)
- Helm 3.x
- kubectl configured and authenticated
- Basic understanding of microservices architecture
- Familiarity with network automation concepts

## Tutorial Structure

```
05_production_network_automation_onap_kubernetes/
├── README.md                          # This file
├── setup.sh                          # Environment setup and ONAP deployment
├── test.sh                           # Comprehensive testing suite
├── cleanup.sh                        # Interactive cleanup script
├── quick_cleanup.sh                  # Fast cleanup script
├── onap_workspace/                   # Created by setup.sh
│   ├── venv/                        # Python virtual environment
│   ├── bin/                         # Local tool installations
│   ├── onap-helm-charts/           # ONAP Helm charts
│   ├── service-models/             # VNF/CNF service templates
│   ├── python-automation/          # ONAP automation scripts
│   ├── policy-models/              # Policy framework templates
│   ├── monitoring-dashboards/      # Grafana/Kibana dashboards
│   └── integration-adapters/       # External system integrations
└── docs/                           # Additional documentation
    ├── onap-architecture.md        # Detailed ONAP architecture
    ├── service-modeling.md         # Service design guide
    └── troubleshooting.md          # Common issues and solutions
```

## Key Components Implemented

### 1. ONAP Core Platform
- **Service Design and Creation (SDC)**: VNF/CNF modeling and catalog
- **Service Orchestrator (SO)**: Automated service lifecycle management
- **SDN Controller (SDNC)**: Network configuration and management
- **Application Controller (APPC)**: VNF lifecycle management

### 2. Analytics and Intelligence
- **DCAE Platform**: Real-time data collection and analytics
- **Policy Framework**: Intent-based policy management and enforcement
- **Holmes**: Root cause analysis and correlation
- **CLAMP**: Closed-loop automation management

### 3. User Interfaces and APIs
- **VID (Virtual Infrastructure Deployment)**: Self-service portal
- **Portal Platform**: Unified ONAP web portal
- **External API**: Integration with external systems

### 4. Automation and Integration
- **Controller Design Studio (CDS)**: Model-driven automation
- **MultiCloud Framework**: Multi-VIM integration
- **External System Adapters**: Legacy system integration

## Network Service Examples

This tutorial includes several production-ready service examples:

### Enterprise vFirewall Service
```yaml
service_type: vnf
vnf_type: vFirewall
vendor: Generic
version: 1.0.0
deployment_target: kubernetes
resources:
  cpu: 2
  memory: 4Gi
  storage: 20Gi
interfaces:
  - name: management
    type: internal
  - name: public
    type: external
  - name: private
    type: internal
```

### 5G Network Slice Template
```yaml
slice_type: eMBB
service_category: NetworkSlicing
instantiation_level: production
network_functions:
  - amf
  - smf
  - upf
  - ausf
sla_requirements:
  latency: 10ms
  throughput: 1Gbps
  availability: 99.99%
```

## Getting Started

1. **Environment Setup**:
   ```bash
   ./setup.sh
   ```

2. **Run Tests**:
   ```bash
   ./test.sh
   ```

3. **Access ONAP Portal**:
   ```bash
   # Portal will be available at:
   # https://localhost:8443/ONAPPORTAL/login.htm
   # Default credentials: demo/demo123456!
   ```

4. **Deploy Sample Service**:
   ```bash
   cd onap_workspace
   source venv/bin/activate
   python python-automation/deploy_vfirewall.py
   ```

## Advanced Features

### Policy-Based Automation
Implement intent-based networking with ONAP's Policy Framework:

```python
# Example: Auto-scaling policy
policy = {
    "policy_name": "vnf_auto_scaling",
    "policy_type": "operational",
    "target": "vFirewall_VNF",
    "condition": "cpu_utilization > 80%",
    "action": "scale_out",
    "parameters": {
        "scale_factor": 2,
        "max_instances": 10
    }
}
```

### Closed-Loop Automation
Use CLAMP for automated network optimization:

```yaml
# Control loop configuration
control_loop:
  name: "Network_Optimization_Loop"
  trigger: "performance_degradation"
  analytics:
    - holmes_correlation
    - dcae_analytics
  policies:
    - traffic_steering_policy
    - resource_optimization_policy
  actions:
    - reconfigure_vnf
    - reallocate_resources
```

## Monitoring and Observability

The tutorial includes comprehensive monitoring setup:

- **Prometheus**: Metrics collection from ONAP components
- **Grafana**: Visualization dashboards for service performance
- **Elasticsearch**: Log aggregation and analysis
- **Kibana**: Log visualization and troubleshooting

## Testing Scenarios

The test suite validates:

1. **ONAP Platform Deployment**: All microservices healthy and communicating
2. **Service Modeling**: SDC catalog operations and model validation
3. **Service Orchestration**: End-to-end service deployment via SO
4. **Policy Enforcement**: Policy framework rule execution
5. **Analytics Pipeline**: DCAE data collection and processing
6. **Closed-Loop Operation**: CLAMP automation workflows
7. **Multi-VIM Integration**: Deployment across multiple cloud environments

## Production Considerations

This tutorial addresses real production concerns:

- **High Availability**: Multi-node deployment with failover
- **Security**: HTTPS, RBAC, and encrypted communication
- **Scalability**: Horizontal scaling of ONAP microservices
- **Performance**: Resource optimization and monitoring
- **Backup/Recovery**: Data persistence and disaster recovery
- **Integration**: APIs for external system connectivity

## Troubleshooting

Common issues and solutions:

- **Pod Startup Issues**: Resource constraints and dependency ordering
- **Service Discovery**: Kubernetes DNS and service mesh configuration
- **Performance Problems**: Resource allocation and JVM tuning
- **Integration Failures**: Network connectivity and authentication

## Next Steps

After completing this tutorial:

1. Explore ONAP community resources and documentation
2. Contribute to ONAP open source projects
3. Implement custom VNFs and CNFs
4. Integrate with your organization's existing network management systems
5. Proceed to Tutorial 06 for multi-cloud orchestration scenarios

## Resources

- [ONAP Official Documentation](https://docs.onap.org)
- [ONAP Architecture Guide](https://wiki.onap.org/display/DW/ONAP+Architecture)
- [Kubernetes ONAP Deployment Guide](https://docs.onap.org/projects/onap-oom/en/latest/)
- [ONAP Use Cases](https://wiki.onap.org/display/DW/Use+Cases)

---

**Note**: This tutorial is designed for educational purposes and demonstrates ONAP's capabilities in a controlled environment. For production deployments, additional considerations for security, scalability, and integration are required.