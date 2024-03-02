local FrameW = 640
local FrameH = 360
local FrameW2 = 1600
local FrameH2 = 900

local PreviewDelay = THEME:GetMetric("ScreenSelectMusic", "SampleMusicDelay")
local DisplayNotefield = false

-- Video/background display
local t = Def.ActorFrame {
    OnCommand=function(self)
        self:zoom(1.8):addy(100):addx(40)
		-- only reason addx is here is to remind you that BGA P is currently overing the optionslist icons
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
                self:zoomto(FrameW2, FrameH2):y(125):x(60) -- reminder that its blocking the optionslist icons
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
                self:LoadFromCached("Background", Path):zoomto(FrameW2, FrameH2):y(125):x(60) -- reminder that its blocking the optionslist icons
                :linear(PreviewDelay):diffusealpha(1)
            else
                self:LoadFromCached("Banner", Song:GetBannerPath()):zoomto(FrameW2, FrameH2):y(125):x(60) -- reminder that its blocking the optionslist icons
                :linear(PreviewDelay):diffusealpha(1)
            end
        end,

        LoadAnimatedCommand=function(self)
            local Path = Song:GetPreviewVidPath()
            if Path and FILEMAN:DoesFileExist(Path) then
                self:Load(Path):zoomto(FrameW2, FrameH2):y(125):x(60) -- reminder that its blocking the optionslist icons
                :linear(PreviewDelay):diffusealpha(1)
            else
                self:queuecommand("LoadBG")
            end
        end
    }
}

-- Chart preview WIP, use at your own risk!
if LoadModule("Config.Load.lua")("ChartPreview", "Save/OutFoxPrefs.ini") then
    t[#t+1] = Def.ActorFrame {
        InitCommand=function(self)
            self:y(0):zoom(0.75)
        end,
        OnCommand=function(self)
            if GAMESTATE:GetCurrentSong() then
                self:AddChildFromPath(THEME:GetPathB("", "NotefieldPreview"))
            end
        end,
        --[[
        Def.Quad {
            InitCommand=function(self)
                self:zoomto(854, 480):diffuse(Color.Black):diffusealpha(0.5):visible(false)
            end,
            SongChosenMessageCommand=function(self) self:visible(true) end,
            SongUnchosenMessageCommand=function(self) self:visible(false) end,
        } ]]
    }
end

-- Portion dedicated to song stats
t[#t+1] = Def.ActorFrame {
    InitCommand=function(self) self:playcommand("Refresh") end,
    CurrentSongChangedMessageCommand=function(self) self:playcommand("Refresh") end,

    RefreshCommand=function(self)
        if GAMESTATE:GetCurrentSong() then
            local Song = GAMESTATE:GetCurrentSong()
            local StepList = Song:GetAllSteps()
            local FirstStep = StepList[1]
            local Duration = FirstStep:GetChartLength()

            local TitleText = Song:GetDisplayFullTitle()
            if TitleText == "" then TitleText = "Unknown" end

            local AuthorText = Song:GetDisplayArtist()
            if AuthorText == "" then AuthorText = "Unknown" end

            local BPMRaw = Song:GetDisplayBpms()
            local BPMLow = math.ceil(BPMRaw[1])
            local BPMHigh = math.ceil(BPMRaw[2])
            local BPMDisplay = (BPMLow == BPMHigh and BPMHigh or BPMLow .. "-" .. BPMHigh)

            if Song:IsDisplayBpmRandom() or BPMDisplay == 0 then BPMDisplay = "???" end

            self:GetChild("Title"):settext(TitleText)
            self:GetChild("Artist"):settext(AuthorText)
            self:GetChild("BPM"):settext(BPMDisplay .. " BPM")

            if GAMESTATE:IsEventMode() then
                self:GetChild("Length"):visible(true):settext(SecondsToMMSS(Duration))
                self:GetChild("HeartsIcon"):visible(false)
                self:GetChild("Hearts"):visible(false)
            else
                self:GetChild("Length"):visible(false)
                self:GetChild("HeartsIcon"):visible(true)
                self:GetChild("Hearts"):visible(true):settext("x " .. Song:GetStageCost() * GAMESTATE:GetNumPlayersEnabled())
            end
        else
            self:GetChild("Title"):settext("")
            self:GetChild("Artist"):settext("")
            self:GetChild("Length"):settext("")
            self:GetChild("BPM"):settext("")
        end
    end,

    Def.Quad {
        InitCommand=function(self)
            self:zoomto(FrameW, 32):y(-FrameH / 2):valign(0)
            :diffuse(Color.Black):diffusealpha(0.5)
        end
    },

    Def.BitmapText {
        Font="Montserrat semibold 40px",
        Name="Title",
        InitCommand=function(self)
            self:zoom(0.7):halign(0):valign(0)
            :maxwidth(FrameW * 0.8 / self:GetZoom())
            :x(-FrameW / 2 + 6)
            :y(-FrameH / 2 + 6)
        end
    },

    Def.BitmapText {
        Font="Montserrat semibold 40px",
        Name="Length",
        InitCommand=function(self)
            self:zoom(0.7):halign(1):valign(0)
            :maxwidth(FrameW * 0.2 / self:GetZoom())
            :x(FrameW / 2 - 6)
            :y(-FrameH / 2 + 6)
        end
    },

    Def.Sprite {
        Texture=THEME:GetPathG("", "UI/Heart"),
        Name="HeartsIcon",
        InitCommand=function(self)
            self:zoom(0.35):halign(1):valign(0)
            :x(FrameW / 2 - 54)
            :y(-FrameH / 2 + 5)
        end,
    },

    Def.BitmapText {
        Font="Montserrat semibold 40px",
        Name="Hearts",
        InitCommand=function(self)
            self:zoom(0.7):halign(0):valign(0)
            :x(FrameW / 2 - 48)
            :y(-FrameH / 2 + 6)

            local Hearts = GAMESTATE:GetNumStagesLeft(PLAYER_1) + GAMESTATE:GetNumStagesLeft(PLAYER_2)
            self:settext("x " .. (GAMESTATE:IsEventMode() and "∞" or Hearts))
        end
    },

    Def.Quad {
        InitCommand=function(self)
            self:zoomto(FrameW, 32):y(FrameH / 2):valign(1)
            :diffuse(Color.Black):diffusealpha(0.5)
        end
    },

    Def.BitmapText {
        Font="Montserrat semibold 40px",
        Name="Artist",
        InitCommand=function(self)
            self:zoom(0.7):halign(0):valign(1)
            :maxwidth(FrameW * 0.7 / self:GetZoom())
            :x(-FrameW / 2 + 6)
            :y(FrameH / 2 - 6)
        end
    },

    Def.BitmapText {
        Font="Montserrat semibold 40px",
        Name="BPM",
        InitCommand=function(self)
            self:zoom(0.7):halign(1):valign(1)
            :maxwidth(FrameW * 0.3 / self:GetZoom())
            :x(FrameW / 2 - 6)
            :y(FrameH / 2 - 6)
        end
    }
}

return t
