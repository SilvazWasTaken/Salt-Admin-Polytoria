--[[

			░██████╗░█████╗░██╗░░░░░████████╗  ░█████╗░██████╗░███╗░░░███╗██╗███╗░░██╗
			██╔════╝██╔══██╗██║░░░░░╚══██╔══╝  ██╔══██╗██╔══██╗████╗░████║██║████╗░██║
			╚█████╗░███████║██║░░░░░░░░██║░░░  ███████║██║░░██║██╔████╔██║██║██╔██╗██║
			░╚═══██╗██╔══██║██║░░░░░░░░██║░░░  ██╔══██║██║░░██║██║╚██╔╝██║██║██║╚████║
			██████╔╝██║░░██║███████╗░░░██║░░░  ██║░░██║██████╔╝██║░╚═╝░██║██║██║░╚███║
			╚═════╝░╚═╝░░╚═╝╚══════╝░░░╚═╝░░░  ╚═╝░░╚═╝╚═════╝░╚═╝░░░░░╚═╝╚═╝╚═╝░░╚══╝
				
			Open source cool admin commands for your game™
			85+ commands ranging from moderation to fun
			
			GITHUB: https://github.com/SilvazWasTaken/Salt-Admin-Polytoria
			
			Get started:
				- You don't need to edit anything to get Salt Admin running, just leave it in Environment or ScriptService
				- Optionally, you can change the settings [Salt Admin > Settings]
				- For advanced users, you can read the code [Salt Admin > Loader > Modules]
				- It is advised to not edit the code as Salt Admin will be updated frequently
				
			How to use:
				- By default, the game creator will have the 'Owner' rank
				- Rank other people with ;permrank [Username] [Rank] when they are in game with you
				- Type ;cmds to view the commands list
				
			Updating:
				- If you have modified settings, copy them to your clipboard
				- Delete the old Salt Admin model, import the new one
				- Paste back in the settings
				
			Advanced users:
				To rank player via script:
					- require([Salt Admin].Loader.Modules.Server.PlayerHandler).GiveRank(player, rankNumber)
]]