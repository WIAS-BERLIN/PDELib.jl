using Test, Pkg
using PDELib
using Pluto, Markdown, InteractiveUtils

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
    @info "Run $(input)"
    Pluto.activate_notebook_environment(input)
    Pkg.instantiate()
    length(include(input))>0  # Notebooks return their manifest in the moment.
end


notebooks=["Pluto-GridsAndVisualization",
           "Pluto-MultECatGrids"]

@testset "Notebooks" begin
for notebook in notebooks
    @test notebooktest(notebook)
end
end
