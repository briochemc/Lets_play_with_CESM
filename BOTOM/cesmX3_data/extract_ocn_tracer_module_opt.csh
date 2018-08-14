#!/bin/csh -f

#
# extract values from key-value pairs in OCN_TRACER_MODULES_OPT
#
# extracted value is written to last line of stdout, with no trailing newline
# usage is to pipe stdout through 'tail -n 1' to get extracted value
# this allows debugging write statements to be added to script without disrupting its usage
#
# known keys, with default value in parentheses, are:
#   IRF_MODE ( offline_transport)
#   IRF_NT (depends on IRF_MODE and OCN_GRID)
#   ECOSYS_NT (27)
#   ZOOPLANKTON_CNT (1)
#   AUTOTROPH_CNT (3)
#   GRAZER_PREY_CNT (3)
#

set key = $1

#
# set default value
#

set retval = unknown

# IRF module option defaults

if ($key == IRF_MODE) set retval = offline_transport
if ($key == IRF_NT) then
  set retval = 36 # default for default IRF_MOD=NK_precond
  set IRF_MODE = offline_transport  # `$0 IRF_MODE | tail -n 1`
  if ($IRF_MODE == offline_transport) then
    set retval = 125 # default for grids with no overflows
    if ($OCN_GRID == gx3v7) set retval = 156
    if ($OCN_GRID == gx1v6) set retval = 178
  endif
endif

# ecosys module option defaults

if ($key == ECOSYS_NT)       set retval = 27
if ($key == ZOOPLANKTON_CNT) set retval = 1
if ($key == AUTOTROPH_CNT)   set retval = 3
if ($key == GRAZER_PREY_CNT) set retval = 3

#
# parse OCN_TRACER_MODULES_OPT for specified value
#

foreach module_opt ( `echo $OCN_TRACER_MODULES_OPT` )
  if ( `echo $module_opt | cut -f 1 -d =` == $key ) then
    set retval = `echo $module_opt | cut -f 2 -d =`
  endif
end

echo -n $retval

exit 0
