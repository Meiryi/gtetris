--[[
	GTetris made by Meiryi :
		None of these codes should be edited, reuploaded, or claim it's made by yourself
		I don't care if you think anywhre needs a edit/patch, just let me know and I'll do it myself!
]]

GTetris.RotationSystem = "SRS-Meiryi"

GTetris.WallkickEnabled = true
GTetris.Wallkicks = {
	["SRS-Meiryi"] = {
		[1] = { -- Not I
			["01"] = {{-1, 0},{-1, 1},{0, -2},{-1, -2}},
			["10"] = {{1, 0},{1, -1},{0, 2},{1, 2}},
			["12"] = {{1, 0},{1, -1},{0, 2},{1, 2}},
			["21"] = {{-1, 0},{-1, 1},{0, -2},{-1, -2}},
			["23"] = {{1, 0},{1, 1},{0, -2},{1, -2}},
			["32"] = {{-1, 0},{-1, -1},{0, 2},{-1, 2}},
			["30"] = {{-1, 0},{-1, -1},{0, 2},{-1, 2}},
			["03"] = {{1, 0},{1, 1},{0, -2},{1, -2}},
			["13"] = {{0, 1},{0, -1},{1, 0},{-1, 0},},
			["31"] = {{0, -1},{0, 1},{-1, 0},{1, 0},},
			["02"] = {{-1, 0},{1, 0},{0, -1},{0, 1},},
			["20"] = {{1, 0},{-1, 0},{0, 1},{0, -1},},
		},
		[2] = { -- I
			["01"] = {{-2, 0},{1, 0},{1, 2},{-2, -1}},
			["10"] = {{2, 0},{-1, 0},{2, 1},{-1, -2}},
			["12"] = {{-1, 0},{2, 0},{-1, 2},{2, -1}},
			["21"] = {{1, 0},{-2, 0},{1, -2},{-2, 1}},
			["23"] = {{2, 0},{-1, 0},{2, 1},{-1, -2}},
			["32"] = {{-2, 0},{1, 0},{-2, -1},{1, 2}},
			["30"] = {{1, 0},{-2, 0},{1, -2},{-2, 1}},
			["03"] = {{-1, 0},{2, 0},{-1, 2},{2, -1}},
			["13"] = {{0, 1},{0, -1},{1, 0},{-1, 0},},
			["31"] = {{0, -1},{0, 1},{-1, 0},{1, 0},},
		}		
	},
	["SRS-Arika"] = {
		[1] = { -- Not I
			["01"] = {{-2, 0},{1, 0},{1, 2},{-2, -1}},
			["10"] = {{2, 0},{-1, 0},{2, 1},{-1, -2}},
			["12"] = {{-1, 0},{2, 0},{-1, 2},{2, -1}},
			["21"] = {{-2, 0},{1, 0},{-2, 1},{1, -1}},
			["23"] = {{2, 0},{-1, 0},{2, 1},{-1, -1}},
			["32"] = {{1, 0},{-2, 0},{1, 2},{-2, -1}},
			["30"] = {{1, 0},{-2, 0},{1, -2},{-2, 1}},
			["03"] = {{-1, 0},{2, 0},{-1, 2},{2, -1}},
			["13"] = {{0, 1},{0, -1},{1, 0},{-1, 0},},
			["31"] = {{0, -1},{0, 1},{-1, 0},{1, 0},},
		},
		[2] = { -- I
			["01"] = {{-2, 0},{1, 0},{1, 2},{-2, -1}},
			["10"] = {{2, 0},{-1, 0},{2, 1},{-1, -2}},
			["12"] = {{-1, 0},{2, 0},{-1, 2},{2, -1}},
			["21"] = {{-2, 0},{1, 0},{-2, 1},{1, -1}},
			["23"] = {{2, 0},{-1, 0},{2, 1},{-1, -1}},
			["32"] = {{1, 0},{-2, 0},{1, 2},{-2, -1}},
			["30"] = {{1, 0},{-2, 0},{1, -2},{-2, 1}},
			["03"] = {{-1, 0},{2, 0},{-1, 2},{2, -1}},
			["13"] = {{0, 1},{0, -1},{1, 0},{-1, 0},},
			["31"] = {{0, -1},{0, 1},{-1, 0},{1, 0},},
		}		
	}
}

function GTetris:GetWallKickType(bID)
	if(bID == 1) then
		return 2
	else
		return 1
	end
end

function GTetris:ValidRotate()
	if(GTetris.Spins == "NONE") then
		return false
	elseif(GTetris.Spins == "TSPIN" && GTetris.CurrentBlockID != 6) then
		return false
	end
	return true
end

function GTetris:CheckBonus(Shape)
	if(!GTetris:ValidRotate()) then GTetris.Bonus = false GTetris:PlayRotateSound(GTetris.Bonus) return end
	if(GTetris.Spins == "STUPID" && GTetris:TouchedGround()) then GTetris.Bonus = true return end
	if(!GTetris:ShapeFits(Shape, GTetris:vOrigin(0, 1)) &&
		!GTetris:ShapeFits(Shape, GTetris:vOrigin(0, -1)) &&
		!GTetris:ShapeFits(Shape, GTetris:vOrigin(1, 0)) &&
		!GTetris:ShapeFits(Shape, GTetris:vOrigin(-1, 0)))then
		GTetris.Bonus = true
	else
		GTetris.Bonus = false
	end
	GTetris:RotateSound(GTetris.Bonus)
	GTetris:PlayRotateSound(GTetris.Bonus)
end

function GTetris:Rotate(r)
	local tmp = GTetris.RotationState + r
	if(tmp > 3) then
		tmp = tmp - 4
	end
	if(tmp < 0) then
		tmp = tmp + 4
	end
	if(!GTetris:IsInside(GTetris:GetCurrentShapeRotate(tmp), 0, 0) || !GTetris:ShapeFits(GTetris:GetCurrentShapeRotateLocal(tmp), GTetris.Origin)) then
		if(!GTetris:ProcessWallKick(GTetris.RotationState, tmp)) then
			return
		end
	end
	GTetris.RotationState = tmp
	GTetris:CheckBonus(GTetris:GetCurrentShape(r))

	GTetris:SyncCDetails()
end

function GTetris:ProcessWallKick(original, rotation)
	if(!GTetris.WallkickEnabled) then return false end
	local rShape = GTetris:GetCurrentShapeRotate(rotation)
	local iType = GTetris:GetWallKickType(GTetris.CurrentBlockID)
	local KickID = tostring(original..rotation)
	if(GTetris.Wallkicks[GTetris.RotationSystem] == nil) then return false end
	local KickTable = GTetris.Wallkicks[GTetris.RotationSystem][iType][KickID]
	if(KickTable == nil) then return false end
	for k,v in next, KickTable do
		local Blocked = false
		if(!GTetris:IsInside(rShape, v[1], -v[2]) || !GTetris:ShapeFits(GTetris:GetCurrentShapeRotateLocal(rotation), {x = GTetris.Origin.x + v[1], y = GTetris.Origin.y + -v[2]})) then
			Blocked = true
		end
		if(!Blocked) then
			GTetris:ForceMove(v[1], -v[2])
			return true
		end
	end
	return false
end