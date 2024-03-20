setenv("IsBasicMode", false)
local t = Def.ActorFrame {}

-- The column thing
t[#t+1] = Def.Quad {
    InitCommand=function(self)
        self:xy(SCREEN_CENTER_X,SCREEN_CENTER_Y):valign(0.5)
        :zoomx(255)
        :diffuse(0,0,0,0.75)
        :zoomy(0)
        :decelerate(0.5)
        :zoomy(SCREEN_HEIGHT)
    end,
    OffCommand=function(self)
        self:stoptweening():decelerate(0.5):zoomy(0)
    end
}

t[#t+1] = LoadActor("MusicWheel") .. { Name="MusicWheel" }

for pn in ivalues(GAMESTATE:GetHumanPlayers()) do
    t[#t+1] = Def.ActorFrame {
        Def.Actor {
            -- If no AV is defined, do it before it causes any issues
            OnCommand=function(self)
                local AV = LoadModule("Config.Load.lua")("AutoVelocity", CheckIfUserOrMachineProfile(string.sub(pn,-1)-1).."/OutFoxPrefs.ini")
                if not AV then
                    LoadModule("Config.Save.lua")("AutoVelocity", tostring(200), CheckIfUserOrMachineProfile(string.sub(pn,-1)-1).."/OutFoxPrefs.ini")
                end
                LoadModule("Player.SetSpeed.lua")(pn)
            end,

            -- Make sure the speed is set relative to the selected song when going to gameplay
            OffCommand=function(self)
                LoadModule("Player.SetSpeed.lua")(pn)
            end
        },

        LoadActor("../ModIcons", pn) .. {
            InitCommand=function(self)
                self:xy(pn == PLAYER_2 and SCREEN_RIGHT + 40 * 2 or -40 * 2, 160)
                :easeoutexpo(1):x(pn == PLAYER_2 and SCREEN_RIGHT - 40 or 40)
            end,
            OffCommand=function(self)
                self:stoptweening():easeoutexpo(1):x(pn == PLAYER_2 and SCREEN_RIGHT + 40 * 2 or -40 * 2)
            end
        },

        Def.ActorFrame {
            InitCommand=function(self)
                self:xy(SCREEN_CENTER_X, -SCREEN_CENTER_Y)
                :easeoutexpo(1):y(SCREEN_CENTER_Y - 11)
            end,
            OffCommand=function(self)
                self:stoptweening():easeoutexpo(1)
                :y(-SCREEN_CENTER_Y - 100)
            end,

            StepsChosenMessageCommand=function(self, params)
                if params.Player == pn then
                    self:stoptweening():easeoutexpo(0.5)
                    :x(SCREEN_CENTER_X + (pn == PLAYER_2 and 380 or -380))
                end
            end,
            CurrentChartChangedMessageCommand=function(self, params)
                if params.Player == pn then
                    self:stoptweening():easeoutexpo(0.5):x(SCREEN_CENTER_X)
                end
            end,
            StepsUnchosenMessageCommand=function(self)
                self:stoptweening():easeoutexpo(0.5):x(SCREEN_CENTER_X)
            end,
            SongUnchosenMessageCommand=function(self)
                self:stoptweening():easeoutexpo(0.5):x(SCREEN_CENTER_X)
            end,

            Def.Quad {
                InitCommand=function(self)
                    self:zoomto(128, 32):diffuse(Color.White)

                    if pn == PLAYER_2 then
                        self:diffuserightedge(Color.Invisible)
                    else
                        self:diffuseleftedge(Color.Invisible)
                    end
                end
            },

            Def.Sprite {
                Texture=THEME:GetPathG("", "UI/Ready" .. ToEnumShortString(pn)),
                InitCommand=function(self) self:y(1) end
            }
        }
  }
end

t[#t+1] = Def.ActorFrame {
    Def.ActorFrame {
        InitCommand=function(self)
            self:xy(SCREEN_CENTER_X, -SCREEN_CENTER_Y):zoom(0.5)
            :easeoutexpo(1):y(SCREEN_CENTER_Y)
        end,
        OffCommand=function(self)
            self:stoptweening():easeoutexpo(1):y(-SCREEN_CENTER_Y)
        end,
        SongChosenMessageCommand=function(self)
            self:stoptweening():easeoutexpo(0.5):y(SCREEN_CENTER_Y + 95):zoom(1)
        end,
        SongUnchosenMessageCommand=function(self)
            self:stoptweening():easeoutexpo(0.25):y(SCREEN_CENTER_Y):zoom(0.5)
        end,

        Def.Sprite {
            Texture=THEME:GetPathG("", "DifficultyDisplay/InfoPanel"),
            InitCommand=function(self) self:y(85):zoom(0.75) end
        },

        LoadActor("ChartInfo")
    }
}

t[#t+1] = Def.ActorFrame {
    Def.ActorFrame {
        InitCommand=function(self)
            self:xy(SCREEN_CENTER_X, -SCREEN_CENTER_Y)
            :easeoutexpo(1):y(SCREEN_CENTER_Y)
        end,
        OffCommand=function(self)
            self:stoptweening():easeoutexpo(1):y(-SCREEN_CENTER_Y)
        end,

        SongChosenMessageCommand=function(self)
            self:stoptweening():easeoutexpo(0.5):y(SCREEN_CENTER_Y-40):zoom(0.9)
        end,
        SongUnchosenMessageCommand=function(self)
            self:stoptweening():easeoutexpo(0.5):y(SCREEN_CENTER_Y):zoom(1)
        end,

        LoadActor("ScoreDisplay") .. {
            InitCommand=function(self) self:y(-100) end
        },
        
        LoadActor("PadIcons") .. {
            InitCommand=function(self) self:y(24) end
        },

        LoadActor("SongPreview") .. {
            InitCommand=function(self) self:y(-100) end
        },
        
        Def.ActorFrame {
            InitCommand=function(self) self:y(85) end,

            SongChosenMessageCommand=function(self)
                self:stoptweening():easeoutexpo(0.5):y(94):zoom(1.25)
            end,
            SongUnchosenMessageCommand=function(self)
                self:stoptweening():easeoutexpo(0.5):y(85):zoom(1)
            end,            

            Def.Sprite {
                Texture=THEME:GetPathG("", "DifficultyDisplay/Bar"),
                InitCommand=function(self) self:zoom(1.2) end
            },

            LoadActor("BigPreviewBall")..{
              Condition = (LoadModule("Config.Load.lua")("ShowBigBall", "Save/OutFoxPrefs.ini") and GetScreenAspectRatio() >= 1.5)
            },

            LoadActor("ChartDisplay", 12)
        }
    }
}

----
-- vvvv POI PROJECT vvvv
----

local usingPOIUX = LoadModule("Config.Load.lua")("ActivatePOIProjectUX", "Save/OutFoxPrefs.ini") or false
if usingPOIUX then
	-- levers
	local chartInfoScoreDisplay_Y = 463
	local chartsBalls_SelectingSongY = 242
	local chartsBalls_SelectingSongZoom = 1.5
	local chartsBalls_SelectingChartY = 74
	local chartsBalls_SelectingSongDiffuseAlpha = 0.4
	local chartsBalls_SelectingChartDiffuseAlpha = 0.8
	
	t = Def.ActorFrame {}
	
	-- song preview module
	t[#t+1] = Def.ActorFrame {
		Def.ActorFrame {
			InitCommand=function(self)
				self:xy(SCREEN_CENTER_X, SCREEN_CENTER_Y)
			end,
			
			LoadActor("SongPreview") .. {
				InitCommand=function(self) self:y(-100) end
			}
		}
	}
	
	-- music wheel
	t[#t+1] = LoadActor("MusicWheel") .. { Name="MusicWheel" }
	
	-- ChartDisplay (the bar with possible charts)
	t[#t+1] = Def.ActorFrame {		
		Def.ActorFrame {
			InitCommand=function(self)
				self:xy(SCREEN_CENTER_X, 860)
				:easeoutexpo(1):y(chartsBalls_SelectingSongY):zoom(chartsBalls_SelectingSongZoom)
			end,
			OffCommand=function(self) self:stoptweening():easeoutexpo(1):y(chartsBalls_SelectingSongY):zoom(chartsBalls_SelectingSongZoom) end,
			SongChosenMessageCommand=function(self) self:stoptweening():easeoutexpo(1):y(chartsBalls_SelectingChartY):zoom(1) end,
			SongUnchosenMessageCommand=function(self) self:stoptweening():easeoutexpo(0.5):y(chartsBalls_SelectingSongY):zoom(chartsBalls_SelectingSongZoom) end,
			
			Def.ActorFrame {
				InitCommand=function(self) self:y(128) end,  

				Def.Sprite {
					Texture=THEME:GetPathG("", "DifficultyDisplay/Bar"),
					InitCommand=function(self) self:zoomy(1.1):y(156):diffusealpha(chartsBalls_SelectingSongDiffuseAlpha) end,
					SongChosenMessageCommand=function(self) self:stoptweening():easeoutexpo(1):diffusealpha(chartsBalls_SelectingChartDiffuseAlpha) end,
					SongUnchosenMessageCommand=function(self) self:stoptweening():easeoutexpo(0.5):diffusealpha(chartsBalls_SelectingSongDiffuseAlpha) end,
				},				

				LoadActor("BigPreviewBall")..{
					Condition = (LoadModule("Config.Load.lua")("ShowBigBall", "Save/OutFoxPrefs.ini") and GetScreenAspectRatio() >= 1.5)
				},
				
				LoadActor("ChartDisplay", 12),				
			}
		}
	}
	
	-- chart details elements that come from below when a chart is selected (ChartInfo, ScoreDisplay)
	t[#t+1] = Def.ActorFrame {    
		Def.ActorFrame {
			InitCommand=function(self)
				self:xy(SCREEN_CENTER_X, chartInfoScoreDisplay_Y+chartInfoScoreDisplay_Y)
			end,
			OffCommand=function(self)
				self:stoptweening():easeoutexpo(1):y(chartInfoScoreDisplay_Y+chartInfoScoreDisplay_Y)
			end,
			SongChosenMessageCommand=function(self)
				self:stoptweening():easeoutexpo(1):y(chartInfoScoreDisplay_Y)
			end,
			SongUnchosenMessageCommand=function(self)
				self:stoptweening():easeoutexpo(0.5):y(chartInfoScoreDisplay_Y+chartInfoScoreDisplay_Y)
			end,		
			
			-- chartInfo (selected chart's details)
			LoadActor("ChartInfo"),
			
			-- ScoreDisplay (selected chart's records)
			LoadActor("ScoreDisplay")
		}
	}
		
	-- for each player present, do logic related to ReadyUI
	for pn in ivalues(GAMESTATE:GetHumanPlayers()) do
		t[#t+1] = Def.ActorFrame {
			-- ready UI
			Def.ActorFrame {
				InitCommand=function(self)
					self:xy(SCREEN_CENTER_X + (pn == PLAYER_2 and 900 or -900), 381)
					:easeoutexpo(1):y(381):zoom(3.5)
				end,
				OffCommand=function(self)
					self:stoptweening():easeoutexpo(1)
					:y(381)
				end,

				StepsChosenMessageCommand=function(self, params)
					if params.Player == pn then
						self:stoptweening():easeoutexpo(0.25):x(SCREEN_CENTER_X + (pn == PLAYER_2 and 223 or -223))
					end
				end,
				CurrentChartChangedMessageCommand=function(self, params)
					if params.Player == pn then
						self:stoptweening():easeoutexpo(0.25):x(SCREEN_CENTER_X + (pn == PLAYER_2 and 900 or -900))
					end
				end,
				StepsUnchosenMessageCommand=function(self)
					self:stoptweening():easeoutexpo(0.25):x(SCREEN_CENTER_X + (pn == PLAYER_2 and 900 or -900))
				end,
				SongUnchosenMessageCommand=function(self)
					self:stoptweening():easeoutexpo(0.25):x(SCREEN_CENTER_X + (pn == PLAYER_2 and 900 or -900))
				end,

				--black quad			
				Def.Quad {
					InitCommand=function(self)
						self:zoomto(300, 240):diffuse(Color.Black):diffusealpha(0.9):y(-4):x(0 + (pn == PLAYER_2 and 86 or -86))
					end
				},
				
				--white quad
				Def.Quad {
					InitCommand=function(self)
						self:zoomto(128, 32):diffuse(Color.White):y(-10)

						if pn == PLAYER_2 then
							self:diffuserightedge(Color.Invisible)
						else
							self:diffuseleftedge(Color.Invisible)
						end
					end
				},

				-- press center step graphic
				LoadActor(THEME:GetPathG("", "PressCenterStep")) .. {				
					InitCommand=function(self)
						self:zoom(0.35):y(-14)
					end
				},
				
				-- READY graphic
				Def.Sprite {
					Texture=THEME:GetPathG("", "UI/Ready" .. ToEnumShortString(pn)),
					InitCommand=function(self) self:y(-9) end
				}
			}
		}
	end
end

return t