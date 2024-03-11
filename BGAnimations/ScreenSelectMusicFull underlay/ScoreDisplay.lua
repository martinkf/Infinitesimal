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
	local gradesAlpha = 0.5
	
	local correction_2P = pn == PLAYER_2 and 0 or 0 --offsetting X for player 2
	
	local machineGradeAnchor_X = 300
	local machineScoreAnchor_X = 300
	local machineNameAnchor_X = 486
	
	local personalGradeAnchor_X = 55
	local personalTextAnchor_X = 55
	local personalNameAnchor_X = 114
	
	local records_Yspacing = 40
	local row1Anchor_Y = -68
	local row2Anchor_Y = row1Anchor_Y + records_Yspacing
	local row3Anchor_Y = row2Anchor_Y + records_Yspacing
	local row4Anchor_Y = row3Anchor_Y + records_Yspacing
	local row5Anchor_Y = row4Anchor_Y + records_Yspacing
	
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
					
					-- CALCULATION AND LOGIC - Personal best score
					if PROFILEMAN:IsPersistentProfile(pn) then
						ProfileScores = PROFILEMAN:GetProfile(pn):GetHighScoreList(Song, Chart):GetHighScores()
						for i = 1, 5 do
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
								self:GetChild("PersonalScore" .. i):settext("")
								self:GetChild("PersonalName" .. i):settext("")
							end
						end
					else
						for i = 1, 5 do
							self:GetChild("PersonalGrade" .. i):visible(false)
							self:GetChild("PersonalScore" .. i):settext("")
							self:GetChild("PersonalName" .. i):settext("")
						end
					end

					-- CALCULATION AND LOGIC - Machine best score
					local MachineHighScores = PROFILEMAN:GetMachineProfile():GetHighScoreList(Song, Chart):GetHighScores()
					for i = 1, 5 do
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
							if pn == PLAYER_2 then
								self:GetChild("MachineName" .. i):settext(MachineName .. "  " .. truncatedDate)
							else
								self:GetChild("MachineName" .. i):settext(truncatedDate .. "  " .. MachineName)
							end
						else
							self:GetChild("MachineGrade" .. i):visible(false)
							self:GetChild("MachineScore" .. i):settext("")
							self:GetChild("MachineName" .. i):settext("")
						end
					end
					
					self:GetChild("PersonalRec-label"):settext("PERSONAL RECORDS")
					self:GetChild("MachineRec-label"):settext("MACHINE RECORDS")
				end,
				
				
				-- DRAWING
				
				-- central quad
				Def.Quad {
					InitCommand=function(self)
						self:zoomto(3, 258):diffuse(Color.White):diffusealpha(0.4):y(16):x(0)
					end
				},
				-- quad that divides personal record from machine record
				Def.Quad {
					InitCommand=function(self)
						self:zoomto(3, 226):diffuse(Color.White):diffusealpha(0.4):y(0):x(246 * (pn == PLAYER_2 and 1 or -1))
					end
				},
				
				-- labels
				Def.BitmapText {
					Font="Montserrat normal 20px",
					Name="PersonalRec-label",
					InitCommand=function(self)
						self:x(124 * (pn == PLAYER_2 and 1 or -1)):y(-104):zoom(0.7)
						:halign(0.5):maxwidth(300):shadowlength(2):skewx(-0.2)
					end
				},
				Def.BitmapText {
					Font="Montserrat normal 20px",
					Name="MachineRec-label",
					InitCommand=function(self)
						self:x(440 * (pn == PLAYER_2 and 1 or -1)):y(-104):zoom(0.7)
						:halign(0.5):maxwidth(300):shadowlength(2):skewx(-0.2)
					end
				},
				
			
				-- personal GRADE -- top 1
				Def.Sprite { Name="PersonalGrade1", InitCommand=function(self)
						self:xy(personalGradeAnchor_X * (pn == PLAYER_2 and 1 or -1), row1Anchor_Y):zoom(gradesZoom):diffusealpha(gradesAlpha) end, },
				-- personal TEXT -- top 1
				Def.BitmapText { Name="PersonalScore1", Font="Common normal", InitCommand=function(self)
						self:xy((personalTextAnchor_X * (pn == PLAYER_2 and 1 or -1)) + correction_2P, row1Anchor_Y):zoom(1):halign(0.5):diffuse(Color.White):vertspacing(-6):shadowlength(1) end, },
				-- personal NAME -- top 1
				Def.BitmapText { Name="PersonalName1", Font="Common normal", InitCommand=function(self)
						self:xy((personalNameAnchor_X * (pn == PLAYER_2 and 1 or -1)) + correction_2P, row1Anchor_Y):zoom(1):halign((pn == PLAYER_2 and 0 or 1)):diffuse(Color.White):vertspacing(-6):shadowlength(1) end, },
						
				-- personal GRADE -- top 2
				Def.Sprite { Name="PersonalGrade2",	InitCommand=function(self)
						self:xy(personalGradeAnchor_X * (pn == PLAYER_2 and 1 or -1), row2Anchor_Y):zoom(gradesZoom):diffusealpha(gradesAlpha) end, },
				-- personal TEXT -- top 2
				Def.BitmapText { Name="PersonalScore2",	Font="Common normal", InitCommand=function(self)
						self:xy((personalTextAnchor_X * (pn == PLAYER_2 and 1 or -1)) + correction_2P, row2Anchor_Y):zoom(1):halign(0.5):diffuse(Color.White):vertspacing(-6):shadowlength(1) end, },
				-- personal NAME -- top 2
				Def.BitmapText { Name="PersonalName2", Font="Common normal", InitCommand=function(self)
						self:xy((personalNameAnchor_X * (pn == PLAYER_2 and 1 or -1)) + correction_2P, row2Anchor_Y):zoom(1):halign((pn == PLAYER_2 and 0 or 1)):diffuse(Color.White):vertspacing(-6):shadowlength(1) end, },
				
				-- personal GRADE -- top 3
				Def.Sprite { Name="PersonalGrade3",	InitCommand=function(self)
						self:xy(personalGradeAnchor_X * (pn == PLAYER_2 and 1 or -1), row3Anchor_Y):zoom(gradesZoom):diffusealpha(gradesAlpha) end, },
				-- personal TEXT -- top 3
				Def.BitmapText { Name="PersonalScore3",	Font="Common normal", InitCommand=function(self)
						self:xy((personalTextAnchor_X * (pn == PLAYER_2 and 1 or -1)) + correction_2P, row3Anchor_Y):zoom(1):halign(0.5):diffuse(Color.White):vertspacing(-6):shadowlength(1) end, },
				-- personal NAME -- top 3
				Def.BitmapText { Name="PersonalName3", Font="Common normal", InitCommand=function(self)
						self:xy((personalNameAnchor_X * (pn == PLAYER_2 and 1 or -1)) + correction_2P, row3Anchor_Y):zoom(1):halign((pn == PLAYER_2 and 0 or 1)):diffuse(Color.White):vertspacing(-6):shadowlength(1) end, },
						
				-- personal GRADE -- top 4
				Def.Sprite { Name="PersonalGrade4",	InitCommand=function(self)
						self:xy(personalGradeAnchor_X * (pn == PLAYER_2 and 1 or -1), row4Anchor_Y):zoom(gradesZoom):diffusealpha(gradesAlpha) end, },
				-- personal TEXT -- top 4
				Def.BitmapText { Name="PersonalScore4",	Font="Common normal", InitCommand=function(self)
						self:xy((personalTextAnchor_X * (pn == PLAYER_2 and 1 or -1)) + correction_2P, row4Anchor_Y):zoom(1):halign(0.5):diffuse(Color.White):vertspacing(-6):shadowlength(1) end, },
				-- personal NAME -- top 4
				Def.BitmapText { Name="PersonalName4", Font="Common normal", InitCommand=function(self)
						self:xy((personalNameAnchor_X * (pn == PLAYER_2 and 1 or -1)) + correction_2P, row4Anchor_Y):zoom(1):halign((pn == PLAYER_2 and 0 or 1)):diffuse(Color.White):vertspacing(-6):shadowlength(1) end, },
						
				-- personal GRADE -- top 5
				Def.Sprite { Name="PersonalGrade5",	InitCommand=function(self)
						self:xy(personalGradeAnchor_X * (pn == PLAYER_2 and 1 or -1), row5Anchor_Y):zoom(gradesZoom):diffusealpha(gradesAlpha) end, },
				-- personal TEXT -- top 5
				Def.BitmapText { Name="PersonalScore5",	Font="Common normal", InitCommand=function(self)
						self:xy((personalTextAnchor_X * (pn == PLAYER_2 and 1 or -1)) + correction_2P, row5Anchor_Y):zoom(1):halign(0.5):diffuse(Color.White):vertspacing(-6):shadowlength(1) end, },
				-- personal NAME -- top 5
				Def.BitmapText { Name="PersonalName5", Font="Common normal", InitCommand=function(self)
						self:xy((personalNameAnchor_X * (pn == PLAYER_2 and 1 or -1)) + correction_2P, row5Anchor_Y):zoom(1):halign((pn == PLAYER_2 and 0 or 1)):diffuse(Color.White):vertspacing(-6):shadowlength(1) end, },
				
				
				
				-- machine GRADE -- top 1
				Def.Sprite { Name="MachineGrade1", InitCommand=function(self)
						self:xy(machineGradeAnchor_X * (pn == PLAYER_2 and 1 or -1), row1Anchor_Y):zoom(gradesZoom):diffusealpha(gradesAlpha) end, },
				-- machine SCORE -- top 1
				Def.BitmapText { Name="MachineScore1", Font="Common normal", InitCommand=function(self)
						self:xy((machineScoreAnchor_X * (pn == PLAYER_2 and 1 or -1)) + correction_2P, row1Anchor_Y):zoom(1):halign(0.5):diffuse(Color.White):vertspacing(-6):shadowlength(1) end, },
				-- machine NAME -- top 1
				Def.BitmapText { Name="MachineName1", Font="Common normal", InitCommand=function(self)
						self:xy((machineNameAnchor_X * (pn == PLAYER_2 and 1 or -1)) + correction_2P, row1Anchor_Y):zoom(1):halign(0.5):diffuse(Color.White):vertspacing(-6):shadowlength(1):maxwidth(265) end, },
				
				-- machine GRADE -- top 2
				Def.Sprite { Name="MachineGrade2", InitCommand=function(self)
						self:xy(machineGradeAnchor_X * (pn == PLAYER_2 and 1 or -1), row2Anchor_Y):zoom(gradesZoom):diffusealpha(gradesAlpha) end, },
				-- machine SCORE -- top 2
				Def.BitmapText { Name="MachineScore2", Font="Common normal", InitCommand=function(self)
						self:xy((machineScoreAnchor_X * (pn == PLAYER_2 and 1 or -1)) + correction_2P, row2Anchor_Y):zoom(1):halign(0.5):diffuse(Color.White):vertspacing(-6):shadowlength(1) end, },
				-- machine NAME -- top 2
				Def.BitmapText { Name="MachineName2", Font="Common normal", InitCommand=function(self)
						self:xy((machineNameAnchor_X * (pn == PLAYER_2 and 1 or -1)) + correction_2P, row2Anchor_Y):zoom(1):halign(0.5):diffuse(Color.White):vertspacing(-6):shadowlength(1):maxwidth(265) end, },
				
				-- machine GRADE -- top 3
				Def.Sprite { Name="MachineGrade3", InitCommand=function(self)
						self:xy(machineGradeAnchor_X * (pn == PLAYER_2 and 1 or -1), row3Anchor_Y):zoom(gradesZoom):diffusealpha(gradesAlpha) end, },
				-- machine SCORE -- top 3
				Def.BitmapText { Name="MachineScore3", Font="Common normal", InitCommand=function(self)
						self:xy((machineScoreAnchor_X * (pn == PLAYER_2 and 1 or -1)) + correction_2P, row3Anchor_Y):zoom(1):halign(0.5):diffuse(Color.White):vertspacing(-6):shadowlength(1) end, },
				-- machine NAME -- top 3
				Def.BitmapText { Name="MachineName3", Font="Common normal", InitCommand=function(self)
						self:xy((machineNameAnchor_X * (pn == PLAYER_2 and 1 or -1)) + correction_2P, row3Anchor_Y):zoom(1):halign(0.5):diffuse(Color.White):vertspacing(-6):shadowlength(1):maxwidth(265) end, },
						
				-- machine GRADE -- top 4
				Def.Sprite { Name="MachineGrade4", InitCommand=function(self)
						self:xy(machineGradeAnchor_X * (pn == PLAYER_2 and 1 or -1), row4Anchor_Y):zoom(gradesZoom):diffusealpha(gradesAlpha) end, },
				-- machine SCORE -- top 4
				Def.BitmapText { Name="MachineScore4", Font="Common normal", InitCommand=function(self)
						self:xy((machineScoreAnchor_X * (pn == PLAYER_2 and 1 or -1)) + correction_2P, row4Anchor_Y):zoom(1):halign(0.5):diffuse(Color.White):vertspacing(-6):shadowlength(1) end, },
				-- machine NAME -- top 4
				Def.BitmapText { Name="MachineName4", Font="Common normal", InitCommand=function(self)
						self:xy((machineNameAnchor_X * (pn == PLAYER_2 and 1 or -1)) + correction_2P, row4Anchor_Y):zoom(1):halign(0.5):diffuse(Color.White):vertspacing(-6):shadowlength(1):maxwidth(265) end, },
						
				-- machine GRADE -- top 5
				Def.Sprite { Name="MachineGrade5", InitCommand=function(self)
						self:xy(machineGradeAnchor_X * (pn == PLAYER_2 and 1 or -1), row5Anchor_Y):zoom(gradesZoom):diffusealpha(gradesAlpha) end, },
				-- machine SCORE -- top 5
				Def.BitmapText { Name="MachineScore5", Font="Common normal", InitCommand=function(self)
						self:xy((machineScoreAnchor_X * (pn == PLAYER_2 and 1 or -1)) + correction_2P, row5Anchor_Y):zoom(1):halign(0.5):diffuse(Color.White):vertspacing(-6):shadowlength(1) end, },
				-- machine NAME -- top 5
				Def.BitmapText { Name="MachineName5", Font="Common normal", InitCommand=function(self)
						self:xy((machineNameAnchor_X * (pn == PLAYER_2 and 1 or -1)) + correction_2P, row5Anchor_Y):zoom(1):halign(0.5):diffuse(Color.White):vertspacing(-6):shadowlength(1):maxwidth(265) end, },
			}
		}
	end
end

return t