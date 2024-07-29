local damageDownWeapons = {}
damageDownWeapons["TNE_AUTOCANNON_0"] = true
damageDownWeapons["TNE_AUTOCANNON_1"] = true
damageDownWeapons["TNE_AUTOCANNON_2"] = true
damageDownWeapons["TNE_AUTOCANNON_3"] = true
damageDownWeapons["TNE_CRYSTAL_SPEAR"] = true
damageDownWeapons["TNE_CRYSTAL_SPEAR_ELITE"] = true

script.on_internal_event(Defines.InternalEvents.SHIELD_COLLISION, function(shipManager, projectile, damage, response)
	local shieldPower = shipManager.shieldSystem.shields.power
	if (damageDownWeapons[Hyperspace.Get_Projectile_Extend(projectile).name]) then
		projectile.damage.iDamage = math.max(projectile.damage.iDamage - shieldPower.first, 0)
	end
	return Defines.Chain.CONTINUE
end)