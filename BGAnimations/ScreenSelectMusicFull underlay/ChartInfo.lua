local PanelW = 330
local PanelH = 120

local StatsX = 55
local StatsXSpacing = 25
local StatsY = 46

local SongIsChosen = false
local PreviewDelay = THEME:GetMetric("ScreenSelectMusic", "SampleMusicDelay")

local wholeGroup_Y = 166
local chartDesc_X = 150
local chartDesc_Y = 0
local chartOrigin_X = chartDesc_X
local chartOrigin_Y = 20
local chartArtist_X = chartDesc_X
local chartArtist_Y = 36


--


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


--


local t = Def.ActorFrame {}

for pn in ivalues(GAMESTATE:GetHumanPlayers()) do
	t[#t+1] = Def.ActorFrame {
		InitCommand=function(self) self:y(wholeGroup_Y):queuecommand("Refresh") end,
		
		SongChosenMessageCommand=function(self) SongIsChosen = true self:playcommand("Refresh") end,
		SongUnchosenMessageCommand=function(self) SongIsChosen = false end,
		CurrentChartChangedMessageCommand=function(self) if SongIsChosen then self:playcommand("Refresh") end end,

		RefreshCommand=function(self, params)
			if GAMESTATE:GetCurrentSong() and GAMESTATE:GetCurrentSteps(pn) then                
				local Chart = GAMESTATE:GetCurrentSteps(pn)					
				
				local ChartPOIName = FetchChartName_POI(Chart)
				local ChartOrigin = FetchChartOrigin_POI(Chart)
				
				local ChartAuthorText = Chart:GetAuthorCredit()
				local displayedArtist = ""
				if (ChartAuthorText == "Andamiro") then
					displayedArtist = ""
				elseif (ChartAuthorText == "") then
					displayedArtist = "Blank"
				else
					displayedArtist = ChartAuthorText
				end
									
				self:GetChild("ChartName"):settext(ChartPOIName)
				self:GetChild("ChartOrigin"):settext(ChartOrigin)
				self:GetChild("ChartAuthor"):settext(displayedArtist)
			else       
				self:GetChild("ChartName"):settext("")
				self:GetChild("ChartOrigin"):settext("")
				self:GetChild("ChartAuthor"):settext("")
			end
		end,
		
		
		-- DRAWING			
		Def.BitmapText {
			Font="Montserrat semibold 20px",
			Name="ChartName",
			InitCommand=function(self)
				self:x(chartDesc_X * (pn == PLAYER_2 and 1 or -1)):y(chartDesc_Y):zoom(1)
				:halign(pn == PLAYER_2 and 0.5 or 0.5):maxwidth(234):shadowlength(1)
			end
		},
		
		Def.BitmapText {
			Font="Montserrat normal 20px",
			Name="ChartOrigin",
			InitCommand=function(self)
				self:x(chartOrigin_X * (pn == PLAYER_2 and 1 or -1)):y(chartOrigin_Y):zoom(0.7)
				:halign(pn == PLAYER_2 and 0.5 or 0.5):maxwidth(172)
				:shadowlength(2)
				:skewx(-0.2)
			end
		},
		
		Def.BitmapText {
			Font="Montserrat normal 20px",
			Name="ChartAuthor",
			InitCommand=function(self)
				self:x(chartArtist_X * (pn == PLAYER_2 and 1 or -1)):y(chartArtist_Y):zoom(0.7)
				:halign(pn == PLAYER_2 and 0.5 or 0.5):maxwidth(172)
				:shadowlength(2)
				:skewx(-0.2)
			end
		}
	}
end


return t