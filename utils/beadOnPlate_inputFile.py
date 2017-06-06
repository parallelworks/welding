# -*- coding: utf-8 -*-
import sys
import salome
import os 

### needed if loading in salome GUI
sys.path.append(os.getcwd()+'/utils/')
import data_IO

# Input arguments: 

if len(sys.argv) < 2:
    print("Number of provided arguments: ", len(sys.argv) -1 )
    print( "Usage: python beadOnPlate.py <inputFile.in>")
    print( "       [<meshFileName=outputs/bead-on-plate.unv>")
    sys.exit()


inputFileName = sys.argv[1]

if len(sys.argv) > 2:
    meshFileName = sys.argv[2]
else:
    meshFileName = "outputs/box_mesh.unv"


in_fp = data_IO.open_file(inputFileName)

Length = data_IO.read_float_from_file_pointer(in_fp, "Length")
Height = data_IO.read_float_from_file_pointer(in_fp, "Height")
Width1 = data_IO.read_float_from_file_pointer(in_fp, "Width1")
Width2 = data_IO.read_float_from_file_pointer(in_fp, "Width2")
EllipseW = data_IO.read_float_from_file_pointer(in_fp, "EllipseW")
EllipseH = data_IO.read_float_from_file_pointer(in_fp, "EllipseH")
meshScale = data_IO.read_float_from_file_pointer(in_fp, "meshScale")
highResWidth = data_IO.read_float_from_file_pointer(in_fp, "highResWidth")
highResMeshScale = data_IO.read_float_from_file_pointer(in_fp, "highResMeshScale")



in_fp.close()

###
### This file is generated automatically by SALOME v8.2.0 with dump python functionality
###


salome.salome_init()
theStudy = salome.myStudy

###
### GEOM component
###

import GEOM
from salome.geom import geomBuilder
import math
import SALOMEDS

geompy = geomBuilder.New(theStudy)

O = geompy.MakeVertex(0, 0, 0)

OX = geompy.MakeVectorDXDYDZ(1, 0, 0)
OY = geompy.MakeVectorDXDYDZ(0, 1, 0)
OZ = geompy.MakeVectorDXDYDZ(0, 0, 1)

O_1 = geompy.MakeVertex(0, 0, 0)
OX_1 = geompy.MakeVectorDXDYDZ(1, 0, 0)
OY_1 = geompy.MakeVectorDXDYDZ(0, 1, 0)
OZ_1 = geompy.MakeVectorDXDYDZ(0, 0, 1)

LocalCS_1 = geompy.MakeMarker(0, -Length/2.0, 0, 1, 0, 0, 0, 0, 1)
geomObj_1 = geompy.MakeMarker(0, 0, 0, 1, 0, 0, 0, 1, 0)

sk = geompy.Sketcher2D()
sk.addPoint(-Width1, -Height)
sk.addSegmentAbsolute(-Width1, 0.0)
sk.addSegmentAbsolute(Width2, 0.0)
sk.addSegmentAbsolute(Width2, -Height)
sk.close()
Sketch_1 = sk.wire(LocalCS_1)

[Edge_1,Edge_2,Edge_3,Edge_4] = geompy.ExtractShapes(Sketch_1, geompy.ShapeType["EDGE"], True)

Vector_1 = geompy.MakeVectorDXDYDZ(0, 1, 0)
Vertex_1 = geompy.MakeVertex(0, -Length/2.0, 0)
Ellipse_1 = geompy.MakeEllipse(Vertex_1, Vector_1, EllipseW/2.0, EllipseH/2.0, Edge_3)

Cut_1 = geompy.MakeCutList(Ellipse_1, [Edge_3], True)
[Edge_5,Edge_6] = geompy.ExtractShapes(Cut_1, geompy.ShapeType["EDGE"], True)
Face_1 = geompy.MakeFaceWires([Edge_5, Edge_6], 1)
Face_2 = geompy.MakeFaceWires([Edge_1, Edge_2, Edge_3, Edge_4], 1)
Cut_2 = geompy.MakeCutList(Face_2, [Face_1], True)
plate = geompy.MakePrismVecH(Cut_2, Vector_1, Length)
bead = geompy.MakePrismVecH(Face_1, Vector_1, Length)
Compound_1 = geompy.MakeCompound([plate, bead])
[beadSolid,plateSolid] = geompy.ExtractShapes(Compound_1, geompy.ShapeType["SOLID"], True)

listSubShapeIDs = geompy.SubShapeAllIDs(Compound_1, geompy.ShapeType["VERTEX"])
listSubShapeIDs = geompy.SubShapeAllIDs(Compound_1, geompy.ShapeType["EDGE"])
listSubShapeIDs = geompy.SubShapeAllIDs(beadSolid, geompy.ShapeType["VERTEX"])
listSubShapeIDs = geompy.SubShapeAllIDs(beadSolid, geompy.ShapeType["FACE"])
listSubShapeIDs = geompy.SubShapeAllIDs(beadSolid, geompy.ShapeType["EDGE"])
listSubShapeIDs = geompy.SubShapeAllIDs(plateSolid, geompy.ShapeType["VERTEX"])
listSubShapeIDs = geompy.SubShapeAllIDs(plateSolid, geompy.ShapeType["FACE"])
listSubShapeIDs = geompy.SubShapeAllIDs(plateSolid, geompy.ShapeType["EDGE"])
listSubShapeIDs = geompy.SubShapeAllIDs(plateSolid, geompy.ShapeType["VERTEX"])

plt_contSurf = geompy.CreateGroup(plateSolid, geompy.ShapeType["FACE"])
geompy.UnionIDs(plt_contSurf, [27])
bead_contSurf = geompy.CreateGroup(beadSolid, geompy.ShapeType["FACE"])
geompy.UnionIDs(bead_contSurf, [3])
bead_outSurf = geompy.CreateGroup(beadSolid, geompy.ShapeType["FACE"])
geompy.UnionIDs(bead_outSurf, [13])
fixPointOnPlate = geompy.CreateGroup(plateSolid, geompy.ShapeType["VERTEX"])

# Add a larger bead for controling mesh size:
origin = geompy.MakeVertex(0, 0, 0)
highResRegion = geompy.MakeScaleAlongAxes(bead, origin, highResWidth, 1, highResWidth)


geompy.UnionIDs(fixPointOnPlate, [37])
geompy.addToStudy( O, 'O' )
geompy.addToStudy( OX, 'OX' )
geompy.addToStudy( OY, 'OY' )
geompy.addToStudy( OZ, 'OZ' )
geompy.addToStudy( O_1, 'O' )
geompy.addToStudy( OX_1, 'OX' )
geompy.addToStudy( OY_1, 'OY' )
geompy.addToStudy( OZ_1, 'OZ' )
geompy.addToStudy( LocalCS_1, 'LocalCS_1' )
geompy.addToStudy( Sketch_1, 'Sketch_1' )
geompy.addToStudyInFather( Sketch_1, Edge_1, 'Edge_1' )
geompy.addToStudyInFather( Sketch_1, Edge_2, 'Edge_2' )
geompy.addToStudyInFather( Sketch_1, Edge_3, 'Edge_3' )
geompy.addToStudyInFather( Sketch_1, Edge_4, 'Edge_4' )
geompy.addToStudy( Vector_1, 'Vector_1' )
geompy.addToStudy( Vertex_1, 'Vertex_1' )
geompy.addToStudy( Ellipse_1, 'Ellipse_1' )
geompy.addToStudy( Cut_1, 'Cut_1' )
geompy.addToStudyInFather( Cut_1, Edge_5, 'Edge_5' )
geompy.addToStudyInFather( Cut_1, Edge_6, 'Edge_6' )
geompy.addToStudy( Face_1, 'Face_1' )
geompy.addToStudy( Face_2, 'Face_2' )
geompy.addToStudy( Cut_2, 'Cut_2' )
geompy.addToStudy( plate, 'plate' )
geompy.addToStudy( bead, 'bead' )
geompy.addToStudy( Compound_1, 'Compound_1' )
geompy.addToStudyInFather( Compound_1, beadSolid, 'beadSolid' )
geompy.addToStudyInFather( Compound_1, plateSolid, 'plateSolid' )
geompy.addToStudyInFather( plateSolid, plt_contSurf, 'plt_contSurf' )
geompy.addToStudyInFather( beadSolid, bead_contSurf, 'bead_contSurf' )
geompy.addToStudyInFather( beadSolid, bead_outSurf, 'bead_outSurf' )
geompy.addToStudyInFather( plateSolid, fixPointOnPlate, 'fixPointOnPlate' )
geompy.addToStudy( origin, 'origin' )
geompy.addToStudy( highResRegion, 'highResRegion' )


###
### SMESH component
###

import  SMESH, SALOMEDS
from salome.smesh import smeshBuilder

smesh = smeshBuilder.New(theStudy)
Mesh_1 = smesh.Mesh(Compound_1)
NETGEN_2D3D = Mesh_1.Tetrahedron(algo=smeshBuilder.NETGEN_1D2D3D)
NETGEN_3D_Parameters_1 = NETGEN_2D3D.Parameters()
NETGEN_3D_Parameters_1.SetMaxSize( 1.2 * meshScale )
NETGEN_3D_Parameters_1.SetSecondOrder( 0 )
NETGEN_3D_Parameters_1.SetOptimize( 1 )
NETGEN_3D_Parameters_1.SetFineness( 2 )
NETGEN_3D_Parameters_1.SetMinSize( 0.1 * meshScale )
NETGEN_3D_Parameters_1.SetUseSurfaceCurvature( 0 )
NETGEN_3D_Parameters_1.SetFuseEdges( 1 )
NETGEN_3D_Parameters_1.SetQuadAllowed( 0 )
NETGEN_2D3D_1 = Mesh_1.Tetrahedron(algo=smeshBuilder.NETGEN_1D2D3D,geom=beadSolid)
NETGEN_3D_Parameters_2 = NETGEN_2D3D_1.Parameters()
NETGEN_3D_Parameters_2.SetMaxSize( 1.2  * meshScale )
NETGEN_3D_Parameters_2.SetSecondOrder( 0 )
NETGEN_3D_Parameters_2.SetOptimize( 1 )
NETGEN_3D_Parameters_2.SetFineness( 2 )
NETGEN_3D_Parameters_2.SetMinSize( 0.1  * meshScale )
NETGEN_3D_Parameters_2.SetUseSurfaceCurvature( 0 )
NETGEN_3D_Parameters_2.SetFuseEdges( 1 )
NETGEN_3D_Parameters_2.SetQuadAllowed( 0 )
NETGEN_3D_Parameters_2.SetLocalSizeOnShape(highResRegion, 1.0 * highResMeshScale)
NETGEN_2D3D_2 = Mesh_1.Tetrahedron(algo=smeshBuilder.NETGEN_1D2D3D,geom=plateSolid)
NETGEN_3D_Parameters_3 = NETGEN_2D3D_2.Parameters()
NETGEN_3D_Parameters_3.SetMaxSize( 1.2  * meshScale )
NETGEN_3D_Parameters_3.SetSecondOrder( 0 )
NETGEN_3D_Parameters_3.SetOptimize( 1 )
NETGEN_3D_Parameters_3.SetFineness( 2 )
NETGEN_3D_Parameters_3.SetMinSize( 0.1  * meshScale)
NETGEN_3D_Parameters_3.SetUseSurfaceCurvature( 0 )
NETGEN_3D_Parameters_3.SetFuseEdges( 1 )
NETGEN_3D_Parameters_3.SetQuadAllowed( 0 )
NETGEN_3D_Parameters_3.SetLocalSizeOnShape(highResRegion, 1.0 * highResMeshScale)
isDone = Mesh_1.Compute()
beadSolid_1 = Mesh_1.GroupOnGeom(beadSolid,'beadSolid',SMESH.VOLUME)
plateSolid_1 = Mesh_1.GroupOnGeom(plateSolid,'plateSolid',SMESH.VOLUME)
bead_contSurf_1 = Mesh_1.GroupOnGeom(bead_contSurf,'bead_contSurf',SMESH.NODE)
bead_outSurf_1 = Mesh_1.GroupOnGeom(bead_outSurf,'bead_outSurf',SMESH.NODE)
plt_contSurf_1 = Mesh_1.GroupOnGeom(plt_contSurf,'plt_contSurf',SMESH.NODE)
fixPointOnPlate_1 = Mesh_1.GroupOnGeom(fixPointOnPlate,'fixPointOnPlate',SMESH.NODE)
Sub_mesh_1 = NETGEN_2D3D_1.GetSubMesh()
Sub_mesh_2 = NETGEN_2D3D_2.GetSubMesh()


## Set names of Mesh objects
smesh.SetName(NETGEN_2D3D.GetAlgorithm(), 'NETGEN_2D3D')
smesh.SetName(NETGEN_3D_Parameters_2, 'NETGEN 3D Parameters_2')
smesh.SetName(NETGEN_3D_Parameters_3, 'NETGEN 3D Parameters_3')
smesh.SetName(NETGEN_3D_Parameters_1, 'NETGEN 3D Parameters_1')
smesh.SetName(Mesh_1.GetMesh(), 'Mesh_1')
smesh.SetName(plateSolid_1, 'plateSolid')
smesh.SetName(beadSolid_1, 'beadSolid')
smesh.SetName(Sub_mesh_2, 'Sub-mesh_2')
smesh.SetName(Sub_mesh_1, 'Sub-mesh_1')
smesh.SetName(bead_outSurf_1, 'bead_outSurf')
smesh.SetName(plt_contSurf_1, 'plt_contSurf')
smesh.SetName(bead_contSurf_1, 'bead_contSurf')
smesh.SetName(fixPointOnPlate_1, 'fixPointOnPlate')

try:
  if not os.path.exists(os.path.dirname(meshFileName)):
    os.makedirs(os.path.dirname(meshFileName))
  Mesh_1.ExportUNV( meshFileName)
except:
  print 'ExportUNV() failed. Invalid file name?', meshFileName


if salome.sg.hasDesktop():
  salome.sg.updateObjBrowser(True)
