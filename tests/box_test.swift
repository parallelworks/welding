import "stdlib.v2";

type file;

# ------ INPUT / OUTPUT DEFINITIONS -------#

string geomFileName = arg("geomFileName", "box.step");
string meshFileName = arg("meshFileName", "box_mesh.unv");
string geomMeshParamsFileName = arg("meshFileName", "geomMeshParams.in");

# file fgeom <strcat("inputs/",geomFileName)>;
# file fmesh <strcat("outputs/",meshFileName)>;
# file meshScript <"utils/boxMesh_inputFile_noArgs.py">;
# file fgeomMeshParams  <strcat("inputs/",geomMeshParamsFileName)>;


file fgeom <"inputs/box.step">;
file meshScript <"utils/boxMesh_inputFile_noArgs.py">;
file fmesh <"outputs/box_mesh.unv">;


# -- APP DEFINITIONS

app (file fmesh, file ferr) meshBox (file meshScript, file fgeom) {
    # Example of running Python mesh script by Salome :
    # salome start -t -w 1 boxMesh_inputFile.py args:inputs/geomMeshParams.in,inputs/box.step,outputs/box_mesh.unv 
    salome "start" "-t" "-w 1" filename(meshScript) stderr=filename(ferr);#  strcat("args:",gmFN, ",", filename(fgeom), ",", filename(fmesh));
}

#----------------workflow---------#

#trace(strcat("args:","inputs/geomMeshParams.in,",filename(fgeom),",", filename(fmesh)));

file salomeErr <"outputs/salome.err">;                        

(fmesh, salomeErr) = meshBox(meshScript, fgeom);
