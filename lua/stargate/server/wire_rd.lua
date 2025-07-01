/*
	Stargate Wire/RD Lib for GarrysMod10
	Copyright (C) 2007-2009  aVoN

	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

--################# Adds LifeSupport,ResourceDistribution and WireSupport to an entity when getting called - HAS TO BE CALLED BEFORE ANY OTHERTHING IS DONE IN A SENT (like includes) @aVoN
-- My suggestion is to put this on the really top of the shared.lua
StarGate.WireRD = {};
function StarGate.LifeSupportAndWire(ENT)
	ENT.WireDebugName = ENT.WireDebugName or "No Name";

	-- General handlers
	ENT.OnRemove = StarGate.WireRD.OnRemove;
	ENT.OnRestore = StarGate.WireRD.OnRestore;

	-- Wire Handlers
	ENT.CreateWireOutputs = StarGate.WireRD.CreateWireOutputs;
	ENT.CreateWireInputs = StarGate.WireRD.CreateWireInputs;
	ENT.SetWire = StarGate.WireRD.SetWire;
	ENT.GetWire = StarGate.WireRD.GetWire;

	-- RD Handling
	ENT.AddResource = StarGate.WireRD.AddResource;
	ENT.GetResource = StarGate.WireRD.GetResource;
	ENT.ConsumeResource = StarGate.WireRD.ConsumeResource;
	ENT.SupplyResource = StarGate.WireRD.SupplyResource;
	ENT.GetUnitCapacity = StarGate.WireRD.GetUnitCapacity;
	ENT.GetNetworkCapacity = StarGate.WireRD.GetNetworkCapacity;

	-- For LifeSupport and Resource Distribution and Wire - Makes all connections savable with Duplicator
	ENT.PreEntityCopy = StarGate.WireRD.PreEntityCopy;
	ENT.PostEntityPaste = StarGate.WireRD.PostEntityPaste;
end

--################# OnRemove @aVoN
--added compatiblity with RD3 @JDM12989
function StarGate.WireRD.OnRemove(self,only_rd,only_wire)
	if CAF and not only_wire then
		if (self.IsNode) then
			CAF.LibRD.UnlinkAllFromNode(self.netid);
		else
			CAF.LibRD.Unlink(self.Entity); -- Lol, why someone not added this? Fix by AlexALX
		end
		CAF.LibRD.RemoveRDEntity(self.Entity);
	end
	if(not only_rd and WireAddon and (self.Outputs or self.Inputs)) then
		Wire_Remove(self.Entity);
	end
end

--################# OnRestore @aVoN
function StarGate.WireRD.OnRestore(self)
	if(WireAddon) then
		Wire_Restored(self.Entity);
	end
end

--##############################
-- Wire handling
--##############################

--################# Creates Wire Outputs @aVoN
-- Allows special datatypes now. Valid are NORMAL,VECTOR,ANGLE,COLOR,ENTITY,STRING,TABLE,ANY,BIDIRTABLE,HOVERDATAPORT
function StarGate.WireRD.CreateWireOutputs(self,...)
	if(WireAddon) then
		local data = {};
		local types = {};
		for k,v in pairs({...}) do
			if(type(v) == "table") then
				types[k] = v.Type;
				data[k] = v.Name;
			else
				data[k] = v;
			end
		end
		--self.Outputs = Wire_CreateOutputs(self.Entity,{...}); -- Old way, kept if I need to revert
		self.Outputs = WireLib.CreateSpecialOutputs(self.Entity,data,types);
	end
end

--################# Creates Wire Inputs @aVoN
-- Allows special datatypes now. Valid are NORMAL,VECTOR,ANGLE,COLOR,ENTITY,STRING,TABLE,ANY,BIDIRTABLE,HOVERDATAPORT
function StarGate.WireRD.CreateWireInputs(self,...)
	if(WireAddon) then
		local data = {};
		local types = {};
		for k,v in pairs({...}) do
			if(type(v) == "table") then
				types[k] = v.Type;
				data[k] = v.Name;
			else
				data[k] = v;
			end
		end
		--self.Inputs = Wire_CreateInputs(self.Entity,{...}); -- Old way, kept if I need to revert
		self.Inputs = WireLib.CreateSpecialInputs(self.Entity,data,types);
	end
end

--################# Sets a Wire value @aVoN
function StarGate.WireRD.SetWire(self,key,value,inp)
	if(WireAddon) then
		if (inp) then
			-- Special interaction to modify datatypes
			if(self.Inputs and self.Inputs[key]) then
				local datatype = self.Inputs[key].Type;
				if(datatype == "NORMAL") then
					-- Supports bools and converts them to numbers
					if(value == true) then
						value = 1;
					elseif(value == false) then
						value = 0;
					end
					-- If still not a number, make it a num now!
					value = tonumber(value);
				elseif(datatype == "STRING") then
					value = tostring(value);
				end
			end
			if(value ~= nil) then
				WireLib.TriggerInput(self.Entity,key,value);
			end
		else
			-- Special interaction to modify datatypes
			if(self.Outputs and self.Outputs[key]) then
				local datatype = self.Outputs[key].Type;
				if(datatype == "NORMAL") then
					-- Supports bools and converts them to numbers
					if(value == true) then
						value = 1;
					elseif(value == false) then
						value = 0;
					end
					-- If still not a number, make it a num now!
					value = tonumber(value);
				elseif(datatype == "STRING") then
					value = tostring(value);
				end
			end
			if(value ~= nil) then
				WireLib.TriggerOutput(self.Entity,key,value);
				if(self.WireOutput) then
					self:WireOutput(key,value);
				end
			end
		end
	end
end

--################# Gets a Wire value @aVoN
function StarGate.WireRD.GetWire(self,key,default,out)
	if(WireAddon) then
		if (out) then
			if(self.Outputs and self.Outputs[key] and self.Outputs[key].Value) then
				return self.Outputs[key].Value or default or WireLib.DT[self.Outputs[key].Type].Zero;
			end
		else
			if(self.Inputs and self.Inputs[key] and self.Inputs[key].Value) then
				return self.Inputs[key].Value or default or WireLib.DT[self.Inputs[key].Type].Zero;
			end
		end
	end
	return default or 0; -- Error. Either wire is not installed or the input is not SET. Return the default value instead
end

--##############################
--  Resource Distribution Handling
--##############################

--################# Register a Resource @aVoN
--added compatiblity with RD3 @JDM12989
function StarGate.WireRD.AddResource(self,resource,maximum,default)
	if CAF then
		CAF.LibRD.AddResource(self.Entity,resource,maximum or 0,default or 0)
	end
end

--################# Get a Resource's ammount @aVoN
--added compatiblity with RD3 @JDM12989
function StarGate.WireRD.GetResource(self,resource,default)
	if CAF then
		return CAF.LibRD.GetResourceAmount(self.Entity,resource) or default or 0
	else
		return default or 0
	end
end

--################# Consume some of this resource @aVoN
--added compatiblity with RD3 @JDM12989
function StarGate.WireRD.ConsumeResource(self,resource,ammount)
	if CAF then
		return CAF.LibRD.ConsumeResource(self.Entity,resource,ammount or 0);
	end
end

--################# Supply a specific ammount to this resource @aVoN
--added compatiblity with RD3 @JDM12989
function StarGate.WireRD.SupplyResource(self,resource,ammount)
	if CAF then
		CAF.LibRD.SupplyResource(self.Entity,resource,ammount or 0)
	end
end

--################# This units capacity @aVoN
--added compatiblity with RD3 @JDM12989
function StarGate.WireRD.GetUnitCapacity(self,resource,default)
	if CAF then
		return CAF.LibRD.GetUnitCapacity(self.Entity,resource) or default or 0;
	else
		return default or 0
	end
end

--################# This networks capacity @aVoN
--added compatiblity with RD3 @JDM12989
function StarGate.WireRD.GetNetworkCapacity(self,resource,default)
	if CAF then
		return CAF.LibRD.GetNetworkCapacity(self.Entity,resource) or default or 0;
	else
		return default or 0;
	end
end

-- Added by AlexALX for zpm hubs etc
function StarGate.WireRD.GetEntListTable(ent)
	if (not IsValid(ent)) then return {}; end
	if CAF then
		local entTable = CAF.LibRD.GetEntityTable(ent);
		local netTable = CAF.LibRD.GetNetTable(entTable["network"]);
		return netTable["entities"] or {};
	end
	return {};
end

-- correct connected status displaying by AlexALX
function StarGate.WireRD.Connected(ent)
	if (not IsValid(ent)) then return false; end
	if CAF then
		local entTable = CAF.LibRD.GetEntityTable(ent);
		if (entTable["network"] and entTable["network"]>0) then
			return true;
		end
	end
	return false;
end

--##############################
--  Duplicator handling
--##############################

--################# Store Entity modifiers @aVoN
function StarGate.WireRD.PreEntityCopy(self)
	if CAF then CAF.LibRD.BuildDupeInfo(self.Entity) end

	if(WireAddon) then
		local data = WireLib.BuildDupeInfo(self.Entity);
		if(data) then
			duplicator.StoreEntityModifier(self.Entity,"WireDupeInfo",data);
		end
	end
end

--################# Restore entity modifiers @aVoN
function StarGate.WireRD.PostEntityPaste(self,Player,Ent,CreatedEntities)
	if CAF then CAF.LibRD.ApplyDupeInfo(Ent,CreatedEntities) end
	
	if(WireAddon) then
		if(Ent.EntityMods and Ent.EntityMods.WireDupeInfo) then
			WireLib.ApplyDupeInfo(Player,Ent,Ent.EntityMods.WireDupeInfo,function(id) return CreatedEntities[id] end);
		end
	end
end


-- damn new wiremod update.

StarGate.KeysConst = StarGate.KeysConst or {
	[KEY_ENTER] = 10,
	[KEY_BACKSPACE] = 127,
}

hook.Add( "Initialize", "StarGate.Wiremod.KeysInit", function()
	if (Wire_Keyboard_Remap and Wire_Keyboard_Remap.American and Wire_Keyboard_Remap.American.normal) then
		StarGate.KeysConst[KEY_ENTER] = Wire_Keyboard_Remap.American.normal[KEY_ENTER]
		StarGate.KeysConst[KEY_BACKSPACE] = Wire_Keyboard_Remap.American.normal[KEY_BACKSPACE]
	end
end)