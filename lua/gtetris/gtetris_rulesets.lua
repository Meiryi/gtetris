--[[
	GTetris made by Meiryi :
		None of these codes should be edited, reuploaded, or claim it's made by yourself
		I don't care if you think anywhre needs a edit/patch, just let me know and I'll do it myself!
]]

GTetris.HoldAllowed = true
GTetris.InfiniteHold = false

GTetris.Spins = "TSPIN"
--[[
	GTetris:InsertDockSubTitle(GTetris.SoloSidePanel, sidegap, topgap, "SPINS", Color(0, 0, 0, 0), color_white, sideWide)
	GTetris:CreateButton(GTetris.SoloSidePanel, sidegap, __pad, "DISABLE SPINS", "SG", "Spins", "string", "NONE", func)
	GTetris:CreateButton(GTetris.SoloSidePanel, sidegap, __pad, "ALL SPINS", "SG", "Spins", "string", "ALL", func)
	GTetris:CreateButton(GTetris.SoloSidePanel, sidegap, __pad, "T-SPINS", "SG", "Spins", "string", "TSPIN", func)
	GTetris:CreateButton(GTetris.SoloSidePanel, sidegap, __pad, "STUPID", "SG", "Spins", "string", "STUPID", func)

	GTetris:CreateButton(GTetris.SoloSidePanel, sidegap, __pad, "NONE", "SG", "ComboTable", "string", "NONE", func)
	GTetris:CreateButton(GTetris.SoloSidePanel, sidegap, __pad, "MULTIPLIER", "SG", "ComboTable", "string", "Meiryi", func)
	GTetris:CreateButton(GTetris.SoloSidePanel, sidegap, __pad, "COMBO INCREASMENT", "SG", "ComboTable", "string", "Increase", func)

	GTetris:CreateButton(GTetris.SoloSidePanel, sidegap, __pad, "DISABLE WALLKICKS", "SG", "RotationSystem", "string", "NONE", func)
	GTetris:CreateButton(GTetris.SoloSidePanel, sidegap, __pad, "SRS+", "SG", "RotationSystem", "string", "SRS-Meiryi", func)
]]
GTetris.ALLSpins = {
	["DISABLE SPINS"] = "NONE",
	["ALL SPINS"] = "ALL",
	["T-SPINS"] = "TSPIN",
	["STUPID"] = "STUPID",
}

GTetris.ALLCombos = {
	["NONE"] = "NONE",
	["MULTIPLIER"] = "Meiryi",
	["SQUARING"] = "Squaring",
	["COMBO INCREASMENT"] = "Increase",
}

GTetris.ALLWallKicks = {
	["DISABLE WALLKICKS"] = "NONE",
	["SRS+"] = "SRS-Meiryi",
	["ARS"] = "SRS-Arika",
}

GTetris.ComboAllowed = true
GTetris.ComboTable = "Meiryi"

GTetris.RotationSystem = "SRS-Meiryi"

GTetris.GarbageCap = 8
GTetris.GarbageApplyDelay = 0.25
GTetris.GarbageArriveDelay = 0.2

GTetris.GarbageScaling = 1

GTetris.Backfire = false


function GTetris:ResetRuleSets()
	for k,v in next, GTetris.Rulesets do
		GTetris[k] = v
	end
end

function GTetris:ApplyRuleSets(ruleset)
	for k,v in next, ruleset do
		GTetris[k] = v
	end
end