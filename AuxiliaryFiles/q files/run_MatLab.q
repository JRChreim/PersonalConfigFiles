#!/bin/sh

#SBATCH -p normal
#SBATCH -J "runMatlab"
#SBATCH -n 24
#SBATCH -t 24:00:00
#SBATCH -o output.o%j
#SBATCH -e output.o%j
#SBATCH --mail-type=all
#SBATCH --mail-user=jchreim@caltech.edu

echo "Starting at `date`"
echo "Runing on hosts: $SLURM_NODELIST"
echo "Runing on nomes: $SLURM_NNODES"
echo "Runing on processors: $SLURM_NPROCS"
echo "current working directory is `pwd`"

## load modules and call programs
/opt/MATLAB/R2018b/bin/matlab -nodesktop -nosplash -r "../MatlabScripts/P64"

## exiting
echo "program finished with exit code $? at `date`"
