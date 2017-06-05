#!/bin/bash 
resultsExoFile=$1
desiredMetricsFile=$2
pvOutputDir=$3
outputMetrics=$4

pvpythonExtractScript=utils/extract_Box_json.py
pythonPlotScript=utils/plot.py

export PATH=$PATH:$PARAVIEWPATH

xvfb-run -a --server-args="-screen 0 1024x768x24" pvpython  $pvpythonExtractScript  $resultsExoFile $desiredMetricsFile  $pvOutputDir $outputMetrics

#convert -delay 15 -loop 0  $pngDir/*.png $animFile

shopt -s nullglob # sets wildcard response to null
for f in ${pvOutputDir}plot_*.csv;do
    python $pythonPlotScript $f
done
