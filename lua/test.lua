local cache = require"cacher"

local source = {
    a = function()
        print("called a")
        return 5
    end
}

local cached = cache(source)

print(cached.a)
print(cached.a)
print(cached.a)
print(cached.a)
