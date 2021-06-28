# Colombia-Wisconsin One Health Consortium genomics protocols


This repository includes the necessary files for carrying out the protocols at the Colombia Wisconsin OH computational resources, including ABACO and Protek.

The protocols have been tested with Guppy 4.5.2, nextflow version 21.04.1.5556, and Miniconda 3 in Ubuntu 20.04 and CentOS 7.5.

All data processing tasks should be carried inside a folder called "local" or outside of the repo's folder to avoid cluttering it with unnecessary files.

### Installing Guppy:

```bash
wget https://mirror.oxfordnanoportal.com/software/analysis/ont-guppy-cpu_4.5.2_linux64.tar.gz
tar -xf ont-guppy-cpu_4.5.2_linux64.tar.gz
mkdir -p ~/opt/ont-guppy-cpu/4.5.2
mv ont-guppy-cpu/* ~/opt/ont-guppy-cpu/4.5.2/
echo "export PATH=~/opt/ont-guppy-cpu/4.5.2/bin:\$PATH" >> ~/.bashrc
source ~/.bashrc
rm -r ont-guppy-cpu
rm ont-guppy-cpu_4.5.2_linux64.tar.gz
```

### Installing Miniconda 3 (Bash):

```bash
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
bash Miniconda3-latest-Linux-x86_64.sh -b -p ~/miniconda3
rm Miniconda3-latest-Linux-x86_64.sh
```

OR

```bash
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
bash Miniconda3-latest-Linux-x86_64.sh -b -p /miniconda3/bin
rm Miniconda3-latest-Linux-x86_64.sh
```

### Set group permissions [only if installed in opt as root]

Follow Anaconda\'s tutorial for multi-user group ownership: https://docs.anaconda.com/anaconda/install/multi-user/
Note: If using CentOS, add users to groups as per: https://linuxconfig.org/redhat-8-add-user-to-group

```bash
setfacl -d -m group:miniconda3:rwx /opt/miniconda3/
setfacl -m group:miniconda3:rwx /opt/miniconda3/
```

### Enabling Miniconda 3 (Bash):

```bash
cd ~/miniconda3/bin [or] cd /miniconda3/bin
./conda init
[only if installed in opt] conda config --prepend envs_dirs /opt/miniconda3/envs
[only if installed in opt] conda config --prepend pkgs_dirs /opt/miniconda3/pkgs
```

### Download or clone this repository:

```bash
git clone https://github.com/alceballosa/cw_onehealth_protocols (must be logged into github)
cd cw_onehealth_protocols
```
### Creating the ohgenom environment

```bash
conda env create -f environment.yml
conda activate ohgenom
```

### Update nextflow to enable DSL2 compatibility

```bash
nextflow self-update
```

# Disclaimers:

- the primer_schemes folder is copied from https://github.com/artic-network/artic-ncov2019
