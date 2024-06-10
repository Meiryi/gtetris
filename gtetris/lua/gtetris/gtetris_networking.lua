--[[
	GTetris made by Meiryi :
		None of these codes should be edited, reuploaded, or claim it's made by yourself
		I don't care if you think anywhre needs a edit/patch, just let me know and I'll do it myself!
]]

if(!GTetris.CurrentCommID) then
GTetris.CurrentCommID = "?"
end

GTetris.SocketCommID = "?"

if(!GTetris.PlayerGrids) then
	GTetris.PlayerGrids = {}
end

GTetris.IsPlayingOnline = false
GTetris.IsQueuing = false
GTetris.IsInRoom = false

GTetris.LocalPlayerDied = false

GTetris.WaitingForRespond = false

GTetris.GameFinishedTime = 0

GTetris.GarbageSent = 0
GTetris.GarbageRecordTime = 0
GTetris.PiecesPlaced = 0
GTetris.PieceRecordTime = 0

GTetris.UpdatingCRoomData = false
GTetris.UpdatingCRoomDataTime = -1

GTetris.MPRulesets = {}

GTetris.MPRulesets.GravityInterval = 1

GTetris.MPRulesets.Cols = 10
GTetris.MPRulesets.Rows = 20
GTetris.MPRulesets.MaximumOverflowRange = -20

GTetris.MPRulesets.Spins = "TSPIN"

GTetris.MPRulesets.ComboAllowed = true
GTetris.MPRulesets.ComboTable = "Meiryi"

GTetris.MPRulesets.RotationSystem = "SRS-Meiryi"

GTetris.MPRulesets.GarbageCap = 8
GTetris.MPRulesets.GarbageApplyDelay = 0.25
GTetris.MPRulesets.GarbageScaling = 1

GTetris.MPRulesets.PlayerLimit = 2

if(!GTetris.CRoomData) then
GTetris.CRoomData = {
	Host = -1,
	ID = "00000000",
	RoomName = "UNDEFINED",
	Players = {},
	Bots = {},
	Rulesets = table.Copy(GTetris.Rulesets),
}
end

function GTetris:GetCompressedData(t)
	local ctx = util.Compress(util.TableToJSON(t))
	local len = string.len(ctx)
	return ctx, len
end

function GTetris:DestroyInstance()
	GTetris.ShouldProcess = false
	GTetris.ShouldRunLogicChecks = false
	GTetris:ResetRuleSets()
	GTetris:ReloadGrids()
	GTetris:ResetCRoomData()
end

function GTetris:SyncCRoomData()
	if(GTetris.CurrentCommID == "?" || !GTetris:IsRoomHost()) then return end
	local ctx, len = GTetris:GetCompressedData(GTetris.CRoomData)
	net.Start("GTetris-SyncCRoomData")
	net.WriteString(GTetris.CurrentCommID)
	net.WriteUInt(len, 32)
	net.WriteData(ctx, len)
	net.SendToServer()
end

function GTetris:ResetCRoomData()
	GTetris.CRoomData = {
		Host = -1,
		ID = "00000000",
		RoomName = "UNDEFINED",
		Players = {},
		Rulesets = table.Copy(GTetris.MPRulesets),
	}
	GTetris.UpdatingCRoomData = false
	GTetris.UpdatingCRoomDataTime = -1

	GTetris.GarbageSent = 0
	GTetris.GarbageRecordTime = 0
	GTetris.PiecesPlaced = 0
	GTetris.PieceRecordTime = 0
end

function GTetris:GetCompDetails(player)
	if(player == LocalPlayer()) then
		return GTetris.GarbageSent, GTetris.PiecesPlaced
	else
		local id = player:EntIndex()
		local d = GTetris.PlayerGrids[id]
		if(d) then
			return d.Attacks, d.Pieces
		else
			return 0, 0
		end
	end
end

function GTetris:ReceiveGarbage(amount)
	table.insert(GTetris.Garbages, {
		amount = amount,
		delay = SysTime() + GTetris.GarbageApplyDelay,
	})
	GTetris:SyncGarbages()
end

function GTetris:JoinRoom(RoomID)
	net.Start("GTetris-JoinRoom")
	net.WriteString(RoomID)
	net.SendToServer()
	GTetris.PlayerGrids = {}
end

function GTetris:FetchRooms()
	net.Start("GTetris-FetchRooms")
	net.SendToServer()
end

function GTetris:ServerRespond()
	GTetris.WaitingForRespond = false
	if(IsValid(GTetris.Waiting)) then
		GTetris.Waiting:Remove()
	end
end

function GTetris:KickPlayer(ply)
	net.Start("GTetris-KickPlayer")
	net.WriteString(GTetris.CurrentCommID)
	net.WriteInt(ply:EntIndex(), 32)
	net.SendToServer()
end

function GTetris:BanPlayer(ply)
	net.Start("GTetris-BanPlayer")
	net.WriteString(GTetris.CurrentCommID)
	net.WriteInt(ply:EntIndex(), 32)
	net.SendToServer()
end

net.Receive("GTetris-DisconnectPlayer", function()
	local rID = net.ReadString()
	local reason = net.ReadString()
	GTetris:ForceLeaveRoom()
	GTetris:PopupMenu("DISCONNECTED BY SERVER", reason)
end)

function GTetris:ForceLeaveRoom()
	GTetris:DestroyInstance()
	if(IsValid(GTetris.PlayField)) then
		GTetris.PlayField:Remove()
	end
	if(IsValid(GTetris.OnlineUI)) then
		GTetris.OnlineUI:SetVisible(true)
	end
	GTetris.PlayerGrids = {}

	GTetris:CreateBackButton(function()
		GTetris:SwitchScene(function()
			GTetris.IsSinglePlayer = false
			GTetris.IsMultiplayer = false
			GTetris.ShouldProcess = false
			GTetris.ShouldRunLogicChecks = false
			GTetris.SoloSidePanel:SetVisible(false)
			GTetris:DestroyOnlineUI()
			GTetris:ToggleTabs(true)
			GTetris.Gui.BackButton:Remove()
		end)
	end)
end

function GTetris:LeaveRoomEvent()

end

net.Receive("GTetris-PlayerLeave", function()
	local id = net.ReadInt(32)
	GTetris.PlayerGrids[id] = nil
end)

function GTetris:RequestGrids(id)
	net.Start("GTetris-GetGrids")
	net.WriteString(GTetris.CurrentCommID)
	net.WriteInt(id, 32)
	net.SendToServer()
end

function GTetris:ForceApplyRulesets()
	GTetris:ApplyRuleSets(GTetris.CRoomData.Rulesets)
end

net.Receive("GTetris-ApplyRulesets", function()
	local len = net.ReadUInt(32)
	local ctx = util.JSONToTable(util.Decompress(net.ReadData(len)))
	GTetris.CRoomData = ctx
	GTetris:ForceApplyRulesets()
end)

function GTetris:StartGame()
	if(IsValid(GTetris.OnlineUI)) then
		GTetris.OnlineUI:SetVisible(false)
	end
	if(IsValid(GTetris.PlayField)) then
		GTetris.PlayField:SetVisible(false)
	end
	GTetris.PieceRecordTime = SysTime() + 2.5
	for k,v in next, GTetris.CRoomData.Players do
		local ply = Entity(v)
		if(!IsValid(ply)) then continue end
		ply:SetNWBool("GTetris-Died", false)

		GTetris:RequestGrids(v)
	end
	local Animseq = GTetris:CreatePanel(GTetris.Gui, 0, 0, ScrW(), ScrH(), Color(0, 0, 0, 255))
	local alpha = 0
	local talpha = 0
	local switch = false
	local wait = 0
	local seconds = false
	local stateCount = 0
	local state = 4
	Animseq.Paint = function()
		if(!switch) then
			alpha = math.Clamp(alpha + GTetris:GetFixedValue(10), 0, 255)
			if(alpha >= 255) then
				GTetris:ReloadGrids()
				GTetris:ToggleRendering(true)
				GTetris:InsertScreenText(GTetris.CRoomData.RoomName, 2, true)
				switch = true
			end
		else
			wait = wait + RealFrameTime()
			alpha = math.Clamp(alpha - GTetris:GetFixedValue(20), 0, 255)
			if(alpha <= 0 && wait >= 1.5) then
				talpha = math.Clamp(talpha - GTetris:GetFixedValue(10), 0, 255)
				if(talpha <= 0) then
					stateCount = stateCount + RealFrameTime()
					if(stateCount > 1) then
						state = state - 1
						stateCount = 0
						if(state <= 0) then
							Animseq:Remove()
							GTetris:InsertScreenText("GO!", 1)
							GTetris:ToggleControl(true)
							GTetris.GarbageSent = 0
							GTetris.GarbageRecordTime = SysTime()
							GTetris.PiecesPlaced = 0
							GTetris.PieceRecordTime = SysTime()
						else
							GTetris:InsertScreenText(state, 1)
						end
					end
				end
			else
				talpha = math.Clamp(talpha + GTetris:GetFixedValue(10), 0, 255)
			end
		end
		draw.RoundedBox(0, 0, 0, ScrW(), ScrH(), Color(0, 0, 0, alpha))
	end
end

function GTetris:IsRoomHost()
	return Entity(GTetris.CRoomData.Host) == LocalPlayer()
end

function GTetris:RunJoinEvent(RoomID, Data)
	GTetris:ResetPDetails()
	GTetris.CurrentCommID = RoomID

	if(IsValid(GTetris.PlayField)) then
		GTetris.PlayField:Remove()
	end

	GTetris.CRoomData = table.Copy(Data)
	local gap = ScreenScale(3)

	GTetris.PlayField = GTetris:CreatePanel(GTetris.Gui, ScrW() * 0.1, ScrH() * 0.075, ScrW() * 0.8, ScrH() * 0.85, Color(40, 40, 40, 255))
	local ow, oh = GTetris.PlayField:GetSize()
	local tw, th = GTetris:GetTextSize("GTetris-FieldText", "DummyText")
	GTetris.PlayField.Paint = function()
		draw.RoundedBox(0, 0, 0, ScrW() * 0.8, ScrH() * 0.85, Color(40, 40, 40, 255))
		draw.RoundedBox(0, 0, 0, ow, th * 1.5, Color(30, 30, 30, 255))
		draw.DrawText(GTetris.CRoomData.RoomName, "GTetris-FieldText", ow / 2, gap, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)
		draw.DrawText("Players "..table.Count(GTetris.CRoomData.Players) + table.Count(GTetris.CRoomData.Bots).." / "..GTetris.CRoomData.Rulesets.PlayerLimit, "GTetris-TabScrollTextTitle", gap * 2, GTetris.PlayField:GetTall() * 0.085, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT)
	end
	GTetris.PlayField:SetZPos(32766)
	
	GTetris.PlayField.Playerlist = GTetris:CreateScroll(GTetris.PlayField, gap, GTetris.PlayField:GetTall() * 0.15, GTetris.PlayField:GetWide() * 0.25, (GTetris.PlayField:GetTall() * 0.7) - gap * 2, Color(30, 30, 30, 255))
	local w, h = GTetris.PlayField:GetWide() * 0.25, GTetris.PlayField.Playerlist:GetTall() * 0.085

	GTetris:CreateAddBotButton(GTetris.PlayField.Playerlist)

	GTetris.PlayField.SettingsTab = GTetris:CreateScroll(GTetris.PlayField, ow * 0.35, GTetris.PlayField:GetTall() * 0.15, (ow * 0.65) - gap, (GTetris.PlayField:GetTall() * 0.7) - gap * 2, Color(30, 30, 30, 255))
	GTetris.PlayField.SettingsTab._h = GTetris.PlayField.SettingsTab:GetTall() * 0.08
	GTetris:MP_InsertTitle("GENERAL")
	GTetris:MP_InsertTextbox("Room name", nil, "RoomName")
	GTetris:MP_InsertIntButton("Max players", "Rulesets", "PlayerLimit", 2, 10)
	GTetris:MP_InsertLine()
	GTetris:MP_InsertTitle("GAMEPLAY")
	GTetris:MP_InsertIntButton("Columns", "Rulesets", "Cols", 4, 16, 2)
	GTetris:MP_InsertIntButton("Gravity", "Rulesets", "GravityInterval", 0, 60)
	GTetris:MP_InsertIntButton("Autolock Time", "Rulesets", "TargetLockTimer", 0.0, 5, 0.1)
	GTetris:MP_InsertLine()
	GTetris:MP_InsertTitle("PIECES GENERATION")
	GTetris:MP_InsertStringButton("7 BAG", "Rulesets", "BagSystem", "7BAG")
	GTetris:MP_InsertStringButton("14 BAG", "Rulesets", "BagSystem", "14BAG")
	GTetris:MP_InsertStringButton("35 BAG", "Rulesets", "BagSystem", "35BAG")
	GTetris:MP_InsertStringButton("COMPLETEY RANDOM", "Rulesets", "BagSystem", "RAND")
	GTetris:MP_InsertLine()
	GTetris:MP_InsertTitle("SPINS")
	for k,v in next, GTetris.ALLSpins do
		GTetris:MP_InsertStringButton(k, "Rulesets", "Spins", v)
	end
	GTetris:MP_InsertLine()
	GTetris:MP_InsertTitle("COMBO")
	for k,v in next, GTetris.ALLCombos do
		GTetris:MP_InsertStringButton(k, "Rulesets", "ComboTable", v)
	end
	GTetris:MP_InsertLine()
	GTetris:MP_InsertTitle("WALLKICKS")
	for k,v in next, GTetris.ALLWallKicks do
		GTetris:MP_InsertStringButton(k, "Rulesets", "RotationSystem", v)
	end
	GTetris:MP_InsertLine()
	GTetris:MP_InsertTitle("GARBAGE")
	GTetris:MP_InsertIntButton("Garbage Cap", "Rulesets", "GarbageCap", 1, 20)
	GTetris:MP_InsertIntButton("Garbage Scaling", "Rulesets", "GarbageScaling", 1, 100)
	GTetris:MP_InsertIntButton("Garbage Arrive Delay", "Rulesets", "GarbageArriveDelay", 0.2, 5, 0.1)
	GTetris:MP_InsertIntButton("Garbage Apply Delay", "Rulesets", "GarbageApplyDelay", 0.1, 5, 0.05)
	
	GTetris.PlayField.BlockVis = GTetris:CreatePanel(GTetris.PlayField, ow * 0.35, GTetris.PlayField:GetTall() * 0.15, (ow * 0.65) - gap, (GTetris.PlayField:GetTall() * 0.7) - gap * 2, Color(0, 0, 0, 155))

	local btnW, btnH = ow * 0.6, oh * 0.075
	local StartBTN = GTetris:CreateButtonEasy(GTetris.PlayField, (ow / 2) - btnW / 2, oh - (btnH + gap * 3), btnW, btnH, "START", Color(18, 20, 21, 255), Color(255, 255, 255, 255), function()
		if(table.Count(GTetris.CRoomData.Players) + table.Count(GTetris.CRoomData.Bots) <= 1) then return end
		net.Start("GTetris-StartGame")
		net.WriteString(GTetris.CurrentCommID)
		net.SendToServer()
	end)

	StartBTN.Think = function()
		if(table.Count(GTetris.CRoomData.Players) + table.Count(GTetris.CRoomData.Bots) > 1) then
			StartBTN.DrawText = "START"
		else
			StartBTN.DrawText = "NOT ENOUGH PLAYERS"
		end
	end

	GTetris.PlayField.Think = function()
		local vis = !GTetris:IsRoomHost()
		GTetris.PlayField.BlockVis:SetVisible(vis)
		StartBTN:SetVisible(!vis)
	end

	GTetris:LoadPlayerlist()

	GTetris:CreateBackButton(function()
		GTetris:SwitchScene(function()
			GTetris:DestroyInstance()
			if(IsValid(GTetris.PlayField)) then
				GTetris.PlayField:Remove()
			end
			if(IsValid(GTetris.OnlineUI)) then
				GTetris.OnlineUI:SetVisible(true)
			end
			net.Start("GTetris-LeaveRoom")
			net.SendToServer()
			GTetris:ResetRuleSets()
			GTetris.CurrentCommID = "?"
			GTetris.PlayerGrids = {}

			if(IsValid(GTetris.OnlineUI)) then
				GTetris:CreateBackButton(function()
					GTetris:SwitchScene(function()
						GTetris.IsSinglePlayer = false
						GTetris.IsMultiplayer = false
						GTetris.ShouldProcess = false
						GTetris.ShouldRunLogicChecks = false
						GTetris.SoloSidePanel:SetVisible(false)
						GTetris:DestroyOnlineUI()
						GTetris:ToggleTabs(true)
						GTetris.Gui.BackButton:Remove()
					end)
				end)
			end
		end)
		GTetris:WaitingScreen(function()
					
		end)
	end)
end

function GTetris:TestSeq()
	local ply = LocalPlayer()
	local nick = "UNKNOWN PLAYER"
	if(IsValid(ply)) then
		nick = ply:Nick()
	end
	local Animseq = GTetris:CreatePanel(GTetris.Gui, 0, 0, ScrW(), ScrH(), Color(0, 0, 0, 255))
	local switch = false
	local alpha = 0
	local alpha2 = 0
	local alpha3 = 255
	local textX = 0
	local t = SysTime()
	local at = false
	local killtime = SysTime() + 5
	local range = ScrW() * 0.03
	local tw, th = GTetris:GetTextSize("GTetris-ScreenText", nick)
	Animseq.Paint = function()
		if(GTetris.GameFinishedTime > SysTime()) then return end
		GTetris.ShouldProcess = false
		GTetris.ShouldRunLogicChecks = false
		draw.RoundedBox(0, 0, 0, ScrW(), ScrH(), Color(0, 0, 0, alpha))
		if(math.abs((ScrW() / 2) - textX) > (range) * 1.1) then
			if(textX < ScrW() / 2) then
				textX = math.min(textX + GTetris:GetFixedValue(30), (ScrW() / 2) - range)
			else
				textX = textX + GTetris:GetFixedValue(((ScrW() - textX) * 0.05) + 1)
				alpha3 = math.Clamp(alpha3 - GTetris:GetFixedValue(alpha3 * 0.15), 0, 255)
			end
			alpha = math.Clamp(alpha - GTetris:GetFixedValue(alpha * 0.05), 0, 255)
			alpha2 = math.Clamp(alpha2 - GTetris:GetFixedValue(alpha2 * 0.5), 0, 255)
			t = SysTime() + 1.5
		else
			if(t > SysTime()) then
				alpha = math.Clamp(alpha + GTetris:GetFixedValue((200 - alpha) * 0.1), 0, 200)
				alpha2 = math.Clamp(alpha2 + GTetris:GetFixedValue((255 - alpha2) * 0.1), 0, 255)
				textX = textX + GTetris:GetFixedValue(0.5)
			else
				textX = textX + GTetris:GetFixedValue(((ScrW() - textX) * 0.05) + 1)
			end
		end

		draw.DrawText("WINNER!", "GTetris-ScreenText2", textX - th / 2, (ScrH() / 2) - (th * 0.85), Color(255, 203, 15, alpha2), TEXT_ALIGN_RIGHT)
		draw.DrawText(nick, "GTetris-ScreenText", textX, (ScrH() / 2) - (th / 2), Color(255, 203, 15, alpha3), TEXT_ALIGN_CENTER)

		if(SysTime() > killtime || (textX - (tw / 2)) > ScrW() || alpha3 <= 10) then
			if(!switch) then
				alpha = math.Clamp(alpha + GTetris:GetFixedValue(20), 0, 255)
				if(alpha >= 255) then
					switch = true
				end
			else
				alpha = math.Clamp(alpha - GTetris:GetFixedValue(20), 0, 255)
				if(alpha <= 0) then
					if(IsValid(GTetris.OnlineUI)) then
						GTetris.OnlineUI:SetVisible(true)
					end
					if(IsValid(GTetris.PlayField)) then
						GTetris.PlayField:SetVisible(true)
					end
					Animseq:Remove()
				end
			end
		end
	end
end

net.Receive("GTetris-GameFinished", function()
	if(GTetris.PlayField:IsVisible()) then return end -- Player is waiting in lobby
	GTetris:ResetPDetails()
	GTetris.ShouldRunLogicChecks = false
	GTetris.GameFinishedTime = SysTime() + 1.5
	local rID = net.ReadString()
	local ply = net.ReadInt(32)
	local nick = "UNKNOWN PLAYER"
	if(IsValid(Entity(ply))) then
		nick = Entity(ply):Nick()
	else
		if(GTetris.PlayerGrids[ply]) then
			if(GTetris.PlayerGrids[ply].name) then
				nick = GTetris.PlayerGrids[ply].name
			end
		end
	end
	local Animseq = GTetris:CreatePanel(GTetris.Gui, 0, 0, ScrW(), ScrH(), Color(0, 0, 0, 255))
	local switch = false
	local alpha = 0
	local alpha2 = 0
	local alpha3 = 255
	local textX = 0
	local t = SysTime()
	local at = false
	local killtime = SysTime() + 30
	local range = ScrW() * 0.03
	local tw, th = GTetris:GetTextSize("GTetris-ScreenText", nick)
	Animseq.Paint = function()
		if(GTetris.GameFinishedTime > SysTime()) then return end
		if(!at) then
			GTetris.PlayerGrids = {}
			at = true
		end
		GTetris.ShouldProcess = false
		GTetris.ShouldRunLogicChecks = false
		draw.RoundedBox(0, 0, 0, ScrW(), ScrH(), Color(0, 0, 0, alpha))
		if(math.abs((ScrW() / 2) - textX) > range * 1.1) then
			if(textX < ScrW() / 2) then
				textX = math.min(textX + GTetris:GetFixedValue(30), (ScrW() / 2) - range)
			else
				textX = textX + GTetris:GetFixedValue(((ScrW() - textX) * 0.05) + 1)
				alpha3 = math.Clamp(alpha3 - GTetris:GetFixedValue(alpha3 * 0.15), 0, 255)
			end
			alpha = math.Clamp(alpha - GTetris:GetFixedValue(alpha * 0.05), 0, 255)
			alpha2 = math.Clamp(alpha2 - GTetris:GetFixedValue(alpha2 * 0.5), 0, 255)
			t = SysTime() + 1.5
		else
			if(t > SysTime()) then
				alpha = math.Clamp(alpha + GTetris:GetFixedValue((200 - alpha) * 0.1), 0, 200)
				alpha2 = math.Clamp(alpha2 + GTetris:GetFixedValue((255 - alpha2) * 0.1), 0, 255)
				textX = textX + GTetris:GetFixedValue(0.5)
			else
				textX = textX + GTetris:GetFixedValue(((ScrW() - textX) * 0.05) + 1)
			end
		end

		draw.DrawText("WINNER!", "GTetris-ScreenText2", textX - th / 2, (ScrH() / 2) - (th * 0.85), Color(255, 203, 15, alpha2), TEXT_ALIGN_RIGHT)
		draw.DrawText(nick, "GTetris-ScreenText", textX, (ScrH() / 2) - (th / 2), Color(255, 203, 15, alpha3), TEXT_ALIGN_CENTER)

		if(SysTime() > killtime || (textX - (tw / 2)) > ScrW() || alpha3 <= 10) then
			if(!switch) then
				alpha = math.Clamp(alpha + GTetris:GetFixedValue(20), 0, 255)
				if(alpha >= 255) then
					switch = true
				end
			else
				alpha = math.Clamp(alpha - GTetris:GetFixedValue(20), 0, 255)
				if(alpha <= 0) then
					if(IsValid(GTetris.OnlineUI)) then
						GTetris.OnlineUI:SetVisible(true)
					end
					if(IsValid(GTetris.PlayField)) then
						GTetris.PlayField:SetVisible(true)
					end
					Animseq:Remove()
				end
			end
		end
	end
end)

net.Receive("GTetris-StartGame", function()
	GTetris:StartGame()
end)

net.Receive("GTetris-SyncCRoomData", function()
	local len = net.ReadUInt(32)
	local ctx = util.JSONToTable(util.Decompress(net.ReadData(len)))
	GTetris.CRoomData = ctx
	GTetris.CRoomData.Started = false
end)

net.Receive("GTetris-Respond", function()
	GTetris:ServerRespond()
end)

net.Receive("GTetris-LeaveRoom", function()
	GTetris:ResetCRoomData()
end)

net.Receive("GTetris-GetPlayers", function()
	local len = net.ReadUInt(32)
	local ctx = util.JSONToTable(util.Decompress(net.ReadData(len)))
	GTetris.CRoomData.Players = ctx[1]
	GTetris.CRoomData.Bots = ctx[2]

	if(IsValid(GTetris.PlayField)) then
		GTetris.PlayField.Playerlist:Clear()
		GTetris:LoadPlayerlist()
	end
end)

net.Receive("GTetris-JoinRoom", function()
	--[[
		net.WriteString(rid)
		net.WriteUInt(len, 32)
		net.WriteData(ctx, len)
	]]
	local RoomID = net.ReadString()
	local len = net.ReadUInt(32)
	local ctx = util.JSONToTable(util.Decompress(net.ReadData(len)))
	GTetris.PieceSeed = ctx.Rulesets.PiecesSeed
	GTetris:RunJoinEvent(RoomID, ctx)
end)

net.Receive("GTetris-SyncPieceSeed", function()
	local seed = net.ReadInt(32)
	if(GTetris.CurrentCommID == "?") then return end
	GTetris.PieceSeed = seed
	GTetris.CRoomData.Rulesets.PiecesSeed = seed
end)

net.Receive("GTetris-OpenGame", function()
	GTetris:OpenGame()
end)

net.Receive("GTetris-FetchRooms", function()
	local len = net.ReadUInt(32)
	local ctx = util.JSONToTable(util.Decompress(net.ReadData(len)))

	if(!IsValid(GTetris.OnlineUI)) then return end
	if(!IsValid(GTetris.OnlineUI.Lower.List)) then return end
	GTetris.OnlineUI.Lower.List:Clear()
	for k,v in next, ctx do
		local padding = ScreenScale(3)
		local padding_ = padding * 0.5
		local p = GTetris.OnlineUI.Lower.List:Add("DPanel")
			p:SetSize(GTetris.OnlineUI.Lower.List:GetWide(), ScrH() * 0.05)
			p:Dock(TOP)
			p:DockMargin(0, ScreenScale(2), 0, 0)
			p.Paint = function()
				draw.RoundedBox(0, 0, 0, p:GetWide(), p:GetTall(), Color(30, 30, 30, 255))

				draw.DrawText(v.RoomName, "GTetris-FieldText", padding, padding_, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT)
				draw.DrawText(v.PlayerAmount.." / "..v.Rulesets.PlayerLimit, "GTetris-FieldText", p:GetWide() - padding, padding_, Color(255, 255, 255, 255), TEXT_ALIGN_RIGHT)
			end

			local b = p:Add("DButton")
				b:SetSize(p:GetWide(), p:GetTall())
				b:SetText("")
				b.DoClick = function()
					GTetris:JoinRoom(v.RoomID)
				end
				b.alpha = 0
				b.Paint = function()
					if(b:IsHovered()) then
						b.alpha = math.Clamp(b.alpha + GTetris:GetFixedValue(5), 0, 60)
					else
						b.alpha = math.Clamp(b.alpha - GTetris:GetFixedValue(5), 0, 60)
					end
					draw.RoundedBox(0, 0, 0, b:GetWide(), b:GetTall(), Color(255, 255, 255, b.alpha))
				end
	end
	--[[
	for k,v in next, ctx do
		for x,y in next, v do
			print(x, y)
		end
	end
	]]
end)

net.Receive("GTetris-PlayerDied", function()
	local id = net.ReadInt(32)
	if(GTetris.PlayerGrids[id] == nil) then return end
	for k,v in next, GTetris.PlayerGrids[id].Grid do
		for x,y in next, v do
			if(y == 0) then continue end
			y = 8
		end
	end
end)

net.Receive("GTetris-SyncBotDetails", function()
	local bId = net.ReadInt(32)
	if(!GTetris.PlayerGrids[bId]) then return end
	GTetris.PlayerGrids[player].name = net.ReadString()
	GTetris.PlayerGrids[player].cblock = net.ReadInt(8) 
	GTetris.PlayerGrids[player].hblock = net.ReadInt(8)
	GTetris.PlayerGrids[player].bags = net.ReadString()
	GTetris.PlayerGrids[player].garbages = net.ReadInt(32)
	GTetris.PlayerGrids[player].target = net.ReadInt(32)
	GTetris.PlayerGrids[player].alive = net.ReadBool()
	GTetris.PlayerGrids[player].combo = net.ReadInt(32)
	GTetris.PlayerGrids[player].b2b = net.ReadInt(32)
end)

net.Receive("GTetris-SyncGrids", function()
	local player = net.ReadInt(32)
	if(player == LocalPlayer():EntIndex()) then return end
	local len = net.ReadUInt(32)
	local grid = GTetris:DecompressGrid(net.ReadData(len))
	local isbot = net.ReadBool()
	if(IsValid(Entity(player))) then
		if(Entity(player):GetNWBool("GTetris-Died", false)) then print("Tried to sync a dead player's grid, ignoring!") return end
	end
	if(GTetris.PlayerGrids[player] == nil) then
		GTetris.PlayerGrids[player] = {
			YOffs = 0,
			CScale = 1,
			AliveTime = SysTime() + 10,
			RandPos = Vector(0, 0, 0),
			FallDelay = SysTime(),
			Grid = grid,
			Origin = Vector(0, 0, 0),
			Size = Vector(0, 0, 0),
			Player = Entity(player),
			CSize = GTetris.CellSize,
			ALLClears = {},
			DamageNumbers = {},

			warning = false,
			color = 255,

			Attacks = 0,
			Pieces = 0,
		}
	else
		GTetris.PlayerGrids[player].Grid = grid
		if(GTetris.PieceRecordTime > SysTime()) then return end
		GTetris.PlayerGrids[player].Pieces = GTetris.PlayerGrids[player].Pieces + 1
	end
	if(isbot) then
		GTetris.PlayerGrids[player].isbot = true
		GTetris.PlayerGrids[player].name = net.ReadString()
		GTetris.PlayerGrids[player].cblock = net.ReadInt(8) 
		GTetris.PlayerGrids[player].hblock = net.ReadInt(8)
		GTetris.PlayerGrids[player].bags = net.ReadString()
		GTetris.PlayerGrids[player].garbages = net.ReadInt(32)
		GTetris.PlayerGrids[player].target = net.ReadInt(32)
		GTetris.PlayerGrids[player].alive = net.ReadBool()
		GTetris.PlayerGrids[player].combo = net.ReadInt(32)
		GTetris.PlayerGrids[player].b2b = net.ReadInt(32)
	end

	GTetris.PlayerGrids[player].warning = GTetris:ShouldWarn(grid)
end)

net.Receive("GTetris-SyncBotDetails", function()
	
end)

function GTetris:SyncCDetails()
	net.Start("GTetris-SyncCBlock")
	net.WriteVector(Vector(GTetris.Origin.x, GTetris.Origin.y, 0))
	net.WriteInt(GTetris.CurrentBlockID, 8)
	net.WriteInt(GTetris.RotationState, 8)
	net.SendToServer()
end

function GTetris:SyncGrids()
	if(GTetris.CurrentCommID == "?") then return end
	local s = GTetris:CompressGrid(GTetris.Grids)
	local len = string.len(s)
	net.Start("GTetris-SyncGrids")
	net.WriteString(GTetris.CurrentCommID)
	net.WriteUInt(len, 32)
	net.WriteData(s, len)
	net.SendToServer()
end

function GTetris:SyncBags(str)
	net.Start("GTetris-SyncBags")
	net.WriteString(str)
	net.SendToServer()
end

function GTetris:SyncHold(hold)
	net.Start("GTetris-SyncHolds")
	net.WriteInt(hold, 8)
	net.SendToServer()
end

function GTetris:SyncGarbages()
	local lines = 0
	for k,v in next, GTetris.Garbages do
		lines = lines + v.amount
	end
	net.Start("GTetris-SyncGarbage")
	net.WriteInt(lines, 32)
	net.SendToServer()
end