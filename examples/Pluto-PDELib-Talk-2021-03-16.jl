### A Pluto.jl notebook ###
# v0.17.1

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

# ╔═╡ d05f97e2-85ba-11eb-06ea-c933332c0630
using ForwardDiff

# ╔═╡ 092e6940-8598-11eb-335d-9fd32dadd468
begin
	using VoronoiFVM      # the finite volume solver
	using ExtendableGrids # grid management
	using GridVisualize   # visualization on grids
end

# ╔═╡ cf503e46-85bb-11eb-2ae7-e959707a01a9
using DifferentialEquations

# ╔═╡ 134530ae-85c2-11eb-1556-a3aa72624a7a
begin
 using SimplexGridFactory
 using Triangulate
 using GradientRobustMultiPhysics
end

# ╔═╡ e44bb844-85cc-11eb-05c9-cdaaa914d6c1
begin 
	using LinearAlgebra
	using Printf
	ENV["LC_NUMERIC"]="C"   # This is needed for triangle
    ENV["MPLBACKEND"]="agg" # Ensure pyplot has the right backend for pluto on mac
    using PlutoUI
	using AbstractTrees
	using PyPlot

 	
	using AbstractTrees, PyPlot,PlutoUI
	AbstractTrees.children(x::Type) = subtypes(x) # Enable AbstractTrees to show typet trees

	PyPlot.svg(true) # Choose svg driver for pyplot
end;

# ╔═╡ b7d13a60-8370-11eb-3a14-1df66337bc34
md"""
# PDELib.jl

### Towards software components for the numerical solution of partial differential equations in Julia

### J. Fuhrmann, Ch. Merdon, T. Streckenbach

$(Resource("https://www.wias-berlin.de/layout3/img/logo-tablet.png")) 

#### WIAS Berlin, 2021-03-16

Update 2021-11-18: switch to Pluto's built-in package manager
"""

# ╔═╡ 6c221d04-863c-11eb-0bf8-41f7a6288b66
md"""
## pdelib
"""

# ╔═╡ 68847d40-863c-11eb-18d3-e1060d831230
html"""<iframe src="https://www.wias-berlin.de/software/index.jsp?lang=1&id=pdelib" width=600 height=200) </iframe>"""

# ╔═╡ b0581c08-863c-11eb-0d81-d59ac5f24479
md"""
- Thanks to: Timo Streckenbach, Hartmut Langmach, Manfred Uhle, Hang Si, Klaus Gärtner, Thomas Koprucki, Matthias Liero, Hong Zhao, Jaques Bloch, Ulrich Wilbrandt and many others who contributed code and/or ideas to the core code
- Attempt to have a flexible toolbox for working with PDEs in research and applications
- Some applications based on pdelib: Semiconductors (ddfermi), Electrochemistry, Steel manufacturing (with RG4), Pressure robust FEM 
   - Patrico Farrell, Markus Kantner, Duy Hai Doan, Thomas Petzold, Alexander Linke, Christian Merdon ... 
- Main languages: C++, Python, Lua
"""

# ╔═╡ 0d1ef53a-85c8-11eb-13ef-952df60b51b0
md"""
# Why Julia?
"""

# ╔═╡ 174e53bc-863f-11eb-169d-2fe8a9b2adfb
md"""
... BTW thanks to Alexander Linke for keeping his (and my) eye on Julia
"""

# ╔═╡ d2f59d32-863a-11eb-2ffe-37e8d2a06d27
md"""
## The two-language problem



- Efficient computational cores in compiled languages (Fortran,C, C++)
- Embedded into scripting languages (Python, Lua)
    - Support of pre- and postprocessing
    - "Glueing" together different algoritms

- Hard to explain and to maintain ⇒ preference for commercial tools (Matlab, Comsol, ... ) outside of core scientifc computing research

- __Julia__ attempts to bridge this gap: write code like in python or matlab which nevertheless performs like code from compiled languages
"""

# ╔═╡ 7cb4be3c-8372-11eb-17cc-ad4f68a34e72
md"""
## Julia homepage [http://www.julialang.org](http://www.julialang.org)
"""

# ╔═╡ 3a462e56-8371-11eb-0503-bf8ebd33276b
html"""<iframe src="https://www.julialang.org" width=650 height=300></iframe>"""

# ╔═╡ 00bcd2be-8373-11eb-368e-61b2cdc2ab74
md"""
## Some general points
- Multidimensional arrays as first class objects
- Extensive library of standard functions, linear algebra operations
- Easy Interfacing to C, Python, R $\dots$
- Build and distribution system for binary code for Linux, Windows, MacOS
- Interactive Read-Eval-Print-Loop (REPL)
- Integration with Visual Studio Code editor
- Notebook functionality: Jupyter, Pluto
    - This talk's slides are a Pluto notebook
"""

# ╔═╡ d0c8331e-840b-11eb-249b-5bba159d0d60
md"""
## Julia packages
"""

# ╔═╡ 3b05b78a-83e9-11eb-3d9e-8dda5fb67594
md"""
- Packages provide functionality  which is not part of the core Julia installation
- Each package is a git repository containing
    - Prescribed subdirectory structure (`src`,`doc`,`test`) 
    - Metadata  on package and dependencies (`Project.toml`)
    - ⇒ No julia package without version management 
- Packages can be registered in package registries which are themselves git  repositories containing metadata of registered packages.
    - By default, a  [General Registry](https://github.com/JuliaRegistries/General) is used 
    - Additonal project specific registries can be added to a Julia installation
   
"""

# ╔═╡ 151c3696-840e-11eb-0cd6-d91971fcf502
md"""
## $(Resource("https://julialang.github.io/Pkg.jl/v1/assets/logo.png", :width=>150, :style => "vertical-align:middle"))  Package manager

- For installing (adding) or removing packages, Julia has a package manager `Pkg` which is integrated  into the core language
- Fine grained package version management supports reproducible research
- UPDATE 2021-11-18: Pluto notebooks like this one have their own package managenment aimed at reproducibility. 
"""

# ╔═╡ 5062ea76-83e9-11eb-26ad-cb5cb7746014
md"""
## CI (Continuous integration)
- Julia provides integrated unit testing facilities
- It is seen as good style to have package unit tests covering as much of the code as possible
- Github Actions or Gitlab Runner can be used to trigger unit tests for all major operating systems on every commit 
"""

# ╔═╡ 0d9b6474-85e8-11eb-24a1-e7c037afb546
html"""<p style="text-align:center"> <img src="https://avatars.githubusercontent.com/u/44036562?s=200&v=4" height=150>
<img src="https://geontech.com/wp-content/uploads/2017/08/runner_logo.png" height=150 ></p>
"""

# ╔═╡ 47127b3a-83e9-11eb-22cf-9904b800edeb
md"""
## $(Resource("https://juliadocs.github.io/Documenter.jl/stable/assets/logo.svg",:height=> 100, :style=>"vertical-align: middle;"))Documentation
- Docstrings document Julia code
- They can be inquired by interactive help facilities (`@doc` macro, `?` mode in REPL)
- During CI runs, automatic documentation generation via `Documenter.jl` puts them together into documentation pages served from `github.io`
"""

# ╔═╡ 2f1894e0-842c-11eb-2489-ab7cbaa2fe68
html"""<iframe src="https://juliadocs.github.io/Documenter.jl/stable/" width=650 height=250></iframe>"""

# ╔═╡ 86f5e288-85b4-11eb-133e-25e1fbe363da
md"""
## Just-In-Time compilation

- Julia has high level syntax comparable to Python or Matlab, but has been developed from scratch in order to integrate Just-In-Time compilation (JIT)  into every of its aspects.
- JIT compilation turns source code into machine code when executing a function the first time
- JIT compilation can be sometimes time consuming, so in many cases one encounters a "JIT-lag" during the first run of an instance of code
"""

# ╔═╡ 5dd7b7b6-8634-11eb-37d0-f13485dca6a0
md"""$(Resource("https://wias-berlin.de/people/fuhrmann/blobs/julia_introspect.png",:height=>300)) (c) D. Robinson 
"""

# ╔═╡ 568527e0-8374-11eb-17b8-7d100bbd8e37
md"""
## Multiple Dispatch

- Aka "Generic Lambdas" in C++-Speak 
- Define a function and its derivative:
"""

# ╔═╡ 045e2078-8641-11eb-188f-a98971dc8155
md"""
- In Julia, methods are attached to functions instead of classes
  - in C++ speak, a Julia method is a specialization of template code for a particular template parameter
- The type of the return value is determined by the type of the input:
"""

# ╔═╡ 8773d184-8375-11eb-0e52-53c2df5dff93
md"""
## Machine code generated by JIT
"""

# ╔═╡ caf52886-8375-11eb-3cf8-a949cf8a3a25
md"""
## Multiple Dispatch: Discussion
- Multiple dispatch allows the JIT compiler to generate optimized machine code tailored to the particular combination of parameter types
- This comes with a price tag: dispatching at compile time influences the performance of the compilation process
- Akin to compiling template heavy C++ code

$(Resource("https://imgs.xkcd.com/xk3d/303/compiling.png",:width=>300)) 
(from xkcd)

Are there other advantages than performance after the first function call?
"""

# ╔═╡ f7f2cb36-8375-11eb-0c40-c5063c068bef
md"""
## Dual numbers
- Complex numbers $\mathbb C$: extend the real numbers $\mathbb R$ based on the introduction of $i$ with $i^2=-1$.

- Dual numbers: extend the real numbers by formally adding a number $\varepsilon$ with $\varepsilon^2=0$:

$D= \{ a + b\varepsilon \; |\; a,b \in \mathbb R\} =
    \left\{  \begin{pmatrix}
        a & b \\
        0 & a
      \end{pmatrix} \; |\; a,b\in\mathbb R \right\}\subset \mathbb R^{2\times 2}$


- Evaluating polynomials on dual numbers: Let $p(x)=\sum_{i=0}^n p_i x^i$. Then 

$\begin{align*}
      p(a+b\varepsilon) &= \sum_{i=0}^n p_i a^i + \sum_{i=1}^n i p_i  a^{i-1} b\varepsilon
                        = p(a)+bp'(a)\varepsilon
\end{align*}$

- ``\Rightarrow`` forward mode automatic differentiation

So let us have this in Julia! But before, have some glance on Julia's type system...
"""

# ╔═╡ 9507b252-837a-11eb-332e-117ceb07cf2b
md"""
## The Julia type system
- Julia is a strongly typed language, information about the layout of a value in memory is encoded in its type
- Concrete types:
   - Every value in Julia has a concrete type
   - Concrete types correspond to computer representations of objects
- Abstract types
   - Abstract types label concepts which work for  several concrete types without regard to their memory layout etc.
   - The functionality of an abstract type is implicitely characterized  by the methods working on it
- Types can have subtypes, e.g. `Int64<:Real` says that the concrete type `Float64`  (possibly through several hierarchy steps) is a subtype of `Real`. 
- Julia types form a tree, with concrete types as leaves

"""

# ╔═╡ 5d5cef6a-85ba-11eb-263e-0dcbcb148ac0
md"""
## Type tree emanating from `Number`
"""

# ╔═╡ 6fb193dc-837b-11eb-0380-3136d173692b
Tree(Number)

# ╔═╡ 69e51df4-8379-11eb-12c6-93e6d605be60
md"""
## A custom dual number type

[Nathan Krislock](https://julialang.zulipchat.com/#narrow/stream/225542-helpdesk/topic/Comparing.20julia.20and.20numpy/near/209143302) provided a simple dual number arithmetic example in Julia. 

- Define a struct parametrized with type T. This is akin a template class in C++
- The type shall work with all methods working with `Number`
- In order to construct a Dual number from arguments of different types, allow promotion aka "parameter type homogenization"
"""

# ╔═╡ b7872370-8376-11eb-0abb-5ba2ba60697f
begin
    struct DualNumber{T} <: Number where {T <: Real}
	  value::T
      deriv::T  
    end
    DualNumber(v,d) = DualNumber(promote(v,d)...)
end;

# ╔═╡ ccbd1974-8642-11eb-39db-212dcf3821fc
md"""
In c++ we would write something along
````
template <typename T> class DualNumber {
        T value;
        T deriv;};
````
"""

# ╔═╡ bd938738-8379-11eb-2e7b-3521b0c4d225
DualNumber(3,2.0)

# ╔═╡ 192ee390-8379-11eb-1666-9bd411478d4d
md"""
## Promotion and Conversion
- Promote a pair of `DualNumber{T}` and `Real` number to `DualNumber{T}` if needed
- This is a function on types !
- Julia functions can have multiple methods. Here, we add another method to the function `promote_rule`:
"""


# ╔═╡ 04d59916-8379-11eb-0c09-d91190563a84
Base.promote_rule(::Type{DualNumber{T}}, ::Type{<:Real}) where T<:Real = DualNumber{T}

# ╔═╡ 3e02d072-837a-11eb-2838-259e4228d577
md"""
- Define a way to convert a `Real` to `DualNumber`
"""

# ╔═╡ e134f5a6-8378-11eb-0766-657ab2915de3
Base.convert(::Type{DualNumber{T}}, x::Real) where T<:Real = DualNumber(x,zero(T))

# ╔═╡ 9eae6a52-837b-11eb-1f08-ff6a44398858
md"""
## Simple arithmetic for `DualNumber`
"""

# ╔═╡ 518b68fe-8643-11eb-3243-719110f74026
md"""
All these definitions add methods to the functions `+, /, *, -, inv` which allow them to work for `DualNumber`
"""

# ╔═╡ 544c6a08-81dd-11eb-301f-df0c8194d88f
begin
    import Base: +, /, *, -, inv
    +(x::DualNumber, y::DualNumber) = DualNumber(x.value + y.value, x.deriv + y.deriv)

    -(y::DualNumber) = DualNumber(-y.value, -y.deriv)

    -(x::DualNumber, y::DualNumber) = x + -y

    *(x::DualNumber, y::DualNumber) = DualNumber(x.value*y.value, x.value*y.deriv + x.deriv*y.value)

    inv(y::DualNumber{T}) where T<:Union{Integer, Rational} = DualNumber(1//y.value, (-y.deriv)//y.value^2)

    inv(y::DualNumber{T}) where T<:Union{AbstractFloat,AbstractIrrational} = DualNumber(1/y.value, (-y.deriv)/y.value^2)

    /(x::DualNumber, y::DualNumber) = x*inv(y)
end;

# ╔═╡ c42de0a2-8374-11eb-2bf2-e11a848bf099
p(x) = x^3 + 2x^2 + 2x + 1

# ╔═╡ 8aa0565e-85cd-11eb-32de-739cf53f6419
p(3//1)

# ╔═╡ ebf09b36-8374-11eb-06a5-f3baec9932c2
with_terminal() do
	@code_native p(3)
end

# ╔═╡ 296637fc-8376-11eb-0fef-050bf60bb7ff
dp(x) = 3x^2 + 4x + 2 

# ╔═╡ 92e1351e-837c-11eb-3b02-33ccb80a48d8
md"""
## Test the implementation

Compare the evaluation of the polynomial `p` and its derivative `dp` on a value `x` with the evaluation of `p` with `DuallNumber(x,1)`.
"""

# ╔═╡ 63e18f7a-837c-11eb-0285-b76ef6d38a1f
x=14//3

# ╔═╡ 549161a6-81df-11eb-2de0-f5629bcd3005
p(x), dp(x), p(DualNumber(x,1))

# ╔═╡ 563e9540-840d-11eb-2a8b-5fca30564841
md"""
## ForwardDiff.jl
"""

# ╔═╡ bfe00216-81e7-11eb-16a1-3f1436253097
md"""
This was of course a toy example. For more serious work, we can use the  `Dual` type from the [ForwardDiff.jl](https://github.com/JuliaDiff/ForwardDiff.jl) package. This also works for standard functions and for partial derivatives.
"""

# ╔═╡ 244e9f36-837e-11eb-1a02-a1989909f58f
p(x),dp(x), p(ForwardDiff.Dual(x,1))

# ╔═╡ 255b62e0-8380-11eb-1c58-7fb1c067f0e5
md"""
## A simple Newton solver
"""

# ╔═╡ ff99425c-837f-11eb-2217-e54e40a5a314
function newton(A,b,u0; tol=1.0e-12, maxit=100)
	# Define storage place for the result of function + Jacobian
    result=DiffResults.JacobianResult(u0)
	history=Float64[]
    u=copy(u0)
    it=1
    while it<maxit
		# This call evaluates both function and jacobian at once
        ForwardDiff.jacobian!(result,(v)->A(v)-b ,u)
        res=DiffResults.value(result)
        jac=DiffResults.jacobian(result)
		
		# Solve the Jacobian linear system
        h=jac\res
        u-=h
        nm=norm(h)
		push!(history,nm)

		if nm<tol
            return u,history
        end

		it=it+1
    end
    throw("convergence failed")
end


# ╔═╡ 1fc5d0ee-85bb-11eb-25d8-69151e6dafc2
md"""
## Test the Newton solver
"""

# ╔═╡ 5ab844b2-8380-11eb-3eff-f562f445b06f
A(x)= [  x[1]+exp(x[1])+3*x[2]*x[3], 
		 0.1*x[2]+x[2]^5-3*x[1]-x[3], 
		 x[3]^5+x[1]*x[2]*x[3]
]

# ╔═╡ 8214acb2-8380-11eb-2d24-1bef38c4e1da
b=[0.3,0.1,0.2];

# ╔═╡ 919677d6-8380-11eb-3e1c-152fea8b92ec
result, history=newton(A,b,ones(3))

# ╔═╡ c41db0b8-8380-11eb-14cc-71af2cd90a9f
A(result)-b

# ╔═╡ 71e783ea-8381-11eb-3eaa-5142de7bbd68
md"""
# I WANT THIS FOR THE SOLUTION OF NONLINEAR PDES!!!
"""

# ╔═╡ d39e6472-8594-11eb-07d6-8961306a6a44
md""

# ╔═╡ d6076ec0-8594-11eb-154d-1dc03499315f
md""

# ╔═╡ dc76902a-85c8-11eb-24a5-5b456ad625d9
md"""
# VoronoiFVM.jl
"""

# ╔═╡ eedfd550-85cd-11eb-1bbf-4daf6fc4d019
html"""<iframe src="https://j-fu.github.io/VoronoiFVM.jl/stable/" width=650 height=400> </iframe>"""

# ╔═╡ 5e0307a2-85be-11eb-2295-3d1f2b01256b
md"""
## The Voronoi Finite Volume Method
$(Resource("https://j-fu.github.io/VoronoiFVM.jl/stable/trivoro.png",:width=>300))
$(Resource("https://j-fu.github.io/VoronoiFVM.jl/stable/vor.png",:width=>300))
"""

# ╔═╡ d0e82116-85bf-11eb-1580-c5cb1efc1ba1
md"""
- __Continuous:__ $n$ coupled PDEs in $\Omega\subset \mathbb R^d$ for unknown $\mathbf  u(\vec x,t)=(u^1(\vec x,t)\dots u^n(\vec x,t))$

$$\partial_t \mathbf s(\mathbf  u) - \nabla \cdot \mathbf j(\mathbf  u, \nabla \mathbf  u) + \mathbf r(\mathbf  u) =0$$

"Storage" $\mathbf s(\mathbf  u)$, "Reaction" $\mathbf r(\mathbf  u)$, "Flux"  $\mathbf j(\mathbf  u, \nabla \mathbf  u)$

- __Discretized:__

$$|\omega_k|\frac{s(\mathbf  u_k)-\mathbf s(\mathbf  u^{\text{old}}_k)}{\Delta t}\\  + \sum_{\omega_l  \text{neigbour of} \omega_k} |\omega_k\cap\omega_l| \mathbf g(\mathbf  u_k , \mathbf  u_l) + |\omega_k|\mathbf r(\mathbf  u_k)=0$$

"Storage" $\mathbf s(\mathbf u_k)$,  "Reaction" $\mathbf r(\mathbf  u_k)$, inter-REV flux $\mathbf g(\mathbf  u_k, \mathbf  u_L)$ ⇒ Software API
""" 

# ╔═╡ b1d732c0-8381-11eb-0d91-eb04784ec1cb
md"""
## Some features of  VoronoiFVM.jl
- Use automatic differentiation (AD) to calculate Jacobi matrices for Newton's method from the describing functions $\mathbf r(), \mathbf g(), \mathbf s()$
- AD is applied at the local level -- on grid nodes and grid edges
- `ExtendableSparse.jl` package allows for efficient value insertion into sparse matrices during assembly into the global matrix


Let us add the package to the environment of this notebook:
"""

# ╔═╡ 62cc9dea-8382-11eb-0552-f3858008c864
md"""
## Example: porous medium equation
```math
\partial_t u -\Delta u^m = 0
```
in $\Omega=(-1,1)$ with homogeneous Neumann boundary conditons. I has an exact solution, the so-called Barenblatt solution.

The Barenblatt solution is an exact solution of this problem  for m>1. It has a finite support.
"""

# ╔═╡ be46f34a-8383-11eb-2972-87f7ef807ebe
function barenblatt(x,t,m)
    t1=t^(-1.0/(m+1.0))
    x1=1- (x*t1)^2*(m-1)/(2.0*m*(m+1))
   	x1<0.0 ? 0.0 : t1*x1^(1.0/(m-1.0))
end;

# ╔═╡ 488377d4-8593-11eb-2f16-1b031f62537b
md"""
We use the exact solution for $t=t_0=0.001$ as initial value.
"""

# ╔═╡ ad3a5aac-8382-11eb-140b-c10660fd8c61
md"""
## Define problem in VoronoiFVM.jl
"""

# ╔═╡ 99ce60fa-85e2-11eb-29af-a5f0feb65191
md"""
The problem has one species, set its number:
"""

# ╔═╡ ae80e57c-85e2-11eb-1297-3b0219a7af3b
iu=1;

# ╔═╡ 89607c62-85e2-11eb-25b7-8b5cb4771d02
md"""
Flux between two neigboring control volumes. Just use the finite differences in $u^m$.
"""

# ╔═╡ dca25088-8382-11eb-0584-399677021678
md"""
"Storage" is the function under the time derivative.
"""

# ╔═╡ d2bfa708-8382-11eb-3bab-07447ecb4adb
pmstorage(f,u,node)=f[1]=u[1];

# ╔═╡ 7b954d3c-8593-11eb-0cfc-2b1a0e51d6e6
md"""
## Implicit Euler in VoronoiFVM
"""

# ╔═╡ 01415fe2-8644-11eb-1fad-51fc9957aea8
md"""
## DifferentialEquations.jl
"""

# ╔═╡ 1a6fbeb4-8644-11eb-00d9-832a003ccd4b
 html"""<iframe src="https://diffeq.sciml.ai/stable/" width=650 height=300></iframe>"""

# ╔═╡ 61666f48-8644-11eb-36a6-35129059c0fd
md"""
Can we use this package for the transient solution based on the method of lines ? This could open pathways e.g. to access Machine Learning with PDEs...
"""

# ╔═╡ 79a8c4a4-8593-11eb-0e16-99a6cff3040e
md"""
## Solver using DifferentialEquations.jl
"""

# ╔═╡ ffd27a44-8385-11eb-150e-2f9a8bc48ec7
function plotsol(sol,X)
        f=sol[1,:,:]'
		fmax=maximum(sol[1,:,1])
	    rnge=range(0,fmax,length=11)
		contourf(X,sol.t,f,rnge,cmap=:summer)
        contour(X,sol.t,f,rnge,colors=:black)
	    xlabel("x")
	    ylabel("t")
end;

# ╔═╡ c7cf0430-85bc-11eb-1527-b152703c025c
md"""
## Compare solutions
"""

# ╔═╡ 099134de-85be-11eb-2aed-812180c08921
diffeq_solver=DifferentialEquations.Rosenbrock23();

# ╔═╡ 528624f4-85c3-11eb-1579-cb4852b9904b
m=2; n=20;

# ╔═╡ 07923cf2-85c9-11eb-0563-3b29940f50bb
let 
	fig=PyPlot.figure(1)
	clf()	
	X=collect(range(-1,1,length=500))
	for t in [0.001,0.002, 0.004, 0.008, 0.01]
	   PyPlot.plot(X,map( (x) -> barenblatt(x,t,m),X),label="t=$(t)")
	end 
	PyPlot.legend()
	PyPlot.grid()
	fig.set_size_inches(6,1.5)
	fig
end

# ╔═╡ 9c94a022-8382-11eb-38ad-adc4d894e517
function pmflux(f,u0,edge)
        u=unknowns(edge,u0)
        f[iu]=u[iu,1]^m-u[iu,2]^m
end;

# ╔═╡ 845f6460-8382-11eb-21b0-b7082bdd66e3
function create_porous_medium_problem(n,m)
    X=collect(range(-1,1,length=n))
	grid=simplexgrid(X)
    physics=VoronoiFVM.Physics(flux=pmflux,storage=pmstorage,num_species=1)
    sys=VoronoiFVM.System(grid,physics)
    enable_species!(sys,iu,[1])
    sys,X
end;

# ╔═╡ 5c82b6bc-8383-11eb-192e-71e5336e0425
function solve_vfvm(;n=20,m=2,t0=0.001, tend=0.01,tstep=1.0e-7)
   	sys,X=create_porous_medium_problem(n,m)
    inival=unknowns(sys)

	inival[1,:].=map(x->barenblatt(x,t0,m),sys.grid)

	control=VoronoiFVM.NewtonControl()
    control.Δt=tstep 
    control.Δu_opt=0.05
    control.Δt_min=tstep
    control.tol_relative=1.0e-5

    t_elapsed=@elapsed sol=VoronoiFVM.solve(inival,sys,[t0,tend],control=control)

	err=norm(sol[1,:,end]-map(x->barenblatt(x,tend,m),sys.grid),Inf)
    sol,X,err,t_elapsed
end

# ╔═╡ d84c89de-8384-11eb-28aa-132d56751734
function solve_diffeq(;n=20,m=2, t0=0.001,tend=0.01,solver=nothing)
    sys,X=create_porous_medium_problem(n,m)
    inival=unknowns(sys)
    inival[1,:].=map(x->barenblatt(x,t0,m),sys.grid)
   
	tspan = (t0,tend)
	
    t_elapsed=@elapsed	begin
      f = DifferentialEquations.ODEFunction( VoronoiFVM.eval_rhs!,
                             jac=            VoronoiFVM.eval_jacobian!,
                             jac_prototype = VoronoiFVM.jac_prototype(sys),
                             mass_matrix=    VoronoiFVM.mass_matrix(sys))
    
      prob = DifferentialEquations.ODEProblem(f,vec(inival),tspan,sys)
	  sol =  DifferentialEquations.solve(prob,solver)

      sol = TransientSolution([reshape(sol.u[i],sys) for i=1:length(sol.u)] ,sol.t)
	end
	err=norm(sol[1,:,end]-map(x->barenblatt(x,tend,m),sys.grid),Inf)
    sol,X,err,t_elapsed
end


# ╔═╡ 52fc31d1-d41b-410d-bb07-17b991d34f05
md"""
UPDATE: timing from the first click on solve will include JIT compilation. Try to run the code a second time to see computation time.
"""

# ╔═╡ c06c99c8-85bc-11eb-29b5-694d7fab6673
md"""
Solve: $(@bind solve_pm CheckBox())
"""

# ╔═╡ 3aed6f3c-85be-11eb-30ae-6170b11fc0a1
if solve_pm
	sol_vfvm,X_vfvm,err_vfvm,t_vfvm=solve_vfvm(m=m,n=n)
end;

# ╔═╡ 20fc42e6-8385-11eb-1b8d-c70dcb798cff
if solve_pm
   sol_diffeq,X_diffeq,err_diffeq,t_diffeq=solve_diffeq(m=m,n=n,solver=diffeq_solver)
end;

# ╔═╡ 0c0a4210-8386-11eb-08a2-ff3625833da3
if solve_pm
    clf()

    subplot(121)
    
    title(@sprintf("VoronoiFVM\n %.0f ms\n err=%.2e",t_vfvm*1000,err_vfvm))
    plotsol(sol_vfvm,X_vfvm)
    
    subplot(122)
    plotsol(sol_diffeq,X_diffeq)
    title(@sprintf("DifferentialEquations\n %.0f ms\n err=%.2e",t_diffeq*1000,err_diffeq))
    
	tight_layout()
    gcf().set_size_inches(7,3.5)
    gcf()

end

# ╔═╡ 51a150ee-8388-11eb-33e2-fb03cf4c0c76
md"""
## More VoronoiFVM.jl features
- 1/2/3D grids
- Multispecies handling  for subdomains, interfaces
- Testfunction based current calculation for implicit Euler metod
- Small signal analysis in frequency domain (impedance spectroscopy); automatic linearization comes here in handy as well

Currently used for:

- Solid oxide cell simulation (EDLSOC project with P. Vágner, V. Miloš)
- Semiconductor and Perovskite modeling in LG5 (Successor of C++- ddfermi, with P. Farell, D. Abdel)
- Investigation of finite volume discretizations with B. Gaudeul
- Rotating disk electrode calculations (With R. Kehl, LuCaMag project)
- Nanopores with P. Berg
"""

# ╔═╡ be8470e0-8594-11eb-2d55-657b74d82ccb
md""

# ╔═╡ 50602f28-85da-11eb-1f03-5d33ec4ee42e
md"""
# GradientRobustMultiphysics.jl
"""

# ╔═╡ 913c1c76-8645-11eb-24b6-47bc88ad6f5d
md"""
- Started by Ch. Merdon based on the same package infrastructure for grid management, sparse matrix assembly and visualization 
"""

# ╔═╡ da9158d6-85ce-11eb-3494-6bbd1b790284
 html"""<iframe src="https://chmerdon.github.io/GradientRobustMultiPhysics.jl/stable/pdedescription/" width=650 height=300> </iframe>"""

# ╔═╡ 4563f38a-8389-11eb-0596-81019d2948c8
md"""
## GradientRobustMultiPhysics.jl features

- Low order H1,Hdiv,Hcurl FEM in 1D/2D/3D on simplices and parallelograms

- Standard interpolations that satisfy commutating diagram ``\mathrm{Curl} (I_{Hcurl}\; v) = I_{Hdiv} \mathrm{Curl}\; v``

-  AD for shape function derivatives up to 2nd order on reference geometry

- user provides weak formulation by combining assembly patterns (bilinearform, linearform, trilinearform etc.) and function operators for their arguments and a kernel function for further manipulation (like application of parameters) + boundary data

- AD for kernels (like (u grad)u for NSE or (1+grad(u))*C*eps(u) for nonlinear elasticity) 

- divergence-preserving reconstruction operators as a function operator

- adaptive mesh refinement in 2D available

"""

# ╔═╡ b6dacce0-838c-11eb-18ca-fd4e85901bde
md"""
## Define grid for Karman vortex street
"""

# ╔═╡ f9479696-838a-11eb-22cd-13f069f2dc9a
function make_grid(L,H; n=20,maxvol=0.1)
	builder=SimplexGridBuilder(Generator=Triangulate)
    function circlehole!(builder, center, radius; n=20)
        points=[point!(builder, center[1]+radius*sin(t),center[2]+radius*cos(t)) 
				for t in range(0,2π,length=n)]
        for i=1:n-1
            facet!(builder,points[i],points[i+1])
        end
        facet!(builder,points[end],points[1])
        holepoint!(builder,center)
    end
    p1=point!(builder,0,0)
    p2=point!(builder,L,0)
    p3=point!(builder,L,H)
    p4=point!(builder,0,H)
    
    facetregion!(builder,1); facet!(builder,p1,p2)
    facetregion!(builder,2); facet!(builder,p2,p3)
	facetregion!(builder,3); facet!(builder,p3,p4)
	facetregion!(builder,4); facet!(builder,p4,p1)

	facetregion!(builder,5); circlehole!(builder, (0.25,H/2),0.05,n=20)
	simplexgrid(builder,maxvolume=maxvol)
end;

# ╔═╡ f95fed4c-85c2-11eb-2b76-a94551adbec1
md"""
## The grid
"""

# ╔═╡ 87dca836-85b3-11eb-1d28-73c08f594823
L=2.2; H=0.41;

# ╔═╡ b272ebcc-85c3-11eb-1fad-bf71ffde1a6c
md"""
## Constitutive functions
"""

# ╔═╡ f6a6c162-b795-46e3-9229-ecad67836fb3
md"""
UPDATE: The API of GradientRobustMultiPhysics changed since the time of the talk.
"""

# ╔═╡ 05910082-85c4-11eb-2bd2-556c9e2c1975
md"""
Inlet data for Karman vortex street example:
"""

# ╔═╡ f572f800-8388-11eb-2774-95a3ff9a3ad6
function bnd_inlet!(result,x)
    result[1] = 6*x[2]*(H-x[2])/H^2;
    result[2] = 0.0;
end;

# ╔═╡ 4fdf3a96-85c4-11eb-2f44-bd15bdf02dec
md"""
Nonlinear convection term to be handeled by AD
"""

# ╔═╡ 4cf131ae-85c4-11eb-28c6-a9d9a73d681e
	function ugradu_kernel_AD(result, input)
        # input = [VeloIdentity(u), grad(u)]
        # result = (u * grad) u = grad(u)*u
        fill!(result,0)
        for j = 1 : 2, k = 1 : 2
            result[j] += input[k]*input[2 + (j-1)*2+k]
        end
        return nothing
end;

# ╔═╡ c0f97390-85c4-11eb-2398-8d96e73caae2
md"""
## Create Navier-Stokes problem
"""

# ╔═╡ e9ce479c-85c3-11eb-0a14-e10dfe1dceb9
function create_problem(;viscosity=1.0e-3)
    Problem = PDEDescription("NSE problem")
    add_unknown!(Problem; equation_name = "momentum equation", 
			unknown_name = "velocity")
    add_unknown!(Problem; equation_name = "incompressibility constraint", 
			unknown_name = "pressure")
    # add Laplacian to [velo,velo] block
    add_operator!(Problem, [1,1], LaplaceOperator(viscosity,2,2; store = true))

    # add Lagrange multiplier for divergence of velocity to [velo,pressure] block
    add_operator!(Problem, [1,2], LagrangeMultiplier(Divergence))
    
    # add boundary data (bregion 2 is outflow)
    user_function_inflow = DataFunction(bnd_inlet!, [2,2]; 
			name = "u_inflow", dependencies = "X", quadorder = 2)
    add_boundarydata!(Problem, 1, [1,3,5], HomogeneousDirichletBoundary)
    add_boundarydata!(Problem, 1, [4], BestapproxDirichletBoundary; 
			data = user_function_inflow)
	action_kernel = ActionKernel(ugradu_kernel_AD, [2,6];
			dependencies = "", quadorder = 1)
	# div-free reconstruction operator for Identity
	VeloIdentity = ReconstructionIdentity{HDIVRT0{2}}
    NLConvectionOperator = GenerateNonlinearForm("(u * grad) u  * v", 
		[VeloIdentity, Gradient], [1,1], 
		VeloIdentity, action_kernel; ADnewton = true)            
    add_operator!(Problem, [1,1], NLConvectionOperator)
    Problem
end

# ╔═╡ a0161bd8-85c4-11eb-2366-45621bbe59b4
md"""
## Solve Navier-Stokes problem
"""

# ╔═╡ ebcd0b92-8388-11eb-02f3-99334d45c9be
function solve_problem(grid,Problem)
    # generate FESpaces
    FESpaceVelocity = FESpace{H1BR{2}}(grid)
    FESpacePressure = FESpace{H1P0{1}}(grid,broken=true)

	Solution = FEVector{Float64}("velocity",FESpaceVelocity)
    append!(Solution,"pressure",FESpacePressure)
    GradientRobustMultiPhysics.solve!(Solution, Problem; 
			maxIterations = 12, maxResidual = 1e-10)
    Solution
end

# ╔═╡ 3199edda-85c5-11eb-2da5-0dafc6cd7b84
md"""
## Run problem creation and solver
"""

# ╔═╡ 95c2ce84-85c3-11eb-37a7-bf13754d062c
maxvol=2.0e-3 # 1.0e-4 still runs in finite time

# ╔═╡ f50ae9c4-838b-11eb-1822-499d9f4afbe4
grid=make_grid(L,H;n=40,maxvol=maxvol)

# ╔═╡ 0bfe0312-838c-11eb-06d2-dbefd908b8ae
gridplot(grid,Plotter=PyPlot, resolution=(800,200))

# ╔═╡ d3d7a9e4-838a-11eb-3e70-9525fb60e1c1
md"""
Solve: $(@bind solve_karman CheckBox())
"""

# ╔═╡ 0eb76256-8389-11eb-2e40-0d4e94c1d18d
if solve_karman
	problem=create_problem()
    Solution=solve_problem(grid,problem)
    GradientRobustMultiPhysics.plot(Solution, [1], [Identity]; Plotter = PyPlot)
end

# ╔═╡ fb4690e2-838e-11eb-38e9-29168d5f6360
md"""
# PDELib.jl

- Combine the tools described so far into a meta-package with liberal licenses (MIT, BSD)

- Translation table between C++ pdelib modules and corresponding Julia packages:

| pdelib (C++) | PDELib.jl                    |                  |
|:------------ |:---------------------------- |:---------------- |
| fvsys2       | VoronoiFVM.jl                |
| femlib       | GradientRobustMultiPhysics.jl|
| Grid         | ExtendableGrids.jl           |
| GridFactory  | SimplexGridFactory.jl        |
| gltools      | GridVisualize.jl             | (PyPlot,Plots,(Makie))
| VMatrix      | ExtendableSparse.jl          |

- Maintained by WIAS but not part of PDElib.jl (for licensing reasons):
| pdelib (C++) | Julia                        |                  |
|:------------ |:---------------------------- |:---------------- |
| triwrap.cxx  | Triangulate.jl               | (Triangle interface) |
| tetwrap.cxx  | TetGen.jl                    | (TetGen interface, with S. Danisch)|


"""

# ╔═╡ 4d14735c-8647-11eb-2891-91d1bc0fe717
md"""
## Profiting from the community
"""

# ╔═╡ 4446bc76-8647-11eb-3d4b-af4000b83024
md"""
- (to be) (partially) replaced by other Julia packages
| pdelib (C++) | Julia                        |                  |
|:------------ |:---------------------------- |:---------------- |
| Iteration  | IterativeSolvers.jl               |  |
| Bifurcation  | BifurcationKit.jl               |  |
| VPrecon   | IncompleteLU.jl||
|           | AlgebraicMultigrid.jl||
|            | ...||
"""

# ╔═╡ 07658648-8596-11eb-12f2-7564ab864a2e
md"""
## Outlook
- Continue transition of knowledge to Julia packages
- Integrate C++ pdelib via python interface (e.g. gltools graphics)
- Support for projects in semiconductor simulation, electrochemistry $\dots$ 
   - Charge transport in semiconductors and electrochemical devices
   - Coupling to additional physics: Nanowires, light...
- Further development of gradient robust FEM: 
   - compressible flows, electro-magneto-hydrodynamics, nonlinear elasticity problems
- Make use of Julia's interfacing capabilities to acces more complex algorithms on top of forward simulation
   - Optimization
   - Bifurcation analysis
   - Machine Learning
   - ...
"""

# ╔═╡ df0cd404-85da-11eb-3274-51394b5edfa8
md"""
# Package environent
"""

# ╔═╡ f94316ca-85cc-11eb-1d6b-8ba91fe99cb5
TableOfContents(depth=4,title="")

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
AbstractTrees = "1520ce14-60c1-5f80-bbc7-55ef81b5835c"
DifferentialEquations = "0c46a032-eb83-5123-abaf-570d42b7fbaa"
ExtendableGrids = "cfc395e8-590f-11e8-1f13-43a2532b2fa8"
ForwardDiff = "f6369f11-7733-5829-9624-2563aa707210"
GradientRobustMultiPhysics = "0802c0ca-1768-4022-988c-6dd5f9588a11"
GridVisualize = "5eed8a63-0fb0-45eb-886d-8d5a387d12b8"
LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Printf = "de0858da-6303-5e67-8744-51eddeeeb8d7"
PyPlot = "d330b81b-6aea-500a-939a-2ce795aea3ee"
SimplexGridFactory = "57bfcd06-606e-45d6-baf4-4ba06da0efd5"
Triangulate = "f7e6ffb2-c36d-4f8f-a77e-16e897189344"
VoronoiFVM = "82b139dc-5afc-11e9-35da-9b9bdfd336f3"

[compat]
AbstractTrees = "~0.3.4"
DifferentialEquations = "~6.20.0"
ExtendableGrids = "~0.7.9"
ForwardDiff = "~0.10.23"
GradientRobustMultiPhysics = "~0.4.1"
GridVisualize = "~0.1.7"
PlutoUI = "~0.7.19"
PyPlot = "~2.10.0"
SimplexGridFactory = "~0.5.3"
Triangulate = "~2.1.0"
VoronoiFVM = "~0.10.12"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

[[AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "0bc60e3006ad95b4bb7497698dd7c6d649b9bc06"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.1"

[[AbstractTrees]]
git-tree-sha1 = "03e0550477d86222521d254b741d470ba17ea0b5"
uuid = "1520ce14-60c1-5f80-bbc7-55ef81b5835c"
version = "0.3.4"

[[Adapt]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "84918055d15b3114ede17ac6a7182f68870c16f7"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.3.1"

[[ArgCheck]]
git-tree-sha1 = "dedbbb2ddb876f899585c4ec4433265e3017215a"
uuid = "dce04be8-c92d-5529-be00-80e4d2c0e197"
version = "2.1.0"

[[ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[ArnoldiMethod]]
deps = ["LinearAlgebra", "Random", "StaticArrays"]
git-tree-sha1 = "62e51b39331de8911e4a7ff6f5aaf38a5f4cc0ae"
uuid = "ec485272-7323-5ecc-a04f-4719b315124d"
version = "0.2.0"

[[ArrayInterface]]
deps = ["Compat", "IfElse", "LinearAlgebra", "Requires", "SparseArrays", "Static"]
git-tree-sha1 = "e527b258413e0c6d4f66ade574744c94edef81f8"
uuid = "4fba245c-0d91-5ea0-9b3e-6abc04ee57a9"
version = "3.1.40"

[[ArrayLayouts]]
deps = ["FillArrays", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "e1ba79094cae97b688fb42d31cbbfd63a69706e4"
uuid = "4c555306-a7a7-4459-81d9-ec55ddd5c99a"
version = "0.7.8"

[[Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[AutoHashEquals]]
git-tree-sha1 = "45bb6705d93be619b81451bb2006b7ee5d4e4453"
uuid = "15f4f7f2-30c1-5605-9d31-71845cf9641f"
version = "0.2.0"

[[BandedMatrices]]
deps = ["ArrayLayouts", "FillArrays", "LinearAlgebra", "Random", "SparseArrays"]
git-tree-sha1 = "ce68f8c2162062733f9b4c9e3700d5efc4a8ec47"
uuid = "aae01518-5342-5314-be14-df237901396f"
version = "0.16.11"

[[BangBang]]
deps = ["Compat", "ConstructionBase", "Future", "InitialValues", "LinearAlgebra", "Requires", "Setfield", "Tables", "ZygoteRules"]
git-tree-sha1 = "0ad226aa72d8671f20d0316e03028f0ba1624307"
uuid = "198e06fe-97b7-11e9-32a5-e1d131e6ad66"
version = "0.3.32"

[[Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[Baselet]]
git-tree-sha1 = "aebf55e6d7795e02ca500a689d326ac979aaf89e"
uuid = "9718e550-a3fa-408a-8086-8db961cd8217"
version = "0.1.1"

[[BenchmarkTools]]
deps = ["JSON", "Logging", "Printf", "Statistics", "UUIDs"]
git-tree-sha1 = "9e62e66db34540a0c919d72172cc2f642ac71260"
uuid = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
version = "0.5.0"

[[Bijections]]
git-tree-sha1 = "705e7822597b432ebe152baa844b49f8026df090"
uuid = "e2ed5e7c-b2de-5872-ae92-c73ca462fb04"
version = "0.1.3"

[[BitTwiddlingConvenienceFunctions]]
deps = ["Static"]
git-tree-sha1 = "bc1317f71de8dce26ea67fcdf7eccc0d0693b75b"
uuid = "62783981-4cbd-42fc-bca8-16325de8dc4b"
version = "0.1.1"

[[BoundaryValueDiffEq]]
deps = ["BandedMatrices", "DiffEqBase", "FiniteDiff", "ForwardDiff", "LinearAlgebra", "NLsolve", "Reexport", "SparseArrays"]
git-tree-sha1 = "fe34902ac0c3a35d016617ab7032742865756d7d"
uuid = "764a87c0-6b3e-53db-9096-fe964310641d"
version = "2.7.1"

[[CEnum]]
git-tree-sha1 = "215a9aa4a1f23fbd05b92769fdd62559488d70e9"
uuid = "fa961155-64e5-5f13-b03f-caf6b980ea82"
version = "0.4.1"

[[CPUSummary]]
deps = ["Hwloc", "IfElse", "Static"]
git-tree-sha1 = "87b0c9c6ee0124d6c1f4ce8cb035dcaf9f90b803"
uuid = "2a0fbf3d-bb9c-48f3-b0a9-814d99fd7ab9"
version = "0.1.6"

[[CSTParser]]
deps = ["Tokenize"]
git-tree-sha1 = "f9a6389348207faf5e5c62cbc7e89d19688d338a"
uuid = "00ebfdb7-1f24-5e51-bd34-a7502290713f"
version = "3.3.0"

[[Cassette]]
git-tree-sha1 = "6ce3cd755d4130d43bab24ea5181e77b89b51839"
uuid = "7057c7e9-c182-5462-911a-8362d720325c"
version = "0.3.9"

[[ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "f885e7e7c124f8c92650d61b9477b9ac2ee607dd"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.11.1"

[[ChangesOfVariables]]
deps = ["LinearAlgebra", "Test"]
git-tree-sha1 = "9a1d594397670492219635b35a3d830b04730d62"
uuid = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
version = "0.1.1"

[[CloseOpenIntervals]]
deps = ["ArrayInterface", "Static"]
git-tree-sha1 = "7b8f09d58294dc8aa13d91a8544b37c8a1dcbc06"
uuid = "fb6a15b2-703c-40df-9091-08a04967cfa9"
version = "0.1.4"

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

[[Combinatorics]]
git-tree-sha1 = "08c8b6831dc00bfea825826be0bc8336fc369860"
uuid = "861a8166-3701-5b0c-9a16-15d98fcdc6aa"
version = "1.0.2"

[[CommonMark]]
deps = ["Crayons", "JSON", "URIs"]
git-tree-sha1 = "393ac9df4eb085c2ab12005fc496dae2e1da344e"
uuid = "a80b9123-70ca-4bc0-993e-6e3bcb318db6"
version = "0.8.3"

[[CommonSolve]]
git-tree-sha1 = "68a0743f578349ada8bc911a5cbd5a2ef6ed6d1f"
uuid = "38540f10-b2f7-11e9-35d8-d573e4eb0ff2"
version = "0.2.0"

[[CommonSubexpressions]]
deps = ["MacroTools", "Test"]
git-tree-sha1 = "7b8a93dba8af7e3b42fecabf646260105ac373f7"
uuid = "bbf7d656-a473-5ed7-a52c-81e309532950"
version = "0.3.0"

[[Compat]]
deps = ["Base64", "Dates", "DelimitedFiles", "Distributed", "InteractiveUtils", "LibGit2", "Libdl", "LinearAlgebra", "Markdown", "Mmap", "Pkg", "Printf", "REPL", "Random", "SHA", "Serialization", "SharedArrays", "Sockets", "SparseArrays", "Statistics", "Test", "UUIDs", "Unicode"]
git-tree-sha1 = "dce3e3fea680869eaa0b774b2e8343e9ff442313"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "3.40.0"

[[CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"

[[CompositeTypes]]
git-tree-sha1 = "d5b014b216dc891e81fea299638e4c10c657b582"
uuid = "b152e2b5-7a66-4b01-a709-34e65c35f657"
version = "0.1.2"

[[CompositionsBase]]
git-tree-sha1 = "455419f7e328a1a2493cabc6428d79e951349769"
uuid = "a33af91c-f02d-484b-be07-31d278c5ca2b"
version = "0.1.1"

[[Conda]]
deps = ["JSON", "VersionParsing"]
git-tree-sha1 = "299304989a5e6473d985212c28928899c74e9421"
uuid = "8f4d0f93-b110-5947-807f-2305c1781a2d"
version = "1.5.2"

[[ConstructionBase]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "f74e9d5388b8620b4cee35d4c5a618dd4dc547f4"
uuid = "187b0558-2788-49d3-abe0-74a17ed4e7c9"
version = "1.3.0"

[[Crayons]]
git-tree-sha1 = "3f71217b538d7aaee0b69ab47d9b7724ca8afa0d"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.0.4"

[[DEDataArrays]]
deps = ["ArrayInterface", "DocStringExtensions", "LinearAlgebra", "RecursiveArrayTools", "SciMLBase", "StaticArrays"]
git-tree-sha1 = "31186e61936fbbccb41d809ad4338c9f7addf7ae"
uuid = "754358af-613d-5f8d-9788-280bf1605d4c"
version = "0.2.0"

[[DataAPI]]
git-tree-sha1 = "cc70b17275652eb47bc9e5f81635981f13cea5c8"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.9.0"

[[DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "7d9d316f04214f7efdbb6398d545446e246eff02"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.10"

[[DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[DefineSingletons]]
git-tree-sha1 = "77b4ca280084423b728662fe040e5ff8819347c5"
uuid = "244e2a9f-e319-4986-a169-4d1fe445cd52"
version = "0.1.1"

[[DelayDiffEq]]
deps = ["ArrayInterface", "DataStructures", "DiffEqBase", "LinearAlgebra", "Logging", "NonlinearSolve", "OrdinaryDiffEq", "Printf", "RecursiveArrayTools", "Reexport", "UnPack"]
git-tree-sha1 = "6eba402e968317b834c28cd47499dd1b572dd093"
uuid = "bcd4f6db-9728-5f36-b5f7-82caef46ccdb"
version = "5.31.1"

[[DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

[[DensityInterface]]
deps = ["InverseFunctions", "Test"]
git-tree-sha1 = "80c3e8639e3353e5d2912fb3a1916b8455e2494b"
uuid = "b429d917-457f-4dbc-8f4c-0cc954292b1d"
version = "0.4.0"

[[DiffEqBase]]
deps = ["ArrayInterface", "ChainRulesCore", "DEDataArrays", "DataStructures", "Distributions", "DocStringExtensions", "FastBroadcast", "ForwardDiff", "FunctionWrappers", "IterativeSolvers", "LabelledArrays", "LinearAlgebra", "Logging", "MuladdMacro", "NonlinearSolve", "Parameters", "PreallocationTools", "Printf", "RecursiveArrayTools", "RecursiveFactorization", "Reexport", "Requires", "SciMLBase", "Setfield", "SparseArrays", "StaticArrays", "Statistics", "SuiteSparse", "ZygoteRules"]
git-tree-sha1 = "5c3d877ddfc2da61ce5cc1f5ce330ff97789c57c"
uuid = "2b5f629d-d688-5b77-993f-72d75c75574e"
version = "6.76.0"

[[DiffEqCallbacks]]
deps = ["DataStructures", "DiffEqBase", "ForwardDiff", "LinearAlgebra", "NLsolve", "OrdinaryDiffEq", "Parameters", "RecipesBase", "RecursiveArrayTools", "StaticArrays"]
git-tree-sha1 = "35bc7f8be9dd2155336fe999b11a8f5e44c0d602"
uuid = "459566f4-90b8-5000-8ac3-15dfb0a30def"
version = "2.17.0"

[[DiffEqFinancial]]
deps = ["DiffEqBase", "DiffEqNoiseProcess", "LinearAlgebra", "Markdown", "RandomNumbers"]
git-tree-sha1 = "db08e0def560f204167c58fd0637298e13f58f73"
uuid = "5a0ffddc-d203-54b0-88ba-2c03c0fc2e67"
version = "2.4.0"

[[DiffEqJump]]
deps = ["ArrayInterface", "Compat", "DataStructures", "DiffEqBase", "FunctionWrappers", "Graphs", "LinearAlgebra", "PoissonRandom", "Random", "RandomNumbers", "RecursiveArrayTools", "Reexport", "StaticArrays", "TreeViews", "UnPack"]
git-tree-sha1 = "0aa2d003ec9efe2a93f93ae722de05a870ffc0b2"
uuid = "c894b116-72e5-5b58-be3c-e6d8d4ac2b12"
version = "8.0.0"

[[DiffEqNoiseProcess]]
deps = ["DiffEqBase", "Distributions", "LinearAlgebra", "Optim", "PoissonRandom", "QuadGK", "Random", "Random123", "RandomNumbers", "RecipesBase", "RecursiveArrayTools", "Requires", "ResettableStacks", "SciMLBase", "StaticArrays", "Statistics"]
git-tree-sha1 = "d6839a44a268c69ef0ed927b22a6f43c8a4c2e73"
uuid = "77a26b50-5914-5dd7-bc55-306e6241c503"
version = "5.9.0"

[[DiffEqPhysics]]
deps = ["DiffEqBase", "DiffEqCallbacks", "ForwardDiff", "LinearAlgebra", "Printf", "Random", "RecipesBase", "RecursiveArrayTools", "Reexport", "StaticArrays"]
git-tree-sha1 = "8f23c6f36f6a6eb2cbd6950e28ec7c4b99d0e4c9"
uuid = "055956cb-9e8b-5191-98cc-73ae4a59e68a"
version = "3.9.0"

[[DiffResults]]
deps = ["StaticArrays"]
git-tree-sha1 = "c18e98cba888c6c25d1c3b048e4b3380ca956805"
uuid = "163ba53b-c6d8-5494-b064-1a9d43ac40c5"
version = "1.0.3"

[[DiffRules]]
deps = ["LogExpFunctions", "NaNMath", "Random", "SpecialFunctions"]
git-tree-sha1 = "3287dacf67c3652d3fed09f4c12c187ae4dbb89a"
uuid = "b552c78f-8df3-52c6-915a-8e097449b14b"
version = "1.4.0"

[[DifferentialEquations]]
deps = ["BoundaryValueDiffEq", "DelayDiffEq", "DiffEqBase", "DiffEqCallbacks", "DiffEqFinancial", "DiffEqJump", "DiffEqNoiseProcess", "DiffEqPhysics", "DimensionalPlotRecipes", "LinearAlgebra", "MultiScaleArrays", "OrdinaryDiffEq", "ParameterizedFunctions", "Random", "RecursiveArrayTools", "Reexport", "SteadyStateDiffEq", "StochasticDiffEq", "Sundials"]
git-tree-sha1 = "91df208ee040be7960c408d4681bf91974bcb4f4"
uuid = "0c46a032-eb83-5123-abaf-570d42b7fbaa"
version = "6.20.0"

[[DimensionalPlotRecipes]]
deps = ["LinearAlgebra", "RecipesBase"]
git-tree-sha1 = "af883a26bbe6e3f5f778cb4e1b81578b534c32a6"
uuid = "c619ae07-58cd-5f6d-b883-8f17bd6a98f9"
version = "1.2.0"

[[Distances]]
deps = ["LinearAlgebra", "Statistics", "StatsAPI"]
git-tree-sha1 = "837c83e5574582e07662bbbba733964ff7c26b9d"
uuid = "b4f34e82-e78d-54a5-968a-f98e89d6e8f7"
version = "0.10.6"

[[Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[Distributions]]
deps = ["ChainRulesCore", "DensityInterface", "FillArrays", "LinearAlgebra", "PDMats", "Printf", "QuadGK", "Random", "SparseArrays", "SpecialFunctions", "Statistics", "StatsBase", "StatsFuns", "Test"]
git-tree-sha1 = "dc6f530de935bb3c3cd73e99db5b4698e58b2fcf"
uuid = "31c24e10-a181-5473-b8eb-7969acd0382f"
version = "0.25.31"

[[DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "b19534d1895d702889b219c382a6e18010797f0b"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.8.6"

[[DomainSets]]
deps = ["CompositeTypes", "IntervalSets", "LinearAlgebra", "StaticArrays", "Statistics"]
git-tree-sha1 = "5f5f0b750ac576bcf2ab1d7782959894b304923e"
uuid = "5b8099bc-c8ec-5219-889f-1d9e522a28bf"
version = "0.5.9"

[[Downloads]]
deps = ["ArgTools", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"

[[DynamicPolynomials]]
deps = ["DataStructures", "Future", "LinearAlgebra", "MultivariatePolynomials", "MutableArithmetics", "Pkg", "Reexport", "Test"]
git-tree-sha1 = "1b4665a7e303eaa7e03542cfaef0730cb056cb00"
uuid = "7c1d4256-1411-5781-91ec-d7bc3513ac07"
version = "0.3.21"

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

[[EllipsisNotation]]
deps = ["ArrayInterface"]
git-tree-sha1 = "9aad812fb7c4c038da7cab5a069f502e6e3ae030"
uuid = "da5c29d0-fa7d-589e-88eb-ea29b0a81949"
version = "1.1.1"

[[ExponentialUtilities]]
deps = ["ArrayInterface", "LinearAlgebra", "Printf", "Requires", "SparseArrays"]
git-tree-sha1 = "cb39752c2a1f83bbe0fda393c51c480a296042ad"
uuid = "d4d017d3-3776-5f7e-afef-a10c40355c18"
version = "1.10.1"

[[ExprTools]]
git-tree-sha1 = "b7e3d17636b348f005f11040025ae8c6f645fe92"
uuid = "e2ba6199-217a-4e67-a87a-7c52f15ade04"
version = "0.1.6"

[[ExtendableGrids]]
deps = ["AbstractTrees", "Dates", "DocStringExtensions", "ElasticArrays", "InteractiveUtils", "LinearAlgebra", "Printf", "Random", "SparseArrays", "Test"]
git-tree-sha1 = "5a42a9371dd5ad1a00ec27c63c5eccc8e38dab43"
uuid = "cfc395e8-590f-11e8-1f13-43a2532b2fa8"
version = "0.7.9"

[[ExtendableSparse]]
deps = ["DocStringExtensions", "LinearAlgebra", "Printf", "SparseArrays", "Test"]
git-tree-sha1 = "ead69f021a6b37642f8c85a5b2b2d95aec40afd7"
uuid = "95c220a8-a1cf-11e9-0c77-dbfce5f500b3"
version = "0.3.7"

[[FastBroadcast]]
deps = ["LinearAlgebra", "Polyester", "Static"]
git-tree-sha1 = "e32a81c505ab234c992ca978f31ed8b0dabbc327"
uuid = "7034ab61-46d4-4ed7-9d0f-46aef9175898"
version = "0.1.11"

[[FastClosures]]
git-tree-sha1 = "acebe244d53ee1b461970f8910c235b259e772ef"
uuid = "9aa1b823-49e4-5ca5-8b0f-3971ec8bab6a"
version = "0.3.2"

[[FileIO]]
deps = ["Pkg", "Requires", "UUIDs"]
git-tree-sha1 = "2db648b6712831ecb333eae76dbfd1c156ca13bb"
uuid = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
version = "1.11.2"

[[FillArrays]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "Statistics"]
git-tree-sha1 = "8756f9935b7ccc9064c6eef0bff0ad643df733a3"
uuid = "1a297f60-69ca-5386-bcde-b61e274b549b"
version = "0.12.7"

[[FiniteDiff]]
deps = ["ArrayInterface", "LinearAlgebra", "Requires", "SparseArrays", "StaticArrays"]
git-tree-sha1 = "8b3c09b56acaf3c0e581c66638b85c8650ee9dca"
uuid = "6a86dc24-6348-571c-b903-95158fe2bd41"
version = "2.8.1"

[[FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[Formatting]]
deps = ["Printf"]
git-tree-sha1 = "8339d61043228fdd3eb658d86c926cb282ae72a8"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.2"

[[ForwardDiff]]
deps = ["CommonSubexpressions", "DiffResults", "DiffRules", "LinearAlgebra", "LogExpFunctions", "NaNMath", "Preferences", "Printf", "Random", "SpecialFunctions", "StaticArrays"]
git-tree-sha1 = "6406b5112809c08b1baa5703ad274e1dded0652f"
uuid = "f6369f11-7733-5829-9624-2563aa707210"
version = "0.10.23"

[[FunctionWrappers]]
git-tree-sha1 = "241552bc2209f0fa068b6415b1942cc0aa486bcc"
uuid = "069b7b12-0de2-55c6-9aab-29f3d0a68a2e"
version = "1.1.2"

[[Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[GeometryBasics]]
deps = ["EarCut_jll", "IterTools", "LinearAlgebra", "StaticArrays", "StructArrays", "Tables"]
git-tree-sha1 = "15ff9a14b9e1218958d3530cc288cf31465d9ae2"
uuid = "5c1252a2-5f33-56bf-86c9-59e7332b4326"
version = "0.3.13"

[[GradientRobustMultiPhysics]]
deps = ["BenchmarkTools", "DiffResults", "DocStringExtensions", "ExtendableGrids", "ExtendableSparse", "ForwardDiff", "GridVisualize", "LinearAlgebra", "Printf", "SparseArrays", "StaticArrays", "SuiteSparse", "Test"]
git-tree-sha1 = "4dd7e32409b3632804ffbc0d814756841290124e"
uuid = "0802c0ca-1768-4022-988c-6dd5f9588a11"
version = "0.4.1"

[[Graphs]]
deps = ["ArnoldiMethod", "DataStructures", "Distributed", "Inflate", "LinearAlgebra", "Random", "SharedArrays", "SimpleTraits", "SparseArrays", "Statistics"]
git-tree-sha1 = "92243c07e786ea3458532e199eb3feee0e7e08eb"
uuid = "86223c79-3864-5bf0-83f7-82e725a168b6"
version = "1.4.1"

[[GridVisualize]]
deps = ["ColorSchemes", "Colors", "DocStringExtensions", "ElasticArrays", "ExtendableGrids", "GeometryBasics", "LinearAlgebra", "PkgVersion", "Printf", "StaticArrays"]
git-tree-sha1 = "39eef7772fbe0945ebd9662f12c4239490cb63e4"
uuid = "5eed8a63-0fb0-45eb-886d-8d5a387d12b8"
version = "0.1.7"

[[HostCPUFeatures]]
deps = ["BitTwiddlingConvenienceFunctions", "IfElse", "Libdl", "Static"]
git-tree-sha1 = "8f0dc80088981ab55702b04bba38097a44a1a3a9"
uuid = "3e5b6fbb-0976-4d2c-9146-d79de83f2fb0"
version = "0.1.5"

[[Hwloc]]
deps = ["Hwloc_jll"]
git-tree-sha1 = "92d99146066c5c6888d5a3abc871e6a214388b91"
uuid = "0e44f5e4-bd66-52a0-8798-143a42290a1d"
version = "2.0.0"

[[Hwloc_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "3395d4d4aeb3c9d31f5929d32760d8baeee88aaf"
uuid = "e33a78d0-f292-5ffc-b300-72abe9b543c8"
version = "2.5.0+0"

[[Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[HypertextLiteral]]
git-tree-sha1 = "2b078b5a615c6c0396c77810d92ee8c6f470d238"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.3"

[[IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "f7be53659ab06ddc986428d3a9dcc95f6fa6705a"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.2"

[[IfElse]]
git-tree-sha1 = "debdd00ffef04665ccbb3e150747a77560e8fad1"
uuid = "615f187c-cbe4-4ef1-ba3b-2fcf58d6d173"
version = "0.1.1"

[[Inflate]]
git-tree-sha1 = "f5fc07d4e706b84f72d54eedcc1c13d92fb0871c"
uuid = "d25df0c9-e2be-5dd7-82c8-3ad0b3e990b9"
version = "0.1.2"

[[InitialValues]]
git-tree-sha1 = "7f6a4508b4a6f46db5ccd9799a3fc71ef5cad6e6"
uuid = "22cec73e-a1b8-11e9-2c92-598750a2cf9c"
version = "0.2.11"

[[InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[IntervalSets]]
deps = ["Dates", "EllipsisNotation", "Statistics"]
git-tree-sha1 = "3cc368af3f110a767ac786560045dceddfc16758"
uuid = "8197267c-284f-5f27-9208-e0e47529a953"
version = "0.5.3"

[[InverseFunctions]]
deps = ["Test"]
git-tree-sha1 = "a7254c0acd8e62f1ac75ad24d5db43f5f19f3c65"
uuid = "3587e190-3f89-42d0-90ee-14403ec27112"
version = "0.1.2"

[[IrrationalConstants]]
git-tree-sha1 = "7fd44fd4ff43fc60815f8e764c0f352b83c49151"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.1.1"

[[IterTools]]
git-tree-sha1 = "05110a2ab1fc5f932622ffea2a003221f4782c18"
uuid = "c8e1da08-722c-5040-9ed9-7db0dc04731e"
version = "1.3.0"

[[IterativeSolvers]]
deps = ["LinearAlgebra", "Printf", "Random", "RecipesBase", "SparseArrays"]
git-tree-sha1 = "1169632f425f79429f245113b775a0e3d121457c"
uuid = "42fd0dbc-a981-5370-80f2-aaf504508153"
version = "0.9.2"

[[IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[JLD2]]
deps = ["DataStructures", "FileIO", "MacroTools", "Mmap", "Pkg", "Printf", "Reexport", "TranscodingStreams", "UUIDs"]
git-tree-sha1 = "46b7834ec8165c541b0b5d1c8ba63ec940723ffb"
uuid = "033835bb-8acc-5ee8-8aae-3f567f8a3819"
version = "0.4.15"

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

[[JuliaFormatter]]
deps = ["CSTParser", "CommonMark", "DataStructures", "Pkg", "Tokenize"]
git-tree-sha1 = "e45015cdba3dea9ce91a573079a5706e73a5e895"
uuid = "98e50ef6-434e-11e9-1051-2b60c6c9e899"
version = "0.19.0"

[[LaTeXStrings]]
git-tree-sha1 = "f2355693d6778a178ade15952b7ac47a4ff97996"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.0"

[[LabelledArrays]]
deps = ["ArrayInterface", "LinearAlgebra", "MacroTools", "StaticArrays"]
git-tree-sha1 = "fa07d4ee13edf79a6ac2575ad28d9f43694e1190"
uuid = "2ee39098-c373-598a-b85f-a56591580800"
version = "1.6.6"

[[Latexify]]
deps = ["Formatting", "InteractiveUtils", "LaTeXStrings", "MacroTools", "Markdown", "Printf", "Requires"]
git-tree-sha1 = "a8f4f279b6fa3c3c4f1adadd78a621b13a506bce"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.15.9"

[[LayoutPointers]]
deps = ["ArrayInterface", "LinearAlgebra", "ManualMemory", "SIMDTypes", "Static"]
git-tree-sha1 = "83b56449c39342a47f3fcdb3bc782bd6d66e1d97"
uuid = "10f19ff3-798f-405d-979b-55457f8fc047"
version = "0.1.4"

[[LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"

[[LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"

[[LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"

[[Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[LineSearches]]
deps = ["LinearAlgebra", "NLSolversBase", "NaNMath", "Parameters", "Printf"]
git-tree-sha1 = "f27132e551e959b3667d8c93eae90973225032dd"
uuid = "d3d80556-e9d4-5f37-9878-2ab0fcc64255"
version = "7.1.1"

[[LinearAlgebra]]
deps = ["Libdl"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[LogExpFunctions]]
deps = ["ChainRulesCore", "ChangesOfVariables", "DocStringExtensions", "InverseFunctions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "be9eef9f9d78cecb6f262f3c10da151a6c5ab827"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.5"

[[Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[LoopVectorization]]
deps = ["ArrayInterface", "CPUSummary", "CloseOpenIntervals", "DocStringExtensions", "HostCPUFeatures", "IfElse", "LayoutPointers", "LinearAlgebra", "OffsetArrays", "PolyesterWeave", "Requires", "SIMDDualNumbers", "SLEEFPirates", "Static", "ThreadingUtilities", "UnPack", "VectorizationBase"]
git-tree-sha1 = "9d8ce46c7727debdfd65be244f22257abf7d8739"
uuid = "bdcacae8-1622-11e9-2a5c-532679323890"
version = "0.12.98"

[[MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "3d3e902b31198a27340d0bf00d6ac452866021cf"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.9"

[[ManualMemory]]
git-tree-sha1 = "9cb207b18148b2199db259adfa923b45593fe08e"
uuid = "d125e4d3-2237-4719-b19c-fa641b8a4667"
version = "0.1.6"

[[Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"

[[Metatheory]]
deps = ["AutoHashEquals", "DataStructures", "Dates", "DocStringExtensions", "Parameters", "Reexport", "TermInterface", "ThreadsX", "TimerOutputs"]
git-tree-sha1 = "0d3b2feb3168e4deb78361d3b5bb5c2e51ea5271"
uuid = "e9d8d322-4543-424a-9be4-0cc815abe26c"
version = "1.3.2"

[[MicroCollections]]
deps = ["BangBang", "Setfield"]
git-tree-sha1 = "4f65bdbbe93475f6ff9ea6969b21532f88d359be"
uuid = "128add7d-3638-4c79-886c-908ea0c25c34"
version = "0.1.1"

[[Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "bf210ce90b6c9eed32d25dbcae1ebc565df2687f"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.0.2"

[[Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[ModelingToolkit]]
deps = ["AbstractTrees", "ArrayInterface", "ConstructionBase", "DataStructures", "DiffEqBase", "DiffEqCallbacks", "DiffEqJump", "DiffRules", "Distributed", "Distributions", "DocStringExtensions", "DomainSets", "Graphs", "IfElse", "InteractiveUtils", "JuliaFormatter", "LabelledArrays", "Latexify", "Libdl", "LinearAlgebra", "MacroTools", "NaNMath", "NonlinearSolve", "RecursiveArrayTools", "Reexport", "Requires", "RuntimeGeneratedFunctions", "SafeTestsets", "SciMLBase", "Serialization", "Setfield", "SparseArrays", "SpecialFunctions", "StaticArrays", "SymbolicUtils", "Symbolics", "UnPack", "Unitful"]
git-tree-sha1 = "c9d6d91b6a976b668309691ea21a459d7bcf4f59"
uuid = "961ee093-0014-501f-94e3-6117800e7a78"
version = "7.1.2"

[[MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"

[[MuladdMacro]]
git-tree-sha1 = "c6190f9a7fc5d9d5915ab29f2134421b12d24a68"
uuid = "46d2c3a1-f734-5fdb-9937-b9b9aeba4221"
version = "0.2.2"

[[MultiScaleArrays]]
deps = ["DiffEqBase", "FiniteDiff", "ForwardDiff", "LinearAlgebra", "OrdinaryDiffEq", "Random", "RecursiveArrayTools", "SparseDiffTools", "Statistics", "StochasticDiffEq", "TreeViews"]
git-tree-sha1 = "258f3be6770fe77be8870727ba9803e236c685b8"
uuid = "f9640e96-87f6-5992-9c3b-0743c6a49ffa"
version = "1.8.1"

[[MultivariatePolynomials]]
deps = ["DataStructures", "LinearAlgebra", "MutableArithmetics"]
git-tree-sha1 = "45c9940cec79dedcdccc73cc6dd09ea8b8ab142c"
uuid = "102ac46a-7ee4-5c85-9060-abc95bfdeaa3"
version = "0.3.18"

[[MutableArithmetics]]
deps = ["LinearAlgebra", "SparseArrays", "Test"]
git-tree-sha1 = "8d9496b2339095901106961f44718920732616bb"
uuid = "d8a4904e-b15c-11e9-3269-09a3773c0cb0"
version = "0.2.22"

[[NLSolversBase]]
deps = ["DiffResults", "Distributed", "FiniteDiff", "ForwardDiff"]
git-tree-sha1 = "50310f934e55e5ca3912fb941dec199b49ca9b68"
uuid = "d41bc354-129a-5804-8e4c-c37616107c6c"
version = "7.8.2"

[[NLsolve]]
deps = ["Distances", "LineSearches", "LinearAlgebra", "NLSolversBase", "Printf", "Reexport"]
git-tree-sha1 = "019f12e9a1a7880459d0173c182e6a99365d7ac1"
uuid = "2774e3e8-f4cf-5e23-947b-6d7e65073b56"
version = "4.5.1"

[[NaNMath]]
git-tree-sha1 = "bfe47e760d60b82b66b61d2d44128b62e3a369fb"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "0.3.5"

[[NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"

[[NonlinearSolve]]
deps = ["ArrayInterface", "FiniteDiff", "ForwardDiff", "IterativeSolvers", "LinearAlgebra", "RecursiveArrayTools", "RecursiveFactorization", "Reexport", "SciMLBase", "Setfield", "StaticArrays", "UnPack"]
git-tree-sha1 = "e9ffc92217b8709e0cf7b8808f6223a4a0936c95"
uuid = "8913a72c-1f9b-4ce2-8d82-65094dcecaec"
version = "0.3.11"

[[OffsetArrays]]
deps = ["Adapt"]
git-tree-sha1 = "043017e0bdeff61cfbb7afeb558ab29536bbb5ed"
uuid = "6fe1bfb0-de20-5000-8ca7-80f57d26f881"
version = "1.10.8"

[[OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"

[[OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"

[[OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "13652491f6856acfd2db29360e1bbcd4565d04f1"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.5+0"

[[Optim]]
deps = ["Compat", "FillArrays", "ForwardDiff", "LineSearches", "LinearAlgebra", "NLSolversBase", "NaNMath", "Parameters", "PositiveFactorizations", "Printf", "SparseArrays", "StatsBase"]
git-tree-sha1 = "35d435b512fbab1d1a29138b5229279925eba369"
uuid = "429524aa-4258-5aef-a3af-852621145aeb"
version = "1.5.0"

[[OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[OrdinaryDiffEq]]
deps = ["Adapt", "ArrayInterface", "DataStructures", "DiffEqBase", "DocStringExtensions", "ExponentialUtilities", "FastClosures", "FiniteDiff", "ForwardDiff", "LinearAlgebra", "Logging", "LoopVectorization", "MacroTools", "MuladdMacro", "NLsolve", "Polyester", "PreallocationTools", "RecursiveArrayTools", "Reexport", "SparseArrays", "SparseDiffTools", "StaticArrays", "UnPack"]
git-tree-sha1 = "6f76c887ddfd3f2a018ef1ee00a17b46bcf4886e"
uuid = "1dea7af3-3e70-54e6-95c3-0bf5283fa5ed"
version = "5.67.0"

[[PDMats]]
deps = ["LinearAlgebra", "SparseArrays", "SuiteSparse"]
git-tree-sha1 = "ee26b350276c51697c9c2d88a072b339f9f03d73"
uuid = "90014a1f-27ba-587c-ab20-58faa44d9150"
version = "0.11.5"

[[ParameterizedFunctions]]
deps = ["DataStructures", "DiffEqBase", "DocStringExtensions", "Latexify", "LinearAlgebra", "ModelingToolkit", "Reexport", "SciMLBase"]
git-tree-sha1 = "3baa1ad75b77f406988be4dc0364e01cf16127e7"
uuid = "65888b18-ceab-5e60-b2b9-181511a3b968"
version = "5.12.2"

[[Parameters]]
deps = ["OrderedCollections", "UnPack"]
git-tree-sha1 = "34c0e9ad262e5f7fc75b10a9952ca7692cfc5fbe"
uuid = "d96e819e-fc66-5662-9728-84c9c7592b0a"
version = "0.12.3"

[[Parsers]]
deps = ["Dates"]
git-tree-sha1 = "ae4bbcadb2906ccc085cf52ac286dc1377dceccc"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.1.2"

[[Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"

[[PkgVersion]]
deps = ["Pkg"]
git-tree-sha1 = "a7a7e1a88853564e551e4eba8650f8c38df79b37"
uuid = "eebad327-c553-4316-9ea0-9fa01ccd7688"
version = "0.1.1"

[[PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "Dates", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "UUIDs"]
git-tree-sha1 = "e071adf21e165ea0d904b595544a8e514c8bb42c"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.19"

[[PoissonRandom]]
deps = ["Random", "Statistics", "Test"]
git-tree-sha1 = "44d018211a56626288b5d3f8c6497d28c26dc850"
uuid = "e409e4f3-bfea-5376-8464-e040bb5c01ab"
version = "0.4.0"

[[Polyester]]
deps = ["ArrayInterface", "BitTwiddlingConvenienceFunctions", "CPUSummary", "IfElse", "ManualMemory", "PolyesterWeave", "Requires", "Static", "StrideArraysCore", "ThreadingUtilities"]
git-tree-sha1 = "892b8d9dd3c7987a4d0fd320f0a421dd90b5d09d"
uuid = "f517fe37-dbe3-4b94-8317-1923a5111588"
version = "0.5.4"

[[PolyesterWeave]]
deps = ["BitTwiddlingConvenienceFunctions", "CPUSummary", "IfElse", "Static", "ThreadingUtilities"]
git-tree-sha1 = "a3ff99bf561183ee20386aec98ab8f4a12dc724a"
uuid = "1d0040c9-8b98-4ee7-8388-3f51789ca0ad"
version = "0.1.2"

[[PositiveFactorizations]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "17275485f373e6673f7e7f97051f703ed5b15b20"
uuid = "85a6dd25-e78a-55b7-8502-1745935b8125"
version = "0.2.4"

[[PreallocationTools]]
deps = ["Adapt", "ArrayInterface", "ForwardDiff", "LabelledArrays"]
git-tree-sha1 = "ba819074442cd4c9bda1a3d905ec305f8acb37f2"
uuid = "d236fae5-4411-538c-8e31-a6e3d9e00b46"
version = "0.2.0"

[[Preferences]]
deps = ["TOML"]
git-tree-sha1 = "00cfd92944ca9c760982747e9a1d0d5d86ab1e5a"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.2.2"

[[Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[PyCall]]
deps = ["Conda", "Dates", "Libdl", "LinearAlgebra", "MacroTools", "Serialization", "VersionParsing"]
git-tree-sha1 = "4ba3651d33ef76e24fef6a598b63ffd1c5e1cd17"
uuid = "438e738f-606a-5dbb-bf0a-cddfbfd45ab0"
version = "1.92.5"

[[PyPlot]]
deps = ["Colors", "LaTeXStrings", "PyCall", "Sockets", "Test", "VersionParsing"]
git-tree-sha1 = "14c1b795b9d764e1784713941e787e1384268103"
uuid = "d330b81b-6aea-500a-939a-2ce795aea3ee"
version = "2.10.0"

[[QuadGK]]
deps = ["DataStructures", "LinearAlgebra"]
git-tree-sha1 = "78aadffb3efd2155af139781b8a8df1ef279ea39"
uuid = "1fd47b50-473d-5c70-9696-f719f8f3bcdc"
version = "2.4.2"

[[REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[Random]]
deps = ["Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[Random123]]
deps = ["Libdl", "Random", "RandomNumbers"]
git-tree-sha1 = "0e8b146557ad1c6deb1367655e052276690e71a3"
uuid = "74087812-796a-5b5d-8853-05524746bad3"
version = "1.4.2"

[[RandomNumbers]]
deps = ["Random", "Requires"]
git-tree-sha1 = "043da614cc7e95c703498a491e2c21f58a2b8111"
uuid = "e6cf234a-135c-5ec9-84dd-332b85af5143"
version = "1.5.3"

[[RecipesBase]]
git-tree-sha1 = "44a75aa7a527910ee3d1751d1f0e4148698add9e"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.1.2"

[[RecursiveArrayTools]]
deps = ["ArrayInterface", "ChainRulesCore", "DocStringExtensions", "FillArrays", "LinearAlgebra", "RecipesBase", "Requires", "StaticArrays", "Statistics", "ZygoteRules"]
git-tree-sha1 = "c944fa4adbb47be43376359811c0a14757bdc8a8"
uuid = "731186ca-8d62-57ce-b412-fbd966d074cd"
version = "2.20.0"

[[RecursiveFactorization]]
deps = ["LinearAlgebra", "LoopVectorization", "Polyester", "StrideArraysCore", "TriangularSolve"]
git-tree-sha1 = "b7edd69c796b30985ea6dfeda8504cdb7cf77e9f"
uuid = "f2c3362d-daeb-58d1-803e-2bc74f2840b4"
version = "0.2.5"

[[Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[Referenceables]]
deps = ["Adapt"]
git-tree-sha1 = "e681d3bfa49cd46c3c161505caddf20f0e62aaa9"
uuid = "42d2dcc6-99eb-4e98-b66c-637b7d73030e"
version = "0.1.2"

[[Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "4036a3bd08ac7e968e27c203d45f5fff15020621"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.1.3"

[[ResettableStacks]]
deps = ["StaticArrays"]
git-tree-sha1 = "256eeeec186fa7f26f2801732774ccf277f05db9"
uuid = "ae5879a3-cd67-5da8-be7f-38c6eb64a37b"
version = "1.1.1"

[[Rmath]]
deps = ["Random", "Rmath_jll"]
git-tree-sha1 = "bf3188feca147ce108c76ad82c2792c57abe7b1f"
uuid = "79098fc4-a85e-5d69-aa6a-4863f24498fa"
version = "0.7.0"

[[Rmath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "68db32dff12bb6127bac73c209881191bf0efbb7"
uuid = "f50d1b31-88e8-58de-be2c-1cc44531875f"
version = "0.3.0+0"

[[RuntimeGeneratedFunctions]]
deps = ["ExprTools", "SHA", "Serialization"]
git-tree-sha1 = "cdc1e4278e91a6ad530770ebb327f9ed83cf10c4"
uuid = "7e49a35a-f44a-4d26-94aa-eba1b4ca6b47"
version = "0.5.3"

[[SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[SIMDDualNumbers]]
deps = ["ForwardDiff", "IfElse", "SLEEFPirates", "VectorizationBase"]
git-tree-sha1 = "62c2da6eb66de8bb88081d20528647140d4daa0e"
uuid = "3cdde19b-5bb0-4aaf-8931-af3e248e098b"
version = "0.1.0"

[[SIMDTypes]]
git-tree-sha1 = "330289636fb8107c5f32088d2741e9fd7a061a5c"
uuid = "94e857df-77ce-4151-89e5-788b33177be4"
version = "0.1.0"

[[SLEEFPirates]]
deps = ["IfElse", "Static", "VectorizationBase"]
git-tree-sha1 = "1410aad1c6b35862573c01b96cd1f6dbe3979994"
uuid = "476501e8-09a2-5ece-8869-fb82de89a1fa"
version = "0.6.28"

[[SafeTestsets]]
deps = ["Test"]
git-tree-sha1 = "36ebc5622c82eb9324005cc75e7e2cc51181d181"
uuid = "1bc83da4-3b8d-516f-aca4-4fe02f6d838f"
version = "0.0.1"

[[SciMLBase]]
deps = ["ArrayInterface", "CommonSolve", "ConstructionBase", "Distributed", "DocStringExtensions", "IteratorInterfaceExtensions", "LinearAlgebra", "Logging", "RecipesBase", "RecursiveArrayTools", "StaticArrays", "Statistics", "Tables", "TreeViews"]
git-tree-sha1 = "ad2c7f08e332cc3bb05d33026b71fa0ef66c009a"
uuid = "0bca4576-84f4-4d90-8ffe-ffa030f20462"
version = "1.19.4"

[[Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[Setfield]]
deps = ["ConstructionBase", "Future", "MacroTools", "Requires"]
git-tree-sha1 = "def0718ddbabeb5476e51e5a43609bee889f285d"
uuid = "efcf1570-3423-57d1-acb7-fd33fddbac46"
version = "0.8.0"

[[SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

[[SimpleTraits]]
deps = ["InteractiveUtils", "MacroTools"]
git-tree-sha1 = "5d7e3f4e11935503d3ecaf7186eac40602e7d231"
uuid = "699a6c99-e7fa-54fc-8d76-47d257e15c1d"
version = "0.9.4"

[[SimplexGridFactory]]
deps = ["DocStringExtensions", "ElasticArrays", "ExtendableGrids", "GridVisualize", "LinearAlgebra", "Printf", "Test"]
git-tree-sha1 = "9789d88e28d43355d1c4293943d320dc1a755de8"
uuid = "57bfcd06-606e-45d6-baf4-4ba06da0efd5"
version = "0.5.3"

[[Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "b3363d7460f7d098ca0912c69b082f75625d7508"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.0.1"

[[SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[SparseDiffTools]]
deps = ["Adapt", "ArrayInterface", "Compat", "DataStructures", "FiniteDiff", "ForwardDiff", "Graphs", "LinearAlgebra", "Requires", "SparseArrays", "StaticArrays", "VertexSafeGraphs"]
git-tree-sha1 = "f87076b43379cb0bd9f421cfe7c649fb510d8e4e"
uuid = "47a9eef4-7e08-11e9-0b38-333d64bd3804"
version = "1.18.1"

[[SparsityDetection]]
deps = ["Cassette", "DocStringExtensions", "LinearAlgebra", "SparseArrays", "SpecialFunctions"]
git-tree-sha1 = "9e182a311d169cb9fe0c6501aa252983215fe692"
uuid = "684fba80-ace3-11e9-3d08-3bc7ed6f96df"
version = "0.3.4"

[[SpecialFunctions]]
deps = ["ChainRulesCore", "IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "f0bccf98e16759818ffc5d97ac3ebf87eb950150"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "1.8.1"

[[SplittablesBase]]
deps = ["Setfield", "Test"]
git-tree-sha1 = "39c9f91521de844bad65049efd4f9223e7ed43f9"
uuid = "171d559e-b47b-412a-8079-5efa626c420e"
version = "0.1.14"

[[Static]]
deps = ["IfElse"]
git-tree-sha1 = "e7bc80dc93f50857a5d1e3c8121495852f407e6a"
uuid = "aedffcd0-7271-4cad-89d0-dc628f76c6d3"
version = "0.4.0"

[[StaticArrays]]
deps = ["LinearAlgebra", "Random", "Statistics"]
git-tree-sha1 = "3c76dde64d03699e074ac02eb2e8ba8254d428da"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.2.13"

[[Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[StatsAPI]]
git-tree-sha1 = "1958272568dc176a1d881acb797beb909c785510"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.0.0"

[[StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "eb35dcc66558b2dda84079b9a1be17557d32091a"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.33.12"

[[StatsFuns]]
deps = ["ChainRulesCore", "InverseFunctions", "IrrationalConstants", "LogExpFunctions", "Reexport", "Rmath", "SpecialFunctions"]
git-tree-sha1 = "385ab64e64e79f0cd7cfcf897169b91ebbb2d6c8"
uuid = "4c63d2b9-4356-54db-8cca-17b64c39e42c"
version = "0.9.13"

[[SteadyStateDiffEq]]
deps = ["DiffEqBase", "DiffEqCallbacks", "LinearAlgebra", "NLsolve", "Reexport", "SciMLBase"]
git-tree-sha1 = "3e057e1f9f12d18cac32011aed9e61eef6c1c0ce"
uuid = "9672c7b4-1e72-59bd-8a11-6ac3964bc41f"
version = "1.6.6"

[[StochasticDiffEq]]
deps = ["Adapt", "ArrayInterface", "DataStructures", "DiffEqBase", "DiffEqJump", "DiffEqNoiseProcess", "DocStringExtensions", "FillArrays", "FiniteDiff", "ForwardDiff", "LinearAlgebra", "Logging", "MuladdMacro", "NLsolve", "OrdinaryDiffEq", "Random", "RandomNumbers", "RecursiveArrayTools", "Reexport", "SparseArrays", "SparseDiffTools", "StaticArrays", "UnPack"]
git-tree-sha1 = "d6756d0c66aecd5d57ad9d305d7c2526fb5922d9"
uuid = "789caeaf-c7a9-5a7d-9973-96adeb23e2a0"
version = "6.41.0"

[[StrideArraysCore]]
deps = ["ArrayInterface", "CloseOpenIntervals", "IfElse", "LayoutPointers", "ManualMemory", "Requires", "SIMDTypes", "Static", "ThreadingUtilities"]
git-tree-sha1 = "12cf3253ebd8e2a3214ae171fbfe51e7e8d8ad28"
uuid = "7792a7ef-975c-4747-a70f-980b88e8d1da"
version = "0.2.9"

[[StructArrays]]
deps = ["Adapt", "DataAPI", "StaticArrays", "Tables"]
git-tree-sha1 = "2ce41e0d042c60ecd131e9fb7154a3bfadbf50d3"
uuid = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
version = "0.6.3"

[[SuiteSparse]]
deps = ["Libdl", "LinearAlgebra", "Serialization", "SparseArrays"]
uuid = "4607b0f0-06f3-5cda-b6b1-a6196a1729e9"

[[SuiteSparse_jll]]
deps = ["Artifacts", "Libdl", "OpenBLAS_jll"]
uuid = "bea87d4a-7f5b-5778-9afe-8cc45184846c"

[[Sundials]]
deps = ["CEnum", "DataStructures", "DiffEqBase", "Libdl", "LinearAlgebra", "Logging", "Reexport", "SparseArrays", "Sundials_jll"]
git-tree-sha1 = "12d529a67c232bd27e9868fbcfad4997435786a5"
uuid = "c3572dad-4567-51f8-b174-8c6c989267f4"
version = "4.6.0"

[[Sundials_jll]]
deps = ["CompilerSupportLibraries_jll", "Libdl", "OpenBLAS_jll", "Pkg", "SuiteSparse_jll"]
git-tree-sha1 = "013ff4504fc1d475aa80c63b455b6b3a58767db2"
uuid = "fb77eaff-e24c-56d4-86b1-d163f2edb164"
version = "5.2.0+1"

[[SymbolicUtils]]
deps = ["AbstractTrees", "Bijections", "ChainRulesCore", "Combinatorics", "ConstructionBase", "DataStructures", "DocStringExtensions", "DynamicPolynomials", "IfElse", "LabelledArrays", "LinearAlgebra", "Metatheory", "MultivariatePolynomials", "NaNMath", "Setfield", "SparseArrays", "SpecialFunctions", "StaticArrays", "TermInterface", "TimerOutputs"]
git-tree-sha1 = "5255e65d129c8edbde92fd2ede515e61098f93df"
uuid = "d1185830-fcd6-423d-90d6-eec64667417b"
version = "0.18.1"

[[Symbolics]]
deps = ["ConstructionBase", "DataStructures", "DiffRules", "Distributions", "DocStringExtensions", "DomainSets", "IfElse", "Latexify", "Libdl", "LinearAlgebra", "MacroTools", "Metatheory", "NaNMath", "RecipesBase", "Reexport", "Requires", "RuntimeGeneratedFunctions", "SciMLBase", "Setfield", "SparseArrays", "SpecialFunctions", "StaticArrays", "SymbolicUtils", "TermInterface", "TreeViews"]
git-tree-sha1 = "56272fc85e8d99332149fece99284ee31a9fa101"
uuid = "0c5d862f-8b57-4792-8d23-62f2024744c7"
version = "4.1.0"

[[TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"

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

[[TermInterface]]
git-tree-sha1 = "7aa601f12708243987b88d1b453541a75e3d8c7a"
uuid = "8ea1fca8-c5ef-4a55-8b96-4e9afe9c9a3c"
version = "0.2.3"

[[Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[ThreadingUtilities]]
deps = ["ManualMemory"]
git-tree-sha1 = "03013c6ae7f1824131b2ae2fc1d49793b51e8394"
uuid = "8290d209-cae3-49c0-8002-c8c24d57dab5"
version = "0.4.6"

[[ThreadsX]]
deps = ["ArgCheck", "BangBang", "ConstructionBase", "InitialValues", "MicroCollections", "Referenceables", "Setfield", "SplittablesBase", "Transducers"]
git-tree-sha1 = "abcff3ac31c7894550566be533b512f8b059104f"
uuid = "ac1d9e8a-700a-412c-b207-f0111f4b6c0d"
version = "0.1.8"

[[TimerOutputs]]
deps = ["ExprTools", "Printf"]
git-tree-sha1 = "7cb456f358e8f9d102a8b25e8dfedf58fa5689bc"
uuid = "a759f4b9-e2f1-59dc-863e-4aeb61b1ea8f"
version = "0.5.13"

[[Tokenize]]
git-tree-sha1 = "0952c9cee34988092d73a5708780b3917166a0dd"
uuid = "0796e94c-ce3b-5d07-9a54-7f471281c624"
version = "0.5.21"

[[TranscodingStreams]]
deps = ["Random", "Test"]
git-tree-sha1 = "216b95ea110b5972db65aa90f88d8d89dcb8851c"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.9.6"

[[Transducers]]
deps = ["Adapt", "ArgCheck", "BangBang", "Baselet", "CompositionsBase", "DefineSingletons", "Distributed", "InitialValues", "Logging", "Markdown", "MicroCollections", "Requires", "Setfield", "SplittablesBase", "Tables"]
git-tree-sha1 = "bccb153150744d476a6a8d4facf5299325d5a442"
uuid = "28d57a85-8fef-5791-bfe6-a80928e7c999"
version = "0.4.67"

[[TreeViews]]
deps = ["Test"]
git-tree-sha1 = "8d0d7a3fe2f30d6a7f833a5f19f7c7a5b396eae6"
uuid = "a2a6695c-b41b-5b7d-aed9-dbfdeacea5d7"
version = "0.3.0"

[[Triangle_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "bfdd9ef1004eb9d407af935a6f36a4e0af711369"
uuid = "5639c1d2-226c-5e70-8d55-b3095415a16a"
version = "1.6.1+0"

[[TriangularSolve]]
deps = ["CloseOpenIntervals", "IfElse", "LayoutPointers", "LinearAlgebra", "LoopVectorization", "Polyester", "Static", "VectorizationBase"]
git-tree-sha1 = "ec9a310324dd2c546c07f33a599ded9c1d00a420"
uuid = "d5829a12-d9aa-46ab-831f-fb7c9ab06edf"
version = "0.1.8"

[[Triangulate]]
deps = ["DocStringExtensions", "Libdl", "Printf", "Test", "Triangle_jll"]
git-tree-sha1 = "2b4f716b192c0c615d96d541ee029e85666388cb"
uuid = "f7e6ffb2-c36d-4f8f-a77e-16e897189344"
version = "2.1.0"

[[URIs]]
git-tree-sha1 = "97bbe755a53fe859669cd907f2d96aee8d2c1355"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.3.0"

[[UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[UnPack]]
git-tree-sha1 = "387c1f73762231e86e0c9c5443ce3b4a0a9a0c2b"
uuid = "3a884ed6-31ef-47d7-9d2a-63182c4928ed"
version = "1.0.2"

[[Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[Unitful]]
deps = ["ConstructionBase", "Dates", "LinearAlgebra", "Random"]
git-tree-sha1 = "0992ed0c3ef66b0390e5752fe60054e5ff93b908"
uuid = "1986cc42-f94f-5a68-af5c-568840ba703d"
version = "1.9.2"

[[VectorizationBase]]
deps = ["ArrayInterface", "CPUSummary", "HostCPUFeatures", "Hwloc", "IfElse", "LayoutPointers", "Libdl", "LinearAlgebra", "SIMDTypes", "Static"]
git-tree-sha1 = "5239606cf3552aff43d79ecc75b1af1ce4625109"
uuid = "3d5dd08c-fd9d-11e8-17fa-ed2836048c2f"
version = "0.21.21"

[[VersionParsing]]
git-tree-sha1 = "e575cf85535c7c3292b4d89d89cc29e8c3098e47"
uuid = "81def892-9a0e-5fdd-b105-ffc91e053289"
version = "1.2.1"

[[VertexSafeGraphs]]
deps = ["Graphs"]
git-tree-sha1 = "8351f8d73d7e880bfc042a8b6922684ebeafb35c"
uuid = "19fa3120-7c27-5ec5-8db8-b0b0aa330d6f"
version = "0.2.0"

[[VoronoiFVM]]
deps = ["DiffResults", "DocStringExtensions", "ExtendableGrids", "ExtendableSparse", "ForwardDiff", "GridVisualize", "IterativeSolvers", "JLD2", "LinearAlgebra", "Printf", "RecursiveArrayTools", "SparseArrays", "SparseDiffTools", "SparsityDetection", "StaticArrays", "SuiteSparse", "Test"]
git-tree-sha1 = "679fd7b10ea44e39eb9e83b256c410eb75d96ffc"
uuid = "82b139dc-5afc-11e9-35da-9b9bdfd336f3"
version = "0.10.12"

[[Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"

[[ZygoteRules]]
deps = ["MacroTools"]
git-tree-sha1 = "8c1a8e4dfacb1fd631745552c8db35d0deb09ea0"
uuid = "700de1a5-db45-46bc-99cf-38207098b444"
version = "0.2.2"

[[nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"

[[p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
"""

# ╔═╡ Cell order:
# ╟─b7d13a60-8370-11eb-3a14-1df66337bc34
# ╟─6c221d04-863c-11eb-0bf8-41f7a6288b66
# ╟─68847d40-863c-11eb-18d3-e1060d831230
# ╟─b0581c08-863c-11eb-0d81-d59ac5f24479
# ╟─0d1ef53a-85c8-11eb-13ef-952df60b51b0
# ╟─174e53bc-863f-11eb-169d-2fe8a9b2adfb
# ╟─d2f59d32-863a-11eb-2ffe-37e8d2a06d27
# ╟─7cb4be3c-8372-11eb-17cc-ad4f68a34e72
# ╟─3a462e56-8371-11eb-0503-bf8ebd33276b
# ╟─00bcd2be-8373-11eb-368e-61b2cdc2ab74
# ╟─d0c8331e-840b-11eb-249b-5bba159d0d60
# ╟─3b05b78a-83e9-11eb-3d9e-8dda5fb67594
# ╟─151c3696-840e-11eb-0cd6-d91971fcf502
# ╟─5062ea76-83e9-11eb-26ad-cb5cb7746014
# ╟─0d9b6474-85e8-11eb-24a1-e7c037afb546
# ╟─47127b3a-83e9-11eb-22cf-9904b800edeb
# ╟─2f1894e0-842c-11eb-2489-ab7cbaa2fe68
# ╟─86f5e288-85b4-11eb-133e-25e1fbe363da
# ╟─5dd7b7b6-8634-11eb-37d0-f13485dca6a0
# ╟─568527e0-8374-11eb-17b8-7d100bbd8e37
# ╠═c42de0a2-8374-11eb-2bf2-e11a848bf099
# ╠═296637fc-8376-11eb-0fef-050bf60bb7ff
# ╟─045e2078-8641-11eb-188f-a98971dc8155
# ╠═8aa0565e-85cd-11eb-32de-739cf53f6419
# ╟─8773d184-8375-11eb-0e52-53c2df5dff93
# ╠═ebf09b36-8374-11eb-06a5-f3baec9932c2
# ╟─caf52886-8375-11eb-3cf8-a949cf8a3a25
# ╟─f7f2cb36-8375-11eb-0c40-c5063c068bef
# ╟─9507b252-837a-11eb-332e-117ceb07cf2b
# ╟─5d5cef6a-85ba-11eb-263e-0dcbcb148ac0
# ╟─6fb193dc-837b-11eb-0380-3136d173692b
# ╟─69e51df4-8379-11eb-12c6-93e6d605be60
# ╠═b7872370-8376-11eb-0abb-5ba2ba60697f
# ╟─ccbd1974-8642-11eb-39db-212dcf3821fc
# ╠═bd938738-8379-11eb-2e7b-3521b0c4d225
# ╟─192ee390-8379-11eb-1666-9bd411478d4d
# ╠═04d59916-8379-11eb-0c09-d91190563a84
# ╟─3e02d072-837a-11eb-2838-259e4228d577
# ╠═e134f5a6-8378-11eb-0766-657ab2915de3
# ╟─9eae6a52-837b-11eb-1f08-ff6a44398858
# ╟─518b68fe-8643-11eb-3243-719110f74026
# ╠═544c6a08-81dd-11eb-301f-df0c8194d88f
# ╟─92e1351e-837c-11eb-3b02-33ccb80a48d8
# ╠═63e18f7a-837c-11eb-0285-b76ef6d38a1f
# ╠═549161a6-81df-11eb-2de0-f5629bcd3005
# ╟─563e9540-840d-11eb-2a8b-5fca30564841
# ╟─bfe00216-81e7-11eb-16a1-3f1436253097
# ╠═d05f97e2-85ba-11eb-06ea-c933332c0630
# ╠═244e9f36-837e-11eb-1a02-a1989909f58f
# ╟─255b62e0-8380-11eb-1c58-7fb1c067f0e5
# ╠═ff99425c-837f-11eb-2217-e54e40a5a314
# ╟─1fc5d0ee-85bb-11eb-25d8-69151e6dafc2
# ╠═5ab844b2-8380-11eb-3eff-f562f445b06f
# ╠═8214acb2-8380-11eb-2d24-1bef38c4e1da
# ╠═919677d6-8380-11eb-3e1c-152fea8b92ec
# ╠═c41db0b8-8380-11eb-14cc-71af2cd90a9f
# ╟─71e783ea-8381-11eb-3eaa-5142de7bbd68
# ╟─d39e6472-8594-11eb-07d6-8961306a6a44
# ╟─d6076ec0-8594-11eb-154d-1dc03499315f
# ╟─dc76902a-85c8-11eb-24a5-5b456ad625d9
# ╟─eedfd550-85cd-11eb-1bbf-4daf6fc4d019
# ╟─5e0307a2-85be-11eb-2295-3d1f2b01256b
# ╟─d0e82116-85bf-11eb-1580-c5cb1efc1ba1
# ╟─b1d732c0-8381-11eb-0d91-eb04784ec1cb
# ╠═092e6940-8598-11eb-335d-9fd32dadd468
# ╟─62cc9dea-8382-11eb-0552-f3858008c864
# ╠═be46f34a-8383-11eb-2972-87f7ef807ebe
# ╟─488377d4-8593-11eb-2f16-1b031f62537b
# ╟─07923cf2-85c9-11eb-0563-3b29940f50bb
# ╟─ad3a5aac-8382-11eb-140b-c10660fd8c61
# ╟─99ce60fa-85e2-11eb-29af-a5f0feb65191
# ╠═ae80e57c-85e2-11eb-1297-3b0219a7af3b
# ╟─89607c62-85e2-11eb-25b7-8b5cb4771d02
# ╠═9c94a022-8382-11eb-38ad-adc4d894e517
# ╟─dca25088-8382-11eb-0584-399677021678
# ╠═d2bfa708-8382-11eb-3bab-07447ecb4adb
# ╠═845f6460-8382-11eb-21b0-b7082bdd66e3
# ╟─7b954d3c-8593-11eb-0cfc-2b1a0e51d6e6
# ╠═5c82b6bc-8383-11eb-192e-71e5336e0425
# ╠═3aed6f3c-85be-11eb-30ae-6170b11fc0a1
# ╟─01415fe2-8644-11eb-1fad-51fc9957aea8
# ╟─1a6fbeb4-8644-11eb-00d9-832a003ccd4b
# ╟─61666f48-8644-11eb-36a6-35129059c0fd
# ╟─79a8c4a4-8593-11eb-0e16-99a6cff3040e
# ╠═cf503e46-85bb-11eb-2ae7-e959707a01a9
# ╠═d84c89de-8384-11eb-28aa-132d56751734
# ╠═20fc42e6-8385-11eb-1b8d-c70dcb798cff
# ╠═ffd27a44-8385-11eb-150e-2f9a8bc48ec7
# ╟─c7cf0430-85bc-11eb-1527-b152703c025c
# ╠═099134de-85be-11eb-2aed-812180c08921
# ╠═528624f4-85c3-11eb-1579-cb4852b9904b
# ╟─52fc31d1-d41b-410d-bb07-17b991d34f05
# ╟─c06c99c8-85bc-11eb-29b5-694d7fab6673
# ╟─0c0a4210-8386-11eb-08a2-ff3625833da3
# ╟─51a150ee-8388-11eb-33e2-fb03cf4c0c76
# ╟─be8470e0-8594-11eb-2d55-657b74d82ccb
# ╟─50602f28-85da-11eb-1f03-5d33ec4ee42e
# ╟─913c1c76-8645-11eb-24b6-47bc88ad6f5d
# ╟─da9158d6-85ce-11eb-3494-6bbd1b790284
# ╟─4563f38a-8389-11eb-0596-81019d2948c8
# ╠═134530ae-85c2-11eb-1556-a3aa72624a7a
# ╟─b6dacce0-838c-11eb-18ca-fd4e85901bde
# ╠═f9479696-838a-11eb-22cd-13f069f2dc9a
# ╟─f95fed4c-85c2-11eb-2b76-a94551adbec1
# ╠═87dca836-85b3-11eb-1d28-73c08f594823
# ╠═f50ae9c4-838b-11eb-1822-499d9f4afbe4
# ╠═0bfe0312-838c-11eb-06d2-dbefd908b8ae
# ╟─b272ebcc-85c3-11eb-1fad-bf71ffde1a6c
# ╟─f6a6c162-b795-46e3-9229-ecad67836fb3
# ╟─05910082-85c4-11eb-2bd2-556c9e2c1975
# ╠═f572f800-8388-11eb-2774-95a3ff9a3ad6
# ╟─4fdf3a96-85c4-11eb-2f44-bd15bdf02dec
# ╠═4cf131ae-85c4-11eb-28c6-a9d9a73d681e
# ╟─c0f97390-85c4-11eb-2398-8d96e73caae2
# ╠═e9ce479c-85c3-11eb-0a14-e10dfe1dceb9
# ╟─a0161bd8-85c4-11eb-2366-45621bbe59b4
# ╠═ebcd0b92-8388-11eb-02f3-99334d45c9be
# ╟─3199edda-85c5-11eb-2da5-0dafc6cd7b84
# ╠═95c2ce84-85c3-11eb-37a7-bf13754d062c
# ╟─d3d7a9e4-838a-11eb-3e70-9525fb60e1c1
# ╠═0eb76256-8389-11eb-2e40-0d4e94c1d18d
# ╟─fb4690e2-838e-11eb-38e9-29168d5f6360
# ╟─4d14735c-8647-11eb-2891-91d1bc0fe717
# ╟─4446bc76-8647-11eb-3d4b-af4000b83024
# ╟─07658648-8596-11eb-12f2-7564ab864a2e
# ╟─df0cd404-85da-11eb-3274-51394b5edfa8
# ╠═e44bb844-85cc-11eb-05c9-cdaaa914d6c1
# ╠═f94316ca-85cc-11eb-1d6b-8ba91fe99cb5
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
