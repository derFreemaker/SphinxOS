local Serializable = require("//OS/System/Json/Serializable")
local Json = require("//OS/System/Json")

local SERIALIZABLE_NAME = Utils.Class.Nameof(Serializable)

---@class SphinxOS.System.Json.Serializer : object
---@field m_classes table<string, object>
---@overload fun(typeInfos: object[]?) : SphinxOS.System.Json.Serializer
local Serializer = {}

---@type SphinxOS.System.Json.Serializer
Serializer.Static__Serializer = Utils.Class.Placeholder

---@private
---@param classes object[]?
function Serializer:__init(classes)
    self.m_classes = {}

    for _, class in ipairs(classes or {}) do
        local name = Utils.Class.Nameof(class)
        self.m_classes[name] = class
    end
end

function Serializer:AddTypesFromStatic()
    for name, typeInfo in pairs(self.Static__Serializer.m_classes) do
        if not Utils.Table.ContainsKey(self.m_classes, name) then
            self.m_classes[name] = typeInfo
        end
    end
end

---@param class object
---@return SphinxOS.System.Json.Serializer
function Serializer:AddClass(class)
    if not Utils.Class.HasBase(class, SERIALIZABLE_NAME) then
        error("class type has not Core.Json.Serializable as base class", 2)
    end
    local name = Utils.Class.Nameof(class)
    if not Utils.Table.ContainsKey(self.m_classes, name) then
        self.m_classes[name] = class
    end
    return self
end

---@param classes object[]
---@return SphinxOS.System.Json.Serializer
function Serializer:AddClasses(classes)
    for _, typeInfo in ipairs(classes) do
        self:AddClass(typeInfo)
    end
    return self
end

---@private
---@param class SphinxOS.System.Json.Serializable
---@return table data
function Serializer:serializeClass(class)
    local typeInfo = Utils.Class.Typeof(class)
    if not typeInfo then
        error("unable to get type from class")
    end

    local data = { __Type = typeInfo.Name, __Data = { class:Serialize() } }

    local max = 0
    for key in next, data.__Data, nil do
        if key > max then
            max = key
        end
    end

    for i = 1, max, 1 do
        if data.__Data[i] == nil then
            data.__Data[i] = "%nil%"
        end
    end

    if type(data.__Data) == "table" then
        for key, value in next, data.__Data, nil do
            data.__Data[key] = self:serializeInternal(value)
        end
    end

    return data
end

---@private
---@param obj any
---@return table data
function Serializer:serializeInternal(obj)
    local objType = type(obj)
    if objType ~= "table" then
        if not Utils.Table.ContainsKey(Json.type_func_map, objType) then
            error("can not serialize: " .. objType .. " value: " .. tostring(obj))
            return {}
        end

        return obj
    end

    if Utils.Class.HasBase(obj, SERIALIZABLE_NAME) then
        ---@cast obj SphinxOS.System.Json.Serializable
        return self:serializeClass(obj)
    end

    for key, value in next, obj, nil do
        if type(value) == "table" then
            rawset(obj, key, self:serializeInternal(value))
        end
    end

    return obj
end

---@param obj any
---@return string str
function Serializer:Serialize(obj)
    return Json.encode(self:serializeInternal(obj))
end

---@private
---@param t table
---@return boolean isDeserializedClass
local function isDeserializedClass(t)
    if not t.__Type then
        return false
    end

    if not t.__Data then
        return false
    end

    return true
end

---@private
---@param t table
---@return object class
function Serializer:deserializeClass(t)
    local data = t.__Data

    local obj = self.m_classes[t.__Type]
    if not obj then
        error("unable to find typeInfo for class: " .. t.__Type)
    end
    ---@cast obj SphinxOS.System.Json.Serializable

    if type(data) == "table" then
        for key, value in next, data, nil do
            if value == "%nil%" then
                data[key] = nil
            end

            if type(value) == "table" then
                data[key] = self:deserializeInternal(value)
            end
        end
    end

    return obj:Static__Deserialize(table.unpack(data))
end

---@private
---@param t table
---@return any obj
function Serializer:deserializeInternal(t)
    if isDeserializedClass(t) then
        return self:deserializeClass(t)
    end

    for key, value in next, t, nil do
        if type(value) == "table" then
            t[key] = self:deserializeInternal(value)
        end
    end

    return t
end

---@param str string
---@return any obj
function Serializer:Deserialize(str)
    local obj = Json.decode(str)

    if type(obj) == "table" then
        return self:deserializeInternal(obj)
    end

    return obj
end

---@param str string
---@return boolean success, any ... results
function Serializer:TryDeserialize(str)
    local results = { pcall(self.Deserialize, self, str) }

    local success = results[1]
    table.remove(results, 1)

    return success, results
end

Utils.Class.Create(Serializer, "SphinxOS.System.Json.JsonSerializer")

Serializer.Static__Serializer = Serializer()

return Serializer
