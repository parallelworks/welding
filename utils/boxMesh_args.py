# -*- coding: utf-8 -*-

###
### This file is generated automatically by SALOME v8.2.0 with dump python functionality
###

import sys
import salome

# Input arguments: 

if len(sys.argv) < 5:
    print("Number of provided arguments: ", len(sys.argv) -1 )
    print( "Usage: python boxMesh <Length> <Width> <Height> <geomFile.step>")
    print( "       [<HighResRegionWidth=Width/3> <meshScale=1>  <meshFileName=box_mesh.unv>")
    sys.exit()

Length = float(sys.argv[1])
Height = float(sys.argv[2])
Width = float(sys.argv[3])
geomFileAddress = sys.argv[4]

if len(sys.argv) >= 6:
    highResWidth = float(sys.argv[5])
else:
    highResWidth = Width/3

if len(sys.argv) >= 7:
    meshScale = float(sys.argv[6])
else:
    meshScale = 1.

if len(sys.argv) >= 8:
    meshFileName = float(sys.argv[7])
else:
    meshFileName = "box_mesh.unv"

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

# Import the geometry

Part_1 = geompy.ImportSTEP(geomFileAddress, False, True)

# Add a box to define the high resolution mesh region

Box_1 = geompy.MakeBoxDXDYDZ(Length, highResWidth, Height)
geompy.TranslateDXDYDZ(Box_1, -Length/2, -highResWidth/2, -Height)


geompy.addToStudy( O, 'O' )
geompy.addToStudy( OX, 'OX' )
geompy.addToStudy( OY, 'OY' )
geompy.addToStudy( OZ, 'OZ' )
geompy.addToStudy( Part_1, 'Part 1' )
geompy.addToStudy( Box_1, 'Box_1' )

###
### SMESH component
###

import  SMESH, SALOMEDS
from salome.smesh import smeshBuilder

smesh = smeshBuilder.New(theStudy)
Mesh_1 = smesh.Mesh(Part_1)
NETGEN_2D3D = Mesh_1.Tetrahedron(algo=smeshBuilder.NETGEN_1D2D3D)
NETGEN_3D_Parameters_1 = NETGEN_2D3D.Parameters()
NETGEN_3D_Parameters_1.SetMaxSize( 1*meshScale )
NETGEN_3D_Parameters_1.SetSecondOrder( 0 )
NETGEN_3D_Parameters_1.SetOptimize( 1 )
NETGEN_3D_Parameters_1.SetFineness( 2 )
NETGEN_3D_Parameters_1.SetMinSize( 0.472582 * meshScale )
NETGEN_3D_Parameters_1.SetUseSurfaceCurvature( 1 )
NETGEN_3D_Parameters_1.SetFuseEdges( 1 )
NETGEN_3D_Parameters_1.SetQuadAllowed( 0 )
NETGEN_3D_Parameters_1.SetLocalSizeOnShape(Box_1, 0.5 * meshScale)
isDone = Mesh_1.Compute()

try:
  Mesh_1.ExportUNV( meshFileName)
except:
  print 'ExportUNV() failed. Invalid file name?'


## Set names of Mesh objects
smesh.SetName(NETGEN_2D3D.GetAlgorithm(), 'NETGEN_2D3D')
smesh.SetName(Mesh_1.GetMesh(), 'Mesh_1')
smesh.SetName(NETGEN_3D_Parameters_1, 'NETGEN 3D Parameters_1')


if salome.sg.hasDesktop():
  salome.sg.updateObjBrowser(True)
