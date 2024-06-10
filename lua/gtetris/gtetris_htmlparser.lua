--[[
	GTetris made by Meiryi :
		None of these codes should be edited, reuploaded, or claim it's made by yourself
		I don't care if you think anywhre needs a edit/patch, just let me know and I'll do it myself!
]]

GTetris.RequestingList = {}
function GTetris:GetUserAvatar(steamid64)
	steamid64 = tostring(steamid64)
	if(GTetris.RequestingList[steamid64] == true) then return end
	GTetris.RequestingList[steamid64] = true
	http.Fetch( "https://steamcommunity.com/profiles/"..steamid64,
		function(body, length, headers, code)
			local _st, _ed = string.find(body, "playerAvatarAutoSizeInner")
			if(_st) then
				local HeadersFound = 0
				local hasFrame = false
				local totalHeader = 1
				local __st, __ed = string.find(body, "profile_avatar_frame")
				_ed = _ed + 4
				if(__st) then -- If user have avatar frame
					hasFrame = true
					totalHeader = 2
					local fst = __ed + 4
					for i = fst, fst + 768, 1 do
						if(string.sub(body, i, i + 8) == "<img src=") then
							local _fst = i
							local _first, _fend = i + 10, 0
							for _i = _fst, _fst + 256, 1 do
								if(string.sub(body, _i, _i + 1) == '">') then
									_fend = _i - 1
									http.Fetch(string.sub(body, _first, _fend),
										function(body, length, headers, code)
											file.Write("gtetris/avatars/frames/"..steamid64..".png", body)
										end,
										function(message)
										end
									)
									break
								end
							end
							break
						end
					end
				else
					file.Write("gtetris/avatars/frames/"..steamid64..".png", file.Read("materials/gtetris/internal/emptyframe.png", "GAME"))
				end
				for i = _st, _st + 2048, 1 do
					if(string.sub(body, i, i + 8) == "<img src=") then
						HeadersFound = HeadersFound + 1
					end
					if(HeadersFound >= totalHeader) then
						for _i = i, i + 256, 1 do
							if(string.sub(body, _i, _i) == ">") then
								local line = string.sub(body, i, _i)
								local len = string.len(line)
								local avt_st, avt_ed = 0, 0
								for __i = 1, len, 1 do
									if(string.sub(line, __i, __i) == '"') then
										if(avt_st == 0) then
											avt_st = __i + 1
										else
											if(avt_ed == 0) then
												avt_ed = __i - 1
												break
											end
										end
									end
								end
								http.Fetch(string.sub(line, avt_st, avt_ed),
									function(body, length, headers, code)
										file.Write("gtetris/avatars/"..steamid64..".png", body)
									end,
									function(message)
									end
								)
								break
							end
						end
						break
					end
				end
			end
		end,

		function(message)
		end
	)
end