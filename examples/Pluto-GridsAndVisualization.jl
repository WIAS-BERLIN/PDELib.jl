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
g1=simplexgrid(X1)

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
ExtendableGrids = "~0.9.16"
GridVisualize = "~0.6.1"
PlutoUI = "~0.7.16"
PlutoVista = "~0.8.6"
SimplexGridFactory = "~0.5.18"
TetGen = "~1.4.0"
Triangulate = "~2.2.0"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

manifest_format = "2.0"
project_hash = "923e356fbb96a3a983b9ae7f68ee55a6e7a31a62"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "8eaf9f1b4921132a4cff3f36a1d9ba923b14a481"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.4"

[[deps.AbstractTrees]]
git-tree-sha1 = "faa260e4cb5aba097a73fab382dd4b5819d8ec8c"
uuid = "1520ce14-60c1-5f80-bbc7-55ef81b5835c"
version = "0.4.4"

[[deps.Adapt]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "195c5505521008abea5aee4f96930717958eac6f"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.4.0"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.BitFlags]]
git-tree-sha1 = "43b1a4a8f797c1cddadf60499a8a077d4af2cd2d"
uuid = "d1d4a3ce-64b1-5f1a-9ba4-7e7e69966f35"
version = "0.1.7"

[[deps.ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "c6d890a52d2c4d55d326439580c3b8d0875a77d9"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.15.7"

[[deps.ChangesOfVariables]]
deps = ["ChainRulesCore", "LinearAlgebra", "Test"]
git-tree-sha1 = "38f7a08f19d8810338d4f5085211c7dfa5d5bdd8"
uuid = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
version = "0.1.4"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "ded953804d019afa9a3f98981d99b33e3db7b6da"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.0"

[[deps.ColorSchemes]]
deps = ["ColorTypes", "ColorVectorSpace", "Colors", "FixedPointNumbers", "Random", "SnoopPrecompile"]
git-tree-sha1 = "aa3edc8f8dea6cbfa176ee12f7c2fc82f0608ed3"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.20.0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "eb7f0f8307f71fac7c606984ea5fb2817275d6e4"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.4"

[[deps.ColorVectorSpace]]
deps = ["ColorTypes", "FixedPointNumbers", "LinearAlgebra", "SpecialFunctions", "Statistics", "TensorCore"]
git-tree-sha1 = "600cc5508d66b78aae350f7accdb58763ac18589"
uuid = "c3611d14-8923-5661-9e6a-0046d554d3a4"
version = "0.9.10"

[[deps.Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "fc08e5930ee9a4e03f84bfb5211cb54e7769758a"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.10"

[[deps.Compat]]
deps = ["Dates", "LinearAlgebra", "UUIDs"]
git-tree-sha1 = "00a2cccc7f098ff3b66806862d275ca3db9e6e5a"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.5.0"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.0.1+0"

[[deps.Configurations]]
deps = ["ExproniconLite", "OrderedCollections", "TOML"]
git-tree-sha1 = "62a7c76dbad02fdfdaa53608104edf760938c4ca"
uuid = "5218b696-f38b-4ac9-8b61-a12ec717816d"
version = "0.17.4"

[[deps.DataAPI]]
git-tree-sha1 = "e8119c1a33d267e16108be441a287a6981ba1630"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.14.0"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "2fb1e02f2b635d0845df5d7c167fec4dd739b00d"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.3"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.EarCut_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e3290f2d49e661fbd94046d7e3726ffcb2d41053"
uuid = "5ae413db-bbd1-5e63-b57d-d24a61df00f5"
version = "2.2.4+0"

[[deps.ElasticArrays]]
deps = ["Adapt"]
git-tree-sha1 = "e1c40d78de68e9a2be565f0202693a158ec9ad85"
uuid = "fdbdab4c-e67f-52f5-8c3f-e7b388dad3d4"
version = "1.2.11"

[[deps.ExproniconLite]]
deps = ["Pkg", "TOML"]
git-tree-sha1 = "c2eb763acf6e13e75595e0737a07a0bec0ce2147"
uuid = "55351af7-c7e9-48d6-89ff-24e801d99491"
version = "0.7.11"

[[deps.ExtendableGrids]]
deps = ["AbstractTrees", "Dates", "DocStringExtensions", "ElasticArrays", "InteractiveUtils", "LinearAlgebra", "Printf", "Random", "SparseArrays", "StaticArrays", "Test", "WriteVTK"]
git-tree-sha1 = "310b903a560b7b18f63486ff93da1ded9cae1f15"
uuid = "cfc395e8-590f-11e8-1f13-43a2532b2fa8"
version = "0.9.16"

[[deps.Extents]]
git-tree-sha1 = "5e1e4c53fa39afe63a7d356e30452249365fba99"
uuid = "411431e0-e8b7-467b-b5e0-f676ba4f2910"
version = "0.1.1"

[[deps.FileIO]]
deps = ["Pkg", "Requires", "UUIDs"]
git-tree-sha1 = "7be5f99f7d15578798f338f5433b6c432ea8037b"
uuid = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
version = "1.16.0"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FillArrays]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "Statistics"]
git-tree-sha1 = "9a0472ec2f5409db243160a8b030f94c380167a3"
uuid = "1a297f60-69ca-5386-bcde-b61e274b549b"
version = "0.13.6"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[deps.FuzzyCompletions]]
deps = ["REPL"]
git-tree-sha1 = "e16dd964b4dfaebcded16b2af32f05e235b354be"
uuid = "fb4132e2-a121-4a70-b8a1-d5b831dcdcc2"
version = "0.5.1"

[[deps.GPUArraysCore]]
deps = ["Adapt"]
git-tree-sha1 = "57f7cde02d7a53c9d1d28443b9f11ac5fbe7ebc9"
uuid = "46192b85-c4d5-4398-a991-12ede77f4527"
version = "0.1.3"

[[deps.GeoInterface]]
deps = ["Extents"]
git-tree-sha1 = "e315c4f9d43575cf6b4e511259433803c15ebaa2"
uuid = "cf35fbd7-0cd7-5166-be24-54bfbe79505f"
version = "1.1.0"

[[deps.GeometryBasics]]
deps = ["EarCut_jll", "GeoInterface", "IterTools", "LinearAlgebra", "StaticArrays", "StructArrays", "Tables"]
git-tree-sha1 = "fe9aea4ed3ec6afdfbeb5a4f39a2208909b162a6"
uuid = "5c1252a2-5f33-56bf-86c9-59e7332b4326"
version = "0.4.5"

[[deps.GridVisualize]]
deps = ["ColorSchemes", "Colors", "DocStringExtensions", "ElasticArrays", "ExtendableGrids", "GeometryBasics", "GridVisualizeTools", "HypertextLiteral", "LinearAlgebra", "Observables", "OrderedCollections", "PkgVersion", "Printf", "StaticArrays"]
git-tree-sha1 = "b19a5815f9ba376dff963fccdf0c98dbddc6f61d"
uuid = "5eed8a63-0fb0-45eb-886d-8d5a387d12b8"
version = "0.6.1"

[[deps.GridVisualizeTools]]
deps = ["ColorSchemes", "Colors", "DocStringExtensions", "StaticArraysCore"]
git-tree-sha1 = "5964fd3e4080af45bfdbdaff75567759fd0367bd"
uuid = "5573ae12-3b76-41d9-b48c-81d0b6e61cc5"
version = "0.2.1"

[[deps.HTTP]]
deps = ["Base64", "CodecZlib", "Dates", "IniFile", "Logging", "LoggingExtras", "MbedTLS", "NetworkOptions", "OpenSSL", "Random", "SimpleBufferStream", "Sockets", "URIs", "UUIDs"]
git-tree-sha1 = "eb5aa5e3b500e191763d35198f859e4b40fff4a6"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "1.7.3"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "c47c5fa4c5308f27ccaac35504858d8914e102f9"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.4"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "f7be53659ab06ddc986428d3a9dcc95f6fa6705a"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.2"

[[deps.IniFile]]
git-tree-sha1 = "f550e6e32074c939295eb5ea6de31849ac2c9625"
uuid = "83e8ac13-25f8-5344-8a64-a9f2b223428f"
version = "0.5.1"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.InverseFunctions]]
deps = ["Test"]
git-tree-sha1 = "49510dfcb407e572524ba94aeae2fced1f3feb0f"
uuid = "3587e190-3f89-42d0-90ee-14403ec27112"
version = "0.1.8"

[[deps.IrrationalConstants]]
git-tree-sha1 = "7fd44fd4ff43fc60815f8e764c0f352b83c49151"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.1.1"

[[deps.IterTools]]
git-tree-sha1 = "fa6287a4469f5e048d763df38279ee729fbd44e5"
uuid = "c8e1da08-722c-5040-9ed9-7db0dc04731e"
version = "1.4.0"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "abc9885a7ca2052a736a600f7fa66209f96506e1"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.4.1"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "3c837543ddb02250ef42f4738347454f95079d4e"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.3"

[[deps.LazilyInitializedFields]]
git-tree-sha1 = "410fe4739a4b092f2ffe36fcb0dcc3ab12648ce1"
uuid = "0e77f7df-68c5-4e49-93ce-4cd80f5598bf"
version = "1.2.1"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.3"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "7.84.0+0"

[[deps.LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.10.2+0"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c7cb1f5d892775ba13767a87c7ada0b980ea0a71"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.16.1+2"

[[deps.LightXML]]
deps = ["Libdl", "XML2_jll"]
git-tree-sha1 = "e129d9391168c677cd4800f5c0abb1ed8cb3794f"
uuid = "9c8b4983-aa76-5018-a973-4c85ecc9e179"
version = "0.9.0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.LogExpFunctions]]
deps = ["ChainRulesCore", "ChangesOfVariables", "DocStringExtensions", "InverseFunctions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "946607f84feb96220f480e0422d3484c49c00239"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.19"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.LoggingExtras]]
deps = ["Dates", "Logging"]
git-tree-sha1 = "cedb76b37bc5a6c702ade66be44f831fa23c681e"
uuid = "e6f89c97-d47a-5376-807f-9c37f3926c36"
version = "1.0.0"

[[deps.MIMEs]]
git-tree-sha1 = "65f28ad4b594aebe22157d6fac869786a255b7eb"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "0.1.4"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "MozillaCACerts_jll", "Random", "Sockets"]
git-tree-sha1 = "03a9b9718f5682ecb107ac9f7308991db4ce395b"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.1.7"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.0+0"

[[deps.MeshIO]]
deps = ["ColorTypes", "FileIO", "GeometryBasics", "Printf"]
git-tree-sha1 = "8be09d84a2d597c7c0c34d7d604c039c9763e48c"
uuid = "7269a6da-0436-5bbc-96c2-40638cbb6118"
version = "0.4.10"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2022.2.1"

[[deps.MsgPack]]
deps = ["Serialization"]
git-tree-sha1 = "a8cbf066b54d793b9a48c5daa5d586cf2b5bd43d"
uuid = "99f44e22-a591-53d1-9472-aa23ef4bd671"
version = "1.1.0"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.Observables]]
git-tree-sha1 = "6862738f9796b3edc1c09d0890afce4eca9e7e93"
uuid = "510215fc-4207-5dde-b226-833fc4488ee2"
version = "0.5.4"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.20+0"

[[deps.OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"
version = "0.8.1+0"

[[deps.OpenSSL]]
deps = ["BitFlags", "Dates", "MozillaCACerts_jll", "OpenSSL_jll", "Sockets"]
git-tree-sha1 = "6503b77492fd7fcb9379bf73cd31035670e3c509"
uuid = "4d8831e6-92b7-49fb-bdf8-b643e874388c"
version = "1.3.3"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "f6e9dba33f9f2c44e08a020b0caf6903be540004"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "1.1.19+0"

[[deps.OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "13652491f6856acfd2db29360e1bbcd4565d04f1"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.5+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[deps.Parsers]]
deps = ["Dates", "SnoopPrecompile"]
git-tree-sha1 = "8175fc2b118a3755113c8e68084dc1a9e63c61ee"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.5.3"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.8.0"

[[deps.PkgVersion]]
deps = ["Pkg"]
git-tree-sha1 = "f6cf8e7944e50901594838951729a1861e668cb8"
uuid = "eebad327-c553-4316-9ea0-9fa01ccd7688"
version = "0.3.2"

[[deps.Pluto]]
deps = ["Base64", "Configurations", "Dates", "Distributed", "FileWatching", "FuzzyCompletions", "HTTP", "HypertextLiteral", "InteractiveUtils", "Logging", "MIMEs", "Markdown", "MsgPack", "Pkg", "PrecompileSignatures", "REPL", "RegistryInstances", "RelocatableFolders", "Sockets", "TOML", "Tables", "URIs", "UUIDs"]
git-tree-sha1 = "f4c99fcadf03dcdd2dd8ae7a56ca963ef1450d4f"
uuid = "c3e4b0f8-55cb-11ea-2926-15256bba5781"
version = "0.19.19"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "eadad7b14cf046de6eb41f13c9275e5aa2711ab6"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.49"

[[deps.PlutoVista]]
deps = ["ColorSchemes", "Colors", "DocStringExtensions", "GridVisualizeTools", "HypertextLiteral", "Pluto", "UUIDs"]
git-tree-sha1 = "5af654ba1660641b3b80614a7be7eacae4c49875"
uuid = "646e1f28-b900-46d7-9d87-d554eb38a413"
version = "0.8.16"

[[deps.PrecompileSignatures]]
git-tree-sha1 = "18ef344185f25ee9d51d80e179f8dad33dc48eb1"
uuid = "91cefc8d-f054-46dc-8f8c-26e11d7c5411"
version = "3.0.3"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "47e5f437cc0e7ef2ce8406ce1e7e24d44915f88d"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.3.0"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.RegistryInstances]]
deps = ["LazilyInitializedFields", "Pkg", "TOML", "Tar"]
git-tree-sha1 = "ffd19052caf598b8653b99404058fce14828be51"
uuid = "2792f1a3-b283-48e8-9a74-f99dce5104f3"
version = "0.1.0"

[[deps.RelocatableFolders]]
deps = ["SHA", "Scratch"]
git-tree-sha1 = "90bc7a7c96410424509e4263e277e43250c05691"
uuid = "05181044-ff0b-4ac5-8273-598c1e38db00"
version = "1.0.0"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Scratch]]
deps = ["Dates"]
git-tree-sha1 = "f94f779c94e58bf9ea243e77a37e16d9de9126bd"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.1.1"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.SimpleBufferStream]]
git-tree-sha1 = "874e8867b33a00e784c8a7e4b60afe9e037b74e1"
uuid = "777ac1f9-54b0-4bf8-805c-2214025038e7"
version = "1.1.0"

[[deps.SimplexGridFactory]]
deps = ["DocStringExtensions", "ElasticArrays", "ExtendableGrids", "FileIO", "GridVisualize", "LinearAlgebra", "MeshIO", "Printf", "Test"]
git-tree-sha1 = "4566d826852b7815d34c7a8829679c6f15f4b2e7"
uuid = "57bfcd06-606e-45d6-baf4-4ba06da0efd5"
version = "0.5.18"

[[deps.SnoopPrecompile]]
deps = ["Preferences"]
git-tree-sha1 = "e760a70afdcd461cf01a575947738d359234665c"
uuid = "66db9d55-30c0-4569-8b51-7e840670fc0c"
version = "1.0.3"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.SpecialFunctions]]
deps = ["ChainRulesCore", "IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "d75bda01f8c31ebb72df80a46c88b25d1c79c56d"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.1.7"

[[deps.StaticArrays]]
deps = ["LinearAlgebra", "Random", "StaticArraysCore", "Statistics"]
git-tree-sha1 = "6954a456979f23d05085727adb17c4551c19ecd1"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.5.12"

[[deps.StaticArraysCore]]
git-tree-sha1 = "6b7ba252635a5eff6a0b0664a41ee140a1c9e72a"
uuid = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
version = "1.4.0"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.StructArrays]]
deps = ["Adapt", "DataAPI", "GPUArraysCore", "StaticArraysCore", "Tables"]
git-tree-sha1 = "b03a3b745aa49b566f128977a7dd1be8711c5e71"
uuid = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
version = "0.6.14"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.0"

[[deps.TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[deps.Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "OrderedCollections", "TableTraits", "Test"]
git-tree-sha1 = "c79322d36826aa2f4fd8ecfa96ddb47b174ac78d"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.10.0"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.1"

[[deps.TensorCore]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1feb45f88d133a655e001435632f019a9a1bcdb6"
uuid = "62fd8b95-f654-4bbd-a8a5-9c27f68ccd50"
version = "0.1.1"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.TetGen]]
deps = ["DocStringExtensions", "GeometryBasics", "LinearAlgebra", "Printf", "StaticArrays", "TetGen_jll"]
git-tree-sha1 = "d99fe468112a24feb36bcdac8c168f423de7e93c"
uuid = "c5d3f3f7-f850-59f6-8a2e-ffc6dc1317ea"
version = "1.4.0"

[[deps.TetGen_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "9ceedd691bce040e24126a56354f20d71554a495"
uuid = "b47fdcd6-d2c1-58e9-bbba-c1cee8d8c179"
version = "1.5.3+0"

[[deps.TranscodingStreams]]
deps = ["Random", "Test"]
git-tree-sha1 = "94f38103c984f89cf77c402f2a68dbd870f8165f"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.9.11"

[[deps.Triangle_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "fe28e9a4684f6f54e868b9136afb8fd11f1734a7"
uuid = "5639c1d2-226c-5e70-8d55-b3095415a16a"
version = "1.6.2+0"

[[deps.Triangulate]]
deps = ["DocStringExtensions", "Libdl", "Printf", "Test", "Triangle_jll"]
git-tree-sha1 = "bbca6ec35426334d615f58859ad40c96d3a4a1f9"
uuid = "f7e6ffb2-c36d-4f8f-a77e-16e897189344"
version = "2.2.0"

[[deps.Tricks]]
git-tree-sha1 = "6bac775f2d42a611cdfcd1fb217ee719630c4175"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.6"

[[deps.URIs]]
git-tree-sha1 = "ac00576f90d8a259f2c9d823e91d1de3fd44d348"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.4.1"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.WriteVTK]]
deps = ["Base64", "CodecZlib", "FillArrays", "LightXML", "TranscodingStreams"]
git-tree-sha1 = "f50c47d715199601a54afdd5267f24c8174842ae"
uuid = "64499a7a-5c06-52f2-abe2-ccb03c286192"
version = "1.16.0"

[[deps.XML2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "93c41695bc1c08c46c5899f4fe06d6ead504bb73"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.10.3+0"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.12+3"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl", "OpenBLAS_jll"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.1.1+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.48.0+0"

[[deps.p7zip_jll]]
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
