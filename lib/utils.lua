local function __NULL__() end

-- class "inheritance" by copying functions
local function inherit(class, interface, ...)
    if not interface then return end
    assert(type(interface) == "table", "Can only inherit from other classes.")

    -- __index and construct are not overwritten as for them class[name] is defined
    for name, func in pairs(interface) do
        if not class[name] then
            class[name] = func
        end
    end
    for super in pairs(interface.__is_a or {}) do
        class.__is_a[super] = true
    end

    return inherit(class, ...)
end

-- class builder
local function new(args)
    local super = {}
    local name = '<unnamed class>'
    local constructor = args or __NULL__
    if type(args) == "table" then
        -- nasty hack to check if args.inherits is a table of classes or a class or nil
        super = (args.inherits or {}).__is_a and {args.inherits} or args.inherits or {}
        name = args.name or name
        constructor = args[1] or __NULL__
    end
    assert(type(constructor) == "function", 'constructor has to be nil or a function')

    -- build class
    local class = {}
    class.__index = class
    class.__tostring = function() return ("<instance of %s>"):format(tostring(class)) end
    class.construct = constructor or __NULL__
    class.inherit = inherit
    class.__is_a = {[class] = true}
    class.is_a = function(self, other) return not not self.__is_a[other] end

    -- inherit superclasses (see above)
    inherit(class, table.unpack(super))

    -- syntactic sugar
    local meta = {
        __call = function(self, ...)
            local obj = {}
            setmetatable(obj, self)
            self.construct(obj, ...)
            return obj
        end,
        __tostring = function() return name end
    }
    return setmetatable(class, meta)
end

function class(name, prototype, parent)
    local init = prototype.init or (parent or {}).init
    return new{name = name, inherits = {prototype, parent}, init}
end
function instance(class, ...)
    return class(...)
end
