local shieldDamageWeapons = {}
shieldDamageWeapons["TNE_RAILGUN_1"] = { damage = 2, damageE = 0, killOnHit = false }
shieldDamageWeapons["TNE_RAILGUN_2"] = { damage = 3, damageE = 0, killOnHit = false }
shieldDamageWeapons["TNE_ELECTRON_1"] = { damage = 1, damageE = 2, killOnHit = true }
shieldDamageWeapons["TNE_ELECTRON_2"] = { damage = 1, damageE = 2, killOnHit = true }

script.on_internal_event(Defines.InternalEvents.SHIELD_COLLISION, function(shipManager, projectile, damage, response)
	local shieldPower = shipManager.shieldSystem.shields.power
	local weaponData = shieldDamageWeapons[Hyperspace.Get_Projectile_Extend(projectile).name]

	if (weaponData) then
		if (shieldPower.super.first < 1) then
			if (response.superDamage < 1) then
				shieldPower.first = math.max(0, shieldPower.first - weaponData.damage)
			end
		else
			if (weaponData.damageE > 0) then
				shieldPower.super.first = math.max(0, shieldPower.super.first - weaponData.damageE)
			end
		end
		if (weaponData.killOnHit) then
			projectile:Kill()
		end
		shipManager.shieldSystem:CollisionReal(projectile.position.x, projectile.position.y, Hyperspace.Damage(), true)
	end
	return Defines.Chain.CONTINUE
end)