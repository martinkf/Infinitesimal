local ItemW = 56
local ItemH = 56
local ItemAmount = ...
local ItemTotalW = ItemW * ((ItemAmount - 1) / 2)

local FrameX = -ItemTotalW

local ChartIndex = { PlayerNumber_P1 = 1, PlayerNumber_P2 = 1 }
local PrevChartIndex = { PlayerNumber_P1 = 1, PlayerNumber_P2 = 1 }
local PlayerCanMove = { PlayerNumber_P1 = true, PlayerNumber_P2 = true }
local ConfirmStart = { PlayerNumber_P1 = false, PlayerNumber_P2 = false }

local ChartArray = nil
local SongIsChosen = false
local PreviewDelay = THEME:GetMetric("ScreenSelectMusic", "SampleMusicDelay")
local CenterList = LoadModule("Config.Load.lua")("CenterChartList", "Save/OutFoxPrefs.ini")
local CanWrap = LoadModule("Config.Load.lua")("WrapChartScroll", "Save/OutFoxPrefs.ini")

-- http://lua-users.org/wiki/CopyTable
function ShallowCopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function SortCharts(a, b)
    if a:GetStepsType() == b:GetStepsType() then
        return a:GetMeter() < b:GetMeter()
    else
        return a:GetStepsType() > b:GetStepsType()
    end
end

local ChartLabels = {
    "NEW",
    "ANOTHER",
    "PRO",
    "TRAIN",
    "QUEST",
    "UCS",
    "HIDDEN",
    "INFINITY",
    "JUMP",
}

local function InputHandler(event)
    local pn = event.PlayerNumber
    if not pn then return end

    -- To avoid control from a player that has not joined, filter the inputs out
    if pn == PLAYER_1 and not GAMESTATE:IsPlayerEnabled(PLAYER_1) then return end
    if pn == PLAYER_2 and not GAMESTATE:IsPlayerEnabled(PLAYER_2) then return end

    if SongIsChosen and PlayerCanMove[pn] then
        -- Filter out everything but button presses
        if event.type == "InputEventType_Repeat" or event.type == "InputEventType_Release" then return end

        local button = event.button
        if button == "Left" or button == "MenuLeft" or button == "DownLeft" then
            if ChartIndex[pn] == 1 then
                if CanWrap then
                    ChartIndex[pn] = #ChartArray
                else return end
            else
                ChartIndex[pn] = ChartIndex[pn] - 1
            end
            MESSAGEMAN:Broadcast("UpdateChartDisplay", { Player = pn })
			ConfirmStart[pn] = false
			
        elseif button == "Right" or button == "MenuRight" or button == "DownRight" then
            if ChartIndex[pn] == #ChartArray then
                if CanWrap then
                    ChartIndex[pn] = 1
                else return end
            else
                ChartIndex[pn] = ChartIndex[pn] + 1
            end
            MESSAGEMAN:Broadcast("UpdateChartDisplay", { Player = pn })
			ConfirmStart[pn] = false
        
		elseif button == "UpLeft" or button == "UpRight" or button == "Up" then
            MESSAGEMAN:Broadcast("StepsUnchosen", { Player = pn })
            MESSAGEMAN:Broadcast("SongUnchosen")
            ConfirmStart[pn] = false
            
        elseif button == "Start" or button == "MenuStart" or button == "Center" then
            if ConfirmStart[pn] then
                SongIsChosen = false
                
                -- Set these or else we crash.
                GAMESTATE:SetCurrentPlayMode("PlayMode_Regular")
                GAMESTATE:SetCurrentStyle(GAMESTATE:GetNumSidesJoined() > 1 and "versus" or string.lower(ShortType(GAMESTATE:GetCurrentSteps(pn))))
                SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
            else
                MESSAGEMAN:Broadcast("StepsChosen", { Player = pn })
                ConfirmStart[pn] = true
            end
        end
    end
    return
end

local t = Def.ActorFrame {
    OnCommand=function(self)
        SCREENMAN:GetTopScreen():AddInputCallback(InputHandler)
        self:playcommand("Refresh")
    end,

    -- Prevent the chart list from moving when transitioning
    OffCommand=function(self)
        SongIsChosen = false
    end,
    
    -- This is done to workaround the loss of input when doing the command window pad code
    CodeMessageCommand=function(self, params)
        if params.Name == "OpenOpList" then
            local pn = params.PlayerNumber
            
            if SongIsChosen and PlayerCanMove[pn] then
                if ChartIndex[pn] == #ChartArray then
                    if CanWrap then
                        ChartIndex[pn] = 1
                    else return end
                else
                    ChartIndex[pn] = ChartIndex[pn] + 1
                end
                MESSAGEMAN:Broadcast("UpdateChartDisplay", { Player = pn })
            end
        end
    end,

    -- Update chart list
    UpdateChartDisplayMessageCommand=function(self) self:playcommand("Refresh") end,
    CurrentSongChangedMessageCommand=function(self) self:playcommand("Refresh") end,

    -- These are to control the visibility of the chart highlight.
    SongChosenMessageCommand=function(self) SongIsChosen = true self:playcommand("Refresh") end,
    SongUnchosenMessageCommand=function(self) SongIsChosen = false self:playcommand("Refresh") end,

    OptionsListOpenedMessageCommand=function(self, params) PlayerCanMove[params.Player] = false end,
    OptionsListClosedMessageCommand=function(self, params) PlayerCanMove[params.Player] = true end,

    RefreshCommand=function(self)
        ChartArray = nil
        local CurrentSong = GAMESTATE:GetCurrentSong()
        if CurrentSong then
            ChartArray = SongUtil.GetPlayableSteps(CurrentSong)
            
            -- Filter out unwanted charts recursively
            local CurGroupName = GroupsList[LastGroupMainIndex] ~= nil and 
            GroupsList[LastGroupMainIndex].SubGroups[LastGroupSubIndex].Name or ""
            
            local ShowFilters = {"ShowUCSCharts", "ShowQuestCharts", "ShowHiddenCharts" }
            local ChartFilters = {"UCS", "QUEST", "HIDDEN" }
            local PrevChartArray
            
            for i = 1, 3 do
                if LoadModule("Config.Load.lua")(ShowFilters[i], "Save/OutFoxPrefs.ini") == false then
                    -- Only make a copy of the array if an attempt at removal will happen
                    PrevChartArray = ShallowCopy(ChartArray)
                    
                    for j = #ChartArray, 1, -1 do
                        if string.find(ToUpper(ChartArray[j]:GetDescription()), ChartFilters[i]) then
                            table.remove(ChartArray, j)
                        end
                    end
                    
                    if #ChartArray == 0 then ChartArray = ShallowCopy(PrevChartArray) end
                end
            end

            -- Normal chart checks
            for i = #ChartArray, 1, -1 do
                -- Couple and Routine crashes the game :(
                if string.find(ToUpper(ChartArray[i]:GetStepsType()), "ROUTINE") or
                    string.find(ToUpper(ChartArray[i]:GetStepsType()), "COUPLE") then
                    table.remove(ChartArray, i)
                end
                
                -- Co-op group should only display co-op charts
                if CurGroupName ~= nil and CurGroupName == "Co-op" then
                    if ChartArray[i]:GetStepsType() == 'StepsType_Pump_Double' and
                    (string.find(ToUpper(ChartArray[i]:GetDescription()), "DP") or 
                    string.find(ToUpper(ChartArray[i]:GetDescription()), "COOP")) and 
                    ChartArray[i]:GetMeter() == 99 then else
                        table.remove(ChartArray, i)
                    end
                end
            end

            -- If no charts are left, load all of them again in an attempt to avoid other crashes
            if #ChartArray == 0 then ChartArray = SongUtil.GetPlayableSteps(CurrentSong) end
            table.sort(ChartArray, SortCharts)
        end

        if ChartArray then
            -- Correct player chart indexes to ensure they're not off limits
            if ChartIndex[PLAYER_1] < 1 then ChartIndex[PLAYER_1] = 1
            elseif ChartIndex[PLAYER_1] > #ChartArray then ChartIndex[PLAYER_1] = #ChartArray end

            if ChartIndex[PLAYER_2] < 1 then ChartIndex[PLAYER_2] = 1
            elseif ChartIndex[PLAYER_2] > #ChartArray then ChartIndex[PLAYER_2] = #ChartArray end

            -- Set the selected charts and broadcast a new message to avoid possible
            -- race conditions trying to obtain the currently selected chart.
            if GAMESTATE:IsPlayerEnabled(PLAYER_1) then
                GAMESTATE:SetCurrentSteps(PLAYER_1, ChartArray[ChartIndex[PLAYER_1]])
                if ChartIndex[PLAYER_1] ~= PrevChartIndex[PLAYER_1] then
                MESSAGEMAN:Broadcast("CurrentChartChanged", { Player = PLAYER_1 }) end
            end
            if GAMESTATE:IsPlayerEnabled(PLAYER_2) then
                GAMESTATE:SetCurrentSteps(PLAYER_2, ChartArray[ChartIndex[PLAYER_2]])
                if ChartIndex[PLAYER_2] ~= PrevChartIndex[PLAYER_2] then
                MESSAGEMAN:Broadcast("CurrentChartChanged", { Player = PLAYER_2 }) end
            end

            -- After we use the previous chart index, we update it in advance for the next refresh
            PrevChartIndex[PLAYER_1] = ChartIndex[PLAYER_1]
            PrevChartIndex[PLAYER_2] = ChartIndex[PLAYER_2]

            local MainChartIndex = ChartIndex[PLAYER_1] > ChartIndex[PLAYER_2] and ChartIndex[PLAYER_1] or ChartIndex[PLAYER_2]

            local ListOffset = 0
            if MainChartIndex + 1 > ItemAmount then
                ListOffset = MainChartIndex - ItemAmount + (MainChartIndex == #ChartArray and 0 or 1)
            end

            if CenterList then
                -- Shift the positioning of the charts if they don't take up all visible slots
                local ChartArrayW = ItemW * ((#ChartArray < ItemAmount and #ChartArray or ItemAmount) - 1) / 2
                self:x(ItemTotalW - ChartArrayW)
            end

            if #ChartArray > ItemAmount then
                self:GetChild("")[ItemAmount+1]:GetChild("MoreLeft"):visible(MainChartIndex + 1 > ItemAmount)
                self:GetChild("")[ItemAmount+1]:GetChild("MoreRight"):visible(MainChartIndex + 1 < #ChartArray)
            else
                self:GetChild("")[ItemAmount+1]:GetChild("MoreLeft"):visible(false)
                self:GetChild("")[ItemAmount+1]:GetChild("MoreRight"):visible(false)
            end

            for i=1,ItemAmount do
                local Chart = ChartArray[ i + ListOffset ]

                if Chart then
                    local ChartMeter = Chart:GetMeter()
                    if ChartMeter == 99 then ChartMeter = "??" end
                    local ChartDescription = Chart:GetDescription()

                    self:GetChild("")[i]:GetChild("Icon"):visible(true):diffuse(ChartTypeToColor(Chart))
                    self:GetChild("")[i]:GetChild("IconTrim"):visible(true)
                    self:GetChild("")[i]:GetChild("Level"):visible(true):settext(ChartMeter)
                    self:GetChild("")[i]:GetChild("HighlightP1"):visible(
                        (ChartIndex[PLAYER_1] == i + ListOffset) and SongIsChosen and GAMESTATE:IsHumanPlayer(PLAYER_1))
                    self:GetChild("")[i]:GetChild("HighlightP2"):visible(
                        (ChartIndex[PLAYER_2] == i + ListOffset) and SongIsChosen and GAMESTATE:IsHumanPlayer(PLAYER_2))

                    --local ChartLabelString = ""
                    local ChartLabelIndex = 0

                    for Index, String in pairs(ChartLabels) do
                        if string.find(ToUpper(ChartDescription), String) then
                            --ChartLabelString = String
                            ChartLabelIndex = Index
                        end
                    end

                    if ChartLabelIndex ~= 0 then
                        self:GetChild("")[i]:GetChild("Label"):visible(true):setstate(ChartLabelIndex - 1)
                    else
                        self:GetChild("")[i]:GetChild("Label"):visible(false)
                    end
                else
                    if not CenterList then
                        self:GetChild("")[i]:GetChild("Icon"):visible(true):diffuse(Color.White):diffusealpha(0.25)
                        self:GetChild("")[i]:GetChild("IconTrim"):visible(true)
                    else
                        self:GetChild("")[i]:GetChild("Icon"):visible(false)
                        self:GetChild("")[i]:GetChild("IconTrim"):visible(false)
                    end
                    self:GetChild("")[i]:GetChild("Level"):visible(false)
                    self:GetChild("")[i]:GetChild("Label"):visible(false)
                    self:GetChild("")[i]:GetChild("HighlightP1"):visible(false)
                    self:GetChild("")[i]:GetChild("HighlightP2"):visible(false)
                end
            end
        else
            for i=1,ItemAmount do
                self:GetChild("")[i]:GetChild("Icon"):visible(false)
                self:GetChild("")[i]:GetChild("IconTrim"):visible(false)
                self:GetChild("")[i]:GetChild("Level"):visible(false)
                self:GetChild("")[i]:GetChild("Label"):visible(false)
                self:GetChild("")[i]:GetChild("HighlightP1"):visible(false)
                self:GetChild("")[i]:GetChild("HighlightP2"):visible(false)
            end
        end
    end,
}

for i=1,ItemAmount do
    t[#t+1] = Def.ActorFrame {
        Def.Sprite {
            Name="Icon",
            Texture=THEME:GetPathG("", "DifficultyDisplay/Ball"),
            InitCommand=function(self)
                self:xy(FrameX + ItemW * (i - 1), 0)
            end
        },

        Def.Sprite {
            Name="IconTrim",
            Texture=THEME:GetPathG("", "DifficultyDisplay/Trim"),
            InitCommand=function(self)
                self:xy(FrameX + ItemW * (i - 1), 0)
            end
        },

        Def.BitmapText {
            Font="Montserrat numbers 40px",
            Name="Level",
            InitCommand=function(self)
                self:xy(FrameX + ItemW * (i - 1), 0):zoom(0.6):maxwidth(75)
            end
        },

        Def.Sprite {
            Name="Label",
            Texture=THEME:GetPathG("", "DifficultyDisplay/Labels"),
            InitCommand=function(self)
                self:xy(FrameX + ItemW * (i - 1), 16):animate(false)
            end
        },

        Def.Sprite {
            Name="HighlightP1",
            Texture=THEME:GetPathG("", "DifficultyDisplay/Cursor/P1"),
            InitCommand=function(self)
                self:xy(FrameX + ItemW * (i - 1), -22)
                :zoom(0.5)
                :bounce():effectmagnitude(0, -5, 0):effectclock("bgm")
                :visible(false)
            end
        },

        Def.Sprite {
            Name="HighlightP2",
            Texture=THEME:GetPathG("", "DifficultyDisplay/Cursor/P2"),
            InitCommand=function(self)
                self:xy(FrameX + ItemW * (i - 1), 22)
                :zoom(0.5)
                :bounce():effectmagnitude(0, 5, 0):effectclock("bgm")
                :visible(false)
            end
        },

        LoadActor(THEME:GetPathS("Common","value")) .. {}
    }
end

t[#t+1] = Def.ActorFrame {
    Def.Sprite {
        Name="MoreLeft",
        Texture=THEME:GetPathG("", "DifficultyDisplay/MoreLeft"),
        InitCommand=function(self)
            self:xy(FrameX - 16 - ItemW, 0):zoom(0.4):visible(false)
            :bounce():effectmagnitude(16, 0, 0):effectclock("bgm")
        end
    },
    Def.Sprite {
        Name="MoreRight",
        Texture=THEME:GetPathG("", "DifficultyDisplay/MoreRight"),
        InitCommand=function(self)
            self:xy(FrameX + 16 + ItemW * 12, 0):zoom(0.4):visible(false)
            :bounce():effectmagnitude(-16, 0, 0):effectclock("bgm")
        end
    },
    Def.Sound {
        File=THEME:GetPathS("Common", "value"),
        IsAction=true,
        UpdateChartDisplayMessageCommand=function(self) self:play() end
    },
	Def.Sound {
        File=THEME:GetPathS("Common", "Start"),
        IsAction=true,
        StepsChosenMessageCommand=function(self) self:play() end
    }
}

----
-- vvvv POI PROJECT vvvv
----

local usingPOIUX = LoadModule("Config.Load.lua")("ActivatePOIProjectUX", "Save/OutFoxPrefs.ini") or false
if usingPOIUX then
	-- levers
	local chartList_Y = 156
	
	t = Def.ActorFrame {
		OnCommand=function(self)
			SCREENMAN:GetTopScreen():AddInputCallback(InputHandler)
			self:playcommand("Refresh"):y(chartList_Y)
		end,

		-- Prevent the chart list from moving when transitioning
		OffCommand=function(self)
			SongIsChosen = false
		end,
		
		-- This is done to workaround the loss of input when doing the command window pad code
		CodeMessageCommand=function(self, params)
			if params.Name == "OpenOpList" then
				local pn = params.PlayerNumber
				
				if SongIsChosen and PlayerCanMove[pn] then
					if ChartIndex[pn] == #ChartArray then
						if CanWrap then
							ChartIndex[pn] = 1
						else return end
					else
						ChartIndex[pn] = ChartIndex[pn] + 1
					end
					MESSAGEMAN:Broadcast("UpdateChartDisplay", { Player = pn })
				end
			end
		end,

		-- Update chart list
		UpdateChartDisplayMessageCommand=function(self) self:playcommand("Refresh") end,
		CurrentSongChangedMessageCommand=function(self) self:playcommand("Refresh") end,

		-- These are to control the visibility of the chart highlight.
		SongChosenMessageCommand=function(self) SongIsChosen = true self:playcommand("Refresh") end,
		SongUnchosenMessageCommand=function(self) SongIsChosen = false self:playcommand("Refresh") end,

		OptionsListOpenedMessageCommand=function(self, params) PlayerCanMove[params.Player] = false end,
		OptionsListClosedMessageCommand=function(self, params) PlayerCanMove[params.Player] = true end,

		RefreshCommand=function(self)
			ChartArray = nil
			local CurrentSong = GAMESTATE:GetCurrentSong()
			if CurrentSong then
				ChartArray = SongUtil.GetPlayableSteps(CurrentSong)
				
				-- Filter out unwanted charts recursively
				local CurGroupName = GroupsList[LastGroupMainIndex] ~= nil and 
				GroupsList[LastGroupMainIndex].SubGroups[LastGroupSubIndex].Name or ""
				
				local ShowFilters = {"ShowUCSCharts", "ShowQuestCharts", "ShowHiddenCharts" }
				local ChartFilters = {"UCS", "QUEST", "HIDDEN" }
				local PrevChartArray
				
				for i = 1, 3 do
					if LoadModule("Config.Load.lua")(ShowFilters[i], "Save/OutFoxPrefs.ini") == false then
						-- Only make a copy of the array if an attempt at removal will happen
						PrevChartArray = ShallowCopy(ChartArray)
						
						for j = #ChartArray, 1, -1 do
							if string.find(ToUpper(ChartArray[j]:GetDescription()), ChartFilters[i]) then
								table.remove(ChartArray, j)
							end
						end
						
						if #ChartArray == 0 then ChartArray = ShallowCopy(PrevChartArray) end
					end
				end

				-- Normal chart checks
				for i = #ChartArray, 1, -1 do
					-- Couple and Routine crashes the game :(
					if string.find(ToUpper(ChartArray[i]:GetStepsType()), "ROUTINE") or
						string.find(ToUpper(ChartArray[i]:GetStepsType()), "COUPLE") then
						table.remove(ChartArray, i)
					end
					
					-- Co-op group should only display co-op charts
					if CurGroupName ~= nil and CurGroupName == "Co-op" then
						if ChartArray[i]:GetStepsType() == 'StepsType_Pump_Double' and
						(string.find(ToUpper(ChartArray[i]:GetDescription()), "DP") or 
						string.find(ToUpper(ChartArray[i]:GetDescription()), "COOP")) and 
						ChartArray[i]:GetMeter() == 99 then else
							table.remove(ChartArray, i)
						end
					end
				end

				-- uses external FilterChartFromGroup POI function to filter out any unwanted chart, based on CurGroupName				
				ChartArray = FilterChartFromGroup_POI(CurGroupName,CurrentSong,ChartArray)
				
				-- If no charts are left, load all of them again in an attempt to avoid other crashes
				if #ChartArray == 0 then ChartArray = SongUtil.GetPlayableSteps(CurrentSong) end
				table.sort(ChartArray, SortCharts)
			end

			if ChartArray then
				-- Correct player chart indexes to ensure they're not off limits
				if ChartIndex[PLAYER_1] < 1 then ChartIndex[PLAYER_1] = 1
				elseif ChartIndex[PLAYER_1] > #ChartArray then ChartIndex[PLAYER_1] = #ChartArray end

				if ChartIndex[PLAYER_2] < 1 then ChartIndex[PLAYER_2] = 1
				elseif ChartIndex[PLAYER_2] > #ChartArray then ChartIndex[PLAYER_2] = #ChartArray end

				-- Set the selected charts and broadcast a new message to avoid possible
				-- race conditions trying to obtain the currently selected chart.
				if GAMESTATE:IsPlayerEnabled(PLAYER_1) then
					GAMESTATE:SetCurrentSteps(PLAYER_1, ChartArray[ChartIndex[PLAYER_1]])
					if ChartIndex[PLAYER_1] ~= PrevChartIndex[PLAYER_1] then
					MESSAGEMAN:Broadcast("CurrentChartChanged", { Player = PLAYER_1 }) end
				end
				if GAMESTATE:IsPlayerEnabled(PLAYER_2) then
					GAMESTATE:SetCurrentSteps(PLAYER_2, ChartArray[ChartIndex[PLAYER_2]])
					if ChartIndex[PLAYER_2] ~= PrevChartIndex[PLAYER_2] then
					MESSAGEMAN:Broadcast("CurrentChartChanged", { Player = PLAYER_2 }) end
				end

				-- After we use the previous chart index, we update it in advance for the next refresh
				PrevChartIndex[PLAYER_1] = ChartIndex[PLAYER_1]
				PrevChartIndex[PLAYER_2] = ChartIndex[PLAYER_2]

				local MainChartIndex = ChartIndex[PLAYER_1] > ChartIndex[PLAYER_2] and ChartIndex[PLAYER_1] or ChartIndex[PLAYER_2]

				local ListOffset = 0
				if MainChartIndex + 1 > ItemAmount then
					ListOffset = MainChartIndex - ItemAmount + (MainChartIndex == #ChartArray and 0 or 1)
				end

				if CenterList then
					-- Shift the positioning of the charts if they don't take up all visible slots
					local ChartArrayW = ItemW * ((#ChartArray < ItemAmount and #ChartArray or ItemAmount) - 1) / 2
					self:x(ItemTotalW - ChartArrayW)
				end

				if #ChartArray > ItemAmount then
					self:GetChild("")[ItemAmount+1]:GetChild("MoreLeft"):visible(MainChartIndex + 1 > ItemAmount)
					self:GetChild("")[ItemAmount+1]:GetChild("MoreRight"):visible(MainChartIndex + 1 < #ChartArray)
				else
					self:GetChild("")[ItemAmount+1]:GetChild("MoreLeft"):visible(false)
					self:GetChild("")[ItemAmount+1]:GetChild("MoreRight"):visible(false)
				end

				for i=1,ItemAmount do
					local CurrentSong = GAMESTATE:GetCurrentSong()
					local Chart = ChartArray[ i + ListOffset ]
										
					for j, chart in ipairs(ChartArray) do
						local scoreIndex = nil
						-- Fetch profile scores only if a valid chart is available
						if chart then
							local profile = PROFILEMAN:GetProfile(GAMESTATE:GetEnabledPlayers()[1])
							if profile then
								local scoreList = profile:GetHighScoreList(CurrentSong, chart)
								if scoreList then
									local scores = scoreList:GetHighScores()
									if scores and #scores > 0 then
										scoreIndex = LoadModule("PIU/Score.Grading.lua")(scores[1])
									end
								end
							end
						end

						-- Update the PersonalRecord sprite visibility and texture accordingly						
						if scoreIndex then
							self:GetChild("")[j]:GetChild("PersonalRecord"):visible(true):Load(THEME:GetPathG("", "LetterGrades/" .. (ClassicGrades and "" or "New/") .. scoreIndex))
						else
							self:GetChild("")[j]:GetChild("PersonalRecord"):visible(false)
						end
					end

					if Chart then
						local ChartMeter = Chart:GetMeter()
						if ChartMeter == 99 then ChartMeter = "??" end
						local ChartDescription = Chart:GetDescription()

						self:GetChild("")[i]:GetChild("Icon"):visible(true):diffuse(ColorFromChart_POI(Chart))
						self:GetChild("")[i]:GetChild("IconTrim"):visible(true)
						self:GetChild("")[i]:GetChild("Level"):visible(true):settext(ChartMeter)
						self:GetChild("")[i]:GetChild("HighlightP1"):visible(
							(ChartIndex[PLAYER_1] == i + ListOffset) and SongIsChosen and GAMESTATE:IsHumanPlayer(PLAYER_1))
						self:GetChild("")[i]:GetChild("HighlightP2"):visible(
							(ChartIndex[PLAYER_2] == i + ListOffset) and SongIsChosen and GAMESTATE:IsHumanPlayer(PLAYER_2))

						--local ChartLabelString = ""
						local ChartLabelIndex = 0

						for Index, String in pairs(ChartLabels) do
							if string.find(ToUpper(ChartDescription), String) then
								--ChartLabelString = String
								ChartLabelIndex = Index
							end
						end

						if ChartLabelIndex ~= 0 then
							self:GetChild("")[i]:GetChild("Label"):visible(true):setstate(ChartLabelIndex - 1)
						else
							self:GetChild("")[i]:GetChild("Label"):visible(false)
						end
						
					else
						if not CenterList then
							self:GetChild("")[i]:GetChild("Icon"):visible(true):diffuse(Color.White):diffusealpha(0.25)
							self:GetChild("")[i]:GetChild("IconTrim"):visible(true)
						else
							self:GetChild("")[i]:GetChild("Icon"):visible(false)
							self:GetChild("")[i]:GetChild("IconTrim"):visible(false)
						end
						self:GetChild("")[i]:GetChild("Level"):visible(false)
						self:GetChild("")[i]:GetChild("Label"):visible(false)
						self:GetChild("")[i]:GetChild("PersonalRecord"):visible(false)
						self:GetChild("")[i]:GetChild("HighlightP1"):visible(false)
						self:GetChild("")[i]:GetChild("HighlightP2"):visible(false)
					end
				end
			else
				for i=1,ItemAmount do
					self:GetChild("")[i]:GetChild("Icon"):visible(false)
					self:GetChild("")[i]:GetChild("IconTrim"):visible(false)
					self:GetChild("")[i]:GetChild("Level"):visible(false)
					self:GetChild("")[i]:GetChild("Label"):visible(false)
					self:GetChild("")[i]:GetChild("PersonalRecord"):visible(false)
					self:GetChild("")[i]:GetChild("HighlightP1"):visible(false)
					self:GetChild("")[i]:GetChild("HighlightP2"):visible(false)
				end
			end
		end,
	}

	for i=1,ItemAmount do
		t[#t+1] = Def.ActorFrame {
			Def.Sprite {
				Name="Icon",
				Texture=THEME:GetPathG("", "DifficultyDisplay/Ball"),
				InitCommand=function(self)
					self:xy(FrameX + ItemW * (i - 1), 0)
				end
			},

			Def.Sprite {
				Name="IconTrim",
				Texture=THEME:GetPathG("", "DifficultyDisplay/Trim"),
				InitCommand=function(self)
					self:xy(FrameX + ItemW * (i - 1), 0)
				end
			},

			Def.BitmapText {
				Font="Montserrat numbers 40px",
				Name="Level",
				InitCommand=function(self)
					self:xy(FrameX + ItemW * (i - 1), 0):zoom(0.6):maxwidth(75)
				end
			},

			Def.Sprite {
				Name="Label",
				Texture=THEME:GetPathG("", "DifficultyDisplay/Labels"),
				InitCommand=function(self)
					self:xy(FrameX + ItemW * (i - 1), 16):animate(false)
				end
			},
			
			Def.Sprite {
				Name="PersonalRecord",				
				InitCommand=function(self)
					self:xy(FrameX + ItemW * (i - 1), (GAMESTATE:IsPlayerEnabled(PLAYER_2) and -22 or 22)):animate(false):zoom(0.09)
				end
			},

			Def.Sprite {
				Name="HighlightP1",
				Texture=THEME:GetPathG("", "DifficultyDisplay/Cursor/P1"),
				InitCommand=function(self)
					self:xy(FrameX + ItemW * (i - 1), -22)
					:zoom(0.5)
					:bounce():effectmagnitude(0, -5, 0):effectclock("bgm")
					:visible(false)
				end
			},

			Def.Sprite {
				Name="HighlightP2",
				Texture=THEME:GetPathG("", "DifficultyDisplay/Cursor/P2"),
				InitCommand=function(self)
					self:xy(FrameX + ItemW * (i - 1), 22)
					:zoom(0.5)
					:bounce():effectmagnitude(0, 5, 0):effectclock("bgm")
					:visible(false)
				end
			},

			LoadActor(THEME:GetPathS("Common","value")) .. {}
		}
	end

	t[#t+1] = Def.ActorFrame {
		Def.Sprite {
			Name="MoreLeft",
			Texture=THEME:GetPathG("", "DifficultyDisplay/MoreLeft"),
			InitCommand=function(self)
				self:xy(FrameX - 16 - ItemW, 0):zoom(0.4):visible(false)
				:bounce():effectmagnitude(16, 0, 0):effectclock("bgm")
			end
		},
		Def.Sprite {
			Name="MoreRight",
			Texture=THEME:GetPathG("", "DifficultyDisplay/MoreRight"),
			InitCommand=function(self)
				self:xy(FrameX + 16 + ItemW * 12, 0):zoom(0.4):visible(false)
				:bounce():effectmagnitude(-16, 0, 0):effectclock("bgm")
			end
		},
		Def.Sound {
			File=THEME:GetPathS("Common", "value"),
			IsAction=true,
			UpdateChartDisplayMessageCommand=function(self) self:play() end
		},
		Def.Sound {
			File=THEME:GetPathS("Common", "Start"),
			IsAction=true,
			StepsChosenMessageCommand=function(self) self:play() end
		}
	}	
end

return t