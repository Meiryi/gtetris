--[[
	GTetris made by Meiryi :
		None of these codes should be edited, reuploaded, or claim it's made by yourself
		I don't care if you think anywhre needs a edit/patch, just let me know and I'll do it myself!
]]

hook.Add("PlayerSay", "GTetris-PlayerSay", function(ply, text)
	if(string.lower(text) == "/tetris" || string.lower(text) == "!tetris") then
		GTetris:OpenGame(ply)
		return ""
	end
end)