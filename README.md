# Colombia-Wisconsin One Health Consortium genomics protocols 


This repository includes the necessary files for carrying out the protocols at the Colombia Wisconsin OH computational resources, including ABACO and Protek.

The protocols have been tested with Miniconda 3 in Ubuntu 20.04 and CentOS 7.5.

All tasks should be carried inside a folder called "local" or outside of the repo's folder to avoid cluttering it with unnecessary files.


### Installing Miniconda 3 (Bash):

- wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
- bash Miniconda3-latest-Linux-x86_64.sh -b -p ~/miniconda3
- rm Miniconda3-latest-Linux-x86_64.sh
- cd ~/miniconda3/bin
- ./conda init


### Creating the ohgenom environment

- conda env create -f environment.yml


# Disclaimers:

- the primer_schemes folder is copied from https://github.com/artic-network/artic-ncov2019
