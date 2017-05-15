#!/bin/bash 
CgxExec=$1 
InpName=$2
chmod +x  $CgxExec
$CgxExec -bg $InpName
