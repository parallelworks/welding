#!/bin/bash 
paraviewPythonScript=$1
resultsExoFile=$2
pngDir=$3
animFile=$4
pngName=temp.png

export PATH=$PATH:$PARAVIEWPATH

xvfb-run -a --server-args="-screen 0 1024x768x24" pvpython  $paraviewPythonScript  $resultsExoFile $pngDir $pngName

convert -delay 15 -loop 0  $pngDir/*.png $animFile
