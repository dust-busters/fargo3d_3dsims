#!/bin/bash

#SBATCH -o $root$/$blockname$/slurm_log/$simid$.%j.%N.log
#SBATCH -D $root$/fargo3d_3dsims/
#SBATCH -J 3dsb.$simid$.%j.%N
#SBATCH --partition=hpg-turin
#SBATCH --get-user-env
#SBATCH --mail-type=end
#SBATCH --mail-user=nicholsonl@ufl.edu
#SBATCH --mem=$ram$
#SBATCH --ntasks=2
#SBATCH --cpus-per-task=2
#SBATCH --gres=gpu:2
#SBATCH --time=48:00:00

module purge
# L4 partition
module load cuda/13.2.1 gcc/14.2.0 openmpi/5.0.10 python
# B200 partition
#module load cuda/12.8.1 gcc/14.2.0 openmpi python

source test1/venv/bin/activate

make clean SETUP=$setup$ GPU=1 PARA=1
make para SETUP=$setup$ GPU=1 PARA=1 MPICUDA=1

# === Run using mpirun ===
export OMP_NUM_THREADS=1
export CUDA_VISIBLE_DEVICES=0,1
export CUDA_DEVICE_ORDER=PCI_BUS_ID

nvidia-smi --query-compute-apps=pid,process_name,gpu_uuid,used_gpu_memory --format=csv -l 10 > gpu_usage.log &

# Create device file
DEVFILE="devfile"
> $DEVFILE  # empty the file if it exists

# Generate list of nodes
nodes=$(scontrol show hostnames $SLURM_NODELIST)

# Loop over each node and get its GPUs
for node in $nodes; do
  # Query each GPU ID on that node
  gpu_indices=$(srun --nodes=1 --ntasks=1 --nodelist=$node nvidia-smi --query-gpu=index --format=csv,noheader)

  # Add each GPU index to the devfile
  for idx in $gpu_indices; do
	realhost=$(srun --nodes=1 --ntasks=1 --nodelist=$node hostname)
	echo "${realhost}: ${idx}" >> $DEVFILE
  done
done

#make blocks setup=p3d
#./utils/cuda/get_cuda_sm.sh
export UCX_TLS=rc,cuda_copy
export UCX_MEMTYPE_CACHE=n
export LD_LIBRARY_PATH=/exa/software/Spack-2023/spack/opt/spack/linux-rocky8-x86_64/gcc-8.5.0/cuda-12.5.0-swvdwcssr73ydtolish4334fy7pwlf53/lib64/:$LD_LIBRARY_PATH

mpirun --mca pml ^ucx --mca btl ^uct,vader,openib --mca coll ^hcoll,ucx -np 2 ./fargo3d +D $DEVFILE $root$/$blockname$/parafiles/para_$simid$.par


