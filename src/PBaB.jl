module PBaB

export branch_and_bound
export Sense, Minimize, Maximize

abstract type Sense end

struct MaximizeSense <: Sense end
struct MinimizeSense <: Sense end

const Maximize = MaximizeSense()
const Minimize = MinimizeSense()

include("branch_and_bound.jl")

end # module
