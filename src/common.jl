const VecOrColorant = Union{Colorant, Base.AbstractVecOrTuple{Colorant}}
const row_ids = Union{Nothing, Integer, Base.AbstractVecOrTuple{Integer}}

function profile_lines!(ax::Axis,
	fp::ForceProfiles,
	rows::Base.AbstractVecOrTuple{Integer};
	colors::VecOrColorant,
	kwargs...,
)
	xs = (1-fp.zero_sample):(n_samples(fp)-fp.zero_sample)
	dat = force(fp)
    if colors isa Colorant
        colors = Iterators.cycle((colors, ))
    end
    @show colors
    for (i, color) in zip(rows, colors)
		lines!(xs, dat[i, :]; color, kwargs...)
	end
end

function profile_lines!(ax::Axis, fp::ForceProfiles, rows::Integer; kwargs...)
	profile_lines!(ax, fp, (rows,); kwargs...)
end

function marker!(ax::Axis, marker::AbstractVector{<:Integer};
	marker_color::Colorant = RGBAf(0.9, 0.4, 0.4, 0.8),
	marker_linewidth::Integer = 2, kwargs...,
)
	vlines!(ax, marker; linewidth = marker_linewidth, color = marker_color,
		kwargs...)
end
marker!(ax::Axis, marker::Nothing; kwargs...) = nothing

