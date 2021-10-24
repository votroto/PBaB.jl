
include("logger.jl")
include("pop_while.jl")
include("locking_atomic.jl")
include("concurrent_heap.jl")

function solve_root(sense::Sense, node, bound, branch)
	lower, feasible... = bound(node)
	branches = tuple.(lower, branch(node))

	LockingAtomic(feasible), make_open_set(sense, branches)
end

isgoodenough(::MaximizeSense, a, b, atol) = isapprox(a, b; atol) || isless(a, b)
isgoodenough(::MinimizeSense, a, b, atol) = isapprox(a, b; atol) || isless(b, a)

atomic_best!(::MaximizeSense, a, b) = atomic_max!(a, b)
atomic_best!(::MinimizeSense, a, b) = atomic_min!(a, b)

function branch_and_bound(root, bound, branch; sense::Sense=Minimize, gap=eps(), out=stderr)
	incumbent, pending = solve_root(sense, root, bound, branch)
	not_fathom(x) = !isgoodenough(sense, first(x), first(incumbent[]), gap)
	branch_iterator = PopWhile(not_fathom, pending)
	log = logger(out, gap)

	Threads.foreach(branch_iterator) do (prior, node)
		best_bound, worst_bound... = bound(node)
		branches = tuple.(best_bound, branch(node))

		atomic_best!(sense, incumbent, worst_bound)
		pruned = filter(not_fathom, branches)
		push!(pending, pruned...)

		update!(log, first(incumbent[]), prior, best_bound, worst_bound...)
	end

	finish!(log)
	incumbent[], stats(log)
end