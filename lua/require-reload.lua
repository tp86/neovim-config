local old_require = require
function require(modname, reload)
  if reload then
    package.loaded[modname] = nil
  end
  return old_require(modname)
end
