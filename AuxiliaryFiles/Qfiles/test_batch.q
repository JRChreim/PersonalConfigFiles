#!/bin/sh

#SBATCH --partition=normal
#SBATCH --job-name="batch_test"
#SBATCH --nodes=24
#SBATCH --ntasks-per-node=1
#SBATCH --mem-per-cpu=120000M
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
/opt/MATLAB/R2018b/bin/matlab -nodesktop -nosplash -r "DPvsMeshRich"

## exiting
echo "program finished with exit code $? at `date`"
