return function (state)
	if state.settings.map then
		state.settings.map.options = state.settings.map.options or {}
	end

	if state.settings.build then
		state.settings.build.package = state.settings.build.package or {}
		state.settings.build.options = state.settings.build.options or {}
	end

	if state.settings.script then
		state.settings.script.package = state.settings.script.package or {}
		state.settings.script.options = state.settings.script.options or {}
	end

	return true
end