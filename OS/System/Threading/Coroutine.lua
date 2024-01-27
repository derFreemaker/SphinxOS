local copy = coroutine
coroutine = nil

if not copy then
    error("global coroutine is nil")
end

return copy
