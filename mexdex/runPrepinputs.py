#!/bin/bash 
sweepParamsFile=$1
casesListFile=$2

python2 mexdex/prepinputs.py --SR_valueDelimiter " " --SR_paramsDelimiter "\n" --noParamTag --CL_paramValueDelimiter =  $sweepParamsFile $casesListFile
