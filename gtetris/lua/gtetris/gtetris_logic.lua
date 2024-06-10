--[[
	GTetris made by Meiryi :
		None of these codes should be edited, reuploaded, or claim it's made by yourself
		I don't care if you think anywhre needs a edit/patch, just let me know and I'll do it myself!
]]

GTetris.LockTimer = -1
GTetris.TargetLockTimer = 1
GTetris.IntLockTimer = 0
GTetris.CurrentHoldBlockID = -1
GTetris.CanHold = true

GTetris.NullOrigin = {x = 0, y = 0}
GTetris.LastPlaceOrigin = {x = 0, y = 0}

GTetris.Bonus = false
GTetris.MiniBonus = false

GTetris.CurrentB2B = 0
GTetris.CurrentCombo = 0

GTetris.CanCombo = false
GTetris.Combo = 0

GTetris.GarbageAllowed = true
GTetris.Garbages = {}

GTetris.IsSinglePlayer = false
GTetris.IsMultiplayer = false
GTetris.bTouchGround = false

GTetris.GravityInterval = 0
GTetris.CurrentGravityTime = -1

GTetris.BonusSound = false
GTetris.WarnGrid = false

GTetris.Matrix = Matrix()

function GTetris:LocalPlayerAlive()
	return !LocalPlayer():GetNWBool("GTetris-Died", false)
end

function GTetris:GetPlayerCount()
	return table.Count(GTetris.PlayerGrids)
end

function GTetris:IsSpecingTarget(target)
	return target == GTetris.CurrentSpecPlayer && !GTetris:LocalPlayerAlive()
end

function GTetris:PlaceSound()
	if(GTetris.CurrentCommID == "?") then return end
	net.Start("GTetris-PlacePiece")
	net.WriteString(GTetris.CurrentCommID)
	net.SendToServer()
end

function GTetris:ShouldWarn(grid)
	local warnHeight = GTetris.Rows - math.floor(GTetris.Rows * 0.85)

	if(grid[warnHeight]) then
		for k,v in next, grid[warnHeight] do
			if(v != 0) then return true end
		end
	else
		return false
	end
end

net.Receive("GTetris-PlacePiece", function()
	local sdtarget = net.ReadInt(32)

	if(GTetris:GetPlayerCount() <= 1 || GTetris:IsSpecingTarget(sdtarget)) then
		GTetris:PlayPlaceSound()
	end
end)

function GTetris:HoldSound()
	if(GTetris.CurrentCommID == "?") then return end
	net.Start("GTetris-HoldPiece")
	net.WriteString(GTetris.CurrentCommID)
	net.SendToServer()
end

net.Receive("GTetris-HoldPiece", function()
	local sdtarget = net.ReadInt(32)

	if(GTetris:GetPlayerCount() <= 1 || GTetris:IsSpecingTarget(sdtarget)) then
		GTetris:PlayHoldSound()
	end
end)

function GTetris:RotateSound(bonus)
	if(GTetris.CurrentCommID == "?") then return end
	net.Start("GTetris-RotatePiece")
	net.WriteString(GTetris.CurrentCommID)
	net.WriteBool(bonus)
	net.SendToServer()
end

net.Receive("GTetris-RotatePiece", function()
	local sdtarget = net.ReadInt(32)
	local bonus = net.ReadBool()

	if(GTetris:GetPlayerCount() <= 1 || GTetris:IsSpecingTarget(sdtarget)) then
		GTetris:PlayRotateSound(bonus)
	end
end)

function GTetris:ClearSound(lines, pbonus, combo, bonus, allclear)
	if(GTetris.CurrentCommID == "?") then return end
	net.Start("GTetris-ClearLines")
	net.WriteString(GTetris.CurrentCommID)
	net.WriteInt(lines, 8)
	net.WriteBool(pbonus)
	net.WriteInt(combo, 16)
	net.WriteBool(bonus)
	net.WriteBool(allclear)
	net.SendToServer()
end

function GTetris:BroadcastUpSound()
	net.Start("GTetris-Boardup")
	net.WriteString(GTetris.CurrentCommID)
	net.SendToServer()
end

net.Receive("GTetris-Boardup", function()
	local sdtarget = net.ReadInt(32)

	if(GTetris:GetPlayerCount() <= 1 || GTetris:IsSpecingTarget(sdtarget)) then
		GTetris:BoardUpSound()
	end
end)


net.Receive("GTetris-ClearLines", function()
	local sdtarget = net.ReadInt(32)
	local lines = net.ReadInt( 8)
	local rotatebonus = net.ReadBool()
	local combo = net.ReadInt(16)
	local bonus_sound = net.ReadBool()
	local allclear = net.ReadBool()

	local vol = 0.2

	if(GTetris:GetPlayerCount() <= 1 || GTetris:IsSpecingTarget(sdtarget)) then
		vol = 2
	else
		vol = math.max(0.1, 2 / (GTetris:GetPlayerCount() + 1))
		if(vol == math.huge) then vol = 2 end
	end

	if(allclear) then
		GTetris:PlayAllClearSound(vol)
	end
	GTetris:PlayClearSound(lines, rotatebonus, combo, bonus_sound, vol)
end)

function GTetris:vOrigin(x, y)
	return {x = x, y = y}
end

function GTetris:PlayerDie()
	if(GTetris.CurrentCommID == "?") then
		if(GTetris.IsSinglePlayer) then
			GTetris:ReloadGrids()
		end
	else
		net.Start("GTetris-PlayerDied")
		net.WriteString(GTetris.CurrentCommID)
		net.SendToServer()
		LocalPlayer():SetNWBool("GTetris-Died", true)
		GTetris:ToggleControl(false)
	end
end

function GTetris:TouchedGround()
	return !GTetris:ShapeFits(GTetris:GetCurrentShape(), GTetris:vOrigin(0, 1))
end

function GTetris:ToggleControl(toggle)
	GTetris.ShouldRunLogicChecks = toggle
end

function GTetris:ToggleRendering(toggle)
	GTetris.ShouldProcess = toggle
end

function GTetris:IsInside(Shape, xOffs, yOffs)
	for k,v in next, Shape do
		local px, py = v[2] + xOffs, v[1] + yOffs
		if(px < 0 || px >= GTetris.Cols || py < GTetris.MaximumOverflowRange || py >= GTetris.Rows) then
			return false
		end
	end
	return true
end

function GTetris:IsEmptyCell(row, col)
	return GTetris.Grids[row][col] == 0
end

function GTetris:ShapeFits(Shape, Origin)
	local _Shape = GTetris:LocalToGrids(Origin, Shape)
	if(!GTetris:IsInside(Shape, Origin.x, Origin.y)) then return false end
	for k,v in next, _Shape do
		local x = GTetris.Grids[v[1]][v[2]]
		if(x == nil) then continue end
		if(x != 0) then return false end
	end
	return true
end

function GTetris:MoveGravity(x, y)
	local origin = {x = GTetris.Origin.x + x, y = GTetris.Origin.y + y}
	if(!GTetris:IsInside(GTetris:GetCurrentShape(), x, y) || !GTetris:ShapeFits(GTetris:GetCurrentShapeLocal(), origin)) then return end

	GTetris.Origin.x = GTetris.Origin.x + x
	GTetris.Origin.y = GTetris.Origin.y + y

	GTetris:SyncCDetails()
end

function GTetris:Move(x, y)
	local origin = {x = GTetris.Origin.x + x, y = GTetris.Origin.y + y}
	if(!GTetris:IsInside(GTetris:GetCurrentShape(), x, y) || !GTetris:ShapeFits(GTetris:GetCurrentShapeLocal(), origin)) then return end

	if(y > 0) then
		GTetris:PlaySoftDropSound()
	else
		GTetris:PlayMoveSound()
	end

	GTetris.Origin.x = GTetris.Origin.x + x
	GTetris.Origin.y = GTetris.Origin.y + y

	GTetris:SyncCDetails()
end

function GTetris:ForceMove(x, y)
	local origin = {x = GTetris.Origin.x + x, y = GTetris.Origin.y + y}
	GTetris.Origin.x = GTetris.Origin.x + x
	GTetris.Origin.y = GTetris.Origin.y + y

	GTetris:SyncCDetails()
end

function GTetris:GetBlockWide(index)
	local W = 1
	local pShape = GTetris.Shapes[index]
	if(pShape == nil) then
		pShape = GTetris.Shapes[1]
	end
	for k,v in next, pShape do
		for x,y in next, v do
			if(y[2] > W) then
				W = y[2]
			end
		end
	end
	return W
end

function GTetris:GetBlockTall(index)
	local W = 1
	local pShape = GTetris.Shapes[index]
	if(pShape == nil) then
		pShape = GTetris.Shapes[1]
	end
	for k,v in next, pShape do
		for x,y in next, v do
			if(y[1] > W) then
				W = y[1]
			end
		end
	end
	return W
end

function GTetris:MoveRowDown(StartFrom)
	for i = StartFrom, GTetris.MaximumOverflowRange, -1 do
		local pRow = i - 1
		if(pRow < -5) then
			GTetris:ClearRows(i)
		else
			GTetris.Grids[i] = table.Copy(GTetris.Grids[pRow])
		end
	end
end

function GTetris:ClearRows(Row)
	for x = 0, GTetris.Cols - 1, 1 do
		GTetris.Grids[Row][x] = 0
	end
end

function GTetris:CheckLines(bonus)
	local TotalLines = 0
	local ALLClear = true
	for i = GTetris.MaximumOverflowRange, GTetris.Rows - 1, 1 do
		local Cols = GTetris.Grids[i]
		local isFullLine = true
		for k,v in next, Cols do
			if(v == 0) then
				isFullLine = false
			end
		end
		if(isFullLine) then
			TotalLines = TotalLines + 1
			GTetris:ClearRows(i)
			GTetris:MoveRowDown(i)
		end
		for k,v in next, Cols do
			if(v != 0) then
				ALLClear = false
			end
		end
	end
	if(TotalLines > 0) then
		if(GTetris.CanCombo) then
			GTetris.Combo = GTetris.Combo + 1
			if(GTetris.Combo > 2) then
				if(bonus || TotalLines >= 4) then
					GTetris.BonusSound = true
				end
			end
			GTetris:SetupSideText("Combo", GTetris.Combo.." Combo", 3, color_white)
		end
		GTetris:SetupSideText("ClearLines", GTetris:GetLinesName(TotalLines), 2, color_white)
		GTetris.CanCombo = true
	else
		GTetris.CanCombo = false
		if(GTetris.Combo > 0) then
			GTetris:SetupSideText("Combo", "0 Combo", 0.85, Color(255, 100, 100, 255))
			if(GTetris.Combo > 3) then
				GTetris:ComboBreakSound()
			end
		end
		GTetris.BonusSound = false
		GTetris.Combo = 0
	end
	if(ALLClear) then
		GTetris:InsertALLClears(LocalPlayer())
		GTetris:PlayAllClearSound()
	end
	if(TotalLines > 0) then
		GTetris:ClearSound(TotalLines, bonus, GTetris.Combo, GTetris.BonusSound, ALLClear)
		GTetris:PlayClearSound(TotalLines, bonus, GTetris.Combo, GTetris.BonusSound)
	end
	GTetris:ProcessGarbage(TotalLines, bonus, ALLClear)

	GTetris.WarnGrid = GTetris:ShouldWarn(GTetris.Grids)
end

function GTetris:PlaceBlock()
	local pShape = GTetris:TraceGhostBlock()
	for k,v in next, pShape do
		GTetris.Grids[v[1]][v[2]] = GTetris.CurrentBlockID
	end
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

	GTetris:PlaceSound()
	GTetris:PlayPlaceSound()
	GTetris.PiecesPlaced = GTetris.PiecesPlaced + 1
end

function GTetris:Hold()
	if(GTetris.InfiniteHold) then
		GTetris.CanHold = true
	end
	if(!GTetris.CanHold || !GTetris.HoldAllowed) then return end
	if(GTetris.CurrentHoldBlockID == -1) then
		GTetris.CurrentHoldBlockID = GTetris.CurrentBlockID

		local nextID = 1
		for k,v in next, GTetris.Bags do
			nextID = v
			break
		end

		local w = GTetris:GetBlockWide(nextID)
		GTetris.RotationState = 0
		GTetris.CurrentBlockID = nextID
		GTetris.Origin = {x = (GTetris.Cols / 2) - math.Round((w / 2) + 0.5, 0), y = -3}

		GTetris:GetRandomBlock()
	else
		local OriginalBlock = GTetris.CurrentBlockID
		local OriginalHoldBlock = GTetris.CurrentHoldBlockID
		GTetris.CurrentHoldBlockID = OriginalBlock
		GTetris.CurrentBlockID = OriginalHoldBlock

		GTetris.RotationState = 0

		local w = GTetris:GetBlockWide(GTetris.CurrentBlockID)
		GTetris.Origin = {x = (GTetris.Cols / 2) - math.Round((w / 2) + 0.5, 0), y = -3}
	end
	GTetris.IntLockTimer = 0
	GTetris.bTouchGround = false
	GTetris.Bonus = false
	GTetris.CanHold = false

	GTetris:HoldSound()
	GTetris:PlayHoldSound()
	GTetris:SyncHold(GTetris.CurrentHoldBlockID)
end

function GTetris:CheckXOutOfBounds(Shape, xOffs, yOffs)
	for k,v in next, Shape do
		local px, py = v[2] + xOffs, v[1] + yOffs
		if(px < 0 || px >= GTetris.Cols || py >= GTetris.Rows) then
			return false
		end
	end
	return true
end

function GTetris:CheckShapes(Shape, Origin)
	local _Shape = GTetris:LocalToGrids(Origin, Shape)
	if(!GTetris:CheckXOutOfBounds(Shape, Origin.x, Origin.y)) then return false end
	for k,v in next, _Shape do
		local x = GTetris.Grids[v[1]][v[2]]
		if(x == nil) then continue end
		if(x != 0) then return false end
	end
	return true
end

function GTetris:TraceGhostBlock()
	local COrigin = table.Copy(GTetris.Origin)
	local PShape = GTetris:GetCurrentShapeLocal()
	for i = COrigin.y, GTetris.Rows, 1 do
		if(!GTetris:CheckShapes(PShape, {x = COrigin.x, y = i})) then
			return GTetris:LocalToGrids({x = COrigin.x, y = i - 1}, PShape)
		end
	end
	return GTetris:GetCurrentShape()
end

function GTetris:TraceYPos()
	local COrigin = table.Copy(GTetris.Origin)
	local PShape = GTetris:GetCurrentShapeLocal()
	for i = COrigin.y, GTetris.Rows, 1 do
		if(!GTetris:CheckShapes(PShape, {x = COrigin.x, y = i})) then
			return i - 1
		end
	end
	return GTetris.Origin.y
end

hook.Add("Think", "GTetris-ProcessLogic", function()
	if(!GTetris.ShouldProcess || !GTetris.ShouldRunLogicChecks) then return end
	if(GTetris.CurrentGravityTime < SysTime() && GTetris.GravityInterval > 0) then
		GTetris:MoveGravity(0, 1)
		GTetris.CurrentGravityTime = SysTime() + (1 / GTetris.GravityInterval)
	end

	if(GTetris:TouchedGround()) then
		GTetris.IntLockTimer = GTetris.IntLockTimer + RealFrameTime()
		if(GTetris.IntLockTimer > GTetris.TargetLockTimer) then
			GTetris:PlaceBlock()
		end
	end
end)