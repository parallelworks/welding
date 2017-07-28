#!/bin/bash 
CcxExec=$1 
ccxInputFile=$2

if [ "$#" -eq 3 ]; then
	matLibFile=$3
fi


WORK_DIR=$(pwd)

pvpythonExtractScript=utils/extract_Box_json.py
pythonPlotScript=utils/plot.py

execDir=$(dirname "${ccxInputFile}")
ccxfilename=$(basename "$ccxInputFile")
ccxfileRootName="${ccxfilename%%.*}" 


# Copy matLibFile to execution directory if provided

if [ "$#" -eq 3 ]; then
	cp $matLibFile $execDir/
fi

chmod +x  $CcxExec


# Run simulation with EXODUSII output for ParaView 
if [ "$embeddedDocker" = true ] ; then
	cp $WORK_DIR/$CcxExec $execDir
	ccxBinName=$(basename "$CcxExec")
    cd $execDir
    docker run --rm -i -v `pwd`:/scratch -w /scratch -u $(id -u):$(id -g) avidalto/calculix:v8 ./$ccxBinName $ccxfileRootName -o exo
    cd $WORK_DIR    
else
cd $execDir
$WORK_DIR/$CcxExec  $ccxfileRootName  -o exo
cd $WORK_DIR
fi
