#!/bin/bash 
caseindex=$1
allinoneFile=$2
prefbdFile=$3
fOut=$4
fErr=$5


if [ "$embeddedDocker" = true ] ; then
    run_command="docker run --rm -i -v `pwd`:/scratch -w /scratch -u 0:0 avidalto/calculix:v11" 
else
	run_command=""
fi


# Make sure the directories exist

WORK_DIR=$(pwd)
meshDir=$(dirname "${allinoneFile}")
mkdir -p $meshDir
errDir=$(dirname "${fErr}")
mkdir -p $errDir
fOutDir=$(dirname "${fOut}")
mkdir -p $fOutDir

# The mesh.unv file generated using salome

unvMeshFile=$meshDir/mesh$caseindex.unv

# Convert the mesh.unv file to mesh_OUT.inp file 

AbqMeshFile=$meshDir/mesh_OUT.inp # !!! Make sure the name matches the name of the file read in prefbdFile

printf '\nUnical output \n------------\n' >> $fOut
printf '\nUnical errors \n------------\n' >> $fErr

echo "run_command: "  $run_command >> $fOut
$run_command ${UNICALPATH}unical $unvMeshFile $AbqMeshFile 1>>$fOut 2>>$fErr

# Generate the files required by ccx from mesh_OUT.inp
printf '\ncgx output \n------------\n' >> $fOut
printf '\ncgx errors \n------------\n' >> $fErr
cp $prefbdFile $meshDir/
cd $meshDir/ 
prefbdFileName=$(basename $prefbdFile)
allinoneFileName=$(basename $allinoneFile)

if [ "$embeddedDocker" = true ] ; then
    run_command="docker run --rm -i -v `pwd`:/scratch -w /scratch -u 0:0 avidalto/calculix:v11" 
else
	run_command=""
fi

$run_command   ${CGXPATH}cgx_2.12 -bg $prefbdFileName 1>>cgx.out 2>>cgx.err

# Combine all required mesh/abaqus files into a single file
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# Modify this line to make it read the list required files from an input file or solve.inp, to make it problem independent
printf '\ncat errors \n------------\n' >>cgx.err
cat all.msh bead_contSurf123.equ bead_contSurf.equ beadSolid.nam plateSolid.nam  > $allinoneFileName  2>>cgx.err
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
cd $WORK_DIR
cat $meshDir/cgx.out >> $fOut
cat $meshDir/cgx.err >> $fErr



