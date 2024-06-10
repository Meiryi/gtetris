--[[
	GTetris made by Meiryi :
		None of these codes should be edited, reuploaded, or claim it's made by yourself
		I don't care if you think anywhre needs a edit/patch, just let me know and I'll do it myself!
]]

GTetris.KeyState = {}

GTetris.Keys = {
	LeftKey = 89,
	RightKey = 91,
	Rotate1Key = 88,
	Rotate2Key = 36,
	Rotate3Key = 11,
	HoldKey = 13,
	HardDropKey = 65,
	SoftDropKey = 90,
}

GTetris.CurARR = -1
GTetris.CurDAS = -1
GTetris.CurSDF = -1

local ___stop = false

local targetFrameTime = 0.01666666

hook.Add("GTetris-KeyPressed", "GTetris-InputReceiver", function(key)
	if(___stop || !GTetris.ShouldProcess || !GTetris.ShouldRunLogicChecks) then return end
	if(key == "LeftKey") then
		GTetris:Move(-1, 0)
		GTetris.CurDAS = SysTime() + (targetFrameTime * GTetris.Handling.DAS)
	end
	if(key == "RightKey") then
		GTetris:Move(1, 0)
		GTetris.CurDAS = SysTime() + (targetFrameTime * GTetris.Handling.DAS)
	end
	if(key == "Rotate1Key") then
		GTetris:Rotate(1)
	end
	if(key == "Rotate2Key") then
		GTetris:Rotate(-1)
	end
	if(key == "Rotate3Key") then
		GTetris:Rotate(2)
	end
	if(key == "HardDropKey") then
		GTetris:PlaceBlock()
	end
	if(key == "HoldKey") then
		GTetris:Hold()
	end
end)

hook.Add("Think", "GTetris-InputHandler", function()
	if(!GTetris.ShouldProcess || !GTetris.ShouldRunLogicChecks) then return end
	for k,v in next, GTetris.Keys do
		if(input.IsKeyDown(v)) then
			if(!GTetris.KeyState[k]) then
				hook.Run("GTetris-KeyPressed", k)
			end
			GTetris.KeyState[k] = true
		else
			GTetris.KeyState[k] = nil
		end
	end

	if(input.IsKeyDown(GTetris.Keys.SoftDropKey)) then
		if(GTetris.Handling.SDF >= 40.5) then
			for i = GTetris.Origin.y, GTetris.Rows, 1 do
				GTetris:Move(0, 1)
			end
		else
			if(GTetris.CurSDF < SysTime()) then
				GTetris:Move(0, 1)
				GTetris.CurSDF = SysTime() + (1 / (GTetris.Handling.SDF * 3))
			end
		end
	end

	if(input.IsKeyDown(GTetris.Keys.LeftKey) || input.IsKeyDown(GTetris.Keys.RightKey)) then
		if(GTetris.CurDAS < SysTime()) then
			if(GTetris.CurARR < SysTime()) then
				if(input.IsKeyDown(GTetris.Keys.LeftKey)) then
					GTetris:Move(-1, 0)
				else
					GTetris:Move(1, 0)
				end
				GTetris.CurARR = SysTime() + (targetFrameTime * GTetris.Handling.ARR)
			end
		end
	else
		GTetris.CurDAS = SysTime() + (targetFrameTime * GTetris.Handling.DAS)
	end
end)