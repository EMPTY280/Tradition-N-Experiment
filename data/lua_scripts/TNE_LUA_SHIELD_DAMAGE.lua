local shieldDamageWeapons = {}
shieldDamageWeapons["TNE_RAILGUN_1"] = 2
shieldDamageWeapons["TNE_RAILGUN_2"] = 3

script.on_internal_event(Defines.InternalEvents.SHIELD_COLLISION_PRE, function(shipManager, projectile, damage, response)
	local shieldPower = shipManager.shieldSystem.shields.power
	local weaponData = shieldDamageWeapons[Hyperspace.Get_Projectile_Extend(projectile).name]

	if (weaponData) then
		if (shieldPower.super.first < 1) then
			shieldPower.first = math.max(0, shieldPower.first - weaponData)
		end
		shipManager.shieldSystem:CollisionReal(projectile.position.x, projectile.position.y, Hyperspace.Damage(), true)
	end
	return Defines.Chain.CONTINUE
end)