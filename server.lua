-- Declares a quadtree to avoid checking EVERY collisions
-- This is a common practice in video games collision checking methods
-- I assume most collisions will be at ground level, that's why this quadtree is 2D only
-- It could be readapted using a octree to have a complete 3D tree if needed
-- Or for a precompiled collision detection approach (use only static objects), kd-tree can be used too
-- In my case, I think that QuadTree must be sufficient
local quadtree = QuadTree.new(-99999999, -999999999, 999999999, 999999999, 20)

-- Rate check for collisions, instead of checking on each frame, this will avoid overusage because collisions check is heavy as f***. (event with a quadtree)
local TIMER_CHECK_VALUE = 500

local id = 0
local zones = {}
local zonesToId = {}
local playerZones = {}

-- TODO All this project is only used for 2D collisions right now. Add the usage of "z" axis for full 3D support.
AddEvent("OnPackageStart", function()
    CreateTimer(function()
        for _, player in pairs(GetAllPlayers()) do
            local x, y, z = GetPlayerLocation(player)

            local playerCollider = newPointShape(x, y)
            -- We retrieve the objects that are in the same cell (or tree branch)
            local x, y, width, height = playerCollider:bbox()
            local collidableZones = quadtree:getCollidableObjects({
                x = x,
                y = y,
                width = width,
                height = height
            })

            if not playerZones[player] then
                playerZones[player] = {}
            end

            -- Clear zones that player is not in anymore
            for zoneId, _ in pairs(playerZones[player]) do
                if not playerCollider:collidesWith(zones[zoneId].parent) then
                    playerZones[player][zoneId] = nil
                    CallEvent("mogzones:zone_exit", player, zoneId)
                end
            end

            for _, zone in pairs(collidableZones) do
                if playerCollider:collidesWith(zone.parent) then
                    local zoneId = zonesToId[zone]
                    if not playerZones[player][zoneId] then
                        playerZones[player][zoneId] = true
                        CallEvent("mogzones:zone_enter", player, zoneId)
                    end
                end
            end
        end
    end, TIMER_CHECK_VALUE)
end)

AddEvent("OnPlayerQuit", function(player)
    playerZones[player] = nil
end)

function CreateZone(shape)
    zones[id] = quadtree:bboxAdd(shape)
    zonesToId[shape] = id
    id = id + 1
    return id - 1
end
AddFunctionExport("CreateZone", CreateZone)

function DeleteZone(id)
    local zone = zones[id]
    zones[id] = nil
    zonesToId[zone] = nill
    quadtree:removeObject(zone)
end
AddFunctionExport("DeleteZone", DeleteZone)

function PlayerCollidesWithZone(player, zoneId)
    local x, y, z = GetPlayerLocation(player)

    local playerCollider = newPointShape(x, y)
    return playerCollider:collidesWith(zones[zoneId])
end
AddFunctionExport("PlayerCollidesWithZone", PlayerCollidesWithZone)
