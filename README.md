A parametric sweep workflow for a welding case
==============================================

This workflow implements a parameter sweep on a parametric model of a thermomechanical simulation of a bead-on-plate welding process.

In this workflow:

-   The geometry and mesh is generated using [Salome platform](http://www.salome-platform.org/) (version 8.2.0)
-   The thrmomechanical simulation of the welding process is performed with the open source [CalculiX FEA solver](http://www.dhondt.de/) (version 2.12)
-   Post-processing is performed using [ParaView](https://www.paraview.org/) and a [python library](https://github.com/parallelworks/MetricExtraction) developed by Parallel Works for automated generation of output images and metrics extraction.

The workflow is implemented with [Swift](http://swift-lang.org/main/).

Required software
-----------------

-   The required software for executing this workflow are dockerized (see <https://hub.docker.com/u/parallelworks/?page=1> and <https://github.com/parallelworks/Dockerfiles>).
-   Executing the workflow requires installing Swift (see <http://swift-lang.org/tutorials/localhost/tutorial.html#_swift_installation>), and docker (<https://docs.docker.com/engine/installation/>)

Instructions for running the workflow
-------------------------------------

To run the workflow, run the following command from the main directory:

``` example
swift main.swift -sweepParamFile=inputs/sweepParams_fast.run  
```

The `sweepParamFile` specifies the file with the parameter values for running the workflow. More examples are in the directory `inputs/`

Authors
-------

The workflow is created by [Parallel Works](https://www.parallelworks.com/)
