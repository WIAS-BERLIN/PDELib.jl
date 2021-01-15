using PDELib

function fv_laplace_rect(;Plotter=nothing)
    nspecies=1 
    ispec=1    
    X=collect(0:0.2:1)
    function g!(f,u0,edge)
        u=unknowns(edge,u0)
        f[1]=u[1,1]-u[1,2]
    end
    grid=simplexgrid(X,X)
    physics=VoronoiFVM.Physics(num_species=nspecies,flux=g!)
    sys=VoronoiFVM.System(grid,physics)
    enable_species!(sys,ispec,[1])
    boundary_dirichlet!(sys,ispec,1,0.0)
    boundary_dirichlet!(sys,ispec,3,1.0)
    inival=unknowns(sys,inival=0)
    solution=unknowns(sys)
    VoronoiFVM.solve!(solution,inival,sys)
    scalarplot(grid,solution[1,:],Plotter=Plotter)
    true
end
