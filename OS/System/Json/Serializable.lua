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

---@param obj object
---@param ... any
---@return object obj
function Serializable.Static__Deserialize(obj, ...)
    return obj(...)
end

return Utils.Class.Create(Serializable, "SphinxOS.System.Json.Serializable", nil, { IsAbstract = true })
