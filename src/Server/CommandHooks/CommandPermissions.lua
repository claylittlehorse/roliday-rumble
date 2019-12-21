local restrictedGroups = {
	DefaultAdmin = true,
	DefaultUtls = true,
	DefaultDebug = true,
}

return function(registry)
	registry:RegisterHook("BeforeRun", function(context)
		local restricted = true--context.Executor:GetRankInGroup(4590888) < 254

		if restrictedGroups[context.Group] and restricted then
			return "You don't have permission to run this command"
		end
	end)
end
