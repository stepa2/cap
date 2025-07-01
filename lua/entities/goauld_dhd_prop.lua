--[[
	Goauld DHD
	Copyright (C) 2010 Madman07
]]--

if (StarGate!=nil and StarGate.LifeSupportAndWire!=nil) then StarGate.LifeSupportAndWire(ENT); end
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Goa'uld DHD"
ENT.Author = "Madman07"
ENT.Category = "Stargate Carter Addon Pack"
ENT.WireDebugName = "Goa'uld DHD"

ENT.Spawnable = false
ENT.AdminSpawnable = false

if SERVER then
AddCSLuaFile();

-----------------------------------INIT----------------------------------

function ENT:Initialize()

	util.PrecacheModel("models/Boba_Fett/portable_dhd/portable_dhd.mdl")
	self.Entity:SetModel("models/Boba_Fett/portable_dhd/portable_dhd.mdl");

	self.Entity:SetName("Goa'uld DHD");
	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetSolid(SOLID_VPHYSICS);
	self.Entity:SetUseType(SIMPLE_USE);

	-- now its wrong, zpms have new code for energy and this thing not work anymore, also all this shit not work with Environments addon
	-- and like i remember it can dial only 7 chevrons, so goauld_dhd_pros is like dhd and this code not needed.
	/*self.MaxEnergy = StarGate.CFG:Get("zpm","capacity",10000000);
	self:AddResource("ZPE",self.MaxEnergy); --ZeroPoint energy @Anorr
	self:SupplyResource("ZPE",self.MaxEnergy);
	self:AddResource("energy",StarGate.CFG:Get("zpm","energy_capacity",5000)); -- Maximum energy to store in a ZPM is 5000 units   */


end

-----------------------------------USE----------------------------------

function ENT:Use(ply)
	ply:Give("goauld_dhd");
	ply:SelectWeapon("goauld_dhd");
	self.Entity:Remove()
end

function ENT:DialMenu()
	//if(self.HasRD) then self.Entity:Power(); end
	if(hook.Call("StarGate.Player.CanDialGate",GAMEMODE,self.Owner,self.Gates) == false) then return end;
	net.Start("StarGate.VGUI.Menu");
	net.WriteEntity(self.Gates);
	net.WriteInt(1,8);
	net.Send(self.Owner);
end

if (StarGate and StarGate.CAP_GmodDuplicator) then
	duplicator.RegisterEntityClass( "goauld_dhd_prop", StarGate.CAP_GmodDuplicator, "Data" )
end

end