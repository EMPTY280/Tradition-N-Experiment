local tachyonWeapons = { }
tachyonWeapons["TNE_LASER_TACHYON"] = { damage = 3 };

script.on_internal_event(Defines.InternalEvents.DAMAGE_AREA, function(shipManager, projectile, location, damage, forceHit, friendly)

	if (projectile == nil) then return end

	local tachyonData = tachyonWeapons[Hyperspace.Get_Projectile_Extend(projectile).name]
	
	if (tachyonData) then
		damage.iDamage = tachyonData.damage
	end
end)