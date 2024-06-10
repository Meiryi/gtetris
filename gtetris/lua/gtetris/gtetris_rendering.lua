--[[
	GTetris made by Meiryi :
		None of these codes should be edited, reuploaded, or claim it's made by yourself
		I don't care if you think anywhre needs a edit/patch, just let me know and I'll do it myself!
]]

GTetris.RenderTargets = {}
GTetris.DamageNumbers = {}
GTetris.ALLClears = {}
GTetris.AttackTraces = {}
GTetris.AttackTrails = {}
GTetris.Killfeeds = {}

GTetris.CurrentSpecPlayer = -1
GTetris.AutoChangeSpecTime = -1

GTetris.DisplayGhostBlock = true
GTetris.ShouldRender = true
GTetris.DebugGrids = false
GTetris.DiedRand = Vector(0, 0, 0)
GTetris.RenderXOffet = 0
GTetris.DiedYOffset = 0
GTetris.DiedDelay = 0
GTetris.SpecCellSize = 0

GTetris.BonusText = "Hello World"
GTetris.BonusTextTime = 0
GTetris.BonusTextTargetTime = 0
GTetris.BonusTextAlpha = 255
GTetris.BonusTextColor = Color(255, 255, 255, 255)
GTetris.BonusTextOffset = 0
GTetris.BonusTextTargetOffset = ScrW() * 0.01

GTetris.B2BText = "Hello World"
GTetris.B2BTextFlash = false
GTetris.B2BTextFlashTime = 0
GTetris.B2BTextTargetFlashTime = 0
GTetris.B2BTextResetAlpha = false
GTetris.B2BTextTime = 0
GTetris.B2BTextTargetTime = 0
GTetris.B2BTextAlpha = 255
GTetris.B2BTextColor = Color(255, 255, 255, 255)
GTetris.B2BTextOffset = 0
GTetris.B2BTextTargetOffset = ScrW() * 0.01

GTetris.ClearLinesText = "Hello World"
GTetris.ClearLinesTextTime = 0
GTetris.ClearLinesTextTargetTime = 0
GTetris.ClearLinesTextAlpha = 255
GTetris.ClearLinesTextColor = Color(255, 255, 255, 255)
GTetris.ClearLinesTextOffset = 0
GTetris.ClearLinesTextTargetOffset = ScrW() * 0.01

GTetris.ComboText = "Hello World"
GTetris.ComboTextTime = 0
GTetris.ComboTextTargetTime = 0
GTetris.ComboTextAlpha = 255
GTetris.ComboTextColor = Color(255, 255, 255, 255)
GTetris.ComboTextOffset = 0
GTetris.ComboTextTargetOffset = ScrW() * 0.01

GTetris.BlockMaterial = Material("gtetris/block.png", "smooth")
GTetris.GarbageParticleMaterial = Material("gtetris/garbageparticle.png", "smooth")
GTetris.LogoMaterial = Material("gtetris/internal/logo.png")

GTetris.GridBGColor = 255

surface.CreateFont("GTetris-FieldText", {
	font = "Arial",
	extended = false,
	size = ScreenScale(15),
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
})

surface.CreateFont("GTetris-AttackText", {
	font = "Arial",
	extended = false,
	size = ScreenScale(30),
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
})

surface.CreateFont("GTetris-SideText", {
	font = "Arial",
	extended = false,
	size = ScreenScale(18),
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
})

surface.CreateFont("GTetris-SideText2x", {
	font = "Arial",
	extended = false,
	size = ScreenScale(14),
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
})

surface.CreateFont("GTetris-SideIndicatorTitle", {
	font = "Arial",
	extended = false,
	size = ScreenScale(11),
	weight = 100,
	blursize = 0,
	scanlines = 0,
	antialias = true,
})

surface.CreateFont("GTetris-SideIndicatorText", {
	font = "Arial",
	extended = false,
	size = ScreenScale(11),
	weight = 250,
	blursize = 0,
	scanlines = 0,
	antialias = true,
})

surface.CreateFont("GTetris-PCText", {
	font = "Arial",
	extended = false,
	size = ScreenScale(24),
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
})

surface.CreateFont("GTetris-NameText", {
	font = "Arial",
	extended = false,
	size = ScrH() * 0.03,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
})

function GTetris:GetAngle(p1, p2)
	local ang = math.atan2(p2.y - p1.y, p1.x - p2.x)
	local deg = math.deg(ang)
	return deg + 90
end

function GTetris:TraceLinear(p1, p2, t)
	local x, y = p2.x - p1.x, p2.y - p1.y
	return Vector(p1.x + x * t, p1.y + y * t, 0)
end

function GTetris:CircumCircle(p, t)
	local a0, a1 ,c0, c1, det, asq, csq, ctr0, ctr1, rad2

	a0 = p[1].x - p[2].x
	a1 = p[1].y - p[2].y

	c0 = p[3].x - p[2].x
	c1 = p[3].y - p[2].y

	det = a0 * c1 - c0 * a1

	if(det == 0) then return false end
	det = 0.5 / det
	asq = a0 * a0 + a1 * a1
	csq = c0 * c0 + c1 * c1
	ctr0 = det * (asq * c1 - csq * a1)
	ctr1 = det * (csq * a0 - asq * c0)
	rad2 = ctr0 * ctr0 + ctr1 * ctr1

	local pos = {x = ctr0 + p[2].x, y = ctr1 + p[2].y}
	local sta, eda = math.floor(math.deg(math.atan2(pos.y - p[1].y, p[1].x - pos.x)) + 90) ,math.floor(math.deg(math.atan2(pos.y - p[3].y, p[3].x - pos.x)) + 90)
	local segs = sta - eda
	local step1 = 1
	local r = math.sqrt(rad2)
	if(sta > eda) then
		step1 = -1
	end
	local ta = {}
	for i = sta, eda, step1 do
		local a = math.rad(i)
		table.insert(ta, {x = pos.x + math.sin( a ) * r, y = pos.y + math.cos( a ) * r, Color(0, 0, 255, 255)})
	end

	local inx = math.max(math.floor(#ta * t), 1)
	return ta[inx]
end

function GTetris:SetupBonusText(text, time, color)
	GTetris.BonusText = text
	GTetris.BonusTextTime = SysTime() + time
	GTetris.BonusTextTargetTime = time
	GTetris.BonusTextColor = color
end

function GTetris:SetupSideText(index, text, time, color)
	GTetris[index.."Text"] = text
	GTetris[index.."TextTime"] = SysTime() + time
	GTetris[index.."TextTargetTime"] = time
	GTetris[index.."TextColor"] = color
end

function GTetris:GetFixedValue(input)
	local target = 0.016666
	return input / (target / RealFrameTime())
end

local mouseDown = false
local cursorX, cursorY = 0, 0
function GTetris:IsHovered(x, y, w, h)
	return (cursorX > x && cursorX < x + w && cursorY > y && cursorY < y + h)
end

function GTetris:RenderGrids(grids, x, y, csize, gsize, eindex, num, bot)

	local baseX, baseY = x - GTetris.TotalW / 2, y - GTetris.TotalH / 2
	
	local player = Entity(eindex)

	local tW, tH = (csize * GTetris.Cols) + GTetris.GridSize, (GTetris.Rows * csize) + GTetris.GridSize
	local totalPlayers = table.Count(GTetris.PlayerGrids)

	local tab = GTetris.PlayerGrids[eindex]

	surface.SetMaterial(GTetris.BlockMaterial)

	local died = false
	local nick = "UNKNOWN PLAYER"
	local vec, id, rot = Vector(0, 0, 0), 1, 0
	local bags = "123456"
	local holds = -1
	local garbage = 0

	local combo, b2b = 0, 0

	local attack, piece = 0, 0

	local warn = false
	local color = 255
	local bgcolor = color_white

	if(!IsValid(player) && tab) then
		if(tab.isbot) then
			nick = tab.name
			id = tab.cblock
			rot = 0
			bags = tab.bags
			holds = tab.hblock
			garbage = tab.garbages

			attack, piece = tab.Attacks, tab.Pieces

			died = !tab.alive

			combo = tab.combo
			b2b = tab.b2b

			warn = tab.warning

			if(warn) then
				tab.color = math.Clamp(tab.color - GTetris:GetFixedValue(30), 50, 255)
			else
				tab.color = math.Clamp(tab.color + GTetris:GetFixedValue(30), 50, 255)
			end

			color = tab.color

			local w = GTetris:GetBlockWide(id)
			vec = Vector((GTetris.Cols / 2) - math.Round((w / 2) + 0.5, 0), -3, 0)
		end
	else
		if(IsValid(player)) then
			nick = player:Nick()
			attack, piece = GTetris:GetCompDetails(player)
			vec, id, rot = player:GetNWVector("GTetris-Origin", Vector(0, 0, 0)), player:GetNWInt("GTetris-BlockID", 1), player:GetNWInt("GTetris-Rotation", 0)
			bags = player:GetNWString("GTetris-Bags", "123456")
			holds = player:GetNWInt("GTetris-Holds", -1)
			garbage = player:GetNWInt("GTetris-Garbages", 0)
			died = player:GetNWBool("GTetris-Died", false)

			combo = player:GetNWBool("GTetris-Combo", 0)
			b2b = player:GetNWBool("GTetris-B2B", 0)
			if(player == LocalPlayer()) then
				warn = GTetris.WarnGrid

				if(warn) then
					GTetris.GridBGColor = math.Clamp(GTetris.GridBGColor - GTetris:GetFixedValue(30), 50, 255)
				else
					GTetris.GridBGColor = math.Clamp(GTetris.GridBGColor + GTetris:GetFixedValue(30), 50, 255)
				end
				color = GTetris.GridBGColor
			else
				if(tab) then
					warn = tab.warning
					if(warn) then
						tab.color = math.Clamp(tab.color - GTetris:GetFixedValue(30), 50, 255)
					else
						tab.color = math.Clamp(tab.color + GTetris:GetFixedValue(30), 50, 255)
					end
					color = GTetris.GridBGColor
				end
			end
		end
	end


	bgcolor = Color(255, color, color, 180)

	if(!bot) then
		draw.RoundedBox(0, baseX, baseY, tW, tH, bgcolor)
	end

	for k,v in next, grids do
		if(died && k < 0) then continue end
		for x,y in next, v do
			if(y == 0 && k < 0) then continue end
			local color = GTetris:GetColor(y)
			local alpha = 255
			if(bot) then
				alpha = 50
			end
			if(died && y != 0) then color = GTetris:GetColor(8) end
			local fsize = csize - gsize
			surface.SetDrawColor(color.r, color.g, color.b, alpha)
			surface.DrawTexturedRect(baseX + (x * csize) + gsize, baseY + (k * csize) + gsize, fsize, fsize)
		end
	end
	local scale = csize / GTetris.CellSize
	if(died) then
		local cx, cy = baseX + tW / 2, baseY + tH / 2
		local koMat = Matrix()

		koMat:Translate(Vector(cx + csize, cy - csize))
		koMat:Rotate(Angle(0, 27, 0))
		koMat:Scale(Vector(scale, scale, 0))
		koMat:Translate(-Vector(cx, cy))

		cam.PushModelMatrix(koMat)
			draw.DrawText("K.O", "GTetris-ScreenText", cx, cy, Color(255, 20, 20, 255), TEXT_ALIGN_CENTER)
		cam.PopModelMatrix()
	end
	if(num <= 1) then
		if(player != LocalPlayer()) then
			local padding = ScreenScale(10)
			local btextX, btextY = baseX - padding, baseY + (csize * 4) + padding + ScreenScale(30)
			if(combo > 0) then
				draw.SimpleTextOutlined(combo.." Combo", "GTetris-SideText", btextX, btextY, Color(255, 255, 255, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, math.Round(ScreenScale(0.5) + 0.1, 0), Color(0, 0, 0, 255))
			end
			btextY = btextY + ScreenScale(15)
			if(b2b > 0) then
				draw.SimpleTextOutlined("B2B   x "..b2b, "GTetris-SideText", btextX, btextY, Color(255, 201, 94, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, math.Round(ScreenScale(0.5) + 0.1, 0), Color(0, 0, 0, 255))
			end
		end

		local tw, th = GTetris:GetTextSize("GTetris-NameText", nick)
		tw = tw * 1.5
		draw.RoundedBox(0, baseX + (tW / 2) - tw / 2, baseY + tH + (th * 0.33), tw + ScreenScale(1), th + ScreenScale(1), Color(0, 0, 0, 200))
		draw.DrawText(nick, "GTetris-NameText", baseX + (tW / 2), baseY + tH + (th * 0.33), Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)

		local gap = ScrW() * 0.02
		
		local scl = math.abs(SysTime() - GTetris.GarbageRecordTime)
		local nextY = (tH * 0.75)
		draw.DrawText("PIECES", "GTetris-SideIndicatorTitle", baseX - gap, baseY + nextY, Color(255, 255, 255, 255), TEXT_ALIGN_RIGHT)
		nextY = nextY + ScreenScale(12)
		draw.DrawText(string.format("%3.2f", piece / scl, 2).." / S", "GTetris-SideIndicatorText", baseX - gap, baseY + nextY, Color(255, 255, 255, 255), TEXT_ALIGN_RIGHT)
		nextY = nextY + ScreenScale(12)
		draw.DrawText("ATTACK", "GTetris-SideIndicatorTitle", baseX - gap, baseY + nextY, Color(255, 255, 255, 255), TEXT_ALIGN_RIGHT)
		nextY = nextY + ScreenScale(12)

		draw.DrawText(string.format("%3.2f", attack / (scl / 60), 2).." / M", "GTetris-SideIndicatorText", baseX - gap, baseY + nextY, Color(255, 255, 255, 255), TEXT_ALIGN_RIGHT)
		
	end
	if(player != LocalPlayer()) then

		local cX, cY = x - tW / 2, y - tH / 2 
		local shape = GTetris.Shapes[id][rot]
		local color = GTetris:GetColor(id)
		local fsize = csize - gsize
		local details = num <= 1
		if(!died) then
			for k,v in next, shape do
				surface.SetDrawColor(color.r, color.g, color.b, color.a)
				surface.DrawTexturedRect(baseX + ((vec.x + v[2]) * csize) + gsize, baseY + ((vec.y + v[1]) * csize) + gsize, fsize, fsize)
			end
		end

		if(num <= 3) then
			local padding = ScreenScale(3)
			local nextX, nextY = baseX + tW + padding, baseY
			local textBoxTall = csize * 1.5
			local wide = (csize * 4.5)
			local fsize = csize - gsize
			draw.RoundedBox(0, nextX, nextY, wide, (csize * 12), bgcolor)
			draw.RoundedBox(0, nextX + gsize, nextY + gsize, wide - gsize * 2, (csize * 12) - gsize * 2, Color(0, 0, 0, 255))
			draw.RoundedBox(0, nextX, nextY, wide, textBoxTall, bgcolor)
			if(details) then
				draw.DrawText("NEXT", "GTetris-FieldText", nextX + wide / 2, nextY, Color(0, 0, 0, 255), TEXT_ALIGN_CENTER)
			end

			if(bags != "NULL") then
				for k = 1, #bags, 1 do
					if(k > 4) then continue end
					local v = tonumber(bags[k])
					local Shapes = GTetris.Shapes[v][0]
					local XOffs, YOffs = nextX, nextY + padding + textBoxTall + (k - 1) * csize * 2.5
					local color = GTetris:GetColor(v)
					local blockWide = (GTetris:GetBlockWide(v) + 1) * csize
					local _XOffset = wide - blockWide

					for x,y in next, Shapes do
						surface.SetDrawColor(color.r, color.g, color.b, color.a)
						surface.DrawTexturedRect((XOffs + _XOffset / 2) + (y[2] * csize) + gsize, YOffs + (y[1] * csize) + gsize, fsize, fsize)
					end
				end
			end

			local GarbageWide = csize * 0.7
			local InnerWide = GarbageWide - (gsize * 2)

			draw.RoundedBox(0, baseX - GarbageWide, baseY, GarbageWide, tH, GTetris.BackgroundColor)
			draw.RoundedBox(0, baseX - GarbageWide + gsize, baseY + gsize, InnerWide, tH - gsize * 2, Color(0, 0, 0, 255))
			draw.RoundedBox(0, (baseX - GarbageWide + gsize), (baseY + tH) - (GTetris.GarbageCap * csize), InnerWide, gsize, GTetris.BackgroundColor)

			local height = garbage * csize
			draw.RoundedBox(0, (baseX - GarbageWide + gsize), ((baseY + tH) - height) + gsize, InnerWide, height, Color(255, 50, 50, 255))

			if(GTetris.HoldAllowed) then
				local holdX, holdY = (baseX - GarbageWide) - wide, baseY
				draw.RoundedBox(0, holdX, nextY, wide, (csize * 4) + gsize, bgcolor)
				draw.RoundedBox(0, holdX + gsize, nextY + gsize, wide - gsize, (csize * 4) - gsize, Color(0, 0, 0, 255))
				draw.RoundedBox(0, holdX, nextY, wide, textBoxTall, bgcolor)
				if(details) then
					draw.DrawText("HOLD", "GTetris-FieldText", holdX + wide / 2, nextY, Color(0, 0, 0, 255), TEXT_ALIGN_CENTER)
				end
				if(holds != -1) then
				local color = GTetris:GetColor(holds)
				if(!GTetris.CanHold) then
					color = Color(50, 50, 50, 255)
				end
				local Shapes = GTetris.Shapes[holds][0]
				for k,v in next, Shapes do
					local XOffs, YOffs = holdX, holdY + textBoxTall + csize * 0.25
					local blockWide = (GTetris:GetBlockWide(holds) + 1) * csize
					local _XOffset = wide - blockWide
					draw.RoundedBox(0, (XOffs + _XOffset / 2) + (v[2] * csize) + gsize, YOffs + (v[1] * csize) + gsize, fsize, fsize, color)
				end
			end
		local w, h = ScrW(), ScrH()
		local _x, _y = w / 2, h / 2
		local baseX, baseY = x - tW / 2, y - tH / 2
		for k,v in next, GTetris.PlayerGrids[eindex].DamageNumbers do
			if(v.time > SysTime()) then
				v.alpha = math.Clamp(v.alpha + GTetris:GetFixedValue((255 - v.alpha) * 0.5), 0, 255)
			else
				v.alpha = math.Clamp(v.alpha - GTetris:GetFixedValue(25), 0, 255)
				if(v.alpha <= 0) then
					table.remove(GTetris.PlayerGrids[eindex].DamageNumbers, k)
				end
			end

			if(v.attacks >= 10) then
				if(v.maxflashtime > SysTime()) then
					if(v.flashtime < SysTime()) then
						if(v.flashed) then
							v.color1 = 255
							v.color2 = 0
							v.flashed = false
						else
							v.color1 = 0
							v.color2 = 255
							v.flashed = true
						end
						v.flashtime = SysTime() + 0.07
					end
				else
					v.color1 = 255
					v.color2 = 0
				end
			end
			v.scale = math.Clamp(v.scale + GTetris:GetFixedValue((v.maxscale - v.scale) * 0.2), 0, v.maxscale)
			local mat = Matrix()
			--print(v.pos.x, v.pos.y)
			mat:Translate(Vector(baseX + (v.pos.x * csize), baseY + ((v.pos.y - v.maxscale) * csize))) -- Position
			mat:Rotate(Angle(0, v.mrotate, 0)) -- Rotation
			mat:Scale(Vector(v.scale * scale, v.scale * scale, 1)) -- Sizes
			mat:Translate(-Vector(_x, _y))
		 
			cam.PushModelMatrix(mat)
		 	   if(!v.canceling) then
		 	   		draw.SimpleTextOutlined(v.attacks, "GTetris-AttackText", _x, _y, Color(v.color1, v.color1, v.color1, v.alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 2, Color(v.color2, v.color2, v.color2, v.alpha))
		 	   	else
		 	   		draw.SimpleTextOutlined(v.attacks, "GTetris-AttackText", _x, _y, Color(107, 142, 255, v.alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 2, Color(0, 0, 0, v.alpha))
		 	   end
			cam.PopModelMatrix()
		end

		end

		end
	end

	if(player == LocalPlayer()) then
		local targeted = 0
		for k,v in next, GTetris.PlayerGrids do
			local e = Entity(k)
			if(IsValid(e)) then
				if(e:GetNWInt("GTetris-Target", -1) == LocalPlayer():EntIndex() && !e:GetNWBool("GTetris-Died", false)) then
					targeted = targeted + 1
				end
			else
				if(v.isbot) then
					if(v.target == LocalPlayer():EntIndex()) then
						targeted = targeted + 1
					end
				end
			end
		end
		if(targeted > 0 && totalPlayers > 1) then
			local str = targeted.." PLAYERS TARGETING YOU"
			local tw, th = GTetris:GetTextSize("GTetris-NameText", str)
			local color = Color(255, 255, 255, 255)
			tw = tw * 1.2
			if(targeted > 2) then
				color = Color(255, 105, 105, 255)
			end
			draw.RoundedBox(0, baseX + (tW / 2) - tw / 2, baseY + tH + (th * 1.75), tw + ScreenScale(1), th + ScreenScale(1), Color(0, 0, 0, 200))
			draw.DrawText(str, "GTetris-NameText", baseX + (tW / 2), baseY + tH + (th * 1.75), color, TEXT_ALIGN_CENTER)
		end

		local padding = ScreenScale(3)
		local nextX, nextY = baseX + GTetris.TotalW + padding, baseY
		local textBoxTall = csize * 1.5
		local wide = (csize * 4.5)
		local fsize = csize - gsize
		draw.RoundedBox(0, nextX, nextY, wide, (csize * 12), bgcolor)
		draw.RoundedBox(0, nextX + gsize, nextY + gsize, wide - gsize * 2, (csize * 12) - gsize * 2, Color(0, 0, 0, 255))
		draw.RoundedBox(0, nextX, nextY, wide, textBoxTall, bgcolor)
		draw.DrawText("NEXT", "GTetris-FieldText", nextX + wide / 2, nextY, Color(0, 0, 0, 255), TEXT_ALIGN_CENTER)
		local w, h = ScrW(), ScrH()
		local _x, _y = w / 2, h / 2
		local vpos = {x = baseX + GTetris.TotalW / 2, y = baseY + GTetris.TotalH / 2}

		for k,v in next, GTetris.Bags do
			if(k > 4) then continue end
			local Shapes = GTetris.Shapes[v][0]
			local XOffs, YOffs = nextX, nextY + padding + textBoxTall + (k - 1) * csize * 2.5
			local color = GTetris:GetColor(v)
			local blockWide = (GTetris:GetBlockWide(v) + 1) * csize
			local _XOffset = wide - blockWide
			for x,y in next, Shapes do
				surface.SetDrawColor(color.r, color.g, color.b, color.a)
				surface.DrawTexturedRect((XOffs + _XOffset / 2) + (y[2] * csize) + gsize, YOffs + (y[1] * csize) + gsize, fsize, fsize)
			end
		end

			local GarbageWide = csize * 0.7
			local InnerWide = GarbageWide - (gsize * 2)

			draw.RoundedBox(0, baseX - GarbageWide, baseY, GarbageWide, GTetris.TotalH, bgcolor)
			draw.RoundedBox(0, baseX - GarbageWide + gsize, baseY + gsize, InnerWide, GTetris.TotalH - gsize * 2, Color(0, 0, 0, 255))
			draw.RoundedBox(0, (baseX - GarbageWide + gsize), (baseY + GTetris.TotalH) - (GTetris.GarbageCap * csize), InnerWide, gsize, bgcolor)
			local NextGarbageY = baseY + GTetris.TotalH - (gsize * 2)

			for k,v in next, GTetris.Garbages do
				if(NextGarbageY <= 0) then continue end
				local TotalHeight = (v.amount * csize) - (gsize * 2)
				if(v.delay > SysTime()) then
					draw.RoundedBox(0, (baseX - GarbageWide + gsize), (NextGarbageY - TotalHeight) + gsize, InnerWide, TotalHeight, Color(255, 50, 50, 85))
				else
					draw.RoundedBox(0, (baseX - GarbageWide + gsize), (NextGarbageY - TotalHeight) + gsize, InnerWide, TotalHeight, Color(255, 50, 50, 255))
				end

				NextGarbageY = NextGarbageY - (v.amount * csize)
			end
			if(GTetris.HoldAllowed) then
				local holdX, holdY = (baseX - GarbageWide) - wide, baseY
				draw.RoundedBox(0, holdX, nextY, wide, (csize * 4) + gsize, bgcolor)
				draw.RoundedBox(0, holdX + gsize, nextY + gsize, wide - gsize, (csize * 4) - gsize, Color(0, 0, 0, 255))
				draw.RoundedBox(0, holdX, nextY, wide, textBoxTall, bgcolor)
				draw.DrawText("HOLD", "GTetris-FieldText", holdX + wide / 2, nextY, Color(0, 0, 0, 255), TEXT_ALIGN_CENTER)
				if(GTetris.CurrentHoldBlockID != -1) then
				local color = GTetris:GetColor(GTetris.CurrentHoldBlockID)
				if(!GTetris.CanHold) then
					color = Color(50, 50, 50, 255)
				end
				local Shapes = GTetris.Shapes[GTetris.CurrentHoldBlockID][0]
				for k,v in next, Shapes do
					local XOffs, YOffs = holdX, holdY + textBoxTall + csize * 0.25
					local blockWide = (GTetris:GetBlockWide(GTetris.CurrentHoldBlockID) + 1) * csize
					local _XOffset = wide - blockWide
					draw.RoundedBox(0, (XOffs + _XOffset / 2) + (v[2] * csize) + gsize, YOffs + (v[1] * csize) + gsize, fsize, fsize, color)
				end
			end
		end
		if(GTetris.DebugGrids) then

			draw.DrawText("Piece Origin X : "..GTetris.Origin.x.." Y : "..GTetris.Origin.y, "TargetID", baseX, baseY - ScreenScale(20), Color(255, 255, 255, 255), TEXT_ALIGN_LEFT)

			for i = 0, (GTetris.Cols - 1), 1 do
				draw.DrawText(i, "TargetID", baseX + csize * i, baseY - csize, Color(105, 255, 255, 255), TEXT_ALIGN_CENTER)
			end

			for i = GTetris.MaximumOverflowRange, (GTetris.Rows - 1), 1 do
				draw.DrawText(i, "TargetID", baseX - csize, baseY + csize * i, Color(255, 105, 255, 255), TEXT_ALIGN_CENTER)
			end
		end

		local padding2x = padding * 2
		local btextX, btextY = baseX - padding2x, baseY + (csize * 4) + padding

		local timeScale = math.max((GTetris.BonusTextTime - SysTime()) / GTetris.BonusTextTargetTime, 0)
		GTetris.BonusTextAlpha = 255 * timeScale
		GTetris.BonusTextOffset = GTetris.BonusTextTargetOffset * timeScale
		draw.SimpleTextOutlined(GTetris.BonusText, "GTetris-FieldText", btextX - (GTetris.BonusTextTargetOffset - GTetris.BonusTextOffset), btextY, Color(GTetris.BonusTextColor.r, GTetris.BonusTextColor.g, GTetris.BonusTextColor.b, GTetris.BonusTextAlpha), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, math.Round(ScreenScale(0.5) + 0.1, 0), Color(0, 0, 0, GTetris.BonusTextAlpha))
		btextY = btextY + ScreenScale(15)

		timeScale = math.max((GTetris.ClearLinesTextTime - SysTime()) / GTetris.ClearLinesTextTargetTime, 0)
		GTetris.ClearLinesTextAlpha = 255 * timeScale
		GTetris.ClearLinesTextOffset = GTetris.ClearLinesTextTargetOffset * timeScale
		draw.SimpleTextOutlined(GTetris.ClearLinesText, "GTetris-SideText", btextX - (GTetris.ClearLinesTextTargetOffset - GTetris.ClearLinesTextOffset), btextY, Color(GTetris.ClearLinesTextColor.r, GTetris.ClearLinesTextColor.g, GTetris.ClearLinesTextColor.b, GTetris.ClearLinesTextAlpha), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, math.Round(ScreenScale(0.5) + 0.1, 0), Color(0, 0, 0, GTetris.ClearLinesTextAlpha))

		btextY = btextY + ScreenScale(15)

		timeScale = math.max((GTetris.ComboTextTime - SysTime()) / GTetris.ComboTextTargetTime, 0)
		GTetris.ComboTextAlpha = 255 * timeScale

		GTetris.ComboTextOffset = GTetris.ComboTextTargetOffset * timeScale
		draw.SimpleTextOutlined(GTetris.ComboText, "GTetris-SideText", btextX - (GTetris.ComboTextTargetOffset - GTetris.ComboTextOffset), btextY, Color(GTetris.ComboTextColor.r, GTetris.ComboTextColor.g, GTetris.ComboTextColor.b, GTetris.ComboTextAlpha), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, math.Round(ScreenScale(0.5) + 0.1, 0), Color(0, 0, 0, GTetris.ComboTextAlpha))
	
		btextY = btextY + ScreenScale(16)

		local color = Color(255, 201, 94, 255)

		if(GTetris.CurrentB2B > 0) then
			GTetris.B2BTextAlpha = math.Clamp(GTetris.B2BTextAlpha + GTetris:GetFixedValue(20), 0, 255)
			GTetris.B2BTextTargetFlashTime = SysTime() + 0.7
		else
			color = Color(255, 80, 80, 255)
			if(GTetris.B2BTextTargetFlashTime > SysTime()) then
				if(GTetris.B2BTextFlashTime < SysTime()) then
					if(GTetris.B2BTextFlash) then
						GTetris.B2BTextAlpha = 0
					else
						GTetris.B2BTextAlpha = 255
					end
					GTetris.B2BTextFlash = !GTetris.B2BTextFlash
					GTetris.B2BTextFlashTime = SysTime() + 0.1
				end
				GTetris.B2BTextResetAlpha = true
			else
				if(GTetris.B2BTextResetAlpha) then
					GTetris.B2BTextAlpha = 255
					GTetris.B2BTextResetAlpha = false
				end
				GTetris.B2BTextAlpha = math.Clamp(GTetris.B2BTextAlpha - GTetris:GetFixedValue(7), 0, 255)
			end
		end

		draw.SimpleTextOutlined("B2B   x "..GTetris.CurrentB2B, "GTetris-SideText2x", btextX - (GTetris.B2BTextTargetOffset - GTetris.B2BTextOffset), btextY, Color(color.r, color.g, color.b, GTetris.B2BTextAlpha), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, math.Round(ScreenScale(0.5) + 0.1, 0), Color(0, 0, 0, GTetris.B2BTextAlpha))

		for k,v in next, GTetris.ALLClears do

			if(v.time > SysTime()) then
				v.alpha = math.Clamp(v.alpha + GTetris:GetFixedValue((255 - v.alpha) * 0.35), 0, 255)
				v.size = math.Clamp(v.size + GTetris:GetFixedValue((v.targetsize - v.size) * 0.1), 0, v.targetsize)
				v.rotate = math.Clamp(v.rotate + GTetris:GetFixedValue(60), 0, v.targetrotate)
			else
				v.alpha = math.Clamp(v.alpha - GTetris:GetFixedValue(10), 0, 255)
				v.size = math.Clamp(v.size - GTetris:GetFixedValue(v.size * 0.05), 0, v.targetsize)
				if(v.alpha <= 0) then
					table.remove(GTetris.ALLClears, k)
					continue
				end
			end

			local mat = Matrix()

			mat:Translate(Vector(vpos.x, vpos.y - (v.size * csize * 2))) -- Position
			mat:Rotate(Angle(0, v.rotate, 0)) -- Rotation
			mat:Scale(Vector(v.size, v.size, 1)) -- Sizes
			mat:Translate(-Vector(_x, _y))

			cam.PushModelMatrix(mat)
		 		draw.DrawText("ALL\nCLEAR", "GTetris-PCText", _x, _y, Color(v.color.r, v.color.g, v.color.b, v.alpha), TEXT_ALIGN_CENTER)
			cam.PopModelMatrix()
		end
	
		for k,v in next, GTetris.DamageNumbers do
			if(v.time > SysTime()) then
				v.alpha = math.Clamp(v.alpha + GTetris:GetFixedValue((255 - v.alpha) * 0.5), 0, 255)
			else
				v.alpha = math.Clamp(v.alpha - GTetris:GetFixedValue(25), 0, 255)
				if(v.alpha <= 0) then
					table.remove(GTetris.DamageNumbers, k)
				end
			end
			if(v.attacks >= 10) then
				if(v.maxflashtime > SysTime()) then
					if(v.flashtime < SysTime()) then
						if(v.flashed) then
							v.color1 = 255
							v.color2 = 0
							v.flashed = false
						else
							v.color1 = 0
							v.color2 = 255
							v.flashed = true
						end
						v.flashtime = SysTime() + 0.07
					end
				else
					v.color1 = 255
					v.color2 = 0
				end
			end
			v.scale = math.Clamp(v.scale + GTetris:GetFixedValue((v.maxscale - v.scale) * 0.2), 0, v.maxscale)

			local mat = Matrix()
			--print(v.pos.x, v.pos.y)
			mat:Translate(Vector(baseX + (v.pos.x * csize), baseY + ((v.pos.y - v.maxscale) * csize))) -- Position
			mat:Rotate(Angle(0, v.mrotate, 0)) -- Rotation
			mat:Scale(Vector(v.scale, v.scale, 1)) -- Sizes
			mat:Translate(-Vector(_x, _y))
		 
			cam.PushModelMatrix(mat)
		 	   if(!v.canceling) then
		 	   		draw.SimpleTextOutlined(v.attacks, "GTetris-AttackText", _x, _y, Color(v.color1, v.color1, v.color1, v.alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 2, Color(v.color2, v.color2, v.color2, v.alpha))
		 	   	else
		 	   		draw.SimpleTextOutlined(v.attacks, "GTetris-AttackText", _x, _y, Color(107, 142, 255, v.alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 2, Color(0, 0, 0, v.alpha))
		 	   end
			cam.PopModelMatrix()
		end
	end

	if(GTetris:IsHovered(baseX, baseY, tW, tH) && eindex != LocalPlayer():EntIndex() && eindex != GTetris.CurrentSpecPlayer) then
		draw.DrawText(nick, "GTetris-NameText", cursorX, cursorY, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)
		local tw, th = GTetris:GetTextSize("GTetris-NameText", nick)
		tw = tw * 1.5
		draw.RoundedBox(0, cursorX - tw / 2, cursorY, tw + ScreenScale(1), th + ScreenScale(1), Color(0, 0, 0, 200))
		draw.DrawText(nick, "GTetris-NameText", cursorX, cursorY, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)

		if(!mouseDown && input.IsMouseDown(107) && LocalPlayer():GetNWBool("GTetris-Died", false)) then
			GTetris.CurrentSpecPlayer = eindex
			GTetris.SpecCellSize = 0
			GTetris.AutoChangeSpecTime = SysTime() + 327670
		end
	end
end

function GTetris:RenderCurrentBlock(x, y, csize, gsize)
	if(LocalPlayer():GetNWBool("GTetris-Died", false)) then return end

	surface.SetMaterial(GTetris.BlockMaterial)

	local curX, curY = GTetris.Origin.x, GTetris.Origin.y 
	local baseX, baseY = x - GTetris.TotalW / 2, y - GTetris.TotalH / 2
	local Blocks = GTetris.Shapes[GTetris.CurrentBlockID][GTetris.RotationState]
	local GridBlocks = GTetris:LocalToGrids(GTetris.Origin, Blocks)
	local color = GTetris:GetColor(GTetris.CurrentBlockID)
	local fsize = csize - gsize
	surface.SetDrawColor(color.r, color.g, color.b, color.a)
	for k,v in next, GridBlocks do
		surface.DrawTexturedRect(baseX + (v[2] * csize) + gsize, baseY + (v[1] * csize) + gsize, fsize, fsize)
	end
	if(GTetris.DisplayGhostBlock) then
		local GhostBlock = GTetris:TraceGhostBlock()
		surface.SetDrawColor(color.r, color.g, color.b, 30)
		for k,v in next, GhostBlock do
			surface.DrawTexturedRect(baseX + (v[2] * csize) + gsize, baseY + (v[1] * csize) + gsize, fsize, fsize)
		end
	end
end

GTetris.ScreenText = {}
function GTetris:InsertScreenText(text, t, wait, color)
	local clr = Color(255, 203, 15, 255)
	local scl = 1
	if(wait) then scl = 0 end
	if(color != nil) then clr = color end
	table.insert(GTetris.ScreenText, {
		staytime = SysTime() + 0.1,
		time = SysTime() + t,
		text = text,
		scale = scl,
		minscale = 0.1,
		alpha = 0,
		wait = wait,
		clr = clr,
	})
end

function GTetris:PaintScreenTexts()
	local pos = Vector(ScrW() / 2, ScrH() / 2)
	local _x, _y = ScrW() / 2, ScrH() / 2
	for k,v in next, GTetris.ScreenText do
		if(v.staytime < SysTime()) then
			if(!v.wait) then
				v.scale = math.Clamp(v.scale - GTetris:GetFixedValue(0.015), 0, 1)
				v.alpha = math.Clamp(v.alpha - GTetris:GetFixedValue(5), 0, 255)
			else
				if(v.time < SysTime()) then
					v.scale = math.Clamp(v.scale - GTetris:GetFixedValue(0.015), 0, 1)
					v.alpha = math.Clamp(v.alpha - GTetris:GetFixedValue(5), 0, 255)
				else
					v.scale = math.Clamp(v.scale + GTetris:GetFixedValue(0.025), 0, 1)
				end
			end
			if(v.alpha <= 0) then
				table.remove(GTetris.ScreenText, k)
			end
		else
			v.alpha = math.Clamp(v.alpha + GTetris:GetFixedValue(50), 0, 255)
			v.scale = math.Clamp(v.scale + GTetris:GetFixedValue(0.025), 0, 1)
		end
			local mat = Matrix()

			mat:Translate(pos - Vector(0, v.scale * (GTetris.ScreenTextSize / 2), 0)) -- Position
			mat:Scale(Vector(v.scale, v.scale, 1))
			mat:Translate(-Vector(_x, _y))
		 
			cam.PushModelMatrix(mat)
				draw.DrawText(v.text, "GTetris-ScreenText", pos.x, pos.y, Color(v.clr.r, v.clr.g, v.clr.b, v.alpha), TEXT_ALIGN_CENTER)
			cam.PopModelMatrix()
	end
end

surface.CreateFont("GTetris-KillfeedText", {
	font = "Arial",
	extended = false,
	size = ScreenScale(10),
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
})

GTetris.KillArrow = Material("gtetris/internal/killarrow.png", "smooth")

function GTetris:PaintKillfeeds()
	local locName = LocalPlayer():Nick()
	local pad = ScreenScale(1)
	local padhx = ScreenScale(2)
	local pad2x = pad * 5
	local pad4x = pad * 10
	local centpad = ScreenScale(36)
	local targetXPos = ScrW() * 0.01
	local targetYPos = ScrH() * 0.07
	surface.SetMaterial(GTetris.KillArrow)
	for k,v in next, GTetris.Killfeeds do
		local w1, h1 = GTetris:GetTextSize("GTetris-KillfeedText", v.n1)
		local w2, h2 = GTetris:GetTextSize("GTetris-KillfeedText", v.n2)
		local nextX = v.x_pos
		if(v.killtime < SysTime()) then
			v.alpha = math.Clamp(v.alpha - GTetris:GetFixedValue(20), 0, 255)
			if(v.alpha <= 0) then
				table.remove(GTetris.Killfeeds, k)
			end
		else
			v.alpha = math.Clamp(v.alpha + GTetris:GetFixedValue(20), 0, 255)
		end

		v.x_pos = math.min(targetXPos, v.x_pos + GTetris:GetFixedValue(math.abs(v.x_pos - targetXPos)) * 0.15)

		local idx = (k - 1)
		local typos = targetYPos + (idx * h1) + (idx * pad2x)

		if(typos > v.y_pos) then
			v.y_pos = math.Clamp(v.y_pos + GTetris:GetFixedValue(math.abs(v.y_pos - typos) * 0.15), v.y_pos, typos)
		else
			v.y_pos = math.Clamp(v.y_pos - GTetris:GetFixedValue(math.abs(v.y_pos - typos) * 0.15), typos, v.y_pos)
		end

		local ascl = v.alpha / 255

		local color = Color(255, 255, 255, 255 * ascl)
		local bgcolor1 = Color(0, 0, 0, 200 * ascl)
		local bgcolor2 = Color(0, 0, 0, 200 * ascl)
		if(v.n1 == locName) then -- Killed somebody
			color = Color(255, 156, 25, 255 * ascl)
			bgcolor1 = Color(76, 46, 7, 220 * ascl)
		end
		if(v.n2 == locName) then -- Died to other players
			color = Color(255, 40, 40, 255 * ascl)
			bgcolor2 = Color(80, 20, 20, 200 * ascl)
		end

		draw.RoundedBox(0, nextX, v.y_pos, w1 + pad4x, h1 + padhx, bgcolor1)
		surface.SetDrawColor(color.r, color.g, color.b, color.a)
		surface.DrawOutlinedRect(nextX, v.y_pos, w1 + pad4x, h1 + padhx, pad)
		draw.DrawText(v.n1, "GTetris-KillfeedText", nextX + pad2x, v.y_pos + pad, color, TEXT_ALIGN_LEFT)

		local centX = nextX + (centpad / 2) + w1

		surface.DrawTexturedRect(centX, v.y_pos + pad, h1, h1)

		nextX = nextX + centpad + w1
		draw.RoundedBox(0, nextX, v.y_pos, w2 + pad4x, h2 + padhx, bgcolor2)
		surface.SetDrawColor(color.r, color.g, color.b, color.a)
		surface.DrawOutlinedRect(nextX, v.y_pos, w2 + pad4x, h2 + padhx, pad)
		draw.DrawText(v.n2, "GTetris-KillfeedText", nextX + pad2x, v.y_pos + pad, color, TEXT_ALIGN_LEFT)
	end	
end

local _textsize = 20
surface.CreateFont("GTetris-MenuFont", {
	font = "Calibri",
	extended = false,
	size = _textsize,
	weight = 1000,
	blursize = 0,
	scanlines = 0,
	antialias = true,
})


local tshape = Material("gtetris/internal/tshape.png", "smooth")
function GTetris:PaintStartButton()
	if(!gui.IsGameUIVisible() || gui.IsConsoleVisible() || IsValid(GTetris.Gui)) then return end

	local maxHeight = 50
	local margin = 5
	local buttonwide = 100
	local buttonheight = maxHeight - (margin * 2)
	local baseX = 180
	local baseY = ScrH() - (maxHeight - margin)

	local x,y = input.GetCursorPos()
	local hovered = (x > baseX && x < baseX + buttonwide && y > baseY && y < baseY + buttonheight)

	local bcolor = 255
	if(hovered) then
		bcolor = 150
	end

	draw.RoundedBox(5, baseX, baseY, buttonwide, buttonheight, Color(bcolor, bcolor, bcolor, 255))
	local sideGap = 12
	local imageSize = 30
	local imageGap = 8

	surface.SetDrawColor(bcolor, bcolor, bcolor, 255)
	surface.SetMaterial(tshape)
	surface.DrawTexturedRect(baseX + sideGap, baseY + (buttonheight - imageSize) / 2, imageSize, imageSize)
	local color = 80
	draw.DrawText("Tetris", "GTetris-MenuFont", baseX + sideGap + imageGap + imageSize, baseY + (buttonheight - _textsize) / 2, Color(color, color, color, 255), TEXT_ALIGN_LEFT)

	if(!mouseDown && input.IsMouseDown(107) && hovered) then
		GTetris:OpenGame()
	end
end

local lastHoldTime = 0
local targetResetTime = 0.45
local curResetTime = 0
local waitForKeyRelease = false
local NextSpecTime = 0
local shouldNotify = false

hook.Add("HUDPaint", "GTetris-Notify", function()
	if(!shouldNotify) then
		LocalPlayer():ChatPrint("[gtetris] Type '/tetris' in chat to play")
		shouldNotify = true
	end
end)

hook.Add("DrawOverlay", "GTetris-Rendering", function()
	GTetris:PaintStartButton()
	--local ret = GTetris:CircumCircle(pts, CurTime() % 1)

	cursorX, cursorY = input.GetCursorPos()

	if(!GTetris.ShouldRender || !GTetris.ShouldProcess) then return end
	local localX, localY = ScrW() / 2, ScrH() / 2
	local playeramount = table.Count(GTetris.PlayerGrids)
	local csize = GTetris.CellSize / math.min(playeramount, 3)
	local localTotalW = GTetris.CellSize * 10
	local TotalW, TotalH = GTetris.Cols * csize, GTetris.Rows * csize

	local gapX = ScrW() * 0.035
	local gapY = ScrH() * 0.03
	local defY = ScrH() * 0.5
	local nextX, nextY = localX + localTotalW * 1.85, defY

	if(playeramount <= 1) then
		nextX = localX + GTetris.TotalW + gapX
		nextY = localY
		GTetris.RenderXOffet = math.Clamp(GTetris.RenderXOffet + GTetris:GetFixedValue(30), 0, GTetris.TotalW)
	else
		GTetris.RenderXOffet = math.Clamp(GTetris.RenderXOffet - GTetris:GetFixedValue(30), 0, GTetris.TotalW / 2)
	end

	if(GTetris.IsSinglePlayer) then
		GTetris.RenderXOffet = 0
	end

	for k,v in next, GTetris.PlayerGrids do
		if(IsValid(v.Player)) then
			if(v.Player:GetNWBool("GTetris-Died")) then
				v.AliveTime = SysTime() + 1
			end
		else
			v.AliveTime = SysTime() + 1
		end
	end


	if(LocalPlayer():GetNWBool("GTetris-Died", false)) then

		if(playeramount <= 1) then
			NextSpecTime = SysTime() + 3
		end

		if(NextSpecTime < SysTime()) then
			GTetris.SpecCellSize = math.Clamp(GTetris.SpecCellSize + GTetris:GetFixedValue((GTetris.CellSize - GTetris.SpecCellSize) * 0.1), 0, GTetris.CellSize)
			for k,v in next, GTetris.PlayerGrids do
				if(IsValid(v.Player)) then
					if(v.Player:GetNWBool("GTetris-Died")) then

					end
				end
				if(!GTetris.PlayerGrids[GTetris.CurrentSpecPlayer]) then
					GTetris.CurrentSpecPlayer = k
				else
					local b = GTetris.PlayerGrids[GTetris.CurrentSpecPlayer]
					if(IsValid(b.Player)) then
						if(b.Player:GetNWBool("GTetris-Died", false)) then
							for x,y in next, GTetris.PlayerGrids do
								if(GTetris.AutoChangeSpecTime > SysTime()) then break end
								if(IsValid(y.Player)) then
									if(!y.Player:GetNWBool("GTetris-Died", false)) then
										GTetris.CurrentSpecPlayer = x
										GTetris.SpecCellSize = 0
										break
									end
								end
							end
						else
							GTetris.AutoChangeSpecTime = SysTime() + 0.45
						end
					else
						if(!b.alive) then
							for x,y in next, GTetris.PlayerGrids do
								if(GTetris.AutoChangeSpecTime > SysTime()) then break end
								if(!IsValid(y.Player)) then
									if(y.alive) then
										GTetris.CurrentSpecPlayer = x
										GTetris.SpecCellSize = 0
										break
									end
								end
							end
						else
							GTetris.AutoChangeSpecTime = SysTime() + 0.45
						end
					end
				end
				if(k == GTetris.CurrentSpecPlayer) then
					GTetris:RenderGrids(v.Grid, localX - GTetris.RenderXOffet, localY, GTetris.SpecCellSize, GTetris.GridSize, k, 0)
					v.Origin = Vector(localX - GTetris.RenderXOffet, localY)
					v.Size = Vector(GTetris.TotalW, GTetris.TotalH)
					v.CSize = GTetris.SpecCellSize
				else
					GTetris:RenderGrids(v.Grid, nextX + v.RandPos.x, nextY + v.RandPos.y, csize * v.CScale, GTetris.GridSize, k, playeramount)
					v.Origin = Vector(nextX + v.RandPos.x, nextY + v.RandPos.y)
					v.Size = Vector(TotalW, TotalH)
					v.CSize = csize
					nextY = nextY + TotalH + gapY
				end
				if(nextY - gapY > ScrH()) then
					nextY = defY
					nextX = nextX + TotalW + gapX
				end
			end
		else
			for k,v in next, GTetris.PlayerGrids do
				if(IsValid(v.Player)) then
					if(v.Player:GetNWBool("GTetris-Died")) then

					end
				end
				GTetris:RenderGrids(v.Grid, nextX + v.RandPos.x, nextY + v.RandPos.y, csize * v.CScale, GTetris.GridSize, k, playeramount)
				v.Origin = Vector(nextX + v.RandPos.x, nextY + v.RandPos.y)
				v.Size = Vector(TotalW, TotalH)
				v.CSize = csize
				nextY = nextY + TotalH + gapY
				if(nextY - gapY > ScrH()) then
					nextY = defY
					nextX = nextX + TotalW + gapX
				end
			end
			GTetris:RenderGrids(GTetris.Grids, localX - GTetris.RenderXOffet, localY, GTetris.CellSize, GTetris.GridSize, LocalPlayer():EntIndex(), 0)
		end
	else
		GTetris.SpecCellSize = 0
		NextSpecTime = SysTime() + 1
		for k,v in next, GTetris.PlayerGrids do
			if(IsValid(v.Player)) then
				if(v.Player:GetNWBool("GTetris-Died")) then

				end
			end
			GTetris:RenderGrids(v.Grid, nextX + v.RandPos.x, nextY + v.RandPos.y, csize * v.CScale, GTetris.GridSize, k, playeramount)
			v.Origin = Vector(nextX + v.RandPos.x, nextY + v.RandPos.y)
			v.Size = Vector(TotalW, TotalH)
			v.CSize = csize
			nextY = nextY + TotalH + gapY
			if(nextY - gapY > ScrH()) then
				nextY = defY
				nextX = nextX + TotalW + gapX
			end
		end

		GTetris:RenderGrids(GTetris.Grids, localX - GTetris.RenderXOffet, localY, GTetris.CellSize, GTetris.GridSize, LocalPlayer():EntIndex(), 0)

		GTetris:RenderCurrentBlock(localX - GTetris.RenderXOffet, localY, GTetris.CellSize, GTetris.GridSize)
	end

	mouseDown = input.IsMouseDown(107)

	for k,v in next, GTetris.AttackTrails do
		if(v.time < SysTime()) then
			table.remove(GTetris.AttackTrails, k)
		end
		local t = math.max(v.time - SysTime(), 0) / v.target_trans
		surface.SetDrawColor(255, 155, 155, v.alpha * t)
		surface.DrawTexturedRectRotated(v.vec.x, v.vec.y, (v.sx * t) * v.ws, (v.sx * t) * v.hs, v.rotate)
	end


	surface.SetMaterial(GTetris.GarbageParticleMaterial)
	for k,v in next, GTetris.AttackTraces do
		if(v.time < SysTime()) then
			v.alpha = math.Clamp(v.alpha - GTetris:GetFixedValue(20), 0, 255)
			v.wscale = v.wscale + GTetris:GetFixedValue(0.05)
			v.hscale = v.hscale + GTetris:GetFixedValue(0.05)
			if(v.alpha <= 0) then
				table.remove(GTetris.AttackTraces, k)
			end
		end

		local t = math.max(v.time - SysTime(), 0.01) / v.target_trans
		--local vec = GTetris:CircumCircle({v.v1, v.v2, v.v3}, 1 - t)
		local vec = math.QuadraticBezier(1 - t, v.v1, v.v2, v.v3)
		if(!vec) then continue end
		surface.SetDrawColor(255, 70, 70, v.alpha)
		surface.DrawTexturedRectRotated(vec.x, vec.y, (v.sx * 1.5) * v.wscale, (v.sx * 1.5) * v.hscale, v.rotate)

		local dst = math.Distance(v.oldvec.x, v.oldvec.y, vec.x, vec.y)

		if(dst > 0) then
			v.rotate = GTetris:GetAngle(v.oldvec, vec)
			local oldpos = v.oldvec
			for i = 0, 1, 1 / dst do
				local vec = GTetris:TraceLinear(v.oldvec, vec, i)
				table.insert(GTetris.AttackTrails, {
					time = SysTime() + v.target_trans / 2,
					target_trans = v.target_trans / 2,
					rotate = v.rotate,
					sx = v.sx * 0.6,
					ws = v.wscale,
					hs = v.hscale,
					vec = vec,
					alpha = 10,
				})
			end
		end

		v.oldvec = vec
	end
	GTetris:ProcessBot()
	if(GTetris.IsSinglePlayer) then

		

		if(input.IsKeyDown(KEY_R)) then
			if(curResetTime < SysTime() && !waitForKeyRelease) then
				GTetris:ReloadGrids()
				waitForKeyRelease = true
			else
				if(waitForKeyRelease) then
					curResetTime = SysTime() + targetResetTime
				end
			end
		else
			waitForKeyRelease = false
			curResetTime = SysTime() + targetResetTime
		end

		local scale = 1 - math.Round((curResetTime - SysTime()) / targetResetTime, 5)
		local resetHeight = (ScrH() * 0.08) * scale
		draw.RoundedBox(0, 0, ScrH() - resetHeight, ScrW(), resetHeight, Color(255, 158, 66, 255))
		draw.DrawText("KEEP HOLDING TO RESET", "GTetris-FieldText", ScrW() / 2, ScrH() - (resetHeight * 0.7), Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)
	end

	GTetris:PaintScreenTexts()
	GTetris:PaintKillfeeds()
end)