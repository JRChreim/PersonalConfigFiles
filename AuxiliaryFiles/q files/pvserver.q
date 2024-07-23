#!/bin/bash

#SBATCH --job-name=ParaView
#####SBATCH -p nodes
#SBATCH -o paraview.out
#SBATCH --partition=normal
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --export=ALL
#SBATCH -t 23:59:00

mpirun /home/jrchreim/packages/ParaView-5.6.0/bin/pvserver --use-offscreen-rendering
