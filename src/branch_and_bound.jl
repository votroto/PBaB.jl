
using DataStructures: BinaryMinHeap

include("pop_while.jl")
include("locking_atomic.jl")
include("concurrent_heap.jl")

function solve_root(node, bound, branch)
	lower, feasible... = bound(node)
	branches = tuple.(lower, branch(node))

	LockingAtomic(feasible), ConcurrentHeap(BinaryMinHeap(branches))
end

function branch_and_bound(root, bound, branch; gap=eps())
	incumbent, work = solve_root(root, bound, branch)
	not_fathom(x) = !isapprox(first(incumbent[]), first(x); atol=gap)
	iter = PopWhile(not_fathom, work)

	Threads.foreach(iter) do (_, node)
		lower, feasible... = bound(node)
		branches = tuple.(lower, branch(node))

		atomic_min!(incumbent, feasible)
		pruned = filter(not_fathom, branches)
		push!(work, pruned...)
	end

	incumbent[]
end