local vter = mods.TNE.vter

-------------------------------- Ex Systems Data -----------------------------------------------

local function Recharger_func(weapon, exSystem)
	if (weapon.cooldown.second < 0) then
		return
	end
	if weapon.chargeLevel < 1 then
		local chargeCount = math.min(weapon.cooldown.second - weapon.cooldown.first, exSystem.cooldown.first)
		exSystem.cooldown.first = exSystem.cooldown.first - chargeCount
		weapon.cooldown.first = weapon.cooldown.first + chargeCount
		if weapon.cooldown.first == weapon.cooldown.second then	
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

local function Repel_active_cost(exSystem, threshold, reduction)
	local cooldownCost = (threshold * reduction) * (exSystem.cooldown.second / exSystem.baseCooldown)
	exSystem.cooldown.first = exSystem.cooldown.first - cooldownCost 
	exSystem.boostLevel = exSystem.boostLevel - reduction
end

local function Repel_func(damage, exSystem, threshold, bRepelSysDam)
	local totalSystemDamage = damage.iDamage + damage.iSystemDamage
	local totalPersDamage = damage.iDamage + damage.iPersDamage
	local playSound = false

	--[[ reduce hull damage ]]--
	local hullDamageReduction = 0
	if damage.iDamage > 0 then
		if (damage.iDamage > exSystem.boostLevel) then
			hullDamageReduction = exSystem.boostLevel
		else
			hullDamageReduction = damage.iDamage
		end
		damage.iDamage = damage.iDamage - hullDamageReduction
		playSound = true
		Repel_active_cost(exSystem, threshold, hullDamageReduction)
	end

	--[[ prevent sysDam decreasing below 0 ]]--
	if (totalSystemDamage > 0) then
		if (hullDamageReduction > totalSystemDamage) then
			damage.iSystemDamage = 0
		end
	else
		damage.iSystemDamage = damage.iSystemDamage + hullDamageReduction
	end

	--[[ prevent persDam decreasing below 0 ]]--
	if (totalPersDamage > 0) then 
		if (hullDamageReduction > totalPersDamage) then
			damage.iPersDamage = 0
		end
	else
		damage.iPersDamage = damage.iPersDamage + hullDamageReduction
	end

	--[[ reduce system damage ]]--
	if (bRepelSysDam) then
		totalSystemDamage = totalSystemDamage - hullDamageReduction
		local systemDamageReduction = 0
		if totalSystemDamage > 0 then
			if (totalSystemDamage > exSystem.boostLevel) then
				systemDamageReduction = exSystem.boostLevel
			else
				systemDamageReduction = totalSystemDamage
			end
			damage.iSystemDamage = damage.iSystemDamage - systemDamageReduction
			playSound = true
			Repel_active_cost(exSystem, threshold, systemDamageReduction)
		end
	end

	if playSound then
		Hyperspace.Global.GetInstance():GetSoundControl():PlaySoundMix("tne_sound_repulsion",-1,false)
	end
end

local function Recharger_ready (exSystem, threshold, maximumCharge)
	local active = threshold / exSystem.baseCooldown
	local charge = exSystem.cooldown.first / exSystem.cooldown.second
	if (active <= charge) then
		exSystem.boostLevel = maximumCharge
	else
		exSystem.boostLevel = 0
	end
end

local function Repel_ready (exSystem, threshold, maximumCharge)
	local charge = exSystem.cooldown.first / exSystem.cooldown.second
	exSystem.boostLevel = math.floor(charge * maximumCharge)
end

-- Used for EX System supporting weapon
local exSystemWeaponTable = { }
exSystemWeaponTable["TNE_EX_RECHARGER_MINOR"] = { exe = Recharger_func }
exSystemWeaponTable["TNE_EX_RECHARGER_1"] = { exe = Recharger_func }
exSystemWeaponTable["TNE_EX_RECHARGER_2"] = { exe = Recharger_func }

-- Used for EX System block weapon
local exSystemBlockTable = { }
exSystemBlockTable["TNE_EX_REPEL_MINOR"] = { exe = Repel_func }
exSystemBlockTable["TNE_EX_REPEL_1"] = { exe = Repel_func }
exSystemBlockTable["TNE_EX_REPEL_2"] = { exe = Repel_func }
exSystemBlockTable["TNE_EX_REPEL_OVER"] = { exe = Repel_func }

-- Used for EX System ready
local exSystemReadyTable = { }
exSystemReadyTable["TNE_EX_RECHARGER_MINOR"] = { threshold = 3, maxCharge = 1, ready = Recharger_ready }
exSystemReadyTable["TNE_EX_RECHARGER_1"] = { threshold = 6, maxCharge = 1, ready = Recharger_ready }
exSystemReadyTable["TNE_EX_RECHARGER_2"] = { threshold = 8, maxCharge = 1, ready = Recharger_ready }

exSystemReadyTable["TNE_EX_REPEL_MINOR"] = { threshold = 10, maxCharge = 1, ready = Repel_ready }
exSystemReadyTable["TNE_EX_REPEL_1"] = { threshold = 20, maxCharge = 3, ready = Repel_ready }
exSystemReadyTable["TNE_EX_REPEL_2"] = { threshold = 20, maxCharge = 5, ready = Repel_ready }
exSystemReadyTable["TNE_EX_REPEL_OVER"] = { threshold = 20, maxCharge = 5, ready = Repel_ready }

local exTele= "TNE_EX_TELEPORTER"

local function is_Ex_Ready(exSys)
	return exSys.cooldown.first >= exSystemReadyTable[exSys.blueprint.name].threshold * (exSys.cooldown.second / exSys.baseCooldown) and exSys.powered
end

local function BlockSystemCheck(weapons, damage, ship, room)
	for w in vter(weapons) do
		if exSystemBlockTable[w.blueprint.name] then
			if is_Ex_Ready(w) then
				local repelSysDam = false
				if (room ~= -1) then
					local systemInRoom = ship:GetSystemInRoom(room)
					if (systemInRoom) then
						repelSysDam = true
						end
					end
				local activeCost = exSystemReadyTable[w.blueprint.name].threshold
				exSystemBlockTable[w.blueprint.name].exe(damage, w, activeCost, repelSysDam)
			end
		end
	end
end

local function GetRoomFromLocation(shipId, location)
	return Hyperspace.ShipGraph.GetShipInfo(shipId):GetSelectedRoom(location.x,location.y,true)
end

-------------------------------- Ex Systems Function -----------------------------------------------

-- RECHARGER
script.on_internal_event(Defines.InternalEvents.PROJECTILE_FIRE, function(projectile, weapon)
	if weapon.isArtillery then
		return
	end
	local weapons = nil 
	if projectile.ownerId == 0 then
		pcall(function() weapons = Hyperspace.ships.player.weaponSystem.weapons end)
	else
		pcall(function() weapons = Hyperspace.ships.enemy.weaponSystem.weapons end)
	end
	if weapons then
		for w in vter(weapons) do
			if exSystemWeaponTable[w.blueprint.name] then
				if is_Ex_Ready(w) then
					if exSystemWeaponTable[w.blueprint.name].exe(weapon, w) then
						break
					end
				end
			end
		end
	end
	return Defines.Chain.CONTINUE
end)

-- REPELSION
script.on_internal_event(Defines.InternalEvents.DAMAGE_AREA, function(ship, projectile, location, damage, forceHit, shipFriendlyFire)
	if (ship.weaponSystem == nil) then return end
	local weapons = ship.weaponSystem.weapons
	if (weapons == nil) then return end
	if (projectile == nil) then return end

	local dodge = ship:GetDodged()
	local damageType = projectile:GetType()

	if (damageType == 6) then
		return Defines.Chain.CONTINUE, forceHit, shipFriendlyFire
	end

	if (damageType) then
		if (dodge) and (damageType ~= 4) then
			forceHit = Defines.Evasion.MISS
		else
			forceHit = Defines.Evasion.HIT
			if weapons then
				BlockSystemCheck(weapons, damage, ship, GetRoomFromLocation(ship.iShipId, location))
			end
		end
	end

	return Defines.Chain.CONTINUE, forceHit, shipFriendlyFire
end)

-- REPULSION (ASB)
script.on_internal_event(Defines.InternalEvents.DAMAGE_AREA_HIT, function(ship, projectile, location, damage, shipFriendlyFire)
	if (ship.weaponSystem == nil) then return end
	local weapons = ship.weaponSystem.weapons
	if (weapons == nil) then return end
	if (projectile == nil) then return end

	local damageType = projectile:GetType()
	local playSound = false
	if (damageType ~= 6) then return Defines.Chain.CONTINUE end

	for w in vter(weapons) do
		if exSystemBlockTable[w.blueprint.name] then
			if is_Ex_Ready(w) then
				if (damage.iDamage > 0) then
					local activeCost = exSystemReadyTable[w.blueprint.name].threshold
					local reduction = 0	
					if (damage.iDamage > w.boostLevel) then
						reduction = w.boostLevel
					else
						reduction = damage.iDamage
					end
					local restore = Hyperspace.Damage()
					restore.iDamage = -reduction
					ship:DamageArea(location, restore, true)
					Repel_active_cost(w, activeCost, reduction)
					playSound = true
					damage.iDamage = damage.iDamage - reduction
				end
			end
		end
	end

	if (playSound) then
		Hyperspace.Global.GetInstance():GetSoundControl():PlaySoundMix("tne_sound_repulsion",-1,false)
	end

	return Defines.Chain.CONTINUE
end)

script.on_internal_event(Defines.InternalEvents.DAMAGE_SYSTEM, function(ship, projectile, roomId, damage)
	if (ship.weaponSystem == nil) then return end
	local weapons = ship.weaponSystem.weapons
	if (weapons == nil) then return end

	if (projectile == nil) then return end
	local damageType = projectile:GetType()

	if (damageType == 6) then
		return Defines.Chain.CONTINUE
	end

	if weapons then
		BlockSystemCheck(weapons, damage, ship, roomId)
	end
	return Defines.Chain.CONTINUE
end)

script.on_internal_event(Defines.InternalEvents.DAMAGE_BEAM, function(ship, projectile, location, damage, newTile, beamHit)
	if (ship.weaponSystem == nil) then return end
	local weapons = ship.weaponSystem.weapons
	if weapons then
		local room = Hyperspace.ShipGraph.GetShipInfo(ship.iShipId):GetSelectedRoom(location.x,location.y,true)
		if (room ~= -1) then
			if beamHit == Defines.BeamHit.NEW_ROOM then
			BlockSystemCheck(weapons, damage, ship, GetRoomFromLocation(ship.iShipId, location))
			end
		end
	end
	return Defines.Chain.CONTINUE, beamHit
end)

-- TELEPORT
script.on_internal_event(Defines.InternalEvents.DAMAGE_AREA_HIT, function(ship, projectile, location, damage, shipFriendlyFire)

	if (projectile == nil) then return end
	if (Hyperspace.Get_Projectile_Extend(projectile).name ~= exTele ) then return end
	
	local playerShip = Hyperspace.ships.player
	local weaponSysId = playerShip:GetSystemRoom(3)
	local targetRoomId = Hyperspace.ShipGraph.GetShipInfo(ship.iShipId):GetSelectedRoom(location.x,location.y,true)
	
	local returnCrew = (weaponSysId == targetRoomId) and (ship.iShipId == 0)
	local playSound = false

	if (returnCrew) then
		local crews = Hyperspace.ships.enemy.vCrewList
		for c in vter(crews) do
			local extend = Hyperspace.Get_CrewMember_Extend(c)
			local canTeleport = (c.iShipId == 0 and c.bMindControlled == false) or (c.iShipId ~= 0 and c.bMindControlled)
			local isCrew = c:IsCrew()
			local canCrewTeleport = c:CanTeleport()
			if canTeleport and isCrew and canCrewTeleport then
				extend:InitiateTeleport(ship.iShipId, targetRoomId, 0)
				playSound = true
			end
		end
	else
		local crews = playerShip.vCrewList
		for c in vter(crews) do
			local extend = Hyperspace.Get_CrewMember_Extend(c)

			local isInWeaponSys = c:InsideRoom(weaponSysId)

			local canTeleport = (c.iShipId == 0 and c.bMindControlled == false) or (c.iShipId ~= 0 and c.bMindControlled)
			canTeleport = canTeleport and c:CanTeleport()

			local isCrew = c:IsCrew()
			if (isInWeaponSys) and (c.bActiveManning == false) and canTeleport and isCrew then
				extend:InitiateTeleport(ship.iShipId, targetRoomId, 0)
				playSound = true
			end
		end
	end

	if (playSound) then
		Hyperspace.Global.GetInstance():GetSoundControl():PlaySoundMix("teleport",-1,false)
	end
	return Defines.Chain.CONTINUE
end)

-- CHARGE LEVEL
script.on_internal_event(Defines.InternalEvents.ON_TICK, function()
	local weapons = {}
	pcall(function() weapons[0] = Hyperspace.ships.player.weaponSystem.weapons end)
	pcall(function() weapons[1] = Hyperspace.ships.enemy.weaponSystem.weapons end)
	for i = 0, 1, 1 do
		if weapons[i] then
			for w in vter(weapons[i]) do
				if exSystemReadyTable[w.blueprint.name] then
					if w.chargeLevel ~= 0 then
						w.chargeLevel = 0
						w.cooldown.first = w.cooldown.second
					end	
					local maxC = exSystemReadyTable[w.blueprint.name].maxCharge
					local thres = exSystemReadyTable[w.blueprint.name].threshold
					exSystemReadyTable[w.blueprint.name].ready(w, thres, maxC)
				end
			end
		end
	end
end)