# TODO:

1) ~~upload the new setup that we will use (with boundaries etc..) [L]~~
2) ~~upload the file to gradually increasing the planet mass [A]~~
3) ~~upload the file with the beta cooling implementation [L]~~
4) ~~upload the script to run a batch of simulations [A]~~
5) prepare the parameter file and slurm submission file for script and write instructions [A]

# slurmshot — Script for Preparing Simulation Groups

`slurmshot` is a Python script for setting up batches of simulations. Run `./slurmshot --help` to list all available options.

## How It Works

When executed, `slurmshot` generates a new directory `<name>` with the following structure:

| Folder | Contents |
|---|---|
| `submits/` | Slurm submission files |
| `parfiles/` | Parameter files |
| `slurm_log/` | Slurm log files |
| `outputs/` | Simulation output files |

## Parameter Files

Parameter files are generated from a template passed via `-p`. The template supports the following placeholders, which are substituted per simulation using values passed as arguments to the script or from the `.csv` file passed via `-l` (matched by column name):

| Placeholder | Replaced with |
|---|---|
| `$<par>$` | The value from the `<par>` column in the CSV |
| `$outf$` | The output file path, generated automatically|
| `$setup$` | The FARGO setup name (placed at the top of the file), from the `-t` argument|

## Submission Files

Submission files are generated from a template passed via `-s`. The following placeholders are substituted with the corresponding arguments passed to `slurmshot`:

| Placeholder | Replaced with |
|---|---|
| `$root$` | Root directory, from `--root` |
| `$simid$` | Simulation ID, automatically from the index column in the CSV |
| `$blockname$` | Block name, from `-n` |
| `$ram$` | RAM allocation, from `-r`|
| `$cores$` | Number of cores, from `-c`|
| `$setup$` | FARGO setup name, form `-t`|


----------------------------------------------------------------------------------------------------------------------------------------
# ORIGINAL --- FARGO3D #

#### A versatile MULTIFLUID HD/MHD code that runs on clusters of CPUs or GPUs, with special emphasis on protoplanetary disks. 

### [Documentation](https://fargo3d.github.io/documentation)

Report bugs to the [issues section](https://github.com/FARGO3D/fargo3d/issues) or to the [Google group](https://groups.google.com/forum/#!forum/fargo3d).

### First run

#### Sequential CPU

``` 
make SETUP=fargo PARALLEL=0 GPU=0
./fargo3d setups/fargo/fargo.par
```

#### Parallel CPU

```
make SETUP=fargo PARALLEL=1 GPU=0
mpirun -np 8 ./fargo3d setups/fargo/fargo.par
```

#### Sequential GPU

```
make SETUP=fargo PARALLEL=0 GPU=1
./fargo3d setups/fargo/fargo.par
```

#### Parallel GPU

```
make SETUP=fargo PARALLEL=1 GPU=1
mpirun -np 2 ./fargo3d setups/fargo/fargo.par
```

------------------------

### Description of subdirectories:

* ```in/```: setup parameter files. Equivalent to the ```.par``` files in the ```setup/``` subdirectory.

* ```planets/```: planets configuration files.

* ```scripts/```: scripts used to build the code.

* ```setups/```: custom setup definitions.

* ```src/```: source files. These files can be copied to the ```setups/``` subdirectory and modified there. The makefile uses the ```VPATH``` variable to decide in which order a given source file is sought within different directories (the ```
setup/``` subdirectory has higher prority than ```src```).

* ```std/```: standard or default definitions. These definitions include standard boundary conditions, units, scaling rules, default setup parameters, etc.

* ```test_suite/```: scripts used to test the code. The rule to issue them is ```make test[name of python script without extension]``` for any script in this subdirectory. These scripts use the 'test' python module in ```
scripts/```

* ```utils/```: utilities to post-process the data.
