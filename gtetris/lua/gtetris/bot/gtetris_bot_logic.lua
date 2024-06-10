--[[
	GTetris made by Meiryi :
		None of these codes should be edited, reuploaded, or claim it's made by yourself
		I don't care if you think anywhre needs a edit/patch, just let me know and I'll do it myself!
]]

BOT_ENUMS_STACKING = 0
BOT_ENUMS_DOWNSTACKING = 0
BOT_ENUMS_COUNTERSPIKING = 0

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

function GTetris:GetBoardHeight(grid)
	for i = -2, GTetris.Rows - 1, 1 do
		for k,v in next, grid[i] do
			if(v != 0) then return GTetris.Rows - i end
		end
	end
	return 0
end

function GTetris:GetBoardHeightRaw(grid)
	for i = -2, GTetris.Rows - 1, 1 do
		for k,v in next, grid[i] do
			if(v != 0) then return i end
		end
	end
	return 0
end

function GTetris:IsHolsVisible(grid, x)
	for i = GTetris.Rows - 1, -2, -1 do
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

function GTetris:SimulatePlaceAndClear(grid, shape, minos)
	local vgrid = ggtcopy(grid)
	local lineCleared = 0
	local emptyCol = {}
	for i = 0, GTetris.Cols - 1, 1 do
		emptyCol[i] = 0
	end
	for k,v in next, shape do
		vgrid[v[1]][v[2]] = 1
	end

	local tmp = ""

	for i = GTetris.MaximumOverflowRange, GTetris.Rows - 1, 1 do
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
			for x = i, GTetris.MaximumOverflowRange, -1 do
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
	for y = GTetris.Rows - 1, -2, -1 do
		for x = 0, GTetris.Cols - 1, 1 do
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
	for y = GTetris.Rows - 1, -2, -1 do
		for x = 0, GTetris.Cols - 1, 1 do
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
	local col = GTetris.Cols - 1
	local rec = {}

	local num = 0
	local deep = 0

	for y = GTetris.Rows - 1, -2, -1 do
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

local enableTSpin = true
function GTetris:FindTShape(bot, grid, bFind)
	local height = GTetris:GetBoardHeight(bot.grid)
	if(bot.quad_hole_vis || height > 13 || !enableTSpin) then return 0, 0 end -- no t-spins when in danger
	local r, c = GTetris.Rows - 1, GTetris.Cols - 2
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

function GTetris:SpinBonus(shape, grid)
	if(!GTetris:IsPossiblePosition(shape, {x = 0, y = 1}, grid) &&
		!GTetris:IsPossiblePosition(shape, {x = 0, y = -1}, grid) &&
		!GTetris:IsPossiblePosition(shape, {x = 1, y = 0}, grid) &&
		!GTetris:IsPossiblePosition(shape, {x = -1, y = 0}, grid)) then
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
	local bhraw = GTetris:GetBoardHeightRaw(cgrid)
	local bh = bhraw - 4
	local grid, clines = GTetris:SimulatePlaceAndClear(cgrid, shape, bot.minos)

	local minos = bot.minos

	local covholes = GTetris:FindCoveredHoles(bot, grid)
	local covholes_self = GTetris:FindCoveredHolesNoGarbage(bot, grid)
	local st, ed = GTetris:GetAffectedRows(shape)

	local t_spins, potential_t_spins = GTetris:FindTShape(bot, grid)

	local i_depends, i_deep = GTetris:FindIDepends(bot, grid)

	local _x = 0

	local _4w = GTetris.Cols == 4

	local att_clines = 0.5
	local att_overhang = -2
	local att_i_depends = -30
	local att_i_deep = -1
	local att_cov_holes = -10
	local att_cov_holes_self = -0.5
	local att_blocked_downstack = -10
	local att_ruined_t_spin = -10
	local att_potential_t_spins = 8
	local att_t_spins = 30
	local att_t_spin_clear = 100

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

	if(clines >= 4) then
		att_clines = 100
	end

	local c, r = GTetris.Cols - 1, GTetris.Rows - 1
	local prev = GTetris.Rows
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
			lt = GTetris.Rows
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
	local h = ((GTetris.Rows - 4) - (GTetris:GetBoardHeight(vgrid)))
	local ro, c = GTetris.Rows - 1, GTetris.Cols - 1

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

	local origin = {x = 0, y = 0}
	local shape = GTetris.Shapes[minos][0]
	for y = ro, -3, -1 do
		for x = -2, c, 1 do
			for r = 0, 3, 1 do
				shape = GTetris.Shapes[minos][r]
				origin.x = x
				origin.y = y
				if(GTetris:IsPossiblePosition(shape, origin, vgrid) && !GTetris:IsPossiblePosition(shape, {x = x, y = y + 1}, vgrid)) then
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


function GTetris:Think(bot, minos) -- This is SLOW

	local vgrid = gtcopy(bot.grid)
	local matrix = gtcopy(bot.grid)

	local fScore, fShape = 0, GTetris.Shapes[minos][0]
	local inited = false

	bot.board_height = GTetris:GetBoardHeight(vgrid)

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
			bot.quad_hole_x = GTetris.Cols - 1
		else
			if(GTetris.Cols >= 10) then
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
			if(GTetris:TraceToTop(vgrid, GTetris.Cols - 1, 20)) then
				bot.quad_hole_x = GTetris.Cols - 1
			end
		end
	end

	bot.quad_hole_vis = GTetris:TraceToTop(vgrid, bot.quad_hole_x, 20)

	fScore, fShape = GTetris:QuickTest(bot, vgrid, minos)

	if(GTetris.CanHold && GTetris.Place) then
		local hminos = GTetris.CurrentHoldBlockID
		if(GTetris.CurrentHoldBlockID == -1) then
			hminos = bot.bags[1]
		end
		local hScore, hShape = GTetris:QuickTest(bot, vgrid, hminos)

		if(hScore > fScore) then
			fShape = hShape
			minos = hminos

			GTetris:Hold()
		end
	end

	return fScore, fShape, minos
end

function GTetris:BotIsInside(Shape, xOffs, yOffs)
	for k,v in next, Shape do
		local px, py = v[2] + xOffs, v[1] + yOffs
		if(px < 0 || px >= GTetris.Cols || py < GTetris.MaximumOverflowRange || py >= GTetris.Rows) then
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

function GTetris:IsPossiblePosition(Shape, Origin, grid)
	local _Shape = {}
	for k,v in next, Shape do
		_Shape[k] = {v[1] + Origin.y, v[2] + Origin.x}
	end
	if(!GTetris:BotIsInside(Shape, Origin.x, Origin.y)) then return false end
	for k,v in next, _Shape do
		if(grid[v[1]][v[2]] != 0) then return false end
	end
	return true
end

function GTetris:vPlaceBlock()

	local nextID = 1
	for k,v in next, GTetris.Bags do
		nextID = v
		break
	end

	if(GTetris.Bonus) then
		GTetris:SetupSideText("Bonus", GTetris:GetBlockName(GTetris.CurrentBlockID).." SPIN", 2, GTetris:GetColor(GTetris.CurrentBlockID))
	end

	GTetris.LastPlaceOrigin = GTetris:vOrigin(GTetris.Origin.x, GTetris:TraceYPos())

	GTetris:GetRandomBlock()
	GTetris:CheckLines(GTetris.Bonus)

	local w = GTetris:GetBlockWide(nextID)
	GTetris.RotationState = 0
	GTetris.IntLockTimer = 0
	GTetris.bTouchGround = false
	GTetris.CurrentBlockID = nextID
	GTetris.Origin = {x = (GTetris.Cols / 2) - math.Round((w / 2) + 0.5, 0), y = -3}
	GTetris.CanHold = true

	GTetris.Bonus = false
	GTetris:SyncGrids()
	GTetris:SyncCDetails()

	if(!GTetris:ShapeFits(GTetris:GetCurrentShape(), GTetris.NullOrigin)) then
		GTetris:PlayerDie()
	end

	GTetris.PiecesPlaced = GTetris.PiecesPlaced + 1
end