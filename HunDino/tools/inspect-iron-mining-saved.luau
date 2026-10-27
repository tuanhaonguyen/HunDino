-- READ ONLY. Never write/serialize a Place or decode Terrain's native voxels.
local fs=require("@lune/fs")
local r=require("@lune/roblox")
local luau=require("@lune/luau")
local serde=require("@lune/serde")
local process=require("@lune/process")
local target=process.args[1] or "HunDino_MerchantWeapons_20261026.rbxl"
local baseline=process.args[2] or "backups/iron-mining-20261026/HunDino_MerchantWeapons_20261026.rbxl"
local planPath=process.args[3] or "assets/iron-mining/iron-mining-install.json"
local reportPath=process.args[4] or "assets/iron-mining/iron-mining-saved.json"
local orePath="Workspace.HuntingRainforest.MineableIron"
local backupPath="ServerStorage.IronMiningBackup_20261026"
local checks=0
local report={Version="IronMiningSavedValidation.1",Target=target,Baseline=baseline,
	Boundary="Four original source edits, six new sources, four original StringValues and exactly thirty fixed ore models. Native Terrain bytes remain opaque."}
local function check(ok,label)checks+=1;assert(ok,label)end
local function hash(s)return serde.hash("sha256",s)end
local function norm(s)return s:gsub("\r\n","\n"):gsub("%s+$","")end
local function at(root,path)for n in path:gmatch("[^.]+")do root=root and root:FindFirstChild(n)end;return root end
local function pathOf(o)local p={};while o and not o:IsA("DataModel")do table.insert(p,1,o.Name);o=o.Parent end;return table.concat(p,".")end
local function inside(path,root)return path==root or path:sub(1,#root+1)==root.."."end
local function stable(value)
	if type(value)~="table"then return serde.encode("json",value)end
	local keys,out={},{};for k in value do table.insert(keys,k)end
	table.sort(keys,function(a,b)return tostring(a)<tostring(b)end)
	for _,k in keys do table.insert(out,stable(k)..":"..stable(value[k]))end
	return "{"..table.concat(out,",").."}"
end
local function value(v)
	local kind=typeof(v)
	if kind=="CFrame" then return {v:GetComponents()}
	elseif kind=="Vector3" then return {v.X,v.Y,v.Z}
	elseif kind=="Vector2" then return {v.X,v.Y}
	elseif kind=="Color3" then return {v.R,v.G,v.B}
	elseif kind=="Instance" then return pathOf(v)
	elseif kind=="PhysicalProperties" then return {v.Density,v.Friction,v.Elasticity,v.FrictionWeight,v.ElasticityWeight}
	elseif type(v)=="table" then local out={};for k,x in v do out[k]=value(x)end;return out
	elseif kind=="EnumItem" then return tostring(v)
	elseif type(v)=="number"or type(v)=="boolean"or type(v)=="string"then return v
	else return if v~=nil then tostring(v)else nil end
end
local function optional(o,name)local ok,v=pcall(function()return o[name]end);return if ok then value(v)else nil end
local function assets(part)
	local rows={}
	for _,o in part:GetDescendants()do
		if o:IsA("DataModelMesh")or o:IsA("SurfaceAppearance")or o:IsA("Decal")then
			local row={path=pathOf(o),class=o.ClassName,attributes=value(o:GetAttributes()),tags=o:GetTags()}
			for _,name in {"MeshId","TextureId","TextureID","MeshType","Scale","Offset","VertexColor","ColorMap","NormalMap","MetalnessMap","RoughnessMap","AlphaMode","Color","Color3","Texture","Face","Transparency","StudsPerTileU","StudsPerTileV","OffsetStudsU","OffsetStudsV","ZIndex"}do row[name]=optional(o,name)end
			table.insert(rows,stable(row))
		end
	end
	table.sort(rows);return rows
end
local function scene(root,skipOre)
	local rows={};local counts={Parts=0,Joints=0,WorkspaceParts=0,WorkspaceJoints=0}
	for _,o in root:GetDescendants()do
		local path=pathOf(o)
		if skipOre and inside(path,orePath)then continue end
		local row={path=path,class=o.ClassName}
		if o:IsA("BasePart")and not o:IsA("Terrain")then
			counts.Parts+=1;if path:sub(1,10)=="Workspace."then counts.WorkspaceParts+=1 end
			row.attributes=value(o:GetAttributes());row.tags=o:GetTags();row.assets=assets(o)
			for _,name in {"CFrame","Size","Color","Material","MaterialVariant","Transparency","Reflectance","Anchored","CanCollide","CanTouch","CanQuery","CastShadow","CollisionGroup","Massless","RootPriority","CustomPhysicalProperties","TopSurface","BottomSurface","FrontSurface","BackSurface","LeftSurface","RightSurface","Shape","MeshId","TextureID","CollisionFidelity","RenderFidelity","DoubleSided"}do row[name]=optional(o,name)end
		elseif o:IsA("JointInstance")or o:IsA("WeldConstraint")then
			counts.Joints+=1;if path:sub(1,10)=="Workspace."then counts.WorkspaceJoints+=1 end
			for _,name in {"Part0","Part1","C0","C1","Transform","Enabled"}do row[name]=optional(o,name)end
		else continue end
		table.insert(rows,stable(row))
	end
	table.sort(rows);return hash(table.concat(rows,"\n")),counts
end
local function configFrom(source)
	return luau.load(source,{environment={Vector3=r.Vector3,CFrame=r.CFrame,Color3=r.Color3,Enum=r.Enum},injectGlobals=true})()
end
local function nearFrame(a,b)
	local aa,bb={a:GetComponents()},{b:GetComponents()}
	for i=1,12 do if math.abs(aa[i]-bb[i])>.001 then return false end end
	return true
end
local function main()
	local oldBytes,bytes=fs.readFile(baseline),fs.readFile(target)
	check(#oldBytes==4373461,"Unexpected native mining baseline size")
	report.Bytes,report.SHA256,report.BaselineBytes,report.BaselineSHA256=#bytes,hash(bytes),#oldBytes,hash(oldBytes)
	local before,after=r.deserializePlace(oldBytes),r.deserializePlace(bytes)
	local rows=serde.decode("json",fs.readFile(planPath));check(#rows==10,"Expected ten iron mining source bindings")
	local allowed,newPaths={},{};local changed,newCount=0,0
	local backup=assert(at(after,backupPath),"Missing iron mining backup folder")
	check(backup:IsA("Folder")and #backup:GetChildren()==4,"Expected four original source backup values")
	check(next(backup:GetAttributes())==nil and #backup:GetTags()==0,"Unexpected backup folder metadata")
	for _,row in rows do
		local current,original=at(after,row.Path),at(before,row.Path);allowed[row.Path]=true
		check(current and current.ClassName==row.Class,"Missing binding/class: "..row.Path)
		check(norm(current.Source)==norm(fs.readFile(row.File)),"Canonical source differs: "..row.Path)
		check(#current:GetDescendants()==0,"Unexpected source descendants: "..row.Path)
		if row.Before then
			changed+=1;check(original and norm(original.Source)==norm(row.Before),"Baseline source differs: "..row.Path)
			check(stable(value(current:GetAttributes()))==stable(value(original:GetAttributes()))
				and stable(current:GetTags())==stable(original:GetTags())and current.Archivable==original.Archivable,"Original source metadata changed: "..row.Path)
			check(stable(optional(current,"Disabled"))==stable(optional(original,"Disabled"))
				and stable(optional(current,"RunContext"))==stable(optional(original,"RunContext")),"Original script execution settings changed: "..row.Path)
			local b=backup:FindFirstChild((row.Path:gsub("%.","__")))
			check(b and b:IsA("StringValue")and norm(b.Value)==norm(original.Source),"Original StringValue backup mismatch: "..row.Path)
			check(#b:GetDescendants()==0 and next(b:GetAttributes())==nil and #b:GetTags()==0,"Unexpected original backup metadata")
		else
			newCount+=1;newPaths[row.Path]=true
			check(original==nil,"New source existed before install: "..row.Path)
			check(next(current:GetAttributes())==nil and #current:GetTags()==0 and current.Archivable,"Unexpected new source metadata")
		end
	end
	check(changed==4 and newCount==6,"Expected four changed originals and six new sources")
	local scripts,oldScripts=0,0
	local function sourceRows(root,isAfter)
		local out={}
		for _,o in root:GetDescendants()do
			local path=pathOf(o)
			if o:IsA("LuaSourceContainer")then
				if isAfter then scripts+=1;check(pcall(luau.compile,o.Source),"Compile failure: "..path)else oldScripts+=1 end
				if not allowed[path]then table.insert(out,path.."|"..o.ClassName.."|"..hash(norm(o.Source)))end
			end
		end
		table.sort(out);return out
	end
	local oldSources,newSources=sourceRows(before,false),sourceRows(after,true)
	check(#oldSources==#newSources,"Unrelated source count changed")
	for i,row in oldSources do check(row==newSources[i],"Unrelated source changed: "..row)end
	check(scripts==oldScripts+6,"Only six new Lua source containers are permitted")
	local function structure(root,isAfter)
		local out={}
		for _,o in root:GetDescendants()do
			local path=pathOf(o)
			if inside(path,orePath)or inside(path,backupPath)or newPaths[path]then continue end
			local row={path=path,class=o.ClassName,attributes=value(o:GetAttributes()),tags=o:GetTags(),archivable=o.Archivable}
			if o:IsA("ValueBase")then row.storedValue=optional(o,"Value")end
			table.insert(out,stable(row))
		end
		table.sort(out);return out
	end
	local oldStructure,newStructure=structure(before,false),structure(after,true)
	check(#oldStructure==#newStructure,"Unexpected instances outside the permitted mining additions")
	for i,row in oldStructure do check(row==newStructure[i],"Original instance structure/metadata changed: "..row)end
	report.OriginalInstancesPreserved=#oldStructure
	report.ScriptsCompiled,report.BaselineScripts,report.UnrelatedSourcesPreserved=scripts,oldScripts,#oldSources
	report.SourceBindings,report.ChangedOriginalSources,report.NewSources,report.VerifiedOriginalBackups=#rows,changed,newCount,changed
	local oldHash,oldCounts=scene(before,false);local unchangedHash,counts=scene(after,true)
	check(oldHash==unchangedHash and stable(oldCounts)==stable(counts),"Geometry/joints outside the ore folder changed")
	local _,allCounts=scene(after,false)
	check(allCounts.Parts==oldCounts.Parts+1830 and allCounts.WorkspaceParts==oldCounts.WorkspaceParts+1830,"Expected exactly 1830 additional ore parts")
	check(allCounts.Joints==oldCounts.Joints and allCounts.WorkspaceJoints==oldCounts.WorkspaceJoints,"Ore may not add scene joints")
	report.PreservedSceneHash,report.PreservedGeometry,report.TotalGeometry=unchangedHash,counts,allCounts
	check(at(before,orePath)==nil,"Baseline unexpectedly already has ore")
	local folder=assert(at(after,orePath),"Fixed ore folder missing")
	local config=configFrom(assert(at(after,"ServerScriptService.HuntingRuntime.IronMiningConfig")).Source)
	check(config.Version=="IronMining.1"and config.FolderName=="MineableIron"and config.MaxHits==3,"Unexpected fixed mining configuration")
	check(config.RespawnSeconds==300 and config.StrikeSeconds==2.2 and config.Reach==9,"Unexpected mining timing/reach")
	check(folder:IsA("Folder")and #folder:GetChildren()==30 and #config.Nodes==30,"Exactly thirty configured ore models required")
	check(folder:GetAttribute("Version")==config.Version,"Ore folder version differs")
	local locations={}
	for index,row in config.Nodes do
		local code=string.format("IRON_%02d",index);local model=assert(folder:FindFirstChild(code),"Missing "..code)
		check(row.Id==code and row.Index==index and model:IsA("Model"),"Configured node identity mismatch")
		check(model:GetAttribute("MiningNodeId")==code and model:GetAttribute("MiningNodeIndex")==index,"Model node identity mismatch")
		check(model:GetAttribute("LocationName")==row.Name and model:GetAttribute("VisualVersion")=="IronOreVisual.2","Node appearance/location metadata mismatch")
		local root=model:FindFirstChild("Root")
		check(root and root:IsA("BasePart")and model.PrimaryPart==root and root.Transparency==1,"Static root/primary part mismatch")
		check(nearFrame(root.CFrame,r.CFrame.new(row.Position)*r.CFrame.Angles(0,math.rad(row.Yaw),0)),"Configured root position/yaw differs: "..code)
		local parts,groups,crystals=0,{0,0,0},0
		for _,o in model:GetDescendants()do
			if o:IsA("BasePart")then
				parts+=1;check(o.Anchored and not o.CanCollide and not o.CanQuery and not o.CanTouch,"Ore is not static/noninteractive geometry")
			elseif o:IsA("Model")then
				local group=o:GetAttribute("StrikeGroup")
				check(type(group)=="number"and group%1==0 and group>=1 and group<=3,"Crystal strike group missing/invalid")
				groups[group]+=1;crystals+=1
			else check(o:IsA("Folder"),"Runtime prompt/behavior/helper saved inside ore: "..o.ClassName)end
		end
		check(parts==61 and crystals==6 and groups[1]==2 and groups[2]==2 and groups[3]==2,"Expected 61 parts, six crystals, two per strike group")
		table.insert(locations,{Id=code,Name=row.Name,Position=value(root.Position),Parts=parts})
	end
	report.Ore={Models=30,Parts=1830,PartsPerNode=61,MaxHits=3,RespawnSeconds=config.RespawnSeconds,Locations=locations,
		Boundary="Placement coordinates match config; grounded access is validated separately in native raycast QA"}
	local account=assert(at(after,"ServerScriptService.AccountData"))
	check(account:GetAttribute("StudioMemoryTest")==nil,"Temporary TestMemory override was saved")
	check(norm(at(after,"ServerScriptService.AccountData.ProfileConfig").Source)==norm(at(before,"ServerScriptService.AccountData.ProfileConfig").Source),"Persistence configuration changed")
	for _,o in after:GetDescendants()do
		check(o.Name~="StudioProfileProbe"and not o.Name:match("^IronMiningQA")and not o.Name:match("^MiningIntegrationQA"),"Temporary mining QA instance persisted")
	end
	-- Container-only decompression: opaque Terrain property payloads are hashed,
	-- including unknown voxel fields. Never deserialize or rebuild their data.
	local opaqueSource=fs.readFile("tools/inspect-persistence-saved.luau")
	local first=assert(opaqueSource:find("local function uncompressBlock",1,true))
	local last=assert(opaqueSource:find("local function sourceBindings",first,true))
	local opaque=luau.load(opaqueSource:sub(first,last-1).."\nreturn opaqueTerrain",{environment={serde=serde,check=check,hash=hash},injectGlobals=true})()
	local oldTerrain,terrain=opaque(oldBytes),opaque(bytes);local terrainCount=0
	for name,payload in oldTerrain do
		terrainCount+=1;check(terrain[name]and terrain[name].sha256==payload.sha256 and terrain[name].bytes==payload.bytes,"Opaque Terrain changed: "..name)
	end
	local afterTerrainCount=0;for _ in terrain do afterTerrainCount+=1 end
	check(afterTerrainCount==terrainCount,"Opaque Terrain property set changed")
	report.OpaqueTerrainProperties,report.VoxelContentMap=terrainCount,terrain.VoxelGridAssetContentMap
	report.QAFlagsRemoved=true
end
local ok,err=xpcall(main,debug.traceback)
report.Ok,report.Checks=ok,checks;if not ok then report.Error=tostring(err)end
if not fs.isDir("assets/iron-mining")then fs.writeDir("assets/iron-mining")end
fs.writeFile(reportPath,serde.encode("json",report,true));print(serde.encode("json",report,true))
assert(ok,"Saved iron mining validation failed: "..tostring(err))
