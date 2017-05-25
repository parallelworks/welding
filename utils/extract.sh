#!/bin/bash 
paraviewPath=$1
resultsExoFile=$2
desiredMetricsFile=$3
pvOutputDir=$4
outputMetrics=$5

pvpythonExtractScript=utils/extractBox.py
pythonPlotScript=utils/plot.py

export PATH=$PATH:$paraviewPath

xvfb-run -a --server-args="-screen 0 1024x768x24" pvpython  $pvpythonExtractScript  $resultsExoFile $desiredMetricsFile  $pvOutputDir $outputMetrics

#convert -delay 15 -loop 0  $pngDir/*.png $animFile

shopt -s nullglob # sets wildcard response to null
for f in ${pvOutputDir}plot_*.csv;do
    python $pythonPlotScript $f
done
