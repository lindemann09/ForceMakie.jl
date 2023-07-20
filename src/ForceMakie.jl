module ForceMakie

using ForceAnalysis
import ForceAnalysis: column_mean, column_median, column_std

using ColorTypes: Colorant
using PlotUtils: ColorGradient
#using ColorSchemes: color
using CairoMakie

export plot_av_profile!,
	plot_good_bad!,
	plot_profiles!

include("common.jl")
include("profiles.jl")

end # module
