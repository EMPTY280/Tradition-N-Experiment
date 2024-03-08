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

script.on_game_event("FUEL_FLEET_DELAY", false, PreIgniteEx)
script.on_game_event("FUEL_NOTHING", false, PreIgniteEx)
script.on_game_event("FUEL_FREEMANTIS_CONFUSED", false, PreIgniteEx)
script.on_game_event("FUEL_TRADER", false, PreIgniteEx)
script.on_game_event("FUEL_EXPLORE", false, PreIgniteEx)
script.on_game_event("FUEL_APPROACH", false, PreIgniteEx)
script.on_game_event("FUEL_OFF_ENGI_DUBIOUS", false, PreIgniteEx)
script.on_game_event("FUEL_ROCK", false, PreIgniteEx)
script.on_game_event("NO_FUEL_REFUGEE_FRIENDLY", false, PreIgniteEx)

script.on_game_event("FUEL_NOTHING_DISTRESS", false, PreIgniteEx)
script.on_game_event("FUEL_SHELL_SCANS", false, PreIgniteEx)

script.on_game_event("FUEL_SELLER_DISTRESS", false, PreIgniteEx)
script.on_game_event("FUEL_TRADER_DISTRESS", false, PreIgniteEx)
script.on_game_event("FUEL_ON_SLUG_OVERPRICED", false, PreIgniteEx)
script.on_game_event("FUEL_ON_SLUG_CHUCKLE", false, PreIgniteEx)
script.on_game_event("FUEL_ON_MANTIS_ATTACK", false, PreIgniteEx)
script.on_game_event("FUEL_ON_REBEL_WARNING", false, PreIgniteEx)
script.on_game_event("FUEL_ON_REBEL_ATTACK", false, PreIgniteEx)
script.on_game_event("FUEL_ON_DYNASTY", false, PreIgniteEx)

script.on_game_event("NO_FUEL_REFUGEE", false, PreIgniteEx)

script.on_game_event("NO_FUEL_FLEET", false, PreIgniteEx)
script.on_game_event("NO_FUEL_FLEET_DLC", false, PreIgniteEx)

script.on_game_event("COMBAT_CHECK_FLAGSHIP", false, PreIgniteEx)