local fs=require("@lune/fs")
local luau=require("@lune/luau")
for _,name in fs.readDir("src/hunting") do
	if name:match("%.luau$") then luau.compile(fs.readFile("src/hunting/"..name));print("COMPILED",name) end
end
