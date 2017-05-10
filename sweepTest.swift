import "stdlib.v2";

type file;

# ------ INPUT / OUTPUT DEFINITIONS -------#

string geomFileName = arg("geomFile", "box.step");
string meshFileName = arg("meshFile", "box_mesh.unv");
string geomMeshParamsFileName = arg("geomMeshParamsFile", "geomMeshParams.in");

file fgeom        <strcat("inputs/",geomFileName)>;
file fsimParams   <strcat("inputs/",geomMeshParamsFileName)>;
file fsweepParams		  <"inputs/sweepParams.run">;

file meshScript <"utils/boxMesh_inputFile.py">;
file utils[] 		<filesys_mapper;location="utils">;

file fmesh <strcat("outputs/",meshFileName)>;
file salomeErr <"outputs/salome.err">;                        

# ------ APP DEFINITIONS --------------------#

app (file cases) expandSweep (file sweepParams, file[] utils) {
	python2 "utils/expandSweep.py" filename(sweepParams) filename(cases);
}

app (file[] simFileParams) writeSimParamFiles (file cases, file[] utils, string simFilesDir, string simFileRootName) {
	python "utils/writeSimParamFiles.py" filename(cases) simFilesDir simFileRootName ;
}

# Generate mesh by running a Salome Python script
# Example of running Python mesh script by Salome :
#    salome start -t -w 1 boxMesh_inputFile.py args:inputs/geomMeshParams.in,inputs/box.step,outputs/box_mesh.unv 
app (file fmesh, file ferr) makeMesh (file meshScript, file fgeom, file utils[], file fsimParams ) {
    salome "start" "-t" "-w 1" filename(meshScript) stderr=filename(ferr) strcat("args:",
                                                                                 filename(fsimParams), ",", 
                                                                                 filename(fgeom), ",", 
                                                                                 filename(fmesh));
}

#----------------workflow---------#

file caseFile 	<"inputs/cases.list">;
caseFile = expandSweep(fsweepParams, utils);

string simFilesDir = "inputs/simFiles/";
file[] simFileParams <filesys_mapper;location=simFilesDir>;
simFileParams = writeSimParamFiles(caseFile, utils, simFilesDir, "simFiles");


