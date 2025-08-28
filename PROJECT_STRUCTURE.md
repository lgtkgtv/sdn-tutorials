# 📁 Project Structure Guide

## 🏗️ Clean Architecture Overview

```
sdn-tutorials/
├── README.md                          # Main project overview
├── PROJECT_STRUCTURE.md               # This file
├── tutorial_usage_instructions.md     # How to use tutorials
├── .gitignore                         # Ignores runtime artifacts
│
├── 01_development_environment_testing_framework/
│   ├── README.md                      # Tutorial 01 main guide
│   ├── setup.sh                      # Tutorial 01 setup
│   ├── test.sh                       # Tutorial 01 testing
│   ├── cleanup.sh                    # Tutorial 01 cleanup
│   ├── quick_cleanup.sh              # Quick cleanup
│   │
│   ├── pytest_yaml_tutorial/         # Standalone pytest/YAML tutorial
│   │   ├── README.md                 # Complete pytest guide
│   │   ├── run_tutorial.sh          # Interactive tutorial
│   │   ├── requirements.txt          # Python dependencies
│   │   ├── src/config_manager.py     # Source code
│   │   ├── tests/test_*.py           # Test suite
│   │   ├── examples/step*.py         # Step-by-step examples
│   │   └── sample_configs/*.yaml     # YAML examples
│   │
│   └── code_quality_security_tools/  # Standalone code quality tutorial
│       ├── README.md                 # Complete tools guide
│       ├── run_tutorial.sh          # Interactive tutorial
│       ├── requirements.txt          # Tool dependencies
│       ├── examples/step*.py         # Step-by-step examples
│       ├── bad_code/*.py            # Intentional violations
│       └── good_code/*.py           # Fixed examples
│
├── 02_infrastructure_as_code_foundations/
│   ├── README.md                      # Tutorial 02 guide
│   ├── setup.sh                      # Setup script
│   ├── test.sh                       # Testing script
│   ├── cleanup.sh                    # Cleanup script
│   └── quick_cleanup.sh              # Quick cleanup
│
├── 03_sdn_controller_integration_opendaylight_lighty/
├── 04_cloud_native_network_functions_nephio/
├── 05_production_network_automation_onap_kubernetes/
├── 06_multicloud_network_orchestration_onap_advanced/
└── 07_ai_driven_network_operations_essedum_integration/
```

## 🎯 Key Design Principles

### ✅ **What We Kept**
- **Single main README.md** - Project overview and tutorial index
- **Tutorial-specific README.md** - Detailed guides for each tutorial
- **Standalone subdirectories** - Self-contained with no parent dependencies
- **Essential scripts** - setup.sh, test.sh, cleanup.sh for each tutorial

### 🗑️ **What We Removed**
- **Duplicate root scripts** - `setup-sdn-tutorial.sh`, `test-sdn-tutorial.sh`, etc.
- **Redundant docs/** - Content now in standalone tutorials
- **Redundant examples/** - Content now in standalone tutorials  
- **Runtime artifacts** - `coverage_html/`, `venv/`, `sdn-everything/`
- **Duplicate sdn-everything/** - Runtime-generated directories

### 🔒 **Runtime Artifacts (Auto-ignored)**
These directories/files are created during tutorial execution and ignored by git:
- `coverage_html/` - pytest-cov HTML reports
- `venv/` - Virtual environments
- `sdn-everything/` - Tutorial runtime workspace
- `sample_project/` - Generated sample projects
- `reports/` - Tool analysis reports
- `demo_fixes/` - Temporary demonstration files

## 📚 **Documentation Structure**

| File | Purpose | Audience |
|------|---------|----------|
| `README.md` | Project overview, tutorial index | All users |
| `tutorial_usage_instructions.md` | How to run tutorials | New users |
| `01_*/README.md` | Tutorial 01 comprehensive guide | Tutorial users |
| `pytest_yaml_tutorial/README.md` | Standalone pytest guide | pytest learners |
| `code_quality_security_tools/README.md` | Standalone tools guide | Quality-focused developers |

## 🚀 **Quick Start**

### For Complete SDN Learning Path:
```bash
# Start with Tutorial 01
cd 01_development_environment_testing_framework
./setup.sh
./test.sh
```

### For Specific Skills:
```bash
# Just pytest and YAML processing
cd 01_development_environment_testing_framework/pytest_yaml_tutorial
./run_tutorial.sh

# Just code quality and security tools
cd 01_development_environment_testing_framework/code_quality_security_tools  
./run_tutorial.sh
```

## 🔧 **Maintenance Guidelines**

1. **No duplicate content** - Each README serves a specific purpose
2. **Runtime artifacts** - Always add to .gitignore, never commit
3. **Standalone tutorials** - Should work without parent directory dependencies
4. **Script consistency** - Each tutorial has setup.sh, test.sh, cleanup.sh
5. **Documentation sync** - Keep main README.md tutorial table updated

---

**Minimal, clean, and focused structure for maximum learning efficiency! 🎯**