--[[
	GTetris made by Meiryi :
		None of these codes should be edited, reuploaded, or claim it's made by yourself
		I don't care if you think anywhre needs a edit/patch, just let me know and I'll do it myself!
]]

function GTetris:ReadSinglePlayerScore(score)
	if(!file.Exists("gtetris/singleplayer/score.txt", "DATA")) then
		GTetris:SaveSinglePlayerScore(0)
		return 0
	else
		return file.Read("gtetris/singleplayer/score.txt", "DATA")
	end
end

function GTetris:SaveSinglePlayerScore(score)
	file.Write("gtetris/singleplayer/score.txt", score)
end

function GTetris:ReadSGRuleSets()
	if(!file.Exists("gtetris/singleplayer/rulesets.txt", "DATA")) then
		GTetris:WriteSGRuleSets()
	else
		GTetris.SG = util.JSONToTable(file.Read("gtetris/singleplayer/rulesets.txt", "DATA"))
	end
end

function GTetris:WriteSGRuleSets()
	file.Write("gtetris/singleplayer/rulesets.txt", util.TableToJSON(GTetris.SG))
end

function GTetris:WriteHandlingConfig()
	file.Write("gtetris/config.txt", util.TableToJSON(GTetris.Handling))
end

function GTetris:ReadHandlingConfig()
	if(!file.Exists("gtetris/config.txt", "DATA")) then
		GTetris:WriteHandlingConfig()
	else
		local data = util.JSONToTable(file.Read("gtetris/config.txt", "DATA"))
		if(data != nil) then
			for k,v in next, data do
				GTetris.Handling[k] = v
			end
		end
	end
end

function GTetris:WriteControlConfig()
	file.Write("gtetris/control.txt", util.TableToJSON(GTetris.Keys))
end

function GTetris:ReadControlConfig()
	if(!file.Exists("gtetris/control.txt", "DATA")) then
		GTetris:WriteControlConfig()
	else
		local data = util.JSONToTable(file.Read("gtetris/control.txt", "DATA"))
		if(data != nil) then
			for k,v in next, data do
				GTetris.Keys[k] = v
			end
		end
	end
end