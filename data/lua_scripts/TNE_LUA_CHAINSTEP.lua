local vter = mods.TNE.vter

local chainWeaponList = { }
chainWeaponList["TNE_FOCUS_CAPACITOR"] = { fireThreshold = 8, chainStep = 4 }
chainWeaponList["TNE_POLARSTAR_4"] = { fireThreshold = 10, chainStep = 6 }

------------------------------------------------------------------------------------

script.on_internal_event(Defines.InternalEvents.ON_TICK, function()
	
	local weapons = {}
	pcall(function() weapons[0] = Hyperspace.ships.player.weaponSystem.weapons end)
	pcall(function() weapons[1] = Hyperspace.ships.enemy.weaponSystem.weapons end)

	for i = 0, 1, 1 do
		if weapons[i] then
			for w in vter(weapons[i]) do
				local chainWeapon = chainWeaponList[w.blueprint.name]

				if chainWeapon then
					local chargeRate = w.cooldown.second / w.baseCooldown
					local fireThres = chainWeapon.fireThreshold * chargeRate
					local step = chainWeapon.chainStep * chargeRate

					if (w.cooldown.first >= fireThres) then
						w.chargeLevel = 1
					else
						w.chargeLevel = 0
					end

					local overCharge = math.floor(math.max(w.cooldown.first - fireThres, 0) / step)
					w.boostLevel = overCharge
				end
			end
		end
	end

end)