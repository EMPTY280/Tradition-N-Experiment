local vter = mods.TNE.vter

local rechargerWeapons = { }
rechargerWeapons["TNE_EX_RECHARGER_MINOR"] = { threshold = 3 }
rechargerWeapons["TNE_EX_RECHARGER_1"] = { threshold = 6 }
rechargerWeapons["TNE_EX_RECHARGER_2"] = { threshold = 8 }

local function IsReady(exSys)
	local actTheshold = rechargerWeapons[exSys.blueprint.name].threshold * (exSys.cooldown.second / exSys.baseCooldown)
	return exSys.cooldown.first >= actTheshold and exSys.powered
end

local function Recharge(weapon, exSystem)
	-- Is preemptive weapon?
	if (weapon.cooldown.second < 0) then return end
	if (weapon.chargeLevel < 1) then
		local chargeCount = math.min(weapon.cooldown.second - weapon.cooldown.first, exSystem.cooldown.first)
		exSystem.cooldown.first = exSystem.cooldown.first - chargeCount
		weapon.cooldown.first = weapon.cooldown.first + chargeCount
		if (weapon.cooldown.first == weapon.cooldown.second) then	
			local newChargeLevel = weapon.chargeLevel + 1
			weapon.chargeLevel = newChargeLevel
			if (weapon.blueprint.chargeLevels > 1) then
				weapon.cooldown.first = 0
			end
			return true
		end
	end
	return false
end

script.on_internal_event(Defines.InternalEvents.PROJECTILE_FIRE, function(projectile, weapon)
	if weapon.isArtillery then return end
	local weapons = nil 
	if projectile.ownerId == 0 then
		pcall(function() weapons = Hyperspace.ships.player.weaponSystem.weapons end)
	else
		pcall(function() weapons = Hyperspace.ships.enemy.weaponSystem.weapons end)
	end

	if weapons then
		for w in vter(weapons) do
			if rechargerWeapons[w.blueprint.name] then
				if IsReady(w) then
					if Recharge(weapon, w) then
						break
					end
				end
			end
		end
	end
	return Defines.Chain.CONTINUE
end)