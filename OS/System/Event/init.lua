---@class SphinxOS.System.Event : object
---@field m_funcs SphinxOS.System.Threading.Task[]
---@field m_onceFuncs SphinxOS.System.Threading.Task[]
---@overload fun() : SphinxOS.System.Event
local Event = {}

--//TODO: Event

---@private
function Event:__init()
    self.m_funcs = {}
    self.m_onceFuncs = {}
end

---@return integer
function Event:Count()
    return #self.m_funcs + #self.m_onceFuncs
end

---@param task SphinxOS.System.Threading.Task
---@return integer index
function Event:AddTask(task)
    local index = #self.m_funcs + 1
    self.m_funcs[index] = task
    return index
end

---@param task SphinxOS.System.Threading.Task
---@return integer index
function Event:AddTaskOnce(task)
    local index = #self.m_onceFuncs + 1
    self.m_onceFuncs[index] = task
    return index
end

---@param index integer
function Event:Remove(index)
    table.remove(self.m_funcs, index)
end

---@param index integer
function Event:RemoveOnce(index)
    table.remove(self.m_onceFuncs, index)
end

---@param logger SphinxOS.System.Logging.Logger?
---@param ... any
function Event:Trigger(logger, ...)
    for _, task in ipairs(self.m_funcs) do
        task:Execute(...)
        task:Close()
        if logger then
            logger:LogError(task:GetError())
        end
    end

    for _, task in ipairs(self.m_onceFuncs) do
        task:Execute(...)
        task:Close()
        if logger then
            logger:LogError(task:GetError())
        end
    end
    self.m_onceFuncs = {}
end

---@alias Core.Event.Mode
---|"Permanent"
---|"Once"

---@return table<Core.Event.Mode, SphinxOS.System.Threading.Task[]>
function Event:Listeners()
    ---@type SphinxOS.System.Threading.Task[]
    local permanentTask = {}
    for _, task in ipairs(self.m_funcs) do
        table.insert(permanentTask, task)
    end

    ---@type SphinxOS.System.Threading.Task[]
    local onceTask = {}
    for _, task in ipairs(self.m_onceFuncs) do
        table.insert(onceTask, task)
    end

    return {
        Permanent = permanentTask,
        Once = onceTask
    }
end

---@param event SphinxOS.System.Event
---@return SphinxOS.System.Event event
function Event:CopyTo(event)
    for _, listener in ipairs(self.m_funcs) do
        event:AddTask(listener)
    end

    for _, listener in ipairs(self.m_onceFuncs) do
        event:AddTaskOnce(listener)
    end

    return event
end

return Utils.Class.Create(Event, "SphinxOS.System.Event")
