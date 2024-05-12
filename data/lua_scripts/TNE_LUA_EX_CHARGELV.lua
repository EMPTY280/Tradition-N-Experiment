local vter = mods.TNE.vter

local readyTable = { }
readyTable["TNE_EX_RECHARGER_MINOR"] = { threshold = 3, maxCharge = 1, type = 0 } -- 0 == RECHARGER
readyTable["TNE_EX_RECHARGER_1"] = { threshold = 6, maxCharge = 1, type = 0 }
readyTable["TNE_EX_RECHARGER_2"] = { threshold = 8, maxCharge = 1, type = 0 }

readyTable["TNE_EX_REPEL_MINOR"] = { threshold = 10, maxCharge = 1, type = 1 }
readyTable["TNE_EX_REPEL_1"] = { threshold = 20, maxCharge = 3, type = 1 }
readyTable["TNE_EX_REPEL_2"] = { threshold = 20, maxCharge = 5, type = 1 }
readyTable["TNE_EX_REPEL_OVER"] = { threshold = 20, maxCharge = 5, type = 1 }

local function UpdateRechargerBoostLV (exSystem, threshold, maximumCharge)
	local active = threshold / exSystem.baseCooldown
	local charge = exSystem.cooldown.first / exSystem.cooldown.second
	if (active <= charge) then
		exSystem.boostLevel = maximumCharge
	else
		exSystem.boostLevel = 0
	end
end

local function UpdateRepulsorBoostLV (exSystem, threshold, maximumCharge)
	local charge = exSystem.cooldown.first / exSystem.cooldown.second
	exSystem.boostLevel = math.floor(charge * maximumCharge)
end

-- UPDATE CHARGE LEVEL
script.on_internal_event(Defines.InternalEvents.ON_TICK, function()
	local weapons = {}
	pcall(function() weapons[0] = Hyperspace.ships.player.weaponSystem.weapons end)
	pcall(function() weapons[1] = Hyperspace.ships.enemy.weaponSystem.weapons end)
	for i = 0, 1, 1 do
		if weapons[i] then
			for w in vter(weapons[i]) do
				local target = readyTable[w.blueprint.name]
				if target then
					-- Prevent from fire
					if w.chargeLevel ~= 0 then
						w.chargeLevel = 0
						w.cooldown.first = w.cooldown.second
					end	
					local maxC = target.maxCharge
					local thres = target.threshold
					if (target.type == 0) then
						UpdateRechargerBoostLV(w, thres, maxC)
					elseif (target.type == 1) then
						UpdateRepulsorBoostLV(w, thres, maxC)
					end
				end
			end
		end
	end
end)