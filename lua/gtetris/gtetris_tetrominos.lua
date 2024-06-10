--[[
	GTetris made by Meiryi :
		None of these codes should be edited, reuploaded, or claim it's made by yourself
		I don't care if you think anywhre needs a edit/patch, just let me know and I'll do it myself!
]]

GTetris.Origin = {x = 0, y = 0}
GTetris.CurrentBlockID = 3
GTetris.RotationState = 0

GTetris.Enums = {}
GTetris.Enums_I = 1
GTetris.Enums_J = 2
GTetris.Enums_L = 3
GTetris.Enums_O = 4
GTetris.Enums_S = 5
GTetris.Enums_T = 6
GTetris.Enums_Z = 7

--[[
	0 = Empty
	1 = I
	2 = J
	3 = L
	4 = O
	5 = S
	6 = T
	7 = Z
	8 = Garbage Lines
]]

GTetris.Shapes = {
	[1] = { -- I
		[0] = {{1, 0},{1, 1},{1, 2},{1, 3},},
		[1] = {{0, 2},{1, 2},{2, 2},{3, 2},},
		[2] = {{2, 0},{2, 1},{2, 2},{2, 3},},
		[3] = {{0, 1},{1, 1},{2, 1},{3, 1},},
	},
	[2] = { -- J
		[0] = {{0, 0},{1, 0},{1, 1},{1, 2},},
		[1] = {{0, 1},{0, 2},{1, 1},{2, 1},},
		[2] = {{1, 0},{1, 1},{1, 2},{2, 2},},
		[3] = {{0, 1},{1, 1},{2, 0},{2, 1},},
	},
	[3] = { -- L
		[0] = {{0, 2},{1, 0},{1, 1},{1, 2},},
		[1] = {{0, 1},{1, 1},{2, 1},{2, 2},},
		[2] = {{1, 0},{1, 1},{1, 2},{2, 0},},
		[3] = {{0, 0},{0, 1},{1, 1},{2, 1},},
	},
	[4] = { -- O
		[0] = {{0, 0},{0, 1},{1, 0},{1, 1},},
		[1] = {{0, 0},{0, 1},{1, 0},{1, 1},},
		[2] = {{0, 0},{0, 1},{1, 0},{1, 1},},
		[3] = {{0, 0},{0, 1},{1, 0},{1, 1},},
	},
	[5] = { -- S
		[0] = {{0, 1},{0, 2},{1, 0},{1, 1},},
		[1] = {{0, 1},{1, 1},{1, 2},{2, 2},},
		[2] = {{1, 1},{1, 2},{2, 0},{2, 1},},
		[3] = {{0, 0},{1, 0},{1, 1},{2, 1},},
	},
	[6] = { -- T
		[0] = {{0, 1},{1, 0},{1, 1},{1, 2},},
		[1] = {{0 ,1},{1, 1},{1, 2},{2, 1},},
		[2] = {{1, 0},{1, 1},{1, 2},{2, 1},},
		[3] = {{0, 1},{1, 0},{1, 1},{2, 1},},
	},
	[7] = { -- Z
		[0] = {{0, 0},{0, 1},{1, 1},{1, 2},},
		[1] = {{0, 2},{1, 1},{1, 2},{2, 1},},
		[2] = {{1, 0},{1, 1},{2, 1},{2, 2},},
		[3] = {{0, 1},{1, 0},{1, 1},{2, 0},},
	},
	--[[
	[8] = { -- Whatever the fuck this is
		[0] = {{0, 0},{0, 1},{0, 2},{0, 3},{1, 0},{1, 1},{1, 2},{1, 3},{2, 0},{2, 1},{2, 2},{2, 3},{3, 0},{3, 1},{3, 2},{3, 3}},
		[1] = {{0, 0},{0, 1},{0, 2},{0, 3},{1, 0},{1, 1},{1, 2},{1, 3},{2, 0},{2, 1},{2, 2},{2, 3},{3, 0},{3, 1},{3, 2},{3, 3}},
		[2] = {{0, 0},{0, 1},{0, 2},{0, 3},{1, 0},{1, 1},{1, 2},{1, 3},{2, 0},{2, 1},{2, 2},{2, 3},{3, 0},{3, 1},{3, 2},{3, 3}},
		[3] = {{0, 0},{0, 1},{0, 2},{0, 3},{1, 0},{1, 1},{1, 2},{1, 3},{2, 0},{2, 1},{2, 2},{2, 3},{3, 0},{3, 1},{3, 2},{3, 3}},
	},
	]]
}

function GTetris:GetCurrentShapeLocal()
	return GTetris.Shapes[GTetris.CurrentBlockID][GTetris.RotationState]
end

function GTetris:GetCurrentShape()
	return GTetris:LocalToGrids(GTetris.Origin, GTetris.Shapes[GTetris.CurrentBlockID][GTetris.RotationState])
end

function GTetris:GetCurrentShapeRotateLocal(rotate)
	return GTetris.Shapes[GTetris.CurrentBlockID][rotate]
end

function GTetris:GetCurrentShapeRotate(rotate)
	return GTetris:LocalToGrids(GTetris.Origin, GTetris.Shapes[GTetris.CurrentBlockID][rotate])
end

function GTetris:GetColor(bID)
	local blist = {
		[0] = Color(0, 0, 0, 255),
		[1] = Color(62, 186, 141, 255),
		[2] = Color(77,62,186, 255),
		[3] = Color(186,123,62, 255),
		[4] = Color(186,164,62, 255),
		[5] = Color(106,186,62, 255),
		[6] = Color(186,62,161, 255),
		[7] = Color(186,62,62, 255),
		[8] = Color(130, 130, 130, 255),
	}
	local ret = blist[bID]
	if(ret == nil) then return blist[8] end
	return ret
end

function GTetris:GetBlockName(bID)
	local blist = {
		[1] = "I",
		[2] = "J",
		[3] = "L",
		[4] = "O",
		[5] = "S",
		[6] = "T",
		[7] = "Z",
	}
	if(blist[bID] == nil) then return "UNDEFINED" end
	return blist[bID]
end

function GTetris:LocalToGridsOffset(Origin, mShape)
	local ret = {}
	for k,v in next, mShape do
		ret[k - 1] = {v[1] + Origin.y, v[2] + Origin.x}
	end
	return ret
end

function GTetris:LocalToGrids(Origin, mShape)
	local ret = {}
	for k,v in next, mShape do
		table.insert(ret, {v[1] + Origin.y, v[2] + Origin.x})
	end
	return ret
end

function GTetris:GetLinesName(input)
	local blist = {
		[0] = "ZERO",
		[1] = "SINGLE",
		[2] = "DOUBLE",
		[3] = "TRIPLE",
		[4] = "QUAD",
	}
	if(blist[input] == nil) then return "UNDEFINED" end
	return blist[input]
end