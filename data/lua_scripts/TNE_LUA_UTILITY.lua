mods.TNE = { }

mods.TNE.vter = function(cvec)
	local i = -1
	local n = cvec:size()
	return function()
		i = i + 1
		if i < n then
			return cvec[i]
		end
 	end
end