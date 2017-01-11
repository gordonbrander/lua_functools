package = "functools"
version = "scm-1"
source = {
  url = "https://github.com/gordonbrander/lua_functools"
}
description = {
  summary = "functional programming tools",
  detailed = [[Common functional programming tools, including:

  - id
  - compose
  - partial
  - namedpartial
  - curry
  - multiple dispatch
  - memoize
  ]],
  homepage = "https://github.com/gordonbrander/lua_functools",
  license = "MIT"
}
dependencies = {}
build = {
  type = "builtin",
  modules = {
    functools = "functools.lua"
  }
}
