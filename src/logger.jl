struct Logger{O}
	tgt::O
	gap
end

function logger(io::Base.TTY, gap)
	progress = ProgressThresh(gap; desc="B&B:", output=io, showspeed=true)
	ProgressMeter.update!(progress, typemax(gap))
	Logger(progress, gap)
end

function logger(io::IOStream, gap)
	Logger(io, gap)
end

function update(l::Logger{<:ProgressThresh}, inc, prior, lower, feas, cut)
	vals = [(:lower, lower), (:feasible, feas)]
	ProgressMeter.update!(l.tgt, inc - prior, showvalues=vals)
end

function update(l::Logger{<:IOStream}, inc, prior, lower, feas, cut)
	println(l.tgt, join([lower, feas], " "))
end

finish(l::Logger{<:ProgressThresh}) = ProgressMeter.finish!(l.tgt)

finish(l::Logger{<:IOStream}) = nothing