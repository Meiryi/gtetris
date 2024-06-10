--[[
	GTetris made by Meiryi :
		None of these codes should be edited, reuploaded, or claim it's made by yourself
		I don't care if you think anywhre needs a edit/patch, just let me know and I'll do it myself!
]]

GTetris.Bags3x = {1, 2, 3, 4, 5, 6, 7, 1 ,2 ,3 ,4 ,5, 6, 7, 1 ,2 ,3 ,4 ,5, 6, 7, 1 ,2 ,3 ,4 ,5, 6, 7, 1 ,2 ,3 ,4 ,5, 6, 7}
GTetris.Bags2x = {1, 2, 3, 4, 5, 6, 7, 1, 2, 3, 4 ,5 ,6 ,7}
GTetris.Bags = {1, 2, 3, 4, 5, 6, 7}

function GTetris:GetNewBags(bagsys, seed)
	local newbag = table.Copy(GTetris.Bags)
	if(bagsys == "14BAG") then
		newbag = table.Copy(GTetris.Bags2x)
	elseif(bagsys == "35BAG") then
		newbag = table.Copy(GTetris.Bags3x)
	elseif(bagsys == "RAND") then
		newbag = {}
		for i = 0, 6, 1 do
			table.insert(newbag, math.random(1, 7))
		end
	end
	local _seed = seed
	local n = #newbag
	for i = 1, n - 1 do
		math.randomseed(_seed)
		local j = math.random(i, n)
		newbag[i], newbag[j] = newbag[j], newbag[i]
		_seed = _seed + 1
	end

	return newbag
end

function GTetris:GetBotRandomBlock(bot)

	for k,v in next, bot.bags do
		table.remove(bot.bags, k)
		break
	end

	if(table.Count(bot.bags) <= 6) then
		bot.pieceseed = bot.pieceseed + 1
		table.Add(bot.bags, GTetris:GetNewBags(bot.rulesets.BagSystem, bot.pieceseed))
	end

	local str = ""
	for k,v in next, bot.bags do
		if(k > 7) then break end
		str = str..v
	end

	
end