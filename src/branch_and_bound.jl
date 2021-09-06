
using DataStructures: BinaryMinHeap
using ProgressMeter

include("logger.jl")
include("pop_while.jl")
include("locking_atomic.jl")
include("concurrent_heap.jl")

function solve_root(node, bound, branch)
	lower, feasible... = bound(node)
	branches = tuple.(lower, branch(node))

	LockingAtomic(feasible), ConcurrentHeap(BinaryMinHeap(branches))
end

function branch_and_bound(root, bound, branch; gap=eps(), out=stderr)
	incumbent, work = solve_root(root, bound, branch)
	not_fathom(x) = first(incumbent[]) - gap >= first(x)
	iter = PopWhile(not_fathom, work)
	log = logger(out, gap)

	Threads.foreach(iter) do (prior, node)
		lower, feasible... = bound(node)
		branches = tuple.(lower, branch(node))

		atomic_min!(incumbent, feasible)
		pruned = filter(not_fathom, branches)
		push!(work, pruned...)

		update(log, first(incumbent[]), prior, lower, feasible...)
	end

	finish(log)
	incumbent[]
end