# Colombia-Wisconsin One Health Consortium genomics protocols 


This repository includes the necessary files for carrying out the protocols at the Colombia Wisconsin OH computational resources, including ABACO and Protek.

The protocols have been tested with Miniconda 3 in Ubuntu 20.04 and CentOS 7.5.

All tasks should be carried inside a folder called "local" or outside of the repo's folder to avoid cluttering it with unnecessary files.


### Installing Miniconda 3 (Bash):

- wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
- bash Miniconda3-latest-Linux-x86_64.sh -b -p ~/miniconda3 [or] /miniconda3/bin
- rm Miniconda3-latest-Linux-x86_64.sh

### Set group permissions [only if installed in opt as root]

- Follow Anaconda's tutorial for multi-user group ownership: https://docs.anaconda.com/anaconda/install/multi-user/ . If using CentOS, add users to groups as per: https://linuxconfig.org/redhat-8-add-user-to-group
- setfacl -d -m group:miniconda3:rwx /opt/miniconda3/
- setfacl -m group:miniconda3:rwx /opt/miniconda3/


### Enabling Miniconda 3 (Bash):

- cd ~/miniconda3/bin [or] cd /miniconda3/bin
- ./conda init
- [only if installed in opt] conda config --prepend envs_dirs /opt/miniconda3/envs
- [only if installed in opt] conda config --prepend pkgs_dirs /opt/miniconda3/pkgs



### Download or clone the repository:

- git clone https://github.com/alceballosa/cw_onehealth_protocols (must be logged into github)
- cd cw_onehealth_protocols

### Creating the ohgenom environment

- conda env create -f environment.yml
- conda activate ohgenom

# Disclaimers:

- the primer_schemes folder is copied from https://github.com/artic-network/artic-ncov2019
