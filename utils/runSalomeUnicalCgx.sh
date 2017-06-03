#!/bin/bash 
caseindex=$1
portlogFile=$2
meshScript=$3
meshParamsFile=$4
allinoneFile=$5
prefbdFile=$6
fOut=$7
fErr=$8

export PATH=$PATH:$SALOMEPATH:$UNICALPATH:$CGXPATH

# Make sure the directories exist

WORK_DIR=$(pwd)
meshDir=$(dirname "${allinoneFile}")
mkdir -p $meshDir
errDir=$(dirname "${fErr}")
mkdir -p $errDir
fOutDir=$(dirname "${fOut}")
mkdir -p $fOutDir
salLogDir=$(dirname "${portlogFile}")
mkdir -p $salLogDir


# Generate the mesh.unv file using salome

unvMeshFile=$meshDir/mesh$caseindex.unv

printf 'Salome output\n------------\n' >> $fOut
printf 'Salome errors\n------------\n' >> $fErr
portlogFileAbsPath=${WORK_DIR}/$portlogFile 
salome start -t   --ns-port-log=$portlogFileAbsPath 1>>$fOut 2>>$fErr
salome shell -p `cat $portlogFileAbsPath`  $meshScript args:$meshParamsFile,$unvMeshFile 1>>$fOut 2>>$fErr


# Convert the mesh.unv file to mesh_OUT.inp file 

AbqMeshFile=$meshDir/mesh_OUT.inp # !!! Make sure the name matches the name of the file read in prefbdFile

printf '\nUnical output \n------------\n' >> $fOut
printf '\nUnical errors \n------------\n' >> $fErr
unical $unvMeshFile $AbqMeshFile 1>>$fOut 2>>$fErr


# Generate the files required by ccx from mesh_OUT.inp

printf '\ncgx output \n------------\n' >> $fOut
printf '\ncgx errors \n------------\n' >> $fErr
cp $prefbdFile $meshDir/
cd $meshDir/ 
prefbdFileName=$(basename $prefbdFile)
allinoneFileName=$(basename $allinoneFile)
cgx_2.12  -bg $prefbdFileName 1>>cgx.out 2>>cgx.err

# Combine all required mesh/abaqus files into a single file
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# Modify this line to make it read the list required files from an input file or solve.inp, to make it problem independent
printf '\ncat errors \n------------\n' >>cgx.err
cat all.msh bead_contSurf123.equ bead_contSurf.equ beadSolid.nam plateSolid.nam  > $allinoneFileName  2>>cgx.err
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
cd $WORK_DIR
cat $meshDir/cgx.out >> $fOut
cat $meshDir/cgx.err >> $fErr



