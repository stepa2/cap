-- Support for gmod13 by AlexALX
-- This lib still needed for fix some problems and add removed functions

if (Gmod13Lib!=nil) then return end -- prevent calling this file twice

if (SERVER) then
	AddCSLuaFile();
end

function Vertex( pos, u, v, normal )
	return { pos = pos, u = u, v = v, normal = normal };
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