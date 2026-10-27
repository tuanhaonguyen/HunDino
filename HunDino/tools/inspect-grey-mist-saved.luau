-- Run from HunDino after a native Roblox Studio Save.
-- READS .rbxl files only; never serialize Terrain through Lune. The only write
-- performed by this inspector is assets/hunting/grey-mist-saved.json.
local fs=require("@lune/fs")
local roblox=require("@lune/roblox")
local luau=require("@lune/luau")
local serde=require("@lune/serde")
local placePath="HunDino_DarkJungle_v2_3.rbxl"
local baselinePath="backups/Hub_before_grey_mist_valley_20261019.rbxl"
local reportPath="assets/hunting/grey-mist-saved.json"
local report={version="GreyMistSavedValidation.1-H2.0",savedPlace=placePath,baseline=baselinePath,
	terrain={inspection="Native Terrain fields are not decoded or serialized by this inspector",
		writeMethod="Roblox Studio native Terrain operations and native Save"}}
local checks=0
local function check(condition,message)
	assert(condition,message);checks+=1
end
local function normalized(source)
	return source:gsub("\r\n","\n"):gsub("\239\187\191",""):gsub("%s+$","")
end
local function pathOf(instance,stop)
	local names={}
	while instance and instance~=stop and not instance:IsA("DataModel") do
		table.insert(names,1,instance.Name);instance=instance.Parent
	end
	return table.concat(names,".")
end
local function vec(v) return {v.X,v.Y,v.Z} end
local function col(v) return {v.R,v.G,v.B} end
local function optional(object,property)
	local ok,value=pcall(function() return object[property] end)
	if not ok then return nil end
	if typeof(value)=="Vector3" then return vec(value) end
	if typeof(value)=="Color3" then return col(value) end
	if typeof(value)=="CFrame" then return {value:GetComponents()} end
	if type(value)=="number" or type(value)=="boolean" or type(value)=="string" then return value end
	return value~=nil and tostring(value) or nil
end
local function assets(part)
	local rows={}
	for _,object in part:GetDescendants() do
		if object:IsA("DataModelMesh") or object:IsA("SurfaceAppearance") or object:IsA("Decal") then
			local row={path=pathOf(object,part),className=object.ClassName}
			for _,property in {"MeshId","MeshContent","TextureId","TextureContent","MeshType","Scale","Offset","VertexColor",
				"ColorMap","ColorMapContent","NormalMap","NormalMapContent","MetalnessMap","MetalnessMapContent",
				"RoughnessMap","RoughnessMapContent","AlphaMode","Color","Color3","Texture","Face","Transparency",
				"StudsPerTileU","StudsPerTileV","OffsetStudsU","OffsetStudsV","ZIndex"} do row[property]=optional(object,property) end
			table.insert(rows,serde.encode("json",row))
		end
	end
	table.sort(rows);return rows
end
local function partShape(part,root)
	local row={path=pathOf(part,root),className=part.ClassName,size=vec(part.Size),color=col(part.Color),
		material=tostring(part.Material),materialVariant=part.MaterialVariant,transparency=part.Transparency,
		reflectance=part.Reflectance,anchored=part.Anchored,canCollide=part.CanCollide,canTouch=part.CanTouch,
		canQuery=part.CanQuery,castShadow=part.CastShadow,collisionGroup=part.CollisionGroup,massless=part.Massless,
		assets=assets(part)}
	for _,property in {"RootPriority","CustomPhysicalProperties","TopSurface","BottomSurface","FrontSurface","BackSurface","LeftSurface","RightSurface"} do
		row[property]=optional(part,property)
	end
	if part:IsA("Part") then row.shape=tostring(part.Shape) end
	if part:IsA("MeshPart") then
		for _,property in {"MeshId","MeshContent","TextureID","TextureContent","CollisionFidelity","RenderFidelity","DoubleSided","MeshSize"} do
			row[property]=optional(part,property)
		end
	end
	if part:IsA("SpawnLocation") then
		row.spawnEnabled=part.Enabled;row.neutral=part.Neutral;row.duration=part.Duration
	end
	return row
end
local function geometry(root)
	local rows={}
	for _,part in root:GetDescendants() do
		if part:IsA("BasePart") then
			local row=partShape(part,root);row.cframe={part.CFrame:GetComponents()}
			table.insert(rows,serde.encode("json",row))
		end
	end
	table.sort(rows);return rows
end
local function exactGeometry(oldRoot,newRoot,label)
	local oldRows,newRows=geometry(oldRoot),geometry(newRoot)
	check(#oldRows==#newRows,label.." part count changed")
	for i,row in oldRows do check(row==newRows[i],label.." geometry changed at sorted row "..i) end
	return #oldRows
end
local function instancesByPath(model)
	local index={}
	for _,object in model:GetDescendants() do index[pathOf(object,model)]=object end
	return index
end
local function rigRows(model)
	local rows={}
	for _,object in model:GetDescendants() do
		if object:IsA("Motor6D") or object:IsA("WeldConstraint") then
			local row={path=pathOf(object,model),className=object.ClassName,
				part0=object.Part0 and pathOf(object.Part0,model),part1=object.Part1 and pathOf(object.Part1,model)}
			for _,property in {"C0","C1","Transform","Enabled"} do row[property]=optional(object,property) end
			table.insert(rows,serde.encode("json",row))
		end
	end
	table.sort(rows);return rows
end
local function preserveTranslatedDinosaur(oldModel,newModel)
	check(oldModel.PrimaryPart~=nil and newModel.PrimaryPart~=nil,"Dinosaur PrimaryPart missing")
	check(pathOf(oldModel.PrimaryPart,oldModel)==pathOf(newModel.PrimaryPart,newModel),"Dinosaur PrimaryPart changed")
	local newBuckets={}
	local counts={parts=0,meshes=0,motors=0,welds=0,anchors=0}
	for _,part in newModel:GetDescendants() do
		if part:IsA("BasePart") then
			counts.parts+=1;if part:IsA("MeshPart") then counts.meshes+=1 end
			if part.Anchored then counts.anchors+=1 end
			local key=serde.encode("json",partShape(part,newModel))
			newBuckets[key]=newBuckets[key] or {};table.insert(newBuckets[key],part)
		elseif part:IsA("Motor6D") then counts.motors+=1
		elseif part:IsA("WeldConstraint") then counts.welds+=1 end
	end
	local shift=newModel.PrimaryPart.CFrame.Position-oldModel.PrimaryPart.CFrame.Position
	local maximumTranslationError,maximumRotationError=0,0
	for _,oldPart in oldModel:GetDescendants() do
		if not oldPart:IsA("BasePart") then continue end
		local key=serde.encode("json",partShape(oldPart,oldModel))
		local bucket=assert(newBuckets[key],"Dinosaur part shape/assets changed: "..pathOf(oldPart,oldModel))
		local best,bestError=nil,math.huge
		for i,p in bucket do
			local error=(p.CFrame.Position-oldPart.CFrame.Position-shift).Magnitude
			if error<bestError then best,bestError=i,error end
		end
		check(best~=nil and bestError<.01,"Dinosaur part did not move with the intact rig: "..pathOf(oldPart,oldModel))
		local current=table.remove(bucket,best)
		maximumTranslationError=math.max(maximumTranslationError,bestError)
		local a,b={oldPart.CFrame:GetComponents()},{current.CFrame:GetComponents()}
		for i=4,12 do maximumRotationError=math.max(maximumRotationError,math.abs(a[i]-b[i])) end
	end
	check(maximumRotationError<.00001,"Dinosaur rig rotation changed")
	check(counts.parts==255 and counts.meshes==21 and counts.motors==7 and counts.welds==247 and counts.anchors==1,
		"Dinosaur part/mesh/rig/anchor counts changed")
	local oldRig,newRig=rigRows(oldModel),rigRows(newModel)
	check(#oldRig==#newRig,"Dinosaur joint count changed")
	for i,row in oldRig do check(row==newRig[i],"Dinosaur joint wiring or rest pose changed at row "..i) end
	check(not newModel:FindFirstChild("CombatHitboxes") and not newModel:FindFirstChild("DinosaurHealthbar"),"Runtime combat volumes were saved")
	check(newModel.MotionRuntime.Disabled,"Legacy dinosaur MotionRuntime must remain disabled")
	counts.translation=vec(shift);counts.maximumTranslationError=maximumTranslationError;counts.maximumRotationError=maximumRotationError
	return counts
end
local function main()
	local bytes,beforeBytes=fs.readFile(placePath),fs.readFile(baselinePath)
	report.bytes=#bytes;report.baselineBytes=#beforeBytes
	local saved,before=roblox.deserializePlace(bytes),roblox.deserializePlace(beforeBytes)
	local world,oldWorld=saved:GetService("Workspace"),before:GetService("Workspace")
	local replicated,server,storage=saved:GetService("ReplicatedStorage"),saved:GetService("ServerScriptService"),saved:GetService("ServerStorage")
	local starter=saved:GetService("StarterPlayer").StarterPlayerScripts
	local forest=assert(world:FindFirstChild("HuntingRainforest"),"Saved hunting forest missing")
	local hub=assert(world:FindFirstChild("HunDinoL0"),"Saved lobby missing")
	report.originalGeometryPreserved={}
	for _,name in {"HunDinoL0","DarkJungle"} do
		report.originalGeometryPreserved[name]=exactGeometry(assert(oldWorld:FindFirstChild(name)),assert(world:FindFirstChild(name)),name)
	end
	local transitParts=#geometry(assert(hub:FindFirstChild("HuntingTransit")))
	local preservedLobbyParts=report.originalGeometryPreserved.HunDinoL0+report.originalGeometryPreserved.DarkJungle
	check(preservedLobbyParts-transitParts==15066,"Expected 15,066 original lobby/base parts plus the existing hunting portal")
	report.preservedLobbyBaseParts=preservedLobbyParts;report.preservedHuntingTransitParts=transitParts
	local archived=assert(storage:FindFirstChild("GreyMistValleyBackup_20261019"),"Archived forest backup missing")
	local oldForest=assert(oldWorld:FindFirstChild("HuntingRainforest"))
	local archivedForest=assert(archived:FindFirstChild("HuntingRainforest_H131"),"H1.3.1 forest archive missing")
	report.archivedForestPartsPreserved=exactGeometry(oldForest,archivedForest,"Archived H1.3.1 forest")
	local intentional={
		["ReplicatedStorage.HuntingBaseConfig"]=true,["ReplicatedStorage.HuntingMapConfig"]=true,
		["ReplicatedStorage.HuntingEnvironmentClock"]=true,["ReplicatedStorage.Shared.HubUI"]=true,
		["ServerScriptService.HunDinoTraining"]=true,["ServerScriptService.HuntingRuntime.DinosaurRouteController"]=true,
		["ServerScriptService.HuntingRuntime.DinosaurCombat"]=true,["ServerScriptService.HuntingRuntime.HuntingSession"]=true,
		["StarterPlayer.StarterPlayerScripts.HunDinoTraining"]=true,["StarterPlayer.StarterPlayerScripts.ConnectedHuntingViewer"]=true,
	}
	local sources,compiled={},0
	for _,object in saved:GetDescendants() do
		if object:IsA("LuaSourceContainer") then
			luau.compile(object.Source);compiled+=1
			local key=pathOf(object).."|"..object.ClassName
			sources[key]=sources[key] or {};table.insert(sources[key],object)
		end
	end
	local preserved,changed=0,{}
	for _,object in before:GetDescendants() do
		if not object:IsA("LuaSourceContainer") then continue end
		local name=pathOf(object)
		-- Roblox permits a Script and LocalScript with the same sibling name;
		-- archived training copies contain this pair. Compare a typed multiset.
		local bucket=assert(sources[name.."|"..object.ClassName],"Original source removed: "..name)
		local matched
		for i,current in bucket do
			if intentional[name] or normalized(current.Source)==normalized(object.Source) then matched=i;break end
		end
		check(matched~=nil,"Unrelated source changed or removed: "..name.." ("..object.ClassName..")")
		table.remove(bucket,matched)
		if intentional[name] then table.insert(changed,name) else preserved+=1 end
	end
	table.sort(changed)
	report.compiledScripts=compiled;report.originalScriptsPreserved=preserved;report.intentionalOriginalScriptChanges=changed
	local matches={}
	local function canonical(object,file)
		check(object~=nil and object:IsA("LuaSourceContainer"),"Saved canonical source missing: "..file)
		check(normalized(object.Source)==normalized(fs.readFile(file)),"Saved source differs from canonical: "..file)
		table.insert(matches,{saved=pathOf(object),source=file})
	end
	canonical(replicated.HuntingBaseConfig,"src/hunting/GreyMistValleyConfig.luau")
	canonical(replicated.HuntingMapConfig,"src/hunting/ConnectedHuntingConfig.luau")
	canonical(replicated.HuntingEnvironmentClock,"src/hunting/EnvironmentClock.luau")
	local runtime=assert(server:FindFirstChild("HuntingRuntime"))
	for _,name in {"HuntingSession","DinosaurRouteController","DinosaurCombat","DinosaurCombatConfig"} do canonical(runtime:FindFirstChild(name),"src/hunting/"..name..".luau") end
	canonical(server.HunDinoTraining,"studio-pet-integration/Training.server.luau")
	canonical(starter.HunDinoTraining,"studio-pet-integration/Training.client.luau")
	canonical(starter.ConnectedHuntingViewer,"src/hunting/ConnectedHuntingViewer.client.luau")
	canonical(replicated.Shared.HubUI,"src/dark-jungle/HubUI.luau")
	canonical(replicated.Shared.TrainingConfig,"studio-pet-integration/TrainingConfig.luau")
	local builders=assert(storage:FindFirstChild("GreyMistBuild"),"Saved builder folder missing")
	for _,name in {"BuildGreyMistValley","ValleyArtKit","ValleyLandmarks","ValleyDressing"} do canonical(builders:FindFirstChild(name),"src/hunting/"..name..".luau") end
	report.canonicalSources=matches
	local cache={};local loadConfig
	local mockGame={GetService=function(_,name)
		assert(name=="ReplicatedStorage");return {WaitForChild=function(_,child) return assert(replicated:FindFirstChild(child)) end}
	end}
	loadConfig=function(module)
		if cache[module] then return cache[module] end
		check(module==replicated.HuntingBaseConfig or module==replicated.HuntingMapConfig,"Unexpected pure-config require")
		local value=luau.load(module.Source,{environment={game=mockGame,Vector2=roblox.Vector2,Vector3=roblox.Vector3,require=loadConfig},injectGlobals=true})()
		cache[module]=value;return value
	end
	local config=loadConfig(replicated.HuntingMapConfig)
	local base=loadConfig(replicated.HuntingBaseConfig)
	check(config.Version=="H2.0" and config.ConnectedToHub==true,"Saved connected H2 configuration missing")
	check(config.MapWidth==4000 and config.MapDepth==4500 and config.PlanarScale==1,"Saved full expansion dimensions differ")
	check(config.WorldOffset==roblox.Vector3.new(0,0,6500),"Hunting world offset changed")
	check(config.North==roblox.Vector3.new(0,0,1),"North must be positive Z")
	check(config.TimeScale==30 and config.TimezoneOffsetMinutes==420,"Real-time hunting clock scale changed")
	check(config.RestSeconds==60 and config.CampSafeRadius==250,"Saved rest/safe-zone settings differ")
	check(config.TerrainMin== -64 and config.TerrainMax==704,"Saved Terrain vertical bounds differ")
	check(#base.Zones==9 and #base.Edges==13 and #base.HumanPaths==3 and #base.Biomes==8,"Saved map topology/biome counts differ")
	local session=luau.load(runtime.HuntingSession.Source,{environment={Vector3=roblox.Vector3},injectGlobals=true})()
	local duration=session.new(forest,config,nil,nil).Duration
	check(duration==2400,"Temporary short hunting duration was saved")
	local combat=luau.load(runtime.DinosaurCombatConfig.Source,{environment={Vector3=roblox.Vector3},injectGlobals=true})()
	local movement=luau.load(replicated.Shared.TrainingConfig.Source)()
	check(combat.MaxHealth==1200 and combat.BiteDamage==24,"Dinosaur health/damage balance changed")
	check(combat.BiteWindup==.95 and combat.BiteCooldown==3.5,"Dinosaur warning/cooldown tuning changed")
	check(combat.LeashDistance==260 and combat.MaxWeaponRange==250,"Dinosaur weapon/leash tuning changed")
	check(movement.DodgeSpeed==72 and movement.DodgeTime==.5,"Saved dodge tuning changed")
	check(movement.DodgeCost*movement.StaminaCostScale==6,"Saved dodge stamina cost changed")
	check(forest:GetAttribute("Version")=="H2.0" and forest:GetAttribute("BuildStage")=="Complete","H2 build is incomplete")
	check(forest:GetAttribute("MapWidth")==4000 and forest:GetAttribute("MapDepth")==4500,"Forest dimensions differ")
	check(forest:GetAttribute("WorldOffset")==config.WorldOffset and forest:GetAttribute("HubConnected")==true,"Forest hub link missing")
	check(forest:GetAttribute("NorthIsPositiveZ")==true and forest:GetAttribute("RouteAIReady")==true,"Forest navigation not ready")
	check(forest:GetAttribute("TerrainTilesComplete")==1152,"Terrain tile build is incomplete")
	check(forest:GetAttribute("TerrainWriteBoundsMin")==roblox.Vector3.new(-2000,-64,4248),"Terrain minimum bounds differ")
	check(forest:GetAttribute("TerrainWriteBoundsMax")==roblox.Vector3.new(2000,704,8752),"Terrain maximum bounds differ")
	check(#forest.Zones:GetChildren()==9 and #forest.Paths:GetChildren()==16,"Expected nine nodes and sixteen paths")
	for _,q in base.Zones do
		local zone=assert(forest.Zones:FindFirstChild(q.id),"Saved zone missing: "..q.id)
		check((zone.Node.CFrame.Position-config.position(q)).Magnitude<.001,"Zone node moved: "..q.id)
		check(zone:GetAttribute("Kind")==q.kind and zone:GetAttribute("Width")==q.width,"Zone metadata differs: "..q.id)
	end
	local routePaths,humanPaths=0,0
	for _,p in forest.Paths:GetChildren() do
		local human=p:GetAttribute("HumanOnly")==true
		if human then humanPaths+=1 else routePaths+=1 end
		check(p:GetAttribute("Bidirectional")==true,"One-way path was saved: "..p.Name)
		check(p:GetAttribute("WalkWidth")== (if human then 24 else 72),"Path width changed: "..p.Name)
		check(#p:GetChildren()>0,"Empty path: "..p.Name)
		for _,part in p:GetChildren() do
			if part:IsA("BasePart") then check(part.Transparency==1 and part.CanCollide and part.Anchored,"Route support must be invisible and solid") end
		end
	end
	check(routePaths==13 and humanPaths==3,"Animal/human path counts differ")
	check(forest.Camp.CampSpawn:IsA("SpawnLocation") and not forest.Camp.CampSpawn.Enabled,"Forest spawn must be disabled")
	check(forest.Camp.CampArrival.CFrame.Position==roblox.Vector3.new(0,25,4650),"Forest arrival moved")
	check(forest.Camp.ReturnToLobby:FindFirstChildOfClass("ProximityPrompt")~=nil,"Return portal prompt missing")
	check(hub.HuntingTransit.ToHunting:FindFirstChildOfClass("ProximityPrompt")~=nil,"Lobby hunting prompt missing")
	check(hub.Lobby.Arrival.CFrame.Position==roblox.Vector3.new(0,23,181),"Lobby arrival changed")
	check(hub.Training.Arrival.CFrame.Position==roblox.Vector3.new(2086,39,160),"Training arrival changed")
	local spawns=0
	for _,object in world:GetDescendants() do
		if object:IsA("SpawnLocation") and object.Enabled then spawns+=1;check(object==hub.Lobby.LobbySpawn,"Unexpected enabled spawn") end
	end
	check(spawns==1,"Expected one enabled lobby spawn")
	local dino=assert(world:FindFirstChild("Dinosaur01_TRex_Visual"))
	report.dinosaur=preserveTranslatedDinosaur(assert(oldWorld:FindFirstChild(dino.Name)),dino)
	local support=dino.PrimaryPart.CFrame:PointToWorldSpace(roblox.Vector3.new(4.6155128,-23.162859,5.200428))
	check((support-(config.position(base.zone("A"))+roblox.Vector3.new(0,.23,0))).Magnitude<.05,"Dinosaur foot anchor was not moved to A")
	report.dinosaur.footSupport=vec(support)
	local library=assert(storage:FindFirstChild("ValleyTreeTemplates"),"Tree template library missing")
	local templateCounts={}
	for kind,expected in {pine=12,birch=6,oak=6,willow=1} do
		local variants=assert(library:FindFirstChild(kind),"Tree species missing: "..kind)
		local count=0
		for _,template in variants:GetChildren() do
			check(template:IsA("Model"),"Tree variant must be a model")
			local partCount=0
			for _,object in template:GetDescendants() do
				check(not object:IsA("LuaSourceContainer"),"Imported tree template contains executable code")
				if object:IsA("BasePart") then
					partCount+=1;check(object.Size.X>0 and object.Size.Y>0 and object.Size.Z>0,"Tree template has invalid geometry")
				end
			end
			check(partCount>0,"Empty tree template: "..template.Name);count+=1
		end
		check(count==expected,"Tree template variant count differs: "..kind);templateCounts[kind]=count
	end
	local trees=assert(forest.Decor:FindFirstChild("Forest"),"Generated forest missing")
	check(#trees:GetChildren()==forest:GetAttribute("TreesPlaced") and #trees:GetChildren()>=1500,"Generated forest is incomplete")
	local landmarks=assert(forest.Decor:FindFirstChild("Landmarks"),"Landmarks missing")
	for _,name in {"01_RangerStation","03_OldPineRefuges","04_LakeLandmarks","05_SwampBoardwalk","06_AbandonedLoggingCamp","07_SplitStoneGorge","08_MountainCave"} do
		check(landmarks:FindFirstChild(name)~=nil,"Missing environmental landmark: "..name)
	end
	report.map={width=4000,depth=4500,worldOffset=vec(config.WorldOffset),animalZones=8,camps=1,
		animalPaths=routePaths,humanPaths=humanPaths,biomes=#base.Biomes,north="positive Z",terrainTiles=1152,
		trees=#trees:GetChildren(),treeTemplates=templateCounts,huntDurationSeconds=duration,timeScale=config.TimeScale,restSeconds=config.RestSeconds}
	report.combat={maxHealth=combat.MaxHealth,biteDamage=combat.BiteDamage,windupSeconds=combat.BiteWindup,cooldownSeconds=combat.BiteCooldown}
	report.dodge={initialSpeed=movement.DodgeSpeed,durationSeconds=movement.DodgeTime,staminaCost=movement.DodgeCost*movement.StaminaCostScale}
	report.terrain.minimumBounds={-2000,-64,4248};report.terrain.maximumBounds={2000,704,8752}
end
local ok,err=xpcall(main,debug.traceback)
report.validation=if ok then "passed" else "failed"
report.checksPassed=checks
if not ok then report.error=tostring(err) end
fs.writeFile(reportPath,serde.encode("json",report,true))
print(serde.encode("json",report,true))
assert(ok,"Saved H2 validation failed; see "..reportPath.."\n"..tostring(err))
