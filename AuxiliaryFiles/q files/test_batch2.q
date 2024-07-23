#!/bin/sh

#SBATCH --partition=serial
#SBATCH --job-name="batch_test"
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem-per-cpu=1000M
#SBATCH --time=24:00:00
#SBATCH --output=output.o%j
#SBATCH --error=output.o%j
#SBATCH --mail-type=all
#SBATCH --mail-user=jchreim@caltech.edu

echo "Starting at `date`"
echo "Runing on hosts: $SLURM_NODELIST"
echo "Runing on nomes: $SLURM_NNODES"
echo "Runing on processors: $SLURM_NPROCS"
echo "current working directory is `pwd`"

## load modules and call programs
# /opt/MATLAB/R2018b/bin/matlab -nodesktop -nosplash -r "DPvsMeshRich.m"

echo "testing to check if this simple example works"

## exiting
echo "program finished with exit code $? at `date`"
