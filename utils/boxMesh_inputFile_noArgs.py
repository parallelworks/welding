# -*- coding: utf-8 -*-

###
### This file is generated automatically by SALOME v8.2.0 with dump python functionality
###

import sys
import salome
import data_IO

# Input arguments: 

# if len(sys.argv) < 3:
#     print("Number of provided arguments: ", len(sys.argv) -1 )
#     print( "Usage: python boxMesh <inputFile.in> <geomFile.step>")
#     print( "       [<meshFileName=box_mesh.unv>")
#     sys.exit()


inputFileName = "/home/marmar/Dropbox/parallelWorks/weldingProject/boxGeom/inputs/geomMeshParams.in"
geomFileAddress = "inputs/box.step"
meshFileName = "outputs/box_mesh.unv"

# Read parameters from input file

in_fp = data_IO.open_file(inputFileName)
Length = data_IO.read_float_from_file_pointer(in_fp, "Length")
Height = data_IO.read_float_from_file_pointer(in_fp, "Height")
Width = data_IO.read_float_from_file_pointer(in_fp, "Width")
highResWidth = data_IO.read_float_from_file_pointer(in_fp, "highResWidth")
meshScale = data_IO.read_float_from_file_pointer(in_fp, "meshScale")
in_fp.close()


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
