setenv("IsBasicMode", false)
local t = Def.ActorFrame {}

--[[
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
]]--

t[#t+1] = Def.ActorFrame {
    Def.ActorFrame {
        InitCommand=function(self)
            self:xy(SCREEN_CENTER_X, -SCREEN_CENTER_Y)
            :easeoutexpo(1):y(SCREEN_CENTER_Y)
        end,
        OffCommand=function(self)
            self:stoptweening():easeoutexpo(1):y(-SCREEN_CENTER_Y)
        end,
		
        LoadActor("SongPreview") .. {
            InitCommand=function(self) self:y(-100) end
        }
	}
}
		
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
                self:xy(pn == PLAYER_2 and SCREEN_RIGHT + 40 * 2 or -40 * 2, 138)
                :easeoutexpo(1):x(pn == PLAYER_2 and SCREEN_RIGHT - 40 or 40)
            end,
            OffCommand=function(self)
                self:stoptweening():easeoutexpo(1):x(pn == PLAYER_2 and SCREEN_RIGHT + 40 * 2 or -40 * 2)
            end
        },

		-- READY graphic when step is selected and ready to play
        Def.ActorFrame {
            InitCommand=function(self)
                self:xy(SCREEN_CENTER_X + (pn == PLAYER_2 and 185 or -185), 881)
                :easeoutexpo(1):y(881):zoom(2)
            end,
            OffCommand=function(self)
                self:stoptweening():easeoutexpo(1)
                :y(881)
            end,

            StepsChosenMessageCommand=function(self, params)
                if params.Player == pn then
                    self:stoptweening():easeoutexpo(0.25):y(565)
                end
            end,
            CurrentChartChangedMessageCommand=function(self, params)
                if params.Player == pn then
                    self:stoptweening():easeoutexpo(0.25):y(881)
                end
            end,
            StepsUnchosenMessageCommand=function(self)
                self:stoptweening():easeoutexpo(0.25):y(881)
            end,
            SongUnchosenMessageCommand=function(self)
                self:stoptweening():easeoutexpo(0.25):y(881)
            end,

			LoadActor(THEME:GetPathG("", "PressCenterStep")) .. {				
				InitCommand=function(self)
					self:zoom(0.35):y(-3)
				end
			},
			
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
    --ChartInfo
	Def.ActorFrame {
        InitCommand=function(self)
            self:xy(SCREEN_CENTER_X, -SCREEN_CENTER_Y+419)
            :easeoutexpo(1):y(SCREEN_CENTER_Y+419)
        end,
        OffCommand=function(self)
            self:stoptweening():easeoutexpo(1):y(-SCREEN_CENTER_Y)
        end,
        SongChosenMessageCommand=function(self)
            self:stoptweening():easeoutexpo(1):y(SCREEN_CENTER_Y + 103)
        end,
        SongUnchosenMessageCommand=function(self)
            self:stoptweening():easeoutexpo(0.5):y(SCREEN_CENTER_Y+419)
        end,

		--bg graphics
		--[[
        Def.Sprite {
            Texture=THEME:GetPathG("", "DifficultyDisplay/InfoPanel"),
            InitCommand=function(self) self:y(85):zoom(0.75) end
        },
		]]--
		
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
		-- stopping the BGA_P zooming shenanigans when a song is selected
		--[[
        SongChosenMessageCommand=function(self)
            self:stoptweening():easeoutexpo(0.5):y(SCREEN_CENTER_Y-40):zoom(0.9)
        end,
        SongUnchosenMessageCommand=function(self)
            self:stoptweening():easeoutexpo(0.5):y(SCREEN_CENTER_Y):zoom(1)
        end,
		]]--       
		
		LoadActor("ScoreDisplay") .. {
            InitCommand=function(self) self:y(500) end
        },
        
		-- disabling padIcons
		--[[
        LoadActor("PadIcons") .. {
            InitCommand=function(self) self:y(24) end
        },
		]]--		
        
        Def.ActorFrame {
            InitCommand=function(self) self:y(128) end,

            SongChosenMessageCommand=function(self)
                self:stoptweening():easeoutexpo(1):y(-102)
            end,
            SongUnchosenMessageCommand=function(self)
                self:stoptweening():easeoutexpo(0.5):y(128)
            end,            

            Def.Sprite {
                Texture=THEME:GetPathG("", "DifficultyDisplay/Bar"),
                InitCommand=function(self) self:zoom(1.2):y(156) end
            },

            LoadActor("ChartDisplay", 12),
			
			LoadActor("BigPreviewBall")..{
              Condition = (LoadModule("Config.Load.lua")("ShowBigBall", "Save/OutFoxPrefs.ini") and GetScreenAspectRatio() >= 1.5)
            }
        }
    }
}

t[#t+1] = LoadActor("MusicWheel-43") .. { Name="MusicWheel" }

return t
