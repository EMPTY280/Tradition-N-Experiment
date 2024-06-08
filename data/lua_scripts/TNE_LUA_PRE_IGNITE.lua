local vter = mods.TNE.vter

-- Used for Ex System Pre-Ignite
local exSystemPreTable = { }
exSystemPreTable["TNE_EX_REPEL_MINOR"] = 10
exSystemPreTable["TNE_EX_REPEL_1"] = 20
exSystemPreTable["TNE_EX_REPEL_2"] = 40
exSystemPreTable["TNE_EX_REPEL_OVER"] = 100
exSystemPreTable["TNE_EX_TELEPORTER"] = 20
exSystemPreTable["TNE_EX_ION_STABILIZER"] = 60

local coolupTable = { }
coolupTable["TNE_EX_TELEPORTER"] = true
coolupTable["TNE_EX_ION_STABILIZER"] = true

local function PreIgniteEx()
	local playerShip = Hyperspace.ships.player
	if (playerShip.weaponSystem == nil) then return end
	local weapons = playerShip.weaponSystem.weapons

	if weapons then
		for w in vter(weapons) do
			if exSystemPreTable[w.blueprint.name] then
				if w.powered then
					local chargeRate = w.cooldown.second / w.baseCooldown
					local igniteValue = exSystemPreTable[w.blueprint.name] * chargeRate
					if (w.cooldown.first < igniteValue) then
						w.cooldown.first = igniteValue
					end
				end
			end
			if coolupTable[w.blueprint.name] then
				w:ForceCoolup()
			end
		end
	end
end
script.on_internal_event(Defines.InternalEvents.JUMP_ARRIVE, function(ship) PreIgniteEx() end)
script.on_internal_event(Defines.InternalEvents.ON_WAIT, function(ship) PreIgniteEx() end)