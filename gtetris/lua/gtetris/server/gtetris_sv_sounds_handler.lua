--[[
	GTetris made by Meiryi :
		None of these codes should be edited, reuploaded, or claim it's made by yourself
		I don't care if you think anywhre needs a edit/patch, just let me know and I'll do it myself!
]]

function GTetris:GetRoomPlayers(rID, exclude)
	local t = {}
	for k,v in next, GTetris.Rooms[rID].Players do
		if(v == exclude) then continue end
		t[k] = v
	end
	return t
end

function GTetris:BroadcastPlaceSound(rID, sdtarget)
	for k,v in next, GTetris:GetRoomPlayers(rID, sdtarget) do
		local p = Entity(v)

		if(!IsValid(p)) then continue end
		net.Start("GTetris-PlacePiece")
		net.WriteInt(sdtarget, 32)
		net.Send(p)
	end
end

function GTetris:BroadcastHoldSound(rID, sdtarget)
	for k,v in next, GTetris:GetRoomPlayers(rID, sdtarget) do
		local p = Entity(v)

		if(!IsValid(p)) then continue end
		net.Start("GTetris-HoldPiece")
		net.WriteInt(sdtarget, 32)
		net.Send(p)
	end
end

function GTetris:BroadcastRotateSound(rID, bonus, sdtarget)
	for k,v in next, GTetris:GetRoomPlayers(rID, sdtarget) do
		local p = Entity(v)

		if(!IsValid(p)) then continue end
		net.Start("GTetris-RotatePiece")
		net.WriteInt(sdtarget, 32)
		net.WriteBool(bonus)
		net.Send(p)
	end
end

function GTetris:BroadcastClearSound(rID, lines_cleared, rotate_bonus, combo, bonus_sound, pc, sdtarget)
	for k,v in next, GTetris:GetRoomPlayers(rID, sdtarget) do
		local p = Entity(v)

		if(!IsValid(p)) then continue end
		net.Start("GTetris-ClearLines")
		net.WriteInt(sdtarget, 32)
		net.WriteInt(lines_cleared, 8)
		net.WriteBool(rotate_bonus)
		net.WriteInt(combo, 16)
		net.WriteBool(bonus_sound)
		net.WriteBool(pc)
		net.Send(p)
	end
end

function GTetris:BroadcastBoardupSound(rID, sdtarget)
	for k,v in next, GTetris:GetRoomPlayers(rID, sdtarget) do
		local p = Entity(v)

		if(!IsValid(p)) then continue end
		net.Start("GTetris-Boardup")
		net.WriteInt(sdtarget, 32)
		net.Send(p)
	end
end

net.Receive("GTetris-PlacePiece", function(len, ply)
	local rID = net.ReadString()

	if(!GTetris.Rooms[rID]) then return end

	GTetris:BroadcastPlaceSound(rID, ply:EntIndex())
end)

net.Receive("GTetris-HoldPiece", function(len, ply)
	local rID = net.ReadString()

	if(!GTetris.Rooms[rID]) then return end

	GTetris:BroadcastHoldSound(rID, ply:EntIndex())
end)

net.Receive("GTetris-RotatePiece", function(len, ply)
	local rID = net.ReadString()
	local bonus = net.ReadBool()

	if(!GTetris.Rooms[rID]) then return end

	GTetris:BroadcastRotateSound(rID, bonus, ply:EntIndex())
end)

net.Receive("GTetris-ClearLines", function(len, ply)
	local rID = net.ReadString()
	local lines = net.ReadInt(8)
	local pbonus = net.ReadBool()
	local combo = net.ReadInt(16)
	local bonus = net.ReadBool()
	local pc = net.ReadBool()

	if(!GTetris.Rooms[rID]) then return end

	GTetris:BroadcastClearSound(rID, lines, pbonus, combo, bonus, pc, ply:EntIndex())
end)

net.Receive("GTetris-Boardup", function(len, ply)
	local rID = net.ReadString()

	if(!GTetris.Rooms[rID]) then return end

	GTetris:BroadcastBoardupSound(rID, ply:EntIndex())
end)