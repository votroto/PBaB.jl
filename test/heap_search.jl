using DataStructures: heapify, heapleft, heapright
using Random: shuffle, MersenneTwister
using PBaB

# -----------------------------------------------------------------------------

struct Node{T}
	xs::Vector{T}
	i::Int
end

function bound(node; lb=-Inf)
	lb, node.xs[node.i], node.i
end

function branch(node)
	branches = [heapleft(node.i), heapright(node.i)]
	valid = filter((<=)(length(node.xs)), branches)
	Node.(Ref(node.xs), valid)
end

# -----------------------------------------------------------------------------

function bab_finds_max(rng=MersenneTwister(2021))
	dat = heapify(rand(rng, 100))

	out = devnull
	sense = Maximize
	root = Node(dat, 1)
	_bound = (node) -> bound(node; lb = Inf)

	res = branch_and_bound(root, _bound, branch; out, sense)
	(val, arg), stats = res

	@test val == maximum(dat)
	@test val == dat[arg]
	@test stats.nodes_solved == 100
end

function bab_finds_min(rng=MersenneTwister(2021))
	dat = -1 .* heapify(rand(rng, 100))

	out = devnull
	root = Node(dat, 1)

	(min_val, min_arg), stats = branch_and_bound(root, bound, branch; out)

	@test min_val == minimum(dat)
	@test min_val == dat[min_arg]
	@test stats.nodes_solved == 100
end

function bab_solves_in_root(rng=MersenneTwister(2021))
	dat = heapify(rand(rng, 100))

	out = devnull
	root = Node(dat, 1)
	_bound = (node) -> bound(node; lb = 1)

	_, stats = branch_and_bound(root, _bound, branch; out)

	@test stats.nodes_solved == 1
end
