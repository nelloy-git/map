local W3X = require ('map.file.w3x')

-- TODO: Remove this table upon release of 1.32.
local import_bytes = {
	[28] = 21,
	[31] = 29
}

return function (state)
	local map = state.settings.map
	local environment = state.environment
	local imports = environment.imports
	environment.imports = nil
	local files = state.loaded_files
	local version = environment.information.version
	local options = {
		type = map.options.directory and 'directory' or 'mpq',
		import_byte = import_bytes [environment.information.format]
	}

	local input = assert (W3X.open (map.input, 'r'))
	local output = assert (W3X.open (map.output, 'w+', options))

	for name, unpacked in pairs (environment) do
		local path = files [name]

		-- Do not copy loaded files, as we pack their data instead.
		imports [path] = nil

		local library = require ('map.file.' .. path)
		local packed = assert (library.pack (unpacked, version))
		local file = output:open (path, 'wb', #packed)
		file:write (packed)
		file:close ()
	end

	if state.settings.script then
		imports ['war3map.lua'] = state.settings.script.output
	end

	for name, path in pairs (imports) do
		if type (name) == 'string' and not name:find ('^%(.*%)$') then
			local source

			if path == true then
				source = assert (input:open (name, 'rb'))
			else
				source = assert (io.open (path, 'rb'))
			end

			local size = source:seek ('end')
			local destination = assert (output:open (name, 'wb', size))
			source:seek ('set')

			repeat
				local bytes = source:read (512)
			until not bytes or not destination:write (bytes)

			assert (source:close ())
			assert (destination:close ())
		end
	end

	assert (input:close ())
	assert (output:close (true))
	io.stdout:write ('Output: ', map.output, '\n')

	return true
end
