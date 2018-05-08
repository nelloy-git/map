local Jass = require ('map.file.jass')

local function replace (input, replacement)
	for key, value in pairs (input) do
		if type (value) == 'table' then
			replace (value, replacement)
		elseif type (value) == 'string' then
			input [key] = value:gsub ('TRIGSTR_(%d+)', replacement)
		end
	end
end

local function replace_jass (input, replacement)
	for key, value in pairs (input, replacement) do
		if type (value) == 'table' then
			replace_jass (value, replacement)
		elseif type (value) == 'string' then
			local text = Jass.strip_comment (value)
			input [key] = text:gsub ('TRIGSTR_(%d+)', replacement)
				.. value:sub (#text + 1)
		end
	end
end

return function (state)
	local function replacement (index)
		return state.strings [tonumber (index)]
	end

	replace (state.environment.information, replacement)
	replace (state.environment.objects, replacement)
	replace (state.environment.constants, replacement)
	replace_jass (state.jass, replacement)

	-- If we are inlining all strings, then we have no use for them after
	-- this point.
	state.strings = {}

	return true
end