--[[
	GTetris made by Meiryi :
		None of these codes should be edited, reuploaded, or claim it's made by yourself
		I don't care if you think anywhre needs a edit/patch, just let me know and I'll do it myself!
]]

function GTetris:CreateBotInstances(rID, roomData)
	local room = roomData
	local mrows, rows, cols = room.Rulesets.MaximumOverflowRange ,room.Rulesets.Rows, room.Rulesets.Cols
	local tmp = {}
	for i = mrows, rows - 1, 1 do
		tmp[i] = {}
		for x = 0, cols - 1, 1 do
			tmp[i][x] = 0
		end
	end

	local assignID = 32767
	for k,v in next, roomData.Bots do
		local ret = GTetris:AddBots(v.name, v.type, v.pps, tmp, cols, rows, rID, roomData.Rulesets, v.tspins, assignID)

		GTetris.Rooms[rID].Bots_InGame[ret.botid] = ret

		GTetris:GetBotRandomBlock(GTetris.Rooms[rID].Bots_InGame[ret.botid])

		GTetris:BroadcastBotGrids(rID, ret.botid)

		assignID = assignID + 32
	end
end

function GTetris:GetBagString(bags)
	local e = ""
	for k,v in next, bags do
		e = e..v
	end
	return e
end

function GTetris:SyncBotDetails(rID, bID)
	local room = GTetris.Rooms[rID]
	local bot = GTetris.Rooms[rID].Bots_InGame[bID]

	for k,v in next, room.Players do
		local p = Entity(v)
		net.Start("GTetris-SyncBotDetails")
		net.WriteInt(bID, 32)
		net.WriteString(bot.name)
		net.WriteInt(bot.currentblock, 8)
		net.WriteInt(bot.hblock, 8)
		net.WriteString(GTetris:GetBagString(bot.bags))
		net.WriteInt(bot.garbages, 32)
		net.WriteInt(bot.target, 32)
		net.WriteBool(bot.alive)
		net.WriteInt(bot.combo, 32)
		net.WriteInt(bot.b2b, 32)
		net.Send(p)
	end
end

function GTetris:BroadcastBotGrids(rID, bID)
	local room = GTetris.Rooms[rID]
	local bot = GTetris.Rooms[rID].Bots_InGame[bID]
	local ctx, len = bot.data, bot.len
	for k,v in next, room.Players do
		local p = Entity(v)
		net.Start("GTetris-SyncGrids")
		net.WriteInt(bID, 32)
		net.WriteUInt(len, 32)
		net.WriteData(ctx, len)
		net.WriteBool(true)
		net.WriteString(bot.name)
		net.WriteInt(bot.currentblock, 8)
		net.WriteInt(bot.hblock, 8)
		net.WriteString(GTetris:GetBagString(bot.bags))
		net.WriteInt(bot.garbages, 32)
		net.WriteInt(bot.target, 32)
		net.WriteBool(bot.alive)
		net.WriteInt(bot.combo, 32)
		net.WriteInt(bot.b2b, 32)
		net.Send(p)
	end
end

function GTetris:SyncBotGrids(rID, bID)
	local room = GTetris.Rooms[rID]
	local bot = GTetris.Rooms[rID].Bots_InGame[bID]
	local ctx, len = bot.data, bot.len
	for k,v in next, room.Players do
		local p = Entity(v)
		net.Start("GTetris-SyncGrids")
		net.WriteInt(bID, 32)
		net.WriteUInt(len, 32)
		net.WriteData(ctx, len)
		net.WriteBool(true)
		net.WriteString(bot.name)
		net.WriteInt(bot.currentblock, 8)
		net.WriteInt(bot.hblock, 8)
		net.WriteString(GTetris:GetBagString(bot.bags))
		net.WriteInt(bot.garbages, 32)
		net.WriteInt(bot.target, 32)
		net.WriteBool(bot.alive)
		net.WriteInt(bot.combo, 32)
		net.WriteInt(bot.b2b, 32)
		net.Send(p)
	end
end

hook.Add("Think", "GTetris-BotsProcessing", function()
	for k,v in next, GTetris.Rooms do
		if(!v.Bots_InGame == nil) then continue end
		for x,y in next, v.Bots_InGame do
			if(y.thinktime > SysTime() || !y.alive) then continue end
			if(GTetris:ShouldDie(y, y.grid)) then
				for o,p in next, y.grid do
					for q,w in next, v do
						if(w == 0) then continue end
							y.grid[o][q] = 8
					end
				end
				if(GTetris.TempData[y.rid]) then
					if(!GTetris.TempData[y.rid][y.botid]) then
						GTetris.TempData[y.rid][y.botid] = {
							attacks = 0,
							pieces = 0,
							dietime = -1,
						}
					else
						GTetris.TempData[y.rid][y.botid].dietime = SysTime()
					end
				end
				y.target = -1
				y.alive = false
				GTetris:RandAttackTarget()
				GTetris:SyncBotGrids(y.rid, y.botid)
				GTetris:BroadcastKillfeed(y.rid, y.lastattackindex, y.botid)
				continue
			end
			y.minos = y.currentblock
			if(!y.minos) then continue end
			local score, shape, minos = GTetris:Think(y, y.minos)
			y.bonus = GTetris:SpinBonus(y, shape, y.grid)

			for k,v in next, shape do
				y.grid[v[1]][v[2]] = minos
			end

			GTetris:BroadcastPlaceSound(y.rid, y.botid)

			y.can_hold = true

			y.currentblock = y.bags[1]
			GTetris:GetBotRandomBlock(y)

			local attacks = GTetris:CheckLines(y, y.bonus)

			local ctx, len = GTetris:GetCompressedData(y.grid)

			if(GTetris.TempData[y.rid]) then
				if(!GTetris.TempData[y.rid][y.botid]) then
					GTetris.TempData[y.rid][y.botid] = {
						attacks = 0,
						pieces = 1,
						dietime = -1,
					}
				else
					GTetris.TempData[y.rid][y.botid].pieces = GTetris.TempData[y.rid][y.botid].pieces + 1
				end
			end

			y.data = ctx
			y.len = len

			GTetris:SyncBotGrids(k, x)


			y.bonus = false
			y.thinktime = SysTime() + y.interval
		end
	end
end)