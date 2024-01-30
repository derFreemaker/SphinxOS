---@alias Core.Json.Serializable.Types
---| string
---| number
---| boolean
---| table
---| SphinxOS.System.Json.Serializable

---@class SphinxOS.System.Json.Serializable : object
local Serializable = {}

---@return any ...
function Serializable:Serialize()
end

Serializable.Serialize = Utils.Class.IsAbstract

---@param class object
---@param ... any
---@return object obj
function Serializable.Static__Deserialize(class, ...)
    return class(...)
end

return Utils.Class.Create(Serializable, "SphinxOS.System.Json.Serializable", { IsAbstract = true })
