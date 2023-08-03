module ForceMakie

using Makie
using ColorTypes: Colorant
using PlotUtils: ColorGradient
import Makie:plot!

using ForceAnalysis

export 	plot!,
	plot_av_epoch!,
	plot_good_bad!,
	highlight_ranges!

include("plot_data.jl")
include("epochs.jl")

end # module
