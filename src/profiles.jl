
function Makie.plot!(ax::Axis, fp::ForceProfiles;
	rows::row_ids = nothing,
	ylims::UnitRange{Int} = -2000:2000,
	colors::VecOrColorant = RGBAf(0.2, 0.6, 0.2, 0.5),
	linewidth::Integer = 2,
	marker::Union{Nothing, AbstractVector{<:Integer}} = nothing,
	marker_color::Colorant = RGBAf(0.9, 0.4, 0.4, 0.8),
	marker_linewidth::Integer = 2,
	info_text::AbstractString = "",
	resp_criterion::Union{Nothing, OnsetCriterion} = nothing,
	mark_peak::Bool = true,
	kwargs...,
)
	if !isnothing(rows)
		fp = subset(fp, rows)
	end

	if !isnothing(resp_criterion)
		resp_mark = _response_marker(fp, resp_criterion; mark_peak)
		if isnothing(marker)
			marker = resp_mark
		else
			append!(marker, resp_mark)
		end
	end

	return plot_profiles!(ax, force(fp); zero_sample = fp.zero_sample,
		ylims, colors, linewidth, marker, marker_color, marker_linewidth,
		info_text, kwargs...)
end

function Makie.plot!(fig::Figure, fp::ForceProfiles; kwargs...)
	return plot_profiles!(Axis(fig[1, 1]), fp; kwargs...)
end

function Makie.plot!(fig::Figure, profile_mtx::Matrix; kwargs...)
	return plot_profiles!(Axis(fig[1, 1]), fp; kwargs...)
end

function plot_good_bad!(ax::Axis, fp::ForceProfiles;
	rows::row_ids = nothing,
	ylims::UnitRange{Int} = -2000:2000,
	good_trials::Union{Nothing, AbstractVector{Bool}} = nothing,
	colors_good::Colorant = RGBAf(0.2, 0.6, 0.2, 0.3),
	color_bad::Colorant = RGBAf(0.9, 0.4, 0.4, 0.3),
	marker::Union{Nothing, AbstractVector{<:Integer}} = nothing,
	linewidth::Int = 2,
	info_text::AbstractString = "",
	kwargs...
)
	if isnothing(good_trials)
		# define sample range based on zero_sample
		colors = colors_good
	else
		colors = [x ? colors_good : color_bad for x in good_trials]
	end
	plot!(ax, fp; rows, ylims, colors, marker, linewidth, info_text,
				kwargs...)
	return ax
end

function plot_good_bad!(fig::Figure, fp::ForceProfiles; kwargs...)
	return plot!(Axis(fig[1, 1]), fp; kwargs...)
end


function plot_av_profile!(ax::Axis, fp::ForceProfiles;
	condition::Symbol = :all,
	marker = Int64[],
	stdev::Bool = true,
	colors::Union{<:ColorGradient, Vector{<:Colorant}, Nothing} = nothing,
	agg_fnc::Function = mean,
	linewidth::Real = 5,
	mark_ranges::Union{Nothing, Vector{UnitRange}} = nothing
)
	# conditions is a variable with the conditions
	# has to have the same number of elemens as rows in froce
	dat = force(fp)
	xs = (1-fp.zero_sample):(fp.n_samples-fp.zero_sample)
	if length(marker) > 0
		vlines!(ax, marker, linewidth=1, color = :gray)
	end

	if !isnothing(mark_ranges)
		start = [x.start for x in mark_ranges]
		stop = [x.stop for x in mark_ranges]
		vspan!(start, stop, color = (:green, 0.3))
	end

	agg_forces = aggregate(fp; condition, agg_fnc = agg_fnc)
	cond = agg_forces.design[:, condition]
	if stdev
		sd_forces = aggregate(fp; condition, agg_fnc = std)
	else
		sd_forces = nothing
	end

	if isnothing(colors)
		cols = cgrad(:roma, length(cond), categorical = true, rev=true)
	else
		cols = colors
	end
	for (i, c) in enumerate(sort(cond))
		val = vec(agg_forces.dat[cond.==c, :])
		lines!(xs, val; label = string(c), linewidth , color = cols[i])

		if !isnothing(sd_forces)
			err = vec(sd_forces.dat[cond.==c, :])
			band!(xs, val + err, val - err, color = (cols[i], 0.2))
		end
	end
	return ax
end

function plot_av_profile!(fig::Figure, fp::ForceProfiles; kwargs...)
	return plot_av_profile!(Axis(fig[1, 1]), fp; kwargs...)
end
