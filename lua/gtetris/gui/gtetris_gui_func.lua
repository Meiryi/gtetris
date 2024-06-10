--[[
	GTetris made by Meiryi :
		None of these codes should be edited, reuploaded, or claim it's made by yourself
		I don't care if you think anywhre needs a edit/patch, just let me know and I'll do it myself!
]]

GTetris.Font = {}
GTetris.Font.ScrollTitleSize = 15
GTetris.Font.ScrollSubTitleSize = 12
GTetris.Font.ScrollTextSize = 7

GTetris.OptionMaterial = Material("gtetris/internal/settings.png", "smooth")

function GTetris:SetupFonts()
	surface.CreateFont("GTetris-TabButtonFont", {
		font = "Arial",
		extended = false,
		size = ScreenScale(13),
		weight = 1000,
		blursize = 0,
		scanlines = 0,
		antialias = true,
	})
	surface.CreateFont("GTetris-TabScrollTextTitle", {
		font = "Arial",
		extended = false,
		size = ScreenScale(GTetris.Font.ScrollTitleSize),
		weight = 1000,
		blursize = 0,
		scanlines = 0,
		antialias = true,
	})
	surface.CreateFont("GTetris-TabScrollTextSubTitle", {
		font = "Arial",
		extended = false,
		size = ScreenScale(GTetris.Font.ScrollSubTitleSize),
		weight = 1000,
		blursize = 0,
		scanlines = 0,
		antialias = true,
	})
	surface.CreateFont("GTetris-TabScrollTextNormal", {
		font = "Arial",
		extended = false,
		size = ScreenScale(GTetris.Font.ScrollTextSize),
		weight = 1000,
		blursize = 0,
		scanlines = 0,
		antialias = true,
	})
end

function GTetris:GetSetValue(set, opt)
	if(set == nil) then
		return GTetris[opt]
	else
		return GTetris[set][opt]
	end
end

function GTetris:ModifySetValue(set, opt, val)
	if(set == nil) then
		GTetris[opt] = val
	else
		GTetris[set][opt] = val
	end
end

function GTetris:CreateFrame(parent, x, y, w, h, color, popup)
	local frame = vgui.Create("DFrame", parent)
		frame:SetPos(x, y)
		frame:SetSize(w, h)
		frame:ShowCloseButton(false)
		frame:SetDraggable(false)
		frame:SetTitle("")
		frame.Paint = function()
			draw.RoundedBox(0, 0, 0, w, h, color)
		end
		if(popup) then
			frame:MakePopup()
		end

	return frame
end

function GTetris:CreatePanel(parent, x, y, w, h, color)
	local frame = vgui.Create("DPanel", parent)
		frame:SetPos(x, y)
		frame:SetSize(w, h)
		frame.Paint = function()
			draw.RoundedBox(0, 0, 0, w, h, color)
		end

	return frame
end

function GTetris:CreateScroll(parent, x, y, w, h, color)
	local frame = vgui.Create("DScrollPanel", parent)
		frame:SetPos(x, y)
		frame:SetSize(w, h)
		frame.Paint = function()
			draw.RoundedBox(0, 0, 0, w, h, color)
		end

	return frame
end

function GTetris:InsertKeybind(parent, set, opt, text, font, color, func)
	local w, h = GTetris:GetTextSize(font, text)
	local frame = GTetris:CreateFrame(parent, 0, 0, parent:GetWide(), h * 1.5, color)
	frame:Dock(TOP)
	frame:DockMargin(0, ScreenScale(2), 0, 0)
	local gap = ScreenScale(6)
	local label = vgui.Create("DLabel", frame)
		label:SetText(text)
		label:SetFont(font)
		label:SetPos(gap, ((h * 1.5) - h) / 2)
		label:SetSize(w, h)
		label:SetColor(Color(255, 255, 255, 255))
		local textBoxSize = ScreenScale(32)
		local pad = w + ScreenScale(10)
		local keybinder = GTetris:CreatePanel(frame, 0, 0, frame:GetWide(), frame:GetTall(), color)
		local t = keybinder:Add("DTextEntry")
		t:SetSize(keybinder:GetWide(), keybinder:GetTall())
		local offs = (h * 1.5) - (h)
		
			keybinder.oPaint = keybinder.Paint
			keybinder.alpha = 0
			keybinder:SetKeyboardInputEnabled(true)
			keybinder.Paint = function()
				local val = GTetris:GetSetValue(set, opt)
				if(keybinder:IsHovered() || GTetris.CurrentFocusedWindow == keybinder) then
					keybinder.alpha = math.Clamp(keybinder.alpha + GTetris:GetFixedValue(10), 0, 30)
				else
					keybinder.alpha = math.Clamp(keybinder.alpha - GTetris:GetFixedValue(10), 0, 30)
				end
				draw.DrawText(input.GetKeyName(val), font, keybinder:GetWide() - gap, offs / 2, Color(255, 255, 255, 255), TEXT_ALIGN_RIGHT)

				draw.RoundedBox(0, 0, 0, keybinder:GetWide(), keybinder:GetTall(), Color(255, 255, 255, keybinder.alpha))
			end

		t.Paint = function() end

		function t:OnMousePressed(key)
			GTetris.CurrentFocusedWindow = keybinder
		end

		function t:OnKeyCodeTyped(key)
			if(GTetris.CurrentFocusedWindow == keybinder) then
				GTetris:ModifySetValue(set, opt, key)
				GTetris.CurrentFocusedWindow = nil

				func()
			end
		end
end


function GTetris:InsertSlider(parent, set, opt, min, max, text, font, color, con, func)
	local w, h = GTetris:GetTextSize(font, text)
	local frame = GTetris:CreateFrame(parent, 0, 0, parent:GetWide(), h * 1.5, color)
	frame:Dock(TOP)
	frame:DockMargin(0, ScreenScale(2), 0, 0)
	local label = vgui.Create("DLabel", frame)
		label:SetText(text)
		label:SetFont(font)
		label:SetPos(h * 0.25, ((h * 1.5) - h) / 2)
		label:SetSize(w, h)
		local textBoxSize = ScreenScale(32)
		local pad = w + ScreenScale(10)
		local innerframe = GTetris:CreateFrame(frame, pad, ((h * 1.2) - h), parent:GetWide() - (pad + ScreenScale(10) + textBoxSize), h * 1.2, color)
		local offs = (h * 1.5) - (h * 1.2)
		local textbox = frame:Add("DTextEntry")
			textbox:SetSize(textBoxSize, h * 1.2)
			textbox:SetPos((frame:GetWide() - textBoxSize) - ScreenScale(4), offs / 2)
			textbox:SetFont(font)
			textbox:SetPaintBackground(false)
			textbox:SetTextColor(Color(255, 255, 255, 255))
			textbox.oPaint = textbox.Paint
			textbox.Paint = function()
				textbox:SetValue(GTetris:GetSetValue(set, opt))
				if(con != nil) then
					if(GTetris:GetSetValue(set, opt) >= con[1]) then
						textbox:SetValue(con[2])
					end
				end
				draw.RoundedBox(0, 0, 0, textbox:GetWide(), textbox:GetTall(), Color(30, 30, 30, 255))
				textbox.oPaint(textbox)
			end
		innerframe.Paint = function()
			local cval = GTetris:GetSetValue(set, opt)
			local pos = innerframe:GetWide() * (cval / max)
			draw.RoundedBox(0, 0, 0, innerframe:GetWide(), innerframe:GetTall(), color)
			draw.RoundedBox(0, 0, innerframe:GetTall() / 2, innerframe:GetWide(), ScreenScale(2), Color(30, 30, 30, 255))
			local wide = ScreenScale(5)
			draw.RoundedBox(0, pos - (wide / 2), 0, wide, innerframe:GetTall(), Color(60, 60, 60, 255))

			if(innerframe:IsHovered()) then
				local x, y = innerframe:CursorPos()
				if(input.IsMouseDown(107)) then
					local val = max * math.Round((x / innerframe:GetWide()), 2)
					if(val != GTetris:GetSetValue(set, opt)) then
						GTetris:ModifySetValue(set, opt, val)
						func()
					end
					textbox:SetValue(GTetris:GetSetValue(set, opt))
					if(con != nil) then
						if(GTetris:GetSetValue(set, opt) >= con[1]) then
							textbox:SetValue("inf")
						end
					end
				end
			end
		end

end

function GTetris:InsertGap(parent, gap)
	local _h = gap
	local w = parent:GetWide()
	local frame = GTetris:CreateFrame(parent, 0, 0, w, _h, bcolor)
		frame:Dock(TOP)
		frame:DockMargin(0, 0, 0, 0)
		frame:SetHeight(_h)
		frame.Paint = function() return end
end

function GTetris:InsertDockTitle(parent, sidegap, topgap, text, bcolor, tcolor, offset)
	local _h = ScreenScale(GTetris.Font.ScrollTitleSize)
	local w = parent:GetWide()
	local frame = GTetris:CreateFrame(parent, 0, 0, w, _h, bcolor)
	local offs = GTetris:GetTextXOffset(w + offset, text, "GTetris-TabScrollTextTitle")
		frame:Dock(TOP)
		frame:DockMargin(sidegap, topgap, 0, 0)
		frame:SetHeight(_h)
		frame.Paint = function()
			draw.RoundedBox(0, 0, 0, w, _h, bcolor)
			draw.DrawText(text, "GTetris-TabScrollTextTitle", offs, 0, tcolor, TEXT_ALIGN_CENTER)
		end
end

function GTetris:InsertDockSubTitle(parent, sidegap, topgap, text, bcolor, tcolor, offset)
	local _h = ScreenScale(GTetris.Font.ScrollSubTitleSize)
	local w = parent:GetWide()
	local frame = GTetris:CreateFrame(parent, 0, 0, w, _h, bcolor)
		frame:Dock(TOP)
		frame:DockMargin(sidegap, topgap, 0, 0)
		frame:SetHeight(_h)
		frame.Paint = function()
			draw.RoundedBox(0, 0, 0, w, _h, bcolor)
			draw.DrawText(text, "GTetris-TabScrollTextSubTitle", 0, 0, tcolor, TEXT_ALIGN_LEFT)
		end
end

function GTetris:CreateButton(parent, sidegap, topgap, text, set, opt, method, __var, func)
	local _h = ScreenScale(7)
	local w = parent:GetWide()
	local frame = GTetris:CreateFrame(parent, 0, 0, w, _h, Color(255, 255, 255, 100))
	local var = GTetris[set][opt]
	local switch = false
	local outline = 2
	local _offs = _h * 0.25
	local _sx = _h * 0.5
		frame:Dock(TOP)
		frame:DockMargin(sidegap, topgap, 0, 0)
		frame:SetHeight(_h)
		frame.Paint = function()
			if(method == "string") then
				switch = (GTetris[set][opt] == __var)
			else
				switch = GTetris[set][opt]
			end

			surface.SetDrawColor(255, 255, 255, 255)
			if(switch) then
				surface.DrawRect(_offs, _offs, _sx, _sx)
			else
				surface.DrawOutlinedRect(_offs, _offs, _sx, _sx, outline)
			end
			draw.DrawText(text, "GTetris-TabScrollTextNormal", _h, 0, Color(255, 255, 255, 255))
		end
		local button = frame:Add("DButton")
			button:SetSize(w, _h)
			button:SetText("")
			button.Paint = function() end

			button.DoClick = function()
				if(method == "string") then
					GTetris[set][opt] = __var
				else
					GTetris[set][opt] = !GTetris[set][opt]
				end
				if(func != nil) then
					func()
				end
			end
end

function GTetris:GetTextSize(font, text)
	surface.SetFont(font)
	return surface.GetTextSize(text)
end

function GTetris:GetTextXOffset(wide, text, font)
	surface.SetFont(font)
	local w, h = surface.GetTextSize("DummyText")
	return math.abs(wide - w) / 2
end

function GTetris:GetTextYOffset(height, font)
	surface.SetFont(font)
	local w, h = surface.GetTextSize("DummyText")
	return math.abs(height - h) / 2
end

function GTetris:CreateButtonEasy(parent, x, y, w, h, text, color, tcolor, clickfunc)
	local button = vgui.Create("DButton", parent)
		button:SetPos(x, y)
		button:SetSize(w, h)
		button:SetText("")
		button.DrawText = text
		button.clr = 0
		button.alpha = 0
		local bottomHeight = h * 0.065
		local offs = GTetris:GetTextYOffset(h + bottomHeight, "GTetris-TabButtonFont")
		local tw, th = GTetris:GetTextSize("GTetris-TabButtonFont", text)
		local maxInt = 15
		button.Paint = function()
			if(button:IsHovered()) then
				button.clr = math.Clamp(button.clr + GTetris:GetFixedValue(7), 0, maxInt)
				button.alpha = math.Clamp(button.alpha + GTetris:GetFixedValue(30), 0, 255)
			else
				button.clr = math.Clamp(button.clr - GTetris:GetFixedValue(7), 0, maxInt)
				button.alpha = math.Clamp(button.alpha - GTetris:GetFixedValue(30), 0, 255)
			end
			draw.RoundedBox(0, 0, 0, w, h, Color(color.r + button.clr, color.g + button.clr, color.b + button.clr, color.a))
			local clr = 255 - (maxInt - button.clr)
			draw.DrawText(button.DrawText, "GTetris-TabButtonFont", w / 2, offs, tcolor, TEXT_ALIGN_CENTER)
		end
		button.DoClick = clickfunc

		return button
end

function GTetris:CreateTabButton(parent, x, y, w, h, text, color, clickfunc)
	local button = vgui.Create("DButton", parent)
		button:SetPos(x, y)
		button:SetSize(w, h)
		button:SetText("")
		button.clr = 0
		button.alpha = 0
		local bottomHeight = h * 0.065
		local offs = GTetris:GetTextYOffset(h + bottomHeight, "GTetris-TabButtonFont")
		local maxInt = 60
		button.Paint = function()
			if(button:IsHovered()) then
				button.clr = math.Clamp(button.clr + GTetris:GetFixedValue(7), 0, maxInt)
				button.alpha = math.Clamp(button.alpha + GTetris:GetFixedValue(30), 0, 255)
			else
				button.clr = math.Clamp(button.clr - GTetris:GetFixedValue(7), 0, maxInt)
				button.alpha = math.Clamp(button.alpha - GTetris:GetFixedValue(30), 0, 255)
			end
			draw.RoundedBox(0, 0, 0, w, h, Color(color.r + button.clr, color.g + button.clr, color.b + button.clr, color.a))
			draw.RoundedBox(0, 0, h - bottomHeight, w, bottomHeight, Color(255, 255, 255, button.alpha))
			local clr = 255 - (maxInt - button.clr)
			draw.DrawText(text, "GTetris-TabButtonFont", w / 2, (h / 2) - offs, Color(clr, clr, clr, 255), TEXT_ALIGN_CENTER)
		end
		button.DoClick = function()

		end
		button.oDoClick = button.DoClick

		button.DoClick = clickfunc

		return button
end