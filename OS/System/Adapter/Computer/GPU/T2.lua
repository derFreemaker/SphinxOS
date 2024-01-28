local PCIDeviceReference = require("//OS/System/References/PCIDeviceReference")

---@type SphinxOS.System.Data.Cache<SphinxOS.System.References.IReference<FIN.Components.GPU_T2_C>>
local Cache = require("//OS/System/Data/Cache")()

---@class SphinxOS.System.Adapter.Computer.GPU.T2 : SphinxOS.System.IAdapter
---@field m_ref SphinxOS.System.References.IReference<FIN.Components.GPU_T2_C>
local GPUT2 = {}

---@private
---@param index number
function GPUT2:__init(index)
    if not index then
        index = 1
    end

    local success, gpu = Cache:TryGet(index)
    if not success then
        gpu = PCIDeviceReference(classes.GPU_T2_C, index)
        if not gpu:Fetch() then
            error("gpu T2 not found")
        end
        Cache:Add(index, gpu)
    end

    self.m_ref = gpu
end

--- Flushes all draw calls to the visible draw call buffer to show all changes at once. The draw buffer gets cleared afterwards.
function GPUT2:Flush()
    self.m_ref:Get():flush()
end

--- Pushes a transformation on the geometry stack. All subsequent drawcalls will be transformed through all previously pushed geometries and this one.
--- Be aware, only all draw calls till, this geometry gets pop'ed are transformed, previous draw calls (and draw calls after the pop) are unaffected by this.
---@param translation FIN.Components.Vector2D The local translation that is supposed to happen to all further drawcalls. Translation can be also thought as 'repositioning'.
---@param rotation float The local rotation that gets applied to all subsequent draw calls. The origin of the rotation is the whole screens center point. The value is in degrees.
---@param scale FIN.Components.Vector2D The scale that gets applied to the whole screen localy along the (rotated) axis. No change in scale is (1,1).
function GPUT2:pushTransform(translation, rotation, scale)
    self.m_ref:Get():flush()
end

--- Pushes a layout to the geometry stack. All subsequent drawcalls will be transformed through all previously pushed geometries and this one.
--- Be aware, only all draw calls, till this geometry gets pop'ed are transformed, previous draw calls (and draw calls after the pop) are unaffected by this.
---@param offset FIN.Components.Vector2D The local translation (or offset) that is supposed to happen to all further drawcalls. Translation can be also thought as 'repositioning'.
---@param size FIN.Components.Vector2D The scale that gets applied to the whole screen localy along both axis. No change in scale is 1.
---@param scale float
function GPUT2:PushLayout(offset, size, scale)
    self.m_ref:Get():pushLayout(offset, size, scale)
end

--- Pushes a rectangle to the clipping stack. All subsequent drawcalls will be clipped to only be visible within this clipping zone and all previously pushed clipping zones.
--- Be aware, only all draw calls, till this clipping zone gets pop'ed are getting clipped by it, previous draw calls (and draw calls after the pop) are unaffected by this.
---@param position FIN.Components.Vector2D The local position of the upper left corner of the clipping rectangle.
---@param size FIN.Components.Vector2D The size of the clipping rectangle.
function GPUT2:PushClipRect(position, size)
    self.m_ref:Get():pushClipRect(position, size)
end

--- Pushes a 4 pointed polygon to the clipping stack. All subsequent drawcalls will be clipped to only be visible within this clipping zone and all previously pushed clipping zones.
--- Be aware, only all draw calls, till this clipping zone gets pop'ed are getting clipped by it, previous draw calls (and draw calls after the pop) are unaffected by this.
---@param topLeft FIN.Components.Vector2D The local position of the top left point.
---@param topRight FIN.Components.Vector2D The local position of the top right point.
---@param bottomLeft FIN.Components.Vector2D The local position of the bottom left point.
---@param bottomRight FIN.Components.Vector2D The local position of the bottom right point.
function GPUT2:PushClipPolygon(topLeft, topRight, bottomLeft, bottomRight)
    self.m_ref:Get():pushClipPolygon(topLeft, topRight, bottomLeft, bottomRight)
end

--- Pops the top most geometry from the geometry stack. The latest geometry on the stack gets removed first. (Last In, First Out)
function GPUT2:PopGeometry()
    self.m_ref:Get():popGeometry()
end

--- Pops the top most clipping zone from the clipping stack. The latest clipping zone on the stack gets removed first. (Last In, First Out)
function GPUT2:PopClip()
    self.m_ref:Get():popClip()
end

---@param text string
---@param size integer
---@param monospace boolean
---@return FIN.Components.Vector2D returnValue
function GPUT2:MeasureText(text, size, monospace)
    return self.m_ref:Get():measureText(text, size, monospace)
end

--- Draws some Text at the given position (top left corner of the text), text, size, color and rotation.
---@param position FIN.Components.Vector2D The position of the top left corner of the text.
---@param text string The text to draw.
---@param size integer The font size used.
---@param color Satisfactory.Components.Color The color of the text.
---@param monospace boolean True if a monospace font should be used.
function GPUT2:DrawText(position, text, size, color, monospace)
    self.m_ref:Get():drawText(position, text, size, color, monospace)
end

--- Draws a Spline from one position to another with given directions, thickness and color.
---@param startPos FIN.Components.Vector2D The local position of the start point of the spline.
---@param startDirections FIN.Components.Vector2D The directions of the spline of how it exists the start point.
---@param endPos FIN.Components.Vector2D The local position of the end point of the spline.
---@param endDirections FIN.Components.Vector2D The direction of how the spline enters the end position.
---@param thickness float The thickness of the line drawn.
---@param color Satisfactory.Components.Color The color of the line drawn.
function GPUT2:DrawSpline(startPos, startDirections, endPos, endDirections, thickness, color)
    self.m_ref:Get():drawSpline(startPos, startDirections, endPos, endDirections, thickness, color)
end

--- Draws a rectangle with the upper left corner at the given local position, size, color and rotation around the upper left corner.
---@param position FIN.Components.Vector2D The local position of the upper left corner of the rectangle.
---@param size FIN.Components.Vector2D The size of the rectangle.
---@param color Satisfactory.Components.Color The color of the rectangle.
---@param image string If not empty string, should be image reference that should be replaced inside the rectangle.
---@param rotation float The rotation of the rectangle around the upper left corner in degrees.
function GPUT2:DrawRect(position, size, color, image, rotation)
    self.m_ref:Get():drawRect(position, size, color, image, rotation)
end

--- Draws connected lines through all given points with the given thickness and color.
---@param points FIN.Components.Vector2D[] The local points that get connected by lines one after the other.
---@param thickness float The thickness of the lines.
---@param color Satisfactory.Components.Color The color of the lines.
function GPUT2:DrawLines(points, thickness, color)
    self.m_ref:Get():drawLines(points, thickness, color)
end

--- Draws a box.
---@param settings FIN.Components.GPUT2DrawCallBox The settings of the box you want to draw.
function GPUT2:DrawBox(settings)
    self.m_ref:Get():drawBox(settings)
end

--- Draws a cubic bezier spline from one position to another with given control points, thickness and color.
---@param startPos FIN.Components.Vector2D The local position of the start point of the spline.
---@param firstControlPos FIN.Components.Vector2D The local position of the first control point.
---@param secondControlPos FIN.Components.Vector2D The local position of the second control point.
---@param endPos FIN.Components.Vector2D The local position of the end point of the spline.
---@param thickness float The thickness of the line drawn.
---@param color Satisfactory.Components.Color The color of the line drawn.
function GPUT2:DrawBezier(startPos, firstControlPos, secondControlPos, endPos, thickness, color)
    self.m_ref:Get():drawBezier(startPos, firstControlPos, secondControlPos, endPos, thickness, color)
end

return Utils.Class.Create(GPUT2, "SphinxOS.System.Adapter.Computer.GPU.T2",
    { BaseClass = require("//OS/System/Adapter/IAdapter") })
