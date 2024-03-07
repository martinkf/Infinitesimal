local FrameW = 640
local FrameH = 360
local FrameW2 = 1600
local FrameH2 = 900

local PreviewDelay = THEME:GetMetric("ScreenSelectMusic", "SampleMusicDelay")
local DisplayNotefield = false

-- Video/background display
local t = Def.ActorFrame {
    OnCommand=function(self)
        self:zoom(1.8):addy(100)
    end,	
}

local t = Def.ActorFrame {
    OnCommand=function(self)
        self:zoom(0.8)		
    end,

	-- disabling this silver border
	--[[
    Def.Sprite {
        Texture=((_G["Secret"] == true) and THEME:GetPathG("", "MusicWheel/SecretPreviewFrame") or THEME:GetPathG("", "MusicWheel/PreviewFrame"))
    },
	]]--

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
                self:zoom(2):y(-40)
                :shadowlength(4)
                --:shadowcolor(0,0,0)
            end,
            NextSongMessageCommand=function(self)
                self:stoptweening()
                :settext("NEXT")
                :zoom(2.1)
                :easeoutquad(0.2)
                :zoom(2)
            end,
            PreviousSongMessageCommand=function(self)
                self:stoptweening()
                :settext("PREV")
                :zoom(2.1)
                :easeoutquad(0.2)
                :zoom(2)
            end,
        },

        Def.BitmapText {
            Name="Arrows",
            Font="VCR OSD Mono 40px",
            Text=" ",
            InitCommand=function(self)
                arr_width = self:GetWidth()
                self:zoom(2):y(40)
                :shadowlength(4)
                --:shadowcolor(0,0,0)
            end,
            NextSongMessageCommand=function(self)
                self:stoptweening():queuecommand("LoopForward")
            end,
            PreviousSongMessageCommand=function(self)
                self:stoptweening():queuecommand("LoopBackward")
             end,
            LoopForwardCommand=function(self)
                self:settext(">")
                :x(arr_width * -1.5):sleep(0.1)
                :x(0):sleep(0.1)
                :x(arr_width * 1.5):sleep(0.1)
                :queuecommand("LoopForward")
            end,
            LoopBackwardCommand=function(self)
                self:settext("<")
                :x(arr_width * 1.5):sleep(0.1)
                :x(0):sleep(0.1)
                :x(arr_width * -1.5):sleep(0.1)
                :queuecommand("LoopBackward")
            end,
        }
    },

	-- bga_P
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
	
	-- bga_P again
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
                self:LoadFromCached("Background", Path):zoomto(FrameW2/8, FrameH2/6.1):y(332):diffusealpha(0)
                :linear(PreviewDelay):diffusealpha(1)
            else
                self:LoadFromCached("Banner", Song:GetBannerPath()):zoomto(FrameW2/8, FrameH2/6.1):y(332):diffusealpha(0)
                :linear(PreviewDelay):diffusealpha(1)
            end
        end,

        LoadAnimatedCommand=function(self)
            local Path = Song:GetPreviewVidPath()
            if Path and FILEMAN:DoesFileExist(Path) then
                self:Load(Path):zoomto(FrameW2/8, FrameH2/6.1):y(332):diffusealpha(0)
                :linear(PreviewDelay):diffusealpha(1)
            else
                self:queuecommand("LoadBG")
            end
        end,
		
		SongChosenMessageCommand=function(self)				
			self:stoptweening():easeoutexpo(1):zoomto(FrameW2/3, FrameH2/3):y(-18):diffusealpha(1)
		end,
		SongUnchosenMessageCommand=function(self)				
			self:stoptweening():easeoutexpo(0.5):zoomto(FrameW2/8, FrameH2/6.1):y(332):diffusealpha(0)
		end
    }
}

-- Chart preview WIP, use at your own risk!
if LoadModule("Config.Load.lua")("ChartPreview", "Save/OutFoxPrefs.ini") then
    t[#t+1] = Def.ActorFrame {
        InitCommand=function(self)
            self:y(702):zoom(0.75)
        end,
        OnCommand=function(self)
            if GAMESTATE:GetCurrentSong() then
                self:AddChildFromPath(THEME:GetPathB("", "NotefieldPreview"))
            end
        end,
		
		SongChosenMessageCommand=function(self)
			self:stoptweening():easeoutexpo(1):y(386)
		end,
        SongUnchosenMessageCommand=function(self)
			self:stoptweening():easeoutexpo(0.5):y(702)
		end,
        
        Def.Quad {
            InitCommand=function(self)
                self:zoomto(520, 448):diffuse(Color.Black):diffusealpha(0.5):y(16)
            end,            
        }
    }
end

-- Portion dedicated to song stats
t[#t+1] = Def.ActorFrame {
    InitCommand=function(self) end,
    CurrentSongChangedMessageCommand=function(self) self:playcommand("Refresh") end,

	LoadActor("../ScreenEvaluation underlay/EvalSongInfo") .. {
        InitCommand=function(self)
			self:xy(0, -202+388)
		end,
		CurrentSongChangedMessageCommand=function(self)
			self:stoptweening():diffusealpha(0):sleep(0.25):easeoutexpo(1):diffusealpha(1)
		end,
		SongChosenMessageCommand=function(self)            
			self:stoptweening():diffusealpha(1):easeoutexpo(1):y(-220)
        end,
		SongUnchosenMessageCommand=function(self)            
			self:stoptweening():diffusealpha(1):easeoutexpo(0.5):y(-202+388)
        end
    }
}

return t
