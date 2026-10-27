local fs = require("@lune/fs")
local luau = require("@lune/luau")
local serde = require("@lune/serde")
local process = require("@lune/process")
local paths = serde.decode("json", fs.readFile(process.args[1]))
local failed = 0
for _, path in paths do
    local ok, err = pcall(luau.compile, fs.readFile(path))
    if not ok then
        failed += 1
        warn(path .. ": " .. tostring(err))
    end
end
print(string.format("Compiled %d Luau sources; %d failures", #paths, failed))
assert(failed == 0, "Luau compilation failed")
