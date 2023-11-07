
local weaponName= "TNE_EX_ION_STABILIZER"

-------------------------------- Ex Systems Function -----------------------------------------------

-- ION REMOVER
script.on_internal_event(Defines.InternalEvents.DAMAGE_AREA_HIT, function(shipManager, projectile, location, damage, shipManagerFriendlyFire)
	if (projectile == nil) then return end
	if (Hyperspace.Get_Projectile_Extend(projectile).name ~= weaponName ) then return end

	local room = Hyperspace.ShipGraph.GetShipInfo(shipManager.iShipId):GetSelectedRoom(location.x, location.y, true)
	local systemInRoom = shipManager:GetSystemInRoom(room)
	if (systemInRoom) then
		local ioned = systemInRoom:GetLocked()
		if (ioned) then
			Hyperspace.Global.GetInstance():GetSoundControl():PlaySoundMix("tne_sound_ex_stabilizer",-1,false)
			systemInRoom:LockSystem(0)
		end
	end
	return Defines.Chain.CONTINUE
end)