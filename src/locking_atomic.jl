import Base.Threads: atomic_min!
import Base: setindex!, getindex

mutable struct LockingAtomic{T}
	lock::ReentrantLock
	data::T

	function ConcurrentHeap(data::T) where T
		lock = ReentrantLock()
		new{T}(lock, data)
	end
end

function atomic_min!(c::LockingAtomic{T}, b::T) where T
	if c.data > b
		lock(c.lock) do
			if c.data > b
				c.data = b
			end
		end
	end
end

getindex(c::LockingAtomic) = c.data
setindex!(c::LockingAtomic{T}, b::T) where T = lock(() -> c.data = b, c.lock)
