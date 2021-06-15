# Overview

This is a built-in module to environment [pip-templates-env-master](https://github.com/pip-templates/pip-templates-env-master). 
This module stores scripts for management local kubernetes environment.

# Usage

- Download this repository
- Copy *kubernetes* folder to master template
- Copy *common/context.ps1* to master template
- Add content of *.ps1.add* files to correspondent files from master template
- Add content of *config/config.k8s.json.add* to json config file from master template and set the required values

# Config parameters

Config variables description

| Variable | Default value | Description |
|----|----|---|
| environment.type | local | Type of the environment |
| environment.version | local | Version of the environment |
| k8s.minikube_home |  | Path to minikube home directory. Can be empty |
| k8s.version | v1.20.2 | Version of installing kubernetes |
| k8s.driver | docker | Name of kubernetes driver |
| k8s.memory | 8198 | Allocated memory for minikube virtual machine |
| k8s.cpus | 2 | Allocated cpu for minikube virtual machine |
| k8s.namespace | infra | Kubernetes namespace for components and services |
| k8s.blobs_storage_gb | 5 | Size of blobs persistence storage |
