--[[
	GTetris made by Meiryi :
		None of these codes should be edited, reuploaded, or claim it's made by yourself
		I don't care if you think anywhre needs a edit/patch, just let me know and I'll do it myself!
]]

local refresh = true

function GTetris:WaitingScreen(func)
	GTetris.WaitingForRespond = true
	if(IsValid(GTetris.Waiting)) then GTetris.Waiting:Remove() end
	local startTime = SysTime()
	local timeout = 5 + (LocalPlayer():Ping() / 1000)
	local p = GTetris:CreatePanel(GTetris.Gui, 0, 0, ScrW(), ScrH(), Color(0, 0, 0, 0))
	p.alpha = 0
	p.Paint = function()
		p.alpha = math.Clamp(p.alpha + GTetris:GetFixedValue(10), 0, 200)
		draw.RoundedBox(0, 0, 0, ScrW(), ScrH(), Color(0, 0, 0, p.alpha))
		draw.DrawText("Waiting for server to respond..", "GTetris-TabButtonFont", ScrW() / 2, ScrH() / 2, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)

		if(!GTetris.WaitingForRespond) then
			p:Remove()
		end

		if(math.abs(startTime - SysTime()) > timeout) then
			func()
			p:Remove()
		end
	end

	GTetris.Waiting = p
end

function GTetris:ToggleTabs(vis)
	for k,v in next, GTetris.Gui.__Tabs do
		v:SetVisible(vis)
	end
	GTetris.Gui.ShouldDrawBG = vis
end

function GTetris:CreateBackButton(func)
	if(IsValid(GTetris.Gui.BackButton)) then
		GTetris.Gui.BackButton:Remove()
	end
	GTetris.Gui.BackButton = vgui.Create("DButton", GTetris.Gui)
	GTetris.Gui.BackButton:SetPos(0, ScrH() * 0.85)
	GTetris.Gui.BackButton:SetZPos(32767)
	GTetris.Gui.BackButton:SetSize(ScreenScale(60), ScreenScale(20))
	GTetris.Gui.BackButton:SetText("")
	GTetris.Gui.BackButton:SetFont("GTetris-TabButtonFont")
	GTetris:ResetRuleSets()
	local oX, oY = ScreenScale(50), ScreenScale(25)
	local padding = 1
	local padding2x = padding * 2
	local offs = GTetris:GetTextYOffset(oY, "GTetris-TabButtonFont")
	GTetris.Gui.BackButton.Paint = function()
		local wide = GTetris.Gui.BackButton:GetWide()
		draw.RoundedBox(0, 0, 0, GTetris.Gui.BackButton:GetWide(), GTetris.Gui.BackButton:GetTall(), Color(100, 100, 100, 255))
		draw.RoundedBox(0, 0, padding, GTetris.Gui.BackButton:GetWide() - padding, GTetris.Gui.BackButton:GetTall() - padding2x, Color(30, 30, 30, 255))
		draw.DrawText("BACK", "GTetris-TabButtonFont", wide * 0.85, offs / 2, Color(200, 200, 200, 255), TEXT_ALIGN_RIGHT)
	end

	GTetris.Gui.BackButton.Think = function()
	local wide = GTetris.Gui.BackButton:GetWide()
		if(GTetris.Gui.BackButton:IsHovered()) then
			GTetris.Gui.BackButton:SetWide(math.Clamp(wide + GTetris:GetFixedValue(10), oX, oX * 1.45))
		else
			GTetris.Gui.BackButton:SetWide(math.Clamp(wide - GTetris:GetFixedValue(10), oX, oX * 1.45))
		end
	end

	GTetris.Gui.BackButton.DoClick = func
end

function GTetris:SwitchScene(func)
	local topLayer = GTetris:CreateFrame(nil, 0, 0, ScrW(), ScrH(), Color(0, 0, 0, 125), true)
	local switch = false
	local alpha = 0
	topLayer.Think = function()
		if(switch) then
			alpha = math.Clamp(alpha - GTetris:GetFixedValue(10), 0, 255)
			if(alpha <= 0) then
				topLayer:Remove()
			end
		else
			alpha = math.Clamp(alpha + GTetris:GetFixedValue(15), 0, 255)
			if(alpha >= 255) then
				if(func != nil) then
					func()
				end
				switch = true
			end
		end
	end
	topLayer.Paint = function()
		draw.RoundedBox(0, 0, 0, ScrW(), ScrH(), Color(0, 0, 0, alpha))
	end
end

function GTetris:OpenGame()
	if(IsValid(GTetris.Gui)) then
		if(!refresh) then
			return
		else
			GTetris.Gui:Remove()
		end
	end
	GTetris:SetupFonts()
	GTetris:ReadHandlingConfig()
	GTetris:ReadControlConfig()
	GTetris.Gui = GTetris:CreateFrame(nil, 0, 0, ScrW(), ScrH(), Color(0, 0, 0, 125), true)
	GTetris.WaitingForRespond = false
	local sideWide = ScreenScale(25)
	local totWide = (ScrW() * 0.25) - sideWide
	GTetris.SoloSidePanel = GTetris:CreateScroll(GTetris.Gui, ScrW() - sideWide, 0, ScrW() * 0.25, ScrH(), Color(0, 0, 0, 240))
	GTetris.SoloSidePanel:SetVisible(false)
	GTetris.SoloSidePanel.Inc = 0
	GTetris.SoloSidePanel.oX = ScrW() - sideWide

	GTetris.SoloSidePanel._IsHovered = function()
		local s = GTetris.SoloSidePanel
		local x, y = input.GetCursorPos()
		return (x >= s:GetX() && x <= s:GetX() + s:GetWide() && y >= s:GetY() && y <= s:GetY() + s:GetTall())
	end

	GTetris.SoloSidePanel.Think = function()
		if(GTetris.SoloSidePanel._IsHovered()) then
			GTetris.SoloSidePanel.Inc = math.Clamp(GTetris.SoloSidePanel.Inc + GTetris:GetFixedValue((totWide - GTetris.SoloSidePanel.Inc) * 0.33), 0, totWide)
		else
			GTetris.SoloSidePanel.Inc = math.Clamp(GTetris.SoloSidePanel.Inc - GTetris:GetFixedValue(GTetris.SoloSidePanel.Inc * 0.33), 0, totWide)
		end
		GTetris.SoloSidePanel:SetX(GTetris.SoloSidePanel.oX - GTetris.SoloSidePanel.Inc)
	end
	local baseX, baseW = ScreenScale(20), totWide
	local centX = baseX + baseW / 2
	local sx = sideWide * 0.65
	local offs = (sideWide - sx) / 2
	local rnd = ScreenScale(3)
	GTetris.SoloSidePanel.Paint = function()
		draw.RoundedBox(0, sideWide, 0, GTetris.SoloSidePanel:GetWide(), GTetris.SoloSidePanel:GetTall(), Color(0, 0, 0, 240))
		draw.RoundedBox(rnd, 0, 0, sideWide * 1.15, sideWide, Color(50, 50, 50, 240))

		surface.SetMaterial(GTetris.OptionMaterial)
		surface.SetDrawColor(255, 255, 255, 255)
		surface.DrawTexturedRect(offs, offs, sx, sx)
	end
	local sidegap = ScreenScale(5) + sideWide
	local topgap = ScreenScale(7)

	GTetris:CreateSGOptions()

	GTetris.IsSinglePlayer = false
	GTetris.IsMultiplayer = false
	GTetris.ShouldProcess = false

	GTetris:ReloadGrids()

	local TabHeight_ = ScrH() * 0.05
	local TabHeight = ScrH() * 0.075

	local boxColor = Color(0, 0, 0, 255)

	local sx = ScreenScale(150)
	local offs = (ScrH() * 0.775)

	GTetris.Gui.ShouldDrawBG = true
	GTetris.Gui.Paint = function()
		draw.RoundedBox(0, 0, 0, GTetris.Gui:GetWide(), GTetris.Gui:GetTall(), Color(0, 0, 0, 210))
		if(GTetris.Gui.ShouldDrawBG) then
			draw.RoundedBox(0, 0, 0, GTetris.Gui:GetWide(), TabHeight_, boxColor)
			surface.SetMaterial(GTetris.LogoMaterial)

			surface.SetDrawColor(255, 255, 255, 255)
			surface.DrawTexturedRect(ScrW() / 2 - sx / 2, (offs / 2) - sx / 2, sx, sx)

			draw.RoundedBox(0, 0, ScrH() - TabHeight_, GTetris.Gui:GetWide(), TabHeight_, boxColor)
		end
	end

	local tabs = {}
	local buttonW = math.floor(ScrW() * 0.18)
	local gap = ScreenScale(5)
	local nextX = 0
	local nextY = ScrH() * 0.775
	local totalBTN = 4
	local offs = (totalBTN * buttonW) + ((totalBTN - 1) * gap)
	nextX = (ScrW() - offs) / 2
	--table.insert(tabs, GTetris:CreateTabButton(GTetris.Gui, 0, 0, buttonW, TabHeight, "MATCHMAKING", Color(0, 0, 0, 180), function() end))

	table.insert(tabs, GTetris:CreateTabButton(GTetris.Gui, nextX, nextY, buttonW, TabHeight, "SINGLEPLAYER", Color(30, 30, 30, 180), function()
		GTetris:SwitchScene(function()
			GTetris:ToggleTabs(false)
			GTetris:CreateBackButton(function()
				GTetris:SwitchScene(function()
					GTetris.IsSinglePlayer = false
					GTetris.IsMultiplayer = false
					GTetris.ShouldProcess = false
					GTetris.ShouldRunLogicChecks = false
					GTetris.SoloSidePanel:SetVisible(false)
					GTetris:ToggleTabs(true)
					GTetris.Gui.BackButton:Remove()
					GTetris:ResetPDetails()
				end)
			end)
			GTetris.GarbageSent = 0
			GTetris.GarbageRecordTime = SysTime()
			GTetris.PiecesPlaced = 0
			GTetris.PieceRecordTime = SysTime()
			GTetris.SoloSidePanel:SetVisible(true)
			GTetris.IsSinglePlayer = true
			GTetris.ShouldProcess = true
			GTetris.ShouldRunLogicChecks = true
			GTetris:ResetPDetails()
			GTetris:ReadSGRuleSets()
			GTetris:ApplyRuleSets(GTetris.SG)
			GTetris:ReloadGrids()
		end)
	end))

	nextX = nextX + buttonW + gap
	table.insert(tabs, GTetris:CreateTabButton(GTetris.Gui, nextX, nextY, buttonW, TabHeight, "MULTIPLAYER", Color(30, 30, 30, 180), function()
		GTetris:SwitchScene(function()
			GTetris:ToggleTabs(false)
			GTetris:CreateBackButton(function()
				GTetris:SwitchScene(function()
					GTetris.IsSinglePlayer = false
					GTetris.IsMultiplayer = false
					GTetris.ShouldProcess = false
					GTetris.ShouldRunLogicChecks = false
					GTetris.SoloSidePanel:SetVisible(false)
					GTetris:DestroyOnlineUI()
					GTetris:ToggleTabs(true)
					GTetris.Gui.BackButton:Remove()
				end)
			end)
			GTetris:BuildOnlineUI()
			GTetris:ToggleTabs(false)
		end)
	end))
	nextX = nextX + buttonW + gap
	table.insert(tabs, GTetris:CreateTabButton(GTetris.Gui, nextX, nextY, buttonW, TabHeight, "SETTINGS", Color(30, 30, 30, 180), function()
		GTetris:SwitchScene(function()
			GTetris:ToggleTabs(false)
			GTetris:CreateBackButton(function()
				GTetris:SwitchScene(function()
					GTetris.IsSinglePlayer = false
					GTetris.IsMultiplayer = false
					GTetris.ShouldProcess = false
					GTetris.ShouldRunLogicChecks = false
					GTetris.SoloSidePanel:SetVisible(false)
					GTetris:DestroyOptionsUI()
					GTetris:ToggleTabs(true)
					GTetris.Gui.BackButton:Remove()
				end)
			end)
			GTetris:BuildOptionsUI()
			GTetris:ToggleTabs(false)
			GTetris.Gui.ShouldDrawBG = true
		end)
	end))
	nextX = nextX + buttonW + gap
	table.insert(tabs, GTetris:CreateTabButton(GTetris.Gui, nextX, nextY, buttonW, TabHeight, "EXIT", Color(30, 30, 30, 180), function()
		GTetris.IsSinglePlayer = false
		GTetris.IsMultiplayer = false
		GTetris.ShouldProcess = false
		GTetris.ShouldRunLogicChecks = false
		GTetris.SoloSidePanel:SetVisible(false)
		GTetris.Gui:Remove()
	end))

	GTetris.Gui.__Tabs = tabs
end