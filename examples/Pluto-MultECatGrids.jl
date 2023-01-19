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

# ╔═╡ 60941eaa-1aea-11eb-1277-97b991548781
begin 
    using PlutoUI
	using ExtendableGrids
	using SimplexGridFactory
	using PlutoVista
	using GridVisualize
        using Triangulate
        isdefined(Main,:PlutoRunner) ? 	default_plotter!(PlutoVista) : default_plotter!(nothing) 
end

# ╔═╡ 07194f25-5735-452f-9bed-cf791958d44d
md"""
## Grid with quadratic boundary subregions at electrode
"""

# ╔═╡ d0f3483a-2bf4-4e2d-80b0-6c869b45cda8
function qxygrid(;nref=0,xymax=1.0,hxymin=0.1,hxymax=0.1)

Xp=geomspace(0,xymax,hxymin,hxymax)
Xm=-reverse(Xp)
X=glue(Xm,Xp)
gridxy=simplexgrid(X,X)
fill!(gridxy[BFaceRegions],5)
gridxy
end

# ╔═╡ fd8f6c48-0030-4f6f-9fbf-9f2340decbf2
g=qxygrid(hxymin=0.05, hxymax=0.2)

# ╔═╡ bbeeebc0-ae16-4022-975d-35588e62166a
gridplot(g)

# ╔═╡ e6c7e47d-6159-4bb6-a71d-7c633e2fefbd
function qxyzgrid(gridxy ;zmax=1.0,hzmin=0.05,hzmax=0.2)
	Z=geomspace(0,zmax,hzmin,hzmax)
	gridxyz=simplexgrid(gridxy,Z,top_offset=1)
	xymax=gridxy[Coordinates][1,end]

	bfacemask!(gridxyz,[-xymax,-xymax,0],[0,0,0],1)
    bfacemask!(gridxyz,[0,0,0],[xymax,xymax,0],2)
    bfacemask!(gridxyz,[0,-xymax,0],[xymax,0,0],3)
    bfacemask!(gridxyz,[-xymax,0,0],[0,xymax,0],4)
    gridxyz
end

# ╔═╡ 9800c97e-c25b-4d08-a014-cccd746f7d71
gxyz=qxyzgrid(g)

# ╔═╡ 9a219111-0275-4cd9-b97e-648d3fcfcbb9
vis=GridVisualizer(dim=3,resolution=(400,300));vis

# ╔═╡ 85be1677-87ff-49dc-af9a-557e575bc55f
@bind z Slider(0:0.01:1,show_value=true,default=0.5)

# ╔═╡ 33ecc78c-16ac-46ac-8d83-cbb26288a6fb
gridplot!(vis,gxyz,show=true,zplanes=[z],xplanes=[1],yplanes=[1],outlinealpha=0.3)

# ╔═╡ 9e640256-61a4-4fb9-a449-d5f948fb2d26
md"""
## Grid with inner circle at electrode
"""

# ╔═╡ bf0004f4-b3c8-4385-b87d-df2ef1420408
md"""
### Plain triangulation
"""

# ╔═╡ 1b70e44b-cbe8-4812-b267-ef9bce20a5b7
function cxygrid(;maxvol=0.01,nref=0,xyzmax=1,rad=0.5)
	builder=SimplexGridBuilder(Generator=Triangulate)

	
	regionpoint!(builder,(xyzmax-0.1,xyzmax-0.1))
	cellregion!(builder,1)
	rect2d!(builder,[-xyzmax,-xyzmax],[xyzmax,xyzmax],facetregions=1)
	
	
	facetregion!(builder,3)
	cellregion!(builder,2)
	regionpoint!(builder, (0,0))
	circle!(builder,(0,0), rad,n=20)
	simplexgrid(builder,maxvolume=maxvol)
end

# ╔═╡ 10ebaeab-3ece-480f-9c4d-a676814e2f7f
gcxy=cxygrid()

# ╔═╡ b711885e-cc61-4e08-9367-437731323863
gridplot(gcxy)

# ╔═╡ e4029d2c-18b7-4592-b47d-294e4af93497
gcxy.components

# ╔═╡ 0c3f5b1c-7bcf-491e-8318-73f2c880e0b5
function cxyzgrid(gcxy,zmax=1.0,hzmin=0.05,hzmax=0.2)
	Z=geomspace(0,zmax,hzmin,hzmax)
	gridxyz=simplexgrid(gcxy,Z,bot_offset=0)
	xymax=maximum(gcxy[Coordinates][1,:])

	bfacemask!(gridxyz,[-xymax,-xymax,zmax],[xymax,xymax,zmax],5,allow_new=false)
	gridxyz

end

# ╔═╡ f9130b5d-b4ea-4ebd-b73f-82a3c1bc1307
gcxyz=cxyzgrid(gcxy)

# ╔═╡ 73847699-40c0-4043-a16f-37883def6858
gcxyz.components

# ╔═╡ bff0a3f1-c545-4fcc-8be8-ef460f8479bd
visc=GridVisualizer(dim=3,resolution=(400,300))

# ╔═╡ 66ce2939-2957-43e0-b7ea-cdd10d9fc17e
@bind zc Slider(0:0.01:1,show_value=true,default=0.5)

# ╔═╡ a310027d-3f9e-4de5-bc9e-5457cb19eef5
gridplot!(visc,gcxyz,show=true,zplanes=[zc],xplanes=[1],yplanes=[1],outlinealpha=0.3)

# ╔═╡ 752bdb8f-de5a-4863-b2d1-53d69aff7dcb
md"""
### Grid with anisotropic local refinement at electrode
"""

# ╔═╡ 5aef30a0-8712-4c6c-9465-25da0624b408
function grxy(;nang=40,nxy=15, r=0.5, dr=0.1,hrmin=0.01,hrmax=0.05,xymax=1.0)
		rad1=geomspace(r-dr,r,hrmax,hrmin)
		rad2=geomspace(r,r+dr,hrmin,hrmax)
		ang=range(0,2π,length=nang)
		δr=2π*r/nang
	    maxvol=0.5*δr^2
		ring1=ringsector(rad1,ang)
		ring1[CellRegions].=1
		ring2=ringsector(rad2,ang)
		ring1[CellRegions].=2
		ring=glue(ring1,ring2,breg=3)
	
		binner=SimplexGridBuilder(Generator=Triangulate)
		regionpoint!(binner,(0,0))
		cellregion!(binner,2)
		
		facetregion!(binner,2)
		bregions!(binner,ring,[1])
		ginner=simplexgrid(binner,maxvolume=maxvol,nosteiner=true)
		ginner[CellRegions].=2
	
		bouter=SimplexGridBuilder(Generator=Triangulate)
	
		holepoint!(bouter,(0,0))
		
		facetregion!(bouter,3)
		bregions!(bouter,ring,[2])
	
	regionpoint!(bouter,(xymax-0.1,xymax-0.1))
	cellregion!(bouter,3)
	rect2d!(bouter,[-xymax,-xymax],[xymax,xymax],facetregions=1,nx=nxy,ny=nxy)
	
	gouter=simplexgrid(bouter;maxvolume=maxvol*2,nosteiner=true)
	
	glue(glue(gouter,ring),ginner)
	
end

# ╔═╡ 4debce38-96c5-4661-a965-1ca723fa8a36
rxygrid=grxy()

# ╔═╡ 52f4c693-0218-4f56-ac95-abd6d99a0b67
gridplot(rxygrid)

# ╔═╡ f43bd8ff-a2ed-4740-a61e-4f5d2c615c10
grxyz=cxyzgrid(rxygrid)

# ╔═╡ b9ced73f-e7a0-4573-9413-c2a231d21c78
  visr=GridVisualizer(dim=3,resolution=(400,300))

# ╔═╡ 2c285e4f-9f10-474b-9482-83a5c4cbfe09
@bind zr Slider(0:0.01:1,show_value=true,default=0.5)

# ╔═╡ 97d8db91-16e6-4070-81a0-7bcaff6cc9f6
gridplot!(visr,grxyz,show=true,zplanes=[zr],xplanes=[1],yplanes=[1],outlinealpha=0.3)

# ╔═╡ 78dba5b2-52c9-40cd-bc1d-d5c343271f97
html"""<hr> """

# ╔═╡ b9cc0359-7286-4c02-ba10-35303da26a50
TableOfContents()

# ╔═╡ 605c914d-607b-4d2e-80c5-d14cb6918e32
md"""
    begin
       using Pkg
       Pkg.activate(mktempdir())
       Pkg.add(["PlutoUI","Revise","Triangulate"])
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
Triangulate = "f7e6ffb2-c36d-4f8f-a77e-16e897189344"

[compat]
ExtendableGrids = "~0.9.16"
GridVisualize = "~0.6.1"
PlutoUI = "~0.7.16"
PlutoVista = "~0.8.6"
SimplexGridFactory = "~0.5.18"
Triangulate = "~2.2.0"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

manifest_format = "2.0"
project_hash = "ed5d0e039c16ed3dff8cdeb7be686be0cd3c7d3e"

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
# ╠═60941eaa-1aea-11eb-1277-97b991548781
# ╟─07194f25-5735-452f-9bed-cf791958d44d
# ╠═d0f3483a-2bf4-4e2d-80b0-6c869b45cda8
# ╠═fd8f6c48-0030-4f6f-9fbf-9f2340decbf2
# ╠═bbeeebc0-ae16-4022-975d-35588e62166a
# ╠═e6c7e47d-6159-4bb6-a71d-7c633e2fefbd
# ╠═9800c97e-c25b-4d08-a014-cccd746f7d71
# ╠═9a219111-0275-4cd9-b97e-648d3fcfcbb9
# ╠═85be1677-87ff-49dc-af9a-557e575bc55f
# ╠═33ecc78c-16ac-46ac-8d83-cbb26288a6fb
# ╟─9e640256-61a4-4fb9-a449-d5f948fb2d26
# ╟─bf0004f4-b3c8-4385-b87d-df2ef1420408
# ╠═1b70e44b-cbe8-4812-b267-ef9bce20a5b7
# ╠═10ebaeab-3ece-480f-9c4d-a676814e2f7f
# ╠═b711885e-cc61-4e08-9367-437731323863
# ╠═e4029d2c-18b7-4592-b47d-294e4af93497
# ╠═0c3f5b1c-7bcf-491e-8318-73f2c880e0b5
# ╠═f9130b5d-b4ea-4ebd-b73f-82a3c1bc1307
# ╠═73847699-40c0-4043-a16f-37883def6858
# ╠═bff0a3f1-c545-4fcc-8be8-ef460f8479bd
# ╠═66ce2939-2957-43e0-b7ea-cdd10d9fc17e
# ╠═a310027d-3f9e-4de5-bc9e-5457cb19eef5
# ╟─752bdb8f-de5a-4863-b2d1-53d69aff7dcb
# ╠═5aef30a0-8712-4c6c-9465-25da0624b408
# ╠═4debce38-96c5-4661-a965-1ca723fa8a36
# ╠═52f4c693-0218-4f56-ac95-abd6d99a0b67
# ╠═f43bd8ff-a2ed-4740-a61e-4f5d2c615c10
# ╠═b9ced73f-e7a0-4573-9413-c2a231d21c78
# ╠═2c285e4f-9f10-474b-9482-83a5c4cbfe09
# ╠═97d8db91-16e6-4070-81a0-7bcaff6cc9f6
# ╟─78dba5b2-52c9-40cd-bc1d-d5c343271f97
# ╠═b9cc0359-7286-4c02-ba10-35303da26a50
# ╠═605c914d-607b-4d2e-80c5-d14cb6918e32
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
