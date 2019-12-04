local import = require(game.ReplicatedStorage.Lib.Import)

local Rodux = import "Rodux"
local Immutable = import "Immutable"

local defaultState = {
	uiEnabled = {},
	scale = 1,
}

return Rodux.createReducer(defaultState, {
	SetLayout = function(state, action)
		local layoutType = action.layoutType

		if layoutType ~= state.layout then
			return Immutable.set(state, "layout", layoutType)
		else
			return state
		end
	end,
	SetScale = function(state, action)
		local scale = action.scale

		return Immutable.set(state, "scale", scale)
	end,
	SetLanguage = function(state, action)
		local language = action.language

		return Immutable.set(state, "language", language)
	end,
	SetUiEnabled = function(state, action)
		local uiId = action.uiId
		local enabled = action.enabled

		local uiEnabled = state.uiEnabled
		local newEnabled = Immutable.set(uiEnabled, uiId, enabled)

		return Immutable.set(state, "uiEnabled", newEnabled)
	end
})
