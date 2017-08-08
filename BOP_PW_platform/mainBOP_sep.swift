import "stdlib.v2";

type file;

# ------ INPUT / OUTPUT DEFINITIONS -------#

#string sweepParamsFileName  = arg("sweepParamFile", "sweepParams_fast.run");

file fsweepParams		    <arg("sweepParamFile")>;
file outputs                <filesys_mapper;location="outputs">;


# directory definitions
string outDir               = "outputs/";
string errorsDir            = strcat(outDir, "errorFiles/");
string pngDir               = strcat("outputs/png");
string logsDir              = strcat(outDir, "logFiles/");
string salPortsDir          = strcat(logsDir, "salPortNums/");
string simFilesDir          = strcat(outDir, "simParamFiles/");
#string meshFilesDir         = strcat(outDir, "meshFiles/case"); 
string meshFilesDir         = strcat(outDir, "case"); 
string outputDirName        ="outputs";

# Script files and utilities
file meshScript             <"utils/beadOnPlate_inputFile.py">;
file preFbdFile             <"utils/bead_pre.fbd">;
file getCcxInpScript        <"utils/writeCCXinpFile_beadOnPlate.py">;
file writeFortranFileScript <"utils/writeDFluxFile.py">;
file materialLibFile        <arg("materialLibFile","inputs/materialLib.mat")>;  # Also need to change the ccx input file changing the name
file metrics2extract        <arg("desiredMetrics","inputs/beadOnPlateKPI_short.json")>;
file tarOutput              <arg("tarOutput","outputs.tgz")>;

file utils[] 		        <filesys_mapper;location="utils", pattern="?*.*">;

# ------- Funciton definitions--------------#

(string nameNoSuffix) trimSuffix (string nameWithSuffix){
   int suffixStartLoc = lastIndexOf(nameWithSuffix, ".", -1);
   nameNoSuffix = substring(nameWithSuffix, 0, suffixStartLoc); 
}

# ------ APP DEFINITIONS --------------------#

app (file cases, file[] simFileParams) writeCaseParamFiles (file sweepParams, string simFilesDir, file[] utils) {
	python2 "utils/expandSweep.py" filename(sweepParams) filename(cases);
	python "utils/writeSimParamFiles.py" filename(cases) simFilesDir "caseParamFile";
}

app (file fmesh, file ferr, file fout) makeMesh (file meshScript, int caseindex, file utils[], 
                                                               file fsimParams, file preFbdFile) {
    bashSalome "utils/runSalome.sh" caseindex  filename(meshScript) filename(fsimParams)
         filename(fmesh) filename(fout) filename(ferr);
    bashCGX "utils/runUnicalCgx.sh" caseindex filename(fmesh) filename(preFbdFile) filename(fout) filename(ferr);
}

app (file fccxInp) getCcxInp (file getCcxInpScript, file fsimParams, file utils[]){
	python filename(getCcxInpScript) filename(fsimParams) filename(fccxInp);
}

app (file ccxBin, file dfluxfile) compileCcx (file writeFortranFileScript, file fsimParams, string caseDir, file utils[]){
    bashCompile "utils/compileCcx3.sh" filename(writeFortranFileScript) filename(fsimParams) caseDir;
}

app (file MetricsOutput, file[] fextractPng, file fOut, file ferr, file fsol) 
                                            runSimExtractMetrics (file ccxBin, file fmsh4ccx,
                                                                  file fInp, file matLibFile, file metrics2extract,
                                                                  string extractOutDir, file utils[]){
    bashRunSim "utils/runSim.sh" filename(ccxBin)  filename(fInp) filename(matLibFile) 
                stderr=filename(ferr) stdout=filename(fOut);
    bashPVExtract  "utils/PVExtract.sh" filename(fInp) filename(metrics2extract) extractOutDir
         filename(MetricsOutput);
}
 
app (file tarOutput) postProcess (string outputDirName, file[] utils, file[] isReady, file[] souts, file[] serrs, file[] metrics, file[] pngs) {
    bash  "utils/postProcess.sh"  outputDirName filename(tarOutput);
}

app (file tarOutput) postProcess2 (file[] outputDirName, file[] utils) {
    bash  "utils/tarCompress.sh"  filename(outputDirName) filename(tarOutput);
}


#----------------workflow-------------------#

# Read parameters from the sweepParams file and write to case files
file caseFile 	            <strcat(outDir,"cases.list")>;
file[] simFileParams        <filesys_mapper; location = simFilesDir>;
(caseFile, simFileParams) = writeCaseParamFiles(fsweepParams, simFilesDir, utils);


file[] fmeshes;
foreach fsimParams,i in simFileParams{
    file meshErr       <strcat(errorsDir, "mesh", i, ".err")>;                          
    file meshOut       <strcat(logsDir, "mesh", i, ".out")>;                          
   	file fmesh  	   <strcat(meshFilesDir, i, "/allinone.inp")>;
    (fmesh, meshErr, meshOut) = makeMesh(meshScript, i, utils, fsimParams, preFbdFile);
    fmeshes[i] = fmesh;
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

# Run ccx and extract metrics for each case
# Completed taks
file[] isReady;
file[] souts;
file[] serrs;
file[] metrics;
file[] pngs;
foreach ccxBin,i in ccxBinaries{
    file MetricsOutput   <strcat(caseOutDirs[i], "metrics.csv")>;
    string extractOutDir = strcat("pngs",i,"/");
    file tar_pngs        <strcat(meshFilesDir,i,"/pngs.tgz")>;
    file fextractPng[]	 <filesys_mapper;location=extractOutDir>;	
    file fRunOut         <strcat(logsDir, "extractRun", i, ".out")>;
    file fRunErr         <strcat(errorsDir, "extractRun", i ,".err")>;
    file fsol            <strcat(trimSuffix(filename(fCcxInpFiles[i])),".exo")>;

    (MetricsOutput, fextractPng, fRunOut, fRunErr, fsol) = runSimExtractMetrics(ccxBin, fmeshes[i], fCcxInpFiles[i],
                                                                          materialLibFile, metrics2extract,
                                                                          extractOutDir, utils);
    tar_pngs=postProcess2(fextractPng,utils);
    pngs[i]=tar_pngs;
    isReady[i]=fsol;
    souts[i]=fRunOut;
    serrs[i]=fRunErr;
    metrics[i]=MetricsOutput;
}  
tarOutput=postProcess(outputDirName,utils,isReady,souts,serrs,metrics,pngs);
