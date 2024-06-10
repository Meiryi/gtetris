--[[
	GTetris made by Meiryi :
		None of these codes should be edited, reuploaded, or claim it's made by yourself
		I don't care if you think anywhre needs a edit/patch, just let me know and I'll do it myself!
]]

GTetris.PlayerGrids = {}

function GTetris:SyncCurrentBlock(ply, vec, id, rot)
	ply:SetNWVector("GTetris-Origin", vec)
	ply:SetNWInt("GTetris-BlockID", id)
	ply:SetNWInt("GTetris-Rotation", rot)
end

function GTetris:AutoSetTarget(at, t)
	if(istable(at)) then
		at.target = t
	else
		at:SetNWInt("GTetris-Target", t)
	end
end

function GTetris:AutoConvert(t)
	if(istable(t)) then
		return t.botid
	else
		return t:EntIndex()
	end
end

function GTetris:ResetPlayerGrid(rID, ply)
	local room = GTetris.Rooms[rID]
	if(room == nil) then return end
	local mrows, rows, cols = room.Rulesets.MaximumOverflowRange ,room.Rulesets.Rows, room.Rulesets.Cols
	local tmp = {}
	for i = mrows, rows - 1, 1 do
		tmp[i] = {}
		for x = 0, cols - 1, 1 do
			tmp[i][x] = 0
		end
	end

	local ctx, len = GTetris:GetCompressedData(tmp)
	GTetris:SetPlayerGrid(ply, ctx, len)
end

function GTetris:SetPlayerGrid(ply, data, len)
	GTetris.PlayerGrids[ply] = {
		data = data,
		len = len,
	}
end

net.Receive("GTetris-SyncGarbage", function(len, ply)
	local lines = net.ReadInt(32)
	ply:SetNWInt("GTetris-Garbages", lines)
end)

net.Receive("GTetris-SyncHolds", function(len, ply)
	local hold = net.ReadInt(8)
	ply:SetNWInt("GTetris-Holds", hold)
end)

net.Receive("GTetris-SyncCBlock", function(len, ply)
	local vec = net.ReadVector()
	local id = net.ReadInt(8)
	local rot = net.ReadInt(8)
	GTetris:SyncCurrentBlock(ply, vec, id, rot)
end)

net.Receive("GTetris-SyncGrids", function(len, ply)
	local rID = net.ReadString()
	local len = net.ReadUInt(32)
	local ret = net.ReadData(len)

	GTetris:SetPlayerGrid(ply, ret, len)

	if(GTetris.TempData[rID]) then
		if(!GTetris.TempData[rID][ply:EntIndex()]) then
			GTetris.TempData[rID][ply:EntIndex()] = {
				attacks = 0,
				pieces = 1,
				dietime = -1,
			}
		else
			GTetris.TempData[rID][ply:EntIndex()].pieces = GTetris.TempData[rID][ply:EntIndex()].pieces + 1
		end
	end

	local room = GTetris.Rooms[rID]
	if(room == nil) then return end
	for k,v in next, room.Players do
		local p = Entity(v)
		if(p == ply) then continue end
		net.Start("GTetris-SyncGrids")
		net.WriteInt(ply:EntIndex(), 32)
		net.WriteUInt(len, 32)
		net.WriteData(ret, len)
		net.WriteBool(false)
		net.Send(p)
	end
end)

net.Receive("GTetris-GetGrids", function(len, ply)
	local rID = net.ReadString()
	local id = net.ReadInt(32)

	if(GTetris.PlayerGrids[id] == nil) then
		GTetris:ResetPlayerGrid(rID, id)
	end
	local ret = GTetris.PlayerGrids[id]
	net.Start("GTetris-SyncGrids")
	net.WriteInt(id, 32)
	net.WriteUInt(ret.len, 32)
	net.WriteData(ret.data, ret.len)
	net.WriteBool(false)
	net.Send(ply)
end)

function GTetris:EnterGame(ply, rID)
	GTetris:ResetPlayerGrid(rID, ply)
	net.Start("GTetris-StartGame")
	net.Send(ply)
end

function GTetris:CreateTestGrid(rID)
	local id = math.random(1, 32767)
		GTetris:ResetPlayerGrid(rID, id)
		GTetris:BroadcastGrids(rID, id)
end

function GTetris:BroadcastGrids(rID, ply)
	local room = GTetris.Rooms[rID]
	local ctx, len = GTetris.PlayerGrids[ply].data, GTetris.PlayerGrids[ply].len
	for k,v in next, room.Players do
		local p = Entity(v)
		net.Start("GTetris-SyncGrids")
		net.WriteInt(ply, 32)
		net.WriteUInt(len, 32)
		net.WriteData(ctx, len)
		net.WriteBool(false)
		net.Send(p)
	end
end

function GTetris:RandAttackTarget()
	for k,v in next, GTetris.Rooms do
		local players = v.Players
		local bots = v.Bots_InGame
		local list = {}
		if(table.Count(players) + table.Count(bots) <= 1) then continue end
		local newlist = table.Add(table.Copy(players), bots)
		local aliveList = {}
		for x,y in next, newlist do
			if(istable(y)) then -- bot
				if(y.alive) then
					table.insert(aliveList, y)
				end
			else
				local p = Entity(y)
				if(!IsValid(p)) then continue end
				if(!p:GetNWBool("GTetris-Died", false)) then
					table.insert(aliveList, p)
				end
			end
		end

		if(table.Count(aliveList) <= 1) then continue end
		if(table.Count(aliveList) <= 2) then
			local a = aliveList[1]
			local b = aliveList[2]
			GTetris:AutoSetTarget(a, GTetris:AutoConvert(b))
			GTetris:AutoSetTarget(b, GTetris:AutoConvert(a))
		else
			for x,y in next, aliveList do
				local atList = table.Copy(aliveList)
				for h,w in next, atList do
					if(w == y) then
						table.remove(atList, h)
						break
					else
						if(istable(w) && istable(y)) then
							if(w.botid == y.botid) then
								table.remove(atList, h)
								break
							end
						end
					end
				end
				GTetris:AutoSetTarget(y, GTetris:AutoConvert(atList[math.random(1, table.Count(atList))]))
			end
		end
	end
end

function GTetris:GetLastPlayer(rID)
	local room = GTetris.Rooms[rID]
	if(room == nil) then return false end
	local retPlayer = -1
	for k,v in next, room.Players do
		local ply = Entity(v)
		if(ply:GetNWBool("GTetris-Died", false)) then continue end
		retPlayer = v
	end
	if(retPlayer == -1) then
		for k,v in next, room.Bots_InGame do
			if(!v.alive) then continue end
			retPlayer = v.botid
		end
	end

	return retPlayer
end

function GTetris:CheckShouldEnd(rID)
	local room = GTetris.Rooms[rID]
	if(room == nil) then return false end
	local playersLeft = 0
	for k,v in next, room.Players do
		local ply = Entity(v)
		if(ply:GetNWBool("GTetris-Died", false)) then continue end
		playersLeft = playersLeft + 1
	end

	for k,v in next, room.Bots_InGame do
		if(v.alive) then 
			playersLeft = playersLeft + 1
		end
	end

	return (playersLeft <= 1)
end

function GTetris:BroadcastSeed(players, seed)
	for k,v in next, players do
		local ply = Entity(v)
		net.Start("GTetris-SyncPieceSeed")
		net.WriteInt(seed, 32)
		net.Send(ply)
	end
end

if(!GTETRIS_TESTDATA) then
	GTETRIS_TESTDATA = {}
end

function GTetris:WriteMatchResult(outdata)
	outdata.HID = bit.tohex(math.random(1, 16777216), 6)
	local data = util.TableToJSON(outdata)
	if(!data) then return end

	HTTP({
		success = function(code, body, headers)
			print(body)
		end,
		method = "POST",
		body = data,
		url = "https://gtetris.gmaniaserv.xyz/gtetris/result_receiver.php"
	})
end

function GTetris:BoolenToStr(boolen)
	if(boolen) then
		return "yes"
	else
		return "no"
	end
end

function GTetris:EndRoom(rID)
	local room = GTetris.Rooms[rID]
	local lastPlayer = GTetris:GetLastPlayer(rID)
	for k,v in next, room.Players do
		local ply = Entity(v)
		net.Start("GTetris-GameFinished")
		net.WriteString(rID)
		net.WriteInt(lastPlayer, 32)
		net.Send(ply)
	end
	local seed = math.random(1, 32767)
	GTetris.Rooms[rID].Rulesets.PiecesSeed = seed
	GTetris:BroadcastSeed(room.Players, seed)

	local sta = GTetris.TempData[rID].time
	local hostname = "Unknown"
	local hsteamid = "?"
	local hostent = Entity(GTetris.Rooms[rID].Host)
	if(IsValid(hostent)) then
		hostname = hostent:Nick()
		hsteamid = hostent:SteamID64()
	end
	local ruleset = GTetris.Rooms[rID].Rulesets
	ruleset.RoomName = GTetris.Rooms[rID].RoomName
	local outdata = {
		RoomDetails = ruleset,
		PlayerDetails = {

		},
		Host = hostname,
		HostSteamID = hsteamid,
		HID = bit.tohex(math.random(1, 16777216), 6),
		Time = SysTime() - sta,
	}
	if(sta != nil) then
		for k,v in next, GTetris.TempData[rID] do
			if(k == "time") then continue end
			local tmp = {}
			local apm, pps = 0, 0
			local nick = "Unknown Player"
			local steamid = "?"
			local isbot = GTetris:IsBot(rID, k)
			local scl = math.abs(SysTime() - sta) / 60
			local scl2 = math.abs(SysTime() - sta)
			local surtime = scl2
			if(!isbot && !IsValid(Entity(k))) then continue end -- Player is invalid
			if(isbot) then
				nick = GTetris.Rooms[rID].Bots_InGame[k].name
			else
				nick = Entity(k):Nick()
				steamid = tostring(Entity(k):SteamID64())
			end
			if(v.dietime != -1) then
				scl = math.abs(v.dietime - sta) / 60
				scl2 = math.abs(v.dietime - sta)
				surtime = scl2
			else
				surtime = 214748364
			end
			apm = math.Round(v.attacks / scl, 2)
			pps = math.Round(v.pieces / scl2, 2)
			tmp.apm = apm
			tmp.pps = pps
			tmp.sent = v.attacks
			tmp.name = nick
			tmp.isbot = GTetris:BoolenToStr(isbot)
			tmp.steamid = steamid
			tmp.surivivetime = math.Round(surtime, 3)
			tmp.winner = GTetris:BoolenToStr((k == lastPlayer))

			outdata.PlayerDetails[k] = tmp
		end
		if(table.Count(outdata.PlayerDetails) > 0) then
			GTETRIS_TESTDATA = outdata
			GTetris:WriteMatchResult(outdata)
		end
	end
	GTetris.Rooms[rID].Bots_InGame = {}
	GTetris.TempData[rID] = {}
	GTetris.Rooms[rID].Started = false
end

function GTetris:IsTargetInRoomOrAlive(rID, Target)
	local room = GTetris.Rooms[rID]
	if(room == nil) then return end
	local valid = false
	for k,v in next, room.Players do
		if(v == Target && !Entity(v):GetNWBool("GTetris-Died", false)) then valid = true end
	end
	for k,v in next, GTetris.Rooms[rID].Bots_InGame do
		if(v.botid != Target || !v.alive) then continue end
		valid = true
	end
	return valid 
end

net.Receive("GTetris-PlayerDied", function(len, ply)
	local rID = net.ReadString()
	ply:SetNWBool("GTetris-Died", true)

	GTetris:BroadcastKillfeed(rID, ply:GetNWInt("GTetris-LastAttackIndex", -1), ply:EntIndex())

	local room = GTetris.Rooms[rID]
	if(room == nil) then return end

	if(GTetris.TempData[rID]) then
		if(!GTetris.TempData[rID][ply:EntIndex()]) then
			GTetris.TempData[rID][ply:EntIndex()] = {
				attacks = 0,
				pieces = 0,
				dietime = SysTime(),
			}
		else
			GTetris.TempData[rID][ply:EntIndex()].dietime = SysTime()
		end
	end

	for k,v in next, room.Players do
		local p = Entity(v)
		net.Start("GTetris-PlayerDied")
		net.WriteInt(ply:EntIndex(), 32)
		net.Send(p)
	end

	if(GTetris:CheckShouldEnd(rID)) then
		GTetris:EndRoom(rID)
	end
end)

function GTetris:ValidateTarget(rID, t)
	local valid = false

	if(IsValid(Entity(t))) then
		valid = true
	else
		for k,v in next, GTetris.Rooms[rID].Bots_InGame do
			if(v.botid != t) then continue end
			valid = true
		end
	end

	return valid
end

function GTetris:IsBot(rID, t)
	if(!GTetris.Rooms[rID]) then return false end
	if(!IsValid(Entity(t))) then
		if(!GTetris.Rooms[rID].Bots_InGame[t]) then return false end
	else
		return false
	end
	return true
end

net.Receive("GTetris-SendAttack", function(len, ply)
	local rID = net.ReadString()
	if(rID == "?") then return end
	local attacks = net.ReadInt(32)
	local offs = net.ReadVector()
	local cancel = net.ReadBool()
	local cancel_amount = net.ReadInt(32)
	local Target = ply:GetNWInt("GTetris-Target", -1)
	if(!GTetris:IsTargetInRoomOrAlive(rID, Target) || !GTetris:ValidateTarget(rID, Target)) then GTetris:RandAttackTarget() return end
	if(GTetris.TempData[rID]) then
		if(!GTetris.TempData[rID][ply:EntIndex()]) then
			GTetris.TempData[rID][ply:EntIndex()] = {
				attacks = attacks + cancel_amount,
				pieces = 0,
				received = 0,
				dietime = -1,
			}
		else
			GTetris.TempData[rID][ply:EntIndex()].attacks = GTetris.TempData[rID][ply:EntIndex()].attacks + attacks + cancel_amount
		end
	end
	if(GTetris:IsBot(rID, Target)) then
		local bot = GTetris.Rooms[rID].Bots_InGame[Target]
		timer.Simple(bot.rulesets.GarbageArriveDelay, function()
			if(attacks > 0) then
				bot.lastattackindex = ply:EntIndex()
				table.insert(bot.internal_garbages, {
					amount = attacks,
					delay = SysTime() + bot.rulesets.GarbageApplyDelay,
				})
			end
			bot.garbages = bot.garbages + attacks
		end)
	else
		local p = Entity(Target)
		if(IsValid(p) && attacks > 0) then
			p:SetNWInt("GTetris-LastAttackIndex", ply:EntIndex())
		end
	end

	local room = GTetris.Rooms[rID]
	if(room == nil) then return end

	for k,v in next, room.Players do
		local p = Entity(v)
		if(p == ply) then continue end
		net.Start("GTetris-SendAttack")
		net.WriteInt(ply:EntIndex(), 32)
		net.WriteInt(Target, 32)
		net.WriteInt(attacks, 32)
		net.WriteVector(offs)
		net.WriteBool(cancel)
		net.WriteInt(cancel_amount, 32)
		net.Send(p)
	end
end)

function GTetris:BroadcastKillfeed(rID, attacker, victim)
	local nick1 = "Undefined" -- Victim's nick
	local nick2 = "Undefined" -- Attackes nick
	if(GTetris:IsBot(rID, victim)) then
		if(GTetris.Rooms[rID].Bots_InGame[victim]) then
			nick1 = GTetris.Rooms[rID].Bots_InGame[victim].name
		end
	else
		if(IsValid(Entity(victim))) then
			nick1 = Entity(victim):Nick()
		end
	end
	if(GTetris:IsBot(rID, attacker)) then
		if(GTetris.Rooms[rID].Bots_InGame[attacker]) then
			nick2 = GTetris.Rooms[rID].Bots_InGame[attacker].name
		end
	else
		if(IsValid(Entity(attacker))) then
			nick2 = Entity(attacker):Nick()
		end
	end
	if(attacker == -1) then
		nick2 = nick1
	end

	for k,v in next, GTetris.Rooms[rID].Players do
		local p = Entity(v)
		if(!IsValid(p)) then continue end
		net.Start("GTetris-Killfeed")
		net.WriteString(nick1)
		net.WriteString(nick2)
		net.Send(p)
	end

end

net.Receive("GTetris-KickPlayer", function(len, ply)
	local rID = net.ReadString()
	local player = net.ReadInt(32)

	local room = GTetris.Rooms[rID]
	if(room == nil || !GTetris:IsRoomHost(rID, ply)) then return end
	GTetris:LeaveRoom(Entity(player))
	GTetris:DisconnectPlayer(rID, Entity(player), "KICKED BY ROOM OWNER.")
end)

function GTetris:AddBannedPlayer(rID, player)
	GTetris.Rooms[rID].BannedPlayers[player] = true
end

function GTetris:IsPlayerBanned(rID, player)
	return GTetris.Rooms[rID].BannedPlayers[player] == true
end

net.Receive("GTetris-BanPlayer", function(len, ply)
	local rID = net.ReadString()
	local player = net.ReadInt(32)

	local room = GTetris.Rooms[rID]
	if(room == nil || !GTetris:IsRoomHost(rID, ply)) then return end
	GTetris:LeaveRoom(Entity(player))
	GTetris:DisconnectPlayer(rID, Entity(player), "BANNED BY ROOM OWNER.")

	GTetris:AddBannedPlayer(rID, player)
end)

net.Receive("GTetris-SyncBags", function(len, ply)
	local blocks = net.ReadString()
	ply:SetNWString("GTetris-Bags", blocks)
end)

net.Receive("GTetris-SyncPlayDetails", function(len, ply)
	local b2b = net.ReadInt(32)
	local combo = net.ReadInt(32)
	ply:SetNWInt("GTetris-B2B", b2b)
	ply:SetNWInt("GTetris-Combo", combo)
end)

net.Receive("GTetris-StartGame", function(len, ply)
	local rID = net.ReadString()
	local room = GTetris.Rooms[rID]
	if(room == nil) then return end
	GTetris.TempData[rID] = {
		time = SysTime() + 6.5,
	}
	GTetris.Rooms[rID].Bots_InGame = {}
	GTetris:CreateBotInstances(rID, room)
	local ctx, len = GTetris:GetCompressedData(GTetris.Rooms[rID])
	for k,v in next, room.Players do
		local p = Entity(v)
		GTetris:EnterGame(p, rID)

		GTetris:ResetPlayerGrid(rID, v)
		GTetris:BroadcastGrids(rID, v)
		p:SetNWInt("GTetris-Holds", -1)
		p:SetNWInt("GTetris-Garbages", 0)
		p:SetNWInt("GTetris-B2B", 0)
		p:SetNWInt("GTetris-Combo", 0)
		p:SetNWInt("GTetris-LastAttackIndex", -1)
		p:SetNWBool("GTetris-Died", false)

		net.Start("GTetris-ApplyRulesets")
		net.WriteUInt(len, 32)
		net.WriteData(ctx, len)
		net.Send(p)
	end
	GTetris.Rooms[rID].Started = true
	GTetris:SyncCRoomData(rID, room.Players, false)
end)

local randtimer = 0
hook.Add("Think", "GTetris-RandAttackTarget", function()
	if(randtimer > SysTime()) then return end
	GTetris:RandAttackTarget()
	randtimer = SysTime() + 5
end)