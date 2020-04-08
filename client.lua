local currentCell
local collisionShapes = {}
local drawCollisions = true

AddRemoteEvent("mogzones:update_collision_shapes", function(receivedCollisionShapes)
    collisionShapes = json_decode(receivedCollisionShapes)
end)

AddRemoteEvent("mogzones:update_current_cell", function(cellData)
    currentCell = json_decode(cellData)
end)

AddRemoteEvent("mogzones:update_draw_collisions", function(status)
    drawCollisions = status
end)

AddEvent("OnRenderHUD", function ()
    if not drawCollisions then
        return
    end
    if currentCell then
        SetDrawColor(RGB(0, 255, 0))
        DrawLine3D(currentCell.x, currentCell.y, 0, currentCell.x, currentCell.y, 100000, 5)
        DrawLine3D(currentCell.x + currentCell.width, currentCell.y, 0, currentCell.x + currentCell.width, currentCell.y, 100000, 5)
        DrawLine3D(currentCell.x, currentCell.y + currentCell.height, 0, currentCell.x, currentCell.y + currentCell.height, 100000, 5)
        DrawLine3D(currentCell.x + currentCell.width, currentCell.y + currentCell.height, 0, currentCell.x, currentCell.y, 100000, 5)
    end
    SetDrawColor(RGB(255, 0, 0))
    for key,shape in pairs(collisionShapes) do
        for i = 1,10 do
            if shape.type == 'circle' then
                DrawLine3D(shape.x, shape.y, 0, shape.x, shape.y, 100000, 5)
                DrawLine3D(shape.x - shape.radius, shape.y - shape.radius, 0, shape.x - shape.radius, shape.y - shape.radius, 100000, 5)
                DrawLine3D(shape.x - shape.radius, shape.y + shape.radius, 0, shape.x - shape.radius, shape.y + shape.radius, 100000, 5)
                DrawLine3D(shape.x + shape.radius, shape.y - shape.radius, 0, shape.x + shape.radius, shape.y - shape.radius, 100000, 5)
                DrawLine3D(shape.x + shape.radius, shape.y + shape.radius, 0, shape.x + shape.radius, shape.y + shape.radius, 100000, 5)
            elseif shape.type == 'polygon' then
                if #shape.vertices > 0 then
                    local lastVertex
                    for _, vertex in pairs(shape.vertices) do
                        if lastVertex then
                            DrawLine3D(vertex.x, vertex.y, 1000 + i * 100, lastVertex.x, lastVertex.y, 1000 + i * 100, 5)
                        end
                        lastVertex = vertex
                    end
                    DrawLine3D(lastVertex.x, lastVertex.y, 1000 + i * 100,
                            shape.vertices[1].x, shape.vertices[1].y, 1000 + i * 100, 5)
                end
            end
        end
    end
end)
