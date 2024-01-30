local Serializable = require("//OS/System/Json/Serializable")
local Json = require("//OS/System/Json")

local SERIALIZABLE_NAME = Utils.Class.Nameof(Serializable)

---@class SphinxOS.System.Json.Serializer : object
---@field m_blueprints table<string, Freemaker.ClassSystem.Blueprint>
---@overload fun(typeInfos: object[]?) : SphinxOS.System.Json.Serializer
local Serializer = {}

---@type SphinxOS.System.Json.Serializer
Serializer.Static__Serializer = Utils.Class.Placeholder

---@private
---@param typeInfos Freemaker.ClassSystem.Type[]?
function Serializer:__init(typeInfos)
    self.m_blueprints = {}

    for _, typeInfo in ipairs(typeInfos or {}) do
        self.m_blueprints[typeInfo.Name] = typeInfo.Blueprint
    end
end

function Serializer:AddTypesFromStatic()
    for name, typeInfo in pairs(self.Static__Serializer.m_blueprints) do
        if not Utils.Table.ContainsKey(self.m_blueprints, name) then
            self.m_blueprints[name] = typeInfo
        end
    end
end

---@param typeInfo Freemaker.ClassSystem.Type
---@return SphinxOS.System.Json.Serializer
function Serializer:AddTypeInfo(typeInfo)
    if not Utils.Class.HasBase(typeInfo, SERIALIZABLE_NAME) then
        error("class type has not Core.Json.Serializable as base class", 2)
    end

    if not Utils.Table.ContainsKey(self.m_blueprints, typeInfo.Name) then
        self.m_blueprints[typeInfo.Name] = typeInfo.Blueprint
    end

    return self
end

---@param typeInfos Freemaker.ClassSystem.Type[]
---@return SphinxOS.System.Json.Serializer
function Serializer:AddTypeInfos(typeInfos)
    for _, typeInfo in ipairs(typeInfos) do
        self:AddTypeInfo(typeInfo)
    end
    return self
end

---@private
---@param class SphinxOS.System.Json.Serializable
---@return table data
function Serializer:_SerializeClass(class)
    local typeInfo = Utils.Class.Typeof(class)
    if not typeInfo then
        error("unable to get type from class")
    end

    self:AddTypeInfo(typeInfo)
    self.Static__Serializer:AddTypeInfo(typeInfo)

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
            data.__Data[key] = self:_SerializeInternal(value)
        end
    end

    return data
end

---@private
---@param obj any
---@return table data
function Serializer:_SerializeInternal(obj)
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
        return self:_SerializeClass(obj)
    end

    for key, value in next, obj, nil do
        if type(value) == "table" then
            rawset(obj, key, self:_SerializeInternal(value))
        end
    end

    return obj
end

---@param obj any
---@return string str
function Serializer:Serialize(obj)
    return Json.encode(self:_SerializeInternal(obj))
end

---@private
---@param t table
---@return boolean isDeserializedClass
local function _IsDeserializedClass(t)
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
function Serializer:_DeserializeClass(t)
    local data = t.__Data

    local obj = self.m_blueprints[t.__Type]
    if not obj then
        error("unable to find typeInfo for class: " .. t.__Type)
    end

    ---@diagnostic disable-next-line: cast-type-mismatch
    ---@cast obj SphinxOS.System.Json.Serializable

    if type(data) == "table" then
        for key, value in next, data, nil do
            if value == "%nil%" then
                data[key] = nil
            end

            if type(value) == "table" then
                data[key] = self:_DeserializeInternal(value)
            end
        end
    end

    return obj:Static__Deserialize(table.unpack(data))
end

---@private
---@param t table
---@return any obj
function Serializer:_DeserializeInternal(t)
    if _IsDeserializedClass(t) then
        return self:_DeserializeClass(t)
    end

    for key, value in next, t, nil do
        if type(value) == "table" then
            t[key] = self:_DeserializeInternal(value)
        end
    end

    return t
end

---@param str string
---@return any obj
function Serializer:Deserialize(str)
    local obj = Json.decode(str)

    if type(obj) == "table" then
        return self:_DeserializeInternal(obj)
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
