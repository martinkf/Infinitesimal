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
	local wholeThing_Y = -270
	
	local gradesZoom = 0.16
	local gradesAlpha = 0.6
	
	local correction_2P = pn == PLAYER_2 and 0 or 0 --offsetting X for player 2
	
	local machineGradeAnchor_X = 334
	local machineScoreAnchor_X = 334
	local machineNameAnchor_X = 445
	local machineDateAnchor_X = 630
	
	local personalGradeAnchor_X = 330+60
	local personalScoreAnchor_X = 330+60
	local personalNameAnchor_X = 390+60
	
	local records_Yspacing = 42
	local row1Anchor_Y = -64
	local row2Anchor_Y = row1Anchor_Y + records_Yspacing
	local row3Anchor_Y = row2Anchor_Y + records_Yspacing
	local row4Anchor_Y = row3Anchor_Y + records_Yspacing
	local row5Anchor_Y = row4Anchor_Y + records_Yspacing
	local row6Anchor_Y = row5Anchor_Y + records_Yspacing
	local row7Anchor_Y = row6Anchor_Y + records_Yspacing
	local row8Anchor_Y = row7Anchor_Y + records_Yspacing
	local row9Anchor_Y = row8Anchor_Y + records_Yspacing
	local row10Anchor_Y = row9Anchor_Y + records_Yspacing
	local rowPer1Anchor_Y = 405
	local rowPer2Anchor_Y = rowPer1Anchor_Y + records_Yspacing
	local rowPer3Anchor_Y = rowPer2Anchor_Y + records_Yspacing
	
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
					
					-- CALCULATION AND LOGIC - Machine best score
					local MachineHighScores = PROFILEMAN:GetMachineProfile():GetHighScoreList(Song, Chart):GetHighScores()
					for i = 1, 10 do
						local scoreIndex = MachineHighScores[i]

						if scoreIndex ~= nil then
							local MachineScore = scoreIndex:GetScore()
							local MachineDP = round(scoreIndex:GetPercentDP() * 100, 2) .. "%"
							local MachineName = scoreIndex:GetName()
							local MachineDate = scoreIndex:GetDate()
							local truncatedDate = string.sub(MachineDate, 1, 10)

							self:GetChild("MachineGrade" .. i):Load(THEME:GetPathG("", "LetterGrades/" .. (ClassicGrades and "" or "New/") ..
								LoadModule("PIU/Score.Grading.lua")(scoreIndex))):visible(true)
							self:GetChild("MachineScore" .. i):settext(MachineDP)
							self:GetChild("MachineName" .. i):settext(MachineName)
							self:GetChild("MachineDate" .. i):settext(truncatedDate)
						else
							self:GetChild("MachineGrade" .. i):visible(false)
							self:GetChild("MachineScore" .. i):settext("-")
							self:GetChild("MachineName" .. i):settext("-")
							self:GetChild("MachineDate" .. i):settext("-")
						end
					end
					
					-- CALCULATION AND LOGIC - Personal best score
					if PROFILEMAN:IsPersistentProfile(pn) then
						ProfileScores = PROFILEMAN:GetProfile(pn):GetHighScoreList(Song, Chart):GetHighScores()
						for i = 1, 3 do
							local scoreIndex = ProfileScores[i]

							if scoreIndex ~= nil then
								local ProfileScore = scoreIndex:GetScore()
								local ProfileDP = round(scoreIndex:GetPercentDP() * 100, 2) .. "%"
								local ProfileDate = scoreIndex:GetDate()
								local truncatedDate = string.sub(ProfileDate, 1, 10)

								self:GetChild("PersonalGrade" .. i):Load(THEME:GetPathG("", "LetterGrades/" .. (ClassicGrades and "" or "New/") ..
									LoadModule("PIU/Score.Grading.lua")(scoreIndex))):visible(true)
								self:GetChild("PersonalScore" .. i):settext(ProfileDP)
								self:GetChild("PersonalName" .. i):settext(truncatedDate)
							else								
								self:GetChild("PersonalGrade" .. i):visible(false)
								self:GetChild("PersonalScore" .. i):settext("-")
								self:GetChild("PersonalName" .. i):settext("-")
							end
						end
					else
						for i = 1, 3 do
							self:GetChild("PersonalGrade" .. i):visible(false)
							self:GetChild("PersonalScore" .. i):settext("-")
							self:GetChild("PersonalName" .. i):settext("-")
						end
					end
					
				end,
				
				
				-- DRAWING
				
				-- central quad
				Def.Quad {
					InitCommand=function(self)
						self:zoomto(3, 320):diffuse(Color.White):diffusealpha(0.4):y(362):x(0)
					end
				},
				
				-- Machine Records label
				Def.Quad {
					InitCommand=function(self)
						self:zoomto(320, 20):diffuse(Color.White):diffusealpha(0.4):y(-104):x(466 * (pn == PLAYER_2 and 1 or -1))
					end
				},
				Def.BitmapText {
					Font="Montserrat normal 20px",
					Name="MachineRec-label",
					Text="MACHINE RECORDS",
					InitCommand=function(self)
						self:x(466 * (pn == PLAYER_2 and 1 or -1)):y(-104):zoom(0.7)
						:halign(0.5):maxwidth(300):shadowlength(2):skewx(-0.2)
					end
				},
				
				-- Personal Records label
				Def.Quad {
					InitCommand=function(self)
						self:zoomto(320, 20):diffuse(Color.White):diffusealpha(0.4):y(365):x(466 * (pn == PLAYER_2 and 1 or -1))
					end
				},
				Def.BitmapText {
					Font="Montserrat normal 20px",
					Name="PersonalRec-label",
					Text="PERSONAL RECORDS",
					InitCommand=function(self)
						self:x(466 * (pn == PLAYER_2 and 1 or -1)):y(365):zoom(0.7)
						:halign(0.5):maxwidth(300):shadowlength(2):skewx(-0.2)
					end
				},
				
				
				
				
							

							
				-- MACHINE RECORDS
				-- top 1
				Def.BitmapText { Name="MachineDate1", Font="Common normal", InitCommand=function(self)
						self:xy((machineDateAnchor_X * (pn == PLAYER_2 and 1 or -1)) + correction_2P, row1Anchor_Y):zoom(0.9):halign((pn == PLAYER_2 and 1 or 0)):diffuse(Color.White):vertspacing(-6):shadowlength(1):maxwidth(265) end, },				
				Def.BitmapText { Name="MachineName1", Font="Common normal", InitCommand=function(self)
						self:xy((machineNameAnchor_X * (pn == PLAYER_2 and 1 or -1)) + correction_2P, row1Anchor_Y):zoom(0.9):halign(0.5):diffuse(Color.White):vertspacing(-6):shadowlength(1):maxwidth(150) end, },				
				Def.Sprite { Name="MachineGrade1", InitCommand=function(self)
						self:xy(machineGradeAnchor_X * (pn == PLAYER_2 and 1 or -1), row1Anchor_Y):zoom(gradesZoom):diffusealpha(gradesAlpha) end, },				
				Def.BitmapText { Name="MachineScore1", Font="Common normal", InitCommand=function(self)
						self:xy((machineScoreAnchor_X * (pn == PLAYER_2 and 1 or -1)) + correction_2P, row1Anchor_Y):zoom(1):halign(0.5):diffuse(Color.White):vertspacing(-6):shadowlength(1) end, },
				
				-- top 2
				Def.BitmapText { Name="MachineDate2", Font="Common normal", InitCommand=function(self)
						self:xy((machineDateAnchor_X * (pn == PLAYER_2 and 1 or -1)) + correction_2P, row2Anchor_Y):zoom(0.9):halign((pn == PLAYER_2 and 1 or 0)):diffuse(Color.White):vertspacing(-6):shadowlength(1):maxwidth(265) end, },				
				Def.BitmapText { Name="MachineName2", Font="Common normal", InitCommand=function(self)
						self:xy((machineNameAnchor_X * (pn == PLAYER_2 and 1 or -1)) + correction_2P, row2Anchor_Y):zoom(0.9):halign(0.5):diffuse(Color.White):vertspacing(-6):shadowlength(1):maxwidth(150) end, },				
				Def.Sprite { Name="MachineGrade2", InitCommand=function(self)
						self:xy(machineGradeAnchor_X * (pn == PLAYER_2 and 1 or -1), row2Anchor_Y):zoom(gradesZoom):diffusealpha(gradesAlpha) end, },				
				Def.BitmapText { Name="MachineScore2", Font="Common normal", InitCommand=function(self)
						self:xy((machineScoreAnchor_X * (pn == PLAYER_2 and 1 or -1)) + correction_2P, row2Anchor_Y):zoom(1):halign(0.5):diffuse(Color.White):vertspacing(-6):shadowlength(1) end, },
								
				-- top 3
				Def.BitmapText { Name="MachineDate3", Font="Common normal", InitCommand=function(self)
						self:xy((machineDateAnchor_X * (pn == PLAYER_2 and 1 or -1)) + correction_2P, row3Anchor_Y):zoom(0.9):halign((pn == PLAYER_2 and 1 or 0)):diffuse(Color.White):vertspacing(-6):shadowlength(1):maxwidth(265) end, },				
				Def.BitmapText { Name="MachineName3", Font="Common normal", InitCommand=function(self)
						self:xy((machineNameAnchor_X * (pn == PLAYER_2 and 1 or -1)) + correction_2P, row3Anchor_Y):zoom(0.9):halign(0.5):diffuse(Color.White):vertspacing(-6):shadowlength(1):maxwidth(150) end, },				
				Def.Sprite { Name="MachineGrade3", InitCommand=function(self)
						self:xy(machineGradeAnchor_X * (pn == PLAYER_2 and 1 or -1), row3Anchor_Y):zoom(gradesZoom):diffusealpha(gradesAlpha) end, },				
				Def.BitmapText { Name="MachineScore3", Font="Common normal", InitCommand=function(self)
						self:xy((machineScoreAnchor_X * (pn == PLAYER_2 and 1 or -1)) + correction_2P, row3Anchor_Y):zoom(1):halign(0.5):diffuse(Color.White):vertspacing(-6):shadowlength(1) end, },
										
				-- top 4
				Def.BitmapText { Name="MachineDate4", Font="Common normal", InitCommand=function(self)
						self:xy((machineDateAnchor_X * (pn == PLAYER_2 and 1 or -1)) + correction_2P, row4Anchor_Y):zoom(0.9):halign((pn == PLAYER_2 and 1 or 0)):diffuse(Color.White):vertspacing(-6):shadowlength(1):maxwidth(265) end, },				
				Def.BitmapText { Name="MachineName4", Font="Common normal", InitCommand=function(self)
						self:xy((machineNameAnchor_X * (pn == PLAYER_2 and 1 or -1)) + correction_2P, row4Anchor_Y):zoom(0.9):halign(0.5):diffuse(Color.White):vertspacing(-6):shadowlength(1):maxwidth(150) end, },				
				Def.Sprite { Name="MachineGrade4", InitCommand=function(self)
						self:xy(machineGradeAnchor_X * (pn == PLAYER_2 and 1 or -1), row4Anchor_Y):zoom(gradesZoom):diffusealpha(gradesAlpha) end, },				
				Def.BitmapText { Name="MachineScore4", Font="Common normal", InitCommand=function(self)
						self:xy((machineScoreAnchor_X * (pn == PLAYER_2 and 1 or -1)) + correction_2P, row4Anchor_Y):zoom(1):halign(0.5):diffuse(Color.White):vertspacing(-6):shadowlength(1) end, },
				
				-- top 5
				Def.BitmapText { Name="MachineDate5", Font="Common normal", InitCommand=function(self)
						self:xy((machineDateAnchor_X * (pn == PLAYER_2 and 1 or -1)) + correction_2P, row5Anchor_Y):zoom(0.9):halign((pn == PLAYER_2 and 1 or 0)):diffuse(Color.White):vertspacing(-6):shadowlength(1):maxwidth(265) end, },				
				Def.BitmapText { Name="MachineName5", Font="Common normal", InitCommand=function(self)
						self:xy((machineNameAnchor_X * (pn == PLAYER_2 and 1 or -1)) + correction_2P, row5Anchor_Y):zoom(0.9):halign(0.5):diffuse(Color.White):vertspacing(-6):shadowlength(1):maxwidth(150) end, },				
				Def.Sprite { Name="MachineGrade5", InitCommand=function(self)
						self:xy(machineGradeAnchor_X * (pn == PLAYER_2 and 1 or -1), row5Anchor_Y):zoom(gradesZoom):diffusealpha(gradesAlpha) end, },				
				Def.BitmapText { Name="MachineScore5", Font="Common normal", InitCommand=function(self)
						self:xy((machineScoreAnchor_X * (pn == PLAYER_2 and 1 or -1)) + correction_2P, row5Anchor_Y):zoom(1):halign(0.5):diffuse(Color.White):vertspacing(-6):shadowlength(1) end, },
						
				-- top 6
				Def.BitmapText { Name="MachineDate6", Font="Common normal", InitCommand=function(self)
						self:xy((machineDateAnchor_X * (pn == PLAYER_2 and 1 or -1)) + correction_2P, row6Anchor_Y):zoom(0.9):halign((pn == PLAYER_2 and 1 or 0)):diffuse(Color.White):vertspacing(-6):shadowlength(1):maxwidth(265) end, },				
				Def.BitmapText { Name="MachineName6", Font="Common normal", InitCommand=function(self)
						self:xy((machineNameAnchor_X * (pn == PLAYER_2 and 1 or -1)) + correction_2P, row6Anchor_Y):zoom(0.9):halign(0.5):diffuse(Color.White):vertspacing(-6):shadowlength(1):maxwidth(150) end, },				
				Def.Sprite { Name="MachineGrade6", InitCommand=function(self)
						self:xy(machineGradeAnchor_X * (pn == PLAYER_2 and 1 or -1), row6Anchor_Y):zoom(gradesZoom):diffusealpha(gradesAlpha) end, },				
				Def.BitmapText { Name="MachineScore6", Font="Common normal", InitCommand=function(self)
						self:xy((machineScoreAnchor_X * (pn == PLAYER_2 and 1 or -1)) + correction_2P, row6Anchor_Y):zoom(1):halign(0.5):diffuse(Color.White):vertspacing(-6):shadowlength(1) end, },
				
				-- top 7
				Def.BitmapText { Name="MachineDate7", Font="Common normal", InitCommand=function(self)
						self:xy((machineDateAnchor_X * (pn == PLAYER_2 and 1 or -1)) + correction_2P, row7Anchor_Y):zoom(0.9):halign((pn == PLAYER_2 and 1 or 0)):diffuse(Color.White):vertspacing(-6):shadowlength(1):maxwidth(265) end, },				
				Def.BitmapText { Name="MachineName7", Font="Common normal", InitCommand=function(self)
						self:xy((machineNameAnchor_X * (pn == PLAYER_2 and 1 or -1)) + correction_2P, row7Anchor_Y):zoom(0.9):halign(0.5):diffuse(Color.White):vertspacing(-6):shadowlength(1):maxwidth(150) end, },				
				Def.Sprite { Name="MachineGrade7", InitCommand=function(self)
						self:xy(machineGradeAnchor_X * (pn == PLAYER_2 and 1 or -1), row7Anchor_Y):zoom(gradesZoom):diffusealpha(gradesAlpha) end, },				
				Def.BitmapText { Name="MachineScore7", Font="Common normal", InitCommand=function(self)
						self:xy((machineScoreAnchor_X * (pn == PLAYER_2 and 1 or -1)) + correction_2P, row7Anchor_Y):zoom(1):halign(0.5):diffuse(Color.White):vertspacing(-6):shadowlength(1) end, },
								
				-- top 8
				Def.BitmapText { Name="MachineDate8", Font="Common normal", InitCommand=function(self)
						self:xy((machineDateAnchor_X * (pn == PLAYER_2 and 1 or -1)) + correction_2P, row8Anchor_Y):zoom(0.9):halign((pn == PLAYER_2 and 1 or 0)):diffuse(Color.White):vertspacing(-6):shadowlength(1):maxwidth(265) end, },				
				Def.BitmapText { Name="MachineName8", Font="Common normal", InitCommand=function(self)
						self:xy((machineNameAnchor_X * (pn == PLAYER_2 and 1 or -1)) + correction_2P, row8Anchor_Y):zoom(0.9):halign(0.5):diffuse(Color.White):vertspacing(-6):shadowlength(1):maxwidth(150) end, },				
				Def.Sprite { Name="MachineGrade8", InitCommand=function(self)
						self:xy(machineGradeAnchor_X * (pn == PLAYER_2 and 1 or -1), row8Anchor_Y):zoom(gradesZoom):diffusealpha(gradesAlpha) end, },				
				Def.BitmapText { Name="MachineScore8", Font="Common normal", InitCommand=function(self)
						self:xy((machineScoreAnchor_X * (pn == PLAYER_2 and 1 or -1)) + correction_2P, row8Anchor_Y):zoom(1):halign(0.5):diffuse(Color.White):vertspacing(-6):shadowlength(1) end, },
										
				-- top 9
				Def.BitmapText { Name="MachineDate9", Font="Common normal", InitCommand=function(self)
						self:xy((machineDateAnchor_X * (pn == PLAYER_2 and 1 or -1)) + correction_2P, row9Anchor_Y):zoom(0.9):halign((pn == PLAYER_2 and 1 or 0)):diffuse(Color.White):vertspacing(-6):shadowlength(1):maxwidth(265) end, },				
				Def.BitmapText { Name="MachineName9", Font="Common normal", InitCommand=function(self)
						self:xy((machineNameAnchor_X * (pn == PLAYER_2 and 1 or -1)) + correction_2P, row9Anchor_Y):zoom(0.9):halign(0.5):diffuse(Color.White):vertspacing(-6):shadowlength(1):maxwidth(150) end, },				
				Def.Sprite { Name="MachineGrade9", InitCommand=function(self)
						self:xy(machineGradeAnchor_X * (pn == PLAYER_2 and 1 or -1), row9Anchor_Y):zoom(gradesZoom):diffusealpha(gradesAlpha) end, },				
				Def.BitmapText { Name="MachineScore9", Font="Common normal", InitCommand=function(self)
						self:xy((machineScoreAnchor_X * (pn == PLAYER_2 and 1 or -1)) + correction_2P, row9Anchor_Y):zoom(1):halign(0.5):diffuse(Color.White):vertspacing(-6):shadowlength(1) end, },
				
				-- top 10
				Def.BitmapText { Name="MachineDate10", Font="Common normal", InitCommand=function(self)
						self:xy((machineDateAnchor_X * (pn == PLAYER_2 and 1 or -1)) + correction_2P, row10Anchor_Y):zoom(0.9):halign((pn == PLAYER_2 and 1 or 0)):diffuse(Color.White):vertspacing(-6):shadowlength(1):maxwidth(265) end, },				
				Def.BitmapText { Name="MachineName10", Font="Common normal", InitCommand=function(self)
						self:xy((machineNameAnchor_X * (pn == PLAYER_2 and 1 or -1)) + correction_2P, row10Anchor_Y):zoom(0.9):halign(0.5):diffuse(Color.White):vertspacing(-6):shadowlength(1):maxwidth(150) end, },				
				Def.Sprite { Name="MachineGrade10", InitCommand=function(self)
						self:xy(machineGradeAnchor_X * (pn == PLAYER_2 and 1 or -1), row10Anchor_Y):zoom(gradesZoom):diffusealpha(gradesAlpha) end, },				
				Def.BitmapText { Name="MachineScore10", Font="Common normal", InitCommand=function(self)
						self:xy((machineScoreAnchor_X * (pn == PLAYER_2 and 1 or -1)) + correction_2P, row10Anchor_Y):zoom(1):halign(0.5):diffuse(Color.White):vertspacing(-6):shadowlength(1) end, },
				
				
				
				
				-- PERSONAL RECORDS
				-- top 1
				Def.Sprite { Name="PersonalGrade1", InitCommand=function(self)
						self:xy(personalGradeAnchor_X * (pn == PLAYER_2 and 1 or -1), rowPer1Anchor_Y):zoom(gradesZoom):diffusealpha(gradesAlpha) end, },				
				Def.BitmapText { Name="PersonalScore1", Font="Common normal", InitCommand=function(self)
						self:xy((personalScoreAnchor_X * (pn == PLAYER_2 and 1 or -1)) + correction_2P, rowPer1Anchor_Y):zoom(1):halign(0.5):diffuse(Color.White):vertspacing(-6):shadowlength(1) end, },				
				Def.BitmapText { Name="PersonalName1", Font="Common normal", InitCommand=function(self)
						self:xy((personalNameAnchor_X * (pn == PLAYER_2 and 1 or -1)) + correction_2P, rowPer1Anchor_Y):zoom(1):halign((pn == PLAYER_2 and 0 or 1)):diffuse(Color.White):vertspacing(-6):shadowlength(1) end, },
						
				-- top 2
				Def.Sprite { Name="PersonalGrade2",	InitCommand=function(self)
						self:xy(personalGradeAnchor_X * (pn == PLAYER_2 and 1 or -1), rowPer2Anchor_Y):zoom(gradesZoom):diffusealpha(gradesAlpha) end, },
				Def.BitmapText { Name="PersonalScore2",	Font="Common normal", InitCommand=function(self)
						self:xy((personalScoreAnchor_X * (pn == PLAYER_2 and 1 or -1)) + correction_2P, rowPer2Anchor_Y):zoom(1):halign(0.5):diffuse(Color.White):vertspacing(-6):shadowlength(1) end, },
				Def.BitmapText { Name="PersonalName2", Font="Common normal", InitCommand=function(self)
						self:xy((personalNameAnchor_X * (pn == PLAYER_2 and 1 or -1)) + correction_2P, rowPer2Anchor_Y):zoom(1):halign((pn == PLAYER_2 and 0 or 1)):diffuse(Color.White):vertspacing(-6):shadowlength(1) end, },
				
				-- top 3
				Def.Sprite { Name="PersonalGrade3",	InitCommand=function(self)
						self:xy(personalGradeAnchor_X * (pn == PLAYER_2 and 1 or -1), rowPer3Anchor_Y):zoom(gradesZoom):diffusealpha(gradesAlpha) end, },
				Def.BitmapText { Name="PersonalScore3",	Font="Common normal", InitCommand=function(self)
						self:xy((personalScoreAnchor_X * (pn == PLAYER_2 and 1 or -1)) + correction_2P, rowPer3Anchor_Y):zoom(1):halign(0.5):diffuse(Color.White):vertspacing(-6):shadowlength(1) end, },
				Def.BitmapText { Name="PersonalName3", Font="Common normal", InitCommand=function(self)
						self:xy((personalNameAnchor_X * (pn == PLAYER_2 and 1 or -1)) + correction_2P, rowPer3Anchor_Y):zoom(1):halign((pn == PLAYER_2 and 0 or 1)):diffuse(Color.White):vertspacing(-6):shadowlength(1) end, },
						
				
			}
		}
	end
end

return t