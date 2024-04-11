local weaponName = { }
weaponName["TNE_LASER_BLOOD"] = { Shots = 2, selfDamage = 1, hitHeal = 1 }

script.on_internal_event(Defines.InternalEvents.PROJECTILE_FIRE, function(projectile, weapon)
	local weaponData = nil
	pcall(function() weaponData = weaponName[weapon.blueprint.name] end)
	if (weaponData == nil) then return end

	local firedShots = weaponData.Shots - weapon.queuedProjectiles:size()
	if (firedShots == 1) then
		local shipManager = Hyperspace.ships(projectile.ownerId)
		shipManager:DamageHull(weaponData.selfDamage, true);
	end
end)

script.on_internal_event(Defines.InternalEvents.DAMAGE_AREA_HIT, function(ship, projectile, location, damage, shipFriendlyFire)
	if (projectile == nil) then return end

	local weaponData = nil
	pcall(function() weaponData = weaponName[Hyperspace.Get_Projectile_Extend(projectile).name] end)
	if (weaponData == nil) then return end

	local shipManager = Hyperspace.ships(projectile.ownerId)
	shipManager:DamageHull(-weaponData.hitHeal, true)
end)