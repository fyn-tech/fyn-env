# Fyn-Env

[![License: GPL-3.0](https://img.shields.io/badge/License-GPL--3.0-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![Python 3.10+](https://img.shields.io/badge/Python-3.10%2B-brightgreen.svg)](https://www.python.org/downloads/)
[![Maintenance](https://img.shields.io/badge/Maintained-Yes-green.svg)](https://github.com/fyn-tech/fyn-env/graphs/commit-activity)
[![GitHub issues](https://img.shields.io/github/issues/fyn-tech/fyn-env.svg)](https://github.com/fyn-tech/fyn-env/issues)
[![Part of Fyn-Tech](https://img.shields.io/badge/Part%20of-Fyn--Tech-orange)](https://github.com/fyn-tech)

> Central repository to manage which repo versions are used for production, development, and staging environments.

## Overview

Fyn-Env is the environment coordinator for the [Fyn-Tech](https://github.com/fyn-tech) project, a cloud-based CFD (Computational Fluid Dynamics) solver. This repository manages the deployment configurations and version compatibility across all Fyn-Tech components.

## Purpose

This repository serves as the central configuration point to ensure that all Fyn-Tech components work together. It handles:

- Version management across repositories
- Environment setup (development, staging, production)
- Dependency coordination
- Python virtual environment setup
- Configuration generation

See [Fyn-Tech](https://github.com/fyn-tech) for specific repository details.

> Currently, the 'working' use case is for setting up the development environment in linux. Over time it will be expanded organically to allow for full automated deployments to various environments through gh-actions.

## Setup Instructions

### Prerequisites

- Git
- Python 3.10+
- Bash shell (Linux/macOS) or Git Bash (Windows)

### Basic Usage

```bash
# Clone this repository
git clone https://github.com/fyn-tech/fyn-env.git
cd fyn-env

# Setup development environment
./setup.sh --development --version_file ./versions/version.yaml --output_directory /path/to/custom/directory
```

### Environment Configuration

Configuration for environments is managed in `versions/version.yaml`. This file defines:

- Component versions for each environment
- Python requirements
- Virtual environment names
- Environment descriptions

Example:

```yaml
environments:
  development:
    description: "Development Environment"
    components:
      fyn-env: latest
      fyn-schema: latest
      fyn-api: latest
      fyn-runner: latest
      fyn-frontend: latest
    python:
      requirements: requirements_development.txt
      virtual_env: venv_development
```

## License

This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](LICENSE) file for details.