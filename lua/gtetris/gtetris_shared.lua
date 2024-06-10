--[[
	GTetris made by Meiryi :
		None of these codes should be edited, reuploaded, or claim it's made by yourself
		I don't care if you think anywhre needs a edit/patch, just let me know and I'll do it myself!
]]

function GTetris:CompressGrid(grid)
	return util.Compress(util.TableToJSON(grid))
end

function GTetris:DecompressGrid(grid)
	return util.JSONToTable(util.Decompress(grid))
end