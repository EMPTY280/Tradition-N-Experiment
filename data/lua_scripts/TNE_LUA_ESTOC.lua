local weaponName = "TNE_FOCUS_CAPACITOR"

script.on_internal_event(Defines.InternalEvents.PROJECTILE_PRE, function(projectile)
	if (weaponName[Hyperspace.Get_Projectile_Extend(projectile).name]) then
		projectile.damage.breachChance = projectile.damage.iDamage
	end
end)