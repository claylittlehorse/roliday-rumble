local Actions = {}

local actionScripts = script:GetDescendants()

delay(nil, function()
	for _, actionScript in pairs(actionScripts) do
		if actionScript:IsA("ModuleScript") then
			local action = require(actionScript)
			Actions[action.actionId] = action
		end
	end
end)

return Actions
