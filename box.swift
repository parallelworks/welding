import "stdlib.v2";

type file;

# ------ INPUT / OUTPUT DEFINITIONS -------#

string geomFileName = arg("geomFile", "box.step");
string meshFileName = arg("meshFile", "box_mesh.unv");
string geomMeshParamsFileName = arg("geomMeshParamsFile", "geomMeshParams.in");

file fgeom <strcat("inputs/",geomFileName)>;
file fgeomMeshParams  <strcat("inputs/",geomMeshParamsFileName)>;

file meshScript <"utils/boxMesh_inputFile_noArgs.py">;
file pythonLib <"utils/data_IO.py">;  # Python functions for reading data from files

file fmesh <strcat("outputs/",meshFileName)>;
file salomeErr <"outputs/salome.err">;                        

# -- APP DEFINITIONS

app (file fmesh, file ferr) meshBox (file meshScript, file fgeom, file pythonLib, file fgeomMeshParams ) {
    # Example of running Python mesh script by Salome :
    # salome start -t -w 1 boxMesh_inputFile.py args:inputs/geomMeshParams.in,inputs/box.step,outputs/box_mesh.unv 
    salome "start" "-t" "-w 1" filename(meshScript) stderr=filename(ferr) 
                               strcat("args:",filename(fgeomMeshParams), ",", filename(fgeom), ",", filename(fmesh));
}

#----------------workflow---------#



(fmesh, salomeErr) = meshBox(meshScript, fgeom, pythonLib, fgeomMeshParams );
