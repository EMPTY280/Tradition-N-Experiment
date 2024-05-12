local vter = mods.TNE.vter

local RepulsorWeapons = { }
RepulsorWeapons["TNE_EX_REPEL_MINOR"] = { threshold = 10, maxCharge = 1}
RepulsorWeapons["TNE_EX_REPEL_1"] = { threshold = 20, maxCharge = 3 }
RepulsorWeapons["TNE_EX_REPEL_2"] = { threshold = 20, maxCharge = 5}
RepulsorWeapons["TNE_EX_REPEL_OVER"] = { threshold = 20, maxCharge = 5 }

local hullRepairBuffer = 0

local function IsReady(exSys)
	local actTheshold = RepulsorWeapons[exSys.blueprint.name].threshold * (exSys.cooldown.second / exSys.baseCooldown)
	return exSys.cooldown.first >= actTheshold and exSys.powered
end

local function ActivationCost(exSystem, threshold, reduction)
	local cooldownCost = (threshold * reduction) * (exSystem.cooldown.second / exSystem.baseCooldown)
	exSystem.cooldown.first = exSystem.cooldown.first - cooldownCost 
	exSystem.boostLevel = exSystem.boostLevel - reduction
end

local function GetRoomFromLocation(shipId, location)
	return Hyperspace.ShipGraph.GetShipInfo(shipId):GetSelectedRoom(location.x,location.y,true)
end

local function CalculateReduction(damageAmount, exSys)
	if (damageAmount > exSys.boostLevel) then
		return exSys.boostLevel
	else
		return damageAmount
	end
end

local function RepelDamage(damage, exSystem, threshold, shipManager, roomId)
	local totalSystemDamage = damage.iDamage + damage.iSystemDamage
	local totalPersDamage = damage.iDamage + damage.iPersDamage
	local systemIdx = shipManager:GetSystemInRoom(roomId)

	local hullReduction = 0
	local sysReduction = 0

	--[[ Hull damage ]]--
	if (damage.iDamage > 0) then
		-- if hullBuster
		if (systemIdx == nil) and (damage.bHullBuster) then
			damage.bHullBuster = false
			damage.iDamage = damage.iDamage * 2
		end
		hullReduction = CalculateReduction(damage.iDamage, exSystem)
		damage.iDamage = damage.iDamage - hullReduction
		hullRepairBuffer = hullRepairBuffer + hullReduction
		ActivationCost(exSystem, threshold, hullReduction)
	end

	--[[ prevent sysDam decreasing below 0 ]]--
	if (totalSystemDamage > 0) then
		if (hullReduction > totalSystemDamage) then
			damage.iSystemDamage = 0
		end
	else
		damage.iSystemDamage = damage.iSystemDamage + hullReduction
	end

	--[[ System damage ]]--
	if (systemIdx) and (damage.iSystemDamage > 0) then
		sysReduction = CalculateReduction(damage.iSystemDamage, exSystem)
		damage.iSystemDamage = damage.iSystemDamage - sysReduction
		ActivationCost(exSystem, threshold, sysReduction)
	end

	--[[ prevent persDam decreasing below 0 ]]--
	if (totalPersDamage > 0) then 
		if (hullReduction > totalPersDamage) then
			damage.iPersDamage = 0
		end
	else
		damage.iPersDamage = damage.iPersDamage + hullReduction
	end

	--[[ should play repulsion sound? ]]--
	if (hullReduction > 0) or (sysReduction > 0) then
		return true
	end
	return false
end

script.on_internal_event(Defines.InternalEvents.DAMAGE_SYSTEM, function(shipManager, projectile, roomId, damage)
	if (shipManager.weaponSystem == nil) then return end
	local weapons = shipManager.weaponSystem.weapons
	if (weapons == nil) then return end
	if (projectile == nil) then return end

	local playSound = false

	for w in vter(weapons) do
		if RepulsorWeapons[w.blueprint.name] then
			if IsReady(w) then
				local activationCost = RepulsorWeapons[w.blueprint.name].threshold
				if (RepelDamage(damage, w, activationCost, shipManager, roomId)) then
					playSound = true
				end
			end
		end
	end

	if (playSound) then
		Hyperspace.Global.GetInstance():GetSoundControl():PlaySoundMix("tne_sound_repulsion",-1,false)
	end

	return Defines.Chain.CONTINUE
end)

script.on_internal_event(Defines.InternalEvents.DAMAGE_AREA_HIT, function(shipManager, projectile, location, damage, shipFriendlyFire)
	shipManager:DamageHull(-hullRepairBuffer, true)
	hullRepairBuffer = 0
	return Defines.Chain.CONTINUE
end)

script.on_internal_event(Defines.InternalEvents.DAMAGE_BEAM, function(shipManager, projectile, location, damage, shipFriendlyFire)
	shipManager:DamageHull(-hullRepairBuffer, true)
	hullRepairBuffer = 0
	return Defines.Chain.CONTINUE
end)