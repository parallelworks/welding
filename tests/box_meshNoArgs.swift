import "stdlib.v2";

type file;

# ------ INPUT / OUTPUT DEFINITIONS -------#

file fgeom <"inputs/box.step">;
file meshScript <"utils/boxMesh_noArgs.py">;
file fmesh <"outputs/box_mesh.unv">;


# -- APP DEFINITIONS

#app (file fmesh, file feff, file salemeLog) meshBox (file fgeom, file salomeScript) {
app (file fmesh) meshBox (file fgeom, file meshScript) {
	salome "start" "-t" "-w 1" filename(meshScript);
}

#----------------workflow---------#

fmesh = meshBox(fgeom, meshScript);

