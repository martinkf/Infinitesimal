local topPanel_Y = -8
local screenName_Y = 12
local amountLivesLeft_X = -88
local amountLivesLeft_Y = 40
local amountLivesRight_X = 0 - amountLivesLeft_X
local amountLivesRight_Y = amountLivesLeft_Y
local bottomPanel_Y = 762
local profileNameBG_X = 572
local profileNameBG_Y = 668+53
local profileNameText_X = 510
local profileNameText_Y = 653+53
local profileLevelBG_X = profileNameBG_X
local profileLevelBG_Y = 640
local profileLevelText_X = 510-120
local profileLevelText_Y = profileNameText_Y
local profilePic_X = 600+4
local profilePic_Y = 637+43+4
local credits_Y = SCREEN_TOP + 8
local credits_size = 0.4

local modIcons_X = 96
local modIcons_Y = 45

local t = Def.ActorFrame {
	Def.ActorFrame {
		InitCommand=function(self)
			self:xy(SCREEN_CENTER_X, -128)
		end,
		OnCommand=function(self)
			self:easeoutexpo(0.5):xy(SCREEN_CENTER_X, 0)
		end,
		--OffCommand=function(self) self:easeoutexpo(0.5):xy(SCREEN_CENTER_X, -128) end,
		OffCommand=function(self) end,
		
		-- Top panel graphic art (big, white)
		Def.Sprite {
			Texture=THEME:GetPathG("", "UI/PanelTop"),
			InitCommand=function(self)				
				self:scaletofit(0, 0, 1280, 128):xy(0, topPanel_Y):valign(0):queuecommand('Refresh')
			end,
			
			ScreenChangedMessageCommand=function(self) self:playcommand('Refresh') end,
			
			RefreshCommand=function(self)
				local currentScreenName = SCREENMAN:GetTopScreen():GetName()
								
				if 
				currentScreenName == "ScreenTitleMenu" or 
				currentScreenName == "ScreenTitleJoin" or
				currentScreenName == "ScreenLogo" or
				currentScreenName == "ScreenSelectProfile" then
					self:visible(false)
				else
					--self:visible(true) --temp disabling it
					self:visible(false)
				end
			end
		},
		
		-- Top panel graphic art (small, black)
		Def.Sprite {
			Texture=THEME:GetPathG("", "UI/PanelBottom"),
			InitCommand=function(self)				
				self:scaletofit(0, 0, 1280, 128):xy(0, topPanel_Y-52):valign(0):queuecommand('Refresh')
			end,
			
			ScreenChangedMessageCommand=function(self) self:playcommand('Refresh') end,
			
			RefreshCommand=function(self)
				local currentScreenName = SCREENMAN:GetTopScreen():GetName()
								
				if 
				currentScreenName == "ScreenTitleMenu" or 
				currentScreenName == "ScreenTitleJoin" or
				currentScreenName == "ScreenLogo" or
				currentScreenName == "ScreenSelectProfile" then
					self:visible(false) --temp disabling it
				else
					self:visible(false)
				end
			end
		},
		
		-- top back panel graphic art (quad test)
		Def.Quad {			
			InitCommand=function(self)				
				self:xy(0, topPanel_Y):setsize(1280, 162):diffuse(color("0,0,0,0.25")):queuecommand('Refresh')
			end,
			
			ScreenChangedMessageCommand=function(self) self:playcommand('Refresh') end,
			
			RefreshCommand=function(self)
				local currentScreenName = SCREENMAN:GetTopScreen():GetName()
								
				if 
				currentScreenName == "ScreenTitleMenu" or 
				currentScreenName == "ScreenTitleJoin" or
				currentScreenName == "ScreenLogo" or
				currentScreenName == "ScreenSelectProfile" then
					self:visible(false)
				else
					self:visible(true)
				end
			end
		},
		
		-- Top panel graphic art (quad test)
		Def.Quad {			
			InitCommand=function(self)				
				self:xy(0, topPanel_Y):setsize(1280, 50):diffuse(color("0,0,0,0.9"))
			end
		},
		
		-- game mode / number of credits
		Def.BitmapText {
			Font="Montserrat semibold 40px",
			InitCommand=function(self)
				self:xy(0,credits_Y):shadowlength(1):zoom(credits_size):queuecommand('Refresh')
			end,
			
			OnCommand=function(self) self:playcommand('Refresh') end,
			CoinInsertedMessageCommand=function(self) self:playcommand('Refresh') end,
			PlayerJoinedMessageCommand=function(self) self:playcommand('Refresh') end,
			ScreenChangedMessageCommand=function(self) self:playcommand('Refresh') end,
			RefreshCreditTextMessageCommand=function(self) self:playcommand('Refresh') end,

			RefreshCommand=function(self)
				local CoinMode = GAMESTATE:GetCoinMode()
				local EventMode = GAMESTATE:IsEventMode()
								
				if CoinMode == "CoinMode_Home" then
					self:visible(true):settext("HOME MODE")
				elseif EventMode then
					self:visible(true):settext("EVENT MODE")
				elseif CoinMode == 'CoinMode_Free' then
					self:visible(true):settext("FREE PLAY")
				elseif CoinMode == 'CoinMode_Pay' then
					local numberofcredits = GAMESTATE:GetCoins()
					local suffix = ""
					if numberofcredits == 1 then suffix = " CREDIT" else suffix = " CREDITS" end
					local CreditText = numberofcredits .. suffix
					self:visible(true):settext(CreditText)
				end
			end
		},
	
		-- StageCount BG UI art
		Def.Sprite {
			Texture=THEME:GetPathG("", "UI/StageCount"),
			InitCommand=function(self)
				self:zoom(0.4):y(45):queuecommand('Refresh')
			end,
			
			ScreenChangedMessageCommand=function(self) self:playcommand('Refresh') end,
			
			RefreshCommand=function(self)
				local currentScreenName = SCREENMAN:GetTopScreen():GetName()
								
				if 
				currentScreenName == "ScreenTitleMenu" or 
				currentScreenName == "ScreenTitleJoin" or
				currentScreenName == "ScreenLogo" or
				currentScreenName == "ScreenSelectProfile" then
					self:visible(false)
				else
					self:visible(true)
				end
				
				if (GAMESTATE:GetCurrentStyle():GetStyleType() == "StyleType_OnePlayerTwoSides") then
					self:x(-426)
				else
					self:x(0)
				end
			end
		},
		
		-- StageCount text
		Def.BitmapText {
			Font="Montserrat semibold 40px",			
			InitCommand=function(self)
				self:y(53):addx(-1):zoom(0.7):shadowlength(1):queuecommand('Refresh')
			end,
			
			ScreenChangedMessageCommand=function(self) self:playcommand('Refresh') end,
			
			RefreshCommand=function(self)
				local currentScreenName = SCREENMAN:GetTopScreen():GetName()
								
				if 
				currentScreenName == "ScreenTitleMenu" or 
				currentScreenName == "ScreenTitleJoin" or
				currentScreenName == "ScreenLogo" or
				currentScreenName == "ScreenSelectProfile" then
					self:visible(false)
				else
					self:visible(true)
				end
				
				if currentScreenName == "ScreenEvaluationNormal" then
					self:settext(string.format("%02d", GAMESTATE:GetCurrentStageIndex()))
				else
					self:settext(string.format("%02d", GAMESTATE:GetCurrentStageIndex() + 1))
				end
				
				if (GAMESTATE:GetCurrentStyle():GetStyleType() == "StyleType_OnePlayerTwoSides") then
					self:x(-426)
				else
					self:x(0)
				end
			end,
		},
		
		-- Amount of lives left	for P1 - disabled
		--[[
		Def.ActorFrame {
			InitCommand=function(self)
				self:xy(amountLivesLeft_X, amountLivesLeft_Y):visible(Screen.String("HeaderText") == "Select Music")
			end,

			Def.Sprite {
				Texture=THEME:GetPathG("", "UI/Button"),
				InitCommand=function(self) self:zoom(0.65) end,
			},
			LoadFont("Common Normal")..{
				InitCommand=function(self)
					self:settext()
						:xy(SCREEN_CENTER_X, SCREEN_CENTER_Y)
						:diffuse(color("#FF0000")) -- Set text color to red
				end
			},
			Def.Sprite {
				Texture=THEME:GetPathG("", "UI/Heart"),
				InitCommand=function(self)
					self:x(-21):zoom(0.3)
				end,
			},
			Def.BitmapText {
				Font="Montserrat semibold 40px",
				InitCommand=function(self)
					self:x(-6):zoom(0.6):halign(0)

					local Hearts = GAMESTATE:GetNumStagesLeft(PLAYER_1) + GAMESTATE:GetNumStagesLeft(PLAYER_2)
					self:settext("x " .. (GAMESTATE:IsEventMode() and "∞" or Hearts))
				end
			},
		},
		]]--
		
		-- Amount of lives left	for P2 - disabled
		--[[
		Def.ActorFrame {
			InitCommand=function(self)
				self:xy(amountLivesRight_X, amountLivesRight_Y):visible(Screen.String("HeaderText") == "Select Music")
			end,

			Def.Sprite {
				Texture=THEME:GetPathG("", "UI/Button"),
				InitCommand=function(self) self:zoom(0.65) end,
			},
			LoadFont("Common Normal")..{
				InitCommand=function(self)
					self:settext()
						:xy(SCREEN_CENTER_X, SCREEN_CENTER_Y)
						:diffuse(color("#FF0000")) -- Set text color to red
				end
			},
			Def.Sprite {
				Texture=THEME:GetPathG("", "UI/Heart"),
				InitCommand=function(self)
					self:x(-21):zoom(0.3)
				end,
			},
			Def.BitmapText {
				Font="Montserrat semibold 40px",
				InitCommand=function(self)
					self:x(-6):zoom(0.6):halign(0)

					local Hearts = GAMESTATE:GetNumStagesLeft(PLAYER_1) + GAMESTATE:GetNumStagesLeft(PLAYER_2)
					self:settext("x " .. (GAMESTATE:IsEventMode() and "∞" or Hearts))
				end
			},
		},
		]]--
	}
}

-- Profile info (clones for every active player)
for pn in ivalues(GAMESTATE:GetHumanPlayers()) do
	if PROFILEMAN:GetProfile(pn) and (PROFILEMAN:IsPersistentProfile(pn) or PROFILEMAN:ProfileWasLoadedFromMemoryCard(pn)) then
		t[#t+1] = Def.ActorFrame {            
			Def.ActorFrame {
				InitCommand=function(self) self:y(128) end,
				OnCommand=function(self) self:easeoutexpo(0.5):y(0) end,
				--OffCommand=function(self) self:easeoutexpo(0.5):y(128) end,
				OffCommand=function(self) end,

				-- profile name BG graphic
				Def.Sprite {
					Texture=THEME:GetPathG("", "UI/NameTag" .. ToEnumShortString(pn)),
					InitCommand=function(self)
						self:xy(SCREEN_CENTER_X + (pn == PLAYER_2 and profileNameBG_X or -profileNameBG_X), SCREEN_BOTTOM - profileNameBG_Y)
						:halign(pn == PLAYER_2 and 0 or 1):valign(1):rotationz(180):zoomx(2)
						:visible(false) --disabling
					end
				},
				
				-- profile name (text)
				Def.BitmapText {
					Font="Montserrat semibold 20px",
					Text=PROFILEMAN:GetProfile(pn):GetDisplayName(),
					InitCommand=function(self)
						self:xy(SCREEN_CENTER_X + (pn == PLAYER_2 and profileNameText_X or -profileNameText_X), SCREEN_BOTTOM - profileNameText_Y):zoom(0.9)
						:maxwidth(112 / self:GetZoom()):skewx(-0.2):shadowlength(1)

						if PROFILEMAN:GetProfile(pn):GetDisplayName() == "" then
							self:settext(THEME:GetString("ProfileStats", "No Profile"))
						end
					end
				},
				
				--[[
				-- player level BGgraphic
				Def.Sprite {
					Texture=THEME:GetPathG("", "UI/NameTag" .. ToEnumShortString(pn)),
					InitCommand=function(self)
						self:xy(SCREEN_CENTER_X + (pn == PLAYER_2 and profileLevelBG_X or -profileLevelBG_X), SCREEN_BOTTOM - profileLevelBG_Y)
						:halign(pn == PLAYER_2 and 0 or 1):valign(1):rotationz(180)
					end
				},
				]]--
				
				-- player level (text)
				Def.BitmapText {
					Font="Montserrat semibold 20px",
					-- This ingenious level system was made up at 4am
					InitCommand=function(self)
						self:xy(SCREEN_CENTER_X + (pn == PLAYER_2 and profileLevelText_X or -profileLevelText_X), SCREEN_BOTTOM - profileLevelText_Y):zoom(0.9)
						:maxwidth(96 / self:GetZoom()):skewx(-0.2):shadowlength(1)
						lvl = math.floor(math.sqrt(PROFILEMAN:GetProfile(pn):GetTotalDancePoints() / 500)) + 1
						-- You can check if a number is "nan" by comparing it to itself
						-- because "nan" is not equal to anything, not even itself
						if (lvl < 0) or (lvl ~= lvl) then lvl = 0 end
						self:settext(THEME:GetString("ProfileStats", "Level") .. " " .. lvl)
					end
				},
				
				-- player profile pic
				Def.Sprite {
					Texture=LoadModule("Options.GetProfileData.lua")(pn)["Image"],
					InitCommand=function(self)
						self:scaletocover(0, 0, 64, 64)
						:xy(SCREEN_CENTER_X + (pn == PLAYER_2 and profilePic_X or -profilePic_X), SCREEN_BOTTOM - profilePic_Y)
					end
				},
				
				-- mod icons (horizontal)
				LoadActor("ModIcons.lua", pn) .. {
					InitCommand=function(self)
						self:xy(pn == PLAYER_2 and modIcons_X * 2 or modIcons_X * -2, modIcons_Y)
						:easeoutexpo(0.5):x(pn == PLAYER_2 and SCREEN_RIGHT - modIcons_X or modIcons_X)
						:queuecommand('Refresh')
					end,
					
					RefreshCommand=function(self)
						if SCREENMAN:GetTopScreen():GetName() == "ScreenGameplay" then						
							self:visible(false)
						end
					end,
				},
				
				-- mod icons (vertical)
				LoadActor("ModIconsVertical.lua", pn) .. {
					InitCommand=function(self)
						--self:xy(pn == PLAYER_2 and modIcons_X * 2 or modIcons_X * -2, modIcons_Y)
						self:xy(pn == PLAYER_2 and modIcons_X * 2 or modIcons_X * -2, modIcons_Y-500)
						:easeoutexpo(0.5):x(pn == PLAYER_2 and SCREEN_RIGHT - modIcons_X or modIcons_X)
						:queuecommand('Refresh')
					end,
					
					RefreshCommand=function(self)
						if SCREENMAN:GetTopScreen():GetName() ~= "ScreenGameplay" then						
							self:visible(false)
						end
					end,
				},
			}
		}
	end
end


return t