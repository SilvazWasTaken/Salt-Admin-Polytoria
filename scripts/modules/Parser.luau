local main = require(script.Parent.Parent.Main)
local settings = main.Settings
local serverCommands = main.GetModule("ServerCommands")

local module = {}

main.commandsExecutedDivider = 10
main.commandsExecuted = {}

spawn(function()
	while true do
		wait(60 / main.commandsExecutedDivider)
		main.commandsExecuted = {}
	end
end)

function checkPrefix(character, start)
	local incorrectPrefixes = {
		[":"] = true,
		[";"] = true,
	}
	if character == settings.Prefix or (start and incorrectPrefixes[character]) then
		return true
	else
		return false
	end
end

module.ParseArguments = function(argsTypes, args, speaker, command)
	local playerHandler = main.GetModule("PlayerHandler")
	local rank = playerHandler.GetRank(speaker)

	local playersToLoop = {}
	local multi = false

	for i, t in pairs(argsTypes) do
		if not args[i] then
			args[i] = main.GetDefaultType(t, speaker)
		end
		if t == "Player" then
			if args[i] == "me" then
				args[i] = speaker.Name
			elseif args[i] == "all" then
				for _, p in pairs(Players:GetPlayers()) do
					table.insert(playersToLoop, p)
				end
				args[i] = speaker.Name -- temp so it doesnt complain
				multi = true
			elseif args[i] == "others" then
				for _, p in pairs(Players:GetPlayers()) do
					if p ~= speaker then
						table.insert(playersToLoop, p)
					end
				end
				args[i] = speaker.Name -- temp so it doesnt complain
				multi = true
			elseif args[i] == "random" then
				local plr = Players:GetPlayers()[math.random(#Players:GetPlayers())]
				args[i] = plr.Name
			elseif not playerHandler.GetPlayer(args[i]) then
				main.Notification(speaker, main.Format("Invalid player '%s'.", args[i]), "Error")
				return nil
			end

			args[i] = playerHandler.GetPlayer(args[i])
			if rank == 1 and (args[i] ~= speaker or multi) then
				main.Notification(
					speaker,
					main.Format("%ss' can only use commands on theirself!", main.GetRankName(rank)),
					"Error"
				)
				return nil
			elseif rank == 2 and multi then
				main.Notification(
					speaker,
					main.Format("'%ss' can only use commands on one person at a time!", main.GetRankName(rank)),
					"Error"
				)
				return nil
			elseif not multi and command.RankLock and playerHandler.GetRank(args[i]) >= rank then
				main.Notification(
					speaker,
					main.Format("You do not have permission to use '%s' on %s!", command.Name, args[i].Name),
					"Error"
				)
				return nil
			end
		elseif t == "Number" then
			if not tonumber(args[i]) then
				main.Notification(speaker, main.Format("Invalid number '%s'.", args[i]), "Error")
				return nil
			end
			if string.lower(args[i]) == "nan" or string.lower(args[i]) == "-nan" then
				args[i] = "0"
			end
			args[i] = tonumber(args[i])

			if args[i] > 100000000 then
				args[i] = 100000000
			end
		elseif t == "Rank" then
			if tonumber(args[i]) then
				local nm = main.GetRankName(tonumber(args[i]))
				if not nm then
					main.Notification(speaker, main.Format("Invalid rank '%s'.", args[i]), "Error")
					return nil
				else
					args[i] = nm
				end
			elseif main.GetRankLongName(args[i]) then
				args[i] = main.GetRankLongName(args[i])
			else
				main.Notification(speaker, main.Format("Invalid rank '%s'.", args[i]), "Error")
				return nil
			end
		elseif t == "String" then
			if i == #argsTypes then
				for j = i + 1, #args do
					args[i] = args[i] .. " " .. args[j]
				end
			end
		end
	end
	return args, playersToLoop
end

module.Parse = function(speaker, originalMessage)
	local message = string.gsub(string.lower(originalMessage), "%c", "")
	local messageCap = string.gsub(originalMessage, "%c", "")

	if not checkPrefix(string.sub(message, 1, 1), true) then
		return
	end

	local batches = {}
	local batchStarts = { 1 }

	for i = 1, #message do
		local character = string.sub(message, i, i)
		if i > 2 and checkPrefix(character) then
			local batchCharacter = string.sub(message, i - 1 - 1, i - 2)
			table.insert(batchStarts, i)
		end
	end

	for i, bStart in pairs(batchStarts) do
		local bEnd = batchStarts[i + 1]
		if bEnd then
			bEnd = bEnd - 2
		else
			bEnd = #messageCap
		end
		local batch = string.sub(messageCap, bStart, bEnd)
		table.insert(batches, batch)
	end

	for batchPos, msg in pairs(batches) do
		wait()

		local args = {}
		msg:gsub("([^" .. " " .. "]+)", function(c)
			args[#args + 1] = c
		end)
		local firstArg = string.lower(args[1]) or ""
		local commandPrefix, commandName = string.sub(firstArg, 1, 1), string.sub(firstArg, 2)
		table.remove(args, 1)

		local unFunction = false
		if string.sub(commandName, 1, 2) == "un" then -- bad bad bad bad bad
			local cmd = main.GetCommand(string.sub(commandName, 3))
			if cmd and cmd.UnFunction then
				commandName = string.sub(commandName, 3)
				unFunction = true
			else
				for _, c in pairs(main.GetModule("ServerCommands")) do
					if c.Alias and table.find(c.Alias, string.sub(commandName, 3)) and c.UnFunction then
						commandName = c.Name
						unFunction = true
						break
					end
				end
			end
		end

		local fullCommand = main.GetCommand(commandName)

		if not fullCommand then
			for _, c in pairs(main.GetModule("ServerCommands")) do
				if c.Alias and table.find(c.Alias, commandName) then
					fullCommand = c
					commandName = c.Name
					break
				end
			end
		end

		if commandPrefix ~= settings.Prefix then
			if main.Settings.WarnIncorrectPrefix then
				main.Notification(
					speaker,
					main.Format("Invalid prefix! Try %s%s instead.", settings.Prefix, commandName),
					"Error"
				)
			end
			return
		elseif not main.Commands[commandName] then
			main.Notification(speaker, main.Format("'%s' is not a valid command!", commandName), "Error")
			return
		elseif
			main.commandsExecuted[speaker]
			and main.commandsExecuted[speaker] >= settings.CommandLimitPerMinute / main.commandsExecutedDivider
		then
			main.Notification(speaker, "Sending commands too fast!", "Error")
			return
		elseif main.GetModule("PlayerHandler").GetRank(speaker) < fullCommand.Rank then
			main.Notification(
				speaker,
				main.Format("You do not have permission to use '%s'!", fullCommand.Name),
				"Error"
			)
			return
		end

		main.commandsExecuted[speaker] = main.commandsExecuted[speaker] or 0
		main.commandsExecuted[speaker] = main.commandsExecuted[speaker] + 1

		local argString = ""

		for _, arg in pairs(args) do
			argString ..= " " .. arg
		end

		local log = main.Settings.Prefix .. commandName .. argString
		table.insert(main.Logs, {
			["Time"] = os.time(),
			["Command"] = string.sub(log, 1, 150),
			["Speaker"] = speaker.Name,
		})

		main.ExecuteCommand(fullCommand, speaker, args, unFunction)
	end
end

return module
