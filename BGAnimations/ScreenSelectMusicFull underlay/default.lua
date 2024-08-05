setenv("IsBasicMode", false)
-- ChartDisplay (the bar with possible charts)
local chartsBalls_SelectingSongY = 242
local chartsBalls_SelectingSongZoom = 1.5
local chartsBalls_SelectingChartY = 144
local chartsBalls_SelectingSongDiffuseAlpha = 0.1
local chartsBalls_SelectingChartDiffuseAlpha = 0.8
-- elements that come from below when a chart is selected
local chartInfoScoreDisplay_Y = 463

-- drawing
local t = Def.ActorFrame {}

-- main elements
t[#t+1] = Def.ActorFrame {
	-- song preview
	Def.ActorFrame {
		LoadActor("SongPreview")
	},
	-- music wheel
	Def.ActorFrame {			
		LoadActor("MusicWheel") .. { Name="MusicWheel" }
	},
	-- song info
	Def.ActorFrame {			
		LoadActor("SongInfo")
	},
	-- ChartDisplay (the bar with possible charts)
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
				InitCommand=function(self) self:zoomy(1.05):y(156):diffusealpha(chartsBalls_SelectingSongDiffuseAlpha) end,
				SongChosenMessageCommand=function(self) self:stoptweening():easeoutexpo(1):diffusealpha(chartsBalls_SelectingChartDiffuseAlpha) end,
				SongUnchosenMessageCommand=function(self) self:stoptweening():easeoutexpo(0.5):diffusealpha(chartsBalls_SelectingSongDiffuseAlpha) end,
			},				

			LoadActor("BigPreviewBall")..{
				Condition = (LoadModule("Config.Load.lua")("ShowBigBall", "Save/OutFoxPrefs.ini") and GetScreenAspectRatio() >= 1.5)
			},
			
			LoadActor("ChartDisplay", 12),				
		}
	},
}

-- elements that come from below when a chart is selected
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
				self:zoom(0.3):y(46):x(0 + (pn == PLAYER_2 and 24 or -24))
			end
		},
		
		-- READY graphic
		Def.Sprite {
			Texture=THEME:GetPathG("", "UI/Ready" .. ToEnumShortString(pn)),
			InitCommand=function(self) self:y(-9) end
		}
	}
end


return t