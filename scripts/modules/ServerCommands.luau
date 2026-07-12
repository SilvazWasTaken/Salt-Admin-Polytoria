local main = require(script.Parent.Parent.Main)
local playerHandler = require(main.Modules.Server.PlayerHandler)
local settings = main.Settings

-- smite
-- banland
-- gun

local connections = {}

local module = {

	-- non admin --
	{
		Name = "cmds",
		Rank = 0,
		Alias = { "commands", "help" },
		Function = function(speaker, args)
			local data = NetMessage.New()
			data:AddString("Function", "OpenGUI")
			data:AddInstance("Instance1", main.GUI)
			main.Modules.Client.ClientNetwork:InvokeClient(data, speaker)
		end,
	},

	{
		Name = "ping",
		Rank = 0,
		Function = function(speaker, args)
			local data = NetMessage.New()
			data:AddString("Function", "AskPing")
			main.Modules.Client.ClientNetwork:InvokeClient(data, speaker)
		end,
	},

	{
		Name = "ranks",
		Rank = 0,
		Alias = { "admins" },
		Args = {},
		Function = function(speaker, args)
			main.RefreshRanks()

			local data = NetMessage.New()
			data:AddString("Function", "OpenRanks")
			main.Modules.Client.ClientNetwork:InvokeClient(data, speaker)
		end,
	},

	{
		Name = "getsound",
		Rank = 0,
		Alias = { "getmusic", "getsong" },
		Function = function(speaker, args)
			local saltAudio = Environment:FindChild("SaltAudio")

			if saltAudio and saltAudio.Playing then
				main.Notification(
					speaker,
					main.Format("The ID of the sound playing is: %s", saltAudio.Audio.AudioID),
					"Info"
				)
			else
				main.Notification(
					speaker,
					main.Format(
						"No sound is currently playing!",
						main.Settings.ScaleLimit,
						main.GetRankName(main.Settings.IgnoreScaleLimit)
					),
					"Info"
				)
			end
		end,
	},

	-- vip --
	{
		Name = "cmdbar",
		Rank = 1,
		Alias = { "commandbar" },
		Args = {},
		Function = function(speaker, args)
			local data = NetMessage.New()
			data:AddString("Function", "CmdBar")
			main.Modules.Client.ClientNetwork:InvokeClient(data, speaker)
		end,
	},

	{
		Name = "refresh",
		Rank = 1,
		Alias = { "re", "respawn" },
		Args = { "Player" },
		Function = function(speaker, args)
			args[1]:Respawn()
			args[1]:ResetAppearance()
			args[1].Size = Vector3.New(1, 1, 1)
			args[1].UseNametag = true
		end,
	},

	{
		Name = "trip",
		Rank = 1,
		Args = { "Player" },
		Function = function(speaker, args)
			args[1].Character:StartRagdoll()
			wait(1)
			args[1].Character:StopRagdoll()
		end,
	},

	{
		Name = "hidename",
		Rank = 1,
		Args = { "Player" },
		Function = function(speaker, args)
			args[1].UseNametag = false
		end,
	},

	{
		Name = "showname",
		Rank = 1,
		Args = { "Player" },
		Function = function(speaker, args)
			args[1].UseNametag = true
		end,
	},

	{
		Name = "view",
		Rank = 1,
		Args = { "Player" },
		Function = function(speaker, args)
			local data = NetMessage.New()
			data:AddString("Function", "CamTarget")
			data:AddString("String1", args[1].Name)
			main.Modules.Client.ClientNetwork:InvokeClient(data, speaker)
		end,
		UnFunction = function(speaker, args)
			local data = NetMessage.New()
			data:AddString("Function", "CamTarget")
			main.Modules.Client.ClientNetwork:InvokeClient(data, speaker)
		end,
	},

	{
		Name = "invisible",
		Rank = 1,
		Alias = { "invis" },
		Args = { "Player" },
		Function = function(speaker, args)
			local character = args[1].Character
			local list = {
				["HeadColor"] = true,
				["TorsoColor"] = true,
				["LeftArmColor"] = true,
				["LeftLegColor"] = true,
				["RightArmColor"] = true,
				["RightLegColor"] = true,
			}

			for c, _ in pairs(list) do
				local cValue = Instance.New("ColorValue")
				cValue.Name = "OGCOL" .. c
				cValue.Value = character[c]
				cValue.Parent = character

				character[c] = Color.New(0, 0, 0, 0)
			end

			for i, v in pairs(speaker.Character:GetChildren()) do
				if typeof(v) == "Accessory" then
					local ogSize = v:FindChild("OgSize")
					if not ogSize then
						ogSize = Instance.New("Vector3Value")
						ogSize.Value = v.Mesh.Size
						ogSize.Name = "OgSize"
						ogSize.Parent = v
					end

					v.Mesh.Size = Vector3.New(0, 0, 0)
				end
			end
		end,
	},

	{
		Name = "visible",
		Rank = 1,
		Alias = { "vis" },
		Args = { "Player" },
		Function = function(speaker, args)
			local character = args[1].Character

			for _, v in pairs(character:GetChildren()) do
				if string.sub(v.Name, 1, 5) == "OGCOL" then
					character[string.sub(v.Name, 6)] = v.Value
					v:Destroy()
				end
				if typeof(v) == "Accessory" then
					local ogSize = v:FindChild("OgSize")

					if ogSize then
						v.Mesh.Size = ogSize.Value
					end
				end
			end
		end,
	},

	{
		Name = "jump",
		Rank = 1,
		Args = { "Player" },
		Function = function(speaker, args)
			args[1]:Jump()
		end,
	},

	{
		Name = "size",
		Rank = 1,
		Args = { "Player", "Number" },
		Function = function(speaker, args)
			local rank = playerHandler.GetRank(speaker)

			if rank < main.Settings.IgnoreScaleLimit and args[2] > main.Settings.ScaleLimit then
				main.Notification(
					speaker,
					main.Format(
						"The ScaleLimit is %s for ranks below '%s'",
						main.Settings.ScaleLimit,
						main.GetRankName(main.Settings.IgnoreScaleLimit)
					),
					"Info"
				)
				return
			end

			args[1].Size = Vector3.New(args[2], args[2], args[2])
		end,
	},

	{
		Name = "flip",
		Rank = 1,
		Alias = { "upsidedown" },
		Args = { "Player" },
		Function = function(speaker, args)
			args[1].Rotation = Vector3.New(args[1].Rotation.X, args[1].Rotation.Y, 180)
		end,
		UnFunction = function(speaker, args)
			args[1].Rotation = Vector3.New(args[1].Rotation.X, args[1].Rotation.Y, 0)
		end,
	},

	{
		Name = "spin",
		Rank = 1,
		Args = { "Player", "Number" },
		Function = function(speaker, args)
			if args[2] < 1 then
				args[2] = 1
			end

			local data = NetMessage.New()
			data:AddString("Function", "Spin")
			data:AddString("String1", "On")
			data:AddNumber("Number1", args[2])
			main.Modules.Client.ClientNetwork:InvokeClient(data, args[1])
		end,
		UnFunction = function(speaker, args)
			local data = NetMessage.New()
			data:AddString("Function", "Spin")
			data:AddString("String1", "Off")
			main.Modules.Client.ClientNetwork:InvokeClient(data, args[1])
		end,
	},

	{
		Name = "fat",
		Rank = 1,
		Alias = { "obese" },
		Args = { "Player" },
		Function = function(speaker, args)
			args[1].Size = Vector3.New(args[1].Size.X, args[1].Size.X, args[1].Size.X * 2.5)
		end,
		UnFunction = function(speaker, args)
			args[1].Size = Vector3.New(args[1].Size.X, args[1].Size.X, args[1].Size.X)
		end,
	},

	{
		Name = "thin",
		Rank = 1,
		Alias = { "skinny" },
		Args = { "Player" },
		Function = function(speaker, args)
			args[1].Size = Vector3.New(args[1].Size.X, args[1].Size.Y * 1.5, args[1].Size.X * 0.5)
		end,
		UnFunction = function(speaker, args)
			args[1].Size = Vector3.New(args[1].Size.X, args[1].Size.X, args[1].Size.X)
		end,
	},

	{
		Name = "hat",
		Rank = 1,
		Alias = { "accessory", "wear" },
		Args = { "Player", "Number" },
		Function = function(speaker, args)
			local hat = Insert:AccessoryAsync(args[2])

			if hat then
				hat.Parent = args[1].Character
				hat.Name = "SaltAdminHat"
			end
		end,
		UnFunction = function(speaker, args)
			for _, v in pairs(args[1].Character:GetChildren()) do
				if v.Name == "SaltAdminHat" then
					v:Destroy()
				end
			end
		end,
	},

	{
		Name = "clearhats",
		Rank = 1,
		Alias = { "clrhats", "clearaccessories", "clraccessories", "removehats", "removeaccessories" },
		Args = { "Player" },
		Function = function(speaker, args)
			for _, v in pairs(args[1].Character:GetChildren()) do
				if typeof(v) == "Accessory" then
					v:Destroy()
				end
			end
		end,
	},

	{
		Name = "char",
		Rank = 1,
		Alias = { "become" },
		VisibleArgs = { "Player", "FullUsername" },
		Args = { "Player", "String" },
		Function = function(speaker, args)
			local userid = main.GetUserIDFromName(args[2])

			if userid then
				args[1].Character:LoadAppearance(userid, true)
			else
				main.Notification(speaker, main.Format("Failed to find user %s.", args[2]), "Error")
			end
		end,
		UnFunction = function(speaker, args)
			args[1].Character:LoadAppearance(args[1].UserID, true)
		end,
	},

	{
		Name = "freeze",
		Rank = 1,
		Alias = { "stopmove" },
		Args = { "Player" },
		Function = function(speaker, args)
			args[1].CanMove = false
		end,
		UnFunction = function(speaker, args)
			args[1].CanMove = true
		end,
	},

	{
		Name = "jail",
		Rank = 1,
		Alias = { "jailCell", "jc" },
		Args = { "Player" },
		Function = function(speaker, args)
			local jail = Environment:FindChild(tostring(args[1].UserID) .. "Jail")
			if not jail then
				jail = main.Modules.Storage.Jail:Clone()
				jail.Name = tostring(args[1].UserID) .. "Jail"
				jail.Parent = Environment
			end
			jail.Position = args[1].Position + Vector3.New(0, 0.7, 0)

			connections[jail.Name] = args[1].Respawned:Connect(function()
				args[1].Position = jail.Position
			end)

			wait(1)
			if jail then
				args[1].Position = jail.Position
			end
		end,
		UnFunction = function(speaker, args)
			local jail = Environment:FindChild(tostring(args[1].UserID) .. "Jail")

			if jail then
				connections[jail.Name]:Disconnect()
				jail:Destroy()
			end
		end,
	},

	-- mod --
	{
		Name = "logs",
		Rank = 2,
		Alias = { "commandlogs" },
		Args = {},
		Function = function(speaker, args)
			main.RefreshLogs()

			local data = NetMessage.New()
			data:AddString("Function", "OpenLogs")
			main.Modules.Client.ClientNetwork:InvokeClient(data, speaker)
		end,
	},

	{
		Name = "speed",
		Rank = 2,
		Alias = { "ws", "walkSpeed" },
		Args = { "Player", "Number" },
		Function = function(speaker, args)
			args[1].WalkSpeed = args[2]
		end,
	},

	{
		Name = "sprint",
		Rank = 2,
		Alias = { "sp", "sprintSpeed" },
		Args = { "Player", "Number" },
		Function = function(speaker, args)
			args[1].SprintSpeed = args[2]
		end,
	},

	{
		Name = "jumppower",
		Rank = 2,
		Alias = { "jp" },
		Args = { "Player", "Number" },
		Function = function(speaker, args)
			args[1].JumpPower = args[2]
		end,
	},

	{
		Name = "kill",
		Rank = 2,
		Args = { "Player" },
		Function = function(speaker, args)
			args[1]:Kill()
		end,
	},

	{
		Name = "explode",
		Rank = 2,
		Args = { "Player" },
		Function = function(speaker, args)
			local expl = Instance.New("Explosion")
			expl.Position = args[1].Position
			expl.Parent = Environment
			args[1]:Kill()
		end,
	},

	{
		Name = "rocket",
		Rank = 2,
		Args = { "Player" },
		Function = function(speaker, args)
			local ourRocket = main.Modules.Storage.Rocket:Clone()
			ourRocket.Position = args[1].Position
			ourRocket.Rotation = args[1].Rotation
			ourRocket.Parent = args[1].Character
			ourRocket.Engine:Play()
			ourRocket.Launch:Play()
			wait(2)
			ourRocket.Launch:Play()
			ourRocket.Launch.Volume = 0.9

			local data = NetMessage.New()
			data:AddString("Function", "StartRocket")
			main.Modules.Client.ClientNetwork:InvokeClient(data, args[1])

			wait(5)

			local expl = Instance.New("Explosion")
			expl.Position = args[1].Position
			expl.Parent = Environment
			args[1]:Kill()
			flying = false
			ourRocket:Destroy()
		end,
	},

	{
		Name = "sword",
		Rank = 2,
		Alias = { "knife" },
		Args = { "Player" },
		Function = function(speaker, args)
			local sword = main.Modules.Storage.Sword
			sword:Clone().Parent = args[1].Inventory
		end,
	},

	{
		Name = "gear",
		Rank = 2,
		Args = { "Player", "Number" },
		Function = function(speaker, args)
			local item = Insert:ToolAsync(args[2])
			if item then
				item.Parent = args[1].Inventory
			end
		end,
	},

	{
		Name = "fly",
		Rank = 2,
		Alias = { "flight" },
		Args = { "Player" },
		Function = function(speaker, args)
			local data = NetMessage.New()
			data:AddString("Function", "FlightToggle")
			data:AddString("String1", "On")

			main.Modules.Client.ClientNetwork:InvokeClient(data, args[1])
		end,
		UnFunction = function(speaker, args)
			local data = NetMessage.New()
			data:AddString("Function", "FlightToggle")
			data:AddString("String1", "Off")
			data:AddVector3("Vector31", Environment.Gravity)

			main.Modules.Client.ClientNetwork:InvokeClient(data, args[1])
		end,
	},

	{
		Name = "teleport",
		Rank = 2,
		Alias = { "tp" },
		Args = { "Player", "Player" },
		Function = function(speaker, args)
			args[1].Position = args[2].Position + (args[2].Forward * 4)
			args[1].Rotation = Vector3.New(-args[2].Rotation.X, args[2].Rotation.Y + 180, -args[2].Rotation.Z)
		end,
	},

	{
		Name = "bring",
		Rank = 2,
		Alias = { "br" },
		Args = { "Player" },
		Function = function(speaker, args)
			args[1].Position = speaker.Position + (speaker.Forward * 4)
			args[1].Rotation = Vector3.New(-speaker.Rotation.X, speaker.Rotation.Y + 180, -speaker.Rotation.Z)
		end,
	},

	{
		Name = "to",
		Rank = 2,
		Args = { "Player" },
		Function = function(speaker, args)
			speaker.Position = args[1].Position + (args[1].Forward * 4)
			speaker.Rotation = Vector3.New(-args[1].Rotation.X, args[1].Rotation.Y + 180, -args[1].Rotation.Z)
		end,
	},

	{
		Name = "fling",
		Rank = 2,
		Args = { "Player" },
		Function = function(speaker, args)
			local x = math.random(250, 500)
			if math.random(2) == 2 then
				x = -x
			end

			local z = math.random(250, 500)
			if math.random(2) == 2 then
				z = -z
			end
			args[1].Velocity = Vector3.New(x, math.random(75, 125), z)
		end,
	},

	{
		Name = "gravity",
		Rank = 2,
		Args = { "Number" },
		Function = function(speaker, args)
			if not main.OGGravity then
				main.OGGravity = Environment.Gravity
			end
			Environment.Gravity = Vector3.New(0, -args[1], 0)
		end,
		UnFunction = function(speaker, args)
			if main.OGGravity then
				Environment.Gravity = main.OGGravity
				main.OGGravity = nil
			end
		end,
	},

	{
		Name = "clone",
		Rank = 2,
		Description = "Creates a clone of the specified player",
		Args = { "Player" },
		Function = function(speaker, args)
			local npc = Insert:DefaultNPC()

			npc.DisplayName = args[1].Name
			npc:LoadAppearance(args[1].UserID)
			npc.Position = args[1].Position + (args[1].Forward * 4)
			npc.Rotation = Vector3.New(-args[1].Rotation.X, args[1].Rotation.Y + 180, -args[1].Rotation.Z)
			npc.Parent = main.Debris
		end,
	},

	{ -- Someone's always watching me
		Name = "kidnap", -- Someone's always there
		Rank = 2, -- When I'm sleeping he just waits
		Alias = { "van", "clown" }, -- And he stares
		Args = { "Player" }, -- Someone's always standing in the
		Function = function(speaker, args) -- Darkest corner of my room
			local ourVan = main.Modules.Storage.Van:Clone() -- He's tall and wears a suit of black
			-- Dressed like the perfect groom

			local savedForward = Vector3.New(0, 0, 1)

			ourVan.Position = args[1].Position + (savedForward * 80)
			ourVan.Rotation = Vector3.New(0, 180, 0)
			ourVan.Parent = Environment
			ourVan.VanMusic:Play()
			args[1].CanMove = false

			for i = 1, 202 do
				ourVan.Position -= savedForward * 0.4
				wait(0.001 * (i / 5))
			end
			if args[1].IsDead then
				ourVan:Destroy()
				args[1].CanMove = true
				return
			end
			wait(0.25)
			ourVan.DoorOpen.Color = Color.New(0, 0, 0, 0)
			wait(1.5)
			if args[1].IsDead then
				ourVan:Destroy()
				args[1].CanMove = true
				return
			end

			local movePlayer = true
			local moveVan = false
			spawn(function()
				while wait() do
					if not ourVan or not ourVan.Position then
						break
					end

					if args[1].IsDead then
						movePlayer = false
					end

					if movePlayer then
						args[1].Position = ourVan.PlayerPoint.Position
					end

					if moveVan then
						ourVan.Position -= savedForward * 0.4
					end
				end
			end)

			wait(0.25)
			ourVan.DoorOpen.Color = Color.New(1, 1, 1, 1)
			ourVan.DoorOpen.CanCollide = true
			moveVan = true
			ourVan.EvilLaugh:Play()
			wait(5)
			if not args[1].IsDead then
				args[1]:Kill()
				local expl = Instance.New("Explosion")
				expl.Position = args[1].Position
				expl.Parent = Environment
			end
			args[1].CanMove = true
			wait(4)
			ourVan:Destroy()
		end,
	},

	{
		Name = "stamina",
		Rank = 2,
		Args = { "Player", "Number" },
		Function = function(speaker, args)
			local newStamina = args[2]
			if newStamina < 1 then
				newStamina = 1
			end
			args[1].MaxStamina = newStamina
			args[1].Stamina = newStamina
		end,
	},

	{
		Name = "health",
		Rank = 2,
		Args = { "Player", "Number" },
		Function = function(speaker, args)
			local newHealth = args[2]
			if newHealth < 1 then
				newHealth = 1
			end
			args[1].MaxHealth = newHealth
			args[1].Health = newHealth
		end,
	},

	{
		Name = "heal",
		Rank = 2,
		Args = { "Player" },
		Function = function(speaker, args)
			args[1].Health = args[1].MaxHealth
		end,
	},

	{
		Name = "god",
		Rank = 2,
		Args = { "Player" },
		Function = function(speaker, args)
			args[1].MaxHealth = math.huge
			args[1].Health = args[1].MaxHealth
		end,
	},

	{
		Name = "damage",
		Rank = 2,
		Alias = { "dmg " },
		Args = { "Player", "Number" },
		Function = function(speaker, args)
			args[1].Health -= args[2]
		end,
	},

	{
		Name = "h",
		Rank = 2,
		Alias = { "hint" },
		Args = { "String" },
		Function = function(speaker, args)
			local data = NetMessage.New()
			data:AddString("Function", "DisplayHint")
			data:AddString("String1", speaker.Name .. ": " .. Filter.Filter(args[1]))

			main.Modules.Client.ClientNetwork:InvokeClients(data)
		end,
	},

	-- admin --
	{
		Name = "cmdbar2",
		Rank = 3,
		Alias = { "commandbar2" },
		Args = {},
		Function = function(speaker, args)
			local data = NetMessage.New()
			data:AddString("Function", "CmdBar2")
			main.Modules.Client.ClientNetwork:InvokeClient(data, speaker)
		end,
	},

	{
		Name = "clear",
		Rank = 3,
		Description = "Clears all clones and inserted items in workspace",
		Alias = { "clr" },
		Args = {},
		Function = function(speaker, args)
			for _, v in pairs(main.Debris:GetChildren()) do
				v:Destroy()
			end
		end,
	},

	{
		Name = "insert",
		Rank = 3,
		Args = { "Number" },
		Function = function(speaker, args)
			local model = Insert:ModelAsync(args[1])

			if model then
				model.Parent = main.Debris
				model.Position = speaker.Position + (speaker.Forward * 4)
			end
		end,
	},

	{
		Name = "broadcast",
		Rank = 3,
		Args = { "String" },
		Function = function(speaker, args)
			local msg = Filter.Filter(args[1])
			Chat:BroadcastMessage(msg)
		end,
	},

	{
		Name = "m",
		Rank = 3,
		Alias = { "message" },
		Args = { "String" },
		Function = function(speaker, args)
			local data = NetMessage.New()
			data:AddString("Function", "DisplayMessage")
			data:AddString("String1", "Message from " .. speaker.Name)
			data:AddString("String2", main.GetRankName(playerHandler.GetRank(speaker)))
			data:AddString("String3", Filter.Filter(args[1]))

			main.Modules.Client.ClientNetwork:InvokeClients(data)
		end,
	},

	{
		Name = "servermessage",
		Rank = 3,
		Alias = { "sm", "smessage" },
		Args = { "String" },
		Function = function(speaker, args)
			local data = NetMessage.New()
			data:AddString("Function", "DisplayMessage")
			data:AddString("String1", "Server Message")
			data:AddString("String2", "")
			data:AddString("String3", Filter.Filter(args[1]))

			main.Modules.Client.ClientNetwork:InvokeClients(data)
		end,
	},

	{
		Name = "serverhint",
		Rank = 3,
		Alias = { "sh", "shint" },
		Args = { "String" },
		Function = function(speaker, args)
			local data = NetMessage.New()
			data:AddString("Function", "DisplayHint")
			data:AddString("String1", "Server: " .. Filter.Filter(args[1]))

			main.Modules.Client.ClientNetwork:InvokeClients(data)
		end,
	},

	{
		Name = "countdown",
		Rank = 3,
		Alias = { "timer", "countdown1" },
		Args = { "Number" },
		Function = function(speaker, args)
			if args[1] == 0 then
				args[1] = 10
			elseif args[1] < 1 then
				args[1] = 1
			end

			local data = NetMessage.New()
			data:AddString("Function", "DisplayHint")
			data:AddNumber("Number1", args[1])

			main.Modules.Client.ClientNetwork:InvokeClients(data)
		end,
	},

	{
		Name = "countdown2",
		Rank = 3,
		Alias = { "countdownm" },
		Args = { "Number" },
		Function = function(speaker, args)
			if args[1] == 0 then
				args[1] = 10
			elseif args[1] < 1 then
				args[1] = 1
			end

			local data = NetMessage.New()
			data:AddString("Function", "DisplayMessage")
			data:AddString("String1", "Countdown")
			data:AddString("String2", "")
			data:AddNumber("Number1", args[1])

			main.Modules.Client.ClientNetwork:InvokeClients(data)
		end,
	},

	{
		Name = "alert",
		Rank = 3,
		Alias = { "alarm", "warm" },
		Args = { "Player", "String" },
		Function = function(speaker, args)
			local data = NetMessage.New()
			data:AddString("Function", "DisplayAlert")
			data:AddString("String1", "ALERT FROM " .. speaker.Name)
			data:AddString("String2", Filter.Filter(args[2]))

			main.Modules.Client.ClientNetwork:InvokeClient(data, args[1])
		end,
	},

	{
		Name = "mute",
		Rank = 3,
		RankLock = true,
		Args = { "Player" },
		Function = function(speaker, args)
			local data = NetMessage.New()
			data:AddString("Function", "UseChat")
			data:AddString("String1", "Off")
			main.Modules.Client.ClientNetwork:InvokeClient(data, args[1])
		end,
		UnFunction = function(speaker, args)
			local data = NetMessage.New()
			data:AddString("Function", "UseChat")
			data:AddString("String1", "On")
			main.Modules.Client.ClientNetwork:InvokeClient(data, args[1])
		end,
	},

	{
		Name = "kick",
		Rank = 3,
		RankLock = true,
		Args = { "Player", "String" },
		Function = function(speaker, args)
			args[1]:Kick(args[2])
		end,
	},

	{
		Name = "temprank",
		Rank = 3,
		Description = "Ranks a player (until player leaves)",
		RankLock = true,
		Alias = { "trank" },
		Args = { "Player", "Rank" },
		Function = function(speaker, args)
			local rankNumber = main.GetRankNumber(args[2])
			if rankNumber > playerHandler.GetRank(speaker) then
				main.Notification(
					speaker,
					main.Format("You do not have permission to rank %s to '%s'!", args[1].Name, args[2]),
					"Error"
				)
				return
			end
			if rankNumber == 5 then
				main.Notification(
					speaker,
					main.Format("For safety, you cannot rank this player to '%s'.", args[2]),
					"Error"
				)
				return
			end

			main.Notification(speaker, main.Format("You tempRanked %s to '%s'.", args[1].Name, args[2]), "Info")
			main.Notification(args[1], main.Format("You've been tempRanked to '%s'!", args[2]), "Info")

			playerHandler.GiveRank(args[1], rankNumber)
		end,
	},

	{
		Name = "unrank",
		Rank = 3,
		Description = "Sets the players rank to 0 (NonAdmin)",
		RankLock = true,
		Args = { "Player" },
		Function = function(speaker, args)
			main.Notification(speaker, main.Format("You unranked %s", args[1].Name), "Info")
			main.Notification(args[1], "You've been unranked!", "Info")

			local ranks = Datastore:GetDatastore("SaltRanks")
			ranks:RemoveAsync(tostring(args[1].UserID))
			ranks:Disconnect()

			playerHandler.GiveRank(args[1], 0)
		end,
	},

	{
		Name = "music",
		Rank = 3,
		Alias = { "sound", "audio" },
		Args = { "Number" },
		Function = function(speaker, args)
			local saltAudio = Environment:FindChild("SaltAudio")
			if not saltAudio then
				saltAudio = Instance.New("Sound")
				saltAudio.Volume = 0.5
				saltAudio.Name = "SaltAudio"
				saltAudio.Loop = true
				saltAudio.Parent = Environment
			end

			local soundInfo = Http.GetAsync("https://api.polytoria.com/v1/store/" .. tostring(args[1]))

			if not soundInfo then
				main.Notification(speaker, main.Format("Invalid asset %s", args[1]), "Error")
				return
			end
			soundInfo = json.parse(soundInfo)

			local pt = PTAudioAsset.New()
			pt.AudioID = args[1]
			saltAudio.Audio = pt
			saltAudio:Play()

			if soundInfo.name then
				main.Notification("all", main.Format("Now playing %s (%s)", soundInfo.name, args[1]), "Silent")
			else
				main.Notification("all", main.Format("Now playing %s", args[1]), "Silent")
			end
		end,
		UnFunction = function(speaker, args)
			local saltAudio = Environment:FindChild("SaltAudio")
			if saltAudio then
				saltAudio:Stop()
			end
		end,
	},

	{
		Name = "volume",
		Rank = 3,
		Alias = { "loudness" },
		Args = { "Number" },
		Function = function(speaker, args)
			local saltAudio = Environment:FindChild("SaltAudio")
			if saltAudio then
				saltAudio.Volume = args[1]
			end
		end,
	},

	{
		Name = "pitch",
		Rank = 3,
		Alias = { "playbackSpeed" },
		Args = { "Number" },
		Function = function(speaker, args)
			local saltAudio = Environment:FindChild("SaltAudio")
			if saltAudio then
				saltAudio.Pitch = args[1]
			end
		end,
	},

	{
		Name = "blind",
		Rank = 3,
		Args = { "Player" },
		Function = function(speaker, args)
			local data = NetMessage.New()
			data:AddString("Function", "Blind")
			data:AddString("String1", "On")
			main.Modules.Client.ClientNetwork:InvokeClient(data, args[1])
		end,
		UnFunction = function(speaker, args)
			local data = NetMessage.New()
			data:AddString("Function", "Blind")
			data:AddString("String1", "Off")
			main.Modules.Client.ClientNetwork:InvokeClient(data, args[1])
		end,
	},

	{
		Name = "team",
		Rank = 3,
		Alias = { "jointeam" },
		Args = { "Player", "String" },
		Function = function(speaker, args)
			local team = Teams:FindChild(args[2])

			if team then
				args[1].Team = team
			end
		end,
	},

	{
		Name = "disco",
		Rank = 3,
		Args = {},
		Function = function(speaker, args)
			local targetHues = { 3 / 3, 2 / 3, 1 / 3 }

			main.Disco = true
			main.OGAmbientSource = Lighting.AmbientSource
			main.OGAmbientColor = Lighting.AmbientColor

			Lighting.AmbientSource = Enums.AmbientSource.Color

			spawn(function()
				while main.Disco do
					for i = 1, #targetHues do
						local targetValue = targetHues[i]

						local t = Tween.NewTween()
						t:TweenColor(Lighting.AmbientColor, Color.FromHSV(targetValue, 1, 1), 1, function(t)
							if main.Disco then
								Lighting.AmbientColor = t
							end
						end)
						t.Finished:Wait()
						if not main.Disco then
							break
						end
					end
				end
			end)
		end,
		UnFunction = function(speaker, args)
			Lighting.AmbientSource = main.OGAmbientSource
			Lighting.AmbientColor = main.OGAmbientColor

			main.Disco = nil
			main.OGAmbientSource = nil
			main.OGAmbientColor = nil
		end,
	},

	{
		Name = "fogend",
		Rank = 3,
		Alias = { "fogenddistance" },
		Args = { "Number" },
		Function = function(speaker, args)
			Lighting.FogEnabled = true
			if Lighting.FogColor.A == 0 then
				Lighting.FogColor.A = 255
			end

			local t = Tween.NewTween()
			t:TweenNumber(Lighting.FogEndDistance, args[1], 2, function(t)
				Lighting.FogEndDistance = t
			end)
		end,
	},

	{
		Name = "fogstart",
		Rank = 3,
		Alias = { "fogstartdistance" },
		Args = { "Number" },
		Function = function(speaker, args)
			Lighting.FogEnabled = true
			if Lighting.FogColor.A == 0 then
				Lighting.FogColor.A = 255
			end

			local t = Tween.NewTween()
			t:TweenNumber(Lighting.FogStartDistance, args[1], 2, function(t)
				Lighting.FogStartDistance = t
			end)
		end,
	},

	{
		Name = "fogcolor",
		Rank = 3,
		Args = { "HexColor" },
		Function = function(speaker, args)
			args[1] = main.FallbackHex(args[1])

			print(Color.FromHex(args[1]))

			local t = Tween.NewTween()
			t:TweenColor(Lighting.FogColor, Color.FromHex(args[1]), 2, function(t)
				Lighting.FogColor = t
			end)
		end,
	},

	{
		Name = "purchase",
		Rank = 3,
		Alias = { "sell", "prompt" },
		Args = { "Player", "Number" },
		Function = function(speaker, args)
			Purchases:PromptAsync(args[1], args[2])
		end,
	},

	-- headadmin --

	{
		Name = "ban",
		Rank = 4,
		Description = "Bans a player forever",
		RankLock = true,
		Alias = { "permban" },
		VisibleArgs = { "FullUsername", "Reason" },
		Args = { "FullUsername", "String" },
		Function = function(speaker, args)
			local userid = main.GetUserIDFromName(args[1])

			if not userid then
				main.Notification(speaker, main.Format("Failed to find user %s.", args[1]), "Error")
				return
			end

			if playerHandler.GetGlobalRank(userid) > playerHandler.GetRank(speaker) then
				main.Notification(
					speaker,
					main.Format("You do not have permission to use 'ban' on %s!", args[1]),
					"Error"
				)
				return
			end

			local bans = Datastore:GetDatastore("SaltBans")
			if args[2] == "" then
				args[2] = "No reason provided."
			end

			bans:SetAsync(userid .. "Reason" .. main.BanDSTesting, args[2])
			bans:Disconnect()

			if Players:FindChild(args[1]) then
				playerHandler.HandleBan(Players:FindChild(args[1]), args[2])
			end

			main.Notification(speaker, main.Format("Successfully banned %s forever.", args[1]), "Info")
		end,
	},

	{
		Name = "tempban",
		Rank = 4,
		Description = "Bans a player for a certain amount of days",
		RankLock = true,
		VisibleArgs = { "FullUsername", "Days", "Reason" },
		Args = { "String", "Number", "String" },
		Function = function(speaker, args)
			local userid = main.GetUserIDFromName(args[1])

			if not userid then
				main.Notification(speaker, main.Format("Failed to find user %s.", args[1]), "Error")
				return
			end

			if playerHandler.GetGlobalRank(userid) > playerHandler.GetRank(speaker) then
				main.Notification(
					speaker,
					main.Format("You do not have permission to use 'ban' on %s!", args[1]),
					"Error"
				)
				return
			end

			if args[2] == 0 then
				main.Notification(speaker, "Invalid ban length", "Error")
				return
			end

			local length = args[2] * 86400

			local bans = Datastore:GetDatastore("SaltBans")
			bans:SetAsync(userid .. "Reason" .. main.BanDSTesting, args[3])
			bans:SetAsync(userid .. "Time" .. main.BanDSTesting, os.time() + length)
			bans:Disconnect()

			if Players:FindChild(args[1]) then
				playerHandler.HandleBan(Players:FindChild(args[1]), args[3], os.time() + length)
			end

			main.Notification(speaker, main.Format("Successfully banned %s for %s days.", args[1], args[2]), "Info")
		end,
	},

	{
		Name = "serverban",
		Rank = 4,
		Description = "Bans a player from the server",
		RankLock = true,
		VisibleArgs = { "Player", "Reason" },
		Args = { "Player", "String" },
		Function = function(speaker, args)
			main.ServerBanned[args[1].UserID] = args[2]
			main.Notification(speaker, main.Format("Successfully server banned %s.", args[1].Name), "Info")

			playerHandler.HandleBan(args[1])
		end,
	},

	{
		Name = "unban",
		Rank = 4,
		RankLock = true,
		VisibleArgs = { "FullUsername" },
		Args = { "String" },
		Function = function(speaker, args)
			local userid = main.GetUserIDFromName(args[1])

			if userid then
				local wasSBanned = false

				if main.ServerBanned[userid] then
					main.Notification(speaker, main.Format("Un server banned %s.", args[1]), "Info")
					main.ServerBanned[userid] = nil
					wasSBanned = true
				end

				local bans = Datastore:GetDatastore("SaltBans")
				local uid = tostring(userid)

				if bans:GetAsync(uid .. "Reason" .. main.BanDSTesting) then
					pcall(function()
						bans:RemoveAsync(uid .. "Reason" .. main.BanDSTesting)
					end)
					pcall(function()
						bans:RemoveAsync(uid .. "Time" .. main.BanDSTesting)
					end)

					main.Notification(speaker, main.Format("Successfully removed global ban for %s.", args[1]), "Info")
				elseif not wasSBanned then
					main.Notification(speaker, main.Format("User %s isn't banned!", args[1]), "Info")
				end
				bans:Disconnect()
			else
				main.Notification(speaker, main.Format("Failed to find user %s.", args[1]), "Error")
			end
		end,
	},

	{
		Name = "createteam",
		Rank = 4,
		Alias = { "cteam" },
		Args = { "HexColor", "String" },
		Function = function(speaker, args)
			args[1] = main.FallbackHex(args[1])

			local team = Instance.New("Team")
			team.Name = Filter.Filter(args[2])
			team.Color = Color.FromHex(args[1])
			team.Parent = Teams
		end,
	},

	{
		Name = "removeteam",
		Rank = 4,
		Alias = { "cteam" },
		Args = { "String" },
		Function = function(speaker, args)
			if Teams:FindChild(args[1]) then
				Teams:FindChild(args[1]):Destroy()
			end
		end,
	},

	{
		Name = "crash",
		Rank = 4,
		Args = { "Player" },
		Function = function(speaker, args)
			local data = NetMessage.New()
			data:AddString("Function", "Crash")

			main.Modules.Client.ClientNetwork:InvokeClient(data, args[1])
		end,
	},

	{
		Name = "shutdown",
		Rank = 4,
		Args = {},
		Function = function(speaker, args)
			local data = NetMessage.New()
			data:AddString("Function", "DisplayMessage")
			data:AddString("String1", "Shutdown")
			data:AddString("String2", "")
			data:AddString("String3", "Shutting down server...")

			main.Modules.Client.ClientNetwork:InvokeClients(data)
			wait(3)
			for _, plr in pairs(Players:GetPlayers()) do
				plr:Kick("The server has been shutdown by " .. speaker.Name)
			end
		end,
	},

	{
		Name = "permrank",
		Rank = 4,
		Description = "Ranks a player (permanently across all servers)",
		RankLock = true,
		Alias = { "prank" },
		Args = { "Player", "Rank" },
		Function = function(speaker, args)
			local rankNumber = main.GetRankNumber(args[2])
			if rankNumber > playerHandler.GetRank(speaker) then
				main.Notification(
					speaker,
					main.Format("You do not have permission to rank %s to '%s'!", args[1].Name, args[2]),
					"Error"
				)
				return
			end
			if rankNumber == 5 then
				main.Notification(
					speaker,
					main.Format("For safety, you cannot rank this player to '%s'.", args[2]),
					"Error"
				)
				return
			end

			main.Notification(speaker, main.Format("You permRanked %s to '%s'", args[1].Name, args[2]), "Info")
			main.Notification(args[1], main.Format("You've been permRanked to '%s'!", args[2]), "Info")

			local ranks = Datastore:GetDatastore("SaltRanks")
			ranks:SetAsync(tostring(args[1].UserID), rankNumber)
			ranks:Disconnect()

			playerHandler.GiveRank(args[1], rankNumber)
		end,
	},

	{
		Name = "thankyou", -- YOU actually changed!
		Rank = 0, -- You found out how to stop being you!
		Alias = { "iloveyou", "alwayswatching", "alwaysnear" }, -- And no one else has noticed...
		Args = {}, -- Because they don't want to!
		Hidden = true, -- They don't want to see how INTERESTING you are now!
		Function = function(speaker, args) -- They'll just keep marching down the same path...
			local data = NetMessage.New() -- Without even thinking where it goes!
			data:AddString("Function", "EasterEgg1") -- Being around you...
			main.Modules.Client.ClientNetwork:InvokeClient(data, speaker) -- Is changing me, too.

			wait(1.5)
			Chat.UnicastMessage("[color=yellow]???[/color]: THANK", speaker)
			wait(1.5)
			Chat.UnicastMessage("[color=yellow]???[/color]: YOU", speaker)
		end,
	},

	-- owner --
	{
		Name = "readdatastore",
		Rank = 5,
		VisibleArgs = { "Datastore", "Key" },
		Args = { "String", "String" },
		Function = function(speaker, args)
			local ds = Datastore:GetDatastore(args[1])
			if not ds then
				main.Notification(speaker, main.Format("Failed to get datastore '%s'", args[1]), "Error")
				return
			end

			local get = ds:GetAsync(args[2])
			if not get then
				main.Notification(speaker, main.Format("Failed to get key '%s'", args[2]), "Error")
				ds:Disconnect()
				return
			end

			main.Notification(
				speaker,
				main.Format("Data for %s.%s: %s (Type: %s)", args[1], args[2], get, typeof(get)),
				"Info"
			)
			ds:Disconnect()
		end,
	},

	{
		Name = "writedatastore",
		Rank = 5,
		VisibleArgs = { "Datastore", "Key", "Data" },
		Args = { "String", "String", "String" },
		Function = function(speaker, args)
			if not args[2] then
				main.Notification(speaker, "Invalid data", "Error")
				return
			end

			if tonumber(args[3]) then
				args[3] = tonumber(args[3])
			end

			local ds = Datastore:GetDatastore(args[1])
			if not ds then
				main.Notification(speaker, main.Format("Failed to get datastore '%s'", args[1]), "Error")
				return
			end

			local get = ds:SetAsync(args[2], args[3])

			main.Notification(speaker, main.Format("Set data for %s.%s to %s", args[1], args[2], args[3]), "Info")
			ds:Disconnect()
		end,
	},

	{
		Name = "removedatastore",
		Rank = 5,
		VisibleArgs = { "Datastore", "Key" },
		Args = { "String", "String" },
		Function = function(speaker, args)
			local ds = Datastore:GetDatastore(args[1])
			if not ds then
				main.Notification(speaker, main.Format("Failed to get datastore '%s'", args[1]), "Error")
				return
			end

			local get = ds:RemoveAsync(args[2])

			main.Notification(speaker, main.Format("Removed datastore %s.%s", args[1], args[2]), "Info")
			ds:Disconnect()
		end,
	},

	{
		Name = "execute",
		Rank = 5,
		Description = "Runs a specified script source (server)",
		Alias = { "run" },
		Args = { "String" },
		Function = function(speaker, args)
			local newEnv = {}
			for i, v in pairs(_G) do
				newEnv[i] = v
			end
			for _, n in pairs(world:GetChildren()) do
				newEnv[n.Name] = n
			end
			newEnv.world = world
			newEnv.game = newEnv.world
			newEnv.Vector3 = Vector3
			newEnv.Vector2 = Vector2
			newEnv.Quaternion = Quaternion
			newEnv.spawn = spawn
			newEnv.Color = Color
			newEnv.Bounds = Bounds
			newEnv.NumberRange = NumberRange
			newEnv.ColorSeries = ColorSeries
			newEnv.InputButton = InputButton
			newEnv.json = json
			newEnv.Enums = Enums
			newEnv.NetMessage = NetMessage
			newEnv.string = string
			newEnv.PTAudioAsset = PTAudioAsset
			newEnv.BuiltInAudioAsset = BuiltInAudioAsset
			newEnv.PTImageAsset = PTImageAsset
			newEnv.GradientImageAsset = GradientImageAsset
			newEnv.env = newEnv.Environment
			newEnv.Instance = Instance
			newEnv.print = print
			newEnv.error = error
			newEnv.warn = warn
			newEnv.CustomError = function(err)
				main.Notification(speaker, tostring(err), "Error")
			end
			newEnv.script = {
				["Name"] = "ExecutedScript",
				["Source"] = args[1],
				["IsEnabled"] = true,
				["GetFullName"] = function()
					return "ExecutedScript"
				end,
			}

			local vLua = main.GetModule("vLua")
			local exec = vLua(args[1], newEnv)

			if not exec then
				main.Notification(speaker, "Malformed script!", "Error")
				return
			end

			exec()
		end,
	},
}

return module
