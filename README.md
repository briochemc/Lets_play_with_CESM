# Lets_play_with_CESM
This repository will serve me and hopefully others as I learn how to use CESM, export transport matrices from it, and optimize some biogeochemical parameters.

## Table of contents

<!-- vim-markdown-toc GFM -->

* [Introduction](#introduction)
  * [Model Grid](#model-grid)
  * [Types of CESM simulations](#types-of-cesm-simulations)
  * [Running CESM and plotting data (incomplete - don't read yet)](#running-cesm-and-plotting-data-incomplete---dont-read-yet)
* [Directory structures](#directory-structures)
* [Starting a new CESM simulation (and use git to version-control it)](#starting-a-new-cesm-simulation-and-use-git-to-version-control-it)
  * [Prerequisites](#prerequisites)
  * [Setting up, building, and running CESM](#setting-up-building-and-running-cesm)
* [Other info (needed here?)](#other-info-needed-here)
  * [Other files (not sure what this is - have not used it yet)](#other-files-not-sure-what-this-is---have-not-used-it-yet)
  * [Plotting](#plotting)
    * [Directories (outdated)](#directories-outdated)
    * [Files](#files)
    * [How to use IDL for the model](#how-to-use-idl-for-the-model)
  * [Key directories on your local desktop/laptop machine (outdated?)](#key-directories-on-your-local-desktoplaptop-machine-outdated)
  * [Files: data and code to run the model (outdated stuff)](#files-data-and-code-to-run-the-model-outdated-stuff)
  * [Files: model-run output data (outdated)](#files-model-run-output-data-outdated)

<!-- vim-markdown-toc -->

## Introduction
Community Earth System Model (CESM 1) was developed at the National Center for Atmospheric Research (NCAR) in Boulder, CO. The model was formerly known as the Community Climate System Model (CCSM).
The model can run just the ocean component, or ocean-sea ice components, with forcing values from the atmosphere from NCEP/NCAR reanalysis data, or from full coupled model output.
When forcing with the NCEP/NCAR reanalysis data, the model repeatedly cycles through all available years (current 1948–2009).
Running the model five times through this 62-year cycle, or 310 years, is enough to fully spin-up upper ocean biogeochemistry and physics.

### Model Grid
Ocean component comes in two grid resolutions:
- `gx1v6` – approximately 1 degree resolution horizontally (320x384x60)
- `gx3v7` – approximately 3 degree resolution horizontally (100x116x60)
Both models have the same vertical resolution with 60 vertical levels.
These levels are 10m thick in the upper 150m, and then increase in thickness with depth.
The latitudinal resolution varies, with finer resolution near the equator.

Both grids also have a "displaced pole", that is the longitudinal lines do not converge at the geographic north pole, but instead converge in central Greenland.
This improves Arctic ocean circulation, and provides higher resolution in the waters around Greenland where North Atlantic Deep Water forms.

![grid image](http://www.cesm.ucar.edu/models/cesm1.0/cesm/cesm_doc_1_0_4/greenland_pole_grid.jpg)

### Types of CESM simulations
- Startup – brand new run starting from already-built initialization files (i.e., WOA nutrients, etc...)
- Branch – initializes the model using output from another simulation.
- Hybrid – some mix of the two, e.g., sea ice is in startup mode but the ocean tracers branch from another run.

### Running CESM and plotting data (incomplete - don't read yet)
There is a number of key directories containing all the files needed to run the model and plot figures of the output.
On Greenplanet (more info on Greenplanet [here](https://ps.uci.edu/greenplanet/)), there are 4 main directories, each with a set of subdirectories and files, serving a specific purpose:
- the Model code – contains the model FORTRAN code, i.e. the algorithms that define the model.
- the Model output – contains the NetCDF files that the model outputs.
- the Plotting code – contains the IDL code for plotting.
- the Plotting output – contains the output of IDL routines?


## Directory structures

On Greenplanet, these are some of the directories and files of J. Keith Moore (JKM) that you will either use without modifying them, or that you will copy to your space and edit:
```bash
/DFS-L/DATA/moore/jkmoore/
 ├── cesm1_2_2              # standard CESM 1.2.2 model code from NCAR (Do not edit!)
 ├── CESM1.98               # one of JKM's CESM modified versions
 │   └── SourceCode_gx3v7                # contains non-standard code you will use
 │       │
 │       ├── SampleNotesCESM1.98.1
 │       │   ├── gdev.001.slurm
 │       │   └── NOTES_20_8_Startup
 │       │
 │       ├── hmix_gm.F90.cesm1.98.1            # Example of non-standard "mod" for mixing
 │       ├── ecosys_parms.F90.cesm1.98.1       # Other example for exosystem parameters
 │       ├── ecosys_mod.F90.cesm1.98.1.atmbox  # Other example for exosystem formulation
 │       ...                                   # (There are many other files not listed here)
 │
 ├── gx1v6_inputs      # input files for the (ocean) 1x1 deg. resolution model
 ├── gx3v7_inputs      # same for the 3x3 resolution
 │
 ├── gcommon1.2        # commonly used non-standard CESM files for the coarse x3 grid
 │
 ├── plotannx1         #
 ├── plotannx3         # plotting routines for annually or monthly averaged,
 ├── plotmonthx1       # 1x1 or 3x3 model output, and so on...
 ├── plotmonthx3       #
  ...
```
CESM1.98.1's non-standard code in `SourceCode_gx3v7` is the version you will use.
The biogeochemistry is nearly identical to the code going into the CESM2.0, in terms of the scientific equations, but the software architecture will change quite a bit in CESM2.0 (to be released in 2018).

You should have personal two personal spaces named after your `USERID` on Greenplanet:
```
/DFS-L
 ├── DATA/moore/USERID/
 └── SCRATCH/moore/USERID/
```
If not, contact hpcops@uci.edu.
(The `DATA` space is for important files and the `SCRATCH` space is where the model will run and output will be stored.)


In your own `SCRATCH` space on Greenplanet will be the following directories.
(If it is your first run, those will not exist at the beginning.)

```bash
/DFS-L/SCRATCH/moore/USERID/
 ├── cesm_runs          # files to run the model
 │   │                  # (automatically during model build and compilation)
 │   ├── xyz.001             # files for 1st run (xyz are your initials)
 │   ├── xyz.002             #           2nd run
 │   ├── xyz.003             #     and so on...
 │   ...
 │
 ├── archive            # where the model output is copied at the end of the simulation
 │
 ├── IRF_runs           # runs that produce transport matrices? (TBC)
  ...
```



## Starting a new CESM simulation (and use git to version-control it)

### Prerequisites

If you are completely new to running CESM on Greenplanet, follow these steps to set yourself up and running.

1. **Use git for your CESM runs** (Recommended but not mandatory).

    1. Fork this repository on github (click the "Fork" button button at the top of this webpage)

    1. Clone your fork somewhere on your laptop by opening a terminal in appropriate directory and typing
        ```bash
        cd PATH_WHERE_YOU_WANT_THE_REPOSITORY
        git clone https://github.com/YOUR_GITHUB_ID/Lets_play_with_CESM.git
        ```

        > [Additional recommendation] You can make a `Projects` directory in your laptop's `$HOME` directory, so that you have a single place where you clone all your repositories.
        > In my case, I just typed:
        > ```bash
        > cd ~/Projects
        > git clone https://github.com/briochemc/Lets_play_with_CESM.git
        > ```

1. **Connect to Greenplanet** via `ssh` using `gplogin2` (`gplogin1` and `gplogin3` go to the old machine) by opening a terminal and typing:
    ```bash
    ssh USERID@gplogin2.ps.uci.edu
    ```
    Note: from off campus you have to connect using a VPN, see www.libraries.uci.edu, click on button on upper left of page that says "Connect from Off Campus" and install the VPN software on your home PC.
    **DO NOT** download any illegal content while on the VPN! (music, movies, etc. - UCI will notice!)
    > [Additional recommendation]
    > I recommend adding an alias on your laptop to facilitate ssh connections.
    > In my case, I added the following line to my laptop's `.bashrc`:
    > ```bash
    > gp2='ssh pasquieb@gplogin2.ps.uci.edu'
    > ```
    > Then I can connect to `gplogin2` by simply typing
    > ```bash
    > gp2
    > ```
    > in my laptop's terminal.

1. **Create the `run` directories** in your `SCRATCH` space on Greenplanet.
    You will need those directories to exist:
    ```bash
    /DFS-L/SCRATCH/moore/USERID/
     ├── cesm_runs
     ├── archive
     ├── IRF_runs
      ...
    ```
    So if they do not exist yet, just type
    ```bash
    cd /DFS-L/SCRATCH/moore/USERID/
    mkdir cesm_runs
    mkdir archive
    mkdir IRF_runs
    ```



### Setting up, building, and running CESM

1. **Make a new local directory on your laptop**

    For each new run called `xyz.abc`, except replace `xyz` with your initials and `abc` with the run number.
    > For example, for my first CESM run, I created `bp.001` in this git repository, which looked like this:
    > ```bash
    > ~/Projects/Lets_play_with_CESM
    >   ├── README.md
    >   └── bp.001
    > ```

1. **Copy and edit some files from `SampleNotesCESM1.98.1`**.

    (I copied `SampleNotesCESM1.98.1` from Greenplanet to this repository for convenience.)

    1. Copy `gdev.001.slurm` to your `xyz.abc` directory, rename it to `xyz.abc.slurm`, and edit the following:
        - line 6 to change the job name to `xyz.abc`:
            ```bash
            #SBATCH --job-name=xyz.abc
            ```
        - line 22 to change the directory path to `/DFS-L/SCRATCH/moore/USERID/cesm_runs/xyz.abc` (change both `USERID` and `xyz.abc`):
            ```bash
            cd /DFS-L/SCRATCH/moore/USERID/cesm_runs/xyz.abc
            ```
        This slurm file that you just edited will be used to submit the job (of running CESM) to the slurm scheduler on Greenplanet.

        > For example for my second run, the slurm file is renamed to `bp.002.slurm` and this is what the two lines look like after editing:
        > ```bash
        > #SBATCH --job-name=bp.002
        > cd /DFS-L/SCRATCH/moore/pasquieb/cesm_runs/bp.002
        > ```

    1. Copy `NOTES_20_8_Startup` to your `xyz.abc` directory and edit the following:
        - line 5 and 6 to change the values of `CCSMUSER` and `CASE_DST`:
            ```tcsh
            setenv CCSMUSER             USERID
            setenv CASE_DST             xyz.abc
            ```
        - lines 45 to 49 to change, e.g., the number of months you will run CESM for (not sure this is correct)
            ```tcsh
            ./xmlchange -file env_run.xml -id STOP_OPTION -val nmonth
            ```



        > For example, for my second run (`bp.002`) I have the following lines 5, 6, and 46:
        >
        > ```tcsh
        > setenv CCSMUSER             pasquieb
        > setenv CASE_DST             bp.002
        > ...
        > ./xmlchange -file env_run.xml -id STOP_N      -val 12
        > ```



1. **Connect to Greenplanet and load the compilers and modules**.

    Simply type the following after login in to Greenplanet:
    ```bash
    module load intel/2018.2 openmpi/3.0.1 netcdf/4.6.1
    ml idl
    ```
    > Ideally this would go in a dotfile in your setup so that there is no need to load these modules every single time.
    > (Although it might be good for remembering what you are actualling using?)

1. **Build CESM's code**

    The following steps show you how you will copy some code files to your `SCRATCH`'s `xyz.abc` run directory and then build CESM's code based on those copied files.

    1. **Copy a bunch of files from JKM's `DATA` directory to your `SCRATCH`'s `xyz.abc` run directory.**

        Just copy lines 4 to 39 (inclusive) of your edited `NOTES_20_8_Startup` and paste them in your terminal session logged in toGreenplanet.
        :warning:**Do not copy-paste the comments!**:warning:

    1. **Make modifications to the code (if you want)**

        As written in the `NOTES_20_8_Startup` file, you should manually copy over any code file you edited to `/SourceMods/src.pop2`.

        :question: Edit and then check this step. :question:

        :exclamation: This is probably where mreging the IRF mods will end up!:exclamation:


    1. **Modify some of CESM's xml files and start the build**

        Just copy-paste lines 45 to 52 of your modified `NOTES_20_8_Startup` in your terminal session logged in toGreenplanet.

    1. **Copy your modified slurm script to Greenplanet**

        Just copy your newly named and edited slurm script `xyz.abc.slurm` from your laptop to your `SCRATCH`'s `xyz.abc` run directory on Greenplanet.
        > (This could probably be improved by using git for it?)
        > I personnaly have a function for that in my local .bashrc that looks like
        > ```bash
        > function cp2gp2_cesmruns() # Copy to greenplanet cesm_runs (via gplogin2)
        > {
        >   scp -r $1 pasquieb@gplogin2.ps.uci.edu:/DFS-L/SCRATCH/moore/pasquieb/cesm_runs/$2
        > }
        > ```
        > so that I only need to type
        > ```bash
        > cp2gp2_cesmruns xyz.abc.slurm xyz.abc/
        > ```
        > This could also be improved with another function like below (not tested yet)
        > ```bash
        > function cpslurm2gp2() # Copy local xyz.abc.slurm file to greenplanet's cesm_runs/xyz.abc/ (via gplogin2)
        > {
        >   scp $1.slurm pasquieb@gplogin2.ps.uci.edu:/DFS-L/SCRATCH/moore/pasquieb/cesm_runs/$1/
        > }
        > ```


1. **Submit your job!**

    You can now submit your job by either copying **line 54** of the `NOTES_20_8_Startup` file and pasting it in your terminal session logged into Greenplanet or you can submit it directly by typing
    ```bash
    sbacth xyz.abc.slurm
    ```
    That's it, your job will running as soon as the slurm scheduler of Greenplanet has room for it! :thumbsup:

Once your job has been submitted, you can directly type the following in the console:
- `squeue` to list all jobs currently running on Greenplanet
- `squeue –u USERID` to list all jobs submitted by `USERID` currently running (`u` is for user)
- `squeue –q QUEUENAME` to list all jobs in the `QUEUENAME` queue.
    (JKM's queues are called `nes2.8` or `sib2.9`.)
    The output at command line should look like:

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


## Other info (needed here?)

1. Copy the sample files to your newly created `xyz.abc` directory.
    Let me clarify what these *sample files* are.
    In this repository, there is a `SampleNotes` directory, containing sample files to setup and run CESM on J. Keith Moore's queues on greenplanet.
    Some of these sample files are listed below (this list is not exhaustive):

    - `NOTES_20_8_Startup` a copy/paste script for starting a new job.
        This script contains code for both running the model and plotting output.
        For this first step, you should just run the model.

    - `xyz.abc_12_12.slurm` the batch script you can submit to Greenplanet's slurm scheduler to run CESM.
        (More info on the slurm scheduler on greenplanet [here](https://ps.uci.edu/greenplanet/).)
        You can submit the job to the scheduler with the `sbatch` command.
        On greenplanet, on the main node, you would just type

        ```bash
        sbatch ./xyz.abc_12_12.slurm
        ```

        to submit your job.
        (Again, you would replace `xyz` and `abc`.)

    - `AAverage_gdev_001` script to cut and paste to average the last 20 years of the simulation.
    Model years 291–310 corresponds to NCEP forcing for the 1990–2009 period (after five times through the (1948-2009) NCEP reanalysis forcings).

    - `arun_idl_gdev_001` a large number of IDL plotting routines that work on annual model output files.
        After the model has run, you can start IDL and then copy and paste individual routines from `arun_idl_gdev_001` or enter

        ```bash
        @arun_idl_gdev_001
        ```

        directly to execute all the commands in the file and plot everything.

    - `arun_idl_min_001` IDL scripts, has just the most commonly used plotting routines.

    A few notes:
        The other files are for specific users and I can find the description in an old email but I am skipping those for now.
        (The old queues, `moore_fast`, `moore_fast6`, and `moore_fast8`, are now called `nes2.8` and `sib2.9`.)
        On Aug 07 2018, I copied all the files from greenplanet's `SampleNotes` directory to this repository, and made some edits to make it more user-friendly.
        You should copy those files into a subdirectory with a name of the form `xyz.abc` for every new run of yours, using your initials instead of `xyz`, and the run number instead of `abc`.
        For example, my second run would be `bp.002`.

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
- `extract_var_file` extracts a variable from a NetCDF file.

#### How to use IDL for the model
1. Create under your user account the directories:
    - `/DFS-L/SCRATCH/moore/USERID/plotdirs/` with subdirectories `plotannx3/` and `plottrendx3/` (oudated!).
    - `/DFS-L/SCRATCH/moore/USERID/popoutx3`  and `/DFS-L/SCRATCH/moore/USERID/popoutx1` should be used to store the output plotting files (generated in the `plotdirs/`), with one subdirectory for each simulation.
That is, for a given year of simulation, `gdev.xyz.001.yr30`.
2. On your local machine create a directory, `/pophome/gdev.jkm.001/`, that contains all the files in my sample directory (?).
You'll need to copy to the scripts directory on Greenplanet when setting up a new simulation (?).
In this local copy of the scripts directory, will be the following files
    - `arun_idl_gdev_001` text file for running annual model output plotting routines.
    - `s_extract_gdev_001` text file for extracting the global fluxes/tracer concentrations from multiple annual output files (to look at trends).
    - `s_plot_gdev_001` text file for plotting the time series data using input files generated by `s_extract_gdev_001`.
3. To start IDL, type `idl` in the command-line console after connecting via `ssh` to Greenplanet:

    ```
    $ idl
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



### Files: data and code to run the model (outdated stuff)
Look for them in `/gdata/mooreprimeau/CESM_CODE/CESM1.97/` (outdated!)
- `ecosys_parms.F90` sets the values of key parameters in the model.
- `ecosys_mod.F90`, the ecosystem/biogeochemical model code.
The key subroutine is `ecosys_set_interior`, which updates the biogeochemical sink/source terms.
- `namelist_defaults_pop2.xml` sets the value of some parameters at runtime, overrides values (careful!) in `ecosys_parms.F90`  (will replace `ecosys_parms` in future model versions).
- `ocn.ecosys.setup.csh` sets up the  variables to be saved in output files.
- `gdev.jkm.001.slurm` the main file that actually runs the model, i.e., what you submit to the job scheduler on Greenplanet.
The number of processors listed in this file must match what you used in the `NOTES_20_8_Startup` (note: `20_8` for 20 nodes with 8 CPUs each) file to set up and compile the simulation.
When setting up new runs you should edit the jobname, the name of the slurm script to match the new simulation name (i.e., for your second job, edit `gdev.xyz.001` into `gdev.xyz.002`), and the directory path that currently says `/DFS-L/SCRATCH/moore/USERID/cesm_runs/gdev.jkm.001.slurm` (outdated!).
 (At NCAR this is `gdev.jkm.001.run`?).


### Files: model-run output data (outdated)
The model-run output data files are written in two directories, which are automatically created (outdated!)
- `/DFS-L/SCRATCH/moore/USERID/gdev.xyz.001/run/` where the model actually runs: Initially, all output files are written to this directory.
- `/DFS-L/SCRATCH/moore/USERID/archive/gdev.xyz.001/` long term storage of the model output and the restart files (note that the path is different from the run/ directory).
Output files from simulations are automatically copied here at the end of the simulation.

After the model has been run, the data files (NetCDF) containing the data to plot for, e.g., the ocean, are located in `/DFS-L/SCRATCH/moore/USERID/archive/gdev.xyz.001/ocn/hist/` (you can delete some files if the model run was not good as long as you take notes).
You will mainly just use the output files with format  `gdev.xyz.001.pop.h.0001.nc` (standard annually-averaged ocean-model output files) or `gdev.xyz.001.pop.h.0001-01.nc` (same but monthly-averaged).

- Note 1: There are other output directories, such as `/ice` (for sea ice), `/atm` (for atmosphere), etc.
- Note 2: There is a `.../archive/gdev.xyz.001/rest/` subdirectory containing files for restarting the model or starting a branch run.
