#!/bin/bash

outcsv=$1
outhtml=$2
rpath=$3

caseslistFile=$4
metrics_json=$5
pngOutDirRoot=$6
caseDirRoot=$7
outputsList4DE=$8

colorby="sliceNT"

echo $@

basedir="$(echo /download$rpath | sed "s|/efs/job_working_directory||g" )"
DEbase="/preview"  

# Works with both python2 and python3 
python utils/writeDesignExplorerCsv.py $caseslistFile $metrics_json $basedir output.csv $pngOutDirRoot $caseDirRoot $outputsList4DE
mv output.csv $outcsv

baseurl="$DEbase/DesignExplorer/index.html?datafile=$basedir/$outcsv&colorby=$colorby"
echo '<html style="overflow-y:hidden;background:white"><a style="font-family:sans-serif;z-index:1000;position:absolute;top:15px;right:0px;margin-right:20px;font-style:italic;font-size:10px" href="'$baseurl'" target="_blank">Open in New Window</a><iframe width="100%" height="100%" src="'$baseurl'" frameborder="0"></iframe></html>' > $outhtml
