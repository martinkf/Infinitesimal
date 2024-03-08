
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
                self:xy(pn == PLAYER_2 and SCREEN_RIGHT + 40 * 2 or -40 * 2, modIconsYvalue)
                :easeoutexpo(1):x(pn == PLAYER_2 and SCREEN_RIGHT - 40 or 40)
            end,
            OffCommand=function(self)
                self:stoptweening():easeoutexpo(1):x(pn == PLAYER_2 and SCREEN_RIGHT + 40 * 2 or -40 * 2)
            end
        },

		-- READY graphic when step is selected and ready to play
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
			
			
			
			LoadActor(THEME:GetPathG("", "PressCenterStep")) .. {				
				InitCommand=function(self)
					self:zoom(0.35):y(-14)
				end
			},
			
			Def.Sprite {
                Texture=THEME:GetPathG("", "UI/Ready" .. ToEnumShortString(pn)),
                InitCommand=function(self) self:y(-9) end
            }
        }
  }
end

return t
