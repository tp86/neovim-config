local common = require("common")
common.with_dependencies({ "git" }, function()
  require("plugins.plug", true)
end, common.warn("cannot install plugins due to: git not available"))
