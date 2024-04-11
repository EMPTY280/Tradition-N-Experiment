local vter = mods.TNE.vter
local weaponName = { }
weaponName["TNE_PARTICLE_AFTERBURNER"] = { chargeBonus = 0.15 }

script.on_internal_event(Defines.InternalEvents.PROJECTILE_FIRE, function(projectile, weapon)
	local weaponData = nil
	pcall(function() weaponData = weaponName[weapon.blueprint.name] end)
	if (weaponData == nil) then return end

	local isLastShot = (weapon.queuedProjectiles:size() == 0)
	if (isLastShot == false) then return end

	local shipManager = Hyperspace.ships(projectile.ownerId)
	local weapons = shipManager.weaponSystem.weapons
	for w in vter(weapons) do
		if (weaponName[w.blueprint.name] == nil) then
			if (w.powered) then
				if (w.cooldown.second > 0) then
					local bonusCharge = w.cooldown.second * weaponData.chargeBonus;
					w.cooldown.first = math.min(w.cooldown.first + bonusCharge, w.cooldown.second)
					if (w.cooldown.first == w.cooldown.second) then	
						local goalLevel = w.blueprint.chargeLevels
						if (goalLevel == w.chargeLevel) then
							return
						end
						local newChargeLevel = w.chargeLevel + 1
						w.chargeLevel = newChargeLevel
						if (goalLevel > 1) then
							w.cooldown.first = 0
						end
						return true
					end

				end
			end
		end
	end
end)