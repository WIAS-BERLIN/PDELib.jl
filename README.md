[![Build status](https://github.com/WIAS-BERLIN/PDELib.jl/workflows/linux-macos-windows/badge.svg)](https://github.com/WIAS-BERLIN/PDELib.jl/actions)
[![](https://img.shields.io/badge/docs-stable-blue.svg)](https://wias-berlin.github.io/PDELib.jl/stable/)
[![](https://img.shields.io/badge/docs-dev-blue.svg)](https://wias-berlin.github.io/PDELib.jl/dev/)


PDELib.jl
=========

This  is  a  meta  package which  re-exports  several  Julia  packages
developed  and  maintained  by   the  [WIAS](https://www.wias-berlin.de)  research  group  [Numerical
Mathematics and Scientific Computing](https://www.wias-berlin.de/research/rgs/fg3/) and various coauthors,
inspired by [pdelib](https://pdelib.org) which was implemented in C++ and python.

The final workflow for maintaining this meta package has not yet been established.
Currently, it is advisable to add the packages listed below one-by-one.

## Packages re-exported
- [VoronoiFVM.jl](https://github.com/j-fu/VoronoiFVM.jl): a finite volume solver for systems of nonlinear PDEs
- [GradientRobustMultiPhysics.jl](https://github.com/chmerdon/GradientRobustMultiPhysics.jl): finite element library implementing gradient robust FEM
- [ExtendableGrids.jl](https://github.com/j-fu/ExtendableGrids.jl): unstructured grid management library
- [GridVisualize.jl](https://github.com/j-fu/GridVisualize.jl): grid and function visualization related to ExtendableGrids.jl
- [SimplexGridFactory.jl](https://github.com/j-fu/SimplexGridFactory.jl): unified high level  mesh generator interface
- [ExtendableSparse.jl](https://github.com/j-fu/ExtendableSparse.jl): convenient and efficient sparse matrix assembly

## Packages associated
- [PlutoVista.jl](https://github.com/j-fu/PlutoVista.jl): Backend for using GridVisualize.jl in Pluto notebooks based on Plotly.js and vtk.js
- [VoronoiFVMDiffEq.jl](https://github.com/j-fu/VoronoiFVMDiffEq.jl):  glue package for using VoronoiFVM.jl together with DifferentialEquations.jl
- [GridVisualizeTools.jl](https://github.com/j-fu/GridVisualizeTools.jl): some tools for GridVisualize.jl and PlutoVista.jl
  
## Additional packages maintained

Not part of PDELib.jl, but maintained as part of the project:

- [Triangulate.jl](https://github.com/JuliaGeometry/Triangulate.jl),  [Triangle_jll.jl](https://github.com/JuliaBinaryWrappers/Triangle_jll.jl):  Julia wrapper and binary package of the [Triangle](https://www.cs.cmu.edu/~quake/triangle.html) triangle mesh generator by J. Shewchuk
- [TetGen.jl](https://github.com/JuliaGeometry/TetGen.jl),[TetGen_jll.jl](https://github.com/JuliaBinaryWrappers/TetGen_jll.jl): (co-maintained with [S. Danisch](https://github.com/SimonDanisch)):   Julia wrapper binary package of the [TetGen](http://www.tetgen.org) tetrahedral mesh generator by H. Si.


## Documentation and examples

Some examples are collected in the [examples](https://github.com/WIAS-BERLIN/PDELib.jl/tree/main/examples) subdirectory.

More up-to-date examples and documentation are found in the respective package repositories, mainly in
-  [VoronoiFVM.jl](https://j-fu.github.io/VoronoiFVM.jl/stable/)
-  [GradientRobustMultiPhysics.jl](https://chmerdon.github.io/GradientRobustMultiPhysics.jl/stable/)
-  [VoronoiFVMDiffEq.jl](https://j-fu.github.io/VoronoiFVMDiffEq.jl/stable/)



