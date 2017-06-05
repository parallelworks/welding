import "stdlib.v2";

type file;

# ------ INPUT / OUTPUT DEFINITIONS -------#

string sweepParamsFileName  = arg("sweepParamFile", "sweepParams.run");
string simParamsFileName    = arg("simParamsFile", "boxSimFile");

file fsweepParams		    <strcat("inputs/",sweepParamsFileName)>;

# directory definitions
string outDir               = "outputs/";
string errorsDir            = strcat(outDir, "errorFiles/");
string logsDir              = strcat(outDir, "logFiles/");
string salPortsDir          = strcat(logsDir, "salPortNums/");
string simFilesDir          = strcat(outDir, "simParamFiles/");
#string meshFilesDir         = strcat(outDir, "meshFiles/case"); 
string meshFilesDir         = strcat(outDir, "case"); 


# Script files and utilities
file meshScript             <"utils/beadOnPlate_inputFile.py">;
file preFbdFile             <"utils/bead_pre.fbd">;
file getCcxInpScript        <"utils/writeCCXinpFile_beadOnPlate.py">;
file writeFortranFileScript <"utils/writeDFluxFile.py">;
file materialLibFile        <"inputs/materialLib.mat">;  


file extractScript          <"utils/extract.sh">;
file metrics2extract        <"inputs/boxKPI.csv">;


file utils[] 		        <filesys_mapper;location="utils", pattern="*.*">;

# ------- Funciton definitions--------------#
(string nameNoSuffix) trimSuffix (string nameWithSuffix){
   int suffixStartLoc = lastIndexOf(nameWithSuffix, ".", -1);
   nameNoSuffix = substring(nameWithSuffix, 0, suffixStartLoc); 
}

# ------ APP DEFINITIONS --------------------#

# Read parameters from the sweepParams file and write to case files
app (file cases, file[] simFileParams) writeCaseParamFiles (file sweepParams, string simFilesDir, file[] utils) {
	python2 "utils/expandSweep.py" filename(sweepParams) filename(cases);
	python "utils/writeSimParamFiles.py" filename(cases) simFilesDir "caseParamFile";
}

app (file fmesh, file ferr, file fout, file salPort) makeMesh (file meshScript, int caseindex, file utils[], 
                                                               file fsimParams, file preFbdFile) {
    bash "utils/runSalomeUnicalCgx.sh" caseindex  filename(salPort) filename(meshScript) filename(fsimParams)
         filename(fmesh) filename(preFbdFile) filename(fout) filename(ferr);
}

app (file ferr, file fout) killSalomeInstance (file[] fmeshes, file salPort, file utils[]){
    bash "utils/killSalome.sh" filename(salPort)  stderr=filename(ferr) stdout=filename(fout); 
}

app (file fccxInp) getCcxInp (file getCcxInpScript, file fsimParams, file utils[]){
	python filename(getCcxInpScript) filename(fsimParams) filename(fccxInp);
}

app (file ccxBin, file dfluxfile) compileCcx (file writeFortranFileScript, file fsimParams, string caseDir, file utils[]){
    bash "utils/compileCcx3.sh" filename(writeFortranFileScript) filename(fsimParams) caseDir;
}

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

file caseFile 	            <strcat(outDir,"cases.list")>;
file[] simFileParams        <filesys_mapper; location = simFilesDir>;
(caseFile, simFileParams) = writeCaseParamFiles(fsweepParams, simFilesDir, utils);


file[] fmeshes;
file[] salPortFiles;
foreach fsimParams,i in simFileParams{
    file fsalPortLog   <strcat(salPortsDir, "salomePort", i, ".log")>;
    file meshErr       <strcat(errorsDir, "mesh", i, ".err")>;                          
    file meshOut       <strcat(logsDir, "mesh", i, ".out")>;                          
   	file fmesh  	   <strcat(meshFilesDir, i, "/allinone.inp")>;
    (fmesh, meshErr, meshOut, fsalPortLog) = makeMesh(meshScript, i, utils, fsimParams, preFbdFile);
    fmeshes[i] = fmesh;
    salPortFiles[i] = fsalPortLog;
}

# Terminate Salome instances after done with generating all mesh files
foreach fsalPort,i in salPortFiles{
    file salKillErr     <strcat(errorsDir, "salomeKill",i,".err")>;                          
    file salKillOut     <strcat(logsDir, "salomeKill",i,".out")>;                          
    (salKillErr, salKillOut) =  killSalomeInstance(fmeshes,  fsalPort, utils);
}

# Generate ccx input (.inp) files
file[] fCcxInpFiles;
string[] caseOutDirs;
foreach fsimParams,i in simFileParams{
	caseOutDirs[i]   = strcat(outDir, "case", i,"/");
	file finp        <strcat(caseOutDirs[i], "solve.inp")>;
	finp = getCcxInp(getCcxInpScript, fsimParams, utils);
	fCcxInpFiles[i] = finp;
}


# Write dflux.f files and use them to compile ccx files for each case
# Will most likely remove this part later ....
file[] ccxBinaries;
foreach fsimParams,i in simFileParams{
    file ccxBin               <strcat(caseOutDirs[i], "/ccx-212-patch/src/ccx_2.12")>;
    file dfluxfile            <strcat(caseOutDirs[i], "/dflux.f")>;
    (ccxBin, dfluxfile) = compileCcx(writeFortranFileScript, fsimParams, caseOutDirs[i], utils );
    ccxBinaries[i] = ccxBin;
}

# Run ccx for each case
file[] solFiles;
foreach ccxBin,i in ccxBinaries{
	file fsol         <strcat(trimSuffix(filename(fCcxInpFiles[i])),".exo")>;
	file fccxErr      <strcat(caseOutDirs[i], "ccx.err")>;
	file fccxOut      <strcat(caseOutDirs[i], "ccx.out")>;
    (fsol, fccxOut, fccxErr) = runCcx (ccxBin,  fmeshes[i], fCcxInpFiles[i], materialLibFile, utils);
	solFiles[i] = fsol;
}

# Extract metrics and png files using paraview

foreach fsol, i in solFiles{
	file MetricsOutput  <strcat(caseOutDirs[i], "metrics.csv")>;
	string extractOutDir = strcat(outDir,"png/",i,"/");
	file fextractPng[]	 <filesys_mapper;location=extractOutDir>;	
	file fextractOut       <strcat(caseOutDirs[i], "extract.out")>;
	file fextractErr       <strcat(caseOutDirs[i], "extract.err")>;
	(MetricsOutput, fextractPng, fextractOut, fextractErr) = extractMetrics (extractScript, fsol,
																			metrics2extract, extractOutDir, utils);
}

