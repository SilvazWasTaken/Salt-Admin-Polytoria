local main = {}

main.Initialize = function(s)
	print(">> Salt Admin is initializing! <<")

	main.Modules = script.Parent
	main.Settings = {}
	main.Commands = {}
	main.ServerBanned = {}
	main.Logs = {}

	main.Version = 1
	main.BanDSTesting = ""

	main.Settings = table.clone(s)
	main.Settings.Prefix = s.Prefix or ";"
	main.Settings.CommandLimitPerMinute = s.CommandLimitPerMinute or 60
	main.Settings.Cmdbar = s.Cmdbar or 1
	main.Settings.Cmdbar2 = s.Cmdbar2 or 3

	main.Knife = main.Modules.Storage.Knife:Clone()
	main.Modules.Storage.Knife:Destroy()

	for id, rank in pairs(main.Settings.Badges) do
		main.Settings.Gamepasses[id] = rank
	end

	for i, c in pairs(main.GetModule("ServerCommands")) do
		main.Commands[c.Name] = true

		if c.Name == "cmdbar" then
			c.Rank = main.Settings.Cmdbar
		elseif c.Name == "cmdbar2" then
			c.Rank = main.Settings.Cmdbar2
		end

		if c.Hidden and not main.Settings.EasterEggs then
			c.Function = function() end
		end
	end

	main.Debris = Instance.New("Folder")
	main.Debris.Name = "SaltDebris"
	main.Debris.Parent = Environment

	main.MakeGUI()

	if main.Settings.VersionCheck then
		spawn(function()
			local newVer = Http.GetAsync(
				"https://raw.githubusercontent.com/SilvazWasTaken/Salt-Admin-Polytoria/refs/heads/main/AutoDetectVERSION.json"
			)
			if newVer and string.sub(newVer, 1, 1) == "{" then
				newVer = json.parse(newVer).version
				if main.Version < newVer then
					main.Outdated = newVer
				end
			end
		end)
	end

	local Parser = main.GetModule("Parser")
	Players.PlayerAdded:Connect(main.GetModule("PlayerHandler").PlayerAdded)

	for _, p in pairs(Players:GetPlayers()) do -- Just incase, we add existing players
		main.GetModule("PlayerHandler").PlayerAdded(p)
	end

	main.Modules.Client.PingTest.InvokedServer:Connect(function(plr)
		local data = NetMessage.New()
		data:AddString("Function", "RecievePing")
		data:AddInstance("Instance1", main.Modules.Storage.Audio.Notification)
		main.Modules.Client.ClientNetwork:InvokeClient(data, plr)
	end)

	Players.PlayerRemoved:Connect(function(plr)
		local jail = Environment:FindChild(tostring(plr.UserID) .. "Jail")

		if jail then
			jail:Destroy()
		end
	end)
end

main.MakeGUI = function()
	local GUI

	if main.Modules.Storage.GUI then
		GUI = main.Modules.Storage.GUI:Clone()
	else
		GUI = PlayerGUI.GUI:Clone()
		PlayerGUI.GUI:Destroy()
	end

	local CategorizedCommands = {}
	for _, command in pairs(main.GetModule("ServerCommands")) do
		if main.Settings.SetCommandRankByName then
			local rankOverride = main.Settings.SetCommandRankByName[command.Name]
			if rankOverride then
				command.Rank = rankOverride
			end
		end

		if not CategorizedCommands[command.Rank + 1] then
			CategorizedCommands[command.Rank + 1] = {}
		end

		local cc = CategorizedCommands[command.Rank + 1]
		table.insert(cc, command)
	end

	local commandsFound = 0
	for rank, cat in ipairs(CategorizedCommands) do
		rank = rank - 1
		local category = main.Modules.Storage.Category:Clone()
		category.Text.Text = string.upper(main.GetRankName(rank)) .. " +"
		category.Parent = GUI.BG.Scroll.Vertical

		for count, command in ipairs(cat) do
			if command.Hidden then
				continue
			end
			commandsFound += 1

			local commandUI = main.Modules.Storage.Command:Clone()
			commandUI.CMDName.Value = command.Name
			commandUI.Rank.Value = tostring(command.Rank)
			commandUI.RankName.Value = main.GetRankName(command.Rank)

			if count % 2 == 0 then
				commandUI.Color = Color.FromHex("#323232")
			end

			if command.Description then
				commandUI.Description.Value = command.Description
			else
				commandUI.Description:Destroy()
			end

			if command.Alias then
				local aliasString = ""
				for i, a in pairs(command.Alias) do
					if i == #command.Alias then
						aliasString ..= a
					else
						aliasString ..= a .. ", "
					end
				end
				commandUI.Alias.Value = aliasString
			else
				commandUI.Alias:Destroy()
			end

			local argsList = ""

			if command.Args then
				local args = command.VisibleArgs or command.Args
				for _, arg in pairs(args) do
					argsList ..= "<" .. string.lower(arg) .. ">" .. " "
				end
			end

			local char = commandUI.UILabel.Text
			commandUI.UILabel.Text =
				string.format("  " .. char .. "  %s%s [color=#afafaf]" .. argsList, main.Settings.Prefix, command.Name)
			commandUI.Parent = GUI.BG.Scroll.Vertical
		end
	end

	GUI.CommandInput.Text = main.Settings.Prefix
	GUI.BG.Heading.Count.Text = commandsFound .. " Found"
	GUI.Parent = PlayerGUI

	main.GUI = GUI
end

main.RefreshRanks = function()
	local scroll = main.GUI.BG3.Scroll.Vertical
	local playerHandler = main.GetModule("PlayerHandler")

	for _, v in pairs(scroll:GetChildren()) do
		v:Destroy()
	end

	local rankPlayers = {}

	for _, p in pairs(Players:GetPlayers()) do
		local rank = playerHandler.GetRank(p)

		if rank > 0 then
			rankPlayers[rank] = rankPlayers[rank] or {}
			table.insert(rankPlayers[rank], p)
		end
	end

	local ranks = {}

	for rank in pairs(rankPlayers) do
		table.insert(ranks, rank)
	end
	table.sort(ranks)

	for _, rank in pairs(ranks) do
		local playerTable = rankPlayers[rank]

		local categoryUI = main.Modules.Storage.Category:Clone()
		categoryUI.Text.Text = main.GetRankName(rank) .. " [" .. rank .. "]"
		categoryUI.Parent = scroll

		for _, player in pairs(playerTable) do
			local playerUI = main.Modules.Storage.PlayerRank:Clone()
			playerUI.UILabel.Text = "" .. player.Name

			local image = PTImageAsset.New()
			image.ImageType = Enums.ImageType.UserAvatarHeadshot
			image.ImageID = player.UserID

			playerUI.UIImage.Image = image
			playerUI.Parent = scroll
		end
	end
end

main.RefreshBans = function()
	local scroll = main.GUI.BG4.Scroll.Vertical

	for _, obj in pairs(scroll:GetChildren()) do
		obj:Destroy()
	end

	local bans = Datastore:GetDatastore("SaltBans")
	local list = bans:GetAsync("List")

	if not list then
		bans:Disconnect()
		return
	end

	list = json.parse(list)

	local count = 0
	for userid, ban in pairs(list) do
		if ban.Time and os.time() > ban.Time then
			continue
		end -- temp ban expired

		count += 1
		local banFrame = main.Modules.Storage.PlayerBan:Clone()

		local image = PTImageAsset.New()
		image.ImageType = Enums.ImageType.UserAvatarHeadshot
		image.ImageID = tonumber(userid)

		if count % 2 == 0 then
			banFrame.Color = Color.FromHex("#323232")
		end

		if ban.Time then
			local remaining = ban.Time - os.time()
			local days = math.floor(remaining / 86400)
			remaining = remaining % 86400
			local hours = math.floor(remaining / 3600)
			remaining = remaining % 3600
			local minutes = math.floor(remaining / 60)

			banFrame.UILabel.Text = userid
				.. " - "
				.. ban.Reason
				.. " ["
				.. string.format("%sD %sH %sM", days, hours, minutes)
				.. "]"
		else
			banFrame.UILabel.Text = userid .. " - " .. ban.Reason
		end

		spawn(function()
			local plrInfo = Http.GetAsync("https://api.polytoria.com/v1/users/" .. userid)
			if plrInfo and json.parse(plrInfo) then
				plrInfo = json.parse(plrInfo)
			else
				plrInfo = {
					["username"] = userid,
				}
			end

			banFrame.UILabel.Text = plrInfo.username .. string.sub(banFrame.UILabel.Text, #userid + 1)
		end)

		banFrame.UIImage.Image = image

		banFrame.Parent = scroll
	end

	bans:Disconnect()
end

main.RefreshLogs = function(page)
	local scroll = main.GUI.BG2.Scroll.Vertical
	local logsFlipped = {}

	for i, v in pairs(scroll:GetChildren()) do
		v:Destroy()
	end

	local t = 0
	for count = #main.Logs, 1, -1 do
		t += 1
		logsFlipped[t] = main.Logs[count]
	end

	local t = main.Paginate(logsFlipped, page, 20)
	local logsVisual = {}

	for count, log in pairs(t) do
		if not log.Time then
			log.Time = os.time()
		end
		if not log.Speaker then
			log.Speaker = Players:GetPlayers()[1]
		end
		if not log.Command then
			log.Command = "Error"
		end
		pcall(function()
			logsVisual[count] = string.format("[%s] %s: %s", os.date("%H:%M", log.Time), log.Speaker, log.Command)
		end)
	end

	return logsVisual, #main.Logs

	--	for count, log in pairs(t) do
	--		local logui = main.GUI.Log:Clone()
	--		logui.UILabel.Text = string.format("[%s] %s: %s", os.date("%H:%M", log.Time), log.Speaker, log.Command)
	--		if count % 2 == 0 then
	--			logui.Color = Color.FromHex("#323232")
	--		end
	--		logui.Visible = true
	--		logui.Parent = scroll
	--
	--		print(logui.UILabel.Text)
	--	end
	--
	--	for count = #main.Logs, 1, -1 do
	--		local log = main.Logs[count]
	--		local logui = main.GUI.Log:Clone()
	--		logui.UILabel.Text = string.format("[%s] %s: %s", os.date("%H:%M", log.Time), log.Speaker, log.Command)
	--		if count % 2 == 0 then
	--			logui.Color = Color.FromHex("#323232")
	--		end
	--		logui.Visible = true
	--		logui.Parent = scroll
	--		amount += 1
	--
	--		if amount > 40 then
	--			return
	--		end
	--	end
end

main.GetModule = function(moduleName)
	for _, m in pairs(main.Modules:GetDescendants()) do
		if m.Name == moduleName and m:IsA("ModuleScript") then
			return require(m)
		end
	end
	warn("Unable to find module: " .. tostring(moduleName))
	return nil
end

main.Notification = function(player, message, type, func, time)
	if main.Settings.DisableAllNotices then
		return
	end
	if not type then
		type = "Info"
	end

	local data = NetMessage.New()
	data:AddString("Function", "PlaySFX")

	if type == "Info" then
		data:AddInstance("Instance1", main.Modules.Storage.Audio.Notification)
	end

	if type == "Error" then
		data:AddInstance("Instance1", main.Modules.Storage.Audio.Error)
	end

	if player == "all" then
		main.Modules.Client.ClientNetwork:InvokeClients(data)
	else
		main.Modules.Client.ClientNetwork:InvokeClient(data, player)
	end

	--Chat.UnicastMessage(message, player)

	local data = NetMessage.New()
	data:AddString("Function", "Notification")
	data:AddString("String1", message)

	if func then
		data:AddString("String2", func)
	end

	if time then
		data:AddNumber("Number1", time)
	end

	if player == "all" then
		main.Modules.Client.ClientNetwork:InvokeClients(data)
	else
		main.Modules.Client.ClientNetwork:InvokeClient(data, player)
	end
end

main.Format = function(message, ...)
	message = string.format(message, ...)
	return message
end

main.GetDefaultType = function(type, speaker)
	if type == "String" then
		return ""
	elseif type == "Number" then
		return 0
	elseif type == "Player" then
		return speaker.Name
	elseif type == "HexColor" then
		return "#ffffff"
	end
end

main.GetCommand = function(name)
	for _, command in pairs(main.GetModule("ServerCommands")) do
		if command.Name == name then
			return command
		end
	end
	return nil
end

main.ExecuteCommand = function(command, speaker, args, unFunction)
	local playerHandler = main.GetModule("PlayerHandler")

	if command.Args then
		local ogArgs = table.clone(args)
		args, playersToLoop = main.GetModule("Parser").ParseArguments(command.Args, args, speaker, command)

		if not args then
			return
		end

		if #playersToLoop > 0 then
			for _, p in pairs(playersToLoop) do
				local newArgs = table.clone(ogArgs)

				for i, a in pairs(newArgs) do
					if a == "all" or a == "others" or string.find(a, ",") then
						newArgs[i] = string.lower(p.Name)
					end
				end

				main.ExecuteCommand(command, speaker, table.clone(newArgs), unFunction)
			end
			return
		end
	end

	if unFunction and command.UnFunction then
		pcall(function()
			spawn(command.UnFunction, speaker, args)
		end)
	end
	if not unFunction and command.Function then
		pcall(function()
			spawn(command.Function, speaker, args)
		end)
	end
end

main.GetRankNumber = function(rank)
	for _, r in pairs(main.Settings.Ranks) do
		if r[2] == rank then
			return r[1]
		end
	end
end

main.GetRankName = function(rank)
	for _, r in pairs(main.Settings.Ranks) do
		if r[1] == rank then
			return r[2]
		end
	end
end

main.GetRankLongName = function(shortName)
	shortName = string.lower(shortName)
	for _, r in pairs(main.Settings.Ranks) do
		local rName = string.lower(r[2])
		if string.sub(rName, 1, #shortName) == shortName then
			return r[2]
		end
	end
end

main.FallbackHex = function(arg)
	if arg == "red" then
		arg = "#ff0000"
	elseif arg == "blue" then
		arg = "#0000ff"
	elseif arg == "green" then
		arg = "#00ff00"
	elseif arg == "yellow" then
		arg = "#ffff00"
	elseif arg == "purple" then
		arg = "#800080"
	elseif arg == "orange" then
		arg = "#ffa500"
	elseif arg == "pink" then
		arg = "#ffaaaa"
	elseif not Color.FromHex(arg) then
		arg = "#ffffff"
	end
	return arg
end

main.GetUserIDFromName = function(name)
	local userid = Http.GetAsync("https://api.polytoria.com/v1/users/find?username=" .. name)

	if userid then
		userid = json.parse(userid)
		userid = tonumber(userid.id)
		return userid
	end
	return nil
end

main.Paginate = function(tbl, page, pageSize)
	local totalItems = #tbl
	local totalPages = math.max(1, math.ceil(totalItems / pageSize))

	if not totalPages then
		return nil
	end

	page = math.max(1, math.min(page, totalPages))

	local startIndex = (page - 1) * pageSize + 1
	local endIndex = math.min(startIndex + pageSize - 1, totalItems)

	local items = {}
	for i = startIndex, endIndex do
		items[#items + 1] = tbl[i]
	end

	return items, totalPages
end

main.UpdateBanList = function(ds, userid, remove, reason, time)
	local list = ds:GetAsync("List")

	if not list then
		list = {}
	else
		list = json.parse(list)
		if not list then
			list = {}
		end
	end

	if not remove then
		list[tostring(userid)] = {
			Reason = reason,
			Time = time,
		}
	else
		list[tostring(userid)] = nil
	end

	local text = json.serialize(list)
	-- printing it crashes the game
	--print(tostring(text))
	--	print(text)
	ds:SetAsync("List", text)
end

return main
