---@class SphinxOS.System.Event : object
---@field m_funcs SphinxOS.System.Threading.Task
---@field m_onceFuncs SphinxOS.System.Threading.Task
---@overload fun() : SphinxOS.System.Event
local Event = {}

--//TODO: Event

return Utils.Class.Create(Event, "SphinxOS.System.Event")
