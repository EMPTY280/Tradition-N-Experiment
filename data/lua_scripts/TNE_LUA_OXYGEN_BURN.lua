local oxygenBurners = { }
oxygenBurners["TNE_MISSILES_BREACH"] = { oxygenChange = -100 }
oxygenBurners["TNE_BEAM_BREACH_2"] = { oxygenChange = -50 }

function ChangeOxygenLevel(ship, projectile, location)
	if (projectile == nil) then return end

	local weaponData = nil
	pcall(function() weaponData = oxygenBurners[Hyperspace.Get_Projectile_Extend(projectile).name] end)
	if (weaponData == nil) then return end

	local oxygenSystem = ship.oxygenSystem
	if (oxygenSystem == nil) then return end

	local targetRoomId = Hyperspace.ShipGraph.GetShipInfo(ship.iShipId):GetSelectedRoom(location.x,location.y,true)
	oxygenSystem:ModifyRoomOxygen(targetRoomId, weaponData.oxygenChange)
end

script.on_internal_event(Defines.InternalEvents.DAMAGE_AREA_HIT, function(ship, projectile, location, damage, shipFriendlyFire)
	ChangeOxygenLevel(ship, projectile, location)
end)

script.on_internal_event(Defines.InternalEvents.DAMAGE_BEAM, function(ship, projectile, location, damage, newTile, beamHit)
	if (beamHit ~= Defines.BeamHit.NEW_ROOM) then return end
	ChangeOxygenLevel(ship, projectile, location)
end)