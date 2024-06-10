--[[
	GTetris made by Meiryi :
		None of these codes should be edited, reuploaded, or claim it's made by yourself
		I don't care if you think anywhre needs a edit/patch, just let me know and I'll do it myself!
]]

GTetris.Bots = {}

function GTetris:AddBots(name, type, pps, egrid, cols, rows, rid, rset, tspin, aID)
	local id = aID
	local ctx, len = GTetris:GetCompressedData(egrid)

	local seed = table.Copy(rset).PiecesSeed
	local bag = GTetris:GetNewBags(rset.BagSystem, rset.PiecesSeed)
 	local instance = {
 		name = name,
 		type = type,
 		grid = table.Copy(egrid),
 		testgrid = table.Copy(egrid),
 		origin = {x = 0, y = 0},
 		minos = bag[1],
 		rotate = 0,
 		bags = bag,
 		target = -1,

 		cancombo = false,
 		bonus_sound = false,
 		bonus = false,

 		b2b = 0,

 		pieceseed = seed,

 		botid = id,

 		attacks = 0,

 		cols = cols,
 		rows = rows,

 		lastattackindex = -1,

 		currentblock = bag[1],

 		hblock = -1,
 		canhold = true,

 		quad_hole_x = -1,
 		quad_hole_vis = false,

 		board_height = 0,

 		hold_minos = -1,
 		can_hold = true,

 		thinktime = SysTime() + 6.5,

 		basepps = pps,
 		pps = pps,
 		interval = 1 / pps,
 		curtime = 0,

 		first_hole = {-32, -32},

 		internal_garbages = {},

 		garbages = 0,
 		combo = 0,

 		has_tspin = false,
 		t_spin_shape = {},
 		t_spin_origin = {x = 0, y = 0},
 		t_spin_enabled = tspin,

 		max_predict_pieces = 4, 

 		lastscore = 0,

 		alive = true,

 		data = ctx,
 		len = len,

 		rid = rid,

 		state = 0,

 		rulesets = rset,
 	}

 	return instance
end