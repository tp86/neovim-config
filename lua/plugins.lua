local with_dependencies = require("utils.deps").with_dependencies
local log = require("utils.log")
with_dependencies({ "git" }, function()
  require("plugins.plug", true)
end, log.warn("cannot install plugins due to: git not available"))
