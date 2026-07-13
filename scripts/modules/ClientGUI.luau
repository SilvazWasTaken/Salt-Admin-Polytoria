local module = {}
local hinting = false
local notifs = {}

module.OpenBG = function(GUI, BG)
	local wasOpen = nil

	for _, bg in pairs(GUI:GetChildren()) do
		if string.sub(bg.Name, 1, 2) == "BG" then
			if bg.Visible then
				wasOpen = bg
			end
			bg.Visible = false
		end
	end

	BG.Visible = true

	if wasOpen == BG then
		return
	end

	if not module.OGScales then
		module.OGScales = {}
	end

	if not module.OGScales[BG.Name] then
		module.OGScales[BG.Name] = Vector2.New(BG.SizeRelative.X, BG.SizeRelative.Y)
	end

	BG.SizeRelative = Vector2.New(module.OGScales[BG.Name].X, 0)

	local t = Tween.NewTween()
	t:TweenVector2(Vector2.New(module.OGScales[BG.Name].X, 0), module.OGScales[BG.Name], 0.2, function(t)
		BG.SizeRelative = t
	end)
end

module.CreateNotification = function(GUI, notif, func, time)
	local NotifTemplate = script.Parent.Parent.Storage:WaitChild("Notification"):Clone() -- ew sorry
	NotifTemplate.Content.Text = notif
	NotifTemplate.Parent = GUI:WaitChild("Notifications")

	local OGSize = NotifTemplate.SizeRelative
	NotifTemplate.SizeRelative = Vector2.New(0, 0)

	NotifTemplate:WaitChild("Heading"):WaitChild("Close").Clicked:Connect(function()
		module.CloseNotification(NotifTemplate)
	end)

	if func == "OpenCommands" then
		NotifTemplate:WaitChild("Click").Clicked:Connect(function()
			module.OpenBG(GUI, GUI.BG)
			module.CloseNotification(NotifTemplate)
		end)
	end

	local t = Tween.NewTween()
	t:TweenVector2(Vector2.New(OGSize.X, 0), OGSize, 0.25, function(t)
		NotifTemplate.SizeRelative = t
	end)

	local index = table.insert(notifs, NotifTemplate)
	if #notifs > 8 then
		module.CloseNotification(notifs[1], 1)
	end

	if time then
		for i = 1, time do
			if not NotifTemplate or not NotifTemplate.SizeRelative then
				return
			end
			NotifTemplate.Content.Text = notif .. string.format(" (%s)", time - i)
			wait(1)
		end
	else
		wait(8)
	end

	module.CloseNotification(NotifTemplate, index)
end

module.CloseNotification = function(notif, index)
	if not notif or not notif.SizeRelative then
		return
	end
	local t = Tween.NewTween()
	t:TweenVector2(notif.SizeRelative, Vector2.New(notif.SizeRelative.X, 0), 0.25, function(t)
		if notif then
			notif.SizeRelative = t
		end
	end)
	table.remove(notifs, index)
	wait(0.25)

	if notif then
		notif:Destroy()
	end
end

module.DisplayHint = function(GUI, content)
	if hinting then
		return
	end
	hinting = true

	GUI.Hint.Content.Text = tostring(content)

	local waitTime = 5

	if type(content) == "number" then
		waitTime = content

		spawn(function()
			for i = 1, content do
				wait(1)
				GUI.Hint.Content.Text = tostring(content - i)
			end
		end)
	end

	local t = Tween.NewTween()
	t:TweenNumber(0, 148, 0.4, function(a)
		GUI.Hint.Color = Color.New(0, 0, 0, a / 255)
	end)
	t:TweenNumber(0, 255, 0.4, function(a)
		GUI.Hint.Content.TextColor = Color.New(255, 255, 255, a / 255)
	end)
	wait(waitTime)

	local t = Tween.NewTween()
	t:TweenNumber(148, 0, 0.4, function(a)
		GUI.Hint.Color = Color.New(0, 0, 0, a / 255)
	end)
	t:TweenNumber(255, 0, 0.4, function(a)
		GUI.Hint.Content.TextColor = Color.New(255, 255, 255, a / 255)
	end)
	hinting = false
end

module.DisplayMessage = function(GUI, title, rank, content)
	local message = GUI.Message:Clone()
	message.Visible = true
	message.Title.Text = title
	message.Sub.Text = rank
	message.Content.Text = tostring(content)
	message.Parent = GUI

	local t = Tween.NewTween()
	t:TweenNumber(0, 148, 0.4, function(a)
		if not message or not message.Color then
			return
		end
		message.Color = Color.New(0, 0, 0, a / 255)
	end)

	wait(0.4)

	local t = Tween.NewTween()
	t:TweenNumber(0, 255, 0.4, function(a)
		if not message or not message.Title or not message.Title.TextColor then
			return
		end
		message.Title.TextColor = Color.New(255, 255, 255, a / 255)
		message.Sub.TextColor = Color.New(255, 255, 255, a / 255)
	end)
	wait(0.4)

	local t = Tween.NewTween()
	t:TweenNumber(0, 255, 0.4, function(a)
		if not message or not message.Content or not message.Content.TextColor then
			return
		end
		message.Content.TextColor = Color.New(255, 255, 255, a / 255)
	end)

	local waitTime = 5

	if type(content) == "number" then
		waitTime = content

		spawn(function()
			for i = 1, content do
				wait(1)
				message.Content.Text = tostring(content - i)
			end
		end)
	end

	wait(waitTime)

	local t = Tween.NewTween()
	t:TweenNumber(255, 0, 0.4, function(a)
		if not message or not message.Content or not message.Content.TextColor then
			return
		end
		message.Content.TextColor = Color.New(255, 255, 255, a / 255)
		message.Title.TextColor = Color.New(255, 255, 255, a / 255)
		message.Sub.TextColor = Color.New(255, 255, 255, a / 255)
	end)
	t:TweenNumber(148, 0, 0.4, function(a)
		if not message or not message.Color then
			return
		end
		message.Color = Color.New(0, 0, 0, a / 255)
	end)
	wait(0.4)
	message:Destroy()
end

module.DisplayAlert = function(GUI, title, content)
	local alert = GUI.Alert
	alert.Content.Text = content
	alert.Heading.Title.Text = title
	alert.Alarm:Play()
	alert.Visible = true
end

function AddInfo(GUI, t, cmdnm)
	local InfoView = script.Parent.Parent.Storage.InfoView:Clone() -- ewwww
	InfoView.UILabel.Text = t
	InfoView.CMDName.Value = cmdnm
	InfoView.Parent = GUI.BG.Scroll.Vertical
end

module.CommandDetails = function(GUI, command)
	local toggling = {}
	local toggle = false
	local closing = false

	for i, v in pairs(GUI.BG.Scroll.Vertical:GetChildren()) do
		if string.find(v.Name, "InfoView") then
			if v.CMDName.Value == command.CMDName.Value then
				v:Destroy()
				closing = true
			end
		end
	end

	if closing then
		return
	end

	for i, v in pairs(GUI.BG.Scroll.Vertical:GetChildren()) do
		if string.find(v.Name, "InfoView") then
			v:Destroy()
		end

		if toggle then
			v.Parent = Hidden
			table.insert(toggling, v)
		end

		if v == command then
			toggle = true
		end
	end

	if command.Alias then
		AddInfo(
			GUI,
			string.format("  [color=#969696]Alias:  [color=#afafaf]%s", command.Alias.Value),
			command.CMDName.Value
		)
	end

	if command.Description then
		AddInfo(
			GUI,
			string.format("  [color=#969696]Description:  [color=#afafaf]%s", command.Description.Value),
			command.CMDName.Value
		)
	end

	AddInfo(
		GUI,
		string.format("  [color=#969696]Rank:  [color=#afafaf]%s (%s)", command.Rank.Value, command.RankName.Value),
		command.CMDName.Value
	)

	for _, v in pairs(toggling) do
		v.Parent = GUI.BG.Scroll.Vertical
	end
end

module.EasterEgg1 = function(GUI)
	if GUI.EasterEgg1.Visible then
		return
	end
	local toHide = {
		["UseUserCard"] = true,
		["UseHealthBar"] = true,
		["UseLeaderboard"] = true,
		["UseHotbar"] = true,
		["UseBackpack"] = true,
		["UseMenuButton"] = true,
		["UseEmoteWheel"] = true,
	}
	for name, _ in pairs(toHide) do
		toHide[name] = CoreUI[name]
		CoreUI[name] = false
	end

	GUI.EasterEgg1.Stab:Play()
	GUI.EasterEgg1.Ominous.Volume = 0
	GUI.EasterEgg1.Ominous:Play()
	repeat
		wait()
	until not GUI.EasterEgg1.Stab.Loading and not GUI.EasterEgg1.Ominous.Loading

	GUI.EasterEgg1.Visible = true
	GUI.EasterEgg1.Color = Color.New(0, 0, 0, 1)

	local t = Tween.NewTween()
	--	t:TweenNumber(0, 255, 0.35, function(a)
	--		GUI.EasterEgg1.UIStab.Color = Color.New(1, 0, 0, a / 255)
	--	end)
	GUI.EasterEgg1.UIStab.Color = Color.New(1, 0, 0, 1)
	GUI.EasterEgg1.UIStab.SizeOffset = Vector2.New(0, 0)

	t:TweenNumber(0, 30, 0.1, function(a)
		GUI.EasterEgg1.UIStab.SizeOffset = Vector2.New(a, a)
	end)
	wait(2)
	local t = Tween.NewTween()
	t:TweenNumber(255, 0, 0.5, function(a)
		GUI.EasterEgg1.UIStab.Color = Color.New(1, 0, 0, a / 255)
	end)
	wait(1)
	GUI.EasterEgg1.Ominous:Play()
	GUI.EasterEgg1.Ominous.Volume = 0.8
	wait(8)
	local t = Tween.NewTween()
	t:TweenNumber(255, 0, 0.5, function(a)
		GUI.EasterEgg1.Color = Color.New(0, 0, 0, a / 255)
	end)
	wait(0.5)
	for name, _ in pairs(toHide) do
		CoreUI[name] = toHide[name]
	end
	GUI.EasterEgg1.Visible = false
end

return module
