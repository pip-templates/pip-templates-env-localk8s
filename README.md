# Overview

This is a built-in module to environment [pip-templates-env-master](https://github.com/pip-templates/pip-templates-env-master). 
This module stores scripts for management local kubernetes environment.

# Usage

- Download this repository
- Copy *src* folder to master template
- Add content of *.ps1.add* files to correspondent files from master template
- Add content of *config/config.k8s.json.add* to json config file from master template and set the required values

# Config parameters

Config variables description

| Variable | Default value | Description |
|----|----|---|
| env_type | local | Type of kubernetes environment |
| minikube_home |  | Path to minikube home directory. Can be empty |
| k8s_version | v1.9.4 | Version of installing kubernetes |
| k8s_driver | virtualbox | Name of kubernetes driver |
| k8s_memory | 8198 | Allocated memory for minikube virtual machine |
| k8s_cpus | 2 | Allocated cpu for minikube virtual machine |
