import Base: setindex!, getindex

mutable struct LockingAtomic{T}
	lock::ReentrantLock
	data::T

	function LockingAtomic(data::T) where T
		lock = ReentrantLock()
		new{T}(lock, data)
	end
end

_always(x...) = true

function atomic_update!(c::LockingAtomic{T}, b::T; condition=_always) where T
	if condition(c.data, b)
		lock(c.lock) do
			if condition(c.data, b)
				c.data = b
			end
		end
	end
end

getindex(c::LockingAtomic) = c.data
setindex!(c::LockingAtomic{T}, b::T) where T = lock(() -> c.data = b, c.lock)
