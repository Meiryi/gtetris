--[[
	GTetris made by Meiryi :
		None of these codes should be edited, reuploaded, or claim it's made by yourself
		I don't care if you think anywhre needs a edit/patch, just let me know and I'll do it myself!
]]

BOT_ENUMS_STACKING = 0
BOT_ENUMS_DOWNSTACKING = 0
BOT_ENUMS_COUNTERSPIKING = 0

GTetris.Shapes = {
	[1] = { -- I
		[0] = {{1, 0},{1, 1},{1, 2},{1, 3},},
		[1] = {{0, 2},{1, 2},{2, 2},{3, 2},},
		[2] = {{2, 0},{2, 1},{2, 2},{2, 3},},
		[3] = {{0, 1},{1, 1},{2, 1},{3, 1},},
	},
	[2] = { -- J
		[0] = {{0, 0},{1, 0},{1, 1},{1, 2},},
		[1] = {{0, 1},{0, 2},{1, 1},{2, 1},},
		[2] = {{1, 0},{1, 1},{1, 2},{2, 2},},
		[3] = {{0, 1},{1, 1},{2, 0},{2, 1},},
	},
	[3] = { -- L
		[0] = {{0, 2},{1, 0},{1, 1},{1, 2},},
		[1] = {{0, 1},{1, 1},{2, 1},{2, 2},},
		[2] = {{1, 0},{1, 1},{1, 2},{2, 0},},
		[3] = {{0, 0},{0, 1},{1, 1},{2, 1},},
	},
	[4] = { -- O
		[0] = {{0, 0},{0, 1},{1, 0},{1, 1},},
		[1] = {{0, 0},{0, 1},{1, 0},{1, 1},},
		[2] = {{0, 0},{0, 1},{1, 0},{1, 1},},
		[3] = {{0, 0},{0, 1},{1, 0},{1, 1},},
	},
	[5] = { -- S
		[0] = {{0, 1},{0, 2},{1, 0},{1, 1},},
		[1] = {{0, 1},{1, 1},{1, 2},{2, 2},},
		[2] = {{1, 1},{1, 2},{2, 0},{2, 1},},
		[3] = {{0, 0},{1, 0},{1, 1},{2, 1},},
	},
	[6] = { -- T
		[0] = {{0, 1},{1, 0},{1, 1},{1, 2},},
		[1] = {{0 ,1},{1, 1},{1, 2},{2, 1},},
		[2] = {{1, 0},{1, 1},{1, 2},{2, 1},},
		[3] = {{0, 1},{1, 0},{1, 1},{2, 1},},
	},
	[7] = { -- Z
		[0] = {{0, 0},{0, 1},{1, 1},{1, 2},},
		[1] = {{0, 2},{1, 1},{1, 2},{2, 1},},
		[2] = {{1, 0},{1, 1},{2, 1},{2, 2},},
		[3] = {{0, 1},{1, 0},{1, 1},{2, 0},},
	},
}

function GTetris:MoveRowDown(bot, StartFrom)
	for i = StartFrom, -20, -1 do
		local pRow = i - 1
		if(pRow < 0) then
			GTetris:ClearRows(bot, i)
		else
			bot.grid[i] = table.Copy(bot.grid[pRow])
		end
	end
end

function GTetris:ClearRows(bot, Row)
	for x = 0, bot.cols - 1, 1 do
		bot.grid[Row][x] = 0
	end
end

function GTetris:MoveRowUp(bot, amount)
	local MaxRange = bot.rows - 1
	local RandGap = math.random(0, bot.cols - 1)
	local RandCol = {}
	for i = 0, bot.cols - 1 do
		if(i != RandGap) then
			RandCol[i] = 8
		else
			RandCol[i] = 0
		end
	end
	for i = -20, MaxRange, 1 do
		local nRow = i + amount
		if(nRow > MaxRange) then
			bot.grid[i] = table.Copy(RandCol)
		else
			bot.grid[i] = table.Copy(bot.grid[nRow])
		end
	end
end

function GTetris:ApplyGarbage(bot, amount)
	GTetris:MoveRowUp(bot, amount)
end

function GTetris:ApplyComboBonus(bot, combo, lines, bonus)
	if(lines <= 0) then return 0 end
	local __bonus = 0
	if(bot.rulesets.ComboTable == "Meiryi") then
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
	elseif(bot.rulesets.ComboTable == "Increase") then
		__bonus = combo
	elseif(bot.rulesets.ComboTable == "Squaring") then -- God this is broken
		__bonus = 2 ^ math.min(combo, 10)
	end

	local b2b = bot.b2b - 1
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

	return __bonus
end

function GTetris:ProcessGarbage(bot, lineCleared, bonus, ALLClear)
	local attack = lineCleared
	if(bonus) then
		attack = attack * 2
		if(lineCleared > 0) then
			bot.b2b = bot.b2b + 1
		end
	else
		if(lineCleared < 4) then
			attack = math.max(lineCleared - 1, 0)
			if(lineCleared > 0) then
				bot.b2b = 0
			end
		else
			bot.b2b = bot.b2b + 1
		end
	end

	attack = attack + GTetris:ApplyComboBonus(bot, bot.combo, lineCleared, bonus)
	if(ALLClear) then
		attack = attack + 10
	end
	
	attack = math.floor(attack * bot.rulesets.GarbageScaling)

	bot.attacks = bot.attacks + attack

	local noGarbage = (lineCleared > 0)
	local cap = bot.rulesets.GarbageCap
	local canceled = 0
	local changed = false
	local playsd = false
	for k,v in next, bot.internal_garbages do
		if(attack <= 0) then
			if(noGarbage || v.delay > SysTime()) then continue end
			if(cap > v.amount) then
				cap = math.max(cap - v.amount)
				GTetris:ApplyGarbage(bot, v.amount)
				playsd = true
				table.remove(bot.internal_garbages, k)
				changed = true
			else
				v.amount = math.max(v.amount - cap, 0)
				GTetris:ApplyGarbage(bot, cap)
				playsd = true
				cap = 0
				if(v.amount <= 0) then
					table.remove(bot.internal_garbages, k)
				end
				changed = true
			end
		else
			if(attack > v.amount) then
				attack = math.max(attack - v.amount)
				canceled = canceled + v.amount
				table.remove(bot.internal_garbages, k)
				changed = true
			else
				v.amount = math.max(v.amount - attack, 0)
				canceled = canceled + attack
				attack = 0
				changed = true
			end
		end
	end

	local garbages = 0

	for k,v in next, bot.internal_garbages do
		garbages = garbages + v.amount
	end

	if(playsd) then
		GTetris:BroadcastBoardupSound(bot.rid, bot.botid)
	end

	bot.garbages = garbages

	if(attack > 0 || canceled > 0) then
		GTetris:SendAttack(bot, attack, canceled > 0, canceled)
	end

	if(changed) then
		GTetris:SyncBotDetails(bot.rid, bot.botid)
	end
end

function GTetris:SendAttack(bot, attack, canceled, cancel_amount)
	local room = GTetris.Rooms[bot.rid]
	if(room == nil) then return end

	if(GTetris.TempData[bot.rid]) then
		if(!GTetris.TempData[bot.rid][bot.botid]) then
			GTetris.TempData[bot.rid][bot.botid] = {
				attacks = attack + cancel_amount,
				pieces = 0,
				dietime = -1,
			}
		else
			GTetris.TempData[bot.rid][bot.botid].attacks = GTetris.TempData[bot.rid][bot.botid].attacks + attack + cancel_amount
		end
	end

	if(!IsValid(Entity(bot.target))) then
		if(GTetris.Rooms[bot.rid].Bots_InGame[bot.target]) then
			timer.Simple(bot.rulesets.GarbageArriveDelay, function()
				if(!GTetris.Rooms[bot.rid].Bots_InGame[bot.target]) then return end
				if(attack > 0) then
					GTetris.Rooms[bot.rid].Bots_InGame[bot.target].lastattackindex = bot.botid
					table.insert(GTetris.Rooms[bot.rid].Bots_InGame[bot.target].internal_garbages, {
						amount = attack,
						delay = SysTime() + bot.rulesets.GarbageApplyDelay,
					})
				end
				GTetris.Rooms[bot.rid].Bots_InGame[bot.target].garbages = GTetris.Rooms[bot.rid].Bots_InGame[bot.target].garbages + attack
			end)
		end
	else
		Entity(bot.target):SetNWInt("GTetris-LastAttackIndex", bot.botid)
	end

	for k,v in next, room.Players do
		local p = Entity(v)
		if(p == ply) then continue end
		net.Start("GTetris-SendAttack")
		net.WriteInt(bot.botid, 32)
		net.WriteInt(bot.target, 32)
		net.WriteInt(attack, 32)
		net.WriteVector(Vector(0, 0, 0))
		net.WriteBool(canceled)
		net.WriteInt(cancel_amount, 32)
		net.Send(p)
	end
end

function GTetris:CheckLines(bot, bonus)
	local TotalLines = 0
	local ALLClear = true
	for i = -20, bot.rows - 1, 1 do
		local Cols = bot.grid[i]
		local isFullLine = true
		for k,v in next, Cols do
			if(v == 0) then
				isFullLine = false
			end
		end
		if(isFullLine) then
			TotalLines = TotalLines + 1
			GTetris:ClearRows(bot, i)
			GTetris:MoveRowDown(bot, i)
		end
		for k,v in next, Cols do
			if(v != 0) then
				ALLClear = false
			end
		end
	end
	if(TotalLines > 0) then
		if(bot.cancombo) then
			bot.combo = bot.combo + 1
			if(bot.combo > 2) then
				if(bonus || TotalLines >= 4) then
					bot.bonus_sound = true
				end
			end
		end

		GTetris:BroadcastClearSound(bot.rid, TotalLines, bonus, bot.combo - 1, bot.bonus_sound, ALLClear, bot.botid)
		bot.cancombo = true
	else
		bot.combo = 0
		bot.bonus_sound = false
	end


	GTetris:ProcessGarbage(bot, TotalLines, bonus, ALLClear)
end

local abs = math.abs
local gtcopy = table.Copy

function ggtcopy(t)
	local r = {}
	for k,v in next, t do
		r[k] = {}
		for x,y in next, v do
			r[k][x] = y
		end
	end
	return r
end

function GTetris:BotLocalToGrids(Origin, mShape)
	local ret = {}
	for k,v in next, mShape do
		ret[k] = {v[1] + Origin.y, v[2] + Origin.x}
	end
	return ret
end

function GTetris:GetHolesCount(grid, st, ed)
	local holes = 0
	for i = st, ed, -1 do
		for k,v in next, grid[i] do
			if(v == 0) then holes = holes + 1 else continue end
		end
	end
	return holes
end

function GTetris:GetAffectedCols(shape)
	local mins, maxs = -1, -1
	for k,v in next, shape do
		if(mins == -1) then
			mins = v[2]
		else
			if(mins < v[2]) then
				mins = v[2]
			end
		end
		if(maxs == -1) then
			maxs = v[2]
		else
			if(maxs > v[2]) then
				maxs = v[2]
			end
		end
	end
	return mins, maxs
end

function GTetris:GetAffectedRows(shape)
	local mins, maxs = -1, -1
	for k,v in next, shape do
		if(mins == -1) then
			mins = v[1]
		else
			if(mins < v[1]) then
				mins = v[1]
			end
		end
		if(maxs == -1) then
			maxs = v[1]
		else
			if(maxs > v[1]) then
				maxs = v[1]
			end
		end
	end
	return mins, maxs
end

function GTetris:GetBoardHeight(bot, grid)
	for i = -2, bot.rows - 1, 1 do
		for k,v in next, grid[i] do
			if(v != 0) then return bot.rows - i end
		end
	end
	return 0
end

function GTetris:GetBoardHeightRaw(bot, grid)
	for i = -2, bot.rows - 1, 1 do
		for k,v in next, grid[i] do
			if(v != 0) then return i end
		end
	end
	return 0
end

function GTetris:IsHolsVisible(grid, x)
	for i = bot.rows - 1, -2, -1 do
		local p = grid[i][x]

		if(p != 0) then return false end
	end 
	return true
end

function GTetris:BotPlaceBlock(bot, shapes, minos)
	if(!GTetris.Place) then
		for k,v in next, shapes do
			bot.grid[v[1]][v[2]] = minos
		end
	else
		if(GTetris:SpinBonus(shapes, bot.grid)) then
			GTetris.Bonus = true
		end
		for k,v in next, shapes do
			GTetris.Grids[v[1]][v[2]] = minos
		end
		GTetris:vPlaceBlock()
	end
end

function GTetris:SimulatePlace(grid, shape, minos)
	local vgrid = ggtcopy(grid)
	for k,v in next, shape do
		vgrid[v[1]][v[2]] = minos
	end
	return vgrid
end

function GTetris:SimulatePlaceAndClear(bot, grid, shape, minos)
	local vgrid = ggtcopy(grid)
	local lineCleared = 0
	local emptyCol = {}
	for i = 0, bot.cols - 1, 1 do
		emptyCol[i] = 0
	end
	for k,v in next, shape do
		vgrid[v[1]][v[2]] = 1
	end

	local tmp = ""

	for i = -3, bot.rows - 1, 1 do
		local cols = grid[i]
		if(!cols) then continue end
		local bfull = true
		for k,v in next, cols do
			if(v == 0) then
				bfull = false
			end
		end
		if(bfull) then
			vgrid[i] = emptyCol
			for x = i, -3, -1 do
				local pRow = x - 1
				if(pRow > 0) then
					vgrid[x] = gtcopy(vgrid[pRow])
				end
			end
			lineCleared = lineCleared + 1
		end
	end

	return vgrid, lineCleared
end

function GTetris:TraceToTop(grid, x, y)
	for _ = y - 1, -2, -1 do
		local y = grid[_][x]
		if(y != 0) then return false end
	end
	return true
end

function GTetris:FindCoveredHoles(bot, grid)
	local num = 0
	for y = bot.rows - 1, -2, -1 do
		for x = 0, bot.cols - 1, 1 do
			local up = grid[y - 1][x] -- it should always be valid
			local c = grid[y][x]
			if(up == 0 || c != 0) then continue end
			if(!GTetris:TraceToTop(grid, x, y)) then
				num = num + 1
			end
		end
	end
	return num
end

function GTetris:FindCoveredHolesNoGarbage(bot, grid)
	local num = 0
	for y = bot.rows - 1, -2, -1 do
		for x = 0, bot.cols - 1, 1 do
			local down = grid[y - 1]
			if(down) then
				if(down[x] == 8) then continue end
			end
			local up = grid[y - 1][x] -- it should always be valid
			local c = grid[y][x]
			if(up == 0 || up == 8 || c != 0) then continue end
			if(!GTetris:TraceToTop(grid, x, y)) then
				num = num + 1
			end
		end
	end
	return num
end

function GTetris:FindIDepends(bot, grid)
	local col = bot.cols - 1
	local rec = {}

	local num = 0
	local deep = 0

	for y = bot.rows - 1, -2, -1 do
		for x = 0, col, 1 do
			if(x == bot.quad_hole_x && bot.quad_hole_vis) then continue end
			local v = grid[y][x]
			if(v != 0 || rec[x]) then continue end
			if(x == 0) then -- Left
				local a = grid[y][x + 1]
				local b = grid[y - 2][x + 1]
				local c = grid[y - 1][x + 1]
				local e = grid[y - 1][x]
				local f = grid[y - 2][x]
				if(a == 0 || b == 0 || c == 0 ||
					a == 8 || b == 8 || c == 8 || e != 0 || f != 0) then
					continue
				end

				rec[x] = true
				num = num + 1
			elseif(x == col) then -- Right
				local a = grid[y][x - 1]
				local b = grid[y - 2][x - 1]
				local c = grid[y - 1][x - 1]
				local e = grid[y - 1][x]
				local f = grid[y - 2][x]
				if(a == 0 || b == 0 || c == 0 ||
					a == 8 || b == 8 || c == 8 || e != 0 || f != 0) then
					continue
				end
				rec[x] = true
				num = num + 1
			else -- Middle
				local a = grid[y][x - 1]
				local b = grid[y - 2][x - 1]
				local c = grid[y][x + 1]
				local d = grid[y - 2][x + 1]
				local e = grid[y - 1][x + 1]
				local f = grid[y - 1][x - 1]
				local g = grid[y - 1][x]
				local h = grid[y - 2][x]
				if(a == 0 || b == 0 || c == 0 || d == 0 ||
					e == 0 || f == 0 || a == 8 || b == 8 ||
					c == 8 || d == 8 || e == 8 || f == 8 ||
					g != 0 || h != 0) then
					continue
				end
				rec[x] = true
				num = num + 1
			end
		end
	end
	return num, deep
end

function GTetris:FindTShape(bot, grid, bFind)
	local height = GTetris:GetBoardHeight(bot, bot.grid)
	if(bot.quad_hole_vis || height > 13 || !bot.t_spin_enabled) then return 0, 0 end -- no t-spins when in danger
	local r, c = bot.rows - 1, bot.cols - 2
	local t_spins = 0
	local pot_t_spins = 0
	if(#bot.t_spin_shape > 0) then return 1, 0 end
	local t_pos = {}
	for y = r, -2, -1 do
		for x = 1, c, 1 do
			local pos = grid[y][x]

			if(pos != 0) then continue end

			local x1, x2, x3 = grid[y], grid[y + 1], grid[y - 1]

			if(!x2 || !x3) then continue end

			local e1, e2 = 0, 0
			for k,v in next, x1 do
				if(v == 0) then e1 = e1 + 1 else continue end
			end
			for k,v in next, x2 do
				if(v == 0) then e2 = e2 + 1 else continue end
			end

			local a, b, c = x1[x - 1], x1[x + 1], x2[x]

			if(e1 > 5 && e2 > 5) then continue end

			if(!a || !b || !c || a != 0 || b != 0 || c != 0 || pos != 0) then continue end

			local a, b, c, d, e, f = x1[x - 2], x1[x + 2], x2[x - 1], x2[x + 1], x3[x - 1], x3[x + 1]

			--[[
				  e     f
				a###b
				   c#d
			]]

			if(a == 0 || b == 0 || c == 0 || d == 0) then continue end

			if(e == 0 && f == 0) then
				pot_t_spins = pot_t_spins + 1
			else
				if(bFind) then
					bot.has_tspin = true
					table.insert(bot.t_spin_shape, {y, x})
					table.insert(bot.t_spin_shape, {y, x + 1})
					table.insert(bot.t_spin_shape, {y, x - 1})
					return
				end
				t_spins = t_spins + 1
			end

		end
	end

	return t_spins, pot_t_spins
end

function GTetris:SpinBonus(bot, shape, grid)
	if(bot.rulesets.Spins == "STUPID") then return true end -- Mega troll
	if(!GTetris:IsPossiblePosition(shape, {x = 0, y = 1}, grid, bot) &&
		!GTetris:IsPossiblePosition(shape, {x = 0, y = -1}, grid, bot) &&
		!GTetris:IsPossiblePosition(shape, {x = 1, y = 0}, grid, bot) &&
		!GTetris:IsPossiblePosition(shape, {x = -1, y = 0}, grid, bot)) then
		return true
	end
	return false
end

function GTetris:HasTinBag(bot)
	for k,v in next, bot.bags do
		if(v == 6) then return true end
	end
	return false
end

function GTetris:Evaluate(bot, cgrid, shape)
	local score = 0
	local flatness = {}
	local bhraw = GTetris:GetBoardHeightRaw(bot, cgrid)
	local bh = bhraw - 4
	local grid, clines = GTetris:SimulatePlaceAndClear(bot, cgrid, shape, bot.minos)

	local minos = bot.minos

	local covholes = GTetris:FindCoveredHoles(bot, grid)
	local covholes_self = GTetris:FindCoveredHolesNoGarbage(bot, grid)
	local st, ed = GTetris:GetAffectedRows(shape)

	local t_spins, potential_t_spins = GTetris:FindTShape(bot, grid)

	local i_depends, i_deep = GTetris:FindIDepends(bot, grid)

	local _x = 0

	local _4w = bot.cols == 4

	local att_clines = 0.5
	local att_overhang = -2
	local att_i_depends = -30
	local att_i_deep = -1
	local att_cov_holes = -10
	local att_cov_holes_self = -0.5
	local att_blocked_downstack = -10
	local att_ruined_t_spin = -10
	local att_potential_t_spins = 6
	local att_t_spins = 20
	local att_t_spin_clear = 120

	if(bot.has_tspin) then
		if(t_spins == 0) then
			score = score + att_ruined_t_spin
		end
	end

	local t_tr = 0

	local dsCheck = false

	if(bot.first_hole[1] != - 32) then
		if(abs(bot.first_hole[2] - bhraw) <= 3) then
			dsCheck = true
		end
	end

	if(bhraw > 10 && bot.quad_hole_vis) then
		att_clines = -2.5
	end

	if(bhraw < 10) then
		att_clines = 5
	end

	if(bot.combo > 0 && clines > 0) then
		att_clines = 7
	end

	if(clines >= 4) then
		att_clines = 100
	end

	local c, r = bot.cols - 1, bot.rows - 1
	local prev = bot.rows
	for x = 0, c, 1 do
		local lt = 0
		local cout = false
		if(x == bot.quad_hole_x && bot.quad_hole_vis) then continue end
		for y = bh, r, 1 do
		if(grid[y][x] == 0 || grid[y][x] == 8) then if(grid[y][x] == 8) then cout = true end continue end
			if(lt == 0) then
				lt = y
			else
				if(y > lt && grid[y - 1][x] == 0) then
					lt = y
					_x = _x + abs((y - 1) - prev)
				end
			end
		end
		if(cout) then continue end

		if(lt == 0) then
			lt = bot.rows
		end
		if(x != 0) then
			_x = _x + abs(lt - prev)
		end

		prev = lt
	end

	for k,v in next, shape do
		if(v[2] == bot.quad_hole_x && bot.quad_hole_vis && !_4w) then
			score = score - 5
		end
		if(dsCheck) then
			if(v[2] == bot.first_hole[1]) then
				score = score + att_blocked_downstack
			end
		end
		local a = cgrid[v[1] + 1]
		if(a) then
			if(a[v[2]] == 0) then
				score = score + att_overhang
			else
				if(a[v[2]] != minos) then
					score = score + 1
				end
			end
		end
		if(minos != 6) then
			for x,y in next, bot.t_spin_shape do
				if(y[2] == v[2]) then
					score = score + att_ruined_t_spin
					break
				end
			end
		else
			for x,y in next, bot.t_spin_shape do
				if(y[2] == v[2]) then
					score = score + att_t_spin_clear
				end
			end
		end
	end
	if(_4w) then
		att_clines = 100
		att_i_depends = 0
		att_cov_holes = 0
	else
		score = score - _x
	end

	score = score + (4 - abs(st - ed))
	score = score + st * 3
	score = score + (covholes * att_cov_holes)
	score = score + (covholes_self * att_cov_holes_self)

	score = score + clines * att_clines

	score = score + potential_t_spins * att_potential_t_spins
	score = score + t_spins * att_t_spins

	score = score + i_depends * att_i_depends

	return score
end

function GTetris:QuickTest(bot, vgrid, minos)
	local h = ((bot.rows - 4) - (GTetris:GetBoardHeight(bot, vgrid)))
	local ro, c = bot.rows - 1, bot.cols - 1

	local fScore, fShape = 0, GTetris.Shapes[minos][0]
	local inited = false
	bot.first_hole = {-32, -32}
	local f = false
	for y = h, ro, 1 do
		for x = -2, c, 1 do
			local v = vgrid[y][x]
			if(v == 0) then
				local va = vgrid[y]
				if(va[x + 1] != 0 && va[x - 1] != 0 && vgrid[y - 1][x] != 0) then
					bot.first_hole = {x, y}
					f = true
					break
				end
			end
		end
		if(f) then break end
	end

	for y = ro, -3, -1 do
		for x = -2, c, 1 do
			for r = 0, 3, 1 do
				local shape = GTetris.Shapes[minos][r]
				local origin = {x = x, y = y}
				if(GTetris:IsPossiblePosition(shape, origin, vgrid, bot) && !GTetris:IsPossiblePosition(shape, {x = x, y = y + 1}, vgrid, bot)) then
					local gShape = GTetris:BotLocalToGrids(origin, shape)
					if(minos == 1) then
						local vis = false
						for k,v in next, gShape do
							if(GTetris:TraceToTop(vgrid, v[2], v[1])) then vis = true break end
						end
						if(!vis) then continue end
					end
					local virtualgrid = GTetris:SimulatePlace(vgrid, gShape, minos)
					local score = GTetris:Evaluate(bot, virtualgrid, gShape)
					if(score > fScore || !inited) then
						fShape = gShape
						fScore = score

						inited = true
					end
				end
			end
		end
	end

	return fScore, fShape
end

function GTetris:AdjustPPS(bot, pps)
	bot.pps = pps
	bot.interval = 1 / pps
end

function GTetris:BotHold(bot)
	if(!bot.can_hold) then return end
	if(bot.hblock == -1) then
		bot.hblock = bot.currentblock

		local nextID = 1
		for k,v in next, bot.bags do
			nextID = v
			break
		end

		bot.currentblock = nextID

		GTetris:GetBotRandomBlock(bot)
	else
		local OriginalBlock = bot.currentblock
		local OriginalHoldBlock = bot.hblock
		bot.hblock = OriginalBlock
		bot.currentblock = OriginalHoldBlock
	end

	GTetris:BroadcastHoldSound(bot.rid, bot.botid)
	bot.can_hold = false

end

function GTetris:ShouldDie(bot, grid)
	return bot.grid[-2][math.floor(bot.cols / 2)] != 0
end

function GTetris:Think(bot, minos) -- This is SLOW

	local vgrid = gtcopy(bot.grid)
	local matrix = gtcopy(bot.grid)

	local fScore, fShape = 0, GTetris.Shapes[minos][0]
	local inited = false

	bot.board_height = GTetris:GetBoardHeight(bot, vgrid)

	local panicHeight = 8
	local scale = math.max(math.min(1.5, bot.board_height / panicHeight), 1)
	GTetris:AdjustPPS(bot, bot.basepps * scale)

	bot.has_tspin = false
	bot.t_spin_shape = {}
	GTetris:FindTShape(bot, vgrid, true)

	if(bot.quad_hole_x == -1) then
		local rnd = math.random(1, 3)

		if(rnd == 1) then
			bot.quad_hole_x = 0
		elseif(rnd == 3) then
			bot.quad_hole_x = bot.cols - 1
		else
			if(bot.cols >= 10) then
				local rnd = math.random(1, 2)

				-- 6-3 Stacking
				if(rnd == 1) then
					bot.quad_hole_x = 3
				else
					bot.quad_hole_x = 6
				end
			end
		end
	else
		if(!bot.quad_hole_vis && bot.board_height <= 4) then
			if(GTetris:TraceToTop(vgrid, 0, 20)) then
				bot.quad_hole_x = 0
			end
			if(GTetris:TraceToTop(vgrid, bot.cols - 1, 20)) then
				bot.quad_hole_x = bot.cols - 1
			end
		end
	end

	bot.quad_hole_vis = GTetris:TraceToTop(vgrid, bot.quad_hole_x, 20)

	fScore, fShape = GTetris:QuickTest(bot, vgrid, minos)

	if(bot.can_hold) then
		local hminos = bot.hblock
		if(bot.hblock == -1) then
			hminos = bot.bags[1]
		end

		local hScore, hShape = GTetris:QuickTest(bot, vgrid, hminos)

		if(hScore > fScore) then
			fShape = hShape
			minos = hminos

			GTetris:BotHold(bot)
		end
	end

	return fScore, fShape, minos
end

function GTetris:BotIsInside(Shape, xOffs, yOffs, bot)
	for k,v in next, Shape do
		local px, py = v[2] + xOffs, v[1] + yOffs
		if(px < 0 || px >= bot.cols || py < -20 || py >= bot.rows) then
			return false
		end
	end
	return true
end

--[[
function GTetris:BotLocalToGrids(Origin, mShape)
	local ret = {}
	for k,v in next, mShape do
		table.insert(ret, {v[1] + Origin.y, v[2] + Origin.x})
	end
	return ret
end
]]

function GTetris:IsPossiblePosition(Shape, Origin, grid, bot)
	local _Shape = {}
	for k,v in next, Shape do
		_Shape[k] = {v[1] + Origin.y, v[2] + Origin.x}
	end
	if(!GTetris:BotIsInside(Shape, Origin.x, Origin.y, bot)) then return false end
	for k,v in next, _Shape do
		if(grid[v[1]][v[2]] != 0) then return false end
	end
	return true
end