local spurWeapon = "TNE_POLARSTAR_4"

------------------------------------------------------------------------------------

script.on_internal_event(Defines.InternalEvents.PROJECTILE_PRE, function(projectile)

	if (Hyperspace.Get_Projectile_Extend(projectile).name == spurWeapon) then
		projectile.damage.fireChance = projectile.damage.iDamage
		projectile.damage.breachChance = projectile.damage.iDamage + 1
	end

end)

script.on_internal_event(Defines.InternalEvents.PROJECTILE_FIRE, function(projectile, weapon)
	if (weapon.blueprint.name == spurWeapon) then
		local damage = projectile.damage.iDamage
		
		if (damage == 3) then
			Hyperspace.Global.GetInstance():GetSoundControl():PlaySoundMix("tne_sound_spur_3",-1,false)
		elseif (damage == 2) then
			Hyperspace.Global.GetInstance():GetSoundControl():PlaySoundMix("tne_sound_spur_2",-1,false)
		else
			Hyperspace.Global.GetInstance():GetSoundControl():PlaySoundMix("tne_sound_spur_1",-1,false)
		end
	end
end)

