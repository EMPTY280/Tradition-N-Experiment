
local renderboxTextTable = { }
renderboxTextTable["TNE_EX_RECHARGER_MINOR"] = 0 --"Recharger"
renderboxTextTable["TNE_EX_RECHARGER_1"] =  0
renderboxTextTable["TNE_EX_RECHARGER_2"] =  0

renderboxTextTable["TNE_EX_REPEL_MINOR"] = 1 --"Repulsor"
renderboxTextTable["TNE_EX_REPEL_1"] = 1
renderboxTextTable["TNE_EX_REPEL_2"] = 1
renderboxTextTable["TNE_EX_REPEL_OVER"] = 1

renderboxTextTable["TNE_LASER_SASHA"] = 2 --"Shots"

renderboxTextTable["TNE_LASER_FRONTIER"] = 3 --"Charged"

local RechargerText = { }
RechargerText[""] = { s1 = "Charging", s2 = "Ready" }
RechargerText["zh-Hans"] = { s1 = "충전 중", s2 = "준비됨" }

local RepulsorText = { }
RepulsorText[""] = " Reduction"
RepulsorText["zh-Hans"] = " 저항" 

local ShotsText = { }
ShotsText[""] = "Shots +"
ShotsText["zh-Hans"] = "발사체 +"

local CritText = { }
CritText[""] = "Crit-Charged"
CritText["zh-Hans"] = "치명타 충전됨"

script.on_internal_event(Defines.InternalEvents.WEAPON_RENDERBOX, function(weapon, cooldown, maxCooldown, firstLine, secondLine)

	local data = renderboxTextTable[weapon.blueprint.name]
	local language = Hyperspace.Settings.language

	if not (RechargerText[language]) then
		language = ""
	end
	if (data == 0) then
		if (weapon.boostLevel == 0) then
			secondLine = RechargerText[language].s1
		else
			secondLine = RechargerText[language].s2
		end
	elseif (data == 1) then
		secondLine = string.format("%d", weapon.boostLevel) .. RepulsorText[language]
	elseif (data == 2) then
		secondLine = ShotsText[language] .. string.format("%d", weapon.boostLevel)
	elseif (data == 3) then
		if (weapon.boostLevel == 0) then
			secondLine = ""
		else
			secondLine = CritText[language]
		end
	end

	return Defines.Chain.CONTINUE, firstLine, secondLine
end)