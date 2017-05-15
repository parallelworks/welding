# -*- coding: utf-8 -*-

import math

def distance3D(p0, p1):
    return math.sqrt((p0[0] - p1[0])**2 + (p0[1] - p1[1])**2 + (p0[2] - p1[2])**2)

###
### This file is generated automatically by SALOME v8.2.0 with dump python functionality
###

import sys
import salome

### needed if loading in salome GUI
sys.path.append('/home/marmar/scratch/parallelWorks/salome/box/data_IO.py')
import data_IO

# To calculate the cylinder height
import numpy 
from scipy.spatial.distance import pdist

inputFileName = "/home/marmar/scratch/parallelWorks/salome/box/inputs/simParams/boxSimFileCyl0.in"
meshFileName = "outputs/box_mesh.unv"

# Initialize solome
salome.salome_init()
theStudy = salome.myStudy

# Read parameters from input file

in_fp = data_IO.open_file(inputFileName)

Length = data_IO.read_float_from_file_pointer(in_fp, "Length")
Height = data_IO.read_float_from_file_pointer(in_fp, "Height")
Width = data_IO.read_float_from_file_pointer(in_fp, "Width")
cyl_p1x = data_IO.read_float_from_file_pointer(in_fp, "weld_x0")
cyl_p1y = data_IO.read_float_from_file_pointer(in_fp, "weld_y0")
cyl_p1z = data_IO.read_float_from_file_pointer(in_fp, "weld_z0")
cyl_p2x = data_IO.read_float_from_file_pointer(in_fp, "weld_x1")
cyl_p2y = data_IO.read_float_from_file_pointer(in_fp, "weld_y1")
cyl_p2z = data_IO.read_float_from_file_pointer(in_fp, "weld_z1")
highResWidth = data_IO.read_float_from_file_pointer(in_fp, "highResWidth")
meshScale = data_IO.read_float_from_file_pointer(in_fp, "meshScale")

in_fp.close()

###
### GEOM component
###

import GEOM
from salome.geom import geomBuilder
import math
import SALOMEDS

highResRad = highResWidth / 2.0
cyl_Height =  distance3D([cyl_p1x, cyl_p1y, cyl_p1z], [cyl_p2x, cyl_p2y, cyl_p2z])

geompy = geomBuilder.New(theStudy)

O = geompy.MakeVertex(0, 0, 0)
OX = geompy.MakeVectorDXDYDZ(1, 0, 0)
OY = geompy.MakeVectorDXDYDZ(0, 1, 0)
OZ = geompy.MakeVectorDXDYDZ(0, 0, 1)

Box_1 = geompy.MakeBoxDXDYDZ(Length, Width, Height)
Translation_1 = geompy.MakeTranslation(Box_1, -Length/2.0, -Width/2.0, -Height)
Vertex_1 = geompy.MakeVertex(cyl_p1x, cyl_p1y, cyl_p1z)
Vertex_2 = geompy.MakeVertex(cyl_p2x, cyl_p2y, cyl_p2z)
Vector_1 = geompy.MakeVector(Vertex_1, Vertex_2)
Vector_1_vertex_2 = geompy.GetSubShape(Vector_1, [2]) 
Cylinder_1 = geompy.MakeCylinder(Vector_1_vertex_2, Vector_1, highResRad, cyl_Height)

geompy.addToStudy( O, 'O' )
geompy.addToStudy( OX, 'OX' )
geompy.addToStudy( OY, 'OY' )
geompy.addToStudy( OZ, 'OZ' )
geompy.addToStudy( Box_1, 'Box_1' )
geompy.addToStudy( Translation_1, 'Translation_1' )
geompy.addToStudy( Vertex_2, 'Vertex_2' )
geompy.addToStudy( Vertex_1, 'Vertex_1' )
geompy.addToStudy( Vector_1, 'Vector_1' )
geompy.addToStudyInFather( Vector_1, Vector_1_vertex_2, 'Vector_1:vertex_2' )
geompy.addToStudy( Cylinder_1, 'Cylinder_1' )

###
### SMESH component
###

import  SMESH, SALOMEDS
from salome.smesh import smeshBuilder

smesh = smeshBuilder.New(theStudy)
Mesh_1 = smesh.Mesh(Translation_1)
NETGEN_2D3D = Mesh_1.Tetrahedron(algo=smeshBuilder.NETGEN_1D2D3D)
NETGEN_3D_Parameters_1 = NETGEN_2D3D.Parameters()
NETGEN_3D_Parameters_1.SetMaxSize( 1.28452 * meshScale)
NETGEN_3D_Parameters_1.SetSecondOrder( 0 )
NETGEN_3D_Parameters_1.SetOptimize( 1 )
NETGEN_3D_Parameters_1.SetFineness( 2 )
NETGEN_3D_Parameters_1.SetMinSize( 0.428174  * meshScale)
NETGEN_3D_Parameters_1.SetUseSurfaceCurvature( 1 )
NETGEN_3D_Parameters_1.SetFuseEdges( 1 )
NETGEN_3D_Parameters_1.SetQuadAllowed( 0 )
NETGEN_3D_Parameters_1.SetLocalSizeOnShape(Cylinder_1, 0.5  * meshScale)
isDone = Mesh_1.Compute()
try:
  Mesh_1.ExportUNV( r'/home/marmar/scratch/parallelWorks/salome/box/boxWCylMesh.unv' )
except:
  print 'ExportUNV() failed. Invalid file name?'


## Set names of Mesh objects
smesh.SetName(NETGEN_2D3D.GetAlgorithm(), 'NETGEN_2D3D')
smesh.SetName(NETGEN_3D_Parameters_1, 'NETGEN 3D Parameters_1')
smesh.SetName(Mesh_1.GetMesh(), 'Mesh_1')


if salome.sg.hasDesktop():
  salome.sg.updateObjBrowser(True)
