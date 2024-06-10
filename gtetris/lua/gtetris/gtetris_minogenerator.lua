--[[
	GTetris made by Meiryi :
		None of these codes should be edited, reuploaded, or claim it's made by yourself
		I don't care if you think anywhre needs a edit/patch, just let me know and I'll do it myself!
]]

GTetris.oBags3x = {1, 2, 3, 4, 5, 6, 7, 1 ,2 ,3 ,4 ,5, 6, 7, 1 ,2 ,3 ,4 ,5, 6, 7, 1 ,2 ,3 ,4 ,5, 6, 7, 1 ,2 ,3 ,4 ,5, 6, 7}
GTetris.oBags2x = {1, 2, 3, 4, 5, 6, 7, 1 ,2 ,3 ,4 ,5, 6, 7}
GTetris.oBags = {1, 2, 3, 4, 5, 6, 7}
GTetris.Bags = {1, 2, 3, 4, 5, 6, 7}
table.Shuffle(GTetris.Bags)

GTetris.BagSystem = "7BAG"
GTetris.PieceSeed = 1024

function GTetris:ResetBags()
	GTetris.CurrentHoldBlockID = -1
	GTetris.CanHold = true
	GTetris.Bags = GTetris:GetNewBags(GTetris.PieceSeed)

	local w = GTetris:GetBlockWide(GTetris.Bags[1])
	GTetris.RotationState = 0
	GTetris.CurrentBlockID = GTetris.Bags[1]
	GTetris.Origin = {x = (GTetris.Cols / 2) - math.Round((w / 2) + 0.5, 0), y = -3}
end

function GTetris:GetNewBags(seed)
	local newbag = table.Copy(GTetris.oBags)
	if(GTetris.BagSystem == "14BAG") then
		newbag = table.Copy(GTetris.oBags2x)
	elseif(GTetris.BagSystem == "35BAG") then
		newbag = table.Copy(GTetris.oBags3x)
	elseif(GTetris.BagSystem == "RAND") then
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

function GTetris:PrintAllBags()
	print("---")
	for k,v in next, GTetris.Bags do
		print(v)
	end
	print("---")
end

function GTetris:GetRandomBlock()

	for k,v in next, GTetris.Bags do
		table.remove(GTetris.Bags, k)
		break
	end

	if(table.Count(GTetris.Bags) <= 6) then
		GTetris.PieceSeed = GTetris.PieceSeed + 1
		table.Add(GTetris.Bags, GTetris:GetNewBags(GTetris.PieceSeed))
	end

	local str = ""
	for k,v in next, GTetris.Bags do
		if(k > 7) then break end
		str = str..v
	end
	GTetris:SyncBags(str)
end