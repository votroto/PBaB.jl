import Base: eltype, IteratorSize, iterate, push!, pop!, isempty, first

using DataStructures: AbstractHeap, BinaryHeap

mutable struct ConcurrentHeap{T}
	lock::ReentrantLock
	data::AbstractHeap{T}

	function ConcurrentHeap(data::AbstractHeap{T}) where T
		lock = ReentrantLock()
		new{T}(lock, data)
	end
end

make_open_set(::MinimizeSense, branches) = ConcurrentHeap(BinaryHeap(Base.By(first, Base.Forward), branches))
make_open_set(::MaximizeSense, branches) = ConcurrentHeap(BinaryHeap(Base.By(first, Base.Reverse), branches))

first(c::ConcurrentHeap) = first(c.data)
isempty(c::ConcurrentHeap) = isempty(c.data)
eltype(::Type{ConcurrentHeap{T}}) where {T} = T
IteratorSize(::ConcurrentHeap) = Base.SizeUnknown()

function push!(c::ConcurrentHeap, vs...)
    lock(c.lock) do
		for v in vs
        	push!(c.data, v)
		end
	end
end

function pop!(c::ConcurrentHeap)
    lock(c.lock) do
		if isempty(c.data)
			nothing
		else
			pop!(c.data)
		end
	end
end