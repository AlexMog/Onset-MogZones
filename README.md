# Mog Zones
This package allows for creation of zones.  
Each zone can take multiple shapes, even custom
polygon shapes.  
The package will generate events depending on players state.  
The packages uses QuadTree to optimize collisions check.  
**WARNING** Current collisions are checked in 2D. 3D Collisions will be provided in future updates.


# Usage
```lua
local MogZones = ImportPackage("mogzones")
local helloWorldZone;

AddEvent("OnPackageStart", function()
    helloWorldZone = MogZones.NewCircleZone(0, 0, 20000)
end)

AddEvent("mogzones:zone_enter", function(player, zoneId)
    if zoneId == helloWorldZone then
        AddPlayerChat(player, "HelloWorld !")
    else
        AddPlayerChat(player, "Enter "..zoneId)
    end
end)

AddEvent("mogzones:zone_exit", function(player, zoneId)
    if zoneId == helloWorldZone then
        AddPlayerChat(player, "GoodbyeWorld !")
    else
        AddPlayerChat(player, "Exit "..zoneId)
    end
end)
```

# Available functions
```lua
--- Deletes a zone
--- @param zoneId number The ID of the zone to delete
MogZones.DeleteZone(zoneId)
--- Check if a player collides with a specific zone
MogZones.PlayerCollidesWithZone(player, zoneId)
--- Creates a new rectangle shaped zone
MogZones.NewRectangleZone(x, y, width, height)
--- Creates a zone of with and height 1
MogZones.NewPointZone(x, y)
--- Creates a circle shaped zone
MogZones.NewCircleZone(x, y, radius)
--- Creates a custom polygon zone. Each point of the polygon is assumed to followup.
--- In this example, x,y are the position of a point, x1,y1 from another point, etc.
MogZones.NewPolygonZone(x,y, x1,y1, x2,y2, ...)
```
