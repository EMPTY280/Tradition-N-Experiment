local chainWeaponList = { }
chainWeaponList["TNE_LASER_SASHA"] = { minShots = 3, maxShots = 6 }

script.on_internal_event(Defines.InternalEvents.PROJECTILE_FIRE, function(projectile, weapon)
	local boost = nil
	pcall(function() boost = chainWeaponList[weapon.blueprint.name] end)

	if (boost == nil) then return end
	local weaponBoostLevel = weapon.weaponVisual.boostLevel + 1
	local firedShots = boost.maxShots - weapon.queuedProjectiles:size()
	if (firedShots >= boost.minShots + weaponBoostLevel) then
		weapon.queuedProjectiles:clear()
	end
end)