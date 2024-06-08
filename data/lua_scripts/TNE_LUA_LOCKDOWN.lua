local lockdownWeapons = { }
lockdownWeapons["TNE_FOCUS_LOCKDOWN"] = true;
lockdownWeapons["TNE_BEAM_LOCKDOWN"] = true;

script.on_internal_event(Defines.InternalEvents.DAMAGE_BEAM, function(shipManager, projectile, location, damage, newTile, beamHit)
	if (projectile == nil) then return end
	if (lockdownWeapons[Hyperspace.Get_Projectile_Extend(projectile).name]) then
		if (beamHit == Defines.BeamHit.NEW_ROOM) then
			local room = Hyperspace.ShipGraph.GetShipInfo(shipManager.iShipId):GetSelectedRoom(location.x, location.y, true)
			if (room ~= -1) then
				shipManager.ship:LockdownRoom(room, location)
				Hyperspace.Global.GetInstance():GetSoundControl():PlaySoundMix("lockdown1", -1, false)
			end
		end
	end
end)