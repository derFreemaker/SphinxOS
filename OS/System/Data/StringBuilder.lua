---@class SphinxOS.System.Data.StringBuilder : object
---@field m_cache string[]
---@field m_eol string
local StringBuilder = {}

---@private
---@deprecated
---@param str string?
---@param eol string?
function StringBuilder:__init(str, eol)
    self.m_cache = { str }
    self.m_eol = eol or "\n"
end

---@param str string
function StringBuilder:Append(str)
    self.m_cache[#self.m_cache + 1] = str
end

function StringBuilder:AppendLine(str)
    self:Append(str .. self.m_eol)
end

---@private
---@deprecated
function StringBuilder:__tostring()
    return Utils.String.Join(self.m_cache, "")
end

return Utils.Class.Create(StringBuilder, "SphinxOS.System.Data.StringBuilder")
