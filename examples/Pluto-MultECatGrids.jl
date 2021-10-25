### A Pluto.jl notebook ###
# v0.16.3

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

# ╔═╡ 60941eaa-1aea-11eb-1277-97b991548781
begin 
    using PlutoUI
	using ExtendableGrids
	using SimplexGridFactory
	using PlutoVista
	using GridVisualize
	using Triangulate
	default_plotter!(PlutoVista)
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
ExtendableGrids = "~0.8.7"
GridVisualize = "~0.3.9"
PlutoUI = "~0.7.16"
PlutoVista = "~0.8.6"
SimplexGridFactory = "~0.5.9"
Triangulate = "~2.1.0"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.7.0-rc2"
manifest_format = "2.0"

[[deps.AbstractTrees]]
git-tree-sha1 = "03e0550477d86222521d254b741d470ba17ea0b5"
uuid = "1520ce14-60c1-5f80-bbc7-55ef81b5835c"
version = "0.3.4"

[[deps.Adapt]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "84918055d15b3114ede17ac6a7182f68870c16f7"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.3.1"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.ColorSchemes]]
deps = ["ColorTypes", "Colors", "FixedPointNumbers", "Random"]
git-tree-sha1 = "a851fec56cb73cfdf43762999ec72eff5b86882a"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.15.0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "024fe24d83e4a5bf5fc80501a314ce0d1aa35597"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.0"

[[deps.Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "417b0ed7b8b838aa6ca0a87aadf1bb9eb111ce40"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.8"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"

[[deps.DataAPI]]
git-tree-sha1 = "cc70b17275652eb47bc9e5f81635981f13cea5c8"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.9.0"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "a32185f5428d3986f47c2ab78b1f216d5e6cc96f"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.8.5"

[[deps.Downloads]]
deps = ["ArgTools", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"

[[deps.EarCut_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "3f3a2501fa7236e9b911e0f7a588c657e822bb6d"
uuid = "5ae413db-bbd1-5e63-b57d-d24a61df00f5"
version = "2.2.3+0"

[[deps.ElasticArrays]]
deps = ["Adapt"]
git-tree-sha1 = "a0fcc1bb3c9ceaf07e1d0529c9806ce94be6adf9"
uuid = "fdbdab4c-e67f-52f5-8c3f-e7b388dad3d4"
version = "1.2.9"

[[deps.ExtendableGrids]]
deps = ["AbstractTrees", "Dates", "DocStringExtensions", "ElasticArrays", "InteractiveUtils", "LinearAlgebra", "Printf", "Random", "SparseArrays", "Test"]
git-tree-sha1 = "1e8e50f054057f23e908fbd6935766dca6293cc2"
uuid = "cfc395e8-590f-11e8-1f13-43a2532b2fa8"
version = "0.8.7"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[deps.GeometryBasics]]
deps = ["EarCut_jll", "IterTools", "LinearAlgebra", "StaticArrays", "StructArrays", "Tables"]
git-tree-sha1 = "58bcdf5ebc057b085e58d95c138725628dd7453c"
uuid = "5c1252a2-5f33-56bf-86c9-59e7332b4326"
version = "0.4.1"

[[deps.GridVisualize]]
deps = ["ColorSchemes", "Colors", "DocStringExtensions", "ElasticArrays", "ExtendableGrids", "GeometryBasics", "LinearAlgebra", "Observables", "OrderedCollections", "PkgVersion", "Printf", "Requires", "StaticArrays"]
git-tree-sha1 = "925ba2f11df005d894b113292d32fca9afe3f8c8"
uuid = "5eed8a63-0fb0-45eb-886d-8d5a387d12b8"
version = "0.3.9"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[deps.HypertextLiteral]]
git-tree-sha1 = "5efcf53d798efede8fee5b2c8b09284be359bf24"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.2"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "f7be53659ab06ddc986428d3a9dcc95f6fa6705a"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.2"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.IterTools]]
git-tree-sha1 = "05110a2ab1fc5f932622ffea2a003221f4782c18"
uuid = "c8e1da08-722c-5040-9ed9-7db0dc04731e"
version = "1.3.0"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "642a199af8b68253517b80bd3bfd17eb4e84df6e"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.3.0"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "8076680b162ada2a031f707ac7b4953e30667a37"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.2"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"

[[deps.LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.LinearAlgebra]]
deps = ["Libdl", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"

[[deps.Observables]]
git-tree-sha1 = "fe29afdef3d0c4a8286128d4e45cc50621b1e43d"
uuid = "510215fc-4207-5dde-b226-833fc4488ee2"
version = "0.4.0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"

[[deps.OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[deps.Parsers]]
deps = ["Dates"]
git-tree-sha1 = "f19e978f81eca5fd7620650d7dbea58f825802ee"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.1.0"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"

[[deps.PkgVersion]]
deps = ["Pkg"]
git-tree-sha1 = "a7a7e1a88853564e551e4eba8650f8c38df79b37"
uuid = "eebad327-c553-4316-9ea0-9fa01ccd7688"
version = "0.1.1"

[[deps.PlutoUI]]
deps = ["Base64", "Dates", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "UUIDs"]
git-tree-sha1 = "4c8a7d080daca18545c56f1cac28710c362478f3"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.16"

[[deps.PlutoVista]]
deps = ["ColorSchemes", "Colors", "DocStringExtensions", "GridVisualize", "UUIDs"]
git-tree-sha1 = "34fc7e41e6eefa58fef0786ab62a20262df88764"
uuid = "646e1f28-b900-46d7-9d87-d554eb38a413"
version = "0.8.6"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "00cfd92944ca9c760982747e9a1d0d5d86ab1e5a"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.2.2"

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

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "4036a3bd08ac7e968e27c203d45f5fff15020621"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.1.3"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.SimplexGridFactory]]
deps = ["DocStringExtensions", "ElasticArrays", "ExtendableGrids", "GridVisualize", "LinearAlgebra", "Printf", "Test"]
git-tree-sha1 = "af52ec74a4b6cfcc5b6d60d259099fa0596de2c1"
uuid = "57bfcd06-606e-45d6-baf4-4ba06da0efd5"
version = "0.5.9"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.StaticArrays]]
deps = ["LinearAlgebra", "Random", "Statistics"]
git-tree-sha1 = "3c76dde64d03699e074ac02eb2e8ba8254d428da"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.2.13"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.StructArrays]]
deps = ["Adapt", "DataAPI", "StaticArrays", "Tables"]
git-tree-sha1 = "2ce41e0d042c60ecd131e9fb7154a3bfadbf50d3"
uuid = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
version = "0.6.3"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"

[[deps.TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[deps.Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "TableTraits", "Test"]
git-tree-sha1 = "fed34d0e71b91734bf0a7e10eb1bb05296ddbcd0"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.6.0"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.Triangle_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "bfdd9ef1004eb9d407af935a6f36a4e0af711369"
uuid = "5639c1d2-226c-5e70-8d55-b3095415a16a"
version = "1.6.1+0"

[[deps.Triangulate]]
deps = ["DocStringExtensions", "Libdl", "Printf", "Test", "Triangle_jll"]
git-tree-sha1 = "2b4f716b192c0c615d96d541ee029e85666388cb"
uuid = "f7e6ffb2-c36d-4f8f-a77e-16e897189344"
version = "2.1.0"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl", "OpenBLAS_jll"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
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
