import "stdlib.v2";

type file;

# ------ INPUT / OUTPUT DEFINITIONS -------#

string geomFileName = arg("geomFileName", "box.step");
string meshFileName = arg("meshFileName", "box_mesh.unv");

file fgeom <strcat("inputs/",geomFileName)>;
file fmesh <strcat("outputs/",meshFileName)>;
file meshScript <"utils/boxMesh_args.py">;

float Length  = parseFloat(arg("Length", "10.0"));
float Width  = parseFloat(arg("Width", "10.0"));
float Height  = parseFloat(arg("Height", "1.0"));
float meshScale  = parseFloat(arg("meshScale", "1.0"));
float highResWidth = parseFloat(arg("highResWidth","3.0"));


# -- APP DEFINITIONS

app (file fmesh) meshBox (file meshScript, float Length, float Width, float Height, float highResWidth, float meshScale, file fgeom) {
    # Example of running Python mesh script by Salome :
    # salome shell   boxMesh_args.py args:10,10,1,inputs/box.step,3,1,outputs/box_mesh.unv
	salome "start" "-t" "-w 1" filename(meshScript)  strcat("args:", Length, ",",
                                                                     Width, ",", 
                                                                     Height, ",", 
                                                                     filename(fgeom), ",",
                                                                     highResWidth, ",",
                                                                     meshScale, ",",
                                                                     filename(fmesh));
}

#----------------workflow---------#

fmesh = meshBox(meshScript, Length, Width, Height, highResWidth, meshScale, fgeom);
