using Documenter, Literate, PDELib

function make_all()

    makedocs(
        sitename="PDELib.jl",
        modules = [PDELib],
        clean = false,
        doctest = false,
        authors = "J. Fuhrmann, Ch.Merdon. T. Streckenbach",
        repo="https://github.com/j-fu/PDELib.jl",
        pages=[ 
            "Home"=>"index.md",
            "Introductory Material"=>"intro.md",
        ],
    )
    
    if !isinteractive()
        deploydocs(repo = "github.com/WIAS-BERLIN/PDELib.jl.git",
                   devbranch = "main"
                   )
    end
end

make_all()
