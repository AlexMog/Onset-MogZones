
--[[
    Copyright (C) 2008  Samuel Stauffer <samuel@descolada.com>
    Updated by AlexMog @ 2020
]]

------------------------------------------------------------
---------------------- QuadTree class ----------------------
------------------------------------------------------------

QuadTree = {}
local QuadTree_mt = {}

function QuadTree.new(_left, _top, _width, _height, _maxObjectsPerChild)
    return setmetatable(
            {
                left   = _left,
                top    = _top,
                width  = _width,
                height = _height,
                children = nil,
                objects = {},
                count = 0,
                maxObjectsPerChild = _maxObjectsPerChild
            }, QuadTree_mt)
end

function QuadTree:subdivide()
    if self.children then
        for i,child in pairs(self.children) do
            child:subdivide()
        end
    else
        local x = self.left
        local y = self.top
        local w = math.floor(self.width / 2)
        local h = math.floor(self.height / 2)
        local maxObjectsPerChild = self.maxObjectsPerChild
        local objectsToReAdd = {}
        for k,v in pairs(self.objects) do
            self:removeObject(k)
            objectsToReAdd[k] = v
        end
        -- Note: This only works for even width/height
        --   for odd the size of the far quadrant needs to be
        --    (self.width - w, wself.height - h)
        self.children = {
            QuadTree.new(x    , y    , w, h, maxObjectsPerChild),
            QuadTree.new(x + w, y    , w, h, maxObjectsPerChild),
            QuadTree.new(x    , y + h, w, h, maxObjectsPerChild),
            QuadTree.new(x + w, y + h, w, h, maxObjectsPerChild)
        }
        for k,v in pairs(objectsToReAdd) do
            self:addObject(v)
        end
    end
end

function QuadTree:check(object, func, x, y)
    local oleft   = x or object.x
    local otop    = y or object.y
    local oright  = oleft + object.width - 1
    local obottom = otop + object.height - 1

    for i,child in pairs(self.children) do
        local left   = child.left
        local top    = child.top
        local right  = left + child.width - 1
        local bottom = top  + child.height - 1

        if oright < left or obottom < top or oleft > right or otop > bottom then
            -- Object doesn't intersect quadrant
        else
            func(child)
        end
    end
end

function QuadTree:bboxAdd(object)
    local x, y, width, height = object:bbox()
    local obj = {
        parent = object,
        x = x,
        y = y,
        width = width,
        height = height
    }
    self:addObject(obj)
    return obj
end

function QuadTree:addObject(object)
    assert(not self.objects[object], "You cannot add the same object twice to a QuadTree")

    if not self.children then
        if self.count >= self.maxObjectsPerChild then
            self:subdivide()
            self:addObject(object)
        else
            self.objects[object] = object
            self.count = self.count + 1
        end
    else
        self:check(object, function(child) child:addObject(object) end)
    end
end

function QuadTree:removeObject(object)
    if not self.children then
        self.objects[object] = nil
        self.count = self.count - 1
    else
        local x = object:getX()
        local y = object:getY()
        self:check(object,
                function(child)
                    child:removeObject(object, usePrevious)
                end, x, y)
    end
end

function QuadTree:updateObject(object)
    self:removeObject(object, true)
    self:addObject(object)
end

function QuadTree:removeAllObjects()
    if not self.children then
        self.objects = {}
        self.count = 0
    else
        for i,child in pairs(self.children) do
            child:removeAllObjects()
        end
    end
end

function QuadTree:getCollidableObjects(object)
    if not self.children then
        return self.objects
    else
        local quads = {}

        self:check(object, function (child) quads[child] = child end)
        local near = {}
        for q in pairs(quads) do
            for i,o in pairs(q:getCollidableObjects(object)) do
                -- Make sure we don't return the object itself
                if i ~= object then
                    table.insert(near, o)
                end
            end
        end

        return near
    end
end

QuadTree_mt.__index = QuadTree
