module ForceMakie

using Makie
using ColorTypes: Colorant
using PlotUtils: ColorGradient
import Makie:plot!

using ForceAnalysis

export 	plot!,
	plot_profiles!,
	plot_av_profile!,
	plot_good_bad!

include("plot_data.jl")
include("profiles.jl")

end # module
