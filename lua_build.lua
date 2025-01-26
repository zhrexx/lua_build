-- LuaBuild - a simple building system library
-- Version: 1.0
-- Author: zhrexx
-- License: MIT
-- Repository: nil

local lua_build_system = {}
local utils = {}

local Build_Configuration = {}
Build_Configuration.__index = Build_Configuration

function Build_Configuration.new(compiler, input, output, flags, build_directory, logs_to_file)
    local self = setmetatable({}, Build_Configuration)
    self.compiler = compiler or "gcc"
    self.input = input or ""
    self.output = output or "output"
    self.flags = flags or {}
    self.build_directory = build_directory or "build"
    self.logs_to_file = logs_to_file == nil and true or logs_to_file
    return self
end

function utils.fstring(str, ...)
    local args = {...}
    return (str:gsub("%%[dsf]", function(match)
        local value = table.remove(args, 1)
        if match == "%d" then
            return math.floor(tonumber(value) or 0)
        elseif match == "%f" then
            return string.format("%.2f", tonumber(value) or 0)
        else
            return tostring(value)
        end
    end))
end

function lua_build_system.build(bconf)
    local build_start = os.time()
    local compiler = bconf.compiler
    local input = bconf.input
    local output = bconf.output
    local flags = table.concat(bconf.flags, " ")
    local build_directory = bconf.build_directory
    local logs = bconf.logs_to_file

    os.execute("mkdir -p " .. build_directory)

    local command
    if logs then
        command = utils.fstring("%s %s -o %s/%s %s > %s", compiler, input, build_directory, output, flags, "logs.log")
    else
        command = utils.fstring("%s %s -o %s/%s %s > /dev/null 2>&1", compiler, input, build_directory, output, flags)
    end

    local handle = io.popen(command)
    local result = handle:read("*a")
    local success = handle:close()

    if success then
        print(utils.fstring("Compilation of \"%s\" succeeded.", input))
    else
        if logs then
            print("Compilation failed. Check \"logs.log\" for output.")
        else
            print("Compilation failed.")
        end
    end
    local build_end = os.time()
    return (build_end - build_start)*1000
end

function utils.default_build(input_file, output)
    local bconf = Build_Configuration.new(nil, input_file, output, nil, nil, false)

    lua_build_system.build(bconf)
end

return {
    lua_build_system = lua_build_system,
    Build_Configuration = Build_Configuration,
    utils = utils,
}
