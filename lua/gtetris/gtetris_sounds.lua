--[[
	GTetris made by Meiryi :
		None of these codes should be edited, reuploaded, or claim it's made by yourself
		I don't care if you think anywhre needs a edit/patch, just let me know and I'll do it myself!
]]

function GTetris:Playsound(sd, pvol)
	local vol = 2
	if(pvol) then
		vol = pvol
	end
	sound.PlayFile(sd, "noplay", function(station, errCode, errStr)
		if(IsValid(station)) then
			station:SetVolume(vol)
			station:Play()
		end
	end)
end

function GTetris:PlayAllClearSound(pvol)
	local vol = 2
	if(pvol) then
		vol = pvol
	end
	GTetris:Playsound("sound/gtetris/general/allclear.mp3", vol)
end

function GTetris:PlayMoveSound()
	GTetris:Playsound("sound/gtetris/general/move.mp3")
end

function GTetris:PlaySoftDropSound()
	GTetris:Playsound("sound/gtetris/general/softdrop.mp3")
end

function GTetris:PlayRotateSound(bonus)
	if(!bonus) then
		GTetris:Playsound("sound/gtetris/general/rotate.mp3")
	else
		GTetris:Playsound("sound/gtetris/general/rotatebonus.mp3")
	end
end

function GTetris:BoardHitSound()
	local index = math.random(1, 3)
	GTetris:Playsound("sound/gtetris/garbage/hit"..index..".mp3")
end

function GTetris:BoardUpSound()
	local index = math.random(1, 3)
	GTetris:Playsound("sound/gtetris/garbage/up.mp3")
end


function GTetris:ReceiveAttackSound(amount)
	local index = 1
	if(amount > 6) then
		index = 3
	elseif(amount >=4) then
		index = 2
	else
		index = 1
	end
	GTetris:Playsound("sound/gtetris/garbage/receive"..index..".mp3", 1.2)
end

function GTetris:SendAttackSound(amount)
	local index = 1
	if(amount > 5) then
		index = 3
	elseif(amount >=4) then
		index = 2
	else
		index = 1
	end
	GTetris:Playsound("sound/gtetris/garbage/send"..index..".mp3")
end

function GTetris:ComboBreakSound()
	GTetris:Playsound("sound/gtetris/combo/combobreak.mp3")
end

function GTetris:PlayPlaceSound()
	GTetris:Playsound("sound/gtetris/general/place.mp3")
end

function GTetris:PlayHoldSound()
	GTetris:Playsound("sound/gtetris/general/hold.mp3")
end

function GTetris:PlayClearSound(lines, bonus, combo, bonusSD, pvol)
	local vol = 2
	if(pvol) then
		vol = pvol
	end
	if(bonus) then
		GTetris:Playsound("sound/gtetris/general/clearbonus.mp3", vol)
	else
		if(lines >= 4) then
			GTetris:Playsound("sound/gtetris/general/quad.mp3", vol)
		else
			GTetris:Playsound("sound/gtetris/general/clear.mp3", vol)
		end
	end

	if(combo > 0) then
		local index = "combo"..math.min(combo, 16)
		if(bonusSD) then
			index = index.."bonus"
		end
		GTetris:Playsound("sound/gtetris/combo/"..index..".mp3", vol)
	end
end