local fs=require('@lune/fs')
local r=require('@lune/roblox')
local serde=require('@lune/serde')
local place=r.deserializePlace(fs.readFile('HunDino_SaveGame.rbxl'))
for _,row in serde.decode('json',fs.readFile('assets/qa/bow-pet-install.json'))do
 local o=place
 for n in row.Path:gmatch('[^.]+')do o=o and o:FindFirstChild(n)end
 local a=o and o.Source:gsub('\r\n','\n'):gsub('%s+$','')or ''
 local b=fs.readFile(row.File):gsub('\r\n','\n'):gsub('%s+$','')
 if a~=b then
  local index=1;while index<=math.min(#a,#b) and a:byte(index)==b:byte(index)do index+=1 end
  print(serde.encode('json',{Path=row.Path,Native=#a,Local=#b,Index=index,Saved=a:sub(index-80,index+220),Expected=b:sub(index-80,index+220)}))
 else print('MATCH '..row.Path)end
end
