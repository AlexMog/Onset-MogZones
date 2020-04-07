-- Adapted from https://github.com/vrld/HC/blob/master/vector-light.lua

local sqrt, cos, sin = math.sqrt, math.cos, math.sin

function vector.str(x,y)
    return "("..tonumber(x)..","..tonumber(y)..")"
end

function vector.mul(s, x,y)
    return s*x, s*y
end

function vector.div(s, x,y)
    return x/s, y/s
end

function vector.add(x1,y1, x2,y2)
    return x1+x2, y1+y2
end

function vector.sub(x1,y1, x2,y2)
    return x1-x2, y1-y2
end

function vector.permul(x1,y1, x2,y2)
    return x1*x2, y1*y2
end

function vector.dot(x1,y1, x2,y2)
    return x1*x2 + y1*y2
end

function vector.det(x1,y1, x2,y2)
    return x1*y2 - y1*x2
end

function vector.eq(x1,y1, x2,y2)
    return x1 == x2 and y1 == y2
end

function vector.lt(x1,y1, x2,y2)
    return x1 < x2 or (x1 == x2 and y1 < y2)
end

function vector.le(x1,y1, x2,y2)
    return x1 <= x2 and y1 <= y2
end

function vector.len2(x,y)
    return x*x + y*y
end

function vector.len(x,y)
    return sqrt(x*x + y*y)
end

function vector.dist(x1,y1, x2,y2)
    return len(x1-x2, y1-y2)
end

function vector.normalize(x,y)
    local l = len(x,y)
    return x/l, y/l
end

function vector.rotate(phi, x,y)
    local c, s = cos(phi), sin(phi)
    return c*x - s*y, s*x + c*y
end

function vector.perpendicular(x,y)
    return -y, x
end

function vector.project(x,y, u,v)
    local s = (x*u + y*v) / (u*u + v*v)
    return s*u, s*v
end

function vector.mirror(x,y, u,v)
    local s = 2 * (x*u + y*v) / (u*u + v*v)
    return s*u - x, s*v - y
end
