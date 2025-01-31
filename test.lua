local lua_build = require("lua_build")

local build_conf = lua_build.Build_Configuration.new("gcc", "test.c", "test", nil, "build", false)
local build_time = lua_build.lua_build_system.build(build_conf)
local build_taken_str = lua_build.utils.fstring("Build taken: %d ms", build_time)
print(build_taken_str)

if lua_build.utils.get_target == "test" then
    -- Do something
end

collectgarbage("collect")