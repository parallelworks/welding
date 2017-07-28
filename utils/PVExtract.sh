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
resultsExoFile=$execDir/$ccxfileRootName.exo

# Extract metrics from results file

if [ "$embeddedDocker" = true ] ; then
    run_command="docker run --rm -i -v `pwd`:/scratch -w /scratch -u 0:0 marmarm/paraview:v5_4u_imgmagick /bin/bash"
    PARAVIEWPATH=""
else
    run_command="/bin/bash"
fi

echo "#!/bin/bash" > pvpythonRun.sh 
echo "xvfb-run -a --server-args=\"-screen 0 1024x768x24\" ${PARAVIEWPATH}pvpython --mesa-llvm $pvpythonExtractScript $resultsExoFile $desiredMetricsFile $pvOutputDir $outputMetrics" >> pvpythonRun.sh
chmod +x pvpythonRun.sh
$run_command pvpythonRun.sh
