using Test
using PDELib

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
