local topPanel_Y = -8
local timerBG_Y = 31+16
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

t = Def.ActorFrame {
	Def.ActorFrame {
		InitCommand=function(self)
			self:xy(SCREEN_CENTER_X, -128)
		end,
		OnCommand=function(self)
			self:easeoutexpo(0.5):xy(SCREEN_CENTER_X, 0)
		end,
		OffCommand=function(self)
			self:easeoutexpo(0.5):xy(SCREEN_CENTER_X, -128)
		end,

		
		-- Top panel			
		Def.Sprite {
			Texture=THEME:GetPathG("", "UI/PanelTop"),
			InitCommand=function(self)
				--self:scaletofit(0, 0, 1280, 128):xy(0, topPanel_Y):valign(0):visible(Screen.String("HeaderText") ~= "Select Profile") --hidden in Select Profile screen (?)
				self:scaletofit(0, 0, 1280, 128):xy(0, topPanel_Y):valign(0):visible(true)
			end,
		},

		--[[
		-- Screen name
		Def.BitmapText {
			Name="ScreenName",
			Font="Montserrat normal 40px",
			Text=ToUpper(Screen.String("HeaderText")),
			InitCommand=function(self)
				self:xy(-WideScale(200, 200), screenName_Y+8):halign(1):zoom(0.6)
				:diffuse(Color.Black):shadowlength(1)

				local IsSelectMusic = self:GetText() == "SELECT MUSIC"
				if IsSelectMusic then self:y(screenName_Y) end					
			end,
		},
		-- Stage count
		Def.BitmapText {
			Font="Montserrat normal 40px",
			InitCommand=function(self)
				self:visible(Screen.String("HeaderText") == "Select Music" and true or false)
				self:settext("STAGE "..string.format("%02d", GAMESTATE:GetCurrentStageIndex() + 1))
				self:xy(-WideScale(200, 200), screenName_Y+20):halign(1):zoom(0.5):diffuse(Color.Black)
			end,
		},
		]]--
		
		-- timer BG
		Def.Sprite {
			Texture=THEME:GetPathG("", "UI/TimerBG"),
			InitCommand=function(self) self:zoom(0.4):xy(0,timerBG_Y) end
		},
		
		-- Amount of lives left			
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
		-- duplicating manually as a hotfix
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
		}
	},

	--[[
	-- Bottom panel
	Def.Sprite {
		Texture=THEME:GetPathG("", "UI/PanelBottom"),
		InitCommand=function(self)
			self:scaletofit(0, 0, 1280, 128)
			:xy(SCREEN_CENTER_X, SCREEN_BOTTOM + 128):valign(1)
		end,
		OnCommand=function(self)
			self:easeoutexpo(0.5)
			:xy(SCREEN_CENTER_X, bottomPanel_Y)
		end,
		OffCommand=function(self)
			self:easeoutexpo(0.5)
			:xy(SCREEN_CENTER_X, SCREEN_BOTTOM + 128)
		end,
	},
	]]--
}

-- Profile info (clones for every active player)
for pn in ivalues(GAMESTATE:GetHumanPlayers()) do
	if PROFILEMAN:GetProfile(pn) and (PROFILEMAN:IsPersistentProfile(pn) or PROFILEMAN:ProfileWasLoadedFromMemoryCard(pn)) then
		t[#t+1] = Def.ActorFrame {            
			Def.ActorFrame {
				InitCommand=function(self) self:y(128) end,
				OnCommand=function(self) self:easeoutexpo(0.5):y(0) end,
				OffCommand=function(self) self:easeoutexpo(0.5):y(128) end,

				-- profile name BG graphic
				Def.Sprite {
					Texture=THEME:GetPathG("", "UI/NameTag" .. ToEnumShortString(pn)),
					InitCommand=function(self)
						self:xy(SCREEN_CENTER_X + (pn == PLAYER_2 and profileNameBG_X or -profileNameBG_X), SCREEN_BOTTOM - profileNameBG_Y)
						:halign(pn == PLAYER_2 and 0 or 1):valign(1):rotationz(180):zoomx(2)
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
				}
			}
		}
	end
end


return t