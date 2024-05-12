local vter = mods.TNE.vter

local exTele= "TNE_EX_TELEPORTER"

script.on_internal_event(Defines.InternalEvents.DAMAGE_AREA_HIT, function(ship, projectile, location, damage, shipFriendlyFire)

	if (projectile == nil) then return end
	if (Hyperspace.Get_Projectile_Extend(projectile).name ~= exTele ) then return end
	
	local playerShip = Hyperspace.ships.player
	local weaponSysId = playerShip:GetSystemRoom(3)
	local targetRoomId = Hyperspace.ShipGraph.GetShipInfo(ship.iShipId):GetSelectedRoom(location.x,location.y,true)
	
	local returnCrew = (weaponSysId == targetRoomId) and (ship.iShipId == 0)
	local playSound = false

	if (returnCrew) then
		local crews = Hyperspace.ships.enemy.vCrewList
		for c in vter(crews) do
			local extend = Hyperspace.Get_CrewMember_Extend(c)
			local canTeleport = (c.iShipId == 0 and c.bMindControlled == false) or (c.iShipId ~= 0 and c.bMindControlled)
			local isCrew = c:IsCrew()
			local canCrewTeleport = c:CanTeleport()
			if canTeleport and isCrew and canCrewTeleport then
				extend:InitiateTeleport(ship.iShipId, targetRoomId, 0)
				playSound = true
			end
		end
	else
		local crews = playerShip.vCrewList
		for c in vter(crews) do
			local extend = Hyperspace.Get_CrewMember_Extend(c)

			local isInWeaponSys = c:InsideRoom(weaponSysId)

			local canTeleport = (c.iShipId == 0 and c.bMindControlled == false) or (c.iShipId ~= 0 and c.bMindControlled)
			canTeleport = canTeleport and c:CanTeleport()

			local isCrew = c:IsCrew()
			if (isInWeaponSys) and (c.bActiveManning == false) and canTeleport and isCrew then
				extend:InitiateTeleport(ship.iShipId, targetRoomId, 0)
				playSound = true
			end
		end
	end

	if (playSound) then
		Hyperspace.Global.GetInstance():GetSoundControl():PlaySoundMix("teleport",-1,false)
	end
	return Defines.Chain.CONTINUE
end)