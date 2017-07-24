#!/bin/bash 
ccxInputFile=$1
desiredMetricsFile=$2
pvOutputDir=$3
outputMetrics=$4

WORK_DIR=$(pwd)

pvpythonExtractScript=utils/extract_Box_json.py
pythonPlotScript=utils/plot.py

#PARAVIEWPATH="/home/marmar/programs-local/ParaView-5.3.0-Qt5-OpenGL2-MPI-Linux-64bit/bin/"
#export PATH=$PATH:$PARAVIEWPATH

execDir=$(dirname "${ccxInputFile}")
ccxfilename=$(basename "$ccxInputFile")
ccxfileRootName="${ccxfilename%%.*}"

# Extract metrics from results file

resultsExoFile=$execDir/$ccxfileRootName.exo

# If opengl is old : 
# xvfb-run -a --server-args="-screen 0 1024x768x24" pvpython --mesa-llvm  $pvpythonExtractScript  $resultsExoFile $desiredMetricsFile  $pvOutputDir $outputMetrics
xvfb-run -a --server-args="-screen 0 1024x768x24" $PARAVIEWPATH/pvpython  $pvpythonExtractScript  $resultsExoFile $desiredMetricsFile  $pvOutputDir $outputMetrics


#convert -delay 15 -loop 0  $pngDir/*.png $animFile

shopt -s nullglob # sets wildcard response to null
for f in ${pvOutputDir}plot_*.csv;do
    python $pythonPlotScript $f
done
