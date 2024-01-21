local Event = require("//OS/System/Event")

---@class SphinxOS.System.EventPull.Data
---@field Sender FIN.UUID
---@field Event string
---@field Params any[]

---@param data any[]
---@return SphinxOS.System.EventPull.Data
local function createDataObj(data)
    local eventPullData = {
        Sender = data[1],
        Event = data[2]
    }

    table.remove(data, 1)
    table.remove(data, 2)
    eventPullData.Params = data

    return eventPullData
end

---@alias SphinxOS.System.Event.Name
---|string
---|"*"

---@class SphinxOS.System.Event.EventPullHandler : object
---@field OnEventPull SphinxOS.System.Event
---@field m_events table<string, SphinxOS.System.Event>
---@field m_logger SphinxOS.System.Logging.Logger
local EventHandler = {}

---@private
---@param data any
local function onEventPull(data)
    local eventPullData = createDataObj(data)

    local allEvent = EventHandler.m_events["*"]
    if allEvent then
        allEvent:Trigger(EventHandler.m_logger, eventPullData)
        if allEvent:Count() == 0 then
            EventHandler.m_events["*"] = nil
        end
    end

    local event = EventHandler.m_events[eventPullData.Event]
    if not event then
        return
    end

    event:Trigger(EventHandler.m_logger, eventPullData)
    if event:Count() == 0 then
        EventHandler.m_events[eventPullData.Event] = nil
    end
end

---@param logger SphinxOS.System.Logging.Logger
function EventHandler.Initialize(logger)
    event.ignoreAll()
    event.clear()

    EventHandler.m_events = {}
    EventHandler.m_logger = logger
    EventHandler.OnEventPull = Event()

    return EventHandler
end

---@param signalName SphinxOS.System.Event.Name
---@return SphinxOS.System.Event
function EventHandler.GetEvent(signalName)
    local event = EventHandler.m_events[signalName]
    if event then
        return event
    end

    event = Event()
    EventHandler.m_events[signalName] = event
    return event
end

---@param signalName SphinxOS.System.Event.Name
---@param task SphinxOS.System.Threading.Task
---@return integer index
function EventHandler.AddTask(signalName, task)
    local event = EventHandler.GetEvent(signalName)
    return event:AddTask(task)
end

---@param signalName SphinxOS.System.Event.Name
---@param task SphinxOS.System.Threading.Task
---@return integer index
function EventHandler.AddTaskOnce(signalName, task)
    local event = EventHandler.GetEvent(signalName)
    return event:AddTaskOnce(task)
end

---@param signalName SphinxOS.System.Event.Name
---@param index integer
function EventHandler.Remove(signalName, index)
    local event = EventHandler.m_events[signalName]
    if not event then
        return
    end

    event:Remove(index)
end

--- Waits for an event to be handled or timeout
--- Returns true if event was handled and false if it timeout
---
---@async
---@param timeoutSeconds number?
---@return boolean gotEvent
function EventHandler.Wait(timeoutSeconds)
    EventHandler.m_logger:LogTrace('## waiting for event pull ##')
    ---@type table?
    local eventPullData = nil
    if timeoutSeconds == nil then
        eventPullData = { event.pull() }
    else
        eventPullData = { event.pull(timeoutSeconds) }
    end
    if #eventPullData == 0 then
        return false
    end

    EventHandler.m_logger:LogDebug("event with signalName: '"
        .. eventPullData[1] .. "' was received from component: "
        .. tostring(eventPullData[2]))

    EventHandler.OnEventPull:Trigger(EventHandler.m_logger, eventPullData)
    onEventPull(eventPullData)
    return true
end

--- Waits for the timeout to run out. There for handling all events in the event queue.
---
---@async
---@param timeoutSeconds number
function EventHandler.WaitForAll(timeoutSeconds)
    while EventHandler.Wait(timeoutSeconds) do
    end
end

return EventHandler
