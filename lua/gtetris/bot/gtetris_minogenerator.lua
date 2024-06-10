--[[
	GTetris made by Meiryi :
		None of these codes should be edited, reuploaded, or claim it's made by yourself
		I don't care if you think anywhre needs a edit/patch, just let me know and I'll do it myself!
]]

function GTetris:ResetBotBags(bID)
	GTetris.Bots[bID].minos = -1
	GTetris.Bots[bID].can_hold = true
	GTetris.Bots[bID].bags = {1, 2, 3, 4, 5, 6, 7}
	table.Shuffle(GTetris.Bots[bID].bags)

	local w = GTetris:GetBlockWide(GTetris.Bots[bID].bags[1])
	GTetris.Bots[bID].rotate = 0
	GTetris.Bots[bID].minos = GTetris.Bots[bID].bags[1]
	GTetris.Bots[bID].origin = {x = (GTetris.Cols / 2) - math.Round((w / 2) + 0.5, 0), y = -3}
end

function GTetris:GetBotRandomBlock(bID)

	for k,v in next, GTetris.Bots[bID].bags do
		table.remove(GTetris.Bots[bID].bags, k)
		break
	end

	local hasDuplicatedMinos = false
	local tmp = {
		0,
		0,
		0,
		0,
		0,
		0,
		0,
	}
	local emptyMinos = {}
	local randList = {}
	for k,v in next, GTetris.Bots[bID].bags do
		if(tmp[v] >= 1) then hasDuplicatedMinos = true end
		tmp[v] = tmp[v] + 1
	end

	for k,v in next, tmp do
		if(v <= 0) then
			table.insert(emptyMinos, k)
		else
			table.insert(randList, k)
		end
	end

	if(hasDuplicatedMinos && #emptyMinos > 0) then
		table.insert(GTetris.Bots[bID].bags, emptyMinos[math.random(1, #emptyMinos)])
	else
		table.insert(GTetris.Bots[bID].bags, randList[math.random(1, #randList)])
	end
	local str = ""
	for k,v in next, GTetris.Bots[bID].bags do
		str = str..v
	end

	
end