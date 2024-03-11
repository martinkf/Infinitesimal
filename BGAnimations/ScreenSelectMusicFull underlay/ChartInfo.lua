local PanelW = 330
local PanelH = 120

local StatsX = 55
local StatsXSpacing = 25
local StatsY = 46

local SongIsChosen = false
local PreviewDelay = THEME:GetMetric("ScreenSelectMusic", "SampleMusicDelay")

-- Breakdown from Soundwaves (JoseVarelaP, Jousway, Lirodon)
local GetStreamBreakdown = function(Player)
    if GAMESTATE:GetCurrentSong() and GAMESTATE:GetCurrentSteps(Player) then
        local streams = LoadModule("Chart.GetStreamMeasure.lua")(NMeasure, 2, mcount)
        if not streams then return "" end

        local streamLengths = {}

        for i, stream in ipairs(streams) do
            local streamCount = tostring(stream.streamEnd - stream.streamStart)
            if not stream.isBreak then
                streamLengths[#streamLengths + 1] = streamCount
            end
        end

        return table.concat(streamLengths, "/")
    end
    return ""
end

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
                local Song = GAMESTATE:GetCurrentSong()
                local Chart = GAMESTATE:GetCurrentSteps(pn)
                local ChartRadar = Chart:GetRadarValues(pn)

                local ChartAuthorText = Chart:GetAuthorCredit()
                if ChartAuthorText == "" then ChartAuthorText = "Unknown" end

                local ChartTypeText = ToEnumShortString(ToEnumShortString(Chart:GetStepsType())) .. " " .. Chart:GetMeter()

                local ChartDescriptionText = Chart:GetChartName()
                -- if ChartDescriptionText == "" then ChartDescriptionText = ToUpper(Chart:GetDescription()) end

                local ChartInfoText = ChartTypeText .. " " .. THEME:GetString("ChartInfo", "By") .. " " .. ChartAuthorText
                if ChartDescriptionText ~= "" then
                    ChartInfoText = ChartInfoText .. "\n" .. ChartDescriptionText
                end
                ChartInfoText = ToUpper(ChartInfoText)

                self:GetChild("ChartInfo"):settext(ChartInfoText)
                self:GetChild("Steps"):settext(THEME:GetString("PaneDisplay", "Steps") .. "\n" .. ChartRadar:GetValue('RadarCategory_TapsAndHolds'))
                self:GetChild("Jumps"):settext(THEME:GetString("PaneDisplay", "Jumps") .. "\n" .. ChartRadar:GetValue('RadarCategory_Jumps'))
                self:GetChild("Holds"):settext(THEME:GetString("PaneDisplay", "Holds") .. "\n" .. ChartRadar:GetValue('RadarCategory_Holds'))
                self:GetChild("Hands"):settext(THEME:GetString("PaneDisplay", "Hands") .. "\n" .. ChartRadar:GetValue('RadarCategory_Hands'))
                self:GetChild("Mines"):settext(THEME:GetString("PaneDisplay", "Mines") .. "\n" .. ChartRadar:GetValue('RadarCategory_Mines'))
                self:GetChild("Rolls"):settext(THEME:GetString("PaneDisplay", "Rolls") .. "\n" .. ChartRadar:GetValue('RadarCategory_Rolls'))
            else
                self:GetChild("ChartInfo"):settext("")
                self:GetChild("Steps"):settext("")
                self:GetChild("Jumps"):settext("")
                self:GetChild("Holds"):settext("")
                self:GetChild("Hands"):settext("")
                self:GetChild("Mines"):settext("")
                self:GetChild("Rolls"):settext("")
            end
        end,

        Def.BitmapText {
            Font="Montserrat extrabold 20px",
            Name="ChartInfo",
            InitCommand=function(self)
                self:maxwidth(PanelW / self:GetZoom())
                :vertspacing(-6):shadowlength(1)
                :skewx(-0.2)
                :x(-172 + (pn == PLAYER_2 and 345 or 0))
                :y(13)
            end
        },

        Def.BitmapText {
            Font="Montserrat normal 20px",
            Name="Steps",
            InitCommand=function(self)
                self:zoom(0.75):shadowlength(1)
                :maxwidth(96 / self:GetZoom())
                :valign(0):vertspacing(-4)
                :x(StatsXSpacing - StatsX * 6 + PlayerX)
                :y(StatsY)
            end
        },

        Def.BitmapText {
            Font="Montserrat normal 20px",
            Name="Jumps",
            InitCommand=function(self)
                self:zoom(0.75):shadowlength(1)
                :maxwidth(96 / self:GetZoom())
                :valign(0):vertspacing(-4)
                :x(StatsXSpacing - StatsX * 5 + PlayerX)
                :y(StatsY)
            end
        },

        Def.BitmapText{
            Font="Montserrat normal 20px",
            Name="Holds",
            InitCommand=function(self)
                self:zoom(0.75):shadowlength(1)
                :maxwidth(96 / self:GetZoom())
                :valign(0):vertspacing(-4)
                :x(StatsXSpacing - StatsX * 4 + PlayerX)
                :y(StatsY)
            end
        },

        Def.BitmapText {
            Font="Montserrat normal 20px",
            Name="Hands",
            InitCommand=function(self)
                self:zoom(0.75):shadowlength(1)
                :maxwidth(96 / self:GetZoom())
                :valign(0):vertspacing(-4)
                :x(StatsXSpacing - StatsX * 3 + PlayerX)
                :y(StatsY)
            end
        },

        Def.BitmapText {
            Font="Montserrat normal 20px",
            Name="Mines",
            InitCommand=function(self)
                self:zoom(0.75):shadowlength(1)
                :maxwidth(96 / self:GetZoom())
                :valign(0):vertspacing(-4)
                :x(StatsXSpacing - StatsX * 2 + PlayerX)
                :y(StatsY)
            end
        },

        Def.BitmapText {
            Font="Montserrat normal 20px",
            Name="Rolls",
            InitCommand=function(self)
                self:zoom(0.75):shadowlength(1)
                :maxwidth(96 / self:GetZoom())
                :valign(0):vertspacing(-4)
                :x(StatsXSpacing - StatsX + PlayerX)
                :y(StatsY)
            end
        },

        Def.ActorFrame {
            InitCommand=function(self) self:diffusealpha(1):queuecommand("ShowAMV") end,
            SongChosenMessageCommand=function(self) self:stoptweening():diffusealpha(1):queuecommand("ShowAMV") end,

            CurrentChartChangedMessageCommand=function(self, params) 
                if params.Player == pn then
                    self:stoptweening():diffusealpha(0)
                    if GAMESTATE:GetCurrentSong() then
                        self:sleep(PreviewDelay):queuecommand("ShowAMV")
                    end
                end
            end,

            ShowAMVCommand=function(self) self:linear(PreviewDelay):diffusealpha(1) end,
            -- valign(1) doesn't work with ActorMultiVertex :(
            LoadActor("../NPSDiagram", (pn == PLAYER_2 and 128 or -128), 111, 250, 40, false, pn)
        }
    }
end

----
-- vvvv POI PROJECT vvvv
----

local usingPOIUX = LoadModule("Config.Load.lua")("ActivatePOIProjectUX", "Save/OutFoxPrefs.ini") or false
if usingPOIUX then
	-- levers

	t = Def.ActorFrame {}

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
					
					local ChartNameFromDesc = ""
					local ChartOriginFromDesc = ""
					local openParen = ChartDescriptionText:find("%(")
					local closeParen = ChartDescriptionText:find("%)")
					ChartNameFromDesc = ChartDescriptionText:sub(1, openParen - 2)
					ChartOriginFromDesc = ChartDescriptionText:sub(openParen + 1, closeParen - 1)
					
					self:GetChild("ChartName-label"):settext("DESCRIPTION")
					self:GetChild("ChartName"):settext(ChartNameFromDesc)
					self:GetChild("ChartOrigin-label"):settext("ORIGIN")				
					self:GetChild("ChartOrigin"):settext(ChartOriginFromDesc)				
					self:GetChild("ChartAuthor-label"):settext("STEP ARTIST")
					self:GetChild("ChartAuthor"):settext(ChartAuthorText)
					self:GetChild("PersonalRec-label"):settext("PERSONAL RECORDS")
					self:GetChild("MachineRec-label"):settext("MACHINE RECORDS")
				else       
					self:GetChild("ChartName-label"):settext("")
					self:GetChild("ChartName"):settext("")
					self:GetChild("ChartOrigin-label"):settext("")
					self:GetChild("ChartOrigin"):settext("")				
					self:GetChild("ChartAuthor-label"):settext("")
					self:GetChild("ChartAuthor"):settext("")
					self:GetChild("PersonalRec-label"):settext("")
					self:GetChild("MachineRec-label"):settext("")
				end
			end,
			
			-- central quad
			Def.Quad {
				InitCommand=function(self)
					self:zoomto(3, 258):diffuse(Color.Black):diffusealpha(0.7):y(120):x(0)
				end
			},
			
			-- quad that divides song info from personal record
			Def.Quad {
				InitCommand=function(self)
					self:zoomto(3, 258):diffuse(Color.Black):diffusealpha(0.7):y(120):x(260 * (pn == PLAYER_2 and 1 or -1))
				end
			},
			
			-- quad that divides personal record from machine record
			Def.Quad {
				InitCommand=function(self)
					self:zoomto(3, 258):diffuse(Color.Black):diffusealpha(0.7):y(120):x(440 * (pn == PLAYER_2 and 1 or -1))
				end
			},
			
			Def.BitmapText {
				Font="Montserrat normal 20px",
				Name="ChartName-label",
				InitCommand=function(self)
					self:x(10 * (pn == PLAYER_2 and 1 or -1)):y(6):zoom(0.7)
					:halign(pn == PLAYER_2 and 0 or 1):maxwidth(172)
					:shadowlength(2)
					:skewx(-0.2)
				end
			},
			Def.BitmapText {
				Font="Montserrat semibold 20px",
				Name="ChartName",
				InitCommand=function(self)
					self:x(10 * (pn == PLAYER_2 and 1 or -1)):y(6+22):zoom(1.4)
					:halign(pn == PLAYER_2 and 0 or 1):maxwidth(172)
					:shadowlength(2)
				end
			},
			
			Def.BitmapText {
				Font="Montserrat normal 20px",
				Name="ChartOrigin-label",
				InitCommand=function(self)
					self:x(10 * (pn == PLAYER_2 and 1 or -1)):y(88):zoom(0.7)
					:halign(pn == PLAYER_2 and 0 or 1):maxwidth(172)
					:shadowlength(2)
					:skewx(-0.2)
				end
			},
			Def.BitmapText {
				Font="Montserrat semibold 20px",
				Name="ChartOrigin",
				InitCommand=function(self)
					self:x(10 * (pn == PLAYER_2 and 1 or -1)):y(88+22):zoom(1.4)
					:halign(pn == PLAYER_2 and 0 or 1):maxwidth(172)
					:shadowlength(2)
				end
			},		
			
			Def.BitmapText {
				Font="Montserrat normal 20px",
				Name="ChartAuthor-label",
				InitCommand=function(self)
					self:x(10 * (pn == PLAYER_2 and 1 or -1)):y(170):zoom(0.7)
					:halign(pn == PLAYER_2 and 0 or 1):maxwidth(172)
					:shadowlength(2)
					:skewx(-0.2)
				end
			},
			Def.BitmapText {
				Font="Montserrat semibold 20px",
				Name="ChartAuthor",
				InitCommand=function(self)
					self:x(10 * (pn == PLAYER_2 and 1 or -1)):y(170+22):zoom(1.4)
					:halign(pn == PLAYER_2 and 0 or 1):maxwidth(172)
					:shadowlength(2)
				end
			},
			
			Def.BitmapText {
				Font="Montserrat normal 20px",
				Name="PersonalRec-label",
				InitCommand=function(self)
					self:x(274 * (pn == PLAYER_2 and 1 or -1)):y(6):zoom(0.7)
					:halign(pn == PLAYER_2 and 0 or 1):maxwidth(300)
					:shadowlength(2)
					:skewx(-0.2)
				end
			},
			Def.BitmapText {
				Font="Montserrat normal 20px",
				Name="MachineRec-label",
				InitCommand=function(self)
					self:x(470 * (pn == PLAYER_2 and 1 or -1)):y(6):zoom(0.7)
					:halign(pn == PLAYER_2 and 0 or 1):maxwidth(300)
					:shadowlength(2)
					:skewx(-0.2)
				end
			},
		}
	end
end

return t