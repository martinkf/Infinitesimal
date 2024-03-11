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
	
	local gradesZoom = 0.15
	
	local correction_2P = pn == PLAYER_2 and 0 or 0 --offsetting for player 2
	local machineRecordGrade1_X = 474
	local machineRecordText1_X = 514
	local machineRecordGrade1_Y = -60
	local machineRecordText1_Y = -60
	
	local personalGrade1_X = 294
	local personalText1_X = 334
	local personalGrade1_Y = -60
	local personalText1_Y = -60
	
	local records_Yspacing = 44
	local machineRecordGrade2_X = 474
	local machineRecordText2_X = 514
	local machineRecordGrade2_Y = machineRecordGrade1_Y + records_Yspacing
	local machineRecordText2_Y = machineRecordText1_Y + records_Yspacing
	
	local personalGrade2_X = 294
	local personalText2_X = 334
	local personalGrade2_Y = personalGrade1_Y + records_Yspacing
	local personalText2_Y = personalText1_Y + records_Yspacing
	
	local machineRecordGrade3_X = 474
	local machineRecordText3_X = 514
	local machineRecordGrade3_Y = machineRecordGrade2_Y + records_Yspacing
	local machineRecordText3_Y = machineRecordText2_Y + records_Yspacing
	
	local personalGrade3_X = 294
	local personalText3_X = 334
	local personalGrade3_Y = personalGrade2_Y + records_Yspacing
	local personalText3_Y = personalText2_Y + records_Yspacing
	
	
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

								self:GetChild("PersonalGrade1"):Load(THEME:GetPathG("", "LetterGrades/" .. (ClassicGrades and "" or "New/") ..
									LoadModule("PIU/Score.Grading.lua")(ProfileScores[1]))):visible(true)
								self:GetChild("PersonalScore1"):settext(ProfileDP)
							else
								self:GetChild("PersonalGrade1"):visible(false)
								self:GetChild("PersonalScore1"):settext("")
							end
							
							if ProfileScores[2] ~= nil then
								local ProfileScore = ProfileScores[2]:GetScore()
								local ProfileDP = round(ProfileScores[2]:GetPercentDP() * 100, 2) .. "%"

								self:GetChild("PersonalGrade2"):Load(THEME:GetPathG("", "LetterGrades/" .. (ClassicGrades and "" or "New/") ..
									LoadModule("PIU/Score.Grading.lua")(ProfileScores[2]))):visible(true)
								self:GetChild("PersonalScore2"):settext(ProfileDP)
							else
								self:GetChild("PersonalGrade2"):visible(false)
								self:GetChild("PersonalScore2"):settext("")
							end
							
							if ProfileScores[3] ~= nil then
								local ProfileScore = ProfileScores[3]:GetScore()
								local ProfileDP = round(ProfileScores[3]:GetPercentDP() * 100, 2) .. "%"

								self:GetChild("PersonalGrade3"):Load(THEME:GetPathG("", "LetterGrades/" .. (ClassicGrades and "" or "New/") ..
									LoadModule("PIU/Score.Grading.lua")(ProfileScores[3]))):visible(true)
								self:GetChild("PersonalScore3"):settext(ProfileDP)
							else
								self:GetChild("PersonalGrade3"):visible(false)
								self:GetChild("PersonalScore3"):settext("")
							end
						else
							self:GetChild("PersonalGrade1"):visible(false)
							self:GetChild("PersonalScore1"):settext("")
							self:GetChild("PersonalGrade2"):visible(false)
							self:GetChild("PersonalScore2"):settext("")
							self:GetChild("PersonalGrade3"):visible(false)
							self:GetChild("PersonalScore3"):settext("")
						end

						-- CALCULATION AND LOGIC - Machine best score
						local MachineHighScores = PROFILEMAN:GetMachineProfile():GetHighScoreList(Song, Chart):GetHighScores()
						if MachineHighScores[1] ~= nil then
							local MachineScore = MachineHighScores[1]:GetScore()
							local MachineDP = round(MachineHighScores[1]:GetPercentDP() * 100, 2) .. "%"
							local MachineName = MachineHighScores[1]:GetName()

							self:GetChild("MachineGrade1"):Load(THEME:GetPathG("", "LetterGrades/" .. (ClassicGrades and "" or "New/") ..
									LoadModule("PIU/Score.Grading.lua")(MachineHighScores[1]))):visible(true)
							self:GetChild("MachineScore1"):settext(MachineName .. "\n" .. MachineDP)
						else
							self:GetChild("MachineGrade1"):visible(false)
							self:GetChild("MachineScore1"):settext("")
						end
						if MachineHighScores[2] ~= nil then
							local MachineScore = MachineHighScores[2]:GetScore()
							local MachineDP = round(MachineHighScores[2]:GetPercentDP() * 100, 2) .. "%"
							local MachineName = MachineHighScores[2]:GetName()

							self:GetChild("MachineGrade2"):Load(THEME:GetPathG("", "LetterGrades/" .. (ClassicGrades and "" or "New/") ..
									LoadModule("PIU/Score.Grading.lua")(MachineHighScores[2]))):visible(true)
							self:GetChild("MachineScore2"):settext(MachineName .. "\n" .. MachineDP)
						else
							self:GetChild("MachineGrade2"):visible(false)
							self:GetChild("MachineScore2"):settext("")
						end
						if MachineHighScores[3] ~= nil then
							local MachineScore = MachineHighScores[3]:GetScore()
							local MachineDP = round(MachineHighScores[3]:GetPercentDP() * 100, 2) .. "%"
							local MachineName = MachineHighScores[3]:GetName()

							self:GetChild("MachineGrade3"):Load(THEME:GetPathG("", "LetterGrades/" .. (ClassicGrades and "" or "New/") ..
									LoadModule("PIU/Score.Grading.lua")(MachineHighScores[3]))):visible(true)
							self:GetChild("MachineScore3"):settext(MachineName .. "\n" .. MachineDP)
						else
							self:GetChild("MachineGrade3"):visible(false)
							self:GetChild("MachineScore3"):settext("")
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
				
				-- sprite for your personal record GRADE -- top 1
				Def.Sprite {
					Name="PersonalGrade1",
					InitCommand=function(self)
						self:xy(personalGrade1_X * (pn == PLAYER_2 and 1 or -1), personalGrade1_Y):zoom(gradesZoom)
					end,
				},

				-- text for your personal record TEXT -- top 1
				Def.BitmapText {
					Name="PersonalScore1",
					Font="Common normal",
					InitCommand=function(self)
						self:xy((personalText1_X * (pn == PLAYER_2 and 1 or -1)) + correction_2P, personalText1_Y):zoom(1):halign((pn == PLAYER_2 and 0 or 1))
						:diffuse(Color.White):vertspacing(-6):shadowlength(1)
					end,
				},
				
				-- sprite for your personal record GRADE -- top 2
				Def.Sprite {
					Name="PersonalGrade2",
					InitCommand=function(self)
						self:xy(personalGrade2_X * (pn == PLAYER_2 and 1 or -1), personalGrade2_Y):zoom(gradesZoom)
					end,
				},

				-- text for your personal record TEXT -- top 2
				Def.BitmapText {
					Name="PersonalScore2",
					Font="Common normal",
					InitCommand=function(self)
						self:xy((personalText2_X * (pn == PLAYER_2 and 1 or -1)) + correction_2P, personalText2_Y):zoom(1):halign((pn == PLAYER_2 and 0 or 1))
						:diffuse(Color.White):vertspacing(-6):shadowlength(1)
					end,
				},
				
				-- sprite for your personal record GRADE -- top 3
				Def.Sprite {
					Name="PersonalGrade3",
					InitCommand=function(self)
						self:xy(personalGrade3_X * (pn == PLAYER_2 and 1 or -1), personalGrade3_Y):zoom(gradesZoom)
					end,
				},

				-- text for your personal record TEXT -- top 3
				Def.BitmapText {
					Name="PersonalScore3",
					Font="Common normal",
					InitCommand=function(self)
						self:xy((personalText3_X * (pn == PLAYER_2 and 1 or -1)) + correction_2P, personalText3_Y):zoom(1):halign((pn == PLAYER_2 and 0 or 1))
						:diffuse(Color.White):vertspacing(-6):shadowlength(1)
					end,
				},
				
				-- sprite for the machine record GRADE -- top 1
				Def.Sprite {
					Name="MachineGrade1",
					InitCommand=function(self)
						self:xy(machineRecordGrade1_X * (pn == PLAYER_2 and 1 or -1), machineRecordGrade1_Y):zoom(gradesZoom)
					end,
				},

				-- text for the machine record TEXT -- top 1
				Def.BitmapText {
					Name="MachineScore1",
					Font="Common normal",
					InitCommand=function(self)
						self:xy((machineRecordText1_X * (pn == PLAYER_2 and 1 or -1)) + correction_2P, machineRecordText1_Y):zoom(1):halign((pn == PLAYER_2 and 0 or 1))
						:diffuse(Color.White):vertspacing(-6):shadowlength(1)
					end,
				},
				
				-- sprite for the machine record GRADE -- top 2
				Def.Sprite {
					Name="MachineGrade2",
					InitCommand=function(self)
						self:xy(machineRecordGrade2_X * (pn == PLAYER_2 and 1 or -1), machineRecordGrade2_Y):zoom(gradesZoom)
					end,
				},

				-- text for the machine record TEXT -- top 2
				Def.BitmapText {
					Name="MachineScore2",
					Font="Common normal",
					InitCommand=function(self)
						self:xy((machineRecordText2_X * (pn == PLAYER_2 and 1 or -1)) + correction_2P, machineRecordText2_Y):zoom(1):halign((pn == PLAYER_2 and 0 or 1))
						:diffuse(Color.White):vertspacing(-6):shadowlength(1)
					end,
				},
				
				-- sprite for the machine record GRADE -- top 3
				Def.Sprite {
					Name="MachineGrade3",
					InitCommand=function(self)
						self:xy(machineRecordGrade3_X * (pn == PLAYER_2 and 1 or -1), machineRecordGrade3_Y):zoom(gradesZoom)
					end,
				},

				-- text for the machine record TEXT -- top 3
				Def.BitmapText {
					Name="MachineScore3",
					Font="Common normal",
					InitCommand=function(self)
						self:xy((machineRecordText3_X * (pn == PLAYER_2 and 1 or -1)) + correction_2P, machineRecordText3_Y):zoom(1):halign((pn == PLAYER_2 and 0 or 1))
						:diffuse(Color.White):vertspacing(-6):shadowlength(1)
					end,
				}
			}
		}
	end
end

return t