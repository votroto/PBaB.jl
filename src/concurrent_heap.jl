import Base: eltype, IteratorSize, iterate, push!, pop!
import Base.Threads: foreach

using Base.Threads: nthreads, @spawn, Atomic, ReentrantLock
using DataStructures: AbstractHeap

mutable struct ConcurrentHeap{T}
	lock::ReentrantLock
	data::AbstractHeap{T}

	function ConcurrentHeap(data::AbstractHeap{T}) where T
		lock = ReentrantLock()
		new{T}(lock, data)
	end
end

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

function iterate(c::ConcurrentHeap, state...)
	v = pop!(c)
	if isnothing(v)
		v
	else
		v, nothing
	end
end

function Threads.foreach(f, heap::ConcurrentHeap; ntasks=nthreads())
	starve_check = Atomic{Bool}(false)

	while !isempty(heap)
		@sync for _ in 1:ntasks
			@spawn for item in heap
				stop = f(item)
				(starve_check[] || stop) && break
			end
			starve_check[] = true
		end
		starve_check[] = false
	end
end
