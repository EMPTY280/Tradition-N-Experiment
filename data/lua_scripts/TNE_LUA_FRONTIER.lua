local vter = mods.TNE.vter
local weaponName = { }
weaponName["TNE_LASER_FRONTIER"] = { Shots = 3, damageMod = 2, pierceMod = 0, ionMod = 1 }

script.on_internal_event(Defines.InternalEvents.PROJECTILE_FIRE, function(projectile, weapon)
	local weaponData = nil
	pcall(function() weaponData = weaponName[weapon.blueprint.name] end)

	if (weaponData == nil) then return end

	local weaponBoostLevel = weapon.weaponVisual.boostLevel + 1
	local firedShots = weaponData.Shots - weapon.queuedProjectiles:size()

	if (weaponBoostLevel >= 1) then
		projectile.damage.iDamage = weaponData.damageMod
		projectile.damage.iShieldPiercing = weaponData.pierceMod
		projectile.damage.iIonDamage = weaponData.ionMod
	end

	if (firedShots >= weaponData.Shots) then
		if (weaponBoostLevel > 0) then
			Hyperspace.Global.GetInstance():GetSoundControl():PlaySoundMix("tne_sound_frontier_crit",-1,false)
		else
			Hyperspace.Global.GetInstance():GetSoundControl():PlaySoundMix("tne_sound_frontier_shot",-1,false)
		end
		weapon.boostLevel = 0
	end
end)

-- Crit Charge

local function ChargeCrit(ship)
	local weapons = ship.weaponSystem.weapons
	if (weapons == nil) then return end 
	for w in vter(weapons) do
		if (weaponName[w.blueprint.name]) then
			w.boostLevel = 1
		end
	end
end

script.on_internal_event(Defines.InternalEvents.DAMAGE_AREA_HIT, function(ship, projectile, location, damage, shipFriendlyFire)
	if (damage.iDamage < 1) then return end
	ChargeCrit(ship)
end)

script.on_internal_event(Defines.InternalEvents.DAMAGE_BEAM, function(ship, projectile, location, damage, newTile, beamHit)
	if (damage.iDamage < 1) then return end
	local room = Hyperspace.ShipGraph.GetShipInfo(ship.iShipId):GetSelectedRoom(location.x,location.y,true)
	if (room == -1) then return end
	if (beamHit ~= Defines.BeamHit.NEW_ROOM) then return end

	ChargeCrit(ship)
end)