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
	[Node(node.xs, i) for i in branches if i <= length(node.xs)]
end

# -----------------------------------------------------------------------------

function bab_finds_min(rng=MersenneTwister(2021))
	dat = -1 .* heapify(shuffle(rng, 1:100))

	root = Node(dat, 1)

	min_val, min_arg = branch_and_bound(root, bound, branch)

	@test min_val == minimum(dat)
	@test min_val == dat[min_arg]
end

function bab_solves_in_root(rng=MersenneTwister(2021))
	dat = heapify(shuffle(rng, 1:100))

	out = IOBuffer()
	root = Node(dat, 1)
	_bound = (node) -> bound(node; lb = 1)

	branch_and_bound(root, _bound, branch; out)

	@test countlines(out) <= 1
end
