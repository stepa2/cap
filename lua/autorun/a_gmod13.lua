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

	local gmsave_LoadMap = gmsave.LoadMap
	function gmsave.LoadMap(strMapContents, ply)
		-- fix for gatespawner
	   	if (StarGate and StarGate.GateSpawner and StarGate.GateSpawner.Restored) then
	   		StarGate.GateSpawner.Restored();
		end
		return gmsave_LoadMap(strMapContents, ply);
	end
end