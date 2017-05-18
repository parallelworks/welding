#!/bin/bash 
CcxExec=$1 
InpName=$2
chmod +x  $CcxExec
# EXPORT TO EXODUSII FOR PARAVIEW SIMULATION
$CcxExec  $InpName -o exo
