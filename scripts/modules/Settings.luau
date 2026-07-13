settings = {

	-- RANK, RANK NAMES & SPECIFIC USERS
	Ranks = {
		{ 5, "Owner", { "Player1", 0 } },
		{ 4, "HeadAdmin", { "", 0 } },
		--{ 3.5, "SuperAdmin", { "", 0 } },
		{ 3, "Admin", { "", 0 } },
		{ 2, "Mod", { "", 0 } }, -- Can only use commands on one person at a time.
		{ 1, "VIP", { "", 0 } }, -- Can only use commands on theirself.
		{ 0, "NonAdmin" },
	},

	-- GAMEPASSES
	Gamepasses = {
		[0] = "VIP",
	},

	-- BADGES
	Badges = {
		[0] = "VIP",
	},

	-- FREE ADMIN
	FreeAdmin = "Mod",

	--
	--
	Prefix = ";", -- The character you use before every command (e.g. ';jump me').
	CommandLimitPerMinute = 60, -- Command limit per admin per minute

	PlaytestUser = "", -- Replace "Player1" when playtesting with specified username
	RankAllTesting = false, -- Set to true to give all testing players (Player2, Player3 etc) the 'Owner' rank

	VersionCheck = true, -- Set to true to send a reminder to the game creator if the system is outdated
	EasterEggs = true, -- Disables funny easter eggs :<

	WelcomeRankNotice = true, -- The 'You're a [rankName]' notice that appears when you join the game. Set to false to disable
	WarnIncorrectPrefix = true, -- Warn the user if using the wrong prefix | "Invalid prefix! Try using [correctPrefix][commandName] instead!"
	DisableAllNotices = false, -- Set to true to disable all Salt's Admin notices.

	ResetSizeOnSpawn = true, -- Resets size on respawn which fixes weird accessory scaling issues

	ScaleLimit = 4, -- The maximum size players with a rank lower than 'IgnoreScaleLimit' can scale theirself. For example, players will be limited to ;size me 4 (if limit is 4) - any number above is blocked.
	IgnoreScaleLimit = 3, -- Any ranks equal or above this value will ignore 'ScaleLimit'

	Cmdbar = 1, -- The minimum rank required to use the Cmdbar.
	Cmdbar2 = 3, -- The minimum rank required to use the Cmdbar2.

	-- MODIFY COMMANDS
	SetCommandRankByName = {
		--[[["fling"] = 5,
		["fly"] = 5,
		["kill"] = 5,--]]
	},
}

return settings
