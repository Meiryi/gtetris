--[[
	GTetris made by Meiryi :
		None of these codes should be edited, reuploaded, or claim it's made by yourself
		I don't care if you think anywhre needs a edit/patch, just let me know and I'll do it myself!
]]

GTetris.Cols = 10
GTetris.Rows = 20

GTetris.MaximumOverflowRange = -20

GTetris.BackgroundColor = Color(160, 160, 160, 255)

GTetris.CellSize = ScreenScale(12)
GTetris.GridSize = 1

GTetris.TotalW, GTetris.TotalH = (GTetris.Cols * GTetris.CellSize) + GTetris.GridSize, (GTetris.Rows * GTetris.CellSize) + GTetris.GridSize

GTetris.Grids = {}

for i = GTetris.MaximumOverflowRange, GTetris.Rows - 1, 1 do
	GTetris.Grids[i] = {}
	for x = 0, GTetris.Cols - 1, 1 do
		GTetris.Grids[i][x] = 0
	end
end

function GTetris:PrintGrids()
	for k,v in next, GTetris.Grids do
		local tmp = ""
		for x,y in next, v do
			tmp = tmp.." "..y
		end
		print(tmp.."\n")
	end
end

function GTetris:TwoWide()
	for i = GTetris.MaximumOverflowRange, GTetris.Rows - 1, 1 do
		GTetris.Grids[i] = {}
		for x = 0, GTetris.Cols - 1, 1 do
			if(x <= 1 || i <= 0) then GTetris.Grids[i][x] = 0 continue end
			GTetris.Grids[i][x] = 1
		end
	end
end

function GTetris:ReloadGrids()
	for i = GTetris.MaximumOverflowRange, GTetris.Rows - 1, 1 do
		GTetris.Grids[i] = {}
		for x = 0, GTetris.Cols - 1, 1 do
			GTetris.Grids[i][x] = 0
		end
	end
	GTetris.TotalW, GTetris.TotalH = (GTetris.Cols * GTetris.CellSize) + GTetris.GridSize, (GTetris.Rows * GTetris.CellSize) + GTetris.GridSize
	local w = GTetris:GetBlockWide(GTetris.CurrentBlockID)
	GTetris.Origin = {x = (GTetris.Cols / 2) - math.Round((w / 2) + 0.5, 0), y = -3}
	GTetris.Bonus = false
	GTetris.CanCombo = false
	GTetris.WarnGrid = false
	GTetris.Combo = 0
	GTetris.Garbages = {}
	GTetris:ResetBags()
	GTetris:GetRandomBlock()

	GTetris.GarbageSent = 0
	GTetris.GarbageRecordTime = SysTime()
	GTetris.PiecesPlaced = 0
	GTetris.PieceRecordTime = SysTime()

	GTetris:SyncCDetails()
end

function GTetris:InsertAttackNumbers(pos, attacks, cancel, cancel_attatck)
	local prevDamage = 0
	for k,v in next, GTetris.DamageNumbers do
		if(!cancel && !cancel_attatck) then
			prevDamage = prevDamage + v.attacks
		end
		v.time = -1
	end
	attacks = attacks + prevDamage
	table.insert(GTetris.DamageNumbers, {
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

function GTetris:InsertALLClears(ply)
	table.insert(GTetris.ALLClears, {
		time = SysTime() + 2,
		rotate = 0,
		targetrotate = 720,
		alpha = 0,
		size = 0,
		targetsize = 1.25,
		color = Color(255, 222, 41, 255)
	})
end

function GTetris:GetPlacePosition(lines, cancel, cancel_attatck)
	local x, y = GTetris.LastPlaceOrigin.x, GTetris.LastPlaceOrigin.y
	local Shape = GTetris:GetCurrentShapeLocal()
	local w, h = 0, 0
	for k,v in next, Shape do
		if(v[2] > w) then
			w = v[2]
		end
		if(v[1] > h) then
			h = v[1]
		end
	end
	x, y = x + (w), y + (h)
	GTetris:InsertAttackNumbers({x = x, y = y}, lines, cancel, cancel_attatck)
end

hook.Add("DrawOverlay", "eyerape", function()
	--draw.RoundedBox(0, 0, 0, ScrW(), ScrH(), Color(math.random(0, 255), math.random(0, 255), math.random(0, 255), 255))
end)