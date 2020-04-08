-- Replaced QuadTree with Spacialhash, after benchmarks, it shows to have better performances
local spatialhash = instance(Spatialhash, 1000)

-- Rate check for collisions, instead of checking on each frame, this will avoid overusage because collisions check is heavy as f***. (even with optimizations)
local TIMER_CHECK_VALUE = 50

local id = 0
local zones = {}
local playerZones = {}
local playerDrawCollisionsState = {}
local zoneUpdate = 0

-- TODO All this project is only used for 2D collisions right now. Add the usage of "z" axis for full 3D support.
AddEvent("OnPackageStart", function()
    CreateTimer(function()
        for _, player in pairs(GetAllPlayers()) do
            local x, y, z = GetPlayerLocation(player)

            local playerCollider = newPointShape(x, y)
            -- We retrieve the objects that are in the same cell (or tree branch)
            local neighbors = spatialhash:inSameCells(playerCollider:bbox())
            rawset(neighbors, playerCollider, nil)

            if not playerZones[player] then
                playerZones[player] = {}
            end

            -- We check collisions with each object
            local collisions = {}
            for other in pairs(neighbors) do
                local collides, dx, dy = playerCollider:collidesWith(other)
                if collides then
                    rawset(collisions, other, {dx,dy, x=dx, y=dy})
                end
            end

            -- Clear zones that player is not in anymore
            for zoneId, _ in pairs(playerZones[player]) do
                if not collisions[zones[zoneId]] then
                    playerZones[player][zoneId] = nil
                    CallEvent("mogzones:zone_exit", player, zoneId)
                end
            end

            if zoneUpdate == 0 and rawget(playerDrawCollisionsState, player) then
                local toSend = {}
                local i = 1
                for neighbor in pairs(neighbors) do
                    if neighbor._type == 'circle' then
                        toSend[i] = {
                            type = 'circle',
                            x = neighbor._center.x,
                            y = neighbor._center.y,
                            radius = neighbor._radius
                        }
                    elseif neighbor._type == 'polygon' then
                        toSend[i] = {
                            type = 'polygon',
                            vertices = neighbor._polygon.vertices
                        }
                    end
                    i = i + 1
                end
                CallRemoteEvent(player, "mogzones:update_collision_shapes", json_encode(toSend))
                local cellX, cellY = spatialhash:cellCoords(x, y)
                CallRemoteEvent(player, "mogzones:update_current_cell", json_encode({
                    x = cellX * 1000,
                    y = cellY * 1000,
                    width = spatialhash.cell_size,
                    height = spatialhash.cell_size
                }))
            end

            for zone in pairs(collisions) do
                if not playerZones[player][zone.id] then
                    playerZones[player][zone.id] = true
                    CallEvent("mogzones:zone_enter", player, zone.id)
                end
            end

            zoneUpdate = (zoneUpdate + 1) % 10
        end
    end, TIMER_CHECK_VALUE)
end)

AddEvent("OnPlayerQuit", function(player)
    playerZones[player] = nil
end)

function CreateZone(shape)
    shape.id = id
    spatialhash:register(shape, shape:bbox())
    zones[id] = shape
    id = id + 1
    return id - 1
end

function DeleteZone(id)
    local shape = zones[id]
    zones[id] = nil
    spatialhash:remove(shape, shape:bbox())
end
AddFunctionExport("DeleteZone", DeleteZone)

AddFunctionExport("NewPolygonZone", function(...)
    return CreateZone(newPolygonShape(...))
end)

AddFunctionExport("NewCircleZone", function(x, y, radius)
    return CreateZone(newCircleShape(x, y, radius))
end)

AddFunctionExport("NewPointZone", function(x, y)
    return CreateZone(newPointShape(x, y))
end)

AddFunctionExport("NewRectangleZone", function(x, y, width, height)
    return CreateZone(newRectangleShape(x, y, width, height))
end)

function PlayerCollidesWithZone(player, zoneId)
    local x, y, z = GetPlayerLocation(player)

    local playerCollider = newPointShape(x, y)
    return playerCollider:collidesWith(zones[zoneId])
end
AddFunctionExport("PlayerCollidesWithZone", PlayerCollidesWithZone)

AddCommand("drawcollisions", function(player)
    local drawCollisionsState = not rawget(playerDrawCollisionsState, player)
    rawset(playerDrawCollisionsState, player, drawCollisionsState)
    CallRemoteEvent(player, "mogzones:update_draw_collisions", drawCollisionsState)
end)
