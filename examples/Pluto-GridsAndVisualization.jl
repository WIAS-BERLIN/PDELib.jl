### A Pluto.jl notebook ###
# v0.19.19

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ d432ad64-f91f-11ea-2e48-4bc7472ac64c
begin
	using SimplexGridFactory
	using ExtendableGrids
	using Triangulate
	using TetGen
	using GridVisualize
        using PlutoVista
	using PlutoUI
        isdefined(Main,:PlutoRunner) ? 	default_plotter!(PlutoVista) : default_plotter!(nothing) 
end

# ╔═╡ 940b1996-fe9d-11ea-2fa4-8b72bee62b76
md"""
# Grid creation and visualization in PDELib.jl

This notebook shows how to perform grid creation and visualization with the assistance of the packages [ExtendableGrids.jl](https://github.com/j-fu/ExtendableGrids.jl) and [SimplexGridFactory.jl](https://github.com/j-fu/SimplexGridFactory.jl) which are part of the  [PDELib.jl](https://github.com/WIAS-BERLIN/PDElib.jl) meta package.

Visualization in this notebook is done using the [GridVisualize.jl](https://github.com/j-fu/GridVisualize.jl) package.
"""

# ╔═╡ 47103e8f-a4ff-46ed-a632-572a2e194a50
md"""
## 1D grids

1D grids are created just from arrays of montonically increasing  coordinates
using the [simplexgrid](https://j-fu.github.io/ExtendableGrids.jl/stable/simplexgrid/#ExtendableGrids.simplexgrid-Tuple{AbstractVector{T}%20where%20T}) method.
"""

# ╔═╡ 93a0c45e-d6a3-415a-a82c-e4f7e2a09d22
X1=range(0,1;length=11)

# ╔═╡ 4622a1fc-fda7-4211-9cc0-4eb1a1584aa6
g1=simplexgrid(X1); @show g1

# ╔═╡ 3212b930-194d-422e-9d06-65885b25cc6d
md"""
We can plot a grid with a method from `GridVisualize.jl`
"""

# ╔═╡ 5520b8c0-0874-4790-a956-224e6c43d9cf
gridplot(g1; resolution=(500,150),legend=:rt)

# ╔═╡ 13aef2a1-5745-4fe5-9659-6b7c0e7267fc
md"""
We see some  additional information:

- `cellregion`: each grid cell (interval, triangle, tetrahedron) as an integer region marker attached 
- `bfaceregion`: boundary faces (points, lines, triangles) have an interger boundary region marker attached


We can also have a look into the grid structure:
"""

# ╔═╡ f19d20c8-4d69-442d-99c8-10874fa0a6d3
g1.components

# ╔═╡ 28e2e3b0-c168-481b-b467-29e6a5407431
md"""
Components can be accessed via `[ ]`. In fact the keys in the dictionary of components are [types](https://j-fu.github.io/ExtendableGrids.jl/stable/tdict/).
"""

# ╔═╡ f04017d7-1c55-4118-8467-1e134259e35d
g1[Coordinates]

# ╔═╡ 98016b49-8786-46b9-aca6-01d15c253b3f
g1[CellNodes]

# ╔═╡ 2d392a98-bf32-4145-ae93-a8e218367277
md"""
### Modifying region markers

The `simplexgrid` method provides a default distribution of markers, but we would like to be able to change them. This can be done by putting masks on cells or faces (points in 1D):
"""

# ╔═╡ 88247350-aa6c-4876-82c3-3534036d5702
g2=deepcopy(g1)

# ╔═╡ 42f8d91d-14c7-488f-bdb9-b3d22705186f
cellmask!(g2, [0.0], [0.5], 2);

# ╔═╡ db7e0233-4e08-41b8-9ebe-5570e6d32264
bfacemask!(g2, [0.5],[0.5], 3);

# ╔═╡ 74641f73-2efe-4df8-bebb-ed97e77d869e
gridplot(g2; resolution=(500, 150),legend=:rt)

# ╔═╡ 14fb7977-93cf-4f74-a8ec-b6ee25dbdf86
md"""
### Creating locally refined grids

For this purpose, we just need to create arrays with the corresponding coordinate values. This can be done programmatically.

Two support metods are provided for this purpose.
"""

# ╔═╡ 2d5cb9e1-2d14-415e-b792-c3124901011d
hmin=0.01 ; hmax=0.1

# ╔═╡ b1f903b3-29d7-4909-b7e2-8ef3528c9965
md"""
The `geomspace` method creates an array such that the smallest interval size is `hmin` and the largest interval size is not larger but close to `hmax`, and the interval sizes constitute a geometric sequence.
"""

# ╔═╡ 19125aed-5c46-4968-bcfc-0b469628b68e
X2L=geomspace(0,0.5,hmax,hmin)

# ╔═╡ f9debaf8-efe8-44d1-9671-4aa5bffa9bb8
DX2=X2L[2:end].-X2L[1:end-1]

# ╔═╡ 4f7f9eaf-61c5-4543-ae39-e58ca14fb89a
DX2[1:end-1]./DX2[2:end]

# ╔═╡ f873cb89-da6e-4e11-b3f6-2bf0b766ce5f
X2R=geomspace(0.5,1,hmin,hmax)

# ╔═╡ a2e6c397-4a7e-47eb-ad84-df6e9d3fdd43
md"""
We can glue these arrays together and create a grid from them:
"""

# ╔═╡ 805c2a1e-a6c6-47fc-b719-31c2a671a8d0
X2=glue(X2L,X2R)

# ╔═╡ dd7d8e17-f825-4047-9386-d9e2bfd0a48d
gridplot(simplexgrid(X2); resolution=(500,150),legend=:rt)

# ╔═╡ 3d7db57f-2864-4984-a979-609e1d838a9f
md"""
### Plotting functions

We assume that functions can be represented by their node values an plotted via their piecewise linear interpolants. E.g. they could come from some simulation.
"""

# ╔═╡ 4cf840e6-86c5-4af1-a780-6fc78b60716b
g1d2=simplexgrid(range(-10,10,length=201))

# ╔═╡ 151cc4b8-c5ed-4f5e-8d5f-2f708c9c7fae
fsin=map(sin,g1d2)

# ╔═╡ 605581c4-3c6f-4c31-bd90-7645d3f70315
fcos=map(cos,g1d2)

# ╔═╡ bd40e614-00ef-426d-aa98-eca2ef48320e
fsinh=map(x->sinh(0.2*x), g1d2)

# ╔═╡ 71af99ab-612a-4821-8e9c-efc8766e2e3e
let
	vis=GridVisualizer(;resolution=(600,300),legend=:lt)
	
	scalarplot!(vis, g1d2, fsinh, label="sinh", markershape=:dtriangle, color=:red,markevery=5,clear=false)

	scalarplot!(vis, g1d2, fcos, label="cos", markershape=:xcross, color=:green, linestyle=:dash, clear=false,markevery=20)
		
	scalarplot!(vis, g1d2, fsin, label="sin", markershape=:none, color=:blue, linestyle=:dot, clear=false, markevery=20)

	reveal(vis)
end

# ╔═╡ 6dfa1d73-8baa-4589-b2e6-547834c9e444
md"""
## 2D grids
### Tensor product grids

For 2D tensor product grids, we can again use the `simplexgrid` method
and apply the mask methods for modifying cell and boundary region markers.
"""

# ╔═╡ f9599246-8238-432c-a315-300d74abfa2c
begin
	g2d1=simplexgrid(X1,X2)
	cellmask!(g2d1, [0.0,0.0], [0.5, 0.5], 2)
	cellmask!(g2d1, [0.5,0.5], [1.0, 1.0], 3)
	bfacemask!(g2d1, [0.0, 0.0], [0.0, 0.5],5)
end

# ╔═╡ ba5af291-fb16-4f21-8b74-664284bf7bd9
gridplot(g2d1,resolution=(600,400),linewidth=0.5,legend=:lt)

# ╔═╡ dfbaacea-4cb4-4147-9f1b-4424d7a7e89b
md"""
To interact with the plot, you can use the mouse wheel or double toch to zoom,
"shift-mouse-left" to pan, and "alt-mouse-left" or "ctrl-mouse-left" to reset.
"""

# ╔═╡ 7d1698dd-3bb7-4b38-9c6d-a88652749eee
md"""
We can also have a look into the components of a 2D grid:
"""

# ╔═╡ 81249f7c-abdf-43cc-b57f-2915b09da009
g2d1.components

# ╔═╡ 0765641a-8ed9-4579-bd9b-90bb02a55792
md"""
### Unstructured grids

For the triangulation of unstructured grids, we use the mesh generator Triangle via the [Triangulate.jl](https://github.com/JuliaGeometry/Triangulate.jl)  and [SimplexGridFactory.jl](https://github.com/j-fu/SimplexGridFactory.jl) packages.

The later package exports the `SimplexGridBuilder` which shall help to simplify the creation of the input for `Triangulate`.
"""

# ╔═╡ 884a11a2-15cf-40fc-a1ca-66ea23c6094e
builder2=let
	b=SimplexGridBuilder(Generator=Triangulate)
	p1=point!(b,0,0)
	p2=point!(b,1,0)
	p3=point!(b,1,1)

	# Specify outer boundary
	facetregion!(b,1)
	facet!(b,p1,p2)
	facetregion!(b,2)
	facet!(b,p2,p3)
	facetregion!(b,3)
	facet!(b,p3,p1)	
	
	cellregion!(b,1)
	regionpoint!(b,0.75,0.25)
	
	options!(b,maxvolume=0.01)
	b
end

# ╔═╡ 8fbd238c-723e-4bce-af69-9cabfc03f8d9
md"""
We can plot the current state of the builder:
"""

# ╔═╡ 342788d4-e5d0-4239-be87-7658bb67c999
grid2d2=simplexgrid(builder2;maxvolume=0.001)

# ╔═╡ 8f7d958e-5dc5-4324-af21-ad829d7d77eb
gridplot(grid2d2, resolution=(400,300),linewidth=0.5)

# ╔═╡ fd27b44a-f923-11ea-2afb-d79f7e62e214
md"""
### More complicated grids


More complicated grids include:

- local refinement
- interior boundaries
- different region markers
- holes

The particular way to describe these things is due to Jonathan Shewchuk and his mesh generator [Triangle](https://www.cs.cmu.edu/~quake/triangle.html) via its Julia wrapper package  [Triangulate.jl](https://github.com/JuliaGeometry/Triangulate.jl).
"""

# ╔═╡ 4a289b23-46b9-495d-b19c-42b3da71b242
md"""
#### Local refinement
"""

# ╔═╡ b12838f0-fe9c-11ea-2939-155ed907322d
refinement_center=[0.8,0.2]

# ╔═╡ d5d8a1d6-fe9d-11ea-0fd8-df6e81492cb5
md"""
For local refimenent, we define  a function, which is able to
tell if a triangle is to be refined ("unsuitable") or can be kept as it is.

The function measures the distance between the refinement center and the  triangle barycenter. We require that the area increases with the distance from the refinement center.
"""

# ╔═╡ aae2e82a-fe9c-11ea-0427-593f8d2c7746
function unsuitable(x1,y1,x2,y2,x3,y3,area)
        bary_x=(x1+x2+x3)/3.0
        bary_y=(y1+y2+y3)/3.0
        dx=bary_x-refinement_center[1]
        dy=bary_y-refinement_center[2]
        qdist=dx^2+dy^2
        area>0.1*max(1.0e-2,qdist)
end;

# ╔═╡ 1ae86964-fe9e-11ea-303b-65bb128384a5
md"""
#### Interior boundaries

Interior boundaries are described in a similar as exterior ones - just by facets connecting points.
"""

# ╔═╡ 3b8cd906-bc4e-44af-bcf4-8836d597ed4c
md"""
#### Subregions

Subregions are defined as regions surrounded by interior boundaries. 
By placing a "region point" into such a region and specifying a "region number",
we can set the cell region marker for all triangles created in the subregion.
"""

# ╔═╡ 9d240ef9-6639-4bde-a463-ea78480a970d
md"""
#### Holes
Holes are defined in a similar way as subregions, but a "hole point" is places into the place which shall become the hole.
"""

# ╔═╡ 511b26c6-f920-11ea-1228-51c3750f495c
builder3=let
	b=SimplexGridBuilder(Generator=Triangulate;tol=1.0e-10)

	#  Specify points
	p1=point!(b,0,0)
	p2=point!(b,1,0)
	p3=point!(b,1,1)
	p4=point!(b,0,0.7)
	
	# Specify outer boundary
	facetregion!(b,1)
	facet!(b,p1,p2)
	facetregion!(b,2)
	facet!(b,p2,p3)
	facetregion!(b,3)
	facet!(b,p3,p4)
	facetregion!(b,4)
	facet!(b,p1,p4)

	# Activate unsuitable callback
	options!(b,unsuitable=unsuitable)
	
	# Specify interior boundary
	facetregion!(b,5)
	facet!(b,p1,p3)
	
	# Coarse elements in upper left region #1
	cellregion!(b,1)
	maxvolume!(b,0.1)
	regionpoint!(b,0.1,0.5)
	
	# Fine elements in lower right region #2
	cellregion!(b,2)
	maxvolume!(b,0.01)
	regionpoint!(b,0.9,0.5)
	
	# Hole
	hp1=point!(b,0.4,0.1)
	hp2=point!(b,0.6,0.1)
	hp3=point!(b,0.5,0.3)
	holepoint!(b,0.5,0.2)
	facetregion!(b,6)
	facet!(b,hp1,hp2)
	facet!(b,hp2,hp3)
	facet!(b,hp3,hp1)
	
	
	b
end;

# ╔═╡ d2129483-285b-49a2-a11d-886956146b85
md"""
__Create a simplex grid from the builder__
"""

# ╔═╡ ac93589b-6315-4677-9542-c0a2333f1755
grid2d3=simplexgrid(builder3)

# ╔═╡ 59a6c8b5-25aa-47aa-9489-a803672013df
gridplot(grid2d3,legend=:lt, resolution=(400,400))

# ╔═╡ 4c99c40f-cf93-4cba-bef1-0c4ffcbf6833
md"""
### Plotting of functions

Functions defined on the nodes of a triangular grid can be seen as piecewise linear functions from the P1 finite element space defined by the triangulation.
"""

# ╔═╡ bad736d7-875c-4bc0-9ec4-494a90a508f7
fsin2=map((x,y)-> sin(x)*y, grid2d2)

# ╔═╡ a375c23f-6b8c-4b2c-a8b5-d38e6b5a8f6d
fsin3=map((x,y)-> sin(y)*x, grid2d3)

# ╔═╡ c3ef9067-3cdb-4bfd-9406-6ded64539978
scalarplot(grid2d2, fsin2, label="grid2d2")


# ╔═╡ 4dfb2e0f-3e3a-4053-8a76-765546e96992
	scalarplot(grid2d3, fsin3, label="grid2d3",colormap=:spring,isolines=10)


# ╔═╡ 2682df92-5955-4b17-ae4f-8e99c5b17980
md"""
## 3D Grids

### Tensor product grids

Please note that "masking" is not yet implemented.
Furthermore, PyPlot visualization is slow, with GLMakie it is way faster.
"""

# ╔═╡ 265fe6c7-d1cc-48a6-8295-f8f55acf677c
X3=range(0.,10.1,length=11)

# ╔═╡ b357395f-2a6e-476f-b008-02802c85a541
grid3d1=simplexgrid(X3,X3,X3)

# ╔═╡ af449be7-aab6-4de5-a059-3f8508502676
func3=map((x,y,z)-> sin(x/2)*cos(y/2)*z/10,grid3d1)

# ╔═╡ 38e2b4a8-2480-40e7-bde3-6d1775201aae
p3dg=GridVisualizer(dim=3,resolution=(200,200))

# ╔═╡ ef1fde48-fe90-4714-ac86-614ae3451aa7
p3ds=GridVisualizer(dim=3,resolution=(400,400))

# ╔═╡ 04041481-0f03-41e1-a7de-1b3fd033c952
mean(x)=sum(x)/length(x)

# ╔═╡ a3844fda-5725-4d95-894b-051a5f6c2faa
md"""
f=$(@bind flevel Slider(range(extrema(func3)...,length=20),default=mean(func3),show_value=true))

x=$(@bind xplane Slider(X3[1]:0.1:X3[end],default=X3[end],show_value=true))

y=$(@bind yplane Slider(X3[1]:0.1:X3[end],default=X3[end],show_value=true))

z=$(@bind zplane Slider(X3[1]:0.1:X3[end],default=X3[end],show_value=true))

"""

# ╔═╡ f97d085c-e7bf-4561-8183-673912bdeab6
gridplot!(p3dg,grid3d1,zplanes=[zplane],yplanes=[yplane], xplanes=[xplane], resolution=(200,200),show=true)

# ╔═╡ d73d18e7-bcf9-4cc1-9154-b70dc1ff5524


	scalarplot!(p3ds,grid3d1, func3, zplanes=[zplane], yplanes=[yplane],xplanes=[xplane],levels=[flevel],colormap=:spring,resolution=(200,200),show=true,levelalpha=0.5,outlinealpha=0.1)


# ╔═╡ 6cad87eb-1c59-4000-b688-a6f6d41f9413
md"""
### Unstructured grids


The SimplexGridBuilder API supports creation of three-dimensional grids in way very similar to the 2D case. Just define points with three coordinates and planar (!) facets with at least three points to describe the geometry.

The backend for mesh generation in this case is the [TetGen](http://tetgen.org) mesh generator by Hang Si from WIAS Berlin and its Julia wrapper [TetGen.jl](https://github.com/JuliaGeometry/TetGen.jl).
"""

# ╔═╡ fefc7587-8e25-4080-b934-90c0e1afc56a
builder3d=let
	    
    b=SimplexGridBuilder(Generator=TetGen)

    p1=point!(b,0,0,0)
    p2=point!(b,1,0,0)
    p3=point!(b,1,1,0)
    p4=point!(b,0,1,0)
    p5=point!(b,0,0,1)
    p6=point!(b,1,0,1)
    p7=point!(b,1,1,1)
    p8=point!(b,0,1,1)

    facetregion!(b,1)
    facet!(b,p1 ,p2 ,p3 ,p4)  
    facetregion!(b,2)
    facet!(b,p5 ,p6 ,p7 ,p8)  
    facetregion!(b,3)
    facet!(b,p1 ,p2 ,p6 ,p5)  
    facetregion!(b,4)
    facet!(b,p2 ,p3 ,p7 ,p6)  
    facetregion!(b,5)
    facet!(b,p3 ,p4 ,p8 ,p7)  
    facetregion!(b,6)
    facet!(b,p4 ,p1 ,p5 ,p8)


	hp1=point!(b,0.4,0.4,0.4)
    hp2=point!(b,0.6,0.4,0.4)
    hp3=point!(b,0.6,0.6,0.4)
    hp4=point!(b,0.4,0.6,0.4)
    hp5=point!(b,0.4,0.4,0.6)
    hp6=point!(b,0.6,0.4,0.6)
    hp7=point!(b,0.6,0.6,0.6)
    hp8=point!(b,0.4,0.6,0.6)

    facetregion!(b,7)
    facet!(b,hp1 ,hp2 ,hp3 ,hp4)  
    facet!(b,hp5 ,hp6 ,hp7 ,hp8)  
    facet!(b,hp1 ,hp2 ,hp6 ,hp5)  
    facet!(b,hp2 ,hp3 ,hp7 ,hp6)  
    facet!(b,hp3 ,hp4 ,hp8 ,hp7)  
    facet!(b,hp4 ,hp1 ,hp5 ,hp8)
	holepoint!(b, 0.5,0.5,0.5)
	
	b

end;

# ╔═╡ 065735f7-c799-4284-bd59-fe6383bb987c
grid3d2=simplexgrid(builder3d,maxvolume=0.0001)

# ╔═╡ 329992a0-e352-468b-af8b-0b190315fc61
gridplot(grid3d2,zplane=0.1,azim=20,elev=20,linewidth=0.5,outlinealpha=0.3)

# ╔═╡ a7965a6e-2e83-47eb-aee2-d366246a8637
html"""<hr>"""

# ╔═╡ 7ad541b1-f40f-4cdd-b7b5-b792a8e63d71
TableOfContents(depth=4)

# ╔═╡ 071b8834-d3d1-4d08-979f-56b05bc1e0d3
md"""
    begin
       using Pkg
       Pkg.activate(mktempdir())
       Pkg.add(["PlutoUI","Revise","Triangulate","TetGen"])
       using Revise
	   Pkg.develop(["ExtendableGrids","SimplexGridFactory",
           "GridVisualize","PlutoVista"])
    end
"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
ExtendableGrids = "cfc395e8-590f-11e8-1f13-43a2532b2fa8"
GridVisualize = "5eed8a63-0fb0-45eb-886d-8d5a387d12b8"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
PlutoVista = "646e1f28-b900-46d7-9d87-d554eb38a413"
SimplexGridFactory = "57bfcd06-606e-45d6-baf4-4ba06da0efd5"
TetGen = "c5d3f3f7-f850-59f6-8a2e-ffc6dc1317ea"
Triangulate = "f7e6ffb2-c36d-4f8f-a77e-16e897189344"

[compat]
ExtendableGrids = "~0.8.7"
GridVisualize = "~0.3.9"
PlutoUI = "~0.7.16"
PlutoVista = "~0.8.6"
SimplexGridFactory = "~0.5.9"
TetGen = "~1.3.0"
Triangulate = "~2.1.0"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

[[AbstractTrees]]
git-tree-sha1 = "03e0550477d86222521d254b741d470ba17ea0b5"
uuid = "1520ce14-60c1-5f80-bbc7-55ef81b5835c"
version = "0.3.4"

[[Adapt]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "84918055d15b3114ede17ac6a7182f68870c16f7"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.3.1"

[[ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[ColorSchemes]]
deps = ["ColorTypes", "Colors", "FixedPointNumbers", "Random"]
git-tree-sha1 = "a851fec56cb73cfdf43762999ec72eff5b86882a"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.15.0"

[[ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "024fe24d83e4a5bf5fc80501a314ce0d1aa35597"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.0"

[[Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "417b0ed7b8b838aa6ca0a87aadf1bb9eb111ce40"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.8"

[[CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.0.1+0"

[[DataAPI]]
git-tree-sha1 = "cc70b17275652eb47bc9e5f81635981f13cea5c8"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.9.0"

[[DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "b19534d1895d702889b219c382a6e18010797f0b"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.8.6"

[[Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[EarCut_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "3f3a2501fa7236e9b911e0f7a588c657e822bb6d"
uuid = "5ae413db-bbd1-5e63-b57d-d24a61df00f5"
version = "2.2.3+0"

[[ElasticArrays]]
deps = ["Adapt"]
git-tree-sha1 = "a0fcc1bb3c9ceaf07e1d0529c9806ce94be6adf9"
uuid = "fdbdab4c-e67f-52f5-8c3f-e7b388dad3d4"
version = "1.2.9"

[[ExtendableGrids]]
deps = ["AbstractTrees", "Dates", "DocStringExtensions", "ElasticArrays", "InteractiveUtils", "LinearAlgebra", "Printf", "Random", "SparseArrays", "Test"]
git-tree-sha1 = "1e8e50f054057f23e908fbd6935766dca6293cc2"
uuid = "cfc395e8-590f-11e8-1f13-43a2532b2fa8"
version = "0.8.7"

[[FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[GeometryBasics]]
deps = ["EarCut_jll", "IterTools", "LinearAlgebra", "StaticArrays", "StructArrays", "Tables"]
git-tree-sha1 = "58bcdf5ebc057b085e58d95c138725628dd7453c"
uuid = "5c1252a2-5f33-56bf-86c9-59e7332b4326"
version = "0.4.1"

[[GridVisualize]]
deps = ["ColorSchemes", "Colors", "DocStringExtensions", "ElasticArrays", "ExtendableGrids", "GeometryBasics", "LinearAlgebra", "Observables", "OrderedCollections", "PkgVersion", "Printf", "Requires", "StaticArrays"]
git-tree-sha1 = "925ba2f11df005d894b113292d32fca9afe3f8c8"
uuid = "5eed8a63-0fb0-45eb-886d-8d5a387d12b8"
version = "0.3.9"

[[Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[HypertextLiteral]]
git-tree-sha1 = "5efcf53d798efede8fee5b2c8b09284be359bf24"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.2"

[[IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "f7be53659ab06ddc986428d3a9dcc95f6fa6705a"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.2"

[[InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[IterTools]]
git-tree-sha1 = "05110a2ab1fc5f932622ffea2a003221f4782c18"
uuid = "c8e1da08-722c-5040-9ed9-7db0dc04731e"
version = "1.3.0"

[[IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "642a199af8b68253517b80bd3bfd17eb4e84df6e"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.3.0"

[[JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "8076680b162ada2a031f707ac7b4953e30667a37"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.2"

[[LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.3"

[[LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "7.84.0+0"

[[LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.10.2+0"

[[Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[LinearAlgebra]]
deps = ["Libdl", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.0+0"

[[Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2022.2.1"

[[NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[Observables]]
git-tree-sha1 = "fe29afdef3d0c4a8286128d4e45cc50621b1e43d"
uuid = "510215fc-4207-5dde-b226-833fc4488ee2"
version = "0.4.0"

[[OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.20+0"

[[OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[Parsers]]
deps = ["Dates"]
git-tree-sha1 = "ae4bbcadb2906ccc085cf52ac286dc1377dceccc"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.1.2"

[[Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.8.0"

[[PkgVersion]]
deps = ["Pkg"]
git-tree-sha1 = "a7a7e1a88853564e551e4eba8650f8c38df79b37"
uuid = "eebad327-c553-4316-9ea0-9fa01ccd7688"
version = "0.1.1"

[[PlutoUI]]
deps = ["Base64", "Dates", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "UUIDs"]
git-tree-sha1 = "615f3a1eff94add4bca9476ded096de60b46443b"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.17"

[[PlutoVista]]
deps = ["ColorSchemes", "Colors", "DocStringExtensions", "GridVisualize", "UUIDs"]
git-tree-sha1 = "b99d4e38e7dba4535cee937e0444aed5912245d0"
uuid = "646e1f28-b900-46d7-9d87-d554eb38a413"
version = "0.8.7"

[[Preferences]]
deps = ["TOML"]
git-tree-sha1 = "00cfd92944ca9c760982747e9a1d0d5d86ab1e5a"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.2.2"

[[Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "4036a3bd08ac7e968e27c203d45f5fff15020621"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.1.3"

[[SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[SimplexGridFactory]]
deps = ["DocStringExtensions", "ElasticArrays", "ExtendableGrids", "GridVisualize", "LinearAlgebra", "Printf", "Test"]
git-tree-sha1 = "af52ec74a4b6cfcc5b6d60d259099fa0596de2c1"
uuid = "57bfcd06-606e-45d6-baf4-4ba06da0efd5"
version = "0.5.9"

[[Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[StaticArrays]]
deps = ["LinearAlgebra", "Random", "Statistics"]
git-tree-sha1 = "3c76dde64d03699e074ac02eb2e8ba8254d428da"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.2.13"

[[Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[StructArrays]]
deps = ["Adapt", "DataAPI", "StaticArrays", "Tables"]
git-tree-sha1 = "2ce41e0d042c60ecd131e9fb7154a3bfadbf50d3"
uuid = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
version = "0.6.3"

[[TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.0"

[[TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "TableTraits", "Test"]
git-tree-sha1 = "fed34d0e71b91734bf0a7e10eb1bb05296ddbcd0"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.6.0"

[[Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.1"

[[Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[TetGen]]
deps = ["DocStringExtensions", "GeometryBasics", "LinearAlgebra", "Printf", "StaticArrays", "TetGen_jll"]
git-tree-sha1 = "2f1d87ccacd2a7faf9e0bade918946ec4d90bfdf"
uuid = "c5d3f3f7-f850-59f6-8a2e-ffc6dc1317ea"
version = "1.3.0"

[[TetGen_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "bc67a0d0b799fe248b1f199a5c893ccf316f0e60"
uuid = "b47fdcd6-d2c1-58e9-bbba-c1cee8d8c179"
version = "1.5.2+0"

[[Triangle_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "bfdd9ef1004eb9d407af935a6f36a4e0af711369"
uuid = "5639c1d2-226c-5e70-8d55-b3095415a16a"
version = "1.6.1+0"

[[Triangulate]]
deps = ["DocStringExtensions", "Libdl", "Printf", "Test", "Triangle_jll"]
git-tree-sha1 = "2b4f716b192c0c615d96d541ee029e85666388cb"
uuid = "f7e6ffb2-c36d-4f8f-a77e-16e897189344"
version = "2.1.0"

[[UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.12+3"

[[libblastrampoline_jll]]
deps = ["Artifacts", "Libdl", "OpenBLAS_jll"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.1.1+0"

[[nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.48.0+0"

[[p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+0"
"""

# ╔═╡ Cell order:
# ╟─940b1996-fe9d-11ea-2fa4-8b72bee62b76
# ╠═d432ad64-f91f-11ea-2e48-4bc7472ac64c
# ╟─47103e8f-a4ff-46ed-a632-572a2e194a50
# ╠═93a0c45e-d6a3-415a-a82c-e4f7e2a09d22
# ╠═4622a1fc-fda7-4211-9cc0-4eb1a1584aa6
# ╟─3212b930-194d-422e-9d06-65885b25cc6d
# ╠═5520b8c0-0874-4790-a956-224e6c43d9cf
# ╟─13aef2a1-5745-4fe5-9659-6b7c0e7267fc
# ╠═f19d20c8-4d69-442d-99c8-10874fa0a6d3
# ╟─28e2e3b0-c168-481b-b467-29e6a5407431
# ╠═f04017d7-1c55-4118-8467-1e134259e35d
# ╠═98016b49-8786-46b9-aca6-01d15c253b3f
# ╟─2d392a98-bf32-4145-ae93-a8e218367277
# ╠═88247350-aa6c-4876-82c3-3534036d5702
# ╠═42f8d91d-14c7-488f-bdb9-b3d22705186f
# ╠═db7e0233-4e08-41b8-9ebe-5570e6d32264
# ╠═74641f73-2efe-4df8-bebb-ed97e77d869e
# ╟─14fb7977-93cf-4f74-a8ec-b6ee25dbdf86
# ╠═2d5cb9e1-2d14-415e-b792-c3124901011d
# ╟─b1f903b3-29d7-4909-b7e2-8ef3528c9965
# ╠═19125aed-5c46-4968-bcfc-0b469628b68e
# ╠═f9debaf8-efe8-44d1-9671-4aa5bffa9bb8
# ╠═4f7f9eaf-61c5-4543-ae39-e58ca14fb89a
# ╠═f873cb89-da6e-4e11-b3f6-2bf0b766ce5f
# ╟─a2e6c397-4a7e-47eb-ad84-df6e9d3fdd43
# ╠═805c2a1e-a6c6-47fc-b719-31c2a671a8d0
# ╠═dd7d8e17-f825-4047-9386-d9e2bfd0a48d
# ╟─3d7db57f-2864-4984-a979-609e1d838a9f
# ╠═4cf840e6-86c5-4af1-a780-6fc78b60716b
# ╠═151cc4b8-c5ed-4f5e-8d5f-2f708c9c7fae
# ╠═605581c4-3c6f-4c31-bd90-7645d3f70315
# ╠═bd40e614-00ef-426d-aa98-eca2ef48320e
# ╠═71af99ab-612a-4821-8e9c-efc8766e2e3e
# ╟─6dfa1d73-8baa-4589-b2e6-547834c9e444
# ╠═f9599246-8238-432c-a315-300d74abfa2c
# ╠═ba5af291-fb16-4f21-8b74-664284bf7bd9
# ╟─dfbaacea-4cb4-4147-9f1b-4424d7a7e89b
# ╟─7d1698dd-3bb7-4b38-9c6d-a88652749eee
# ╠═81249f7c-abdf-43cc-b57f-2915b09da009
# ╟─0765641a-8ed9-4579-bd9b-90bb02a55792
# ╠═884a11a2-15cf-40fc-a1ca-66ea23c6094e
# ╟─8fbd238c-723e-4bce-af69-9cabfc03f8d9
# ╠═342788d4-e5d0-4239-be87-7658bb67c999
# ╠═8f7d958e-5dc5-4324-af21-ad829d7d77eb
# ╟─fd27b44a-f923-11ea-2afb-d79f7e62e214
# ╟─4a289b23-46b9-495d-b19c-42b3da71b242
# ╠═b12838f0-fe9c-11ea-2939-155ed907322d
# ╟─d5d8a1d6-fe9d-11ea-0fd8-df6e81492cb5
# ╠═aae2e82a-fe9c-11ea-0427-593f8d2c7746
# ╟─1ae86964-fe9e-11ea-303b-65bb128384a5
# ╟─3b8cd906-bc4e-44af-bcf4-8836d597ed4c
# ╟─9d240ef9-6639-4bde-a463-ea78480a970d
# ╠═511b26c6-f920-11ea-1228-51c3750f495c
# ╟─d2129483-285b-49a2-a11d-886956146b85
# ╠═ac93589b-6315-4677-9542-c0a2333f1755
# ╠═59a6c8b5-25aa-47aa-9489-a803672013df
# ╟─4c99c40f-cf93-4cba-bef1-0c4ffcbf6833
# ╠═bad736d7-875c-4bc0-9ec4-494a90a508f7
# ╠═a375c23f-6b8c-4b2c-a8b5-d38e6b5a8f6d
# ╠═c3ef9067-3cdb-4bfd-9406-6ded64539978
# ╠═4dfb2e0f-3e3a-4053-8a76-765546e96992
# ╟─2682df92-5955-4b17-ae4f-8e99c5b17980
# ╠═265fe6c7-d1cc-48a6-8295-f8f55acf677c
# ╠═b357395f-2a6e-476f-b008-02802c85a541
# ╠═af449be7-aab6-4de5-a059-3f8508502676
# ╠═38e2b4a8-2480-40e7-bde3-6d1775201aae
# ╠═f97d085c-e7bf-4561-8183-673912bdeab6
# ╠═ef1fde48-fe90-4714-ac86-614ae3451aa7
# ╠═d73d18e7-bcf9-4cc1-9154-b70dc1ff5524
# ╠═a3844fda-5725-4d95-894b-051a5f6c2faa
# ╠═04041481-0f03-41e1-a7de-1b3fd033c952
# ╟─6cad87eb-1c59-4000-b688-a6f6d41f9413
# ╠═fefc7587-8e25-4080-b934-90c0e1afc56a
# ╠═065735f7-c799-4284-bd59-fe6383bb987c
# ╠═329992a0-e352-468b-af8b-0b190315fc61
# ╟─a7965a6e-2e83-47eb-aee2-d366246a8637
# ╠═7ad541b1-f40f-4cdd-b7b5-b792a8e63d71
# ╠═071b8834-d3d1-4d08-979f-56b05bc1e0d3
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
