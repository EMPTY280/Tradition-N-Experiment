local shieldDamageWeapons = {}
shieldDamageWeapons["TNE_BEAM_SAPPER"] = 2

script.on_internal_event(Defines.InternalEvents.SHIELD_COLLISION_PRE, function(shipManager, projectile, damage, response)
	local shieldPower = shipManager.shieldSystem.shields.power
	local weaponData = shieldDamageWeapons[Hyperspace.Get_Projectile_Extend(projectile).name]

	if (weaponData) then
		if (shieldPower.super.first < 1) then
			if (shieldPower.first <= weaponData) then
				shieldPower.first = 0
			end
		end
	end
	return Defines.Chain.CONTINUE
end)