-- # functools
--
-- Tools for functional programming.

local functools = {}
local compat = require("batterypack.compat")
local dict = require("batterypack.dict")
local list = require("batterypack.list")
local id = require("batterypack.id")

local function extend(a, b)
  -- Insert indexed values `other` on `into`.
  -- Mutates and returns `into`.
  for i, v in ipairs(b) do
    table.insert(a, v)
  end
  return a
end

function functools.id(x)
  return x
end

function functools.compose2(b, a)
  return function(x)
    return b(a(x))
  end
end

function functools.compose(fns)
  a = id
  for i, b in ipairs(fns) do
    a = functools.compose2(b, a)
  end
  return a
end

function functools.partial1(f, a)
  return function(...)
    return f(a, ...)
  end
end

function functools.partial2(f, a, b)
  return function(...)
    return f(a, b, ...)
  end
end

function functools.partial3(f, a, b, c)
  return function(...)
    return f(a, b, c, ...)
  end
end

function functools.partial(f, ...)
  local head = {...}
  return function(...)
    local args = extend(head, {...})
    return f(unpack(args))
  end
end

-- Partial application for functions that take a single table argument and treat
-- it as named arguments. This allows you to bind arguments by key in any order.
-- 
-- Functions are responsible for validating they have all their required keys.
-- 
-- Returns a "partially applied" function that will merge the keyed contents of
-- `over` into the keyed contents of `under`. `over` wins any key collisions.
function functools.namedpartial(f, under)
  return function(over)
    return f(extend(extend({}, under), over))
  end
end

-- [Curry](https://en.wikipedia.org/wiki/Currying) a function of `n` arguments.
function functools.curry(f, n)
  args = {}
  local function curried(v)
    args.insert(v)
    if #args < n then
      return curried
    else
      return f(compat.unpack(args))
    end
  end
  return curried
end

-- Define a metatable for multidispatch (below) to use.
local _multidispatch = {}

function _multidispatch.__call(t, ...)
  local method = t[t._readkey(...)] or t._default
  return method(...)
end

-- Transform a function `f` into a generic multidispatch function that
-- can dispatch on all arguments. By default, dispatches on type of first
-- argument.
-- 
-- Arguments:
-- 
-- - `f`: the default function to dispatch on, if no other function is found.
-- - `readkey` (optional): decides which key to dispatch on. Uses type by default.
-- 
-- Overloading for a specific argument key: `function myfn.string(a, b) ... end`
function functools.multidispatch(f, readkey)
  return setmetatable({
    _readkey = readkey or type,
    _default = f
  }, _multidispatch)
end

-- Define a metatable for `memoize` to use.

local _memoize = {}

-- The table is a callable (can be used like a function).
function _memoize.__call(t, ...)
  local key = t[t._readkey(...)]
  if not t[key] then
    t[key] = t._f(...)
  end
  return t[key]
end

-- Memoize a function by serializing its parameters with readkey.
-- By default, will memoize on the identity of the first argument.
-- 
-- Cached keys are stored on the returned table, so you can delete or inspect
-- them.
-- @TODO consider lru caching instead of naive memoization.
function functools.memoize(f, readkey)
  return setmetatable({
    _readkey = readkey or functools.id,
    _f = f
  }, _memoize)
end

return functools