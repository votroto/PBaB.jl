using ProgressMeter
using Base.Threads: Atomic, atomic_add!


mutable struct Logger{O,G}
	io::O
	gap::G
	nodes_solved::Atomic{Int}
end

function logger(io::IO, gap)
	progress = ProgressThresh(gap; desc="B&B:", output=io, showspeed=true)
	ProgressMeter.update!(progress, typemax(gap))
	Logger(progress, gap, Atomic{Int}(1))
end

function update!(l::Logger{<:ProgressThresh}, inc, prior, lower, upper, rest...)
	vals = [(:lower, lower), (:feasible, upper)]
	ProgressMeter.update!(l.io, inc - prior, showvalues=vals)
	atomic_add!(l.nodes_solved, 1)
end

finish!(l::Logger{<:ProgressThresh}) = ProgressMeter.finish!(l.io)

stats(l::Logger) = (nodes_solved = l.nodes_solved[],)