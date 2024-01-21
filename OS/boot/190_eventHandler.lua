local logger = require("/OS/System/Logging/Logger")
local eventHandler = require("/OS/System/Event/EventPullHandler")

--//TODO: load logLevel from some kind of config
eventHandler.Initialize(logger("EventHandler", 2))
