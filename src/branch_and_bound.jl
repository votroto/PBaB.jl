
using DataStructures: BinaryMinHeap

include("pop_while.jl")
include("locking_atomic.jl")
include("concurrent_heap.jl")

function solve_root(node, bound, branch)
	lower, feasible = bound(node)
	branches = branch(node, lower, feasible)

	LockingAtomic(feasible), ConcurrentHeap(BinaryMinHeap(branches))
end

function branch_and_bound(root, bound, branch, fathom)
	incumbent, work = solve_root(root, bound, branch)
	not_fathom(x) = !fathom(incumbent[], x)
	iter = PopWhile(not_fathom, work)

	Threads.foreach(iter) do node
		lower, feasible = bound(node)
		branches = branch(node, lower, feasible)

		atomic_min!(incumbent, feasible)
		pruned = filter(not_fathom, branches)
		push!(work, pruned...)
	end

	incumbent[]
end