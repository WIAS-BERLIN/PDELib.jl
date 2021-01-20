using PDELib
using Triangulate

function fv_laplace_circle(;Plotter=nothing,nref=0)
    
    function circle!(builder, center, radius; n=20*2^nref)
        points=[point!(builder, center[1]+radius*sin(t),center[2]+radius*cos(t)) for t in range(0,2π,length=n)]
        for i=1:n-1
            facet!(builder,points[i],points[i+1])
        end
        facet!(builder,points[end],points[1])
    end

    builder=SimplexGridBuilder(Generator=Triangulate)
    cellregion!(builder,1)
    maxvolume!(builder,0.1)
    regionpoint!(builder,0,0)
    
    facetregion!(builder,1)
    circle!(builder,(0,0),1)

    facetregion!(builder,2)
    circle!(builder,(-0.2,-0.2),0.2)
    holepoint!(builder,-0.2,-0.2)

    grid=simplexgrid(builder,maxvolume=0.1*4.0^(-nref))

    function flux(f,u0,edge)
        u=unknowns(edge,u0)
        f[1]=u[1,1]-u[1,2]
    end
    physics=VoronoiFVM.Physics(num_species=1,flux=flux)

    sys=VoronoiFVM.System(grid,physics)
    ispec=1
    enable_species!(sys,ispec,[1])
    boundary_dirichlet!(sys,ispec,1,0.0)
    boundary_dirichlet!(sys,ispec,2,1.0)
    inival=unknowns(sys,inival=0)
    solution=unknowns(sys)
    VoronoiFVM.solve!(solution,inival,sys)

    visualizer=GridVisualizer(Plotter=Plotter,layout=(1,2),resolution=(800,400))
    gridplot!(visualizer[1,1],grid)
    scalarplot!(visualizer[1,2],grid,solution[1,:])
    reveal(visualizer)
    true
end
