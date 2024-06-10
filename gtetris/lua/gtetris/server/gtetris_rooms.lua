--[[
	GTetris made by Meiryi :
		None of these codes should be edited, reuploaded, or claim it's made by yourself
		I don't care if you think anywhre needs a edit/patch, just let me know and I'll do it myself!
]]

GTetris.TempData = {}
if(!GTetris.Rooms) then
	GTetris.Rooms = {}
end


--[[
	GTetris.Rooms table struct
	
	Table ->
		<Entity> Host = Host
		<String> ID = Room ID
		<String> RoomName = Room Name
		<Table> Players - Players
		<Table> Rulesets - Game Rulesets
		<Boolen> Started - Game Started
		<Table> Grids - Player Grids 
]]

function GTetris:DisconnectPlayer(rID, player, reason)
	net.Start("GTetris-DisconnectPlayer")
	net.WriteString(rID)
	net.WriteString(reason)
	net.Send(player)
end

net.Receive("GTetris-AddBot", function(len, ply)
	local rID = net.ReadString()
	local name = net.ReadString()
	local type = net.ReadString()
	local pps = net.ReadFloat()
	local tspins = net.ReadBool()

	if(!GTetris.Rooms[rID] || !GTetris:IsRoomHost(rID, ply)) then return end

	local room = GTetris.Rooms[rID]

	if(table.Count(room.Players) + table.Count(room.Bots) >= room.Rulesets.PlayerLimit) then print("a") return end

	local bid = bit.tohex(math.random(1, 16777216), 6)
	GTetris.Rooms[rID].Bots[bid] = {
		name = name,
		type = type,
		pps = pps,
		tspins = tspins,
	}

	GTetris:SyncPlayers(rID)
end)

net.Receive("GTetris-RemoveBot", function(len, ply)
	local rID = net.ReadString()
	local bID = net.ReadString()

	if(!GTetris.Rooms[rID] || !GTetris:IsRoomHost(rID, ply)) then return end

	local room = GTetris.Rooms[rID]
	GTetris.Rooms[rID].Bots[bID] = nil
	GTetris:SyncPlayers(rID)
end)

net.Receive("GTetris-FetchRooms", function(len, ply)
	local tbl = {}
	for k,v in next, GTetris.Rooms do
		table.insert(tbl, {
			RoomName = v.RoomName,
			PlayerAmount = #v.Players + table.Count(v.Bots),
			Rulesets = v.Rulesets,
			RoomID = v.ID,
			Started = v.Started,
		})
	end 
	local ctx = util.Compress(util.TableToJSON(tbl))
	local len = string.len(ctx)
	net.Start("GTetris-FetchRooms")
	net.WriteUInt(len, 32)
	net.WriteData(ctx, len)
	net.Send(ply)
end)

function GTetris:CreateRoom(ply)
	local RoomID = bit.tohex(math.random(1, 16777216), 6)
	local players = {ply:EntIndex()}
	local rulesets = table.Copy(GTetris.Rulesets)
	rulesets.PiecesSeed = math.random(1, 1024)
	GTetris.Rooms[RoomID] = {
		Host = ply:EntIndex(),
		ID = RoomID,
		RoomName = ply:Nick().."'s Room",
		Players = players,
		Rulesets = rulesets,
		Started = false,
		Bots = {},
		Bots_InGame = {},
		BannedPlayers = {},
	}

	GTetris:JoinEvent(ply, RoomID, GTetris.Rooms[RoomID])
end

function GTetris:RespondPlayer(ply)
	net.Start("GTetris-Respond")
	net.Send(ply)
end

function GTetris:PickHost(rID)
	if(table.Count(GTetris.Rooms[rID].Players) <= 0) then return end
	GTetris.Rooms[rID].Host = GTetris.Rooms[rID].Players[math.random(1, table.Count(GTetris.Rooms[rID].Players))]
	GTetris:SyncCRoomData(rID, GTetris.Rooms[rID].Players, false)
end

function GTetris:IsPlayerInRoom(ply)
	for k,v in next, GTetris.Rooms do
		for x,y in next, v.Players do
			if(Entity(y) != ply) then continue end
			return true
		end
	end
	return false
end

function GTetris:GetCompressedData(t)
	local ctx = util.Compress(util.TableToJSON(t))
	local len = string.len(ctx)
	return ctx, len
end

function GTetris:JoinEvent(ply, rID, t)
	local ctx, len = GTetris:GetCompressedData(t)
	net.Start("GTetris-JoinRoom")
	net.WriteString(rID)
	net.WriteUInt(len, 32)
	net.WriteData(ctx, len)
	net.Send(ply)
end

function GTetris:IsRoomHost(rID, ply)
	local room = GTetris.Rooms[rID]
	if(room == nil) then return false end
	return Entity(room.Host) == ply
end

function GTetris:SyncCRoomData(rID, t, ignoreHost)
	local host = Entity(GTetris.Rooms[rID].Host)
	local datas = table.Copy(GTetris.Rooms[rID])
	datas.Bots_InGame = nil -- Don't sync bot's data
	local ctx, len = GTetris:GetCompressedData(datas)
	for k,v in next, t do
		local e = Entity(v)
		if(e == host && ignoreHost) then continue end
		net.Start("GTetris-SyncCRoomData")
		net.WriteUInt(len, 32)
		net.WriteData(ctx, len)
		net.Send(e)
	end
end

function GTetris:UpdateCRoomData(ply, rID, ctx)
	if(GTetris.Rooms[rID] == nil) then return end
	local bots = table.Copy(GTetris.Rooms[rID].Bots_InGame)
	GTetris.Rooms[rID] = ctx
	GTetris.Rooms[rID].Bots_InGame = bots
	GTetris:SyncCRoomData(rID, GTetris.Rooms[rID].Players, true)
end

net.Receive("GTetris-SyncCRoomData", function(len, ply)
	local rID = net.ReadString()
	local len = net.ReadUInt(32)
	local ctx = util.JSONToTable(util.Decompress(net.ReadData(len)))

	if(!GTetris:IsRoomHost(rID, ply)) then return end
	GTetris:UpdateCRoomData(ply, rID, ctx)
end)

function GTetris:SyncPlayers(rID)
	local t = GTetris.Rooms[rID].Players
	local ctx, len = GTetris:GetCompressedData({t, GTetris.Rooms[rID].Bots})
	for k,v in next, t do
		net.Start("GTetris-GetPlayers")
		net.WriteUInt(len, 32)
		net.WriteData(ctx, len)
		net.Send(Entity(v))
	end
end

function GTetris:JoinRoom(ply, rID)
	local room = GTetris.Rooms[rID]
	if(room == nil) then return end
	if(table.Count(room.Players) + table.Count(room.Bots) >= room.Rulesets.PlayerLimit || GTetris:IsPlayerInRoom(ply)) then return end
	table.insert(GTetris.Rooms[rID].Players, ply:EntIndex())
	GTetris:JoinEvent(ply, rID, GTetris.Rooms[rID])
	GTetris:SyncPlayers(rID)

	ply:SetNWBool("GTetris-Died", room.Started)
end

function GTetris:BroadcastLeaveEvent(t, p, rID)
	for k,v in next, t do
		net.Start("GTetris-PlayerLeave")
		net.WriteInt(p, 32)
		net.Send(Entity(v))
	end
end

function GTetris:ValidateRoom()
	for k,v in next, GTetris.Rooms do
		if(table.Count(v.Players) <= 0) then
			GTetris.Rooms[k] = nil
		end
	end
end

function GTetris:RemovePlayer(ply, rID)
	local room = GTetris.Rooms[rID]
	if(room == nil) then return end
	for k,v in next, room.Players do
		if(Entity(v) != ply) then continue end
		GTetris:BroadcastLeaveEvent(room.Players, v, rID)
		table.remove(GTetris.Rooms[rID].Players, k)
		GTetris:SyncPlayers(rID)
	end
	GTetris:ValidateRoom()
end

function GTetris:ValidatePlayers(idx)
	local host = GTetris.Rooms[idx].Host
	for k,v in next, GTetris.Rooms[idx].Players do
		if(IsValid(Entity(v))) then continue end
		GTetris:BroadcastLeaveEvent(GTetris.Rooms[idx].Players, v, idx)
		table.remove(GTetris.Rooms[idx].Players, k)
			if(v == host) then
				GTetris:PickHost(v.ID)
			end
		GTetris:SyncPlayers(idx)
	end
		if(GTetris:CheckShouldEnd(idx) && GTetris.Rooms[idx].Started) then
			GTetris:EndRoom(idx)
		end
end

function GTetris:LeaveRoom(ply)
	for k,v in next, GTetris.Rooms do
		for x,y in next, v.Players do
			if(Entity(y) != ply) then continue end
			GTetris:BroadcastLeaveEvent(v.Players, x, v.ID)
			table.remove(v.Players, x)
			if(y == v.Host) then
				GTetris:PickHost(v.ID)
			end
			GTetris:SyncPlayers(v.ID)
		end
	end

	GTetris:ValidateRoom()
end

net.Receive("GTetris-LeaveRoom", function(len, ply)
	ply:SetNWBool("GTetris-Died", false)
	GTetris:LeaveRoom(ply)
	GTetris:RespondPlayer(ply)
end)

net.Receive("GTetris-JoinRoom", function(len, ply)
	local ID = net.ReadString()

	GTetris:RespondPlayer(ply)
	if(GTetris:IsPlayerBanned(ID, ply:EntIndex())) then
		GTetris:DisconnectPlayer(ID, ply, "BANNED BY ROOM OWNER.")
		return
	end
	GTetris:JoinRoom(ply, ID)
end)

net.Receive("GTetris-CreateRoom", function(len, ply)
	GTetris:RespondPlayer(ply)
	if(GTetris:IsPlayerInRoom(ply)) then return end
	GTetris:CreateRoom(ply)
end)

local nextThink = 0
hook.Add("Think", "GTetris-ProcessRooms", function()
	if(nextThink > CurTime()) then return end
	for k,v in next, GTetris.Rooms do
		GTetris:ValidatePlayers(v.ID)
	end
	nextThink = CurTime() + 1
end)