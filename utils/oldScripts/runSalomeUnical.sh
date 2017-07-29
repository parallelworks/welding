#!/bin/bash 
caseindex=$1
portlogFile=$2
meshScript=$3
meshParamsFile=$4
AbqMeshFile=$5
fOut=$6
fErr=$7

SALOMEPATH="/home/marmar/programs-local/SALOME-8.2.0-UB14.04/"
UNICALPATH="/home/marmar/programs-local/CalculiXLauncher-03beta2-64bit-linux/bin/"


# make directories
WORK_DIR=$(pwd)
meshDir=$(dirname "${AbqMeshFile}")
mkdir -p $meshDir
errDir=$(dirname "${fErr}")
mkdir -p $errDir
fOutDir=$(dirname "${fOut}")
mkdir -p $fOutDir
salLogDir=$(dirname "${portlogFile}")
mkdir -p $salLogDir

unvMeshFile=$meshDir/mesh$caseindex.unv

export PATH=$PATH:$SALOMEPATH
export PATH=$PATH:$UNICALPATH

printf 'Salome output\n------------\n' >> $fOut
printf 'Salome errors\n------------\n' >> $fErr
portlogFileAbsPath=${WORK_DIR}/$portlogFile 
salome start -t   --ns-port-log=$portlogFileAbsPath 1>>$fOut 2>>$fErr
salome shell -p `cat $portlogFileAbsPath`  $meshScript args:$meshParamsFile,$unvMeshFile 1>>$fOut 2>>$fErr

printf '\nUnical output \n------------\n' >> $fOut
printf '\nUnical errors \n------------\n' >> $fErr
unical $unvMeshFile $AbqMeshFile 1>>$fOut 2>>$fErr

