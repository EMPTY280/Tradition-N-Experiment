local vter = mods.TNE.vter

local intelDrones = { }
intelDrones["TNE_DRONE_PRIORITY"] = { 0, 1, 3 }
intelDrones["TNE_DRONE_LOCKON_SHIELD"] = { 0 }
intelDrones["TNE_DRONE_LOCKON_ENGINE"] = { 1 }
intelDrones["TNE_DRONE_LOCKON_OXYGEN"] = { 2 }
intelDrones["TNE_DRONE_LOCKON_WEAPON"] = { 3 }
intelDrones["TNE_DRONE_LOCKON_DRONE"] = { 4 }
intelDrones["TNE_DRONE_LOCKON_MEDBAY"] = { 5 }
intelDrones["TNE_DRONE_LOCKON_PILOT"] = { 6 }
intelDrones["TNE_DRONE_LOCKON_SENSOR"] = { 7 }
intelDrones["TNE_DRONE_LOCKON_DOOR"] = { 8 }
intelDrones["TNE_DRONE_LOCKON_TELEPORTER"] = { 9 }
intelDrones["TNE_DRONE_LOCKON_CLOAK"] = { 10 }
intelDrones["TNE_DRONE_LOCKON_ARTILLERY"] = { 11 }
intelDrones["TNE_DRONE_LOCKON_BATTERY"] = { 12 }
intelDrones["TNE_DRONE_LOCKON_CLONE"] = { 13 }
intelDrones["TNE_DRONE_LOCKON_MIND"] = { 14 }
intelDrones["TNE_DRONE_LOCKON_HACKING"] = { 15 }
intelDrones["TNE_DRONE_LOCKON_TEMPORAL"] = { 20 }
--[[
    SYS_SHIELDS,    //0
    SYS_ENGINES,    //1
    SYS_OXYGEN,     //2
    SYS_WEAPONS,    //3
    SYS_DRONES,     //4
    SYS_MEDBAY,     //5
    SYS_PILOT,      //6
    SYS_SENSORS,    //7
    SYS_DOORS,      //8
    SYS_TELEPORTER, //9
    SYS_CLOAKING,   //10
    SYS_ARTILLERY,  //11
    SYS_BATTERY,    //12
    SYS_CLONEBAY,   //13
    SYS_MIND,       //14
    SYS_HACKING,    //15
    SYS_TEMPORAL    // 20
]]--

local function SetProjectileTarget(projectile, pointf)

	projectile.target = pointf
	projectile:ComputeHeading()
end

script.on_internal_event(Defines.InternalEvents.DRONE_FIRE, function(projectile, spacedrone)

	local droneName = spacedrone.blueprint.name
	if (intelDrones[droneName] == nil) then
		return
	end

	local shipManager = nil

	if projectile.targetId == 0 then
		shipManager = Hyperspace.ships.player
	else
		shipManager = Hyperspace.ships.enemy
	end

	local systemTargets = intelDrones[droneName]
	for index, systemId in ipairs(systemTargets) do
		if (shipManager:HasSystem(systemId)) then
			if (systemId ~= 11) then
				local targetSys = shipManager:GetSystem(systemId)
				if (targetSys:CompletelyDestroyed() == false) then
					local systemRoom = shipManager:GetSystemRoom(systemId)

					SetProjectileTarget(projectile, shipManager:GetRoomCenter(systemRoom))

					return Defines.Chain.CONTINUE
				end
			else -- Artillery
				local artillerys = shipManager.artillerySystems
				for artillery in vter(artillerys) do
					if (artillery:CompletelyDestroyed() == false) then
						local systemRoom = artillery.roomId

						SetProjectileTarget(projectile, shipManager:GetRoomCenter(systemRoom))

						return Defines.Chain.CONTINUE
					end
				end
			end
		end
	end

	return Defines.Chain.CONTINUE
end)