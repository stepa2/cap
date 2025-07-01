-- Support for gmod13 by AlexALX
-- This lib still needed for fix some problems and add removed functions

if (Gmod13Lib!=nil) then return end -- prevent calling this file twice

if (SERVER) then
	AddCSLuaFile();
end

function Vertex( pos, u, v, normal )
	return { pos = pos, u = u, v = v, normal = normal };
end

-- still needed to be here
function GetAddonList(lower)
	local _,folders = file.Find("addons/*","GAME");
	local addons = {};
	for _,v in pairs(folders) do
		if (file.Exists("addons/"..v.."/addon.txt","GAME")) then
			if (lower) then	 v = v:lower(); end
			table.insert(addons,v);
		end
	end
	return addons;
end

function GetAddonInfo(addon)
	-- damn you garry, i have to code this function myself now...
	local info = {Info="",Version="0",URL="",LastUpdate="",Author="",Name="",Email=""};
	if (file.Exists("addons/"..addon.."/addon.txt","GAME")) then
		local file = file.Read("addons/"..addon.."/addon.txt","GAME");
		if (file) then
			local lines = string.Explode("\n", file);
			for k,l in pairs(lines) do
				local line = string.Trim(l);
				if (line=="") then continue; end
				local inf = string.Explode("\"", line);
				if (inf[2] and inf[4]) then
					local str = string.lower(inf[2]);
					if (str=="info") then
						info["Info"] = tostring(inf[4]);
					elseif (str=="version") then
						info["Version"] = string.format("%f",tonumber(inf[4]) or 0);
					elseif (str=="author_url") then
						info["URL"] = tostring(inf[4]);
					elseif (str=="up_date") then
						info["LastUpdate"] = tostring(inf[4]);
					elseif (str=="author_name") then
						info["Author"] = tostring(inf[4]);
					elseif (str=="name") then
						info["Name"] = tostring(inf[4]);
					elseif (str=="author_email") then
						info["Email"] = tostring(inf[4]);
					end
				end
			end
		end
	end
	return info;
end

-- for detect some new addons, like wiremod
function GetAddonListJson(lower)
	local _,folders = file.Find("addons/*","GAME");
	local addons = {};
	for _,v in pairs(folders) do
		if (file.Exists("addons/"..v.."/addon.json","GAME")) then
			if (lower) then	 v = v:lower(); end
			table.insert(addons,v);
		end
	end
	return addons;
end

function GetAddonInfoJson(addon)
	-- damn you garry, i have to code this function myself now...
	local info = {Desc="",Name=""};
	if (file.Exists("addons/"..addon.."/addon.json","GAME")) then
		local file = file.Read("addons/"..addon.."/addon.json","GAME");
		if (file) then
			local lines = string.Explode("\n", file);
			for k,l in pairs(lines) do
				local line = string.Trim(l);
				if (line=="") then continue; end
				local inf = string.Explode("\"", line);
				if (inf[2] and inf[4]) then
					local str = string.lower(inf[2]);
					if (str=="description") then
						info["Desc"] = tostring(inf[4]);
					elseif (str=="title") then
						info["Name"] = tostring(inf[4]);
					end
				end
			end
		end
	end
	return info;
end

-- some old fonts used in cap entities
if (CLIENT) then
	local tbl = {
		font = "coolvetica",
		size = 64,
		weight = 500,
		antialias = true,
		additive = false,
	}
	surface.CreateFont( "SandboxLabel", tbl )
	local tbl2 = {
		font = "Tahoma",
		size = 16,
		weight = 1000,
		antialias = true,
		additive = false,
	}
	surface.CreateFont("ScoreboardText", tbl2)
end

if (SERVER) then
	function UpdateRenderTarget( Ent )
	    if ( !Ent || !Ent:IsValid() ) then return end

	    if ( !RenderTargetCamera || !RenderTargetCamera:IsValid() ) then

	        RenderTargetCamera = ents.Create( "point_camera" )
	        RenderTargetCamera:SetKeyValue( "GlobalOverride", 1 )
	        RenderTargetCamera:Spawn()
	        RenderTargetCamera:Activate()
	        RenderTargetCamera:Fire( "SetOn", "", 0.0 )

	    end
	    Pos = Ent:LocalToWorld( Vector( 12,0,0) )
	    RenderTargetCamera:SetPos(Pos)
	    RenderTargetCamera:SetAngles(Ent:GetAngles())
	    RenderTargetCamera:SetParent(Ent)

	    RenderTargetCameraProp = Ent
	end

	-- workaround for fix gmsave
	local gmsave_ShouldSaveEntity  = gmsave.ShouldSaveEntity
	function gmsave.ShouldSaveEntity(ent,t)
		if (ent.CAP_NotSave) then return false end
		return gmsave_ShouldSaveEntity(ent,t);
	end

	local gmsave_LoadMap = gmsave.LoadMap
	function gmsave.LoadMap(strMapContents, ply)
		-- fix for gatespawner
	   	if (StarGate and StarGate.GateSpawner and StarGate.GateSpawner.Restored) then
	   		StarGate.GateSpawner.Restored();
		end
		return gmsave_LoadMap(strMapContents, ply);
	end
end