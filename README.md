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
* [Checking jobs that are running on Greenplanet](#checking-jobs-that-are-running-on-greenplanet)
* [Building Offline Transport Operators (Matrices) from CESM's POP2 Circulation](#building-offline-transport-operators-matrices-from-cesms-pop2-circulation)
* [MATLAB Build Ops File Organization](#matlab-build-ops-file-organization)
* [Notes on building the IRF masks](#notes-on-building-the-irf-masks)
  * [Notes on changes going from v1.0 to v1.2](#notes-on-changes-going-from-v10-to-v12)
  * [References:](#references)
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

<details><summary>Prerequisites if you are completely new to running CESM</summary>
<p>

> If you are completely new to running CESM on Greenplanet, follow these steps to set yourself up and running.
>
> 1. **Use git for your CESM runs** (Recommended but not mandatory).
>
>     1. Fork this repository on github (click the "Fork" button button at the top of this webpage)
>
>     1. Clone your fork somewhere on your laptop by opening a terminal in appropriate directory and typing
>         ```bash
>         cd PATH_WHERE_YOU_WANT_THE_REPOSITORY
>         git clone https://github.com/YOUR_GITHUB_ID/Lets_play_with_CESM.git
>         ```
>
>         <details><summary>Additional recommendation</summary>
>         <p>
>
>         > You can make a `Projects` directory in your laptop's `$HOME` directory, so that you have a single place where you clone all your repositories.
>         > In my case, I just typed:
>         >
>         > ```bash
>         > cd ~/Projects
>         > git clone https://github.com/briochemc/Lets_play_with_CESM.git
>         > ```
>
>         </p>
>         </details>
>
>
>
> 1. **Connect to Greenplanet** via `ssh` using `gplogin2` (`gplogin1` and `gplogin3` go to the old machine) by opening a terminal and typing:
>     ```bash
>     ssh USERID@gplogin2.ps.uci.edu
>     ```
>     Note: from off campus you have to connect using a VPN, see www.libraries.uci.edu, click on button on upper left of page that says "Connect from Off Campus" and install the VPN software on your home PC.
>     **DO NOT** download any illegal content while on the VPN! (music, movies, etc. - UCI will notice!)
>
>     <details><summary>Additional recommendation</summary>
>     <p>
>
>     > I recommend adding an alias on your laptop to facilitate ssh connections.
>     > In my case, I added the following line to my laptop's `.bashrc`:
>     >
>     > ```bash
>     > gp2='ssh pasquieb@gplogin2.ps.uci.edu'
>     > ```
>     >
>     > Then I can connect to `gplogin2` by simply typing
>     >
>     > ```bash
>     > gp2
>     > ```
>     >
>     > in my laptop's terminal.
>
>     </p>
>     </details>
>
> 1. **Create the `run` directories** in your `SCRATCH` space on Greenplanet.
>     You will need those directories to exist:
>     ```bash
>     /DFS-L/SCRATCH/moore/USERID/
>      ├── cesm_runs
>      ├── archive
>      ├── IRF_runs
>       ...
>     ```
>     So if they do not exist yet, just type
>     ```bash
>     cd /DFS-L/SCRATCH/moore/USERID/
>     mkdir cesm_runs
>     mkdir archive
>     mkdir IRF_runs
>     ```

</details>
</p>


1. **Make a new local directory on your laptop**

    For each new run create a directory called `xyz.abc`, except replace `xyz` with your initials and `abc` with the run number.

    <details><summary>Example</summary>
    <p>

    > For my first CESM run, I created `bp.001` in this git repository, which looked like this:
    >
    > ```bash
    > ~/Projects/Lets_play_with_CESM
    >   ├── README.md
    >   └── bp.001
    > ```

    </p>
    </details>

1. **Copy and edit some files from `SampleNotesCESM1.98.1`**.

    You can find `SampleNotesCESM1.98.1` in this repository, or you can find it on Greenplanet.
    (I copied it in this repository for convenience on August 10 2018, and will update if I notice it being updated too - Maybe I will even get JKM to push to this repository or make his own eventually!)

    1. Copy `gdev.001.slurm` to your local `xyz.abc` directory, rename it to `xyz.abc.slurm`, and edit the job name to `xyz.abc` and the directory path to `/DFS-L/SCRATCH/moore/USERID/cesm_runs/xyz.abc`.
        This slurm file that you just edited will be used to submit the job (of running CESM) to the slurm scheduler on Greenplanet.

        <details><summary>Example</summary>
        <p>

        > For my second run, the slurm file is renamed to `bp.002.slurm` and this is what the two lines look like after editing:
        >
        > ```bash
        > #SBATCH --job-name=bp.002
        > ...
        > cd /DFS-L/SCRATCH/moore/pasquieb/cesm_runs/bp.002
        > ```

        </p>
        </details>

    1. Copy `NOTES_20_8_Startup` to your local `xyz.abc` directory and edit the values of `CCSMUSER` and `CASE_DST` to your user ID and case name.
        You can also edit the number of months to run CESM for at the end of the file.

        <details><summary>Example</summary>
        <p>

        > For my second run (`bp.002`) I have the following lines 5, 6, and 46:
        >
        > ```tcsh
        > setenv CCSMUSER             pasquieb
        > setenv CASE_DST             bp.002
        > ...
        > ./xmlchange -file env_run.xml -id STOP_N      -val 12
        > ```

        </p>
        </details>

1. **Connect to Greenplanet and load the compilers and modules**.

    Simply type the following after login in to Greenplanet:

    ```bash
    ml idl intel/2018.2 openmpi/3.0.1 netcdf/4.6.1
    ```

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


        <details><summary>Suggestion for future</summary>
        <p>

        > (This could probably be improved by using git for it?)
        > I personnaly have a function for that in my local .bashrc that looks like
        >
        > ```bash
        > function cp2gp2_cesmruns() # Copy to greenplanet cesm_runs (via gplogin2)
        > {
        >   scp -r $1 pasquieb@gplogin2.ps.uci.edu:/DFS-L/SCRATCH/moore/pasquieb/cesm_runs/$2
        > }
        > ```
        >
        > so that I only need to type
        >
        > ```bash
        > cp2gp2_cesmruns xyz.abc.slurm xyz.abc/
        > ```
        >
        > This could also be improved with another function like below (not tested yet)
        >
        > ```bash
        > function cpslurm2gp2() # Copy local xyz.abc.slurm file to greenplanet's cesm_runs/xyz.abc/ (via gplogin2)
        > {
        >   scp $1.slurm pasquieb@gplogin2.ps.uci.edu:/DFS-L/SCRATCH/moore/pasquieb/cesm_runs/$1/
        > }
        > ```

        </p>
        </details>


1. **Submit your job!**

    You can now submit your job by either copying **line 54** of the `NOTES_20_8_Startup` file and pasting it in your terminal session logged into Greenplanet or you can submit it directly by typing

    ```bash
    sbacth xyz.abc.slurm
    ```

    That's it, your job will running as soon as the slurm scheduler of Greenplanet has room for it! :thumbsup:


<details><summary>Suggested change to protocol</summary>
<p>

> [ ] Rewrite the `NOTES` files to directly use `$USER` instead of `$CCSMUSER`. 
>     Is there is a need for defining the variable `$CCSMUSER`.
> [ ] Automate more steps to avoid user mistakes.
>     That is, use a script to
>     [ ] figure out the value of `xyz.abc` (Why use `xyz` instead of `$USER`?)
>     [ ] `mkdir` the `xyz.abc` directory
>     [ ] `cp` the slurm file
>     [ ] Edit the slurm file
>     [ ] `cp` the `NOTES` file
>     [ ] Edit the `NOTES` file
>     [ ] Load the modules
> [ ] Have 2 separate notes files so that the workflow becomes simpler, like (i) run setup script, (ii) make user edits, (iii) run submission script.

</p>
</details>


## Checking jobs that are running on Greenplanet

List of basic commands to type directly in the command line interface:
- `squeue` lists all jobs currently running on Greenplanet.
- `squeue –u USERID` lists all jobs submitted by `USERID` that are currently in the queue or running (`u` is for user).
- `squeue –q QUEUENAME` lists all jobs in the `QUEUENAME` queue (`q` for queue).
    Note JKM's queues are called `nes2.8` and `sib2.9`.
- `scancel JOBID` kills the job with the ID `JOBID`.
    (The job IDs are displayed by `squeue` commands.)
- `sbatch SCRIPT.slurm` submits the job `SCRIPT.slurm` to the scheduler.
    (Note: commands on Yellowstone are different: for example, `SCRIPT.submit` submits the job.)

More information on the slurm workload manager can be found at https://slurm.schedmd.com.

## Building Offline Transport Operators (Matrices) from CESM's POP2 Circulation

It is assumed that a POP2 parent has been spun-up dynamically, and that a restart file exists.
These instructions are for version 1.2.2.1, nominal 3° horizontal resolution.



<details><summary>Reference documents</summary>
<p>

> - CESM tutorial link: http://www2.cesm.ucar.edu/events/tutorials/2014
>
> - CESM bulletin board: http://bb.cgd.ucar.edu/
>
> - CESM User’s Guide (CESM1.2 Release Series User’s Guide): http://www2.cesm.ucar.edu
>     - select "Models" in the top selection bar
>     - select "CESM1.2.z" under the "Supported CESM Release Versions" title
>     - under "Model Documentation", "CESM1.2", are selectable:
>         - User's Guide
>         - Model Component `Namelists`
>         - `$CASEROOT` xml files

</p>
</details>

<details><summary>Directory structure as implemented on Cheyenne by AB</summary>
<p>

This is the directory structure assumed in the build scripts **as implemented on Cheyenne by AB**.

```bash
$HOME/IRF_X3/
 ├── $CASNAME_1.notes       # command procedures to be executed to implement
 ├── $CASNAME_2.notes       # the generation of the IRF output files
 ...


/SCRATCH/
 ├── cesm1_2_2_1            # standard release (Note: different from 1_2_2?)
 │   │
 │   ├── models             # code, definition files
 │   │
 │   ├── $CASNAME_1         # (created by the build)
 │   │   ├── CaseDocs
 │   │   ├── env_*.xml
 │   │   ├── *.build
 │   │   ├── *.submit
 │   │   ...
 │   │
 │   ├── $CASNAME_2         # (created by the build)
 │   ...
 │
 ├── cesmX3_data            # mods, definition files for IRF
 │
 ├── $CASENAME_1            # built definition and run files (created by the build)
 │
 ├── $CASENAME_2            # built definition and run files (created by the build)
 │
 ...
```

</p>
</details>


<details><summary>Status of things as of 8/10/2018 (from AB email)</summary>
<p>


> My `T62_gx3v7_CIAF.IRFtakeoff.016.notes` file used on Cheyenne for the branch run to make the operators is in `/DFS-L/DATA/moore/abardin/cheyenne/IRF_X3/v1.2.2.1/`.
>
> This will need to be merged with JKM's notes to make the branch run with the IRF takeoff.
>
> **Merging the code mods**
>
> In `/DFS-L/DATA/moore/abardin/IRF_mods_X3v1.2.2.1/`, are 3 subdirectories that I used to merge my IRF mods and JKM's mods:
> - `SourceMods.IRF` has the IRF mods copied from Cheyenne.
>     It also has `List_of_MERGE_files.txt`, which lists the files for which
>     there were versions in both `SourceMods.IRF` and `SourceMods.JKM`,
>     and therefore had to be merged into one version in `SourceMods.JKM.IRF`.
>
> - `SourceMods.JKM/gdev.720/` contains JKM's mods copied from his `dev.720/run/SourceMods` directory before he continued the run.
>     (Some files were changed when he continued the run, which is why we must get a copy of his `.notes` file that was used for the segment of the run that we are to do the IRF takeoff from, as a standard part of our procedure.)
>
> - `SourceMods.JKM.IRF/gdev.720/` contains the merged set of files.
>     This is the set that will need to be applied to the branch run.


</p>
</details>


1. **Make a branch run of the POP ocean model with the IRF module installed**

    1. **Copy to your own directory set from an existing example set**
        - Directory `/cesmX3_data/*`
        - File `$CASENAMEx.notes` (to be modified for your new case)

    2. **If it does not exist, build `IRF_offline_transport_tracers_grid_name.nc`**

        (It should be in `cesmX3_data/`, but not in this repo since it is a NetCDF file)

        <details><summary>How to build `IRF_offline_transport_tracers_grid_name.nc`</summary>
        <p>

        > There is a NCL script, `gen_IRF_offline_transport.ncl` in `cesmX3_data` (on AB's copy from `/glade/p/cgd/oce/people/klindsay/cesm12_cases/IRF/`) which can be used to generate this NetCDF file.
        > Executing the script will generate 125 IRF tracers (with `1`s and `0`s), and additional tracers for the overflow "source" and "entrainment" regions.
        > The generated IRFs are stored in NetCDF file `IRF_offline_transport_tracers_grid_name.nc`
        >
        > The script should be modified for the following:
        >
        > - output directory (`basis_function_dir`)
        >      (The directory with the output impulse variables for POP v1.2 is `glade/p/cesm/bgcwg/klindsay/IRF/`)
        > - grid name (`grid_name`), valid values are `gx1v6` or `gx3v7`
        > - For other versions of POP, check also for new names for `grid_dir` and `grid_fname`, for the input grid definitions.
        > - Note that the locations for the overflow special handling, "source" and "entrainment" regions, are hard-coded in this routine.

        </details>
        </p>

    3. Build the branch run case, with the IRF mods installed.

        If there are other mods to the standard model, other than the IRF mods, they will need to be merged before both sets of mods are used in the build process.

        For each `$CASENAME`, the steps and commands to set it up and run it are in the file `$CASENAME.notes`.
        To do the IRF-build, execute a modified copy of the `*.notes` file, with a new `$CASENAME`. The `*.notes` file is scripted to be run interactively (i.e., don't copy the comments because `tcsh` does not understand them!).

        `RUN_REFCASE` is physics run from which the IRF run is branched.
        `RUN_REFDATE` is date of branching (in model time)
        Scripts assume that restart files for `$RUN_REFCASE` at `$RUN_REFDATE` are in the directory `/$RUN_REFCASE/$RUN_REFDATE-00000`.

        These definitions are set in the `*.notes` file.
        Note that the sequence numbers on the end of the `*.notes` files do not match the numbers for the IRF build cases.
        That is, the reference case from which the branch run is made does not have the same sequence number as the IRF-build case branch run.

        For the v1.2.2.1 X3 standard code, the base run was implemented in `T62_gx3v7_CIAF.IRF.003.notes`;
        this can be used for reference.
        To see what restart files are available for making a branch run to do the IRF takeoff, look in the `/archive/$RUN_REFCASE/rest/`.


        If you are running a different configuration, the number of tracers may be different, and will need to be changed:
        - change value for `IRF_NT`
        - change the name of the IRF definition file.

        The length of run is specified by `STOP_OPTION` (`ndays`, `nmonths`, `nyears`) and `STOP_N` (integer value).
        Runs normally require changes to the time limit in the `.run` script.
        (The `.run` script is generated as part of the build process.)

        Changes to POP's namelist, if needed, can be placed in `$CASEROOT/user_nl_pop2`, after the `$CASEROOT` directory has been generated (with some caveats listed in the top of the file).
        This is done with following commands in `$CASE.notes` file:
        ```tcsh
        cat >> user_nl_pop2 << EOF
        ...
        EOF
        ```

        The IRF output variables are hardcoded to `tavg` stream 1 (ocn.IRF.setup.csh).
        (For information on how to change `tavg` variables and data stream assignments, see [here](http://www.cesm.ucar.edu/models/cesm1.1/pop2/doc/faq/#nml_tavg_change_nml).)
        Default values for 4 `tavg` controlling variables are:
        - `tavg_freq_opt = 'nmonth' 'nday' 'once'`
        - `tavg_freq = 1 1 1`
        - `tavg_file_freq_opt = 'nmonth' 'nmonth' 'once'`
        - `tavg_file_freq = 1 1 1`
        - 1st stream is monthly averages, 1 month per file
        - 2nd stream is daily averages, 1 month per file
        - 3rd stream is once per run at initialization, 1 file per run.

        The mechanisms for changes to the `namelist` and `tavg` names and frequencies are described in the CESM users guide (listed above).

        Output of IRF variables with 5-day means, one 5-day mean per file would be achieved by appending the following lines to `user_nl_pop2`:
        - `tavg_freq_opt = 'nday' 'nday' 'once'`
        - `tavg_freq = 5 1 1`
        - `tavg_file_freq_opt = 'nday' 'nmonth' 'once'`
        - `tavg_file_freq = 5 1 1`

        Modified files specific to IRF are in `/cesmX3_data/ directory`.
        These are automatically applied in the `*.notes` scripts.
        If you are working with a base POP model that has non-standard code or parameter settings, the base-set modifications will need to be merged with the IRF-modified code before the build is made.


        <details><summary>List of IRF modifications</summary>
        <p>

        - `./build-namelist`
            The directory with the unmodified version `$CCSMROOT/models/ocn/pop2/bld`.
            This is a perl script that constructs POP's namelist file, `pop2_in`.
            Modifications are to include `namelist` variables for `IRF_nml`, the `namelist`.
            For IRF mods, the IRF tracer module namelist variables are:
              - `irf_tracer_file`
              - `IRF_MODE`
            The generated `pop2_in` file is in `$CASEROOT/CaseDocs/pop2_in`.

        - `./namelist_definition_pop2.xml`
            The directory with the unmodified version is `$CCSMROOT/models/ocn/pop2/bld/namelist_files`.
            This is an `.xml` file with documentation of all namelist variables.
            Modifications are to include `IRF_nml` variables.

        - `./namelist_defaults_pop2.xml`
            The directory with the unmodified version `$CCSMROOT/models/ocn/pop2/bld/namelist_files`
            This is an `.xml` file with default values for all namelist variables.
            Modifications are to include defaults for `IRF_nml` variables.

        - `./pop2.buildexe.csh`
            The directory with unmodified version is `$CCSMROOT/models/ocn/pop2/bld`.
            This is the script to build the POP2 executable.
            Modifications are to add IRF tracers to POP's full tracer count and to make output double precision.

        - `./ocn.IRF.tavg.csh`
            This is a new file that will in future releases be placed in directory `$CCSMROOT/models/ocn/pop2/input_templates`.
            This script generates tavg output variable names:
            - `HDIF_EXPLICIT_3D_$var_name`
            - `ADV_3D_$var_name`
            - `VDC_GM`: on the bottom face of a cell.

        - `./advection.F90`
            The directory with unmodified version is `$CCSMROOT/models/ocn/pop2/source`
            Modifications are to add `ADV_3D_` vars and positive and negative parts of velocity as variables that can be recorded using the `tavg` mechanism.

        - `./baroclinic.F90`
            The directory with unmodified version is `$CCSMROOT/models/ocn/pop2/source`.
            Modifications are to add a new argument to `reset_passive_tracers`.

        - `./hmix_gm.F90`
            The directory with the unmodified version is `$CCSMROOT/models/ocn/pop2/source`
            Modifications are to add `VDC_GM` `tavg` variable.

        - `./horizontal_mix.F90`
            The directory with unmodified version is `$CCSMROOT/models/ocn/pop2/source`.
            Modifications are to add `HDIF_EXPLICIT_3D_` variables.

        - `./passive_tracers.F90`
            The directory  with unmodified version is `$CCSMROOT/models/ocn/pop2/source`.
            Modifications are to add a call to the `IRF_mod` subroutines.

        - `./IRF_mod.F90`
            This is a new file that in future releases will be placed in directory `$CCSMROOT/models/ocn/pop2/source`.
            Differences from prior version are:
            - read namelist variables
            - reading impulse variable names from impulse variable file
            - read impulse variables from impulse variable file
            - reset `newtime` values from `oldtime` values

        (`vertical_mix.F90` is not modified
        (`VDC_KPP_{1,2}` in the previous IRF mod set now exists in standard code now as `VDC_{T,S}`.)
        `VDC_{T,S}` are on the bottom face of a cell.)

        </details>
        </p>

    4. Run the dynamic model to generate the IRF circulation variables output.

        As is mentioned in the `$CASENAME.notes`, edit the `$CASENAME.run` file to give the proper project number, the needed time limit, `jobname`.
        Then submit the job to the queue.
        The `$CASENAME.submit` file contains some preliminary checks before submission to the queue of `$CASENAME.run`.
        In the `$CASENAME` directory, `/$CASENAME.submit`.

        To monitor the job `qstat` gives status for all of your Cheyenne jobs.

        The IRF output from the run is in `/glade/scratch/’username’/archive/$CASENAME/ocn/hist/`.
        The processing of the IRF output to make the offline operators begins with Step 2.


1. Build the IRF masks

    The IRF mask building has been split off into a separate program because it only needs to be run once for a given configuration.
    For the 1.2.2.1 X3 configuration the masks are saved in `/glade/p/work/abardin/IRF_masks/CESM1.2_X3/`

    Note that as a convention for STEP 2 and beyond, directories are not built on the fly;
    they must be pre-built before the execution of any of the software that puts files into them.

    The definitions for the overflow source, entrainment, and product regions have been adapted from the `gx3v7_overflow` file, which is part of the standard release, and can be found in `[cesm_version]/models/ocn/pop2/input_templates/`.
    The definition for the product region is from an edited version of the `gx3v7_overflow` file.

    The source and entrainment regions are hard-coded in `build_stencils_X3.m`.
    The product regions are read in from a text file that must be created as described in STEP 2a.

    1. Make sure the MATLAB script can read the output

        Edit POP source file `*_overflow`, to create `*_overflow_data.txt`, formatted so that the Matlab script can read it.
        There are formatting and editing definitions at the end of `build_stencils_X3.m`

        OR

        A version of the already edited file for the X3 configuration can be found in the `IRF_masks` directory listed above.

    2. Edit some files

        Edit the parameters at the beginning of `build_stencils_X3.m` to define the file names and directories to access, and the "expected configuration dimensions", which is used as a check for consistency with the NetCDF output data from the model run.
        For a new configuration, the definitions for the source and entrainment regions, which are hard-coded in `build_stencils_X3.m`, will need to be modified.

    3. Execute `build_stencils_X3.m.`

        The IRF masks are built, and saved in the specified directory (on Cheyenne, `/glade/p/work/IRF_masks/CESM1.2_X3`).
        There are `NOTES` below (near the end of this document) giving additional details of the code that makes the masks.


3. Make the transport operators

    The end-product are operators `A`, `H`, `D`, `T`, plus the periodic adjustment term `dxidt`.
    These are organized into monthly files plus an annual average file in the final directory.

    The processing to achieve a monthly climatologically averaged set of operators has 2 stages:
    - The IRF monthly output is converted into monthly operators; these are kept in `noc_dir` as building blocks for the second stage.
    - The climatological monthly sets of operators, and the annual average set are made, together with the periodic adjustment term dxidt.
    Doing the processing in two stages allows for various climatological averages to be made relatively easily.

    In `noc_dir` directory, the month starts with the first of the first model year to be processed, and the month number continues consecutively.
    For example, if you have 3 years worth of output files, they are numbered 1 through 36.

    The final climatologically averaged operator set generated in the `ops_dir` directory contains a set of monthly operators, numbered 1 through 12, and the annual average, numbered 0.

    1. Build the `noc` monthly operators from the IRF output
        The set of operators in the `noc` directory is extracted from the IRF output, and does not have any SSH (sea surface height?) adjustment factor.
        This processing is set up with some bash command files, such that batches of 12 months can be processed in parallel.
        (Only 12 because of the limitation on the number of Matlab licenses available at the Cheyenne site.)
        The procedure will not start the processing for each month unless there are plenty of spare licenses available.

        1. Edit `Build_control_mo.slurm`
            Modify the number of years to process in the statement

            ```
            for year in {1..n}; do
            ```

        1. Edit `runM[n].slurm` files.
            Modify the reference file names.
            These are the IRF-takeoff output files that are in the `/archive/`.
            Modify the location of the `noc_dir`, where the unadjusted monthly operators are to go.
            Modify the `zeroyr`, which is the year before the first year of the IRF-takeoff output.


        1. Edit `buildMET.m` if this is a new configuration.
            `buildMET.m` contains the definitions of the mask-outs for the marginal seas that are not included in the offline model.
            It also contains the expected dimensions of the model, in order to check for a consistent definition.
            `ms_buildMET.m`, which generates the geometric definitions without the marginal seas masked out, also contains the expected dimensions of the model, and must be made consistent with `buildMET.m`.

        1. Execute `Build_control_mo.slurm`

            ```bash
            sbatch Build_control_mo.slurm
            ```

            This is the job control file.
            It runs the processing of the IRF-takeoff files, making the `noc` operators monthly files, up to 12 months at a time.

            Be patient - this takes awhile.

            The control flow is as follows:

            - `buildMET` builds the geometric data that is needed for processing the operators and/or running with them.
                `MET` is saved in the `noc_ops` directory.
            - `make_ops_from_IRF_output` builds the ocean-sized matrix operators (excludes land points) from the OGCM NetCDF output files.
                The operators have not yet been adjusted to make them annually-periodic, and are thus in an intermediate state.
                The files are output to the `noc_dir` directory.

            The monthly operator sets are in files `MTM[n].mat`, where `n` runs from 1 to the last month processed.
            Each `MTM` file contains the operators `A` (advection), `H` (horizontal diffusion), `D` (vertical diffusion), and `T` (total `T = A + H + D`).

            Inputs are the netcdf history files from the dynamic model run, the IRF-masks that were made in STEP 2.

        1. Build the state data files
            The job file `runBldStateData.slurm` is to be parameterized to give the basic name for the dynamic model output files, which years, and how many years are to be processed.
            The job executes `Build_state_data.m`, which collects selected monthly data from the dynamic model's output files, and saves it in the noc directory.

    1. Generate the climatologically averaged operator set

        The code for this is in the `/BUILD_FAST/[version]/multi_yr_build/` directory.
        The control file is `BLD_multi_yr_clim_mo.slurm`.
        In the control file are defined the `noc` directory, the final `ops` directory, which years and how-many years to use for the climatological average.
        The final operator directory contains only monthly files that are included in the annualized average, numbered according the calendar month, and the annualized average (`MTM0.mat`).
        The periodic adjustment has been applied to the sets of operators.
        The state-data files are also climatologically averaged and included in the `ops` directory.

        The major logic for generating the climatologically averaged operator set is in the following files:

        - `make_A_periodic` computes the periodic adjustment for the surface layer from the divergence of the annual advection operator.
            This is applied to the `A` and `T` operators for all the months in the annual set, in addition to the annual average `A` and `T`.
            For each month, the change in sea-surface height (SSH) is calculated from the row-divergence in the surface layer grid-cells to compensate for the SSH changes during the month.
            The term is `dxidt`, which is the change in `Xi` (dxi)` (?) per unit time (`dt`)
            It is used when stepping the offline model through a seasonal cycle per equation (12) of *Bardin et al.* [2014].

        - Mass-balance and row-divergence are checked on the resulting operators.
            Each monthly output file contains `A`, `H`, `D`, `T`, `dxidt` at this point, in the final directory.
            Checks are also made that each IRF pulse occurred once, and only once; and that operator fields are not on land.

        - `build_model_state_data` builds `.mat` files containing `SSH`, `TEMP` (potential temperature), `PD` (potential density), `SALT` (salinity), `RHO` (in-situ density), `IFRAC` (sea-ice fraction, and other variables that are convenient to have for additional BGC processing.
            `SSH` is used in starting up a seasonal cycle in the offline model.

    1. Delete temporary files
        Delete the files in the `tmp_mo` directory, that were used for the IRF pulse check.
        From this point forward they are no longer needed.



1. Enjoy using the offline operators.
    An example of using the operators is given for radiocarbon in *Bardin et al.* [2014].


## MATLAB Build Ops File Organization

The files are listed by top-level-script or function, then the functions called.
The file ending of `X1` or `X3` means they contain configuration details for the nominal 1° and 3° configurations of the POP model.

- In directory `/glade/u/home/abardin/BUILD_FAST/X3_v1_2_2_1/noc_ops_build/`:
    - `BldStencils.slurm` job control to build the IRF masks (stencils).

    - `Build_stencils_X3.m`
        Builds the `Impulse_Response_Function` (IRF) set of masks (also referred to as stencils) needed to pick up the output from the IRF dynamic parent model runs.
        Uses in-file functions:
        - `make_stencils_61` constructs the regular IRF masks, and those for the source and entrainment regions.
        - `setup_stencil_bands_61` makes the X, Y, and Z bands for the POP stencils from the dimensions specified.
        - `make_prod_stencil_61` constructs the extended masks for the product areas.
        At the end of the `Build_stencils_X3.m` file, are the definitions for the formatting of the product regions definition file.

    - `Build_control_mo.slurm` job control to build the noc operator set, with monthly processing overlapped.

    - `runM[n].slurm` job control to build one month’s IRF output and create a noc monthly file.

    - `Build_monthly_ops.m`
        The purpose of `Build_montly_ops.m` is to build the advection/diffusion operators for the offline model from the history files resulting from running the POP ocean model with the "IRF tracers" turned on.
        This script invokes functions which output files containing a sparse matrix with each operator (`A` (advection), `H` (horizontal diffusion, `D` (vertical diffusion), for each month specified in the control job.
        The monthly files are saved in the `noc` operator directory.
        Uses external file functions
        - `buildMET.m` gathers the geometric data from a netcdf history file

        - `make_ops_from_IRF_output.m` collects the output from the netcdf history files, and makes the operators.
            Uses external file functions:
            - `get_g_data.m` forms `A` and `H` operators from the regular IRF output
            - `get_s_data.m` forms `A` and `H` operators from overflow source IRF output
            - `get_e_data.m` forms `A` and `H` operators from overflow entrainment IRF output
            - `get_VDC_data.m` gets vertical diffusion parameters from IRF output
            - `Vdiff.m` makes `D` operators from `VDC` data
            - `pulse_ck.m` checks IRF pulse locations are in all ocean grid cells, and only once for each grid cell
            - `ck_landfall` checks that operators do not have values on land grid cells

- In directory `/glade/u/home/abardin/BUILD_FAST/X3_v1_2_2_1/multi_yr_build/`
    - `BLD_multi_yr_clim_mo.slurm` job control for making the climatologically averaged operators and state data

    - `Build_multi_period.m` makes the adjustment for annual periodicity to the operators
        Uses external file functions:
        - `make_A_periodic.m` calculates the 2-D modification to the surface grid cells for the advection operator, to make it cyclic on an annualized basis, without divergence.
            Uses internal file functions
            - `mkAtilde2d` makes the annual periodic-adjustment operator for advection
            - `grad` makes the gradient operator from the grid-cell geometry
            - `div` makes the divergence operator from the grid-cell geometry
            - `load_iocn_ops` loads the un-adjusted operators from the `noc` directory
            - `display_op_div` makes displays of operator divergence (for debugging)

        - `make_annual_ops.m` makes annualized average operators with the adjustment, and saves them in the ops directory
            Uses internal file functions:
            - `annual_avg_dmo` makes annualized average operators from the monthly ones

        - `ck_ops_massb_div.m` provides mass-balance and row-sum checks

    - `Build_mo_climate_state.m` builds a set of climatological monthly data files containing `SSH`, and other model data frequently needed for biogeochemical models.


## Notes on building the IRF masks

There are three types of masks used.
Each mask deals with the possible results of one IRF source grid-cell, and the possible grid-cells that may be impacted after one timestep.
The `g_irf_mask` is for the general case, where the impulse may have an impact on any cell within 2 grid-cells in each of the 3 dimensions.
These masks define a 3D box with a total of 125 grid-cells, with the impulse grid-cell in the middle.
The `s_irf_mask` defines the locations impacted from an impulse in the overflow source region.
This includes anywhere in the source region itself, plus 2 grid-cells bordering the source region;
specified grid-cells in the associated overflow entrainment region;
and specified grid-cells in the associated overflow product region.
The `e_irf_mask` is defined for the entrainment region, since it acts as an additional source.
The `e_irf_mask` is for an impulse within the entrainment area, and includes the entrainment area, and the associated product grid-cells further down-slope.

In `build_stencils_X3.m`, the parameters are defined for the general IRF masks.
The numbers of masks are defined by `PARAM.g_imin` (1) to `PARAM.g_imax` (number of cells in the x–dimension), etc. for each dimension.
The z-dimension has an extra layer compared to the OGCM to ensure that there is land (or air) on all boundaries.
`PARAM.g_X_band` defines how many cells there are on each side of the subject Impulse cell in the x dimension (=2).
This is similar for the other dimensions.
`PARAM.g_Y_limit` (= 0) is a constraint on the Y dimension, which has no effect on the general IRF mask, but is provided for compatibility with this parameter for the source and entrainment definitions.

The source and entrainment definitions are given in a format that matches that in the Fortran source code.
Each column defines one source or associated entrainment region's location in terms of the xyz cell indices.
The `PARAM.Y_limit` is a constraint in the y direction to assure that there is no overlap.
All of the parameters are passed to the function `make_irf_masks`, which is in the same file.

Function `make_irf_masks` first makes the regular masks, in a 2-step process.
It uses function `setup_irf_bands` to set up a band of matrices in each dimension.
The bands are then propagated in each direction using the kron function, which makes a matrix of matrices (the Kronecker tensor product).

Function `setup_irf_bands` builds an nx by nx matrix, with bands on the diagonal that are + and – `X_band` (defined in the `PARAMs`) wide.
The band is extended to deal with the wrap-around of the globe in the x-dimension.
The band in the y-dimension is built in a similar manner, but with a limitation on the dimension that keeps regions from overlapping.
This has no effect for the general IRF mask, and actually only has an effect if the definitions of the overflow regions overlap.
A similar banded matrix is made for the z-dimension.

Within function `make_irf_masks`, the overflow "source" region masks are made in a similar manner, but within the dimensions of each source region.
The masks are extended with the "product" regions, which include areas within the associated "entrainment" region and further down-slope.
The overflow entrainment masks are defined in a similar manner.

Within function `make_irf_masks`, the product region masks are created in function `make_prod_mask`.
This is a separate function because the product-area masks are defined in a different way.
The locations of the product regions are determined by reading the `product_txt_file`.
The way that the product areas are specified is somewhat convoluted;
there are some detailed notes on the format of the file at the end of file `build_stencils_X3.m`.
There may be several product areas associated with one overflow region, including parts of the entrainment area, and further downslope.
A mask is created that includes all of the possible product area grid-cells for the overflow region.

### Notes on changes going from v1.0 to v1.2

The interface to the prognostic POP model is organized differently.
The version 1.2 interfaces are described above.
The output variables in the history files have the same names as much as possible, however, there are some changes:
- For the `VDC` data, version 1.2 name `VDC_T` (for temperature) replaces v1.0 name `VDC_KPP_1` (not used for the standard operators).
- Version 1.2 name `VDC_S` (for salinity) replaces v1.0 name `VDC_KPP_2`.
- For both `VDC_S` and `VDC_GM`, the values given are on the BOTTOM of the cell, rather than the top.
    The two variables need to be added together to get the total coefficient for vertical diffusion, as before.

Another significant change is that the pulse locations are not output in the history file.
Instead, they can be read from a file that was created from the definition of the pulse locations.
For version 1.2 this is located on Cheyenne at `/glade/p/cesm/bgcwg/klindsay/IRF/IRF_offline_transport_tracers_gx1v6.nc`, and the equivalent for `gx3v7`.
This file is copied into the output `/case_name/` directory for access when building the offline operators.
It was found that this file has in addition to the pulses in the ocean, pulses in all the land grid-cells, which must be masked out to make the file usable.

The variable `KPP_NONLOC_KERN` in version 1.0 is not recorded in the history file;
the processing for the corresponding off-line operator has been deleted.

All 178 of the tracers were captured in a single 1-year run; as opposed to the previous 7 runs required in version 1.0.
Changes were made in `BUILD_OPS.m` and functions it uses to eliminate the number of cases required, and the file handling to extract the data.

### References:

Bardin, Ann, Francois Primeau, Keith Lindsay, **An offline implicit solver for simulating prebomb radiocarbon**, *Ocean Modelling* (2014)

Briegleb, B.P., Danabasoglu, G., Large, W.G., 2010. **An Overflow Parameterization for the Ocean Component of the Community Climate System Model**. *NCAR Technical Note*. NCAR.

Smith et al., **Parallel ocean program (POP) reference manual** (2010)

Online users guide:
CESM User’s Guide (CESM1.2 Release Series User’s Guide): http://www.cesm.ucar.edu/models/cesm1.2/cesm/doc/usersguide/x1955.html

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
