--[[
	GTetris made by Meiryi :
		None of these codes should be edited, reuploaded, or claim it's made by yourself
		I don't care if you think anywhre needs a edit/patch, just let me know and I'll do it myself!
]]

GTetris.Bots = {}

function GTetris:AddBots(name, type)
	local id = bit.tohex(math.random(1, 102400), 8)
	local pps = 2.5

 	local instance = {
 		name = name,
 		type = type,
 		grid = table.Copy(GTetris.Grids),
 		testgrid = table.Copy(GTetris.Grids),
 		origin = GTetris:vOrigin(0, 0),
 		minos = math.random(1, 7),
 		rotate = 0,
 		bags = table.Shuffle(table.Copy(GTetris.Bags)),

 		quad_hole_x = -1,
 		quad_hole_vis = false,

 		board_height = 0,

 		hold_minos = -1,
 		can_hold = true,

 		thinktime = 0,

 		basepps = pps,
 		pps = pps,
 		interval = 1 / pps,
 		curtime = 0,

 		first_hole = {-32, -32},

 		garbages = 0,
 		combo = 0,

 		has_tspin = false,
 		t_spin_shape = {},
 		t_spin_origin = {x = 0, y = 0},
 		t_spin_enabled = true,

 		max_predict_pieces = 4, 

 		lastscore = 0,

 		state = 0,
 	}
 	GTetris.Bots[id] = instance

 	GTetris:ResetBotBags(id)
end

GTetris:AddBots("Bot01", "Meiryi")

local curtime = SysTime()

local __break = false

function GTetris:PrintBotGrids(grid)
	local tmp = ""
	for i = 0, GTetris.Rows - 1, 1 do
		for k,v in next, grid[i] do
			tmp = tmp.." "..v
			if(k == #grid[i]) then
				tmp = tmp.."\n"
			end
		end
	end
	print(tmp)
end

function GTetris:UpdatePPS(pps)
	for id, bot in next, GTetris.Bots do
 		bot.pps = pps
 		bot.interval = 1 / pps
	end
end

GTetris.ShouldRunBot = false
GTetris.Place = true
local testScore = true
function GTetris:ProcessBot()
	if(!GTetris.ShouldRunBot || LocalPlayer():GetNWBool("GTetris-Died", false) || !GTetris.ShouldRunLogicChecks) then return end

	local localX, localY = ScrW() / 2, ScrH() / 2
	local baseX, baseY = localX - GTetris.TotalW / 2, localY - GTetris.TotalH / 2
	local csize = GTetris.CellSize
	local gsize = GTetris.GridSize
	local fsize = csize - gsize

	for id, bot in next, GTetris.Bots do

		local color = Color(255, 255, 255, 255)

		if(!bot.quad_hole_vis) then
			color = Color(255, 0, 0, 255)
		end

		draw.RoundedBox(0, baseX + (bot.quad_hole_x * csize) + gsize, baseY - (2 * csize) + gsize, fsize, fsize, color)
		if(testScore) then
			draw.DrawText("Think Cost : "..bot.thinktime.." / Target PPS : "..bot.pps, "TargetID", localX - GTetris.RenderXOffet - GTetris.TotalW / 2, localY - GTetris.TotalH / 2 - ScrH() * 0.12, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT)
			local shape = GTetris:TraceGhostBlock()
			local score = GTetris:Evaluate(bot, bot.grid, shape)
			draw.DrawText("Current Score Test : "..score.." ("..bot.lastscore..")", "TargetID", localX - GTetris.RenderXOffet - GTetris.TotalW / 2, localY - GTetris.TotalH / 2 - ScrH() * 0.08, Color(255, 125, 255, 255), TEXT_ALIGN_LEFT)
		end

		GTetris:RenderGrids(bot.grid, localX - GTetris.RenderXOffet, localY, GTetris.CellSize, GTetris.GridSize, LocalPlayer():EntIndex(), 0, true)

		if(bot.curtime > SysTime()) then continue end

		bot.grid = table.Copy(GTetris.Grids)
		bot.testgrid = table.Copy(bot.grid)

		bot.bags = table.Copy(GTetris.Bags)

		bot.minos = GTetris.CurrentBlockID

		local st = SysTime()
		local score, shape, minos = GTetris:Think(bot, bot.minos)
		bot.thinktime = math.Round(SysTime() - st, 4)
		if(shape) then
			GTetris:BotPlaceBlock(bot, shape, minos)
		end

		bot.lastscore = score

		bot.curtime = SysTime() + bot.interval
	end
end