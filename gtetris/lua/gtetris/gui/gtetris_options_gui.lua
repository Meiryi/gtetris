--[[
	GTetris made by Meiryi :
		None of these codes should be edited, reuploaded, or claim it's made by yourself
		I don't care if you think anywhre needs a edit/patch, just let me know and I'll do it myself!
]]

function GTetris:DestroyOptionsUI()
	if(IsValid(GTetris.OptionsUI)) then
		GTetris.OptionsUI:Remove()
	end
end

GTetris.CurrentFocusedWindow = nil

surface.CreateFont("GTetris-OptionsTitle", {
	font = "Arial",
	extended = false,
	size = ScreenScale(14),
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
})

surface.CreateFont("GTetris-OptionsText", {
	font = "Arial",
	extended = false,
	size = ScreenScale(14),
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
})

GTetris.CurrentOption = nil

GTetris.Options = {
	HANDLING = {
		ARR = {0, 5, "s", "Handling", "ARR"},
		DAS = {0, 20, "s", "Handling", "DAS"},
		SDF = {0, 41, "s", "Handling", "SDF", {41, "inf"}},
	},
	CONTROLS = {
		{nil, nil, "k", "Keys", "LeftKey", "MOVE LEFT"},
		{nil, nil, "k", "Keys", "RightKey", "MOVE RIGHT"},
		{nil, nil, "k", "Keys", "Rotate1Key", "ROTATE CLOCKWISE"},
		{nil, nil, "k", "Keys", "Rotate2Key", "ROTATE COUNTERCLOCKWISE"},
		{nil, nil, "k", "Keys", "Rotate3Key", "ROTATE 180"},
		{nil, nil, "k", "Keys", "HoldKey", "HOLD"},
		{nil, nil, "k", "Keys", "SoftDropKey", "SOFT DROP"},
		{nil, nil, "k", "Keys", "HardDropKey", "HARD DROP"},
	},
	GAMEPLAY = {
		BoardZoom = {0, 30, "s", "Gameplay", "Board zoom"}
	}
}

function GTetris:CreateOptionsButton(index, title, func)
	local w, h = GTetris:GetTextSize("GTetris-OptionsTitle", title)
	local b = vgui.Create("DButton", GTetris.OptionsUI)
	local size = math.floor(ScrW() * 0.12)
	b:SetSize(size, ScrH() * 0.06)
	b:SetX((index - 1) * size)
	b:SetText(title)
	b:SetFont("GTetris-OptionsTitle")
	b:SetTextColor(Color(255, 255, 255, 255))

	b.Paint = function()
		if(GTetris.CurrentOption == title) then
			draw.RoundedBox(0, 0, 0, b:GetWide(), b:GetTall(), Color(60, 60, 60, 255))
		else
			draw.RoundedBox(0, 0, 0, b:GetWide(), b:GetTall(), Color(40, 40, 40, 255))
		end
	end

	b.DisplayOptions = function()
		GTetris.OptionsUI.Lower:Clear()
		if(GTetris.Options[title] == nil) then return end
		for k,v in next, GTetris.Options[title] do
			if(v[3] == "s") then
				GTetris:InsertSlider(GTetris.OptionsUI.Lower, v[4], k, v[1], v[2], v[5], "GTetris-OptionsText", Color(0, 0, 0, 100), v[6], GTetris.WriteHandlingConfig)
			elseif(v[3] == "k") then
				GTetris:InsertKeybind(GTetris.OptionsUI.Lower, v[4], v[5], v[6], "GTetris-OptionsText", Color(0, 0, 0, 100), GTetris.WriteControlConfig)
			end
		end
	end


	b.DoClick = function()
	b.DisplayOptions()
	GTetris.CurrentOption = title
		func(b)
	end

	if(index == 1) then
		b.DisplayOptions()
	end
end

function GTetris:BuildOptionsUI()
	if(IsValid(GTetris.OptionsUI)) then
		GTetris.OptionsUI:Remove()
	end
	GTetris.CurrentFocusedWindow = nil
	GTetris.CurrentOption = "HANDLING"

	local upperHeight = ScrH() * 0.06
	GTetris.OptionsUI = GTetris:CreatePanel(GTetris.Gui, ScrW() * 0.15, ScrH() * 0.15, ScrW() * 0.7, ScrH() * 0.7, Color(40, 40, 40, 255))
	GTetris.OptionsUI.Lower = GTetris:CreateScroll(GTetris.OptionsUI, 0, upperHeight, GTetris.OptionsUI:GetWide(), GTetris.OptionsUI:GetTall() - upperHeight, Color(60, 60, 60, 255))
	local options = {"HANDLING","CONTROLS", "GAMEPLAY", "MISC"}
	for k,v in next, options do
		GTetris:CreateOptionsButton(k, v, function(b)

		end)
	end

	
end