function plot_profiles!(ax::Axis, fp::ForceProfiles;
	rows::row_ids = nothing,
	ylims::UnitRange{Int} = -2000:2000,
	colors::VecOrColorant = RGBAf(0.2, 0.6, 0.2, 0.5),
	linewidth::Integer = 2,
	marker::Union{Nothing, AbstractVector{<:Integer}} = nothing,
	marker_color::Colorant = RGBAf(0.9, 0.4, 0.4, 0.8),
	marker_linewidth::Integer = 2,
	info_text::AbstractString = "",
)
	if isnothing(rows)
		rows = 1:n_profiles(fp)
	end
	profile_lines!(ax, fp, rows; colors, linewidth)
	marker!(ax, marker; linewidth = marker_linewidth, color = marker_color)
	ylims!(ax, ylims.start, ylims.stop)
	text!(ax, 0, 1,
		text = info_text,
		align = (:left, :top), offset = (4, -2),
		space = :relative, fontsize = 18)
	return nothing
end

function plot_profiles!(fig::Figure, fp::ForceProfiles; kwargs...)
	plot_profiles!(Axis(fig[1, 1]), fp; kwargs...)
end


function plot_good_bad!(ax::Axis, fp::ForceProfiles;
	rows::row_ids = nothing,
	ylims::UnitRange{Int} = -2000:2000,
	good_trials::Union{Nothing, AbstractVector{Bool}} = nothing,
	colors_good::Colorant = RGBAf(0.2, 0.6, 0.2, 0.5),
	color_bad::Colorant = RGBAf(0.9, 0.4, 0.4, 0.5),
	marker::Union{Nothing, AbstractVector{<:Integer}} = nothing,
	linewidth::Int = 2,
	info_text::AbstractString = "",
)
	if isnothing(good_trials)
		# define sample range based on zero_sample
		colors = colors_good
	else
		colors = [x ? colors_good : color_bad for x in good_trials]
	end
	plot_profiles!(ax, fp; rows, ylims, colors, marker, linewidth, info_text)
end

function plot_good_bad!(fig::Figure, fp::ForceProfiles; kwargs...)
	plot_good_bad!(Axis(fig[1, 1]), fp; kwargs...)
end


function plot_av_profile!(ax::Axis, fp::ForceProfiles;
	group::Symbol = :all,
	colorscheme::ColorScheme = ColorSchemes.tableau_20,
	color_steps = 1 / 8,
	marker = Int64[],
	errors = true,
)
	# conditions is a variable with the conditions
	# has to have the same number of elemens as rows in froce
	dat = force(fp)
	xs = (1-fp.zero_sample):(n_samples(fp)-fp.zero_sample)
	if length(marker) > 0
		vlines!(ax, marker, linewidth = 1.5, color = :gray)
	end
	if group == :all
		# no conditions defined
		cond_dict = Dict("all" => 1:n_profiles(fp))
	else
		cond_dict = Dict()
		for c in unique(fp.design[:, group])
			cond_dict[string(c)] = findall(fp.design[:, group] .== c)
		end
	end

	cols = get(colorscheme, 0:color_steps:1)
	i = 0
	for k in sort(collect(keys(cond_dict)))
		i += 1
		val = column_mean(dat, rows = cond_dict[k])
		lines!(xs, val, label = k, linewidth = 5, color = cols[i])

		if errors
			err = column_std(dat, rows = cond_dict[k]) / sqrt(length(cond_dict[k]))
			band!(xs, val + err, val - err, color = (cols[i], 0.2))
		end
	end
	return fig, ax
end

function plot_av_profile!(fig::Figure, fp::ForceProfiles; kwargs...)
	plot_av_profile!(Axis(fig[1, 1]), fp; kwargs...)
end
