local hybridBeams = { }
hybridBeams["TNE_BEAM_HYBRID"] = { blueprint = "TNE_BEAM_HYBRID_EXTRA", sound = "focus_weak" }

script.on_internal_event(Defines.InternalEvents.PROJECTILE_FIRE, function(projectile, weapon)
	local weaponName = weapon.blueprint.name
	local weaponData = hybridBeams[weaponName]
	if (weaponData == nil) then return end

	local extraPinpointBlueprint = Hyperspace.Global.GetInstance():GetBlueprints():GetWeaponBlueprint(hybridBeams[weaponName].blueprint)

	local position = projectile.position
	local space = projectile.currentSpace
	local ownerId = projectile.ownerId
	local target1 = projectile.target1
	local target2 = projectile.target2
	local targetSpace = (space + 1) % 2
	local heading = projectile.heading

	local spaceManager = Hyperspace.Global.GetInstance():GetCApp().world.space
	local newBeam = spaceManager:CreateBeam(extraPinpointBlueprint, position, space, ownerId,
		target1, target2, targetSpace, 1, heading)
	newBeam.sub_start = projectile.sub_start
	Hyperspace.Global.GetInstance():GetSoundControl():PlaySoundMix(hybridBeams[weaponName].sound, -1, false)
end)