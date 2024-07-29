local weaponName = { }
weaponName["TNE_CRYSTAL_SPEAR"] = true
weaponName["TNE_CRYSTAL_SPEAR_ELITE"] = true

script.on_internal_event(Defines.InternalEvents.PROJECTILE_PRE, function(projectile)
	local weaponChanceData = weaponName[Hyperspace.Get_Projectile_Extend(projectile).name]
	if (weaponChanceData) then
		local statusChance = math.max(0, projectile.damage.iDamage) * 2
		projectile.damage.breachChance = statusChance
		projectile.damage.stunChance = statusChance
	end
end)