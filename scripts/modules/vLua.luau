local compile = require(script:WaitChild("Yueliang"))
local createExecutable = require(script:WaitChild("FiOne"))

return function(source, env)
	local executable
	local env = env or _G
	local name = (env.script and env.script:GetFullName())
	local ran, failureReason = pcall(function()
		local compiledBytecode = compile(source, name)
		executable = createExecutable(compiledBytecode, env)
	end)

	if ran then
		return executable
	end
	return nil, failureReason
end
