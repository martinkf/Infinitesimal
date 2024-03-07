local PanelW = 330

local SongIsChosen = false

local t = Def.ActorFrame {}

for pn in ivalues(GAMESTATE:GetHumanPlayers()) do
    -- This will help us position each element to each player's side
    local PlayerX = pn == PLAYER_2 and 339 or 0

    t[#t+1] = Def.ActorFrame {
        InitCommand=function(self) self:queuecommand("Refresh") end,
        
        SongChosenMessageCommand=function(self) SongIsChosen = true self:playcommand("Refresh") end,
        SongUnchosenMessageCommand=function(self) SongIsChosen = false end,
        CurrentChartChangedMessageCommand=function(self) if SongIsChosen then self:playcommand("Refresh") end end,

        RefreshCommand=function(self, params)
            if GAMESTATE:GetCurrentSong() and GAMESTATE:GetCurrentSteps(pn) then                
                local Chart = GAMESTATE:GetCurrentSteps(pn)
                local ChartAuthorText = Chart:GetAuthorCredit()
                local ChartDescriptionText = Chart:GetChartName()
				
				self:GetChild("ChartOrigin-label"):settext("ORIGIN")
				self:GetChild("ChartOrigin"):settext(ChartDescriptionText)
				self:GetChild("ChartName-label"):settext("DESCRIPTION")
				self:GetChild("ChartName"):settext(ChartDescriptionText)
				self:GetChild("ChartAuthor-label"):settext("STEP ARTIST")
				self:GetChild("ChartAuthor"):settext(ChartAuthorText)
            else                
				self:GetChild("ChartOrigin-label"):settext("")
				self:GetChild("ChartOrigin"):settext("")
				self:GetChild("ChartName-label"):settext("")
				self:GetChild("ChartName"):settext("")
				self:GetChild("ChartAuthor-label"):settext("")
				self:GetChild("ChartAuthor"):settext("")
            end
        end,
		
		Def.Quad {
            InitCommand=function(self)
                self:zoomto(3, 258):diffuse(Color.Black):diffusealpha(0.7):y(120):x(0)
            end
        },
		
		Def.BitmapText {
            Font="Montserrat normal 20px",
            Name="ChartOrigin-label",
            InitCommand=function(self)
                self:x(10 * (pn == PLAYER_2 and 1 or -1)):y(6):zoom(0.7)
				:halign(pn == PLAYER_2 and 0 or 1):maxwidth(PanelW / self:GetZoom())
                :shadowlength(2)
                :skewx(-0.2)
            end
        },
		Def.BitmapText {
            Font="Montserrat semibold 20px",
            Name="ChartOrigin",
            InitCommand=function(self)
                self:x(30 * (pn == PLAYER_2 and 1 or -1)):y(6+22):zoom(1.4)
				:halign(pn == PLAYER_2 and 0 or 1):maxwidth(PanelW / self:GetZoom())
                :shadowlength(2)
            end
        },
		
		Def.BitmapText {
            Font="Montserrat normal 20px",
            Name="ChartName-label",
            InitCommand=function(self)
                self:x(10 * (pn == PLAYER_2 and 1 or -1)):y(88):zoom(0.7)
				:halign(pn == PLAYER_2 and 0 or 1):maxwidth(PanelW / self:GetZoom())
                :shadowlength(2)
                :skewx(-0.2)
            end
        },
		Def.BitmapText {
            Font="Montserrat semibold 20px",
            Name="ChartName",
            InitCommand=function(self)
                self:x(30 * (pn == PLAYER_2 and 1 or -1)):y(88+22):zoom(1.4)
				:halign(pn == PLAYER_2 and 0 or 1):maxwidth(PanelW / self:GetZoom())
                :shadowlength(2)
            end
        },
		
		Def.BitmapText {
            Font="Montserrat normal 20px",
            Name="ChartAuthor-label",
            InitCommand=function(self)
                self:x(10 * (pn == PLAYER_2 and 1 or -1)):y(170):zoom(0.7)
				:halign(pn == PLAYER_2 and 0 or 1):maxwidth(PanelW / self:GetZoom())
                :shadowlength(2)
                :skewx(-0.2)
            end
        },
		Def.BitmapText {
            Font="Montserrat semibold 20px",
            Name="ChartAuthor",
            InitCommand=function(self)
                self:x(30 * (pn == PLAYER_2 and 1 or -1)):y(170+22):zoom(1.4)
				:halign(pn == PLAYER_2 and 0 or 1):maxwidth(PanelW / self:GetZoom())
                :shadowlength(2)
            end
        }
    }
end

return t
