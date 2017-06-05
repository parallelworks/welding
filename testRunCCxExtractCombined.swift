import "stdlib.v2";

type file;

# ------ INPUT / OUTPUT DEFINITIONS -------#

# string paraviewPath         = arg("pvpythonPath",
#                                   "/home/marmar/programs-local/ParaView-5.3.0-Qt5-OpenGL2-MPI-Linux-64bit/bin/");

file utils[] 		        <filesys_mapper;location="utils", pattern="*.*">;

string outDir              = "outputs/";
string errorsDir            = strcat(outDir, "errorFiles/");
string logsDir              = strcat(outDir, "logFiles/");


file runExtractScript          <"utils/runSimPVExtract.sh">;
file metrics2extract        <"inputs/beadOnPlateKPI_short.json">;

file materialLibFile        <"inputs/materialLib.mat">;  
file fmesh  	   <strcat(meshFilesDir, i, "/allinone.inp")>;


# ------- Funciton definitions--------------#
(string nameNoSuffix) trimSuffix (string nameWithSuffix){
   int suffixStartLoc = lastIndexOf(nameWithSuffix, ".", -1);
   nameNoSuffix = substring(nameWithSuffix, 0, suffixStartLoc); 
}

# ------ APP DEFINITIONS --------------------#


app (file MetricsOutput, file[] fpngs, file fOut, file ferr) runSimExtractMetrics (file ccxBin, file fmsh4ccx,
                                                                  file fInp, file matLibFile,
																  file metrics2extract, string extractOutDir,
															      file utils[]){
    bash "utils/runSimPVExtract.sh" filename(ccxBin)  filename(fInp) filename(metrics2extract) extractOutDir
         filename(MetricsOutput) filename(matLibFile) stderr=filename(ferr) stdout=filename(fOut);
}

#----------------workflow-------------------#

# Extract metrics and png files using paraview

int i=0;
string[] caseOutDirs;
caseOutDirs[i] = strcat(outDir, "case", i,"/");
string caseName = strcat(caseOutDirs[i], "solve");

file[] fCcxInpFiles;
file finp        <strcat(caseOutDirs[i], "solve.inp")>;
fCcxInpFiles[i] = finp;



string meshFilesDir         = strcat(outDir, "case"); 
file[] fmeshes;

fmeshes[i] = fmesh;

# Run ccx for each case

# file[] solFiles;
# foreach ccxBin,i in ccxBinaries{

    file ccxBin               <strcat(caseOutDirs[i], "/ccx-212-patch/src/ccx_2.12")>;
	file MetricsOutput  <strcat(caseOutDirs[i], "metrics.csv")>;
	string extractOutDir = strcat(outDir,"png/",i,"/");
	file fextractPng[]	 <filesys_mapper;location=extractOutDir>;	
	file fRunOut       <strcat(logsDir, "extractRun", i, ".out")>;
	file fRunErr       <strcat(errorsDir, "extractRun", i ,".err")>;
    (MetricsOutput, fextractPng, fRunOut, fRunErr) = runSimExtractMetrics(ccxBin, fmeshes[i], fCcxInpFiles[i],
                                                                          materialLibFile, metrics2extract,
                                                                          extractOutDir, utils);

