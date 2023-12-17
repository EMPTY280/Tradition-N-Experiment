local activeDrones = { }
activeDrones["TNE_DRONE_ACTIVE_OVERCHARGER"] = true

script.on_internal_event(Defines.InternalEvents.DRONE_FIRE, function(projectile, spacedrone)

	local droneName = spacedrone.blueprint.name
	if (activeDrones[droneName] == nil) then
		return
	end

	local shipManager = nil

	if projectile.ownerId == 0 then
		shipManager = Hyperspace.ships.player
	else
		shipManager = Hyperspace.ships.enemy
	end
	projectile:Kill()

	local shieldSystem = shipManager.shieldSystem
	local droneLocation = spacedrone.currentLocation
	shieldSystem:AddSuperShield(Hyperspace.Point(droneLocation.x, droneLocation.y))

	return Defines.Chain.CONTINUE
end)