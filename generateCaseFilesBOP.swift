import "stdlib.v2";

type file;

# ------ INPUT / OUTPUT DEFINITIONS -------#

string sweepParamsFileName  = arg("sweepParamFile", "sweepParams.run");
file fsweepParams		    <strcat("inputs/",sweepParamsFileName)>;

file utils[] 		        <filesys_mapper;location="utils", pattern="*.*">;
string outDir               = "outputs/";
file caseFile 	            <strcat(outDir,"cases.list")>;

# ------ APP DEFINITIONS --------------------#

# Read parameters from the sweepParams file and write to case files
app (file cases, file[] simFileParams) writeCaseParamFiles (file sweepParams, string simFilesDir, file[] utils) {
	python2 "utils/expandSweep.py" filename(sweepParams) filename(cases);
	python "utils/writeSimParamFiles.py" filename(cases) simFilesDir "caseParamFile";
}

#----------------workflow-------------------#

string simFilesDir = strcat(outDir, "simParamFiles/");
file[] simFileParams <filesys_mapper; location = simFilesDir>;
string simParamsFileName    = arg("simParamsFile", "boxSimFile");

(caseFile, simFileParams) = writeCaseParamFiles(fsweepParams, simFilesDir, utils );
