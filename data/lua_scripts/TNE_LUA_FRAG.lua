local weaponTable = { }
weaponTable["TNE_GRENADE_1"] = { subMunitions = 3, extraProj = "TNE_GRENADE_SUB" }
weaponTable["TNE_GRENADE_2"] = { subMunitions = 5, extraProj = "TNE_GRENADE_SUB" }
weaponTable["TNE_GRENADE_FIRE"] = { subMunitions = 3, extraProj = "TNE_GRENADE_SUB_FIRE" }
weaponTable["TNE_GRENADE_HULL"] = { subMunitions = 3, extraProj = "TNE_GRENADE_SUB_HULL" }
weaponTable["TNE_GRENADE_3"] = { subMunitions = 6, extraProj = "TNE_GRENADE_SUB" }

script.on_internal_event(Defines.InternalEvents.DAMAGE_AREA_HIT, function(ship, projectile, location, damage, shipFriendlyFire)
	local weaponData = nil
    local weaponName = Hyperspace.Get_Projectile_Extend(projectile).name
	pcall(function() weaponData = weaponTable[weaponName] end)

	if (weaponData == nil) then return end

    local spaceManager = Hyperspace.Global.GetInstance():GetCApp().world.space
    local cs = projectile.currentSpace

    local radius = Hyperspace.Global.GetInstance():GetBlueprints():GetWeaponBlueprint(weaponName).radius
    local extraProjBlueprint = Hyperspace.Global.GetInstance():GetBlueprints():GetWeaponBlueprint(weaponTable[weaponName].extraProj)

    for i = 0, (weaponData.subMunitions - 1) do

        local distFromCenter = math.random(0, radius)
        local direction = (math.random() + i) * 2 / weaponData.subMunitions
        direction = direction * math.pi

        local targetX = projectile.target.x + math.cos(direction) * distFromCenter
        local targetY = projectile.target.y + math.sin(direction) * distFromCenter
        local targetPoint = Hyperspace.Pointf(targetX,targetY)
        local subMunition = spaceManager:CreateLaserBlast(extraProjBlueprint, location, cs, projectile.ownerId,
            targetPoint, cs, projectile.heading)
        subMunition.bBroadcastTarget = true
    end
end) 