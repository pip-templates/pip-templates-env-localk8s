# Overview
Scriptable environments introduce “infrastructure as a code” into devops practices. They allow to:

* Have controllable and verifiable environment structure
* Quickly spin up fully-functional environments in minutes
* Minimize differences between environments
* Provide developers with environment to run and test their components integrated into the final system and expand their area of responsibilities

# Syntax
All sripts have one required paramenter - *$ConfigPath*. This is the path to config, path can be absolute or relative. 

**Examples of installing lokalk8s**
Relative path example:
`
./local/install_k8s.ps1 ./config/local_config.json
`
Absolute path example:
`
~/pip-templates-env-localk8s/local/install_k8s.ps1 ~/pip-templates-env-localk8s/config/local_config.json
`

**Example delete script**
`
./local/destroy_k8s.ps1 ./config/local_config.json
`

Also you can install environment using single script:
`
./create_env.ps1 ./config/local_config.json
`

Delete whole environment:
`
./delete_env.ps1 ./config/local_config.json
`

If you have any problem with not installed tools - use `install_prereq_` script for you type of operation system.

# Project structure
| Folder | Description |
|----|----|
| Config | Config files for scripts. Store *example* configs for each environment, recomendation is not change this files with actual values, set actual values in duplicate config files without *example* in name. Also stores *resources* files, created automaticaly. | 
| Lib | Scripts with support functions like working with configs, templates etc. | 
| Local | Scripts related to management local environment | 
| Temp | Folder for storing automaticaly created temporary files. | 
| Templates | Folder for storing templates, such as kubernetes yml files, az resource manager json files, ansible playbooks, etc. | 

# Environment types
There are 3 types of enviroment: 

* Cloud - resources created by azure resource manager, use azure kubernetes services (AKS) for deploying kubernetes cluster, etc.
* On premises - use existing instances and via ansible install kubernetes cluster using kubeadm. Also created install azure virtual machines script to simulate existing instances.
* Local - use minikube to install kubernetes cluster. 

### Local environment

* Local config parameters

| Variable | Default value | Description |
|----|----|---|
| env_type | local | Type of environment |
| minikube_home |  | Path of *.minikube* folder, if it is not located in home directory.  |
| k8s_version | v1.9.4 | Kuberntes cluster version |
| k8s_driver | virtualbox | Driver for minikube kubernetes cluster |
| k8s_memory | 8198 | Memory allocated to minikube vm |
| k8s_cpus | 2 | Minikube cpu |

# Known issues

* Local kubernetes installation failed `Error starting host: Error getting state for host: machine does not exist`
Fixed by removing `~/.minikube` folder.
