#!/bin/bash 
dirName=$1
export PATH=$PATH:$salomePath
mkdir -p $dirName
echo $PATH> $dirName/test.txt 
echo $SALOMEPATH>> $dirName/test.txt  
echo $PARAVIEWPATH>> $dirName/test.txt  
