local SongInfo_SelectingSongY = 543
local SongInfo_SelectingChartY = 246
local SongInfo_SongChangedDelay = 0.5

local t = Def.ActorFrame {
	InitCommand=function(self)
		self:zoom(0.8)
	end,
	CurrentSongChangedMessageCommand=function(self) self:playcommand("Refresh") end,

	LoadActor("../ScreenEvaluation underlay/EvalSongInfo") .. {
		InitCommand=function(self)
			self:xy(SCREEN_CENTER_X+158, SongInfo_SelectingSongY)
		end,
		CurrentSongChangedMessageCommand=function(self)
			self:stoptweening():diffusealpha(0):sleep(SongInfo_SongChangedDelay):easeoutexpo(1):diffusealpha(1)
		end,
		SongChosenMessageCommand=function(self)            
			self:stoptweening():diffusealpha(1):easeoutexpo(1):y(SongInfo_SelectingChartY)
		end,
		SongUnchosenMessageCommand=function(self)            
			self:stoptweening():diffusealpha(1):easeoutexpo(0.5):y(SongInfo_SelectingSongY)
		end
	}
}

return t