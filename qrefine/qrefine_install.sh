#!/bin/bash

#load module(s) if no conda in path already
if [ $(command -v conda) ]; then
        echo "conda found, no need to activate environment"
else
        echo "conda not found.  loading module"
        module load mamba/py3.13
fi

git clone https://github.com/qrefine/qrefine.git qrefine && cd qrefine

#Install qrefine and activate the environment
conda env create -n qrefine -f environment.yaml
source activate qrefine


echo "# qrefine/aquaref modifications" >> ~/.bashrc
#run qrefine script to build into the conda environment
source_cmd=$(bash ./build_into_conda.sh | tail -n 1)
echo "$source_cmd"

$source_cmd

#AIMNET2 AQua plugins
conda env update -f config/aimnet2.yaml
qrefine.python -m pip install git+https://github.com/zubatyuk/aimnet2calc.git

#Performance mod and torchani
echo "export NUMBA_CUDA_USE_NVIDIA_BINDING=1" >> ~/.bashrc
conda install -y torchani -c conda-forge


#create qrefine function to set up environment for using the package
cat << EOF >> ~/.test1
function qrefine {
        module load mamba/py3.13
        source activate qrefine
        source ~/.conda/envs/qrefine/lib/python3.10/site-packages/build/setpaths.sh
}
export -f qrefine
EOF



echo "A function has been created in your ~/.bashrc to load the necessary modules and environment for qrefine.  It can be called as 'qrefine'."
echo "You will need to log out and back in or re-load your .bashrc file with the command 'source ~/.bashrc' to have access to the new function."