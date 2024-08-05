local FrameW = 640
local FrameH = 360

local DisplayNotefield = false

local FrameW2 = 1600
local FrameH2 = 900
local PreviewDelay = THEME:GetMetric("ScreenSelectMusic", "SampleMusicDelay")
--PreviewDelay = 0.11
local VHSText_Y = -100
local SmallerBGAPreview_SelectingSongY = 364
local SmallerBGAPreview_SelectingChartY = 0 -- this must match EntireWheel_SelectingChartY from MusicWheel.lua


local t = Def.ActorFrame {
	OnCommand=function(self)
		self:xy(SCREEN_CENTER_X, SCREEN_CENTER_Y-100):zoom(0.8)		
	end,
	
	-- noise fx when switching song
	Def.ActorFrame {
		Name="Noise",

		Def.Sprite {
			Texture=THEME:GetPathG("", "Noise"),
			InitCommand=function(self)
				self:zoomto(FrameW2, FrameH2):y(125)
				:texcoordvelocity(24,16)
			end
		},

		Def.BitmapText {
			Name="NextPrevText",
			Font="VCR OSD Mono 40px",
			Text="",
			InitCommand=function(self)
				self:zoom(2):xy(0,VHSText_Y)
				:shadowlength(4)					
			end,
			ScrollMessageCommand=function(self, params)
				local direction = params.Direction
				if direction == -1 then
					self:stoptweening()
					:settext("PREV")
					:zoom(2.3)
					:easeoutquad(0.2)
					:zoom(2)
				elseif direction == 1 then
					self:stoptweening()
					:settext("NEXT")
					:zoom(2.3)
					:easeoutquad(0.2)
					:zoom(2)
				end					
			end,
		},
	},

	-- fullscreen bga_P
	Def.Sprite {
		InitCommand=function(self) self:Load(nil):queuecommand("Refresh") end,
		CurrentSongChangedMessageCommand=function(self) self:Load(nil):queuecommand("Refresh") end,

		RefreshCommand=function(self)
			self:stoptweening():diffusealpha(0):sleep(PreviewDelay)
			Song = GAMESTATE:GetCurrentSong()
			if Song then
				if GAMESTATE:GetCurrentSong():GetPreviewVidPath() == nil or LoadModule("Config.Load.lua")("ImagePreviewOnly", "Save/OutFoxPrefs.ini") then
					self:queuecommand("LoadBG")
				else
					self:queuecommand("LoadAnimated")
				end
			end
		end,

		LoadBGCommand=function(self)
			local Path = Song:GetBackgroundPath()
			if Path and FILEMAN:DoesFileExist(Path) then
				self:LoadFromCached("Background", Path):zoomto(FrameW2, FrameH2):y(125)
				:linear(PreviewDelay):diffusealpha(1):diffuse(color("#ffffff"))
			else
				self:LoadFromCached("Banner", Song:GetBannerPath()):zoomto(FrameW2, FrameH2):y(125)
				:linear(PreviewDelay):diffusealpha(1):diffuse(color("#ffffff"))
			end
		end,

		LoadAnimatedCommand=function(self)
			local Path = Song:GetPreviewVidPath()
			if Path and FILEMAN:DoesFileExist(Path) then
				self:Load(Path):zoomto(FrameW2, FrameH2):y(125)
				:linear(PreviewDelay):diffusealpha(1):diffuse(color("#ffffff"))
			else
				self:queuecommand("LoadBG")
			end
		end,
		
		SongChosenMessageCommand=function(self)				
			self:stoptweening():easeoutexpo(1):diffuse(color("#333333"))
		end,
		
		SongUnchosenMessageCommand=function(self)				
			self:stoptweening():easeoutexpo(0.5):diffuse(color("#ffffff"))
		end
	},
	
	-- smaller scale bga_P
	Def.Sprite {
		InitCommand=function(self) self:Load(nil):queuecommand("Refresh") end,
		CurrentSongChangedMessageCommand=function(self) self:Load(nil):queuecommand("Refresh") end,

		RefreshCommand=function(self)
			self:stoptweening():diffusealpha(0):sleep(PreviewDelay)
			Song = GAMESTATE:GetCurrentSong()
			if Song then
				if GAMESTATE:GetCurrentSong():GetPreviewVidPath() == nil or LoadModule("Config.Load.lua")("ImagePreviewOnly", "Save/OutFoxPrefs.ini") then
					self:queuecommand("LoadBG")
				else
					self:queuecommand("LoadAnimated")
				end
			end
		end,

		LoadBGCommand=function(self)
			local Path = Song:GetBackgroundPath()
			if Path and FILEMAN:DoesFileExist(Path) then
				self:LoadFromCached("Background", Path):zoomto(FrameW2/8, FrameH2/6.1):y(SmallerBGAPreview_SelectingSongY):diffusealpha(0)
				:linear(PreviewDelay):diffusealpha(0)
			else
				self:LoadFromCached("Banner", Song:GetBannerPath()):zoomto(FrameW2/8, FrameH2/6.1):y(SmallerBGAPreview_SelectingSongY):diffusealpha(0)
				:linear(PreviewDelay):diffusealpha(0)
			end
		end,

		LoadAnimatedCommand=function(self)
			local Path = Song:GetPreviewVidPath()
			if Path and FILEMAN:DoesFileExist(Path) then
				self:Load(Path):zoomto(FrameW2/8, FrameH2/6.1):y(SmallerBGAPreview_SelectingSongY):diffusealpha(0)
				:linear(PreviewDelay):diffusealpha(0)
			else
				self:queuecommand("LoadBG")
			end
		end,
		
		SongChosenMessageCommand=function(self)				
			self:stoptweening():easeoutexpo(1):zoomto(FrameW2/3, FrameH2/3):y(SmallerBGAPreview_SelectingChartY):diffusealpha(1)
		end,
		SongUnchosenMessageCommand=function(self)				
			self:stoptweening():easeoutexpo(0.5):zoomto(FrameW2/8, FrameH2/6.1):y(SmallerBGAPreview_SelectingSongY):diffusealpha(0)
		end
	}
}


return t