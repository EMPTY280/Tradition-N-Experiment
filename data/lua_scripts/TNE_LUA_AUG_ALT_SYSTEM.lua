local vter = mods.TNE.vter

local cloakAugName = "TNE_ALT_CLOAK"
local lastCloakPow = { }
local cloakDamage = Hyperspace.Damage()

local hackAugName = "TNE_ALT_HACK"
local lastHackPow = { }
local hackDamage_1 = Hyperspace.Damage()
hackDamage_1.iSystemDamage = 1
local hackDamage_2 = Hyperspace.Damage()
hackDamage_2.breachChance = 10

local mindAugName = "TNE_ALT_MIND"
local lastMindPow = { }
local lastControledCrew = { }
local mindDamage = Hyperspace.Damage()
mindDamage.iPersDamage = 1
mindDamage.fireChance = 10

-- ALT CLOAK

local function IonizeShield(ship, damage)
	local system = ship.shieldSystem
	if (system == nil) then return end
	
	local shieldPower = system.shields.power
	if (shieldPower.super.first < 1) then
		local sysRoom = ship:GetSystemRoom(0)
		local center = ship:GetRoomCenter(sysRoom)
		ship:DamageArea(center, damage, true)
	else
		system:CollisionReal(system.center.x, system.center.y, damage, true)
	end
end

local function AltCloak(ship)
	if (ship:HasAugmentation(cloakAugName) < 1) then return end

	cloakSys = ship.cloakSystem
	if (cloakSys == nil) then return end

	local shipId = ship.iShipId
	if (cloakSys.bTurnedOn) then
		lastCloakPow[shipId] = cloakSys:GetEffectivePower()
	else
		if (lastCloakPow[shipId] ~= nil) then
			Hyperspace.Global.GetInstance():GetSoundControl():PlaySoundMix("pulsar", -1, false)

			cloakDamage.iIonDamage = lastCloakPow[shipId] * 2
			pcall(function() IonizeShield(Hyperspace.ships.player, cloakDamage) end)
			pcall(function() IonizeShield(Hyperspace.ships.enemy, cloakDamage) end)
		end
		lastCloakPow[shipId] = nil
	end
end

-- ALT HACKING

local function AltHacking(ship)
	if (ship:HasAugmentation(hackAugName) < 1) then return end
	hackSys = ship.hackingSystem
	if (hackSys == nil) then return end

	local shipId = ship.iShipId
	local isHackingActivated = (hackSys.effectTimer.first < hackSys.effectTimer.second)

	if (isHackingActivated) then
		lastHackPow[shipId] = hackSys:GetEffectivePower()
	else
		if (lastHackPow[shipId] ~= nil) then
			local targetShip = Hyperspace.Global.GetInstance():GetShipManager((ship.iShipId + 1) % 2)
			if (targetShip ~= nil) then
				local targetRoomId = hackSys.currentSystem:GetRoomId()
				local location = targetShip:GetRoomCenter(targetRoomId)
				targetShip:DamageArea(location, hackDamage_1, true)

				local repeats = lastHackPow[shipId]
				for i = 1, repeats, 1 do
					targetShip:DamageArea(location, hackDamage_2, true)
				end
			end
		end
		lastHackPow[shipId] = nil
	end
end

-- ALT MIND CONTROL

local function ControledCrewsCount(shipId)
	local count = lastControledCrew[shipId]
	if (count == nil) then count = 0 end
	return count
end

local function ClearControledCrew(shipId)
	lastControledCrew[shipId] = 0
end

local function SaveControledCrews(shipId, crews)
	lastControledCrew[shipId] = 0
	local tableIdx = shipId + 2
	for c in vter(crews) do
		lastControledCrew[tableIdx] = c
		lastControledCrew[shipId] = lastControledCrew[shipId] + 1
		tableIdx = tableIdx + 2
	end
end

local function BlastBody(shipId)
	local crewCount = lastControledCrew[shipId]
	for i = 1, crewCount, 1 do
		local targetCrew = lastControledCrew[shipId + i * 2]
		local targetShipId = targetCrew.currentShipId
		if (targetShipId > -1) then
			local targetShip = Hyperspace.Global.GetInstance():GetShipManager(targetShipId)
			if (targetShip ~= nil and targetShip.bDestroyed == false) then
				local location = targetShip:GetRoomCenter(targetCrew.iRoomId)
				mindDamage.iPersDamage = lastMindPow[shipId]
				targetShip:DamageArea(location, mindDamage, true)
			end
		end
	end

end

local function AltMind(ship)
	if (ship:HasAugmentation(mindAugName) < 1) then return end
	mindSys = ship.mindSystem
	if (mindSys == nil) then return end

	local shipId = ship.iShipId
	local isMindActivated = (mindSys.controlTimer.first < mindSys.controlTimer.second)

	if (isMindActivated) then
		lastMindPow[shipId] = mindSys:GetEffectivePower()
		if (ControledCrewsCount(shipId) == 0) then
			SaveControledCrews(shipId, mindSys.controlledCrew)
		end
	else
		if (lastMindPow[shipId] == nil) then return end
		BlastBody(shipId)
		ClearControledCrew(shipId)
		lastMindPow[shipId] = nil
	end
end

script.on_internal_event(Defines.InternalEvents.SHIP_LOOP, function(ship)
	AltCloak(ship)
	pcall(function() AltHacking(ship) end)
	pcall(function() AltMind(ship) end)
end)

local function ResetAug()
	lastMindPow[0] = nil
	lastHackPow[0] = nil
	lastCloakPow[0] = nil

	lastMindPow[1] = nil
	lastHackPow[1] = nil
	lastCloakPow[1] = nil
end
script.on_internal_event(Defines.InternalEvents.JUMP_ARRIVE, function(ship) ResetAug() end)
script.on_internal_event(Defines.InternalEvents.ON_WAIT, function(ship) ResetAug() end)