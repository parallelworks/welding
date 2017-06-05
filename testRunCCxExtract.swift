import "stdlib.v2";

type file;

# ------ INPUT / OUTPUT DEFINITIONS -------#

# string paraviewPath         = arg("pvpythonPath",
#                                   "/home/marmar/programs-local/ParaView-5.3.0-Qt5-OpenGL2-MPI-Linux-64bit/bin/");

file utils[] 		        <filesys_mapper;location="utils", pattern="*.*">;

string outDir              = "outputs/"; 


file extractScript          <"utils/extract.sh">;
file metrics2extract        <"inputs/beadOnPlateKPI_short.json">;

file materialLibFile        <"inputs/materialLib.mat">;  
file fmesh  	   <strcat(meshFilesDir, i, "/allinone.inp")>;


# ------- Funciton definitions--------------#
(string nameNoSuffix) trimSuffix (string nameWithSuffix){
   int suffixStartLoc = lastIndexOf(nameWithSuffix, ".", -1);
   nameNoSuffix = substring(nameWithSuffix, 0, suffixStartLoc); 
}

# ------ APP DEFINITIONS --------------------#


app (file fsol, file fOut, file ferr) runCcx (file ccxBin, file fmsh4ccx, file fInp, file matLibFile, file utils[]){
	bash "utils/runCcx2PVBinary.sh" filename(ccxBin)  filename(fInp) filename(matLibFile) stderr=filename(ferr)
          stdout=filename(fOut);
}

app (file MetricsOutput, file[] fpngs, file fOut, file ferr) extractMetrics (file extractScript, file fsol,
																  file metrics2extract, string extractOutDir,
															      file utils[]){
    bash filename(extractScript) filename(fsol) filename(metrics2extract) extractOutDir
         filename(MetricsOutput) stderr=filename(ferr) stdout=filename(fOut);
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
	file fsol         <strcat(trimSuffix(filename(fCcxInpFiles[i])),".exo")>;
	file fccxErr      <strcat(caseOutDirs[i], "ccx.err")>;
	file fccxOut      <strcat(caseOutDirs[i], "ccx.out")>;
    (fsol, fccxOut, fccxErr) = runCcx (ccxBin,  fmeshes[i], fCcxInpFiles[i], materialLibFile, utils);
# }

#foreach fsol, i in solFiles{
	file MetricsOutput  <strcat(caseOutDirs[i], "metrics.csv")>;
	string extractOutDir = strcat(outDir,"png/",i,"/");
	file fextractPng[]	 <filesys_mapper;location=extractOutDir>;	
	file fextractOut       <strcat(caseOutDirs[i], "extract.out")>;
	file fextractErr       <strcat(caseOutDirs[i], "extract.err")>;
	(MetricsOutput, fextractPng, fextractOut, fextractErr) = extractMetrics (extractScript, fsol,
																			metrics2extract, extractOutDir, utils);
 # (MetricsOutput, fextractPng) =  extractMetricsTest (extractScript,  paraviewPath, fsol,
 # 									metrics2extract, extractOutDir, utils);
