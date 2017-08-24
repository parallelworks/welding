import "stdlib.v2";

type file;

# ------ INPUT / OUTPUT DEFINITIONS -------#

string sweepParamsFileName  = arg("sweepParamFile", "sweepParams_fast.run");

file fsweepParams		    <strcat("inputs/",sweepParamsFileName)>;

file outhtml <arg("html","DE.html")>;
file outcsv <arg("csv","DE.csv")>;


# directory definitions
string outDir               = "outputs/";
string errorsDir            = strcat(outDir, "errorFiles/");
string logsDir              = strcat(outDir, "logFiles/");
string salPortsDir          = strcat(logsDir, "salPortNums/");
string simFilesDir          = strcat(outDir, "simParamFiles/");
#string meshFilesDir         = strcat(outDir, "meshFiles/case"); 
string meshFilesDir         = strcat(outDir, "case"); 
string pngOutDirRoot        = strcat(outDir,"png/");
string caseDirRoot          = strcat(outDir, "case"); 

string runPath = getEnv("PWD");

# Script files and utilities
file meshScript             <"utils/beadOnPlate_inputFile.py">;
file preFbdFile             <"utils/bead_pre.fbd">;
file getCcxInpScript        <"utils/writeCCXinpFile_beadOnPlate.py">;
file writeFortranFileScript <"utils/writeDFluxFile.py">;
file materialLibFile        <"inputs/materialLib.mat">;  # Also need to change the ccx input file changing the name
file metrics2extract        <"inputs/beadOnPlateKPI_short.json">;
file outputsList4DE         <"DEoutputParams.txt">;

file utils[] 		        <filesys_mapper;location="utils", pattern="?*.*">;
file mexdex[] 		        <filesys_mapper;location="mexdex", pattern="?*.*">;

# ------- Funciton definitions--------------#

(string nameNoSuffix) trimSuffix (string nameWithSuffix){
   int suffixStartLoc = lastIndexOf(nameWithSuffix, ".", -1);
   nameNoSuffix = substring(nameWithSuffix, 0, suffixStartLoc); 
}

# ------ APP DEFINITIONS --------------------#

app (file cases, file[] simFileParams, file so, file se) writeCaseParamFiles (file sweepParams, string simFilesDir, file[] mexdex, file[] utils) {
#	python2 "utils/expandSweep.py" filename(sweepParams) filename(cases);
    python2 "mexdex/prepinputs.py" "--SR_valueDelimiter" " " "--SR_paramsDelimiter" "\n" "--noParamTag" "--CL_paramValueDelimiter" "="  filename(sweepParams) filename(cases) stdout=filename(so) stderr=filename(se);
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
    bash "utils/compileCcx3.sh" filename(writeFortranFileScript) filename(fsimParams) caseDir;
}

app (file MetricsOutput, file[] fpngs, file fOut, file ferr, file fsol) 
                                            runSimExtractMetrics (file ccxBin, file fmsh4ccx,
                                                                  file fInp, file matLibFile, file metrics2extract,
                                                                  string extractOutDir, file utils[]){
    bashRunSim "utils/runSim.sh" filename(ccxBin)  filename(fInp) filename(matLibFile) 
                stderr=filename(ferr) stdout=filename(fOut);
    bashPVExtract  "utils/PVExtract.sh" filename(fInp) filename(metrics2extract) extractOutDir
         filename(MetricsOutput) stderr=filename(ferr) stdout=filename(fOut);
}

app (file outcsv, file outhtml, file so, file se) designExplorer (string runPath, file caselist, file metrics2extract, string pngOutDirRoot, string caseDirRoot, file[] MetricsFiles, file outputsList4DE, file mexdex[])
{
  bash "mexdex/addDesignExplorer.sh" filename(outcsv) filename(outhtml) runPath  filename(caselist) filename(metrics2extract) pngOutDirRoot caseDirRoot filename(outputsList4DE) stdout=filename(so) stderr=filename(se);
}

 
#----------------workflow-------------------#

# Read parameters from the sweepParams file and write to case files
file caseFile 	            <strcat(outDir,"cases.list")>;
file[] simFileParams        <filesys_mapper; location = simFilesDir>;
file prepCaseListOut       <strcat(logsDir, "prepCaseList.out")>; 
file prepCaseListErr       <strcat(errorsDir, "prepCaseList.err")>;

(caseFile, simFileParams, prepCaseListOut, prepCaseListErr) = writeCaseParamFiles(fsweepParams, simFilesDir, mexdex, utils);

