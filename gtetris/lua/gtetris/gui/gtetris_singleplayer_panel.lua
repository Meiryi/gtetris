--[[
	GTetris made by Meiryi :
		None of these codes should be edited, reuploaded, or claim it's made by yourself
		I don't care if you think anywhre needs a edit/patch, just let me know and I'll do it myself!
]]

function GTetris:CreateSGOptions()
	GTetris.SoloSidePanel:Clear()
	local sideWide = ScreenScale(25)
	local sidegap = ScreenScale(5) + sideWide
	local topgap = ScreenScale(7)
	local __pad = ScreenScale(2)

	local func = function()
		GTetris:WriteSGRuleSets()
		GTetris:ApplyRuleSets(GTetris.SG)
	end

	GTetris:InsertDockTitle(GTetris.SoloSidePanel, sidegap, topgap, "SETTINGS", Color(0, 0, 0, 0), color_white, sideWide)
	GTetris:InsertGap(GTetris.SoloSidePanel, ScreenScale(20))
	GTetris:InsertDockSubTitle(GTetris.SoloSidePanel, sidegap, topgap, "GENERAL", Color(0, 0, 0, 0), color_white, sideWide)
	GTetris:CreateButton(GTetris.SoloSidePanel, sidegap, __pad, "ENABLE HOLD", "SG", "HoldAllowed", "bool", nil, func)
	GTetris:CreateButton(GTetris.SoloSidePanel, sidegap, __pad, "INFINITE HOLD", "SG", "InfiniteHold", "bool", nil, func)

	GTetris:InsertDockSubTitle(GTetris.SoloSidePanel, sidegap, topgap, "SPINS", Color(0, 0, 0, 0), color_white, sideWide)
	--[[
	GTetris:CreateButton(GTetris.SoloSidePanel, sidegap, __pad, "DISABLE SPINS", "SG", "Spins", "string", "NONE", func)
	GTetris:CreateButton(GTetris.SoloSidePanel, sidegap, __pad, "ALL SPINS", "SG", "Spins", "string", "ALL", func)
	GTetris:CreateButton(GTetris.SoloSidePanel, sidegap, __pad, "T-SPINS", "SG", "Spins", "string", "TSPIN", func)
	GTetris:CreateButton(GTetris.SoloSidePanel, sidegap, __pad, "STUPID", "SG", "Spins", "string", "STUPID", func)
	]]

	for k,v in next, GTetris.ALLSpins do
		GTetris:CreateButton(GTetris.SoloSidePanel, sidegap, __pad, k, "SG", "Spins", "string", v, func)
	end

	GTetris:InsertDockSubTitle(GTetris.SoloSidePanel, sidegap, topgap, "COMBOS", Color(0, 0, 0, 0), color_white, sideWide)
	--[[
	GTetris:CreateButton(GTetris.SoloSidePanel, sidegap, __pad, "NONE", "SG", "ComboTable", "string", "NONE", func)
	GTetris:CreateButton(GTetris.SoloSidePanel, sidegap, __pad, "MULTIPLIER", "SG", "ComboTable", "string", "Meiryi", func)
	GTetris:CreateButton(GTetris.SoloSidePanel, sidegap, __pad, "COMBO INCREASMENT", "SG", "ComboTable", "string", "Increase", func)
	]]

	for k,v in next, GTetris.ALLCombos do
		GTetris:CreateButton(GTetris.SoloSidePanel, sidegap, __pad, k, "SG", "ComboTable", "string", v, func)
	end

	GTetris:InsertDockSubTitle(GTetris.SoloSidePanel, sidegap, topgap, "WALLKICKS", Color(0, 0, 0, 0), color_white, sideWide)
	--[[
	GTetris:CreateButton(GTetris.SoloSidePanel, sidegap, __pad, "DISABLE WALLKICKS", "SG", "RotationSystem", "string", "NONE", func)
	GTetris:CreateButton(GTetris.SoloSidePanel, sidegap, __pad, "SRS+", "SG", "RotationSystem", "string", "SRS-Meiryi", func)
	]]
	for k,v in next, GTetris.ALLWallKicks do
		GTetris:CreateButton(GTetris.SoloSidePanel, sidegap, __pad, k, "SG", "RotationSystem", "string", v, func)
	end

	GTetris:InsertDockSubTitle(GTetris.SoloSidePanel, sidegap, topgap, "GARBAGE", Color(0, 0, 0, 0), color_white, sideWide)
	GTetris:CreateButton(GTetris.SoloSidePanel, sidegap, __pad, "BACKFIRE 1x", "SG", "Backfire", "bool", nil, func)
end