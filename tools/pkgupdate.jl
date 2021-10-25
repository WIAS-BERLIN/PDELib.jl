using Pkg
Pkg.activate(".")
Pkg.instantiate()

using Pluto
using PDELib


Pkg.update()

notebooks=["examples/Pluto-GridsAndVisualization.jl",
           "examples/Pluto-MultECatGrids.jl"]
    

for notebook in notebooks
    println("Updating packages in $(notebook):")
    Pluto.activate_notebook_environment(notebook)
    Pkg.update()
    Pkg.status()
    run(`git diff $(notebook)`)
    println("Updating of  $(notebook) done\n")
    Pkg.activate(".")
end
