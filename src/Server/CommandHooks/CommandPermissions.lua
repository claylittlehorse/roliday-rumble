local restrictedGroups = {
	DefaultAdmin = true,
	DefaultUtls = true,
	DefaultDebug = true,
}

return function(registry)
	registry:RegisterHook("BeforeRun", function(context)
		local isTestPlayer = context.Executor.UserId < 0
		if isTestPlayer then
			return
		end

		local isntAdmin = context.Executor:GetRankInGroup(4590888) < 254
		if restrictedGroups[context.Group] and isntAdmin then
			return "You don't have permission to run this command"
		end
	end)
end
