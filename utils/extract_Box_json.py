from paraview.simple import *
import json
import sys
import pvutils
import data_IO

if len(sys.argv) < 5:
    print("Number of provided arguments: ", len(sys.argv) - 1)
    print("Usage: pvpython extractBox_json.py  <solve.exo>  <desiredMetrics.json> <outputDir> <outputMetrics.csv>")
    sys.exit()


solveexoFileAddress = sys.argv[1]
kpiFileAddress = sys.argv[2]
outputDir = sys.argv[3]
metricFileName = sys.argv[4]
individualImages = True
magnification = 2

# Read the desired outputs/metrics from the csv file:
fp_jsonIn = data_IO.open_file(kpiFileAddress)
kpihash = json.load(fp_jsonIn)
kpihash = pvutils.byteify(kpihash)
fp_jsonIn.close()
print kpihash

cellsarrays = pvutils.getfieldsfromkpihash(kpihash)

#### disable automatic camera reset on 'Show'
paraview.simple._DisableFirstRenderCameraReset()

## Read the results file : create a new 'ExodusIIReader'
solveExo = ExodusIIReader(FileName=solveexoFileAddress)

# get animation scene
animationScene1 = GetAnimationScene()

# update animation scene based on data timesteps
animationScene1.UpdateAnimationUsingDataTimeSteps()

# only load the data that is needed
solveExo.PointVariables = cellsarrays

solveExo.ElementBlocks = ['PNT', 'C3D20 C3D20R', 'COMPOSITE LAYER C3D20', 'Beam B32 B32R',
                          'CPS8 CPE8 CAX8 S8 S8R', 'C3D8 C3D8R', 'TRUSS2', 'TRUSS2',
                          'CPS4R CPE4R S4 S4R', 'CPS4I CPE4I', 'C3D10', 'C3D4', 'C3D15',
                          'CPS6 CPE6 S6', 'C3D6', 'CPS3 CPE3 S3',
                          '2-node 1d network entry elem', '2-node 1d network exit elem',
                          '2-node 1d genuine network elem']

latesttime = animationScene1.TimeKeeper.TimestepValues[-1]
print("Latest Time: ",latesttime)

# get active view
renderView1 = GetActiveViewOrCreate('RenderView')

# set the view size
renderView1.ViewSize = [700, 600]
renderView1.Background = [1,1,1] # set background color
#renderView1.OrientationAxesVisibility=False
renderView1.ViewTime = latesttime

# show data in view
solveDisplay = Show(solveExo, renderView1)
# trace defaults for the display properties.
solveDisplay.Representation = 'Surface'
solveDisplay.ColorArrayName = [None, '']
solveDisplay.EdgeColor = [0.0, 0.0, 0.0]

solveDisplay.OSPRayScaleArray = 'GlobalNodeId'
solveDisplay.OSPRayScaleFunction = 'PiecewiseFunction'
solveDisplay.SelectOrientationVectors = 'GlobalNodeId'
solveDisplay.SelectScaleArray = 'GlobalNodeId'
solveDisplay.GlyphType = 'Arrow'
solveDisplay.PolarAxes = 'PolarAxesRepresentation'
solveDisplay.ScalarOpacityUnitDistance = 1.3416442064699057
solveDisplay.GaussianRadius = 0.5
solveDisplay.SetScaleArray = ['POINTS', 'GlobalNodeId']
solveDisplay.ScaleTransferFunction = 'PiecewiseFunction'
solveDisplay.OpacityArray = ['POINTS', 'GlobalNodeId']
solveDisplay.OpacityTransferFunction = 'PiecewiseFunction'

# reset view to fit data
renderView1.ResetCamera()

camera=GetActiveCamera()


print("Generating KPIs")

# Set component to "Magnitude" if not given for vector/tensor fields
for kpi in kpihash:
    kpihash[kpi] = pvutils.correctfieldcomponent(solveExo, kpihash[kpi])

fp_csv_metrics = data_IO.open_file(metricFileName, "w")
fp_csv_metrics.write(",".join(['metric','ave','min','max'])+"\n")

renderView1.InteractionMode = '2D'
for kpi in kpihash:
    metrichash = kpihash[kpi]
    kpitype = metrichash['type']
    kpifield = metrichash['field']
    kpiComp = metrichash['fieldComponent']

    try:
        kpiimage = metrichash['image'].split("_")[0]
    except:
        kpiimage = "None"
    if individualImages:
        HideAll()
        Show(solveExo, renderView1)
        if kpiimage != "None" and kpiimage != "" and kpiimage != "plot":
            pvutils.adjustCamera(kpiimage, renderView1)
    print(kpi)
    if kpitype=="Slice":
        d = pvutils.createSlice(metrichash, solveExo, solveDisplay, individualImages)
    elif kpitype== "Clip":
        d = pvutils.createClip(metrichash, solveExo, solveDisplay, individualImages)
    elif kpitype== "Probe":
        d = pvutils.createProbe(metrichash, solveExo)
    elif kpitype== "Line":
        d,ave = pvutils.createLine(metrichash, kpi, solveExo, outputDir)
    elif kpitype== "Volume":
        d = pvutils.createVolume(metrichash, solveExo)

    datarange = pvutils.getdatarange(d, kpifield, kpiComp)

    if kpitype == "Probe":
        average=(datarange[0]+datarange[1])/2
    elif kpitype == "Line":
        average=ave
    elif kpitype == "Slice":
        # get kpi field value and area - average = value/area
        integrateVariables = IntegrateVariables(Input=d)
        average= pvutils.getdatarange(integrateVariables, kpifield, kpiComp)[0]\
                 / integrateVariables.CellData['Area'].GetRange()[0]
    elif kpitype == "Volume" or kpitype == "Clip":
        integrateVariables = IntegrateVariables(Input=d)
        average= pvutils.getdatarange(integrateVariables, kpifield, kpiComp)[0]\
                 / integrateVariables.CellData['Volume'].GetRange()[0]

    fp_csv_metrics.write(",".join([kpi,str(average),str(datarange[0]),str(datarange[1])])
                         +"\n")

    if individualImages:
        if kpiimage != "None" and kpiimage != "" and kpiimage != "plot":
            SaveScreenshot(outputDir + "/out_" + kpi + ".png", magnification=magnification, quality=100)


fp_csv_metrics.close()

SaveScreenshot(outputDir + "/out_stl.png", magnification=magnification, quality=100)
