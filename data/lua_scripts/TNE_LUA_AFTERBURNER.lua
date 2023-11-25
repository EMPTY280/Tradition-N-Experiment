local vter = mods.TNE.vter
local weaponName = { }
weaponName["TNE_PARTICLE_AFTERBURNER"] = { chargeBonus = 0.15 }

script.on_internal_event(Defines.InternalEvents.PROJECTILE_FIRE, function(projectile, weapon)
	local weaponData = nil
	pcall(function() weaponData = weaponName[weapon.blueprint.name] end)
	if (weaponData == nil) then return end

	local isLastShot = (weapon.queuedProjectiles:size() == 0)
	if (isLastShot == false) then return end

	local shipManager = Hyperspace.Global.GetInstance():GetShipManager(projectile.ownerId)
	local weapons = shipManager.weaponSystem.weapons
	for w in vter(weapons) do
		if (weaponName[w.blueprint.name] == nil) then
			if (w.powered) then
				if (w.cooldown.second > 0) then
					local bonusCharge = w.cooldown.second * weaponData.chargeBonus;
					w.cooldown.first = math.min(w.cooldown.first + bonusCharge, w.cooldown.second)
					if (w.cooldown.first == w.cooldown.second) then
						w:ForceCoolup()
					end
				end
			end
		end
	end
end)