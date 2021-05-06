### A Pluto.jl notebook ###
# v0.14.5

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : missing
        el
    end
end

# ╔═╡ d432ad64-f91f-11ea-2e48-4bc7472ac64c
begin
    # Ensure not using `,` as floating point decimal delimiter
    # in certain language enviromnents. 
    ENV["LC_NUMERIC"]="C"
    
	# Use package manager in temporary environment not 
	# interfering with other projects
    using Pkg
    Pkg.activate(mktempdir())

	# Revise helps with debugging dependencies when developing
	Pkg.add("Revise")
    using Revise
 
	# Add Julia packages
	Pkg.add(name="Triangulate", version="1")
    Pkg.add(name="TetGen", version="1")
    Pkg.add(name="PlutoUI",version="0.7")	
	import Triangulate,TetGen
	using PlutoUI
	
	# Add PDELib packages
	Pkg.add(name="GridVisualize",version="0.2")
	Pkg.add(name="ExtendableGrids",version="0.7")
	Pkg.add(name="SimplexGridFactory",version="0.5")    
   
	using SimplexGridFactory,GridVisualize,ExtendableGrids
end;

# ╔═╡ cc92dad8-0839-4ac3-924d-340cf6167ddc
begin
	# Ensure the right choice of PyPlot backend
    ENV["MPLBACKEND"]="agg"
	import PyPlot
	Pkg.add(name="PyPlot",version="2")	
	PyPlot.svg(true)
end;

# ╔═╡ 940b1996-fe9d-11ea-2fa4-8b72bee62b76
md"""
# Grid creation and visualization in PDELib.jl

This notebook shows how to perform grid creation and visualization with the assistance of the packages [ExtendableGrids.jl](https://github.com/j-fu/ExtendableGrids.jl) and [SimplexGridFactory.jl](https://github.com/j-fu/SimplexGridFactory.jl) which are part of the  [PDELib.jl](https://github.com/WIAS-BERLIN/PDElib.jl) meta package.

Visualization in this notebook is done using the [GridVisualize.jl](https://github.com/j-fu/GridVisualize.jl) package.
"""

# ╔═╡ a0fe8382-428a-41a5-94d5-c9c2e25a43e6
md"""
Import and use GLMakie as default plotter ? $(@bind import_glmakie CheckBox(default=false))

By default, this notebook uses PyPlot as plotting backend for GridVisualize.

GLMakie allows for faster, GPU accelerated plotting, but takes a rather long time to load unless it has been compiled into the Julia system image.
"""

# ╔═╡ 8bfd30a0-a0d4-4811-9871-f9f8fe58480a
if import_glmakie
	Pkg.add(name="GLMakie",version="0.2.9")
	import GLMakie
	default_plotter!(GLMakie)
else
	default_plotter!(PyPlot)
end	

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
gridplot(g1; resolution=(750,150),legend=:rt)

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
gridplot(g2; resolution=(750, 150),legend=:rt)

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
gridplot(simplexgrid(X2); resolution=(750,150),legend=:rt)

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
	vis=GridVisualizer(;resolution=(750,300),legend=:lt)
	
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

# ╔═╡ c9b658b0-ad0b-4a95-9a3d-b7762c36ce8d
builderplot(builder2,Plotter=PyPlot,resolution=(500,500))

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

# ╔═╡ 9735eba3-a51b-4870-8557-c3a2985b2297
md"""
__Testplot with input and output__
"""

# ╔═╡ 8f0bd5c0-f920-11ea-3b1c-db90fc95f990
builderplot(builder3,Plotter=PyPlot,resolution=(750,700))

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
### Plotting functions

Functions defined on the nodes of a triangular grid can be seen as piecewise linear functions from the P1 finite element space defined by the triangulation.
"""

# ╔═╡ bad736d7-875c-4bc0-9ec4-494a90a508f7
fsin2=map((x,y)-> sin(x)*y, grid2d2)

# ╔═╡ a375c23f-6b8c-4b2c-a8b5-d38e6b5a8f6d
fsin3=map((x,y)-> sin(y)*x, grid2d3)

# ╔═╡ c3ef9067-3cdb-4bfd-9406-6ded64539978
let
	vis=GridVisualizer(;resolution=(750,300), layout=(1,2))
	

	scalarplot!(vis[1,1], grid2d2, fsin2, label="grid2d2")
	
	scalarplot!(vis[1,2], grid2d3, fsin3, label="grid2d3",colormap=:spring,isolines=10)
	
	reveal(vis)
end

# ╔═╡ 2682df92-5955-4b17-ae4f-8e99c5b17980
md"""
## 3D Grids

### Tensor product grids

Please note that "masking" is not yet implemented.
Furthermore, PyPlot visualization is slow, with GLMakie it is way faster.
"""

# ╔═╡ 265fe6c7-d1cc-48a6-8295-f8f55acf677c
X3=range(0.,10,length=11)

# ╔═╡ b357395f-2a6e-476f-b008-02802c85a541
grid3d1=simplexgrid(X3,X3,X3)

# ╔═╡ af449be7-aab6-4de5-a059-3f8508502676
func3=map((x,y,z)-> sin(x/2)*cos(x/2)*z/10,grid3d1)

# ╔═╡ d73d18e7-bcf9-4cc1-9154-b70dc1ff5524
vis3=GridVisualizer(;layout=(1,2), resolution=(600,300))

# ╔═╡ 50f9331c-50fd-43bf-9b78-d500b0f72955
mean(x)=sum(x)/length(x);

# ╔═╡ a3844fda-5725-4d95-894b-051a5f6c2faa
md"""
f=$(@bind flevel Slider(range(extrema(func3)...,length=20),default=mean(func3),show_value=true))

x=$(@bind xplane Slider(X3[1]:0.1:X3[end],default=X3[end],show_value=true))

y=$(@bind yplane Slider(X3[1]:0.1:X3[end],default=X3[end],show_value=true))

z=$(@bind zplane Slider(X3[1]:0.1:X3[end],default=X3[end],show_value=true))

"""

# ╔═╡ 3b14e5ba-353d-45de-9851-8ddbf2c410a5
let
	
	gridplot!(vis3[1,1],grid3d1,zplane=zplane,yplane=yplane, xplane=xplane)
	scalarplot!(vis3[1,2],grid3d1, func3, zplane=zplane, yplane=yplane,xplane=xplane,flevel=flevel,colormap=:spring)
	reveal(vis3)
end

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
gridplot(grid3d2,zplane=0.1,azim=20,elev=20,linewidth=0.5)

# ╔═╡ a7965a6e-2e83-47eb-aee2-d366246a8637
html"""<hr>"""

# ╔═╡ 52157c99-61ad-4b98-a6ed-e5502553560c
Pkg.status()

# ╔═╡ 7ad541b1-f40f-4cdd-b7b5-b792a8e63d71
TableOfContents(depth=4)

# ╔═╡ Cell order:
# ╟─940b1996-fe9d-11ea-2fa4-8b72bee62b76
# ╠═d432ad64-f91f-11ea-2e48-4bc7472ac64c
# ╠═cc92dad8-0839-4ac3-924d-340cf6167ddc
# ╟─a0fe8382-428a-41a5-94d5-c9c2e25a43e6
# ╠═8bfd30a0-a0d4-4811-9871-f9f8fe58480a
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
# ╟─7d1698dd-3bb7-4b38-9c6d-a88652749eee
# ╠═81249f7c-abdf-43cc-b57f-2915b09da009
# ╟─0765641a-8ed9-4579-bd9b-90bb02a55792
# ╠═884a11a2-15cf-40fc-a1ca-66ea23c6094e
# ╟─8fbd238c-723e-4bce-af69-9cabfc03f8d9
# ╠═c9b658b0-ad0b-4a95-9a3d-b7762c36ce8d
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
# ╟─9735eba3-a51b-4870-8557-c3a2985b2297
# ╠═8f0bd5c0-f920-11ea-3b1c-db90fc95f990
# ╟─d2129483-285b-49a2-a11d-886956146b85
# ╠═ac93589b-6315-4677-9542-c0a2333f1755
# ╠═59a6c8b5-25aa-47aa-9489-a803672013df
# ╟─4c99c40f-cf93-4cba-bef1-0c4ffcbf6833
# ╠═bad736d7-875c-4bc0-9ec4-494a90a508f7
# ╠═a375c23f-6b8c-4b2c-a8b5-d38e6b5a8f6d
# ╠═c3ef9067-3cdb-4bfd-9406-6ded64539978
# ╟─2682df92-5955-4b17-ae4f-8e99c5b17980
# ╠═265fe6c7-d1cc-48a6-8295-f8f55acf677c
# ╠═b357395f-2a6e-476f-b008-02802c85a541
# ╠═af449be7-aab6-4de5-a059-3f8508502676
# ╠═d73d18e7-bcf9-4cc1-9154-b70dc1ff5524
# ╠═3b14e5ba-353d-45de-9851-8ddbf2c410a5
# ╟─a3844fda-5725-4d95-894b-051a5f6c2faa
# ╠═50f9331c-50fd-43bf-9b78-d500b0f72955
# ╟─6cad87eb-1c59-4000-b688-a6f6d41f9413
# ╠═fefc7587-8e25-4080-b934-90c0e1afc56a
# ╠═065735f7-c799-4284-bd59-fe6383bb987c
# ╠═329992a0-e352-468b-af8b-0b190315fc61
# ╟─a7965a6e-2e83-47eb-aee2-d366246a8637
# ╠═52157c99-61ad-4b98-a6ed-e5502553560c
# ╠═7ad541b1-f40f-4cdd-b7b5-b792a8e63d71
