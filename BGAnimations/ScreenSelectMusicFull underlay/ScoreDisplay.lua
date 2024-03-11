local Scoring = LoadModule("Config.Load.lua")("ScoringSystem", "Save/OutFoxPrefs.ini") or "Old"
local ClassicGrades = LoadModule("Config.Load.lua")("ClassicGrades", "Save/OutFoxPrefs.ini") and Scoring == "Old"
local SongIsChosen = false

local t = Def.ActorFrame {}

for pn in ivalues(GAMESTATE:GetHumanPlayers()) do
    -- Player 2's panel is slightly adjusted, so we need to correct
    -- the positioning of actors so that they fit in properly
    local CorrectionX = pn == PLAYER_2 and -15 or 0
    
    t[#t+1] = Def.ActorFrame {
        Def.ActorFrame {
            CurrentChartChangedMessageCommand=function(self, params) if SongIsChosen and params.Player == pn then self:playcommand("Refresh") end end,
            
            SongChosenMessageCommand=function(self)
                SongIsChosen = true
                self:stoptweening():easeoutexpo(0.5)
                :x(358 * (pn == PLAYER_2 and 1 or -1))
                self:playcommand("Refresh")
            end,
            SongUnchosenMessageCommand=function(self)
                SongIsChosen = false
                self:stoptweening():easeoutexpo(0.5):x(0)
            end,

            RefreshCommand=function(self)
                Song = GAMESTATE:GetCurrentSong()
                Chart = GAMESTATE:GetCurrentSteps(pn)

                -- Personal best score
                if PROFILEMAN:IsPersistentProfile(pn) then
                    ProfileScores = PROFILEMAN:GetProfile(pn):GetHighScoreList(Song, Chart):GetHighScores()

                    if ProfileScores[1] ~= nil then
                        local ProfileScore = ProfileScores[1]:GetScore()
                        local ProfileDP = round(ProfileScores[1]:GetPercentDP() * 100, 2) .. "%"

                        self:GetChild("PersonalGrade"):Load(THEME:GetPathG("", "LetterGrades/" .. (ClassicGrades and "" or "New/") ..
                            LoadModule("PIU/Score.Grading.lua")(ProfileScores[1]))):visible(true)
                        self:GetChild("PersonalScore"):settext(ProfileDP .. "\n" .. ProfileScore)
                    else
                        self:GetChild("PersonalGrade"):visible(false)
                        self:GetChild("PersonalScore"):settext("")
                    end
                else
                    self:GetChild("PersonalGrade"):visible(false)
                    self:GetChild("PersonalScore"):settext("")
                end

                -- Machine best score
                local MachineHighScores = PROFILEMAN:GetMachineProfile():GetHighScoreList(Song, Chart):GetHighScores()
                if MachineHighScores[1] ~= nil then
                    local MachineScore = MachineHighScores[1]:GetScore()
                    local MachineDP = round(MachineHighScores[1]:GetPercentDP() * 100, 2) .. "%"
                    local MachineName = MachineHighScores[1]:GetName()

                    self:GetChild("MachineGrade"):Load(THEME:GetPathG("", "LetterGrades/" .. (ClassicGrades and "" or "New/") ..
                            LoadModule("PIU/Score.Grading.lua")(MachineHighScores[1]))):visible(true)
                    self:GetChild("MachineScore"):settext(MachineName .. "\n" .. MachineDP .. "\n" .. MachineScore)
                else
                    self:GetChild("MachineGrade"):visible(false)
                    self:GetChild("MachineScore"):settext("")
                end
            end,

            Def.Sprite {
                -- Texture=THEME:GetPathG("", "UI/ScoreDisplay"),
                InitCommand=function(self)
                    self:Load(THEME:GetPathG("", "UI/ScoreDisplay" .. ToEnumShortString(pn)))
                    :xy(0, 0):zoom(0.75)
                end,
            },
            
            Def.Sprite {
                Name="PersonalGrade",
                InitCommand=function(self)
                    self:xy(-40 + CorrectionX, -35):zoom(0.2)
                end,
            },

            Def.BitmapText {
                Name="PersonalScore",
                Font="Common normal",
                InitCommand=function(self)
                    self:xy(90 + CorrectionX, -35):zoom(1):halign(1)
                    :diffuse(Color.White):vertspacing(-6):shadowlength(1)
                end,
            },
            
            Def.Sprite {
                Name="MachineGrade",
                InitCommand=function(self)
                    self:xy(-40 + CorrectionX, 60):zoom(0.2)
                end,
            },

            Def.BitmapText {
                Name="MachineScore",
                Font="Common normal",
                InitCommand=function(self)
                    self:xy(90 + CorrectionX, 60):zoom(1):halign(1)
                    :diffuse(Color.White):vertspacing(-6):shadowlength(1)
                end,
            },
        }
    }
end

----
-- vvvv POI PROJECT vvvv
----

local usingPOIUX = LoadModule("Config.Load.lua")("ActivatePOIProjectUX", "Save/OutFoxPrefs.ini") or false
if usingPOIUX then
	-- levers
	local wholeThing_X = 0
	local wholeThing_Y = 104
	
	local correction_2P = pn == PLAYER_2 and 0 or 0 --offsetting for player 2
	local machineRecordGrade_X = 160+314
	local machineRecordText_X = 200+314
	local machineRecordGrade_Y = -60
	local machineRecordText_Y = -60
	
	local personalGrade_X = 294
	local personalText_X = 334
	local personalGrade_Y = -60
	local personalText_Y = -60
	
	--local recordStyle = "Points and Percent"
	local recordStyle = "Percent Only"
	
	
	t = Def.ActorFrame {}
	for pn in ivalues(GAMESTATE:GetHumanPlayers()) do
		-- Player 2's panel is slightly adjusted, so we need to correct
		-- the positioning of actors so that they fit in properly
		
		
		t[#t+1] = Def.ActorFrame {
			Def.ActorFrame {
				CurrentChartChangedMessageCommand=function(self, params) if SongIsChosen and params.Player == pn then self:playcommand("Refresh") end end,
				InitCommand=function(self)
					self:x(wholeThing_X * (pn == PLAYER_2 and 1 or -1))
				end,
				
				SongChosenMessageCommand=function(self)
					SongIsChosen = true
					self:stoptweening():easeoutexpo(1)
					:y(wholeThing_Y)
					self:playcommand("Refresh")
				end,
				SongUnchosenMessageCommand=function(self)
					SongIsChosen = false
					self:stoptweening():easeoutexpo(0.5)
					:y(wholeThing_Y-wholeThing_Y)
				end,

				RefreshCommand=function(self)
					Song = GAMESTATE:GetCurrentSong()
					Chart = GAMESTATE:GetCurrentSteps(pn)

					if (recordStyle == "Points and Percent") then
						-- CALCULATION AND LOGIC - Personal best score
						if PROFILEMAN:IsPersistentProfile(pn) then
							ProfileScores = PROFILEMAN:GetProfile(pn):GetHighScoreList(Song, Chart):GetHighScores()

							if ProfileScores[1] ~= nil then
								local ProfileScore = ProfileScores[1]:GetScore()
								local ProfileDP = round(ProfileScores[1]:GetPercentDP() * 100, 2) .. "%"

								self:GetChild("PersonalGrade"):Load(THEME:GetPathG("", "LetterGrades/" .. (ClassicGrades and "" or "New/") ..
									LoadModule("PIU/Score.Grading.lua")(ProfileScores[1]))):visible(true)
								self:GetChild("PersonalScore"):settext(ProfileDP .. "\n" .. ProfileScore)
							else
								self:GetChild("PersonalGrade"):visible(false)
								self:GetChild("PersonalScore"):settext("")
							end
						else
							self:GetChild("PersonalGrade"):visible(false)
							self:GetChild("PersonalScore"):settext("")
						end

						-- CALCULATION AND LOGIC - Machine best score
						local MachineHighScores = PROFILEMAN:GetMachineProfile():GetHighScoreList(Song, Chart):GetHighScores()
						if MachineHighScores[1] ~= nil then
							local MachineScore = MachineHighScores[1]:GetScore()
							local MachineDP = round(MachineHighScores[1]:GetPercentDP() * 100, 2) .. "%"
							local MachineName = MachineHighScores[1]:GetName()

							self:GetChild("MachineGrade"):Load(THEME:GetPathG("", "LetterGrades/" .. (ClassicGrades and "" or "New/") ..
									LoadModule("PIU/Score.Grading.lua")(MachineHighScores[1]))):visible(true)
							self:GetChild("MachineScore"):settext(MachineName .. "\n" .. MachineDP .. "\n" .. MachineScore)
						else
							self:GetChild("MachineGrade"):visible(false)
							self:GetChild("MachineScore"):settext("")
						end
					elseif (recordStyle == "Percent Only") then					
						-- CALCULATION AND LOGIC - Personal best score
						if PROFILEMAN:IsPersistentProfile(pn) then
							ProfileScores = PROFILEMAN:GetProfile(pn):GetHighScoreList(Song, Chart):GetHighScores()

							if ProfileScores[1] ~= nil then
								local ProfileScore = ProfileScores[1]:GetScore()
								local ProfileDP = round(ProfileScores[1]:GetPercentDP() * 100, 2) .. "%"

								self:GetChild("PersonalGrade"):Load(THEME:GetPathG("", "LetterGrades/" .. (ClassicGrades and "" or "New/") ..
									LoadModule("PIU/Score.Grading.lua")(ProfileScores[1]))):visible(true)
								self:GetChild("PersonalScore"):settext(ProfileDP)
							else
								self:GetChild("PersonalGrade"):visible(false)
								self:GetChild("PersonalScore"):settext("")
							end
						else
							self:GetChild("PersonalGrade"):visible(false)
							self:GetChild("PersonalScore"):settext("")
						end

						-- CALCULATION AND LOGIC - Machine best score
						local MachineHighScores = PROFILEMAN:GetMachineProfile():GetHighScoreList(Song, Chart):GetHighScores()
						if MachineHighScores[1] ~= nil then
							local MachineScore = MachineHighScores[1]:GetScore()
							local MachineDP = round(MachineHighScores[1]:GetPercentDP() * 100, 2) .. "%"
							local MachineName = MachineHighScores[1]:GetName()

							self:GetChild("MachineGrade"):Load(THEME:GetPathG("", "LetterGrades/" .. (ClassicGrades and "" or "New/") ..
									LoadModule("PIU/Score.Grading.lua")(MachineHighScores[1]))):visible(true)
							self:GetChild("MachineScore"):settext(MachineName .. "\n" .. MachineDP)
						else
							self:GetChild("MachineGrade"):visible(false)
							self:GetChild("MachineScore"):settext("")
						end
					else
					end
				end,

				-- background BG graphic UI
				--[[
				Def.Sprite {
					-- Texture=THEME:GetPathG("", "UI/ScoreDisplay"),
					InitCommand=function(self)
						self:Load(THEME:GetPathG("", "UI/ScoreDisplay" .. ToEnumShortString(pn)))
						:xy(0, 0):zoom(0.75)
					end,
				},
				]]--
				
				-- sprite for your personal record GRADE
				Def.Sprite {
					Name="PersonalGrade",
					InitCommand=function(self)
						self:xy(personalGrade_X * (pn == PLAYER_2 and 1 or -1), personalGrade_Y):zoom(0.2)
					end,
				},

				-- text for your personal record TEXT
				Def.BitmapText {
					Name="PersonalScore",
					Font="Common normal",
					InitCommand=function(self)
						self:xy((personalText_X * (pn == PLAYER_2 and 1 or -1)) + correction_2P, personalText_Y):zoom(1):halign((pn == PLAYER_2 and 0 or 1))
						:diffuse(Color.White):vertspacing(-6):shadowlength(1)
					end,
				},
				
				-- sprite for the machine record GRADE
				Def.Sprite {
					Name="MachineGrade",
					InitCommand=function(self)
						self:xy(machineRecordGrade_X * (pn == PLAYER_2 and 1 or -1), machineRecordGrade_Y):zoom(0.2)
					end,
				},

				-- text for the machine record TEXT
				Def.BitmapText {
					Name="MachineScore",
					Font="Common normal",
					InitCommand=function(self)
						self:xy((machineRecordText_X * (pn == PLAYER_2 and 1 or -1)) + correction_2P, machineRecordText_Y):zoom(1):halign((pn == PLAYER_2 and 0 or 1))
						:diffuse(Color.White):vertspacing(-6):shadowlength(1)
					end,
				}
			}
		}
	end
end

return t