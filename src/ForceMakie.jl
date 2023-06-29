module ForceMakie

using ForceAnalysis
using ColorSchemes
using CairoMakie

export plot_av_profile,
       plot_good_bad

function plot_good_bad(fig::Figure,
                    force::Matrix;
                    zero_sample::Int = 0,
                    ylims::UnitRange{Int}=-2000:2000,
                    good_trials::Union{Nothing, AbstractVector{Bool}}=nothing,
                    colors_good = RGBAf(0.2, 0.6, 0.2, 0.5),
                    color_bad = RGBAf(0.9, 0.4, 0.4, 0.5),
                    marker::Union{Nothing, AbstractVector{Int}} = nothing,
                    linewidth::Int=2,
                    info_text::AbstractString = "")
    plot_good_bad(Axis(fig[1, 1]),
                    force;
                    zero_sample,
                    ylims,
                    good_trials,
                    colors_good ,
                    color_bad ,
                    marker,
                    linewidth,
                    info_text)

end

function plot_good_bad(ax::Axis,
                force::Matrix;
                zero_sample::Int = 0,
                ylims::UnitRange{Int}=-2000:2000,
                good_trials::Union{Nothing, AbstractVector{Bool}}=nothing,
                colors_good = RGBAf(0.2, 0.6, 0.2, 0.5),
                color_bad = RGBAf(0.9, 0.4, 0.4, 0.5),
                marker::Union{Nothing, AbstractVector{Int}} = nothing,
                linewidth::Int=2,
                info_text::AbstractString = "")
    nrow = size(force, 1)
    if isnothing(good_trials)
        # define sample range based on zero_sample
        good_trials = repeat([true], nrow)
    end;

    xs = (1-zero_sample):(size(force, 2)-zero_sample)
    if !isnothing(marker)
        vlines!(ax, marker, linewidth = 0.5, color=:gray)
    end
    for i in 1:nrow
        if good_trials[i] == true
            col = colors_good
        else
            col = color_bad
        end
        lines!(xs, force[i, :], color=col, linewidth=linewidth)
    end
    ylims!(ax, ylims.start, ylims.stop)
    text!(ax, 0, 1,
        text = info_text,
        align = (:left, :top), offset = (4, -2),
        space = :relative, fontsize = 18)
    return nothing
end;


function plot_av_profile(fig::Figure, fp::ForceProfiles;
        group::Symbol = :all,
        colorscheme::ColorScheme = ColorSchemes.tableau_20,
        color_steps=1/8,
        marker = Int64[],
        errors=true)
    # conditions is a variable with the conditions
    # has to have the same number of elemens as rows in froce

    ax = Axis(fig[1, 1])
    force = fp.force
    xs = (1-fp.zero_sample):(size(force, 2)-fp.zero_sample)
    if length(marker) > 0
        vlines!(ax, marker, linewidth = 1.5, color=:gray)
    end
    if group == :all
        # no conditions defined
        cond_dict = Dict("all" => 1:size(force, 1))
    else
        cond_dict = Dict()
        for c in unique(fp.design[:, group])
            cond_dict[string(c)] = findall(fp.design[:, group].==c)
        end
    end

    cols = get(colorscheme, 0:color_steps:1)
    i = 0
    for k in sort(collect(keys(cond_dict)))
        i += 1
        val = column_mean(force, rows=cond_dict[k])
        lines!(xs, val, label = k, linewidth=5, color = cols[i])

        if errors
            err = column_std(force, rows=cond_dict[k]) / sqrt(length(cond_dict[k]))
            band!(xs, val+err, val-err, color = (cols[i], 0.2))
        end
    end
    return fig, ax
end;



end # module
