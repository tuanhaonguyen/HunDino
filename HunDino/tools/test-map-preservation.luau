local fs=require('@lune/fs'); local r=require('@lune/roblox'); local process=require('@lune/process')
local a=r.deserializePlace(fs.readFile(assert(process.args[1]))):GetService('Workspace')
local b=r.deserializePlace(fs.readFile(assert(process.args[2]))):GetService('Workspace')
local function parts(root)
 local out={}
 for _,v in root:GetDescendants() do if v:IsA('BasePart') then
  local key=v:GetFullName(); out[key]=out[key] or {}
  table.insert(out[key],table.concat({tostring(v.CFrame),tostring(v.Size),tostring(v.Color),tostring(v.Material),tostring(v.Transparency),tostring(v.Anchored),tostring(v.CanCollide)},'|'))
 end end
 for _,values in out do table.sort(values) end
 return out
end
local pa,pb=parts(a),parts(b); local n=0
for path,values in pa do assert(pb[path] and #pb[path]==#values,path..' count'); for i,value in values do assert(pb[path][i]==value,path..' geometry'); n+=1 end end
for path in pb do assert(pa[path],path..' added') end
assert(#a:GetDescendants()==#b:GetDescendants(),'workspace descendant count changed')
print('PASS preserved',n,'map parts and workspace instance count from the latest Desktop input')
