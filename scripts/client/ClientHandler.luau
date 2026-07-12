local network = script.Parent:WaitChild("ClientNetwork")
local clientGui = require(script.Parent:WaitChild("ClientGui"))
local cam = Environment.CurrentCamera
local flight = false
local pingWaiting
local cmdPrefix = ""
local muted = false
local canCmdBar, canCmdBar2 = false, false
local spin
local logsPage = 1
local logsMax = 0
local flyHelp = Instance.New("Part")
flyHelp.Color = Color.New(0, 0, 0, 0)
flyHelp.CanCollide = false

local GUI = PlayerGUI:WaitChild("GUI")

local keysPressed = {}

Input.KeyDown:Connect(function(k, focused)
	if focused then
		local keyName = string.sub(tostring(k), 13)
		keysPressed[keyName] = true

		if canCmdBar2 and keyName == "Semicolon" then
			GUI.CmdBar2.Visible = not GUI.CmdBar2.Visible
		end

		if canCmdBar and keysPressed["Apostrophe"] then
			if not GUI.CommandInput.Visible then
				GUI.CommandInput.Visible = true
				CoreUI.UseChat = false

				GUI.CommandInput.Text = cmdPrefix
			else
				GUI.CommandInput.Visible = false

				if not muted then
					CoreUI.UseChat = true
				end
			end
		end
	end
end)

Input.KeyUp:Connect(function(k, focused)
	local keyName = string.sub(tostring(k), 13)
	keysPressed[keyName] = nil
end)

function GetNextMovement()
	local move = Vector3.New(0, 0, 0)

	local forward = cam.Forward
	local right = cam.Right

	if keysPressed["W"] then
		move = move + forward
	end

	if keysPressed["S"] then
		move = move - forward
	end

	if keysPressed["A"] then
		move = move - right
	end

	if keysPressed["D"] then
		move = move + right
	end

	if keysPressed["E"] or keysPressed["Space"] then
		move = move + Vector3.New(0, 1, 0)
	end

	if keysPressed["Q"] or keysPressed["LeftShift"] then
		move = move - Vector3.New(0, 1, 0)
	end

	return move
end

Hooks.Updated:Connect(function(dt)
	if flight then
		flyHelp.Position = flyHelp.Position + GetNextMovement()
		flyHelp.Rotation = Vector3.New(-cam.Rotation.X, cam.Rotation.Y + 180, -cam.Rotation.Z)

		Players.LocalPlayer.Position = flyHelp.Position
		Players.LocalPlayer.Rotation = flyHelp.Rotation
	end

	if spin then
		local rot = Players.LocalPlayer.Rotation
		Players.LocalPlayer.Rotation = Vector3.New(rot.X, rot.Y + spin, rot.Z)
	end
end)

network.InvokedClient:Connect(function(data)
	local func = data:GetString("Function")
	local inst = data:GetInstance("Instance1")
	local str = data:GetString("String1")
	local str2 = data:GetString("String2")
	local str3 = data:GetString("String3")
	local vec3 = data:GetVector3("Vector31")
	local num1 = data:GetNumber("Number1")
	local bool1 = data:GetBool("Bool1")
	local bool2 = data:GetBool("Bool2")

	if func == "OpenGUI" then
		GUI.BG.Visible = true
	end

	if func == "OpenLogs" then
		if bool1 then
			logsPage = 1
		end

		local visualLogs = {}

		for i = 1, 20 do
			visualLogs[i] = data:GetString("Log" .. i)
		end

		local logCount = num1
		GUI.BG2.Heading.Count.Text =
			string.format("Page %s of %s (%s)", tostring(logsPage), math.ceil(logCount / 20), logCount)

		logsMax = logCount

		for _, v in pairs(GUI.BG2.Scroll.Vertical:GetChildren()) do
			v:Destroy()
		end

		for count, log in pairs(visualLogs) do
			local logui = GUI.Log:Clone()
			logui.UILabel.Text = log
			if count % 2 == 0 then
				logui.Color = Color.FromHex("#323232")
			end
			logui.Visible = true
			logui.Parent = GUI.BG2.Scroll.Vertical
		end

		GUI.BG2.Visible = true
	end

	if func == "OpenRanks" then
		GUI.BG3.Visible = true
	end

	if func == "CanCmdBar" then
		canCmdBar = bool1
		canCmdBar2 = bool2

		if not canCmdBar then
			GUI.CommandInput.Visible = false

			if not muted then
				CoreUI.UseChat = true
			end
		end

		if not canCmdBar2 then
			GUI.CmdBar2.Visible = false
		end
	end

	if func == "InitGUI" then
		GUI:WaitChild("BG"):WaitChild("Heading"):WaitChild("Close").Clicked:Connect(function()
			GUI.BG.Visible = false
		end)
		GUI:WaitChild("BG2"):WaitChild("Heading"):WaitChild("Close").Clicked:Connect(function()
			GUI.BG2.Visible = false
		end)
		GUI:WaitChild("BG2"):WaitChild("Heading"):WaitChild("ArrowLeft").Clicked:Connect(function()
			logsPage -= 1

			if logsPage < 1 then
				logsPage = 1
			end

			local data = NetMessage.New()
			data:AddString("Function", "LoadLogs")
			data:AddNumber("Number1", logsPage)
			network:InvokeServer(data)
		end)
		GUI:WaitChild("BG2"):WaitChild("Heading"):WaitChild("ArrowRight").Clicked:Connect(function()
			if logsPage + 1 > math.ceil(logsMax / 20) then
				return
			end

			logsPage += 1

			local data = NetMessage.New()
			data:AddString("Function", "LoadLogs")
			data:AddNumber("Number1", logsPage)
			network:InvokeServer(data)
		end)
		GUI:WaitChild("BG3"):WaitChild("Heading"):WaitChild("Close").Clicked:Connect(function()
			GUI.BG3.Visible = false
		end)
		GUI:WaitChild("CmdBar2"):WaitChild("Heading"):WaitChild("Close").Clicked:Connect(function()
			GUI.CmdBar2.Visible = false
		end)
		GUI:WaitChild("Alert"):WaitChild("Heading"):WaitChild("Close").Clicked:Connect(function()
			GUI.Alert.Visible = false
			GUI.Alert.Alarm:Stop()
		end)

		GUI:WaitChild("CmdBar2"):WaitChild("ExecuteButton").Clicked:Connect(function()
			local data = NetMessage.New()
			data:AddString("Function", "CmdBar")
			data:AddString("String1", GUI.CmdBar2.UITextInput.Text)
			network:InvokeServer(data)
		end)

		GUI:WaitChild("CommandInput").Submitted:Connect(function()
			local data = NetMessage.New()
			data:AddString("Function", "CmdBar")
			data:AddString("String1", GUI.CommandInput.Text)
			network:InvokeServer(data)

			GUI.CommandInput.Visible = false
			if not muted then
				CoreUI.UseChat = true
			end
		end)

		cmdPrefix = GUI.CommandInput.Text

		wait(1)
		for _, b in pairs(GUI.BG:WaitChild("Scroll"):WaitChild("Vertical"):GetChildren()) do
			if string.find(b.Name, "Command") then
				b.Click.Clicked:Connect(function()
					clientGui.CommandDetails(GUI, b)
				end)
			end
		end
	end

	if func == "PlaySFX" and inst then
		inst:Play()
	end

	if func == "StartRocket" then
		spawn(function()
			Players.LocalPlayer.Character:WaitChild("Rocket")
			while wait() do
				if Players.LocalPlayer.IsDead or not Players.LocalPlayer.Character:FindChild("Rocket") then
					break
				end
				Players.LocalPlayer.Velocity = Vector3.New(0, 80, 0)
			end
		end)
	end

	if func == "CmdBar" then
		GUI.CommandInput.Visible = true
		CoreUI.UseChat = false

		GUI.CommandInput.Text = cmdPrefix
	end

	if func == "CmdBar2" then
		GUI.CmdBar2.Visible = true
	end

	if func == "AskPing" then
		pingWaiting = os.clock()
		script.Parent:WaitChild("PingTest"):InvokeServer()
	end

	if func == "RecievePing" then
		local ping = os.clock() - pingWaiting
		ping = math.floor(ping * 1000 + 0.5) / 1000
		inst:Play()
		clientGui.CreateNotification(GUI, "Your ping is " .. ping .. "!", "Info")
	end

	if func == "DisplayMessage" then
		if num1 then
			clientGui.DisplayMessage(GUI, str, str2, num1)
		else
			clientGui.DisplayMessage(GUI, str, str2, str3)
		end
	end

	if func == "CamTarget" then
		Environment.CurrentCamera.Mode = Enums.CameraMode.Follow

		if str and str ~= Players.LocalPlayer.Name then
			Environment.CurrentCamera.Target = Players:FindChild(str)
		else
			Environment.CurrentCamera.Target = Players.LocalPlayer.CameraAttachment
		end
	end

	if func == "Spin" then
		if str == "On" then
			spin = num1
		else
			spin = nil
		end
	end

	if func == "DisplayHint" then
		if num1 then
			clientGui.DisplayHint(GUI, num1)
		else
			clientGui.DisplayHint(GUI, str)
		end
	end

	if func == "DisplayAlert" then
		clientGui.DisplayAlert(GUI, str, str2)
	end

	if func == "EasterEgg1" then
		clientGui.EasterEgg1(GUI)
	end

	if func == "FlightToggle" then
		if str == "On" then
			flight = true
			Environment.Gravity = Vector3.New(0, 0, 0)
			Players.LocalPlayer.Velocity = Vector3.New(0, 0, 0)
			flyHelp.Position = Players.LocalPlayer.Position

			Players.LocalPlayer.CanMove = false
		else
			flight = false
			Players.LocalPlayer.Rotation = Vector3.New(0, 0, 0)
			Environment.Gravity = vec3

			Players.LocalPlayer.CanMove = true
		end
	end

	if func == "Blind" then
		GUI.Blind.Visible = str == "On"
	end

	if func == "UseChat" then
		CoreUI.UseChat = str == "On"
		muted = str == "Off"
	end

	if func == "Notification" then
		clientGui.CreateNotification(GUI, str, str2, num1)
	end

	if func == "Crash" then
		while true do
		end
	end
end)

local data = NetMessage.New()
data:AddString("Function", "Init")

network:InvokeServer(data)
