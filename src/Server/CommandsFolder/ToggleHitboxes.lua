local import = require(game.ReplicatedStorage.Lib.Import)

return {
	Name = "toggleHitboxes",
	Aliases = {"hitboxes"},
	Description = "Toggles damage and character hitboxes",
	Group = "Unrestricted",
	Args = {},
	ClientRun = function()
		local HitboxState = import "Client/Systems/HitboxState"
		HitboxState.visible = not HitboxState.visible
		return "Toggled hitboxes "..(HitboxState.visible and "on" or "off")
		-- print("toggled", HitboxState.visible)
	end
}
