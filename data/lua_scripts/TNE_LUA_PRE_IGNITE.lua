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
local exTele= "TNE_EX_TELEPORTER"

function PreIgniteEx()
	local playerShip = Hyperspace.ships.player
	if (playerShip.weaponSystem == nil) then return end
	local weapons = playerShip.weaponSystem.weapons

	if weapons then
		for w in vter(weapons) do
			if exSystemPreTable[w.blueprint.name] then
				if w.powered then
					local chargeRate = w.cooldown.second / w.baseCooldown
					w.cooldown.first = exSystemPreTable[w.blueprint.name] * chargeRate
				end
			end
			if coolupTable[w.blueprint.name] then
				w:ForceCoolup()
			end
		end
	end
end
script.on_internal_event(Defines.InternalEvents.JUMP_ARRIVE, function(ship) PreIgniteEx() end)


script.on_game_event("NO_FUEL", false, PreIgniteEx)
script.on_game_event("NO_FUEL_DISTRESS", false, PreIgniteEx)

script.on_game_event("NO_FUEL_FLEET", false, PreIgniteEx)
script.on_game_event("NO_FUEL_FLEET_DLC", false, PreIgniteEx)


script.on_game_event("FLEET_THREAT_VLOW", false, PreIgniteEx)
script.on_game_event("FLEET_THREAT_LOW", false, PreIgniteEx)
script.on_game_event("FLEET_THREAT_MLOW", false, PreIgniteEx)
script.on_game_event("FLEET_THREAT_MEDIUM", false, PreIgniteEx)
script.on_game_event("FLEET_THREAT_HIGH", false, PreIgniteEx)
script.on_game_event("FLEET_THREAT_VHIGH", false, PreIgniteEx)
script.on_game_event("FLEET_THREAT_CRITICAL", false, PreIgniteEx)
script.on_game_event("FLEET_THREAT_CRITICAL_S8", false, PreIgniteEx)

script.on_game_event("COMBAT_CHECK_FLAGSHIP", false, PreIgniteEx)