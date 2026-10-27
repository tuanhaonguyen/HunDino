-- Read-only native-save inspector. The only permitted write is the JSON report.
-- Run from HunDino after native Studio Save: lune run tools/inspect-bio-tubes-saved.luau
-- --baseline inspects the untouched baseline without requiring installed tubes.
local fs=require("@lune/fs")
local roblox=require("@lune/roblox")
local luau=require("@lune/luau")
local serde=require("@lune/serde")
local process=require("@lune/process")
local BASELINE="backups/Hub_v24_before_5_specimen_tubes_20261021.rbxl"
local PLACE="HunDino_DarkJungle_v2_4.rbxl"
local REPORT="assets/hunting/bio-tubes-saved.json"
local baselineOnly=table.find(process.args,"--baseline")~=nil
local report={version="BioTubesSavedValidation.1",baseline=BASELINE,savedPlace=PLACE,
	mode=if baselineOnly then "baseline-preflight" else "native-save",
	boundary="Reads native places only; never serializes a place, writes rbxl, decodes Terrain, or creates player records.",
	terrainScope="Hashes all Terrain fields readable by bundled Lune. Its parser does not support native type 0x23 (Terrain.VoxelGridAssetContentMap); this field is not claimed as binary-verified."}
local checks=0
local function check(condition,message) checks+=1;assert(condition,message) end
local function normalize(source) return source:gsub("\r\n","\n"):gsub("^\239\187\191",""):gsub("%s+$","") end
local function pathOf(object)
	local segments={}
	while object and not object:IsA("DataModel") do table.insert(segments,1,object.Name);object=object.Parent end
	return table.concat(segments,".")
end
local function at(root,path)
	for name in path:gmatch("[^.]+") do root=root and root:FindFirstChild(name) end
	return root
end
local function read(object,key)
	local ok,value=pcall(function() return object[key] end)
	return ok,value
end
local function stable(value)
	if type(value)~="table" then return serde.encode("json",value) end
	local keys,parts={},{}
	for key in value do table.insert(keys,key) end
	table.sort(keys,function(a,b) return tostring(a)<tostring(b) end)
	for _,key in keys do table.insert(parts,stable(key)..":"..stable(value[key])) end
	return "{"..table.concat(parts,",").."}"
end
local function valueOf(value)
	local kind=typeof(value)
	if kind=="Instance" then
		local _,cf=read(value,"CFrame")
		return {kind=kind,path=pathOf(value),className=value.ClassName,frame=if typeof(cf)=="CFrame" then {cf:GetComponents()} else nil}
	elseif kind=="CFrame" then return {kind=kind,value={value:GetComponents()}}
	elseif kind=="Vector3" then return {kind=kind,value={value.X,value.Y,value.Z}}
	elseif kind=="Vector2" then return {kind=kind,value={value.X,value.Y}}
	elseif kind=="Color3" then return {kind=kind,value={value.R,value.G,value.B}}
	elseif kind=="string" then return {kind=kind,bytes=#value,sha256=serde.hash("sha256",value)}
	elseif kind=="number" then return {kind=kind,value=string.format("%.17g",value)}
	elseif kind=="boolean" or kind=="nil" then return {kind=kind,value=value} end
	return {kind=kind,value=tostring(value)}
end
local function equivalent(a,b)
	if a==b then return true end
	if typeof(a)~=typeof(b) then return false end
	return stable(valueOf(a))==stable(valueOf(b))
end
local bindings={
	{"ServerScriptService.HuntingRuntime.BioTubeGeometry","src/hunting/BioTubeGeometry.luau","ModuleScript",true},
	{"ServerScriptService.HuntingRuntime.BioTubeSpecimen","src/hunting/BioTubeSpecimen.luau","ModuleScript",true},
	{"ServerScriptService.HuntingRuntime.BioTubeService","src/hunting/BioTubeService.luau","ModuleScript",true},
	{"StarterPlayer.StarterPlayerScripts.HunDinoBioTubeMotion","src/hunting/BioTubeMotion.client.luau","LocalScript",true},
	{"ServerScriptService.HuntingRuntime.HuntEconomyService","src/hunting/HuntEconomyService.luau","ModuleScript"},
	{"ServerScriptService.HuntingRuntime.HuntEconomyRules","src/hunting/HuntEconomyRules.luau","ModuleScript"},
	{"ServerScriptService.AccountData.ProfileSchema","src/data/ProfileSchema.luau","ModuleScript"},
	{"ReplicatedStorage.Shared.EquipmentInventory","src/dark-jungle/EquipmentInventory.luau","ModuleScript"},
}
local newSources,changedSources={},{}
for _,binding in bindings do
	if binding[4] then newSources[binding[1]]=true else changedSources[binding[1]]=true end
end
local DISPLAY="Workspace.SpecimenTubeDisplays"
local BACKUP="ServerStorage.SpecimenTubesBackup_20261021"
local function below(path,root) return path==root or path:sub(1,#root+1)==root.."." end
local partProperties={"CFrame","Size","Color","Material","MaterialVariant","Transparency","Reflectance","Anchored",
	"CanCollide","CanTouch","CanQuery","CastShadow","Massless","CollisionGroup","PivotOffset","Shape",
	"MeshId","TextureID","DoubleSided","RenderFidelity","CollisionFidelity","UsePartColor",
	"AssetId","MeshData","ChildData","CSGPropertyData","SerializedMesh"}
local jointProperties={"Part0","Part1","C0","C1","Transform","Enabled","Attachment0","Attachment1",
	"Length","LimitsEnabled","LowerAngle","UpperAngle","Restitution","MaxForce","MaxTorque"}
local meshProperties={"MeshId","TextureId","MeshType","Scale","Offset","VertexColor",
	"ColorMap","NormalMap","MetalnessMap","RoughnessMap","AlphaMode","Color"}
local reflection=roblox.getReflectionDatabase()
local geometryPropertyCache={}
local function geometryProperties(object)
	if geometryPropertyCache[object.ClassName] then return geometryPropertyCache[object.ClassName] end
	local requested={}
	if object:IsA("BasePart") and not object:IsA("Terrain") then requested=partProperties
	elseif object:IsA("JointInstance") or object:IsA("Constraint") then requested=jointProperties
	elseif object:IsA("DataModelMesh") or object:IsA("SurfaceAppearance") then requested=meshProperties
	elseif object:IsA("Attachment") then requested={"CFrame","Axis","SecondaryAxis"}
	elseif object:IsA("Model") then requested={"PrimaryPart"} end
	local supported={}
	local class=reflection:GetClass(object.ClassName)
	while class do
		for name in class.Properties do supported[name]=true end
		class=if class.Superclass then reflection:GetClass(class.Superclass) else nil
	end
	local selected={}
	for _,property in requested do if supported[property] then table.insert(selected,property) end end
	geometryPropertyCache[object.ClassName]=selected
	return selected
end
local function fingerprint(object)
	local row={}
	for _,property in geometryProperties(object) do
		local ok,value=read(object,property)
		if ok then row[property]=valueOf(value) end
	end
	if object:IsA("LuaSourceContainer") and not changedSources[pathOf(object)] then row.Source=normalize(object.Source) end
	return stable(row)
end
local function counts(root)
	local world=root:GetService("Workspace")
	local out={instances=0,parts=0,joints=0,workspaceParts=0,workspaceJoints=0,sources=0}
	for _,object in root:GetDescendants() do
		out.instances+=1
		if object:IsA("LuaSourceContainer") then out.sources+=1 end
		if object:IsA("BasePart") and not object:IsA("Terrain") then
			out.parts+=1;if object:IsDescendantOf(world) then out.workspaceParts+=1 end
		elseif object:IsA("JointInstance") or object:IsA("WeldConstraint") then
			out.joints+=1;if object:IsDescendantOf(world) then out.workspaceJoints+=1 end
		end
	end
	return out
end
local function buckets(root,excludeAdditions)
	local out={}
	for _,object in root:GetDescendants() do
		local path=pathOf(object)
		if object.Parent==root and object.Name=="FilteredSelection" then
			check(#object:GetDescendants()==0,"Native selection record unexpectedly contains game data")
			continue
		end
		if excludeAdditions and (below(path,DISPLAY) or below(path,BACKUP) or newSources[path]) then continue end
		local key=path.."|"..object.ClassName
		out[key]=out[key] or {};table.insert(out[key],object)
	end
	return out
end
local function compareOriginals(baseline,saved)
	local before,after=buckets(baseline,false),buckets(saved,not baselineOnly)
	local compared,properties,joints,meshes=0,0,0,0
	for key in after do check(before[key]~=nil,"Unexpected addition outside authorized tube/source/backup folders: "..key) end
	for key,oldGroup in before do
		local newGroup=after[key]
		check(newGroup~=nil and #newGroup==#oldGroup,"Original hierarchy/class/count changed: "..key)
		-- Forest dressing uses repeated sibling names. Bucket signatures once,
		-- rather than comparing every old leaf to every candidate leaf.
		local bySignature={}
		if #oldGroup>1 then
			for _,object in newGroup do
				local signature=fingerprint(object)
				bySignature[signature]=bySignature[signature] or {};table.insert(bySignature[signature],object)
			end
		end
		for _,old in oldGroup do
			local candidate
			if #oldGroup==1 then candidate=newGroup[1]
			else
				local matches=bySignature[fingerprint(old)]
				if matches then candidate=table.remove(matches) end
			end
			check(candidate~=nil,"Same-name geometry multiset changed: "..key)
			compared+=1
			for _,property in geometryProperties(old) do
				local readable,a=read(old,property)
				local readableNow,b=read(candidate,property)
				check(readable==readableNow,"Original property readability changed: "..key.."."..property)
				if readable then properties+=1;check(equivalent(a,b),"Original property changed: "..key.."."..property) end
			end
			if old:IsA("JointInstance") or old:IsA("WeldConstraint") then joints+=1 end
			if old:IsA("MeshPart") or old:IsA("DataModelMesh") or old:IsA("SurfaceAppearance") then meshes+=1 end
			if old:IsA("LuaSourceContainer") and (baselineOnly or not changedSources[pathOf(old)]) then
				check(normalize(old.Source)==normalize(candidate.Source),"Unrelated original source changed: "..key)
			end
		end
	end
	report.preserved={instances=compared,properties=properties,joints=joints,meshOrAppearanceObjects=meshes}
end
local function terrainHash(root)
	local terrain=assert(root:GetService("Workspace"):FindFirstChildOfClass("Terrain"),"Terrain missing")
	local reflection=roblox.getReflectionDatabase()
	local class=reflection:GetClass("Terrain")
	local values,unreadable={},{}
	for property in class.Properties do
		local ok,value=read(terrain,property)
		if ok then values[property]=valueOf(value) else table.insert(unreadable,property) end
	end
	table.sort(unreadable)
	return serde.hash("sha256",stable(values)),unreadable
end
local function topology(root)
	local world=root:GetService("Workspace")
	local forest=assert(world:FindFirstChild("HuntingRainforest"),"HuntingRainforest missing")
	local dinosaur=assert(world:FindFirstChild("Dinosaur01_TRex_Visual"),"Original T-Rex missing")
	local rig={parts=0,meshes=0,motors=0,welds=0,anchors=0}
	for _,object in dinosaur:GetDescendants() do
		if object:IsA("BasePart") then
			rig.parts+=1;if object.Anchored then rig.anchors+=1 end
			if object:IsA("MeshPart") then rig.meshes+=1 end
		elseif object:IsA("Motor6D") then rig.motors+=1
		elseif object:IsA("WeldConstraint") then rig.welds+=1 end
	end
	return {width=forest:GetAttribute("MapWidth"),depth=forest:GetAttribute("MapDepth"),version=forest:GetAttribute("Version"),
		trees=#forest.Decor.Forest:GetChildren(),reportedTrees=forest:GetAttribute("TreesPlaced"),
		paths=#forest.Paths:GetChildren(),zones=#forest.Zones:GetChildren(),rig=rig}
end
local function verifySources(baseline,saved)
	local originals=assert(at(saved,BACKUP),"Native source backup folder missing")
	local sourceCount=0
	for _,object in saved:GetDescendants() do if object:IsA("LuaSourceContainer") then
		luau.compile(object.Source);sourceCount+=1
	end end
	report.compiledScripts=sourceCount
	for _,binding in bindings do
		local path,file,className=binding[1],binding[2],binding[3]
		local object=assert(at(saved,path),"Missing installed source "..path)
		check(object.ClassName==className,"Wrong installed source type "..path)
		check(normalize(object.Source)==normalize(fs.readFile(file)),"Saved source differs from canonical file "..file)
		if not binding[4] then
			local old=assert(at(baseline,path),"Original module missing "..path)
			local backup=assert(originals:FindFirstChild(old.Name),"Missing original backup "..old.Name)
			local source=if backup:IsA("LuaSourceContainer") then backup.Source elseif backup:IsA("StringValue") then backup.Value else nil
			check(source~=nil and normalize(source)==normalize(old.Source),"Backup lost original source "..old.Name)
			if backup:IsA("BaseScript") then check(backup.Disabled,"Original backup script can execute") end
		end
	end
	check(#originals:GetChildren()==4,"Expected four original modified source backups")
	report.canonicalSources=bindings;report.originalSourceBackups=4
end
local function verifyStaticTubes(saved)
	local displays=assert(at(saved,DISPLAY),"Static tube display root missing")
	check(#displays:GetChildren()==12,"Expected one display cluster per each of 12 bases")
	local tubes,parts,prompts=0,0,0
	local offsets={[1]=roblox.Vector3.new(-28,0,-10),[2]=roblox.Vector3.new(-15,0,0),
		[3]=roblox.Vector3.new(15,0,0),[4]=roblox.Vector3.new(28,0,-10),[5]=roblox.Vector3.new(0,0,5)}
	local headings={[1]=22,[2]=11,[3]=-11,[4]=-22,[5]=0}
	local clusterPlacements={{10,0},{10,8},{10,0},{10,0},{10,8},{10,8},{10,0},{10,0},{10,0},{10,0},{10,0},{10,0}}
	for base=1,12 do
		local cluster=assert(displays:FindFirstChild("Base"..base),"Missing cluster Base"..base)
		local clusterOrigin=cluster:GetAttribute("ClusterOrigin")
		check(typeof(clusterOrigin)=="CFrame","Cluster origin missing")
		local spawn=assert(at(saved,"Workspace.DarkJungle.Bases.Base"..base..".SpawnPad"),"Original base SpawnPad missing")
		local shelter=assert(at(saved,"Workspace.DarkJungle.Bases.Base"..base..".ShelterFloor"),"Original base shelter missing")
		local back=shelter.CFrame.Position-spawn.CFrame.Position;back=roblox.Vector3.new(back.X,0,back.Z).Unit
		local right=roblox.Vector3.yAxis:Cross(back)
		local placement=clusterPlacements[base]
		local expectedCenter=roblox.Vector3.new(spawn.CFrame.Position.X,spawn.CFrame.Position.Y-.3,spawn.CFrame.Position.Z)+back*placement[1]+right*placement[2]
		check((clusterOrigin.Position-expectedCenter).Magnitude<.003 and clusterOrigin.LookVector:Dot(-back)>.99999,
			"Per-base cluster placement or explicit orientation differs from approved obstacle clearance layout")
		local toSpawn=spawn.CFrame.Position-clusterOrigin.Position
		toSpawn=roblox.Vector3.new(toSpawn.X,0,toSpawn.Z).Unit
		check(clusterOrigin.LookVector:Dot(toSpawn)>math.cos(math.rad(45)),"Tube cluster faces outside its SpawnPad approach cone")
		local count=0
		for _,object in cluster:GetChildren() do if object.Name:match("^BioTube_") then count+=1 end end
		check(count==5,"Base"..base.." does not have exactly five tubes")
		for slot=1,5 do
			local tube=assert(cluster:FindFirstChild("BioTube_"..slot),"Missing tube "..base.."/"..slot)
			check(tube:IsA("Model") and tube:GetAttribute("DisplaySlot")==slot,"Wrong tube slot metadata")
			local origin=tube:GetAttribute("StaticOrigin")
			check(typeof(origin)=="CFrame" and tube:GetAttribute("VisualHeight")==19.2,"Tube dimensions/origin missing")
			local expected=clusterOrigin*roblox.CFrame.new(offsets[slot])*roblox.CFrame.Angles(0,math.rad(headings[slot]),0)
			check((origin.Position-expected.Position).Magnitude<.003 and origin.LookVector:Dot(expected.LookVector)>.99999,
				"Tube V formation/heading differs from designed slot "..base.."/"..slot)
			for _,name in {"LowerMechanicalAssembly","ContainmentChamber","MultiTieredMechanicalDome","SpecimenAnchor","InjectorAnchor","Interaction"} do
				check(tube:FindFirstChild(name)~=nil,"Missing static tube assembly "..name)
			end
			check(math.abs(origin:PointToObjectSpace(tube.SpecimenAnchor.CFrame.Position).Y-8.7)<.002,"Specimen marker has inherited/doubled offset")
			local dome=tube.MultiTieredMechanicalDome
			for _,name in {"OuterRecessedShroud","CeilingNeonRing_Outer","CeilingNeonRing_Inner","RibbedCoolingCore","CentralInjectorHub"} do
				check(dome:FindFirstChild(name)~=nil,"Missing multi-tiered mechanical head "..name)
			end
			for fin=1,24 do check(dome:FindFirstChild("CoolingFin_"..fin)~=nil,"Cooling fin missing") end
			for strut=1,4 do check(dome:FindFirstChild("AngledMechanicalStrut_"..strut)~=nil,"Mechanical strut missing") end
			for nozzle=1,8 do check(dome:FindFirstChild("InjectorNozzle_"..nozzle)~=nil,"Injector nozzle missing") end
			local bubbles=tube:FindFirstChild("BioBubbles",true)
			check(bubbles and bubbles:IsA("ParticleEmitter") and bubbles.Rate==14,"Missing configured bubble emitter")
			local prompt=tube.Interaction:FindFirstChild("SpecimenTubePrompt")
			check(prompt and prompt:IsA("ProximityPrompt") and prompt.KeyboardKeyCode==roblox.Enum.KeyCode.G,"Tube does not expose G interaction")
			check(not tube:FindFirstChild("DisplaySpecimen",true) and not tube:FindFirstChild("BioTetherCables",true),"Runtime specimen/cables saved in empty static tube")
			for _,object in tube:GetDescendants() do
				if object:IsA("BasePart") then parts+=1;check(object.Anchored,"Unanchored static tube geometry") end
				check(not object:IsA("LuaSourceContainer") and not object:IsA("Humanoid") and not object:IsA("Model"),"Runtime script/actor/specimen model saved in static tube")
			end
			check(#tube:GetTags()==0 or not table.find(tube:GetTags(),"HunDinoBioSpecimen"),"Runtime specimen tag saved")
			tubes+=1;prompts+=1
		end
	end
	report.tubes={bases=12,tubes=tubes,staticParts=parts,gPrompts=prompts,savedSpecimens=0}
end
local function verifyNoRuntime(saved)
	local world=saved:GetService("Workspace")
	check(not at(saved,"ServerScriptService.BioTubeQA") and not at(saved,"StarterPlayer.StarterPlayerScripts.BioTubeClientQA"),
		"Temporary QA scripts remain in the native save")
	local account=assert(at(saved,"ServerScriptService.AccountData"),"AccountData missing")
	local profileConfig=luau.load(assert(account:FindFirstChild("ProfileConfig"),"ProfileConfig missing").Source)()
	check(profileConfig.StudioMemoryTest==false and account:GetAttribute("StudioMemoryTest")~=true,
		"Temporary Studio memory QA mode remains enabled in saved configuration")
	report.productionSafety={temporaryQAScripts=0,studioMemoryTest=false,savedRuntimeSpecimens=0}
	for _,name in {"TrainingPets","HuntEconomyStations","HuntQuestBoard"} do check(not world:FindFirstChild(name),"Runtime workspace folder saved: "..name) end
	local replicated=saved:GetService("ReplicatedStorage")
	for _,name in {"SpecimenVisuals","HunDinoEconomyAction","HunDinoHuntQuest","HunDinoProfileAction"} do
		check(not replicated:FindFirstChild(name),"Runtime replicated object saved: "..name)
	end
	for _,object in world:GetDescendants() do
		check(not object.Name:match("^HuntHarvest_") and not object.Name:match("^HuntItems_"),"Runtime loot/carry items saved")
		check(not table.find(object:GetTags(),"HunDinoBioSpecimen"),"Player-owned specimen saved into Edit")
	end
	check(not saved:GetService("StarterGui"):FindFirstChild("WeaponSelection",true),"Runtime Inventory GUI saved")
end
local function main()
	local baselineBytes=fs.readFile(BASELINE)
	local savedBytes=if baselineOnly then baselineBytes else fs.readFile(PLACE)
	local before=roblox.deserializePlace(baselineBytes)
	local saved=roblox.deserializePlace(savedBytes)
	report.baselineSha256=serde.hash("sha256",baselineBytes);report.savedSha256=serde.hash("sha256",savedBytes)
	report.bytes=#savedBytes;report.baselineCounts=counts(before);report.savedCounts=counts(saved)
	compareOriginals(before,saved)
	local baselineTopology,currentTopology=topology(before),topology(saved)
	check(stable(baselineTopology)==stable(currentTopology),"Original forest/route/zone/rig counts or dimensions changed")
	report.map=currentTopology
	local beforeTerrain,unreadableBefore=terrainHash(before)
	local currentTerrain,unreadableCurrent=terrainHash(saved)
	report.baselineTerrainSha256=beforeTerrain;report.savedTerrainSha256=currentTerrain
	report.unreadableTerrainProperties=unreadableCurrent
	check(stable(unreadableBefore)==stable(unreadableCurrent),"Terrain native property readability changed")
	check(report.baselineTerrainSha256==report.savedTerrainSha256,"Opaque Terrain properties changed")
	if not baselineOnly then
		verifySources(before,saved);verifyStaticTubes(saved);verifyNoRuntime(saved)
		check(report.savedCounts.parts==report.baselineCounts.parts+report.tubes.staticParts,"New BaseParts exist outside static tube models")
		check(report.savedCounts.joints==report.baselineCounts.joints,"Unexpected added or missing physics joints")
	end
	check(fs.readFile(BASELINE)==baselineBytes,"Inspector modified baseline rbxl")
	check((if baselineOnly then baselineBytes else fs.readFile(PLACE))==savedBytes,"Inspector modified current rbxl")
	report.nativePlaceBytesUnchanged=true
end
local ok,err=pcall(main)
report.validation=if ok then "passed" else "failed";report.checksPassed=checks
if not ok then report.error=tostring(err) end
if not baselineOnly then fs.writeFile(REPORT,serde.encode("json",report,true)) end
print(serde.encode("json",report,true))
assert(ok,"Bio tube saved inspection failed: "..tostring(err))

