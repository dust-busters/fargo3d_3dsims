#!/bin/bash

#SBATCH -o $root$/$blockname$/slurm_log/$simid$.%j.%N.log
#SBATCH -D $root$/fargo3d_3dsims/
#SBATCH -J 3dsb.$simid$.%j.%N
#SBATCH --partition=hpg-b200
#SBATCH --get-user-env
#SBATCH --mail-type=end
#SBATCH --mail-user=nicholsonl@ufl.edu
#SBATCH --mem=$ram$
#SBATCH --ntasks=2
#SBATCH --cpus-per-task=2
#SBATCH --gres=gpu:4
#SBATCH --time=14-00:00:00

# Load modules
module purge
module load cuda/13.2.1 gcc/14.2.0 openmpi/5.0.10

# Compile the code
make clean SETUP=$setup$ GPU=1 PARA=1
make para SETUP=$setup$ GPU=1 PARA=1 MPICUDA=1

# Run the code
mpirun ./fargo3d -m $root$/$blockname$/parafiles/para_$simid$.par

