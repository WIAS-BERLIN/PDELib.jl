using Test
using PDELib
import Pluto, Pkg

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



function testnotebook(name)
    input=joinpath(@__DIR__,"..","examples",name*".jl")
    notebook=Pluto.load_notebook_nobackup(input)
    session = Pluto.ServerSession();
    notebook = Pluto.SessionActions.open(session,input; run_async=false)
    errored=false
    for c in notebook.cells
        if c.errored
            errored=true
            @error "Error in  $(c.cell_id): $(c.output.body[:msg])\n $(c.code)"
        end
    end
    !errored
end

notebooks=["Pluto-GridsAndVisualization",
           "Pluto-MultECatGrids"]

@testset "Notebooks" begin
     for notebook in notebooks
         @test testnotebook(notebook)
     end
end
