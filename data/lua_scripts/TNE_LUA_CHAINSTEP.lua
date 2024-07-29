local vter = mods.TNE.vter

local chainWeaponList = { }
chainWeaponList["TNE_FOCUS_CAPACITOR"] = { fireThreshold = 7, chainStep = 3.5 }
chainWeaponList["TNE_POLARSTAR_4"] = { fireThreshold = 10, chainStep = 6 }
chainWeaponList["TNE_BEAM_CAPACITOR"] = { fireThreshold = 11, chainStep = 8 }
chainWeaponList["TNE_CRYSTAL_SPEAR"] = { fireThreshold = 8, chainStep = 3 }
chainWeaponList["TNE_CRYSTAL_SPEAR_ELITE"] = { fireThreshold = 8, chainStep = 3 }

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
					if (w.cooldown.first >= w.cooldown.second) then
						overCharge = w.blueprint.boostPower.count
					end
					w.boostLevel = overCharge
				end
			end
		end
	end

end)