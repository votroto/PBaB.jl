import Base: IteratorEltype, eltype, IteratorSize, SizeUnknown, iterate, isempty
import Base.Threads: foreach

using Base.Threads: nthreads, @spawn, Atomic, ReentrantLock

struct PopWhile{C,P<:Function}
    pred::P
	c::C
end

IteratorEltype(::Type{PopWhile{T}}) where {T} = IteratorEltype(T)

eltype(::Type{PopWhile{T}}) where {T} = eltype(T)

IteratorSize(::PopWhile) = SizeUnknown()

isempty(i::PopWhile) = isempty(i.c) || !i.pred(first(i.c))

function iterate(i::PopWhile, state...)
	if !isempty(i)
		pop!(i.c), nothing
	else
		nothing
	end
end

function Threads.foreach(f, iter::PopWhile; ntasks=nthreads())
	starve_check = Atomic{Bool}(false)

	while !isempty(iter)
		@sync for _ in 1:ntasks
			@spawn for item in iter
				f(item)
				starve_check[] && break
			end
			starve_check[] = true
		end
		starve_check[] = false
	end
end
