local main = require(script.Parent.Parent.Main)
local settings = main.Settings

local LoadedPlayers = {}

local module = {}

repeat
	wait()
until main.Modules

module.PlayerAdded = function(player)
	local isBanned = module.HandleBan(player)
	if isBanned == true then
		return
	end

	if player.Name == "Player1" and main.Settings.PlaytestUser ~= "" then
		local userid = main.GetUserIDFromName(main.Settings.PlaytestUser)

		player.Character:LoadAppearance(userid, true)

		player.Respawned:Connect(function()
			player.Character:LoadAppearance(userid, true)
		end)
	else
		if main.Settings.ResetSizeOnSpawn then
			player.Respawned:Connect(function()
				player.Size = Vector3.New(1, 1, 1)
			end)
		end
	end

	local timeout = 0
	repeat
		wait()
		timeout += 1
	until not player or timeout >= 10000 or LoadedPlayers[player.UserID]

	if timeout >= 10000 or not player then
		return
	end

	player.Chatted:Connect(function(msg)
		main.GetModule("Parser").Parse(player, msg)
	end)

	local data = NetMessage.New()
	data:AddString("Function", "InitGUI")
	data:AddInstance("Instance1", main.GUI)
	main.Modules.Client.ClientNetwork:InvokeClient(data, player)

	local ranks = Datastore:GetDatastore("SaltRanks")
	local savedRank = ranks:GetAsync(tostring(player.UserID))
	ranks:Disconnect()

	local foundRank
	for _, r in pairs(main.Settings.Ranks) do
		local plrs = r[3]
		if plrs then
			for _, p in pairs(plrs) do
				if type(p) == "string" and player.Name == p then
					foundRank = r[1]
				elseif type(p) == "number" and player.UserID == p then
					foundRank = r[2]
				end
			end
		end
	end

	if main.Outdated and player.IsCreator then
		main.Notification(
			player,
			main.Format(
				"Salt Admin is outdated! (This version: %s | New version: %s) [Only shown to creator]",
				main.Version,
				main.Outdated
			),
			"Info"
		)
	end

	if
		(not main.Settings.RankAllTesting and not world.IsLocalTest or main.Settings.RankAllTesting and true)
		and player.IsCreator
	then
		print("creator")
		module.GiveRank(player, 5, "Welcome")
	elseif savedRank then
		module.GiveRank(player, savedRank, "Welcome")
	elseif foundRank then
		module.GiveRank(player, foundRank, "Welcome")
	elseif main.Settings.FreeAdmin then
		local rank = main.GetRankNumber(main.Settings.FreeAdmin)

		if rank then
			module.GiveRank(player, main.GetRankNumber(main.Settings.FreeAdmin), "Welcome")
		end
	end

	if main.Settings.Gamepasses then
		local highestGamepassRank = 0
		for id, rank in pairs(main.Settings.Gamepasses) do
			local rankNumber = main.GetRankNumber(rank)
			if not rankNumber then
				warn("Gamepass rank invalid: " .. tostring(rank))
				return
			end

			local owns = pcall(function()
				return Purchases:OwnsItemAsync(player, tonumber(id))
			end)

			if owns and rankNumber > highestGamepassRank then
				highestGamepassRank = rankNumber
			end
		end

		if highestGamepassRank > module.GetRank(player) then
			module.GiveRank(player, highestGamepassRank, "Award")
		end
	end

	main.RefreshRanks()
end

module.HandleBan = function(plr, reason, time)
	if main.ServerBanned[plr.UserID] then
		plr:Kick("You have been banned from this server. Reason: " .. main.ServerBanned[plr.UserID])
		return true
	end

	local bans = Datastore:GetDatastore("SaltBans")
	local uid = tostring(plr.UserID)
	local reason = reason or bans:GetAsync(uid .. "Reason" .. main.BanDSTesting)
	local time = time or bans:GetAsync(uid .. "Time" .. main.BanDSTesting)

	print("Handling ban")

	if reason then
		print("Ban found")
		if time then
			print("time found")
			local remaining = time - os.time()
			local days = math.floor(remaining / 86400)
			remaining = remaining % 86400
			local hours = math.floor(remaining / 3600)
			remaining = remaining % 3600
			local minutes = math.floor(remaining / 60)
			local seconds = math.floor(remaining % 60)

			if os.time() < time then
				plr:Kick(
					string.format(
						"You have been temporarily banned. Your ban expires in %s days %s hours %s minutes %s seconds. Reason: %s",
						tostring(days),
						tostring(hours),
						tostring(minutes),
						tostring(seconds),
						reason
					)
				)
				return true
			end
		else
			print("Time not found, its a perm ban")
			plr:Kick(string.format("You have been permanently banned. Reason: %s", reason))
			return true
		end
	end
	return false
end

main.Modules.Client.ClientNetwork.InvokedServer:Connect(function(p, data)
	local func = data:GetString("Function")
	local str1 = data:GetString("String1")
	local num1 = data:GetNumber("Number1")

	if func == "Init" then
		LoadedPlayers[p.UserID] = true
	elseif func == "CmdBar" then
		main.GetModule("Parser").Parse(p, str1)
	elseif func == "LoadLogs" then
		local logs, count = main.RefreshLogs(num1)

		local data = NetMessage.New()
		data:AddString("Function", "OpenLogs")
		data:AddNumber("Number1", count)

		for i = 1, #logs do
			data:AddString("Log" .. i, logs[i])
		end

		main.Modules.Client.ClientNetwork:InvokeClient(data, p)
	end
end)

module.GiveRank = function(player, rank, handle)
	if module.GetRank(player) == rank then
		return
	end
	if not player:FindChild("Rank") then
		local rankVal = Instance.New("NumberValue")
		rankVal.Name = "Rank"
		rankVal.Value = rank
		rankVal.Parent = player
	else
		player.Rank.Value = rank
	end

	if handle == "Welcome" and main.Settings.WelcomeRankNotice then
		main.Notification(
			player,
			main.Format("Your rank is '%s'! Click to view the commands.", main.GetRankName(rank)),
			"Info",
			"OpenCommands",
			20
		)
	elseif handle == "Award" then
		main.Notification(
			player,
			main.Format(
				"You've unlocked the rank '%s'! Click to view the commands.",
				main.GetRankName(highestGamepassRank)
			),
			"Info",
			"OpenCommands",
			20
		)
	end

	if main.Settings.Cmdbar then
		local data = NetMessage.New()
		data:AddString("Function", "CanCmdBar")
		data:AddBool("Bool1", rank >= main.Settings.Cmdbar)
		data:AddBool("Bool2", rank >= main.Settings.Cmdbar2)
		main.Modules.Client.ClientNetwork:InvokeClient(data, player)
	end
end

module.GetPlayer = function(name)
	name = string.lower(name)
	for _, plr in pairs(Players:GetPlayers()) do
		local plrName = string.lower(plr.Name)
		if string.sub(plrName, 1, #name) == name then
			return plr
		end
	end
	warn("Could not find player " .. tostring(name))
	return nil
end

module.GetRank = function(p)
	if p:FindChild("Rank") then
		return p.Rank.Value
	else
		return 0
	end
end

module.GetGlobalRank = function(userid)
	local ranks = Datastore:GetDatastore("SaltRanks")
	local savedRank = ranks:GetAsync(tostring(userid)) or 0
	ranks:Disconnect()

	return savedRank
end

return module
