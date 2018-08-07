# Lets_play_with_CESM
This repository will serve me and hopefully others as I learn how to use CESM, export transport matrices from it, and optimize some biogeochemical parameters.

## Introduction
Community Earth System Model (CESM 1) was developed at the National Center for Atmospheric Research (NCAR) in Boulder, CO. The model was formerly known as the Community Climate System Model (CCSM).
The model can run just the ocean component, or ocean-sea ice components, with forcing values from the atmosphere from NCEP/NCAR reanalysis data, or from full coupled model output.
When forcing with the NCEP/NCAR reanalysis data, the model repeatedly cycles through all available years (current 1948–2009).
Running the model five times through this 62-year cycle, or 310 years, is enough to fully spin-up upper ocean biogeochemistry and physics.

## Model Grid
Ocean component comes in two grid resolutions:
- `gx1v6` – approximately 1 degree resolution horizontally (320x384x60)
- `gx3v7` – approximately 3 degree resolution horizontally (100x116x60)
Both models have the same vertical resolution with 60 vertical levels.
These levels are 10m thick in the upper 150m, and then increase in thickness with depth.
The latitudinal resolution varies, with finer resolution near the equator.

Both grids also have a "displaced pole", that is the longitudinal lines do not converge at the geographic north pole, but instead converge in central Greenland.
This improves Arctic ocean circulation, and provides higher resolution in the waters around Greenland where North Atlantic Deep Water forms.

![grid image](http://www.cesm.ucar.edu/models/cesm1.0/cesm/cesm_doc_1_0_4/greenland_pole_grid.jpg)

## Types of CESM simulations
- Startup – brand new run starting from already-built initialization files (i.e., WOA nutrients, etc...)
- Branch – initializes the model using output from another simulation.
- Hybrid – some mix of the two, e.g., sea ice is in startup mode but the ocean tracers branch from another run.

## Running CESM and plotting data
There is a number of key directories containing all the files needed to run the model and plot figures of the output.
On greenplanet (more info on greenplanet here), there are 4 main directories, each with a set of subdirectories and files, serving a specific purpose:
- the Model code – contains the model FORTRAN code, i.e. the algorithms that define the model.
- the Model output – contains the NetCDF files that the model outputs.
- the Plotting code – contains the IDL code for plotting.
- the Plotting output – contains the output of IDL routines?

## Running the model
The purpose here is to run the model, i.e., time-step it to see how the earth system evolves.


### Directories already there in J. Keith Moore's directory
```
/DFS-L/DATA/moore/jkmoore/
  ├── cesm1_2_2
  ├── CESM1.98
  │   └── SourceCode_gx3v7
  ├── gx1v6_inputs
  ├── gx3v7_inputs
  ├── gcommon1.2
  ├── plotannx1
  ├── plotannx3
  ├── plotmonthx1
  ├── plotmonthx3
  ├── plottrendx1
  ├── plottrendx3
  ...
```
- `cesm1_2_2` contains the standard CESM 1.2.2 model code downloaded from NCAR.
We never edit or modify the files in this directory.
Everyone can access from this location.
- `gx3v7_inputs` contains input files for the gx3v7 ocean model (coarse 3x3 deg. resolution).
- `gx1v6_inputs` contains input files for the gx1v6 ocean model (fine 1x1 deg. resolution).
- `gcommon1.2` contains commonly used non-standard CESM files for the coarse x3 grid.
- `SourceCode_gx3v7` contains non-standard code for J. Keith Moore's locally modified code version.
This is the version you should use for now (what about CESM2.0?).
The biogeochemistry is nearly identical to the code going into the CESM2.0, in terms of the scientific equations, but the software architecture will change quite a bit in CESM2.0 (to be released in 2018).
This is also where the `sampleNOTES` directory is (to be used for running and plotting).
- `plotannx1`, `plotannx3`, and so on, contain J. Keith Moore's plotting routines.
(You will copy those to your own plotting directory)

### Directories you have to create if you want to run the model
Your `USERID` will determine the path of the directory where the files you use and create as you run CESM are living.
The `DATA` space is for important files and the `SCRATCH` space is where the model will run and output will be stored.
Output that you want to keep long term should be moved to the `DATA` equivalent.

```
/DFS-L/SCRATCH/moore/USERID/
  ├── IRF_runs
  ├── cesm_runs
  ├── archive
  ...
```

- `cesm_runs` is the scripts directory, we put files here when running the model to tell CESM which non-standard files to use, how many years to run, etc.
One subdirectory for each model run, e.g., `gdev.xyz.001` for your first run (`xyz` are your initals. Why `gdev`?).
This directory is created automatically during model build and compilation?
- `archive` is the directory where the model output files are copied at the end of simulation.
- `IRF_runs` is for model runs that produce transport matrices.
Maybe make sure that the transport matrices produced are stored in `DATA`?

```
/DFS-L/DATA/moore/USERID/
  ├── plotannx3
  ...
```

- `plotannx3` is the plotting routines (you should copy it from `/DFS-L/DATA/moore/jkmoore` - I have no idea why.)

### Files: data and code to run the model
Look for them in `/gdata/mooreprimeau/CESM_CODE/CESM1.97/` (outdated!)
- `ecosys_parms.F90` sets the values of key parameters in the model.
- `ecosys_mod.F90`, the ecosystem/biogeochemical model code.
The key subroutine is `ecosys_set_interior`, which updates the biogeochemical sink/source terms.
- `namelist_defaults_pop2.xml` sets the value of some parameters at runtime, overrides values (careful!) in `ecosys_parms.F90`  (will replace `ecosys_parms` in future model versions).
- `ocn.ecosys.setup.csh` sets up the  variables to be saved in output files.
- `gdev.jkm.001.slurm` the main file that actually runs the model, i.e., what you submit to the job scheduler on greenplanet.
The number of processors listed in this file must match what you used in the `NOTES_12_12` (note: `12_12` for 12 nodes with 12 CPUs each) file to set up and compile the simulation.
When setting up new runs you should edit the jobname, the name of the slurm script to match the new simulation name (i.e., for your second job, edit `gdev.xyz.001` into `gdev.xyz.002`), and the directory path that currently says `/lustre/SCRATCH/moore/USERID/cesm_runs/gdev.jkm.001.slurm` (outdated!).
 (At NCAR this is `gdev.jkm.001.run`?).


### Files: model-run output data (outdated)
The model-run output data files are written in two directories, which are automatically created (outdated!)
- `/lustre/SCRATCH/moore/USERID/gdev.xyz.001/run/` where the model actually runs: Initially, all output files are written to this directory.
- `/lustre/SCRATCH/moore/USERID/archive/gdev.xyz.001/` long term storage of the model output and the restart files (note that the path is different from the run/ directory).
Output files from simulations are automatically copied here at the end of the simulation.

After the model has been run, the data files (NetCDF) containing the data to plot for, e.g., the ocean, are located in `/lustre/SCRATCH/moore/USERID/archive/gdev.xyz.001/ocn/hist/` (you can delete some files if the model run was not good as long as you take notes).
You will mainly just use the output files with format  `gdev.xyz.001.pop.h.0001.nc` (standard annually-averaged ocean-model output files) or `gdev.xyz.001.pop.h.0001-01.nc` (same but monthly-averaged).

- Note 1: There are other output directories, such as `/ice` (for sea ice), `/atm` (for atmosphere), etc.
- Note 2: There is a `.../archive/gdev.xyz.001/rest/` subdirectory containing files for restarting the model or starting a branch run.

### Starting a new CESM simulation (and use git to version-control it)
1. Make a new local directory on your laptop called `xyz.001`, except replace `xyz` with your initials.
2. There are samples directories with files to setup and run the model (on 12 of the 12cpu nodes in the `new2.8` queue) at `/DFS-L/DATA/moore/jkmoore/CESM1.98/SourceCode_gx3v7/SampleNotes/`.
Copy all the files from the SampleNotes/ directory to your new local `/gdev.xyz.001/` directory.
The files you just copied are:
    - `NOTES_12_12` a copy/paste script for starting a new job.
    This script contains code for both running the model and plotting output.
    For this first step, you should just run the model.
    - `arun_idl_gdev_001` a large number of IDL plotting routines that work on annual model output files.
    After the model has run, you can start IDL and then copy and paste individual routines from `arun_idl_gdev_001` or enter `@arun_idl_gdev_001` directly to execute all the commands in the file and plot everything.
    - `gdev.001.slurm` the batch execution file you submit to the scheduler to run the model.
    (More info on the slurm scheduler on greenplanet [here](https://ps.uci.edu/greenplanet/).)
    You can submit the job to the scheduler with the sbatch command, i.e., when in greenplanet in the main node, type sbatch `./gdev.001.slurm`.
    - `AAverage_gdev_001` script to cut and paste to average the last 20 years of the simulation (model years 291–310 corresponds to NCEP forcing for the 1990–2009 period)
3. In `gdev.001.slurm`, edit the job name (twice) and and the directory path.
4. In `NOTES_12_12`, edit `USERID`, the job name, and the length of the run (the number of years).
5. Copy and paste up to the Comments to build? or compile? and run your first job.
Do not plot right away as you need to setup the directories for plotting (right?).
6. Once your job has been submitted, you can directly type the following in the console:
    - `squeue` to list all jobs currently running on greenplanet
    - `squeue –u jkmoore` to list all jobs submitted by `jkmoore` currently running (`u` is for user)
    - `squeue –q moore_fast6` to list all jobs in the `moore_fast6` (outdated!) queue. The output at command line should look like:

    ```
    JobID             USER       QUEUE     Jobname       NDS  ElapTime
    99999.greenplane  jkmoore    moore     qdev.ell.001  8    1:05
    ```

    - `scancel 99999` stops/kills the job with the ID `99999` that is running.
(Use the job ID you get from `qstat –u youruserid`?)
    - `sbatch ./gdev.jkm.001.slurm` submits the job to the scheduler.
It will go in a queue and run whenever the scheduler decides it can run.
(You should have already submitted your job at this point.)
Note: commands to use on Yellowstone are different. Example use:
`./gdev.jkm.001.submit`
7. Connect via `ssh` to `gplogin1.ps.uci.edu` or to `gplogin3.ps.uci.edu.` (outdated!)
Note: from off campus you have to connect using a VPN, see www.libraries.uci.edu, click on button on upper left of page that says "Connect from Off Campus" and install the VPN software on your home PC.
**DO NOT** download any illegal content while on the VPN! (music, movies, etc. - UCI will notice!)

### Other files (not sure what this is - have not used it yet)
There are other files that will be copied to your scripts directory that you might need to edit in the future:
- `ocn.ecosys.setup.csh` this file tells the model which variables to save in the output files (normally you should not edit this file).
- `env_run` tells whether this is a `CONTINUE_RUN` or not.
Here you can edit the number of months to run the model or the number of times for the model to automatically re-submit itself (`RESUBMIT` variable).
- `env_conf` in which the `RUN_TYPE` variable tells CESM whether this is a branch, a startup, or a hybrid run.
- `RUN_STARTDATE` gives start date for this simulation
- `RUN_REFCASE` name of previous run for branch or hybrid runs
- `RUN_REFDATE` date to branch from previous run
- `CCSM_CO2_PPMV` tells model what constant atmospheric CO₂ concentration to use when calculating the air-sea CO₂ flux.

### Plotting
Interactive Data Language (IDL) is used to plot data from the model output.

#### Directories (outdated)
- `/gdata/moore2/jkmoore/plotdirs/` contains subdirectories with IDL routines for extracting and plotting output from the main model output files.
The Subdirectories include `/plotannx3` (routines for extracting plotting model output from annual output files.) and `/plottrendx3` (routines for extracting and plotting time series of key fluxes and tracer concentrations from multiple annual output files, e.g., time series showing primary production varying over time).

#### Files
Some key data files in the plotting directories (many are also variables in the output files):
- `kmt` integer array (320x384, or 100x116) giving the number of ocean levels (depth) at each location.
For a given location, say `x=30` and `y=20`, if `kmt(30,20) = 0`, this is a land point, no ocean. If `kmt(30,20) = 5`, then the ocean is 5 levels, or 50m deep at that location.
Note: Arrays in IDL are typically defined to hold integer or floating point data.
Example of creating integer and float arrays: `temp=intarr(320,384)` and `temp=fltarr(100,116,60)`.
- `varnames_ccsm4` or `cesm_gx3v7_varnames` lists the variables typically present in the model ocean output files.
- `zw_pop` and `zw_pop_m` the depths of the ocean levels in cm and m, respectively.
- `tlats` and `tlongs` give the latitude and longitude at each point on the 320x384 or 100x116 grid.
- `ulats` and `ulongs` the latitude and longitude (... What does `t` and `u` stand for?) at each point on the 320x384 or 100x116 grid.
- `tarea` the area of each grid cell in cm².
- `dz_pop` and `dzw_pop` thickness of each model layer in cm and m? (To be confirmed!)

The IDL files are in the plotting directories, e.g., `extraction.V3` and `pop4_coords`. Key files include:
- `poplatlong_x3` finds location on ocean grid for a specific latitude/longitude.
Usage: `poplatlong_x3,lat,lon,x,y`.
Example: `poplatlong_x3,-10.0,140.0,x,y` will return x grid location in the variable `x`, and y location in the variable `y` (Type `print,x,y` to print the values of `x` and `y`).
- `extract_var_file` extracts a variable from a netcdf file.

#### How to use IDL for the model
1. Create under your user account the directories:
    - `/lustre/SCRATCH/moore/USERID/plotdirs/` with subdirectories `plotannx3/` and `plottrendx3/` (oudated!).
    - `/lustre/SCRATCH/moore/USERID/popoutx3`  and `/lustre/SCRATCH/moore/USERID/popoutx1` should be used to store the output plotting files (generated in the `plotdirs/`), with one subdirectory for each simulation.
That is, for a given year of simulation, `gdev.xyz.001.yr30`.
2. On your local machine create a directory, `/pophome/gdev.jkm.001/`, that contains all the files in my sample directory (?).
You'll need to copy to the scripts directory on greenplanet when setting up a new simulation (?).
In this local copy of the scripts directory, will be the following files
    - `arun_idl_gdev_001` text file for running annual model output plotting routines.
    - `s_extract_gdev_001` text file for extracting the global fluxes/tracer concentrations from multiple annual output files (to look at trends).
    - `s_plot_gdev_001` text file for plotting the time series data using input files generated by `s_extract_gdev_001`.
3. To start IDL, type `idl` in the command-line console after connecting via `ssh` to greenplanet:

    ```
    [USERID@gplogin1 ~]$ idl
    IDL Version 8.1 (linux x86_64 m64). (c) 2011, ITT Visual Information Solutions
    Installation number: XXXXXXX-X.
    Licensed for use by: UC Irvine

    IDL>
    ```

4. To use these, copy the model output files to either `plotannx3`, `plottrendx3`, then copy and paste to run just some routines, or type:

    ```
    IDL> @arun_idl_gdev_001
    ```

    to run all the plotting routines in this file.
    Example use:

    ```
    IDL> extract_var_file,’gdev.001.pop.h.010.nc’,’NO3’,nitrate
    ```

    (After execution, nitrate will be a `fltarr(100,116,60)` that has the nitrate concentration from the simulation.)
    To execute these in IDL you have to first "compile" them (the IDL files) with the `.run` command, i.e., type:

    ```
    IDL> .run extraction.V3
    ```

Note: A quirk of IDL is that array index notation starts with `0`, not `1`, as in Fortran. 
Thus, to to access all values of the nitrate array, you need to scroll through `x=0` to `99`, `y=0` to `115`, and `z=0` to `59`.

### Key directories on your local desktop/laptop machine (outdated?)

- `/ccsm4/pophomex3` to keep your local copies of the script files with one subdirectory for each run.
- `/ccsm4/plotannx3` to keep local copies of annual plotting routines if you need to edit them, or are developing new plotting routines.
- `/ccsm4/popoutx3` subdirectory for each simulation, to store the output files from the plotting routines, e.g., `gdev.xyz.001.yr30`.
- `/ccsm4/plotmonthx3` same as `plotmonthx3`
- `/ccsm4/plottrendx3` same as `plottrendx3`
- `aLogsCESMRuns` to keep a log file where you note what you modified in the code for each run, and maybe some notes on the results.
