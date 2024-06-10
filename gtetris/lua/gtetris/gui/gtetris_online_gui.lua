--[[
	GTetris made by Meiryi :
		None of these codes should be edited, reuploaded, or claim it's made by yourself
		I don't care if you think anywhre needs a edit/patch, just let me know and I'll do it myself!
]]

function GTetris:DestroyOnlineUI()
	if(IsValid(GTetris.OnlineUI)) then
		GTetris.OnlineUI:Remove()
	end
end

GTetris.FetchingHistory = false
GTetris.CurrentOnlineOption = "?"
GTetris.ReturnedContent = ""
GTetris.TotalRequests = 1
GTetris.CurrentRequested = 0
GTetris.GameStarted = false
GTetris.WaitingAPIPanel = nil
GTetris.MaximumINX = 1

function GTetris:APIRespond()
	if(IsValid(GTetris.WaitingAPIPanel)) then
		GTetris.WaitingAPIPanel.clicked = true
	end
end

function GTetris:WaitingAPIScreen()
	local p = GTetris:CreatePanel(GTetris.Gui, 0, 0, ScrW(), ScrH(), Color(0, 0, 0, 0))
		p:SetZPos(32767)
		p:MakePopup()
		p.alpha = 0
		p.player = player
		p.clicked = false
		p:SetAlpha(p.alpha)
		local gap = ScreenScale(5)
		local switch = false
		local switchtime = 0
		local alpha = 40
		local timeout = SysTime() + 15
		p.Paint = function()
			if(!switch) then
				if(switchtime < SysTime()) then
					alpha = math.Clamp(alpha + GTetris:GetFixedValue(5), 0, 255)
				end
				if(alpha >= 255) then
					switchtime = SysTime() + 0.15
					switch = true
				end
			else
				if(switchtime < SysTime()) then
					alpha = math.Clamp(alpha - GTetris:GetFixedValue(5), 0, 255)
				end
				if(alpha <= 50) then
					switchtime = SysTime() + 0.15
					switch = false
				end
			end
			if(!p.clicked) then
				p.alpha = math.Clamp(p.alpha + GTetris:GetFixedValue(20), 0, 255)
			else
				p.alpha = math.Clamp(p.alpha - GTetris:GetFixedValue(20), 0, 255)
				if(p.alpha <= 0) then
					p:Remove()
				end
			end
			draw.RoundedBox(0, 0, 0, p:GetWide(), p:GetTall(), Color(0, 0, 0, 200))
			if(timeout > SysTime()) then
				local tl = math.floor(math.abs(SysTime() - timeout))
				if(tl > 5) then
					draw.DrawText("FETCHING DATA..", "GTetris-ProfileName", ScrW() / 2, ScrH() / 2, Color(255, 255, 255, alpha), TEXT_ALIGN_CENTER)
				else
					draw.DrawText("FETCHING DATA.. (TIMEOUT IN "..tl..")", "GTetris-ProfileName", ScrW() / 2, ScrH() / 2, Color(255, 255, 255, alpha), TEXT_ALIGN_CENTER)
				end
			else
				p:Remove()
				GTetris:PopupMenu("REQUEST FAILED", "CONNECTION TO SERVER TIMEDOUT")
			end
			p:SetAlpha(p.alpha)
		end

	GTetris.WaitingAPIPanel = p
end

surface.CreateFont("GTetris-ProfileName", {
	font = "Arial",
	extended = false,
	size = ScreenScale(28),
	weight = 1000,
	blursize = 0,
	scanlines = 0,
	antialias = true,
})

surface.CreateFont("GTetris-ProfileText", {
	font = "Arial",
	extended = false,
	size = ScreenScale(20),
	weight = 1000,
	blursize = 0,
	scanlines = 0,
	antialias = true,
})

surface.CreateFont("GTetris-MPTitle", {
	font = "Arial",
	extended = false,
	size = ScreenScale(14),
	weight = 1000,
	blursize = 0,
	scanlines = 0,
	antialias = true,
})

surface.CreateFont("GTetris-MPSettings", {
	font = "Arial",
	extended = false,
	size = ScreenScale(10),
	weight = 300,
	blursize = 0,
	scanlines = 0,
	antialias = true,
})

GTetris.ScreenTextSize = ScreenScale(36)
surface.CreateFont("GTetris-ScreenText", {
	font = "Arial",
	extended = false,
	size = GTetris.ScreenTextSize,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
})

GTetris.ScreenTextSize2 = ScreenScale(16)
surface.CreateFont("GTetris-ScreenText2", {
	font = "Arial",
	extended = false,
	size = GTetris.ScreenTextSize2,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
})

surface.CreateFont("GTetris-BotTitle", {
	font = "Arial",
	extended = false,
	size = ScreenScale(12),
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
})

surface.CreateFont("GTetris-BotSubTitle", {
	font = "Arial",
	extended = false,
	size = ScreenScale(10),
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
})


local gap = ScreenScale(3)
local line = ScreenScale(1)

function GTetris:EasyWebAvatar(parent, x, y, w, h, steamid, bot)

	local isbot = false
	if(steamid == "?" || bot) then isbot = true end
	local nextCheckTime = 0
	local found = false
	local expectedPath = "data/gtetris/avatars/"..steamid..".png"
	local padding = h * 0.1
	local img = parent:Add("DImage")
		img:SetPos(x + padding, y + padding)
		img:SetSize(w - padding * 2, h - padding * 2)
		img.Think = function()
			if(isbot) then img:SetImage("gtetris/internal/bot.png") img.Think = nil return end
			if(nextCheckTime > SysTime()) then return end
			if(file.Exists(expectedPath, "GAME")) then
				img:SetImage(expectedPath)
				img.Think = nil
				return
			else
				GTetris:GetUserAvatar(steamid)
			end
			nextCheckTime = SysTime() + 0.33
		end

	local expectedPath = "data/gtetris/avatars/frames/"..steamid..".png"
	local frame = parent:Add("DImage")
		frame:SetPos(x, y)
		frame:SetSize(w, h)
		frame.Think = function()
			if(isbot) then frame.Think = nil return end
			if(nextCheckTime > SysTime()) then return end
			if(file.Exists(expectedPath, "GAME")) then
				frame:SetImage(expectedPath)
				frame.Think = nil
				return
			else
				GTetris:GetUserAvatar(steamid)
			end
			nextCheckTime = SysTime() + 0.33
		end
end

function GTetris:PopupMenu(title, desc)
	local p = GTetris:CreatePanel(GTetris.Gui, 0, 0, ScrW(), ScrH(), Color(0, 0, 0, 0))
		p:SetZPos(32767)
		p.alpha = 0
		p.player = player
		p.clicked = false
		p:SetAlpha(p.alpha)
		local gap = ScreenScale(5)
		local tw, th = GTetris:GetTextSize("GTetris-MPTitle", title)
		p.Paint = function()
			if(!p.clicked) then
				p.alpha = math.Clamp(p.alpha + GTetris:GetFixedValue(20), 0, 255)
			else
				p.alpha = math.Clamp(p.alpha - GTetris:GetFixedValue(20), 0, 255)
				if(p.alpha <= 0) then
					p:Remove()
				end
			end
			draw.RoundedBox(0, 0, 0, p:GetWide(), p:GetTall(), Color(0, 0, 0, 200))
			p:SetAlpha(p.alpha)
		end
		function p:OnMousePressed(key)
			p.clicked = true
		end
		local inner = GTetris:CreatePanel(p, ScrW() * 0.33, ScrH() * 0.4, ScrW() * 0.33, ScrH() * 0.25, Color(50, 50, 50, 255))
		inner.oPaint = inner.Paint
		inner.Paint = function()
			inner.oPaint(inner)
			draw.DrawText(title, "GTetris-MPTitle", gap, gap, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT)

			draw.DrawText(desc, "GTetris-MPSettings", gap, gap + th + gap, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT)
		end
		local iw, ih = inner:GetSize()
		local buttonH = ih * 0.2
		local ok = GTetris:CreateButtonEasy(inner, 0, ih - buttonH, iw, buttonH + 1, "OK", Color(25, 25, 25, 255), Color(255, 255, 255, 255), function()
			p.clicked = true
		end)
end

function GTetris:GetMPValue(set, opt)
	if(set == nil) then
		return GTetris.CRoomData[opt]
	else
		return GTetris.CRoomData[set][opt]
	end
end

function GTetris:SetMPValue(set, opt, val)
	if(set == nil) then
		GTetris.CRoomData[opt] = val
	else
		GTetris.CRoomData[set][opt] = val
	end
	GTetris.UpdatingCRoomData = true
	GTetris.UpdatingCRoomDataTime = SysTime()

	GTetris:SyncCRoomData()
end

function GTetris:MP_InsertLine()
	local ow, oh = GTetris.PlayField.SettingsTab:GetSize()
	local f = GTetris:CreatePanel(GTetris.PlayField.SettingsTab, 0, 0, ow - gap * 2, line, Color(100, 100, 100, 255))
	f:Dock(TOP)
	f:DockMargin(gap, gap, gap, gap)
end

function GTetris:MP_InsertTitle(title)
	--GTetris:MP_InsertLine()
	local t = GTetris.PlayField.SettingsTab:Add("DLabel")
	local ow, oh = GTetris.PlayField.SettingsTab:GetSize()
	local w, h = GTetris:GetTextSize("GTetris-MPTitle", title)
	t:SetSize(w, h)
	t:SetText(title)
	t:SetFont("GTetris-MPTitle")
	t:SetTextColor(Color(200, 200, 200, 255))
	t:Dock(TOP)
	t:DockMargin(gap, gap, 0, 0)
end

function GTetris:MP_InsertButton(title, set, opt)
	local ow, oh = GTetris.PlayField.SettingsTab:GetSize()
	local f = GTetris:CreatePanel(GTetris.PlayField.SettingsTab, 0, 0, ow, oh, Color(0, 0, 0, 0))
	local w, h = GTetris:GetTextSize("GTetris-MPSettings", title)
		f:SetHeight(GTetris.PlayField.SettingsTab._h)
		f:Dock(TOP)
		local t = f:Add("DLabel")
		t:SetPos(gap, gap)
		t:SetSize(w, h)
		t:SetText(title)
		t:SetFont("GTetris-MPSettings")
		t:SetTextColor(Color(200, 200, 200, 255))
end

function GTetris:MP_InsertIntButton(title, set, opt, min, max, __step)
	local step = 1
	if(__step != nil) then
		step = __step
	end
	local ow, oh = GTetris.PlayField.SettingsTab:GetSize()
	local f = GTetris:CreatePanel(GTetris.PlayField.SettingsTab, 0, 0, ow, oh, Color(0, 0, 0, 0))
	local w, h = GTetris:GetTextSize("GTetris-MPSettings", title)
	f:SetHeight(GTetris.PlayField.SettingsTab._h)
	f:Dock(TOP)
	local baseX = gap
	local pButton = f:Add("DButton")
		pButton:SetPos(baseX, gap)
		pButton:SetSize(h, h)
		pButton:SetTextColor(Color(200 ,200 ,200 ,255))
		pButton:SetText("-")
		pButton:SetFont("GTetris-MPSettings")
		pButton.Paint = function()
			draw.RoundedBox(0, 0, 0, h, h, Color(80, 80, 80 ,255))
		end
		pButton.CurInc = 0
		pButton.CurRep = 0
		pButton.DAS = 0.25
		pButton.ARR = 0.05
		pButton.Think = function()
			if(pButton:IsHovered() && input.IsMouseDown(107)) then
				if(pButton.CurRep < SysTime()) then
					if(pButton.CurInc < SysTime()) then
						pButton.DoClick()
						pButton.CurInc = SysTime() + pButton.ARR
					end
				end
			else
				pButton.CurRep = SysTime() + pButton.DAS
			end
		end
		pButton.DoClick = function()
			local val = GTetris:GetMPValue(set, opt)

			if(val <= min) then return end
			GTetris:SetMPValue(set, opt, val - step)
		end
		baseX = baseX + h + gap
	local pButton = f:Add("DButton")
		pButton:SetPos(baseX, gap)
		pButton:SetSize(h, h)
		pButton:SetTextColor(Color(200 ,200 ,200 ,255))
		pButton:SetText("+")
		pButton:SetFont("GTetris-MPSettings")
		pButton.Paint = function()
			draw.RoundedBox(0, 0, 0, h, h, Color(80, 80, 80 ,255))
		end
		pButton.CurInc = 0
		pButton.CurRep = 0
		pButton.DAS = 0.25
		pButton.ARR = 0.05
		pButton.Think = function()
			if(pButton:IsHovered() && input.IsMouseDown(107)) then
				if(pButton.CurRep < SysTime()) then
					if(pButton.CurInc < SysTime()) then
						pButton.DoClick()
						pButton.CurInc = SysTime() + pButton.ARR
					end
				end
			else
				pButton.CurRep = SysTime() + pButton.DAS
			end
		end

		pButton.DoClick = function()
			local val = GTetris:GetMPValue(set, opt)

			if(val >= max) then return end
			GTetris:SetMPValue(set, opt, val + step)
		end
		local t = f:Add("DLabel")
		t:SetPos(baseX + h + gap, gap)
		t:SetSize(w, h)
		t:SetText(title)
		t:SetFont("GTetris-MPSettings")
		t:SetTextColor(Color(200, 200, 200, 255))
		t.Think = function()
			local val = GTetris:GetMPValue(set, opt)
			local str = title.." : "..math.Round(val, 3)
			local w, h = GTetris:GetTextSize("GTetris-MPSettings", str)
			t:SetSize(w, h)
			t:SetText(str)
		end
end

function GTetris:MP_InsertTextbox(title, set, opt)
	local ow, oh = GTetris.PlayField.SettingsTab:GetSize()
	local f = GTetris:CreatePanel(GTetris.PlayField.SettingsTab, 0, 0, ow, oh, Color(0, 0, 0, 0))
	local w, h = GTetris:GetTextSize("GTetris-MPSettings", title)
	local val = GTetris:GetMPValue(set, opt)
		f:SetHeight(GTetris.PlayField.SettingsTab._h)
		f:Dock(TOP)
		local t = f:Add("DLabel")
		t:SetPos(gap, gap)
		t:SetSize(w, h)
		t:SetText(title)
		t:SetFont("GTetris-MPSettings")
		t:SetTextColor(Color(200, 200, 200, 255))

		local tb = f:Add("DTextEntry")
			tb:SetSize(ow - (w + gap * 4), h)
			tb:SetPos(w + gap * 2, gap)
			tb:SetTextColor(Color(200, 200, 200, 255))
			tb:SetPaintBackground(false)
			tb:SetValue(val)
			tb:SetFont("GTetris-MPSettings")
			tb.oPaint = tb.Paint
			tb.Paint = function()
				draw.RoundedBox(0, 0, 0, tb:GetWide(), tb:GetTall(), Color(20, 20, 20, 255))
				tb.oPaint(tb)
			end

			function tb:OnChange(val)
				GTetris:SetMPValue(set, opt, tb:GetValue())
			end
end

function GTetris:MP_InsertStringButton(title, set, opt, val)
	local ow, oh = GTetris.PlayField.SettingsTab:GetSize()
	local f = GTetris:CreatePanel(GTetris.PlayField.SettingsTab, 0, 0, ow, oh, Color(0, 0, 0, 0))
	local w, h = GTetris:GetTextSize("GTetris-MPSettings", title)
	local _h = GTetris.PlayField.SettingsTab._h
	local gap = _h * 0.2
	local sx = _h * 0.5
	local sxp = (_h - sx) - sx / 2
		f:SetHeight(_h)
		f:Dock(TOP)
		f.Paint = function()
			local _val = GTetris:GetMPValue(set, opt)
			if(_val == val) then
				draw.RoundedBox(0, gap, sxp, sx, sx, Color(255, 255, 255, 255))
			end
			surface.SetDrawColor(255, 255, 255, 255)
			surface.DrawOutlinedRect(gap, sxp, sx, sx, line)
		end
		local t = f:Add("DLabel")
		t:SetPos(gap * 2 + sx, gap)
		t:SetSize(w, h)
		t:SetText(title)
		t:SetFont("GTetris-MPSettings")
		t:SetTextColor(Color(200, 200, 200, 255))
		local btn = f:Add("DButton")
			btn:SetSize(ow, _h)
			btn:SetText("")
			btn.Paint = function() end
			btn.DoClick = function()
				GTetris:SetMPValue(set, opt, val)
			end
end

function GTetris:DisplayPlayerOptions(player, fetchid)
	local p = GTetris:CreatePanel(GTetris.Gui, 0, 0, ScrW(), ScrH(), Color(0, 0, 0, 0))
		p:SetZPos(32767)
		p.alpha = 0
		p.player = player
		p.clicked = false
		p:SetAlpha(p.alpha)
		p.Paint = function()
			if(!p.clicked) then
				p.alpha = math.Clamp(p.alpha + GTetris:GetFixedValue(20), 0, 255)
			else
				p.alpha = math.Clamp(p.alpha - GTetris:GetFixedValue(20), 0, 255)
				if(p.alpha <= 0) then
					p:Remove()
				end
			end
			draw.RoundedBox(0, 0, 0, p:GetWide(), p:GetTall(), Color(0, 0, 0, 200))
			p:SetAlpha(p.alpha)
		end
		function p:OnMousePressed(key)
			p.clicked = true
		end
		local inner = GTetris:CreatePanel(p, ScrW() * 0.25, ScrH() * 0.4, ScrW() * 0.5, ScrH() * 0.2, Color(50, 50, 50, 255))
		local iw, ih = inner:GetSize()
		inner.alpha = 0
		local steamid = 0
		local name, apm, pps, match = "FETCHING PLAYER DATA..", 0, 0, 0
		local fromweb = false
		local error = true
		if(fetchid == nil && IsValid(player)) then
			steamid = player:SteamID64()
			name = player:Nick()
		else
			steamid = fetchid
			fromweb = true
		end
		if(steamid == nil) then steamid = 0 end
		
		local gap = ScreenScale(5)
		local sx = ih * 0.5
		if(fromweb) then

		else
			local avatar = inner:Add("AvatarImage")
				avatar:SetSize(sx, sx)
				avatar:SetPos(gap, gap)
				avatar:SetPlayer(player, 128)
		end

		local nameframe = GTetris:CreatePanel(inner, gap * 2 + sx, gap, iw, ih, Color(0, 0, 0, 0))
			nameframe.Paint = function()
				draw.DrawText(name, "GTetris-ProfileName", 0, 0, Color(255 ,255 ,255 ,255), TEXT_AN_LEFLIGT)
			end
		local dummyFunc = function() end
		local buttonH = ih * 0.25
		local buttonW = iw * 0.5
		local gap = ScreenScale(1)
		if(GTetris.CurrentCommID != "?") then
			if(GTetris:IsRoomHost() && player != LocalPlayer()) then
				local kick = GTetris:CreateButtonEasy(inner, 0, ih - buttonH, buttonW - gap, buttonH + 1, "Kick", Color(25, 25, 25, 255), Color(255, 150, 40, 255), function()
					GTetris:KickPlayer(player)
					p.clicked = true
				end)
				local ban = GTetris:CreateButtonEasy(inner, buttonW + gap, ih - buttonH, buttonW + gap, buttonH + 1, "Ban", Color(25, 25, 25, 255), Color(255, 100, 100, 255), function()
					GTetris:BanPlayer(player)
					p.clicked = true
				end)
			else
				local kick = GTetris:CreateButtonEasy(inner, 0, ih - buttonH, buttonW - gap, buttonH + 1, "Kick", Color(25, 25, 25, 105), Color(255, 150, 40, 105), dummyFunc)
				local ban = GTetris:CreateButtonEasy(inner, buttonW + gap, ih - buttonH, buttonW + gap, buttonH + 1, "Ban", Color(25, 25, 25, 105), Color(255, 100, 100, 105), dummyFunc)
			end
		end
		local gap4x = gap * 4
		local gap2x = gap * 2

		local tw, th = GTetris:GetTextSize("GTetris-ProfileText", "DummyText")


		local fetching = true
		http.Fetch("https://gtetris.gmaniaserv.xyz/gtetris/profile/"..steamid..".gpf",
			function(body, length, headers, code)
				if(code == 404) then
					error = true
					if(fromweb) then
						name = "NON-EXISTING PLAYER"
					end
				else

				end
				fetching = false
			end,
			function(message)
				if(!fromweb) then return end
				fetching = false
				error = true
				name = "ERROR FETCHING PLAYER DATA"
			end,
			{}
			)
end

function GTetris:EasyLabel(parent, x, y, text, font, color)
	local w, h = GTetris:GetTextSize(font, text)
	local d = parent:Add("DLabel")
		d:SetPos(x, y)
		d:SetSize(w, h)
		d:SetText(text)
		d:SetTextColor(color)
		d:SetFont(font)

	return w, h, d
end

function GTetris:EasyTextEntry(parent, x, y, w, h, font, defaultvar)
	local t = parent:Add("DTextEntry")
		t:SetPos(x, y)
		t:SetSize(w, h)
		t:SetFont(font)
		t:SetValue(defaultvar)

		t:SetTextColor(Color(255, 255, 255, 255))
		t:SetPaintBackground(false)

		t.oPaint = t.Paint

		t.Paint = function()
			draw.RoundedBox(0, 0, 0, w, h, Color(40, 40, 40, 255))
			t.oPaint(t)
		end

		return t
end

function GTetris:EasySlider(parent, x, y, w, h, min, max, var, font)
	local p = parent:Add("DPanel")
		p:SetPos(x, y)
		p:SetSize(w, h)
		p.Paint = function() end

		local var = var

		local gap = ScreenScale(3)

		local size = parent:GetWide() * 0.1
		local displayVar = p:Add("DPanel")
		displayVar:SetPos(w - size)
		displayVar:SetSize(size, h)

		displayVar.Paint = function()
			draw.RoundedBox(0, 0, 0, size, h, Color(30, 30, 30, 255))
		end

		local tw, th, varLabel = GTetris:EasyLabel(displayVar, size / 2, 0, var, "GTetris-BotSubTitle", Color(255, 255, 255, 255))
		varLabel:SetPos(math.abs(tw - size) / 2, math.abs(th - h) / 2)

		local slider = p:Add("DPanel")
			slider:SetSize(w - (size + gap), h)

			slider.Paint = function()
				draw.RoundedBox(0, 0, 0, slider:GetWide(), h, Color(30, 30, 30, 255))

				draw.RoundedBox(0, 0, (h / 2) - 1, slider:GetWide(), 2, Color(80, 80, 80, 255))

				local tall = slider:GetTall()
				local pos = (var / max) * slider:GetWide()
				tw, th = GTetris:GetTextSize("GTetris-BotSubTitle", var)
				varLabel:SetWide(tw)
				varLabel:SetPos(math.abs(tw - size) / 2)
				draw.RoundedBox(0, pos, (h / 2) - tall / 2, gap, tall, Color(80, 80, 80, 255))

				if(slider:IsHovered() && input.IsMouseDown(107)) then
					local cx, cy = slider:CursorPos()
					local newvar = cx / slider:GetWide()

					var = math.Round(math.Clamp(max * newvar, min, max), 1)
				end

				varLabel:SetText(var)
			end

			function slider:GTetrisGetVar()
				return var
			end
	return slider
end

function GTetris:EasyButton(parent, x, y, w, h, font, var)
	local p = parent:Add("DPanel")
		p:SetPos(x, y)
		p:SetSize(w, h)
		p.Paint = function() end

		local var = var

		local gap = ScreenScale(2)

		local switchSize = parent:GetWide() * 0.1
		local nextX = 0
		nextX = nextX + switchSize + gap
		local btn = p:Add("DButton")
			btn:SetX(0)
			btn:SetText("ON")
			btn:SetFont("GTetris-BotSubTitle")
			btn:SetSize(switchSize, h)
			btn:SetTextColor(Color(255, 255, 255, 255))
			btn.Paint = function()
				if(var) then
					draw.RoundedBox(0, 0, 0, switchSize, h, Color(40, 40, 40, 255))
					btn:SetTextColor(Color(255, 255, 255, 255))
				else
					draw.RoundedBox(0, 0, 0, switchSize, h, Color(20, 20, 20, 255))
					btn:SetTextColor(Color(105, 105, 105, 255))
				end
			end
btn.DoClick = function() var = true end
		local btn = p:Add("DButton")
			btn:SetX(nextX)
			btn:SetText("OFF")
			btn:SetFont("GTetris-BotSubTitle")
			btn:SetSize(switchSize, h)
			btn:SetTextColor(Color(255, 255, 255, 255))
			btn.Paint = function()
				if(!var) then
					draw.RoundedBox(0, 0, 0, switchSize, h, Color(40, 40, 40, 255))
					btn:SetTextColor(Color(255, 255, 255, 255))
				else
					draw.RoundedBox(0, 0, 0, switchSize, h, Color(20, 20, 20, 255))
					btn:SetTextColor(Color(105, 105, 105, 255))
				end
			end
			btn.DoClick = function() var = false end

			function p:GTetrisGetVar()
				return var
			end

	return p
end

function GTetris:CreateTypeSelection(parent, x, y, w, h, type)
	local p = parent:Add("DPanel")
		p:SetPos(x, y)
		p:SetSize(w, h)
		p.Paint = function() end

		local switchSize = parent:GetWide() * 0.05
		local nextX = 0

		local tw, th = GTetris:GetTextSize("GTetris-BotSubTitle", "DummyText")

		local index = 1
		local CSelection = type[index]

		nextX = nextX + switchSize
		local size = parent:GetWide() * 0.2
		local cnt = p:Add("DPanel")
			cnt:SetX(nextX)
			cnt:SetSize(size, h)
			cnt.Paint = function()
				draw.RoundedBox(0, 0, 0, size, h, Color(30, 30, 30, 255))
				draw.DrawText(CSelection, "GTetris-BotSubTitle", size / 2, math.abs(h - th) / 2, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)
			end

		local btn = p:Add("DButton")
			btn:SetX(0)
			btn:SetText("<")
			btn:SetFont("GTetris-BotSubTitle")
			btn:SetSize(switchSize, h)
			btn:SetTextColor(Color(255, 255, 255, 255))
			btn.Paint = function()
				draw.RoundedBox(0, 0, 0, switchSize, h, Color(40, 40, 40, 255))
			end
		nextX = nextX + size
		local btn = p:Add("DButton")
			btn:SetX(nextX)
			btn:SetText(">")
			btn:SetFont("GTetris-BotSubTitle")
			btn:SetSize(switchSize, h)
			btn:SetTextColor(Color(255, 255, 255, 255))
			btn.Paint = function()
				draw.RoundedBox(0, 0, 0, switchSize, h, Color(40, 40, 40, 255))
			end

		function p:GTetrisGetVar()
			return CSelection
		end

	return p
end

function GTetris:BotSelectionTab()
	local p = GTetris:CreatePanel(GTetris.Gui, 0, 0, ScrW(), ScrH(), Color(0, 0, 0, 0))
		p:SetZPos(32767)
		p.alpha = 0
		p.player = player
		p.clicked = false
		p:SetAlpha(p.alpha)
		p.Paint = function()
			if(!p.clicked) then
				p.alpha = math.Clamp(p.alpha + GTetris:GetFixedValue(20), 0, 255)
			else
				p.alpha = math.Clamp(p.alpha - GTetris:GetFixedValue(20), 0, 255)
				if(p.alpha <= 0) then
					p:Remove()
				end
			end
			draw.RoundedBox(0, 0, 0, p:GetWide(), p:GetTall(), Color(0, 0, 0, 200))
			p:SetAlpha(p.alpha)
		end
		function p:OnMousePressed(key)
			p.clicked = true
		end
		local inner = GTetris:CreatePanel(p, ScrW() * 0.3, ScrH() * 0.33, ScrW() * 0.4, ScrH() * 0.33, Color(50, 50, 50, 255))
		local iw, ih = inner:GetSize()
		local buttonH = ih * 0.15
		local gap = ScreenScale(3)
		local ngap = ScreenScale(5)
		local sidegap = iw * 0.02
		
		local defaultName = "MeirBot"
		local eHeight = ih * 0.4
		local nextY = ih * 0.04
		local tw, th = GTetris:EasyLabel(inner, sidegap, nextY, "Name", "GTetris-BotTitle", Color(255, 255, 255, 255))
		local tent = GTetris:EasyTextEntry(inner, sidegap + tw + gap, nextY, iw - (sidegap + tw + gap * 2), th, "GTetris-BotTitle", defaultName)
		nextY = nextY + ngap + th
		local tw, th = GTetris:EasyLabel(inner, sidegap, nextY, "PPS", "GTetris-BotTitle", Color(255, 255, 255, 255))
		local pps = 2.5
		local slider = GTetris:EasySlider(inner, sidegap + tw + gap, nextY, iw - (sidegap + tw + gap * 2), th, 0.1, 20, pps, "GTetris-BotTitle")
		local bot_type = {"MeirBot"}
		nextY = nextY + ngap + th
		local tw, th = GTetris:EasyLabel(inner, sidegap, nextY, "Bot Type", "GTetris-BotTitle", Color(255, 255, 255, 255))
		local sel = GTetris:CreateTypeSelection(inner, sidegap + tw + gap, nextY, iw - (sidegap + tw + gap * 2), th, bot_type)
		nextY = nextY + ngap + th
		local tspin = true
		local tw, th = GTetris:EasyLabel(inner, sidegap, nextY, "T-Spins [Experimental]", "GTetris-BotTitle", Color(255, 255, 255, 255))
		local tbtn = GTetris:EasyButton(inner, sidegap + tw + gap, nextY, iw - (sidegap + tw + gap * 2), th, "GTetris-BotTitle", tspin)

		GTetris:EasyLabel(inner, sidegap, ih * 0.675, "Bot's logic processing could affect your game's performance\nDepends on it's PPS and amount", "GTetris-BotSubTitle", Color(255, 125, 125, 255))
		GTetris:CreateButtonEasy(inner, 0, ih - buttonH, iw, buttonH + 1, "ADD BOT", Color(25, 25, 25, 255), Color(255, 255, 255, 255), function()
			
			local name = tent:GetValue()
			local pps = slider:GTetrisGetVar()
			local type = sel:GTetrisGetVar()
			local tspin = tbtn:GTetrisGetVar()
			
			net.Start("GTetris-AddBot")
			net.WriteString(GTetris.CurrentCommID)
			net.WriteString(name)
			net.WriteString(type)
			net.WriteFloat(pps)
			net.WriteBool(tspin)
			net.SendToServer()

			p.clicked = true
		end)
end

function GTetris:CreateAddBotButton(parent)
	local w, h = parent:GetWide(), parent:GetTall()
	local btnW, btnH = w, h * 0.1
	local gap = ScreenScale(2)
	local btn = parent:Add("DButton")
		btn:SetZPos(32767)
		btn:SetSize(btnW - gap * 2, btnH - gap * 2)
		btn:SetPos(gap, h - btnH)
		btn:SetText("ADD BOT")
		btn:SetTextColor(Color(255, 255, 255, 255))
		btn:SetFont("GTetris-MPTitle")

		btn.Paint = function()
			if(!GTetris:IsRoomHost()) then
				draw.RoundedBox(0, 0, 0, btnW, btnH, Color(40, 40, 40, 255))
				btn:SetTextColor(Color(85, 85, 85, 255))
			else
				draw.RoundedBox(0, 0, 0, btnW, btnH, Color(70, 70, 70, 255))
				btn:SetTextColor(Color(255, 255, 255, 255))
			end
		end

	btn.DoClick = function()
		if(!GTetris:IsRoomHost()) then return end
		GTetris:BotSelectionTab()
	end
end

function GTetris:LoadPlayerlist()
	local gap = ScreenScale(3)
	local w, h = GTetris.PlayField:GetWide() * 0.25, GTetris.PlayField.Playerlist:GetTall() * 0.085
	GTetris:CreateAddBotButton(GTetris.PlayField.Playerlist)
	for k,v in next, GTetris.CRoomData.Players do
		local ply = Entity(v)
		if(!IsValid(ply)) then continue end
		local f = GTetris:CreatePanel(GTetris.PlayField.Playerlist, 0, 0, GTetris.PlayField.Playerlist:GetWide(), GTetris.PlayField.Playerlist:GetTall() * 0.085, Color(25, 25, 25, 255))
		local fw, fh = f:GetSize()
		local tw, th = GTetris:GetTextSize("TargetID", "HOST")
		tw, th = tw, th
		f.Paint = function()
			draw.RoundedBox(0, 0, 0, fw, fh, Color(25, 25, 25, 255))
		end
		f:Dock(TOP)
		f:DockMargin(0, gap, 0, 0)
		local avatar = vgui.Create("AvatarImage", f)
			avatar:SetSize(h, h)
			avatar:SetPos(0, 0)
			avatar:SetPlayer(ply, 64)
			local _w, _h = GTetris:GetTextSize("GTetris-TabScrollTextSubTitle", ply:Nick())
			local nick = ply:Nick()
			local name = f:Add("DLabel")
				name:SetPos(h + gap, gap)
				name:SetText(nick)
				name:SetSize(_w, _h)
				name:SetFont("GTetris-TabScrollTextSubTitle")
				name:SetTextColor(Color(255, 255, 255, 255))
				name.Think = function()
					if(v == GTetris.CRoomData.Host) then
						local t = nick.." [HOST]"
						name:SetText(t)
						local _w, _h = GTetris:GetTextSize("GTetris-TabScrollTextSubTitle", t)
						name:SetSize(_w, _h)
					else
						name:SetText(nick)
					end
				end
				local btn = f:Add("DButton")
					btn:SetSize(w, h)
					btn:SetText("")
					btn.Paint = function() end
					btn.DoClick = function()
						GTetris:DisplayPlayerOptions(ply)
					end
	end
	for k,v in next, GTetris.CRoomData.Bots do
		local f = GTetris:CreatePanel(GTetris.PlayField.Playerlist, 0, 0, GTetris.PlayField.Playerlist:GetWide(), GTetris.PlayField.Playerlist:GetTall() * 0.085, Color(25, 25, 25, 255))
		local fw, fh = f:GetSize()
		local tw, th = GTetris:GetTextSize("TargetID", "HOST")
		tw, th = tw, th
		f.Paint = function()
			draw.RoundedBox(0, 0, 0, fw, fh, Color(25, 25, 25, 255))
		end
		f:Dock(TOP)
		f:DockMargin(0, gap, 0, 0)
		local avatar = vgui.Create("DImage", f)
			avatar:SetSize(h, h)
			avatar:SetPos(0, 0)
			avatar:SetImage("gtetris/internal/bot.png")
			local _w, _h = GTetris:GetTextSize("GTetris-TabScrollTextSubTitle", v.name)
			local nick = v.name
			local name = f:Add("DLabel")
				name:SetPos(h + gap, gap)
				name:SetText(nick)
				name:SetSize(_w, _h)
				name:SetFont("GTetris-TabScrollTextSubTitle")
				name:SetTextColor(Color(255, 255, 255, 255))
				local btn = f:Add("DButton")
					btn:SetSize(w, h)
					btn:SetText("")
					btn.Paint = function()
					local str = v.name
					if(btn:IsHovered()) then
						str = "REMOVE BOT"
					end
						local _w, _h = GTetris:GetTextSize("GTetris-TabScrollTextSubTitle", str)
						name:SetText(str)
						name:SetSize(_w, _h)
					end
					btn.DoClick = function()
						net.Start("GTetris-RemoveBot")
						net.WriteString(GTetris.CurrentCommID)
						net.WriteString(k)
						net.SendToServer()
					end
	end
end

function GTetris:CreateOnlineButton(index, title, func)
	local w, h = GTetris:GetTextSize("GTetris-OptionsTitle", title)
	local b = vgui.Create("DButton", GTetris.OnlineUI)
	local size = math.floor(ScrW() * 0.175)
	b:SetSize(size, ScrH() * 0.06)
	b:SetX((index - 1) * size)
	b:SetText(title)
	b:SetFont("GTetris-OptionsTitle")
	b:SetTextColor(Color(255, 255, 255, 255))

	b.Paint = function()
		if(GTetris.CurrentOnlineOption == title) then
			draw.RoundedBox(0, 0, 0, b:GetWide(), b:GetTall(), Color(60, 60, 60, 255))
		else
			draw.RoundedBox(0, 0, 0, b:GetWide(), b:GetTall(), Color(40, 40, 40, 255))
		end
	end

	b.DoClick = function()
		GTetris.CurrentOnlineOption = title
		func()
	end

	if(index == 1) then
		b.DoClick()
	end
end

surface.CreateFont("GTetris-BannerDetails", {
	font = "Arial",
	extended = false,
	size = ScreenScale(8),
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
})

surface.CreateFont("GTetris-BannerTime", {
	font = "Arial",
	extended = false,
	size = ScrH() * 0.05,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
})

surface.CreateFont("GTetris-PlayerDetails", {
	font = "Arial",
	extended = false,
	size = ScreenScale(10),
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
})

function GTetris:MENU_InsertLine(parent)
	local ow, oh = parent:GetSize()
	local f = GTetris:CreatePanel(parent, 0, 0, ow - gap * 2, line, Color(100, 100, 100, 255))
	f:Dock(TOP)
	f:DockMargin(gap, gap, gap, gap)
end

function GTetris:MENU_InsertTitle(parent, title)
	if(title == nil) then title = "UNDEFINED" end
	--GTetris:MP_InsertLine()
	local t = parent:Add("DLabel")
	local ow, oh = parent:GetSize()
	local w, h = GTetris:GetTextSize("GTetris-MPTitle", title)
	t:SetSize(w, h)
	t:SetText(title)
	t:SetFont("GTetris-MPTitle")
	t:SetTextColor(Color(200, 200, 200, 255))
	t:Dock(TOP)
	t:DockMargin(gap, gap / 2, 0, 0)
end

function GTetris:MENU_InsertDesc(parent, title, conc)
	if(conc == nil) then conc = "UNDEFINED" end
	title = title.." : "..conc
	--GTetris:MP_InsertLine()
	local t = parent:Add("DLabel")
	local ow, oh = parent:GetSize()
	local w, h = GTetris:GetTextSize("GTetris-MPSettings", title)
	t:SetSize(w, h)
	t:SetText(title)
	t:SetFont("GTetris-MPSettings")
	t:SetTextColor(Color(200, 200, 200, 255))
	t:Dock(TOP)
	t:DockMargin(gap, gap / 2, 0, 0)
end

local varCorrection = {
	["ALL"] = "ALL SPINS",
	["Meiryi"] = "MULTIPLIER",
	["SRS-Meiryi"] = "SRS+",
	["RAND"] = "COMPLETEY RANDOM",
}

function GTetris:CorrectVars(var)
	if(varCorrection[var]) then return varCorrection[var] end
	return var
end

function GTetris:GetMatchDetails(inx, idx)
	http.Fetch("https://gtetris.gmaniaserv.xyz/gtetris/historygroup/"..inx.."/"..idx..".gmx",

		function(body, length, headers, code)
			GTetris:APIRespond()
			if(code == 404) then
				GTetris:PopupMenu("REQUEST FAILED", "CANNOT GET REQUESTED MATCH DATA (404)")
			else

				local data = util.JSONToTable(body)
				if(!data) then GTetris:PopupMenu("ERROR", "INVALID MATCH DATA RECEIVED") return end
				local p = GTetris:CreatePanel(GTetris.Gui, 0, 0, ScrW(), ScrH(), Color(0, 0, 0, 0))
					p:SetZPos(32767)
					p.alpha = 0
					p.player = player
					p.clicked = false
					p:SetAlpha(p.alpha)
					local gap = ScreenScale(5)
					p.Paint = function()
						if(!p.clicked) then
							p.alpha = math.Clamp(p.alpha + GTetris:GetFixedValue(20), 0, 255)
						else
							p.alpha = math.Clamp(p.alpha - GTetris:GetFixedValue(20), 0, 255)
							if(p.alpha <= 0) then
								p:Remove()
							end
						end
						draw.RoundedBox(0, 0, 0, p:GetWide(), p:GetTall(), Color(0, 0, 0, 200))
						p:SetAlpha(p.alpha)
					end
					function p:OnMousePressed(key)
						p.clicked = true
					end
					local inner = GTetris:CreatePanel(p, ScrW() * 0.15, ScrH() * 0.1, ScrW() * 0.7, ScrH() * 0.8, Color(45, 45, 45, 255))
					local iw, ih = inner:GetSize()
					local gap = ScreenScale(3)
					local listHeight = ih * 0.5
					local settingsHeight = ih * 0.45

					local settingsList = GTetris:CreateScroll(inner, gap, gap, iw - gap * 2, settingsHeight, Color(30, 30, 30, 255))
					local rset = data.RoomDetails
					GTetris:MENU_InsertTitle(settingsList, "GENERAL")
					GTetris:MENU_InsertLine(settingsList)
					GTetris:MENU_InsertDesc(settingsList, "ROOM NAME", rset.RoomName)
					GTetris:MENU_InsertDesc(settingsList, "MAX PLAYERS", rset.PlayerLimit )

					GTetris:MENU_InsertTitle(settingsList, "GAMEPLAY")
					GTetris:MENU_InsertLine(settingsList)
					GTetris:MENU_InsertDesc(settingsList, "COLUMNS", rset.Cols)
					GTetris:MENU_InsertDesc(settingsList, "ROWS", rset.Rows)
					GTetris:MENU_InsertDesc(settingsList, "SPINS", rset.Spins)
					GTetris:MENU_InsertDesc(settingsList, "COMBO", GTetris:CorrectVars(rset.ComboTable))
					GTetris:MENU_InsertDesc(settingsList, "GRAVITY", rset.GravityInterval)
					GTetris:MENU_InsertDesc(settingsList, "ROTATION SYSTEM", GTetris:CorrectVars(rset.RotationSystem))
					GTetris:MENU_InsertDesc(settingsList, "AUTOLOCK TIME", rset.TargetLockTimer)
					GTetris:MENU_InsertDesc(settingsList, "PIECE GENERATION", GTetris:CorrectVars(rset.BagSystem))

					GTetris:MENU_InsertTitle(settingsList, "GARBAGE")
					GTetris:MENU_InsertLine(settingsList)
					GTetris:MENU_InsertDesc(settingsList, "GARBAGE CAP", rset.GarbageCap)
					GTetris:MENU_InsertDesc(settingsList, "GARBAGE SCALING", rset.GarbageScaling)
					GTetris:MENU_InsertDesc(settingsList, "GARBAGE ARRIVE DELAY", rset.GarbageArriveDelay)
					GTetris:MENU_InsertDesc(settingsList, "GARBAGE APPLY DELAY", rset.GarbageApplyDelay)

					local playerList = GTetris:CreateScroll(inner, gap, ih - (listHeight + gap), iw - gap * 2, listHeight, Color(30, 30, 30, 255))
					local t = {}
					for k,v in next, data.PlayerDetails do
						table.insert(t, v) -- so it can sort
					end

					table.sort(t, function(a, b) return a.surivivetime > b.surivivetime end)
					local w, h = playerList:GetSize()
					local ph = h * 0.2
					for k,v in next, t do

						local pbase = playerList:Add("DPanel")
						pbase:SetSize(w, ph)
						pbase:Dock(TOP)
						pbase:DockMargin(0, 0, 0, gap)

						pbase.Paint = function()
							draw.RoundedBox(0, 0, 0, w, h, Color(20, 20, 20, 255))
						end
						local namestr = v.name
						if(v.isbot == "yes") then namestr = namestr.." [BOT]" end

						local ntw, nth, label = GTetris:EasyLabel(pbase, gap, gap, "##"..k, "GTetris-MPTitle", Color(255, 255, 255, 255))
						label:SetY((ph - nth) / 2)
						GTetris:EasyWebAvatar(pbase, ntw, 0, ph, ph, v.steamid, false)
						local tw, th = GTetris:EasyLabel(pbase, ntw + gap * 2 + ph, gap, namestr, "GTetris-MPTitle", Color(255, 255, 255, 255))
						local tw, th = GTetris:EasyLabel(pbase, ntw + gap * 2 + ph, gap + th, "PPS : "..v.pps.."   APM : "..v.apm.."   GARBAGE SENT : "..v.sent, "GTetris-PlayerDetails", Color(255, 255, 255, 255))

						local str = v.surivivetime
						if(k == 1) then
							str = "WINNER"
						end
						local tw, th, label = GTetris:EasyLabel(pbase, 0, 0, str, "GTetris-BannerTime", Color(255, 255, 255, 255))
						label:SetPos(w - (tw + gap), (ph - th) / 2)
					end
			end
		end,

		function(message)
			
		end
	)
end

function GTetris:CreateMatchBanner(ctx)
	if(!IsValid(GTetris.OnlineUI) || !IsValid(GTetris.OnlineUI.Lower.List)) then return end
	local ret = string.Explode(":", ctx)	--$ret["Host"].":".$ret["Time"].":".$count.":".$content.":".$date.":".$currentINX.":".$ret["HostSteamID"];
	for i = 1, 5 do if(!ret[i]) then return end end

	local w, h = GTetris.OnlineUI.Lower.List:GetWide(), ScrH() * 0.08
	local gap = ScreenScale(2)
	local p = GTetris.OnlineUI.Lower.List:Add("DPanel")
		p:SetSize(w, h)
		p:Dock(TOP)
		p:DockMargin(0, 0, 0, gap)

		p.Paint = function()
			draw.RoundedBox(0, 0, 0, w, h, Color(25, 25, 25, 255))
		end

		local titlestr = "MATCH HOSTED BY "..ret[1]
		local datestr = "PLAYED ON "..ret[5]..", "..ret[3].." PLAYERS"
		GTetris:EasyWebAvatar(p, 0, 0, h, h, ret[7], false)
		local tw, th = GTetris:EasyLabel(p, gap + h, gap, titlestr, "GTetris-MPTitle", Color(255, 255, 255, 255))
		local tw, th = GTetris:EasyLabel(p, gap + h, gap + th, datestr, "GTetris-BannerDetails", Color(255, 255, 255, 255))

		local time = math.Round(tonumber(ret[2]), 3)
		local tw, th = GTetris:GetTextSize("GTetris-BannerTime", time)
		local timelabel = p:Add("DLabel")
		timelabel:SetPos(w - (tw + gap * 4), (h - th) / 2)
		timelabel:SetFont("GTetris-BannerTime")
		timelabel:SetSize(tw, th)
		timelabel:SetTextColor(Color(255, 255, 255, 255))
		timelabel:SetText(time)

		local btn = p:Add("DButton")
			btn:SetSize(w, h)
			btn:SetText("")
			btn.Paint = function() end

			btn.DoClick = function()
				GTetris:WaitingAPIScreen()
				GTetris:GetMatchDetails(ret[6], ret[4])
			end
end

function GTetris:FetchHistory(inx, idx)
	local content = ""
	http.Fetch("https://gtetris.gmaniaserv.xyz/gtetris/historygroup/"..inx.."/fetch.ftx",
		function(body, length, headers, code)
			content = body

			if(GTetris.TotalRequests >= 2 && idx == 1 && GTetris.CurrentRequested == 1) then
				GTetris.ReturnedContent = GTetris.ReturnedContent..content
			else
				GTetris.ReturnedContent = content..GTetris.ReturnedContent
			end

			GTetris.CurrentRequested = GTetris.CurrentRequested + 1

			if(GTetris.CurrentRequested >= GTetris.TotalRequests) then
				GTetris:APIRespond()
				local ctx = string.Explode("\n", GTetris.ReturnedContent)
				ctx[#ctx] = nil
				ctx = table.Reverse(ctx)
				for k,v in next, ctx do
					GTetris:CreateMatchBanner(v)
				end
			end
		end,
		function(message)
	end)
	return content
end

function GTetris:BuildOnlineUI()
	if(IsValid(GTetris.OnlineUI)) then
		GTetris.OnlineUI:Remove()
	end

	GTetris.CurrentOnlineOption = "?"

	GTetris.OnlineUI = GTetris:CreatePanel(GTetris.Gui, ScrW() * 0.1, ScrH() * 0.075, ScrW() * 0.8, ScrH() * 0.85, Color(40, 40, 40, 255))

	local upperHeight = ScrH() * 0.06
	GTetris.OnlineUI.Lower = GTetris:CreatePanel(GTetris.OnlineUI, 0, upperHeight, GTetris.OnlineUI:GetWide(), GTetris.OnlineUI:GetTall() - upperHeight, Color(60, 60, 60, 255))
	--GTetris.OnlineUI.Lower = GTetris:CreateScroll(GTetris.OnlineUI, 0, upperHeight, GTetris.OnlineUI:GetWide(), GTetris.OnlineUI:GetTall() - upperHeight, Color(60, 60, 60, 255))
	local lw, lh = GTetris.OnlineUI.Lower:GetSize()
	local pad = ScreenScale(3)
	local pad2x = pad * 2
	local options = {
		--[[
		{"MATCHMAKING", function()
			GTetris.OnlineUI.Lower:Clear()
			local bw = lw * 0.5
			local QueueButton = GTetris:CreateButtonEasy(GTetris.OnlineUI.Lower, (lw * 0.5) / 2, lh * 0.35, bw, lh * 0.1, "Enter Matchmaking", Color(40, 40, 40, 255), Color(250, 250, 250, 255), function()

			end)
		end},
		]]
		{"ROOMS", function()
			GTetris.OnlineUI.Lower:Clear()
			local upperHeight = ScrH() * 0.06
			local gap = ScreenScale(5)
			local topgap = ScrH() * 0.15
			GTetris.OnlineUI.Lower.List = GTetris:CreateScroll(GTetris.OnlineUI.Lower, gap, upperHeight + topgap, GTetris.OnlineUI.Lower:GetWide() - gap * 2, GTetris.OnlineUI.Lower:GetTall() - (upperHeight + topgap + gap), Color(40, 40, 40, 255))

			local btnwide = ScrW() * 0.15
			local topscl = 0.85
			local createbtn = GTetris:CreateButtonEasy(GTetris.OnlineUI.Lower, gap, topgap * topscl, btnwide, upperHeight, "Create Room", Color(20, 20, 20, 255), Color(255, 255, 255, 255), function()
				net.Start("GTetris-CreateRoom")
				net.SendToServer()
				GTetris:WaitingScreen(function()
						
				end)
			end)

			local refreshbtn = GTetris:CreateButtonEasy(GTetris.OnlineUI.Lower, gap + btnwide + ScreenScale(2), topgap * topscl, btnwide, upperHeight, "Refresh", Color(20, 20, 20, 255), Color(255, 255, 255, 255), function()
				GTetris:FetchRooms()
			end)

			GTetris:FetchRooms()
		end},
		{"MATCH HISTORY", function()
			local upperHeight = ScrH() * 0.06
			local gap = ScreenScale(5)
			local topgap = ScrH() * 0.06
			GTetris.OnlineUI.Lower:Clear()
			GTetris.OnlineUI.Lower.List = GTetris:CreateScroll(GTetris.OnlineUI.Lower, gap, upperHeight + topgap, GTetris.OnlineUI.Lower:GetWide() - gap * 2, GTetris.OnlineUI.Lower:GetTall() - (upperHeight + topgap + gap), Color(40, 40, 40, 255))
				if(!GTetris.FetchingHistory) then
					GTetris.ReturnedContent = ""
					GTetris.TotalRequests = 1
					GTetris.CurrentRequested = 0
					GTetris:WaitingAPIScreen()
					http.Fetch("https://gtetris.gmaniaserv.xyz/gtetris/latestinx.gnx",

						function(body, length, headers, code)
							local num = tonumber(body)
							if(!num) then return end
								GTetris.MaximumINX = num
								local totalContentRequired = 1
								if(num > 1) then totalContentRequired = 2 end

								if(num <= 1) then
									GTetris:FetchHistory(num, 1)
								else
									GTetris.TotalRequests = 2
									GTetris:FetchHistory(num, 1)
									GTetris:FetchHistory(num - 1, 2)
								end

							GTetris.FetchingHistory = false
						end,

						function(message)
							GTetris.FetchingHistory = false
						end
					)
				end
			GTetris.FetchingHistory = true
		end},
	}
	for k,v in next, options do
		GTetris:CreateOnlineButton(k, v[1], v[2])
	end
end