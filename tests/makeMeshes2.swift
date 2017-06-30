import "stdlib.v2";

type file;

# ------ INPUT / OUTPUT DEFINITIONS -------#

string sweepParamsFileName  = arg("sweepParamFile", "sweepParams.run");
string meshFileName         = arg("meshFile", "bead_on_plate");
string simParamsFileName    = arg("simParamsFile", "boxSimFile");

file fsweepParams		    <strcat("inputs/",sweepParamsFileName)>;

# directory definitions
string outDir               = "outputs/";
string errorsDir           = strcat(outDir, "errorFiles/");
string logsDir           = strcat(outDir, "logFiles/");
string simFilesDir = strcat(outDir, "simParamFiles/");
string meshFilesDir = strcat(outDir, "meshFiles/"); 


# Script files and utilities
file meshScript             <"utils/beadOnPlate_inputFile.py">;
file utils[] 		        <filesys_mapper;location="utils", pattern="*.*">;

# ------ APP DEFINITIONS --------------------#

# Read parameters from the sweepParams file and write to case files
app (file cases, file[] simFileParams) writeCaseParamFiles (file sweepParams, string simFilesDir, file[] utils) {
	python2 "utils/expandSweep.py" filename(sweepParams) filename(cases);
	python "utils/writeSimParamFiles.py" filename(cases) simFilesDir "caseParamFile";
}

app (file fmesh, file ferr, file fout, file salPort) makeMeshWritePort (file meshScript, file utils[], 
                                                                        file fsimParams) {
    bash "utils/runSalome.sh" filename(salPort) filename(meshScript) filename(fsimParams)
         filename(fmesh) stderr=filename(ferr) stdout=filename(fout);
}

app (file ferr, file fout) killSalomeInstance (file[] fmeshes, file salPort, file utils[]){
    bash "utils/killSalome.sh" filename(salPort)  stderr=filename(ferr) stdout=filename(fout); 
}


#----------------workflow-------------------#

file caseFile 	            <strcat(outDir,"cases.list")>;
file[] simFileParams <filesys_mapper; location = simFilesDir>;
(caseFile, simFileParams) = writeCaseParamFiles(fsweepParams, simFilesDir, utils);


file[] fmeshes;
file[] salPortFiles;
foreach fsimParams,i in simFileParams{
   	file fmesh  	   <strcat(meshFilesDir, meshFileName,i,".unv")>;
    file salomeErr     <strcat(errorsDir, "salome",i,".err")>;                          
    file salomeOut     <strcat(logsDir, "salome",i,".out")>;                          
    file fsalPortNum   <strcat(logsDir,"salomePort" ,i,".log")>;
    (fmesh, salomeErr, salomeOut, fsalPortNum) = makeMeshWritePort(meshScript, utils, fsimParams);
    fmeshes[i] = fmesh;
    salPortFiles[i] = fsalPortNum;
}

# Terminate Salome instances after done with generating all mesh files
foreach fsalPort,i in salPortFiles{
    file salKillErr     <strcat(errorsDir, "salomeKill",i,".err")>;                          
    file salKillOut     <strcat(logsDir, "salomeKill",i,".out")>;                          
    (salKillErr, salKillOut) =  killSalomeInstance(fmeshes,  fsalPort, utils);
}
