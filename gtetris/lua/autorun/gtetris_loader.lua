--[[
	GTetris made by Meiryi :
		None of these codes should be edited, reuploaded, or claim it's made by yourself
		I don't care if you think anywhre needs a edit/patch, just let me know and I'll do it myself!
]]
CreateConVar("gtetris_maximum_bot_per_room", 10, FCVAR_ARCHIVE, "How manu bots a oom can add", 1, 10)
CreateConVar("gtetris_maximum_bot_pps", 20, FCVAR_ARCHIVE, "How fast bots can place a piece", 0.3, 20)

if(SERVER) then
	AddCSLuaFile("gtetris/gtetris_client.lua")
	AddCSLuaFile("gtetris/gtetris_shared_rulesets.lua")
	AddCSLuaFile("gtetris/gtetris_singleplayer_options.lua")
	AddCSLuaFile("gtetris/gtetris_rulesets.lua")
	AddCSLuaFile("gtetris/gtetris_handling.lua")
	AddCSLuaFile("gtetris/gtetris_minogenerator.lua")
	AddCSLuaFile("gtetris/gtetris_garbages.lua")
	AddCSLuaFile("gtetris/gtetris_logic.lua")
	AddCSLuaFile("gtetris/gtetris_grids.lua")
	AddCSLuaFile("gtetris/gtetris_networking.lua")
	AddCSLuaFile("gtetris/gtetris_rendering.lua")
	AddCSLuaFile("gtetris/gtetris_tetrominos.lua")
	AddCSLuaFile("gtetris/gtetris_rotationsystem.lua")
	AddCSLuaFile("gtetris/gtetris_data_io.lua")
	AddCSLuaFile("gtetris/gtetris_sounds.lua")
	AddCSLuaFile("gtetris/gtetris_htmlparser.lua")

	AddCSLuaFile("gtetris/bot/gtetris_minogenerator.lua")
	AddCSLuaFile("gtetris/bot/gtetris_opener_library.lua")
	AddCSLuaFile("gtetris/bot/gtetris_bot_logic.lua")
	AddCSLuaFile("gtetris/bot/gtetris_bot.lua")

	AddCSLuaFile("gtetris/gui/gtetris_gui_func.lua")
	AddCSLuaFile("gtetris/gui/gtetris_gui.lua")
	AddCSLuaFile("gtetris/gui/gtetris_singleplayer_panel.lua")
	AddCSLuaFile("gtetris/gui/gtetris_options_gui.lua")
	AddCSLuaFile("gtetris/gui/gtetris_options.lua")
	AddCSLuaFile("gtetris/gui/gtetris_online_gui.lua")

	include("gtetris/server/gtetris_server.lua")
	include("gtetris/gtetris_shared_rulesets.lua")
	include("gtetris/server/gtetris_rooms.lua")
	include("gtetris/server/gtetris_sv_gamelogic.lua")
	include("gtetris/server/gtetris_sv_hooks.lua")
	include("gtetris/server/gtetris_sv_networking.lua")
	include("gtetris/server/gtetris_bots_processing.lua")
	include("gtetris/server/gtetris_sv_sounds_handler.lua")

	include("gtetris/server/bot/gtetris_bot.lua")
	include("gtetris/server/bot/gtetris_bot_logic.lua")
	include("gtetris/server/bot/gtetris_minogenerator.lua")
else
	include("gtetris/gtetris_client.lua")
	include("gtetris/gtetris_shared_rulesets.lua")
	include("gtetris/gtetris_singleplayer_options.lua")
	include("gtetris/gtetris_rulesets.lua")
	include("gtetris/gtetris_handling.lua")
	include("gtetris/gtetris_minogenerator.lua")
	include("gtetris/gtetris_garbages.lua")
	include("gtetris/gtetris_logic.lua")
	include("gtetris/gtetris_grids.lua")
	include("gtetris/gtetris_networking.lua")
	include("gtetris/gtetris_rendering.lua")
	include("gtetris/gtetris_tetrominos.lua")
	include("gtetris/gtetris_rotationsystem.lua")
	include("gtetris/gtetris_data_io.lua")
	include("gtetris/gtetris_sounds.lua")
	include("gtetris/gtetris_htmlparser.lua")

	include("gtetris/bot/gtetris_bot_logic.lua")
	include("gtetris/bot/gtetris_opener_library.lua")
	include("gtetris/bot/gtetris_minogenerator.lua")
	include("gtetris/bot/gtetris_bot.lua")

	include("gtetris/gui/gtetris_gui_func.lua")
	include("gtetris/gui/gtetris_gui.lua")
	include("gtetris/gui/gtetris_singleplayer_panel.lua")
	include("gtetris/gui/gtetris_options_gui.lua")
	include("gtetris/gui/gtetris_options.lua")
	include("gtetris/gui/gtetris_online_gui.lua")
end

include("gtetris/gtetris_shared.lua")
AddCSLuaFile("gtetris/gtetris_shared.lua")

file.CreateDir("gtetris")
file.CreateDir("gtetris/multiplayer")
file.CreateDir("gtetris/singleplayer")
file.CreateDir("gtetris/avatars")
file.CreateDir("gtetris/avatars/frames")