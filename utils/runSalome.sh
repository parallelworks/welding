#!/bin/bash 
caseindex=$1
meshScript=$2
meshParamsFile=$3
allinoneFile=$4
fOut=$5
fErr=$6


if [ "$embeddedDocker" = true ] ; then
    run_command="docker run --rm  -i -v `pwd`:/scratch -w /scratch -u 0:0 marmarm/salome:v8_2u /bin/bash"
    SALOMEPATH=""
else
    run_command="/bin/bash"
fi

# Make sure the directories exist
WORK_DIR=$(pwd)
meshDir=$(dirname "${allinoneFile}")
mkdir -p $meshDir
errDir=$(dirname "${fErr}")
mkdir -p $errDir
fOutDir=$(dirname "${fOut}")
mkdir -p $fOutDir

# Generate the mesh.unv file using salome

unvMeshFile=$meshDir/mesh$caseindex.unv

printf 'Salome output\n------------\n' > $fOut
printf 'Salome errors\n------------\n' > $fErr

####### !!! copy the required files for Salome to make them accessible in docker (?)
cp $meshScript meshScript_localCopy.py
meshScript=meshScript_localCopy.py
cp utils/data_IO.py . 

cp $meshParamsFile meshParamsFile_localCopy
meshParamsFile=meshParamsFile_localCopy
####### !!!

echo ${SALOMEPATH}salome start -t -w 1 $meshScript args:$meshParamsFile,$unvMeshFile    > makeMeshRun.sh

echo $run_command >>$fOut
echo $embeddedDocker >>$fOut
cat makeMeshRun.sh >>$fOut

printf '\n------------\n' >> $fOut

chmod +x makeMeshRun.sh

$run_command makeMeshRun.sh 1>>$fOut 2>>$fErr 

