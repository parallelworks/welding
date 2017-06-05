#!/bin/bash 
CcxExec=$1 
ccxInputFile=$2

desiredMetricsFile=$3
pvOutputDir=$4
outputMetrics=$5

WORK_DIR=$(pwd)

pvpythonExtractScript=utils/extract_Box_json.py
pythonPlotScript=utils/plot.py

#PARAVIEWPATH="/home/marmar/programs-local/ParaView-5.3.0-Qt5-OpenGL2-MPI-Linux-64bit/bin/"
export PATH=$PATH:$PARAVIEWPATH

execDir=$(dirname "${ccxInputFile}")
ccxfilename=$(basename "$ccxInputFile")
ccxfileRootName="${ccxfilename%%.*}"

# Copy matLibFile to execution directory if provided

if [ "$#" -eq 6 ]; then
	matLibFile=$6
	cp $matLibFile $execDir/
fi

chmod +x  $CcxExec


# Run simulation with EXODUSII output for ParaView 

cd $execDir
$WORK_DIR/$CcxExec  $ccxfileRootName  -o exo
cd $WORK_DIR


# Extract metrics from results file

resultsExoFile=$execDir/$ccxfileRootName.exo
xvfb-run -a --server-args="-screen 0 1024x768x24" pvpython  $pvpythonExtractScript  $resultsExoFile $desiredMetricsFile  $pvOutputDir $outputMetrics


#convert -delay 15 -loop 0  $pngDir/*.png $animFile

shopt -s nullglob # sets wildcard response to null
for f in ${pvOutputDir}plot_*.csv;do
    python $pythonPlotScript $f
done
