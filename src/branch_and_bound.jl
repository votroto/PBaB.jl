
include("logger.jl")
include("pop_while.jl")
include("locking_atomic.jl")
include("concurrent_heap.jl")

function solve_root(node, bound, branch)
	lower, feasible... = bound(node)
	branches = tuple.(lower, branch(node))

	LockingAtomic(feasible), make_open_set(branches)
end

function branch_and_bound(root, bound, branch; gap=eps(), out=stderr)
	incumbent, pending = solve_root(root, bound, branch)
	not_fathom(x) = first(incumbent[]) - gap >= first(x)
	branch_iterator = PopWhile(not_fathom, pending)
	log = logger(out, gap)

	Threads.foreach(branch_iterator) do (prior, node)
		lower, feasible... = bound(node)
		branches = tuple.(lower, branch(node))

		atomic_min!(incumbent, feasible)
		pruned = filter(not_fathom, branches)
		push!(pending, pruned...)

		update!(log, first(incumbent[]), prior, lower, feasible...)
	end

	finish!(log)
	incumbent[], stats(log)
end