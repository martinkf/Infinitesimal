t = Def.ActorFrame {}

local isSelectingDifficulty = false

for pn in ivalues(GAMESTATE:GetHumanPlayers()) do

    -- Larger stationary difficulty icons
    t[#t+1] = Def.ActorFrame {
        Name="BigPreviewBallContainer",

    CurrentStepsP1ChangedMessageCommand=function(self) self:playcommand("Refresh") end,
    CurrentStepsP2ChangedMessageCommand=function(self) self:playcommand("Refresh") end,
    SongChosenMessageCommand=function(self) isSelectingDifficulty = true self:playcommand("Refresh") end,
    SongUnchosenMessageCommand=function(self) isSelectingDifficulty = false self:playcommand("Refresh") end,

    RefreshCommand=function(self)
      if isSelectingDifficulty then
        local Chart = GAMESTATE:GetCurrentSteps(pn)
        local ChartMeter = Chart:GetMeter()
        if ChartMeter == 99 then ChartMeter = "??" end
        self:GetChild("BigPreviewBallContainer_"..pn):GetChild("BigPreviewBall"):diffuse(ChartTypeToColor(Chart))
        self:GetChild("BigPreviewBallContainer_"..pn):GetChild("MeterText"):settext(ChartMeter)
        self:GetChild("BigPreviewBallContainer_"..pn):GetChild("Difficulty"):settext(FullModeChartLabel(Chart))
      end
    end,

    Def.ActorFrame {
      Name="BigPreviewBallContainer_"..pn,

      InitCommand=function(self)
        self:zoom(2)
        :xy(pn == PLAYER_1 and -350 or 350, 135)
      end,

      OnCommand=function(self)
        self:diffusealpha(0)
      end,

      SongChosenMessageCommand=function(self)
        self:stoptweening()
        :easeoutexpo(0.5)
        :diffusealpha(1)
        :x(pn == PLAYER_1 and -375 or 375)
      end,

      SongUnchosenMessageCommand=function(self)
        self:stoptweening()
        :easeoutexpo(0.25)
        :diffusealpha(0)
        :x(pn == PLAYER_1 and -350 or 350)
      end,

        Def.Sprite {
            Texture=THEME:GetPathG("", "DifficultyDisplay/Ball"),
            Name="BigPreviewBall"
        },

      Def.Sprite {
        Texture=THEME:GetPathG("", "DifficultyDisplay/Trim"),
        Name="PreviewBallTrim"
      },

      Def.BitmapText {
        Font="Montserrat extrabold 20px",
        Name="Difficulty",
        InitCommand=function(self)
          self:y(-13):visible(true):zoom(0.4):maxwidth(80):shadowlength(2):skewx(-0.1)
        end
      },

      Def.BitmapText {
        Font="Montserrat numbers 40px",
        Name="MeterText",
        InitCommand=function(self)
          self:y(3):zoom(0.6)
        end
      }
    }
    }

end

----
-- vvvv POI PROJECT vvvv
----

local usingPOIUX = LoadModule("Config.Load.lua")("ActivatePOIProjectUX", "Save/OutFoxPrefs.ini") or false
if usingPOIUX then
	-- levers	
	BigBallGroup_X = 120
	BigBallGroup_Y = 220+90
	MeterText_OffsetX = -1
	MeterText_OffsetY = -4
	MeterText_Zoom = 0.6
	
	t = Def.ActorFrame {}
	
	for pn in ivalues(GAMESTATE:GetHumanPlayers()) do
		-- Larger stationary difficulty icons
		t[#t+1] = Def.ActorFrame {
			Name="BigPreviewBallContainer",

		CurrentStepsP1ChangedMessageCommand=function(self) self:playcommand("Refresh") end,
		CurrentStepsP2ChangedMessageCommand=function(self) self:playcommand("Refresh") end,
		SongChosenMessageCommand=function(self) isSelectingDifficulty = true self:playcommand("Refresh") end,
		SongUnchosenMessageCommand=function(self) isSelectingDifficulty = false self:playcommand("Refresh") end,

		RefreshCommand=function(self)
			if isSelectingDifficulty then
				local Chart = GAMESTATE:GetCurrentSteps(pn)
				local ChartMeter = Chart:GetMeter()
				if ChartMeter == 99 then
					ChartMeter = "??"
				else
					ChartMeter = string.format("%02d", ChartMeter)
				end
				self:GetChild("BigPreviewBallContainer_"..pn):GetChild("BigPreviewBall"):diffuse(ColorFromChartStepstype_POI(Chart))
				self:GetChild("BigPreviewBallContainer_"..pn):GetChild("MeterText"):settext(ChartMeter)
				self:GetChild("BigPreviewBallContainer_"..pn):GetChild("Difficulty"):settext(FullModeChartLabel(Chart))
			end
		end,

		Def.ActorFrame {
			Name="BigPreviewBallContainer_"..pn,
			InitCommand=function(self)
				self:zoom(4):xy(pn == PLAYER_1 and -(BigBallGroup_X) or BigBallGroup_X, BigBallGroup_Y)
			end,
			
			Def.Sprite {
				Texture=THEME:GetPathG("", "DifficultyDisplay/Ball"),
				Name="BigPreviewBall"
			},
			
			Def.Sprite {
				Texture=THEME:GetPathG("", "DifficultyDisplay/Trim"),
				Name="PreviewBallTrim"
			},
			
			Def.BitmapText {
				Font="Montserrat extrabold 20px",
				Name="Difficulty",
				InitCommand=function(self)
					self:y(-13):visible(false):zoom(0.4):maxwidth(80):shadowlength(2):skewx(-0.1)
				end
			},
			
			Def.BitmapText {
				Font="Montserrat numbers 40px",
				Name="MeterText",
				InitCommand=function(self)
					self:xy(MeterText_OffsetX, MeterText_OffsetY):zoom(MeterText_Zoom)
				end
			}
		}
	}
	end
end

return t
