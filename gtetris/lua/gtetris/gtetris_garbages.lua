--[[
	GTetris made by Meiryi :
		None of these codes should be edited, reuploaded, or claim it's made by yourself
		I don't care if you think anywhre needs a edit/patch, just let me know and I'll do it myself!
]]

function GTetris:MoveRowUp(amount)
	local MaxRange = GTetris.Rows - 1
	local RandGap = math.random(0, GTetris.Cols - 1)
	local RandCol = {}
	for i = 0, GTetris.Cols - 1 do
		if(i != RandGap) then
			RandCol[i] = 8
		else
			RandCol[i] = 0
		end
	end
	for i = GTetris.MaximumOverflowRange, MaxRange, 1 do
		local nRow = i + amount
		if(nRow > MaxRange) then
			GTetris.Grids[i] = table.Copy(RandCol)
		else
			GTetris.Grids[i] = table.Copy(GTetris.Grids[nRow])
		end
	end
end

function GTetris:SendAttack(attack, cancel, cancel_amount)
	net.Start("GTetris-SendAttack")
	net.WriteString(GTetris.CurrentCommID)
	net.WriteInt(attack, 32)
	net.WriteVector(Vector(GTetris.LastPlaceOrigin.x, GTetris.LastPlaceOrigin.y, 0))
	net.WriteBool(cancel)
	net.WriteInt(cancel_amount, 32)
	net.SendToServer()
	if(attack <= 0) then return end
	GTetris:SendAttackSound(attack)
	GTetris:InsertAttackParticle(LocalPlayer():EntIndex(), LocalPlayer():GetNWInt("GTetris-Target", -1), attack, GTetris.LastPlaceOrigin)
end

function GTetris:InsertAttackParticle(from, to, amount, offs)
	if(to == -1 || GTetris.IsSinglePlayer) then return end
	local numPlayers = table.Count(GTetris.PlayerGrids)
	local grid = GTetris.PlayerGrids[to]
	local grid2 = GTetris.PlayerGrids[from]
	local origin = Vector(0, 0, 0)
	local tovec = Vector(0, 0, 0)
	local offset = Vector(0, 0, 0)

	if(grid == nil && Entity(to) != LocalPlayer()) then return end
	if(grid2 == nil && Entity(from) != LocalPlayer()) then return end

	local localX, localY = ScrW() / 2, ScrH() / 2
	local size = GTetris.CellSize
	if(grid2 != nil) then
		size = grid2.CSize
	end

	local offsets = Vector(offs.x * size, offs.y * size)
	if(LocalPlayer():EntIndex() == from) then
		origin = Vector((localX - GTetris.RenderXOffet) - (GTetris.TotalW / 2), localY - (GTetris.TotalH / 2))
	else
		if(grid2 == nil) then return end
		origin = Vector(grid2.Origin.x - (GTetris.TotalW / 2), grid2.Origin.y - (GTetris.TotalH / 2))
	end

	if(LocalPlayer():EntIndex() == to) then
		tovec = Vector((localX - GTetris.RenderXOffet), localY)
	else
		if(grid == nil) then return end
		offset = Vector(grid.Size.x / 2, grid.Size.y / 2)
		tovec = Vector(grid.Origin.x, grid.Origin.y) - Vector(GTetris.TotalW / 2, GTetris.TotalH / 2) + offset
	end

	origin = origin + offsets

	local targetTime = GTetris.GarbageArriveDelay
	local dst = origin:Distance(tovec)
	local hd = dst / 4
	local rand = VectorRand(-hd, hd)
	local middle = GTetris:TraceLinear(origin, tovec, 0.5) + rand
	table.insert(GTetris.AttackTraces, {
		v1 = origin,
		v2 = middle,
		v3 = tovec,
		alpha = 255,
		time = SysTime() + targetTime,
		wscale = 0.5,
		hscale = 1,
		sx = ScreenScale(16),
		rotate = GTetris:GetAngle(origin, middle),
		oldvec = origin,
		trans = 0,
		target_trans = targetTime,
	})
end

function GTetris:AddAttackNumbers(player, pos, attacks, cancel)
	if(GTetris.PlayerGrids[player] == nil) then return end
	local prevDamage = 0
	for k,v in next, GTetris.PlayerGrids[player].DamageNumbers do
		if(!cancel) then
			prevDamage = prevDamage + v.attacks
		end
		v.time = -1
	end
	attacks = attacks + prevDamage
	table.insert(GTetris.PlayerGrids[player].DamageNumbers, {
		attacks = attacks,
		time = SysTime() + (0.7 + math.min(attacks * 0.05, 0.5)),
		flashtime = -1,
		maxflashtime = SysTime() + 0.5,
		flashed = false,
		scale = 0.05,
		maxscale = 0.5 + math.min(attacks * 0.03, 0.35),
		alpha = 0,
		color1 = 255,
		color2 = 0,
		canceling = cancel,
		mrotate = math.random(-13, 13),
		pos = pos,
	})
end

function GTetris:TestKillFeed(v1, v2)
	local vic = v1
	local att = v2

	table.insert(GTetris.Killfeeds, {
		n1 = att,
		n2 = vic,
		killtime = SysTime() + 5,
		alpha = 0,
		y_pos = 0,
		x_pos = -(ScrW() * 0.2),
	})
end

net.Receive("GTetris-Killfeed", function()
	local vic = net.ReadString()
	local att = net.ReadString()

	table.insert(GTetris.Killfeeds, {
		n1 = att,
		n2 = vic,
		killtime = SysTime() + 5,
		alpha = 0,
		y_pos = 0,
		x_pos = -(ScrW() * 0.2),
	})
end)

net.Receive("GTetris-SendAttack", function()
	local player = net.ReadInt(32)
	local target = net.ReadInt(32)
	local amount = net.ReadInt(32)
	local offs = net.ReadVector()
	local cancel = net.ReadBool()
	local cancel_amount = net.ReadInt(32)

	if(LocalPlayer():GetNWBool("GTetris-Died", false)) then
		if(target == GTetris.CurrentSpecPlayer) then
			if(amount > 0) then
				GTetris:ReceiveAttackSound(amount)
			end
			timer.Simple(GTetris.GarbageArriveDelay, function()
				if(cancel || amount <= 0) then return end
				GTetris:BoardHitSound()
			end)
		end
		if(player == GTetris.CurrentSpecPlayer) then
			if(amount > 0) then
				GTetris:SendAttackSound(amount)
			end
		end
	end

	if(Entity(target) == LocalPlayer()) then
		if(amount > 0) then
			GTetris:ReceiveAttackSound(amount)
		end
		GTetris.CurrentSpecPlayer = player
		timer.Simple(GTetris.GarbageArriveDelay, function()
			if(cancel || amount <= 0) then return end
			GTetris:BoardHitSound()
			GTetris:ReceiveGarbage(amount)
		end)
		if(cancel) then
			amount = cancel_amount
		end
		if(amount > 0) then
			offs.x = offs.x + 1
			offs.y = offs.y + 1
			GTetris:AddAttackNumbers(player, offs, amount, cancel)
		end
	end

	local e = Entity(player)
	if(player == LocalPlayer() || amount <= 0 || cancel) then return end
	local b = GTetris.PlayerGrids[player]
	if(b) then
		b.Attacks = b.Attacks + (cancel_amount + amount)
	end
	GTetris:InsertAttackParticle(player, target, amount, offs)
end)

function GTetris:ApplyGarbage(amount)
	GTetris:MoveRowUp(amount)
end

function GTetris:SyncPDetails()
	net.Start("GTetris-SyncPlayDetails")
	net.WriteInt(GTetris.CurrentB2B, 32)
	net.WriteInt(GTetris.CurrentCombo, 32)
	net.SendToServer()
end

function GTetris:ResetPDetails()
	GTetris.CurrentB2B = 0
	GTetris.Combo = 0
	GTetris:SyncPDetails()
end

function GTetris:ApplyComboBonus(combo, lines, bonus)
	if(lines <= 0) then return 0 end
	local __bonus = 0
	if(GTetris.ComboTable == "Meiryi") then
		if(bonus) then
			__bonus = combo
		else
			if(lines < 4) then
				local maxScaling = (3 * (2 ^ (lines-1))) + math.floor(0.1667 * combo)
				local baseBonus = math.floor(math.Clamp((0.55 * lines) * combo, 0, 1))
				local linesMul = math.floor(combo * (0.15 + (lines * 0.15)))
				__bonus = math.min(linesMul + baseBonus, maxScaling)
			else
				__bonus = combo
			end
		end
	elseif(GTetris.ComboTable == "Increase") then
		__bonus = combo
	elseif(GTetris.ComboTable == "Squaring") then -- God this is broken
		__bonus = 2 ^ math.min(combo, 10)
	end

	local b2b = GTetris.CurrentB2B - 1
	local b2b_bonus = 0

	if(b2b >= 24) then
		b2b_bonus = 4
	elseif(b2b >= 8) then
		b2b_bonus = 3
	elseif(b2b >= 3) then
		b2b_bonus = 2
	elseif(b2b >= 1) then
		b2b_bonus = 1
	end

	return __bonus + b2b_bonus
end

function GTetris:ProcessGarbage(lineCleared, bonus, ALLClear)
	local attack = lineCleared
	if(bonus) then
		attack = attack * 2
		if(lineCleared > 0) then
			GTetris.CurrentB2B = GTetris.CurrentB2B + 1
		end
	else
		if(lineCleared < 4) then
			attack = math.max(lineCleared - 1, 0)
			if(lineCleared > 0) then
				GTetris.CurrentB2B = 0
			end
		else
			GTetris.CurrentB2B = GTetris.CurrentB2B + 1
		end
	end
	attack = attack + GTetris:ApplyComboBonus(GTetris.Combo, lineCleared, bonus)
	if(ALLClear) then
		attack = attack + 10
	end
	
	attack = math.floor(attack * GTetris.GarbageScaling)

	GTetris.GarbageSent = GTetris.GarbageSent + attack

	local noGarbage = (lineCleared > 0)
	local cap = GTetris.GarbageCap
	local canceled = 0
	local playsd = false
	for k,v in next, GTetris.Garbages do
		if(attack <= 0) then
			if(noGarbage || v.delay > SysTime()) then continue end
			if(cap > v.amount) then
				cap = math.max(cap - v.amount)
				GTetris:ApplyGarbage(v.amount)
				playsd = true
				table.remove(GTetris.Garbages, k)
			else
				v.amount = math.max(v.amount - cap, 0)
				GTetris:ApplyGarbage(cap)
				playsd = true
				cap = 0
				if(v.amount <= 0) then
					table.remove(GTetris.Garbages, k)
				end
			end
		else
			if(attack > v.amount) then
				attack = math.max(attack - v.amount)
				canceled = canceled + v.amount
				table.remove(GTetris.Garbages, k)
			else
				v.amount = math.max(v.amount - attack, 0)
				canceled = canceled + attack
				attack = 0
			end
		end
	end
	if(canceled > 0 || attack > 0) then
		if(canceled > 0 && attack > 0) then
			GTetris:GetPlacePosition(attack, false, true)
		else
			if(canceled > 0) then
				GTetris:GetPlacePosition(canceled, true, false)
			end
			if(attack > 0) then
				GTetris:GetPlacePosition(attack, false, false)
			end
		end
	end
	if(playsd) then
		GTetris:BroadcastUpSound()
		GTetris:BoardUpSound()
	end
	if(GTetris.Backfire && attack > 0) then
		GTetris:ReceiveGarbage(attack)
	end
	if(GTetris.CurrentCommID != "?") then
		if(attack > 0 || canceled > 0) then
			GTetris:SendAttack(attack, canceled > 0, canceled)
		end
	end

	GTetris:SyncPDetails()
	GTetris:SyncGarbages()
end