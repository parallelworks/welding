#!/bin/bash 
CcxExec=$1 
ccxInputFile=$2
WORK_DIR=$(pwd)

execDir=$(dirname "${ccxInputFile}")
ccxfilename=$(basename "$ccxInputFile")
ccxfileRootName="${ccxfilename%%.*}"
echo $ccxInputFile
echo $ccxfilename
echo $ccxfileRootName

# Copy matLibFile to execution directory if provided
if [ "$#" -eq 3 ]; then
	matLibFile=$3
	cp $matLibFile $execDir/
fi

chmod +x  $CcxExec

# Export to EXODUSII for ParaView simulation
cd $execDir
$WORK_DIR/$CcxExec  $ccxfileRootName  -o exo

