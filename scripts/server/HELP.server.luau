--[[

			░██████╗░█████╗░██╗░░░░░████████╗  ░█████╗░██████╗░███╗░░░███╗██╗███╗░░██╗
			██╔════╝██╔══██╗██║░░░░░╚══██╔══╝  ██╔══██╗██╔══██╗████╗░████║██║████╗░██║
			╚█████╗░███████║██║░░░░░░░░██║░░░  ███████║██║░░██║██╔████╔██║██║██╔██╗██║
			░╚═══██╗██╔══██║██║░░░░░░░░██║░░░  ██╔══██║██║░░██║██║╚██╔╝██║██║██║╚████║
			██████╔╝██║░░██║███████╗░░░██║░░░  ██║░░██║██████╔╝██║░╚═╝░██║██║██║░╚███║
			╚═════╝░╚═╝░░╚═╝╚══════╝░░░╚═╝░░░  ╚═╝░░╚═╝╚═════╝░╚═╝░░░░░╚═╝╚═╝╚═╝░░╚══╝
				
			Open source cool admin commands for your game™
			75+ commands ranging from moderation to fun
			
			GITHUB: https://github.com/SilvazWasTaken/Salt-Admin-Polytoria
			
			Get started:
				- You don't need to edit anything to get Salt Admin running, just leave it in Environment
				- Optionally, you can change the settings [Salt Admin > Settings]
				- For advanced users, you can read the code [Salt Admin > Loader > Modules]
				- It is advised to not edit the code as Salt Admin will be updated frequently
				
			How to use:
				- By default, the game creator will have the 'Owner' rank
				- Rank other people with ;permrank [Username] [Rank] when they are in game with you
				- Type ;cmds to view the commands list
				
			Updating:
				- To preserve settings, replace [Salt Admin > Loader] with the updated Loader
				- If you have no settings you wish to preserve, just delete [Salt Admin] and replace it with the updated one
				
			Advanced users:
				To rank player via script:
					- require([Salt Admin].Loader.Modules.Server.PlayerHandler).GiveRank(player, rankNumber)
]]