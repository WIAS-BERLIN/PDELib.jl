using Test, Pkg
using PDELib
import Pluto
using Markdown, InteractiveUtils

function runtest(t)
    include(joinpath(@__DIR__,"..","examples",t*".jl"))
    eval(Meta.parse("$(t)()"))
end

@testset "VoronoiFVM" begin
    @test runtest("fv_laplace_rect")
    @test runtest("fv_laplace_circle")
end

@testset "GradientRobustMultiPhysics" begin
    @info "GradientRobustMultiPhysics tests disabled in the moment"
#    @test runtest("fe_liddrivencavity_autonewton")
end



function notebooktest(name)
    input=joinpath(@__DIR__,"..","examples",name*".jl")
    cd(joinpath(@__DIR__,"..","examples"))
    @info pwd()
    @info "Run $(input)"
    Pluto.reset_notebook_environment(input, keep_project=true,backup=false)
    Pluto.activate_notebook_environment(input)
    Pkg.resolve()
    Pkg.instantiate()
    include(input)  # Notebooks return their manifest in the moment.
    true
end


notebooks=["Pluto-GridsAndVisualization",
           "Pluto-MultECatGrids"]

# @testset "Notebooks" begin
#     for notebook in notebooks
#         @test notebooktest(notebook)
#     end
# end
