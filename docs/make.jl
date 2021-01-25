using Documenter
using TcpInstruments

makedocs(
    sitename = "TcpInstruments",
    format = Documenter.HTML(),
    modules = [TcpInstruments]
)

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.
#=deploydocs(
    repo = "<repository url>"
)=#
