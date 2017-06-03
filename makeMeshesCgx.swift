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
string meshFilesDir         = strcat(outDir, "meshFiles/case"); 


# Script files and utilities
file meshScript             <"utils/beadOnPlate_inputFile.py">;
file preFbdFile             <"utils/bead_pre.fbd">;
file utils[] 		        <filesys_mapper;location="utils", pattern="*.*">;

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


#----------------workflow-------------------#

file caseFile 	            <strcat(outDir,"cases.list")>;
file[] simFileParams        <filesys_mapper; location = simFilesDir>;
(caseFile, simFileParams) = writeCaseParamFiles(fsweepParams, simFilesDir, utils);


file[] fmeshes;
file[] salPortFiles;#         <filesys_mapper; location = salPortsDir, pattern="*.log" >;

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
