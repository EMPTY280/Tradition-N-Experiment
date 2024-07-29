local droneName = { }
droneName["TNE_DRONE_GAZER"] = { killProj = true }
droneName["TNE_DRONE_GAZER_2_LASER"] = { killProj = false }
droneName["TNE_DRONE_GAZER_2_SPEED"] = { killProj = true }
local engineIonDamage = Hyperspace.Damage()
engineIonDamage.iIonDamage = 1

script.on_internal_event(Defines.InternalEvents.DRONE_FIRE, function(projectile, spacedrone)

	if (droneName[spacedrone.blueprint.name] == nil) then
		return
	end

	if (droneName[spacedrone.blueprint.name].killProj == true) then
		projectile:Kill()
	end

	local shipManager = nil
	if projectile.targetId == 0 then
		shipManager = Hyperspace.ships.player
	else
		shipManager = Hyperspace.ships.enemy
	end

	if (shipManager:HasSystem(1)) then
		local systemRoom = shipManager:GetSystemRoom(1)
		local center = shipManager:GetRoomCenter(systemRoom)
		shipManager:DamageArea(center, engineIonDamage, true)
	end

	return Defines.Chain.CONTINUE
end)