#!/bin/bash 
ccxInputFile=$1
desiredMetricsFile=$2
pvOutputDir=$3
outputMetrics=$4

WORK_DIR=$(pwd)

pvpythonExtractScript=utils/extract.py
pythonPlotScript=utils/plot.py

#PARAVIEWPATH="/home/marmar/programs-local/ParaView-5.3.0-Qt5-OpenGL2-MPI-Linux-64bit/bin/"
#export PATH=$PATH:$PARAVIEWPATH

execDir=$(dirname "${ccxInputFile}")
ccxfilename=$(basename "$ccxInputFile")
ccxfileRootName="${ccxfilename%%.*}"

# Extract metrics from results file

resultsExoFile=$execDir/$ccxfileRootName.exo

xvfb-run -a --server-args="-screen 0 1024x768x24" $PARAVIEWPATH/pvpython --mesa-llvm  $pvpythonExtractScript  $resultsExoFile $desiredMetricsFile  $pvOutputDir $outputMetrics
