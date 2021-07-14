
using DataStructures: BinaryMinHeap
using Base.Iterators: takewhile

include("locking_atomic.jl")
include("concurrent_heap.jl")

function solve_root(node, bound, branch)
	lower, feasible = bound(node)
	branches = branch(node, lower, feasible)

	LockingAtomic(feasible), ConcurrentHeap(BinaryMinHeap(branches))
end

function branch_and_bound(root, bound, branch, converged)
	incumbent, work = solve_root(root, bound, branch)
	iter = takewhile(!converged, work)

	Threads.foreach(iter) do node
		lower, feasible = bound(node)
		branches = branch(node, lower, feasible)

		atomic_min!(incumbent, feasible)
		if incumbent[] > lower
			push!(work, branches...)
		end
	end

	incumbent[]
end