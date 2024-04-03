-- Our main table which will contain all sorted groups.
MasterGroupsList = {}
GroupsList = {}

local ShowUCS = LoadModule("Config.Load.lua")("ShowUCSCharts", "Save/OutFoxPrefs.ini")
local ShowQuest = LoadModule("Config.Load.lua")("ShowQuestCharts", "Save/OutFoxPrefs.ini")
local ShowHidden = LoadModule("Config.Load.lua")("ShowHiddenCharts", "Save/OutFoxPrefs.ini")

local function GetValue(t, value)
    for k, v in pairs(t) do
        if v == value then return k end
    end
    return nil
end

local function HasValue(tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

local function PairsByKeys(t, f)
    local a = {}
    for n in pairs(t) do table.insert(a, n) end
    table.sort(a, f)
    local i = 0      -- iterator variable
    local iter = function ()   -- iterator function
        i = i + 1
        if a[i] == nil then return nil
        else return a[i], t[a[i]]
        end
    end
    return iter
end

local function SortSongsByTitle(a, b)
    return ToLower(a:GetTranslitFullTitle()) < ToLower(b:GetTranslitFullTitle())
end

function PlayableSongs(SongList)
	local SongTable = {}
	for Song in ivalues(SongList) do
        local Steps = SongUtil.GetPlayableSteps(Song)
		if #Steps > 0 then
			SongTable[#SongTable+1] = Song
		end
	end
	return SongTable
end

-- http://lua-users.org/wiki/CopyTable
function deepcopy(orig, copies)
    copies = copies or {}
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        if copies[orig] then
            copy = copies[orig]
        else
            copy = {}
            copies[orig] = copy
            for orig_key, orig_value in next, orig, nil do
                copy[deepcopy(orig_key, copies)] = deepcopy(orig_value, copies)
            end
            setmetatable(copy, deepcopy(getmetatable(orig), copies))
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function AssembleGroupSorting()
    Trace("Creating group sorts...")
    
	if not (SONGMAN and GAMESTATE) then
        Warn("SONGMAN or GAMESTATE were not ready! Aborting!")
        return
    end
	
	-- Empty current table
	MasterGroupsList = {}
    GroupsList = {}
    
    -- ======================================== All songs ========================================
    local AllSongs = SONGMAN:GetAllSongs()
    
    MasterGroupsList[#MasterGroupsList + 1] = {
        Name = "Special",
        Banner = THEME:GetPathG("", "Common fallback banner"),
        SubGroups = {
            {   
                Name = "All Tunes",
                Banner = THEME:GetPathG("", "Common fallback banner"),
                Songs = AllSongs
            }
        }
    }
    
    Trace("Group added: " .. MasterGroupsList[#MasterGroupsList].Name .. "/" .. 
    MasterGroupsList[#MasterGroupsList].SubGroups[#MasterGroupsList[#MasterGroupsList].SubGroups].Name  .. " - " .. 
    #MasterGroupsList[#MasterGroupsList].SubGroups[#MasterGroupsList[#MasterGroupsList].SubGroups].Songs .. " songs")
    
    -- ======================================== Shortcuts ========================================
    local Shortcuts = {}
    for j, Song in ipairs(AllSongs) do
        if Song:GetLastSecond() < 75 or string.find(string.upper(Song:GetSongDir()), "[SHORT CUT]", nil, true) then
           table.insert(Shortcuts, Song)
        end
    end
    
    if #Shortcuts ~= nil then
        MasterGroupsList[#MasterGroupsList].SubGroups[#MasterGroupsList[#MasterGroupsList].SubGroups + 1] = {
            Name = "Shortcut",
            Banner = THEME:GetPathG("", "Common fallback banner"), -- something appending v at the end
            Songs = Shortcuts,
        }
            
        Trace("Group added: " .. MasterGroupsList[#MasterGroupsList].Name .. "/" .. 
        MasterGroupsList[#MasterGroupsList].SubGroups[#MasterGroupsList[#MasterGroupsList].SubGroups].Name  .. " - " .. 
        #MasterGroupsList[#MasterGroupsList].SubGroups[#MasterGroupsList[#MasterGroupsList].SubGroups].Songs .. " songs")
    end
    
    -- ======================================== Remixes ========================================
    local Remixes = {}
    for j, Song in ipairs(AllSongs) do
        if string.find(string.upper(Song:GetSongDir()), "[REMIX]", nil, true) then
           table.insert(Remixes, Song)
        end
    end
    
    if #Remixes ~= nil then
        MasterGroupsList[#MasterGroupsList].SubGroups[#MasterGroupsList[#MasterGroupsList].SubGroups + 1] = {
            Name = "Remix",
            Banner = THEME:GetPathG("", "Common fallback banner"), -- something appending v at the end
            Songs = Remixes,
        }
            
        Trace("Group added: " .. MasterGroupsList[#MasterGroupsList].Name .. "/" .. 
        MasterGroupsList[#MasterGroupsList].SubGroups[#MasterGroupsList[#MasterGroupsList].SubGroups].Name  .. " - " .. 
        #MasterGroupsList[#MasterGroupsList].SubGroups[#MasterGroupsList[#MasterGroupsList].SubGroups].Songs .. " songs")
    end
    
    -- ======================================== Full Songs ========================================
    local FullSongs = {}
    for j, Song in ipairs(AllSongs) do
        local StepList = Song:GetAllSteps()
        if #StepList ~= 0 then
            local FirstStep = StepList[1]
            local Duration = FirstStep:GetChartLength()
            if string.find(string.upper(Song:GetSongDir()), "[FULL SONG]", nil, true) then
                table.insert(FullSongs, Song)
            elseif Duration > 150 and not string.find(string.upper(Song:GetSongDir()), "[REMIX]", nil, true) then
                table.insert(FullSongs, Song)
            end
        end
    end
    
    if #FullSongs ~= nil then
        MasterGroupsList[#MasterGroupsList].SubGroups[#MasterGroupsList[#MasterGroupsList].SubGroups + 1] = {
            Name = "Full Song",
            Banner = THEME:GetPathG("", "Common fallback banner"), -- something appending v at the end
            Songs = FullSongs,
        }
            
        Trace("Group added: " .. MasterGroupsList[#MasterGroupsList].Name .. "/" .. 
        MasterGroupsList[#MasterGroupsList].SubGroups[#MasterGroupsList[#MasterGroupsList].SubGroups].Name  .. " - " .. 
        #MasterGroupsList[#MasterGroupsList].SubGroups[#MasterGroupsList[#MasterGroupsList].SubGroups].Songs .. " songs")
    end
    
    -- ======================================== Co-op charts ========================================
    local CoopSongs = {}
    for j, Song in ipairs(AllSongs) do
        for i, Chart in ipairs(Song:GetStepsByStepsType('StepsType_Pump_Double')) do
            -- Filter out unwanted charts
            local ShouldRemove = false

            if not ShowUCS and string.find(ToUpper(Chart:GetDescription()), "UCS") then ShouldRemove = true
            elseif not ShowQuest and string.find(ToUpper(Chart:GetDescription()), "QUEST") then ShouldRemove = true
            elseif not ShowHidden and string.find(ToUpper(Chart:GetDescription()), "HIDDEN") then ShouldRemove = true end
            
            if not ShouldRemove then
                local ChartMeter = Chart:GetMeter()
                local ChartDescription = Chart:GetDescription()
                
                ChartDescription:gsub("[%p%c%s]", "")
                if string.find(string.upper(ChartDescription), "DP") or
                string.find(string.upper(ChartDescription), "COOP") then
                    if ChartMeter == 99 then
                       table.insert(CoopSongs, Song)
                       break
                    end
                end
            end
		end
    end
    
    if #CoopSongs ~= nil then
        MasterGroupsList[#MasterGroupsList].SubGroups[#MasterGroupsList[#MasterGroupsList].SubGroups + 1] = {
            Name = "Co-op",
            Banner = THEME:GetPathG("", "Common fallback banner"), -- something appending v at the end
            Songs = CoopSongs,
        }
            
        Trace("Group added: " .. MasterGroupsList[#MasterGroupsList].Name .. "/" .. 
        MasterGroupsList[#MasterGroupsList].SubGroups[#MasterGroupsList[#MasterGroupsList].SubGroups].Name  .. " - " .. 
        #MasterGroupsList[#MasterGroupsList].SubGroups[#MasterGroupsList[#MasterGroupsList].SubGroups].Songs .. " songs")
    end

    -- ======================================== Song groups ========================================
	local SongGroups = {}
    MasterGroupsList[#MasterGroupsList + 1] = {
        Name = "Group",
        Banner = THEME:GetPathG("", "Common fallback banner"),
        SubGroups = {}
    }

	-- Iterate through the song groups and check if they have AT LEAST one song with valid charts.
	-- If so, add them to the group.
	for GroupName in ivalues(SONGMAN:GetSongGroupNames()) do
		for Song in ivalues(SONGMAN:GetSongsInGroup(GroupName)) do
			local Steps = Song:GetAllSteps()
			if #Steps > 0 then
				SongGroups[#SongGroups + 1] = GroupName
				break
			end
		end
	end
    table.sort(SongGroups)
    
	for i, v in ipairs(SongGroups) do
		MasterGroupsList[#MasterGroupsList].SubGroups[#MasterGroupsList[#MasterGroupsList].SubGroups + 1] = {
			Name = SongGroups[i],
			Banner = SONGMAN:GetSongGroupBannerPath(SongGroups[i]),
			Songs = SONGMAN:GetSongsInGroup(SongGroups[i])
		}
        
        Trace("Group added: " .. MasterGroupsList[#MasterGroupsList].Name .. "/" .. 
        MasterGroupsList[#MasterGroupsList].SubGroups[#MasterGroupsList[#MasterGroupsList].SubGroups].Name  .. " - " .. 
        #MasterGroupsList[#MasterGroupsList].SubGroups[#MasterGroupsList[#MasterGroupsList].SubGroups].Songs .. " songs")
	end
    
    -- If nothing is available, remove the main entry completely
    if #MasterGroupsList[#MasterGroupsList].SubGroups == 0 then table.remove(MasterGroupsList) end
    
    -- ======================================== Song titles ========================================
    local Alphabet = {"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "#"}
    local TitleGroups = {}
    local SongInserted = false
    MasterGroupsList[#MasterGroupsList + 1] = {
        Name = "Title",
        Banner = THEME:GetPathG("", "Common fallback banner"),
        SubGroups = {}
    }
    
    for j, Song in ipairs(AllSongs) do
        SongInserted = false
        for i, Letter in ipairs(Alphabet) do
            if string.upper(Song:GetDisplayMainTitle():sub(1, 1)) == Letter then
                if TitleGroups[Letter] == nil then TitleGroups[Letter] = {} end
                table.insert(TitleGroups[Letter], Song)
                SongInserted = true
                break
            end
		end
        
        if SongInserted == false then
            if TitleGroups["#"] == nil then TitleGroups["#"] = {} end
            table.insert(TitleGroups["#"], Song)
        end
    end
    
    for i, v in pairs(Alphabet) do
        if TitleGroups[v] ~= nil then
            table.sort(TitleGroups[v], SortSongsByTitle)
            MasterGroupsList[#MasterGroupsList].SubGroups[#MasterGroupsList[#MasterGroupsList].SubGroups + 1] = {
                Name = v,
                Banner = THEME:GetPathG("", "Common fallback banner"), -- something appending v at the end
                Songs = TitleGroups[v],
            }
            
            Trace("Group added: " .. MasterGroupsList[#MasterGroupsList].Name .. "/" .. 
            MasterGroupsList[#MasterGroupsList].SubGroups[#MasterGroupsList[#MasterGroupsList].SubGroups].Name  .. " - " .. 
            #MasterGroupsList[#MasterGroupsList].SubGroups[#MasterGroupsList[#MasterGroupsList].SubGroups].Songs .. " songs")
        end
	end
    
    -- If nothing is available, remove the main entry completely
    if #MasterGroupsList[#MasterGroupsList].SubGroups == 0 then table.remove(MasterGroupsList) end
    
    -- ======================================== Song artists ========================================
    local ArtistGroups = {}
    local SongInserted = false
    MasterGroupsList[#MasterGroupsList + 1] = {
        Name = "Artist",
        Banner = THEME:GetPathG("", "Common fallback banner"),
        SubGroups = {}
    }
    
    for j, Song in ipairs(AllSongs) do
        SongInserted = false
        
        for i, Letter in ipairs(Alphabet) do
            if string.upper(Song:GetDisplayArtist():sub(1, 1)) == Letter then
                if ArtistGroups[Letter] == nil then ArtistGroups[Letter] = {} end
                table.insert(ArtistGroups[Letter], Song)
                SongInserted = true
                break
            end
		end
        
        if SongInserted == false then
            if ArtistGroups["#"] == nil then ArtistGroups["#"] = {} end
            table.insert(ArtistGroups["#"], Song)
        end
    end
    
    for i, v in pairs(Alphabet) do
        if ArtistGroups[v] ~= nil then
            table.sort(ArtistGroups[v], SortSongsByTitle)
            MasterGroupsList[#MasterGroupsList].SubGroups[#MasterGroupsList[#MasterGroupsList].SubGroups + 1] = {
                Name = v,
                Banner = THEME:GetPathG("", "Common fallback banner"), -- something appending v at the end
                Songs = ArtistGroups[v],
            }
            
            Trace("Group added: " .. MasterGroupsList[#MasterGroupsList].Name .. "/" .. 
            MasterGroupsList[#MasterGroupsList].SubGroups[#MasterGroupsList[#MasterGroupsList].SubGroups].Name  .. " - " .. 
            #MasterGroupsList[#MasterGroupsList].SubGroups[#MasterGroupsList[#MasterGroupsList].SubGroups].Songs .. " songs")
        end
	end
    
    -- If nothing is available, remove the main entry completely
    if #MasterGroupsList[#MasterGroupsList].SubGroups == 0 then table.remove(MasterGroupsList) end
    
    -- ======================================== Single levels ========================================
    local LevelGroups = {}
    MasterGroupsList[#MasterGroupsList + 1] = {
        Name = "Single",
        Banner = THEME:GetPathG("", "Common fallback banner"),
        SubGroups = {}
    }
    
    for j, Song in ipairs(AllSongs) do
        for i, Chart in ipairs(Song:GetAllSteps()) do
            -- Filter out unwanted charts
            local ShouldRemove = false
            local CurrentGameMode = GAMESTATE:GetCurrentGame():GetName()

            if not ShowUCS and string.find(ToUpper(Chart:GetDescription()), "UCS") then ShouldRemove = true
            elseif not ShowQuest and string.find(ToUpper(Chart:GetDescription()), "QUEST") then ShouldRemove = true
            elseif not ShowHidden and string.find(ToUpper(Chart:GetDescription()), "HIDDEN") then ShouldRemove = true end
            
            if string.find( Chart:GetStepsType():lower(), CurrentGameMode ) then
                if ToEnumShortString(ToEnumShortString(Chart:GetStepsType())) == "Single" and not ShouldRemove then
                    local ChartLevel = Chart:GetMeter()
                    if LevelGroups[ChartLevel] == nil then LevelGroups[ChartLevel] = {} end
                    if not HasValue(LevelGroups[ChartLevel], Song) then
                        table.insert(LevelGroups[ChartLevel], Song) 
                    end
                end
            end
        end
    end
        
    for i, v in PairsByKeys(LevelGroups) do
        MasterGroupsList[#MasterGroupsList].SubGroups[#MasterGroupsList[#MasterGroupsList].SubGroups + 1] = {
            Name = "Single " .. i,
            Banner = THEME:GetPathG("", "Common fallback banner"), -- something appending v at the end
            Songs = v,
        }
        
        Trace("Group added: " .. MasterGroupsList[#MasterGroupsList].Name .. "/" .. 
        MasterGroupsList[#MasterGroupsList].SubGroups[#MasterGroupsList[#MasterGroupsList].SubGroups].Name  .. " - " .. 
        #MasterGroupsList[#MasterGroupsList].SubGroups[#MasterGroupsList[#MasterGroupsList].SubGroups].Songs .. " songs")
	end
    
    -- If nothing is available, remove the main entry completely
    if #MasterGroupsList[#MasterGroupsList].SubGroups == 0 then table.remove(MasterGroupsList) end
    
    -- ======================================== Halfdouble levels ========================================
    LevelGroups = {}
    MasterGroupsList[#MasterGroupsList + 1] = {
        Name = "Half-Double",
        Banner = THEME:GetPathG("", "Common fallback banner"),
        SubGroups = {}
    }
    
    for j, Song in ipairs(AllSongs) do
        for i, Chart in ipairs(Song:GetAllSteps()) do
            -- Filter out unwanted charts
            local ShouldRemove = false
            local CurrentGameMode = GAMESTATE:GetCurrentGame():GetName()

            if not ShowUCS and string.find(ToUpper(Chart:GetDescription()), "UCS") then ShouldRemove = true
            elseif not ShowQuest and string.find(ToUpper(Chart:GetDescription()), "QUEST") then ShouldRemove = true
            elseif not ShowHidden and string.find(ToUpper(Chart:GetDescription()), "HIDDEN") then ShouldRemove = true end
            
            if string.find( Chart:GetStepsType():lower(), CurrentGameMode ) then
                if ToEnumShortString(ToEnumShortString(Chart:GetStepsType())) == "Halfdouble" and not ShouldRemove then
                    local ChartLevel = Chart:GetMeter()
                    if LevelGroups[ChartLevel] == nil then LevelGroups[ChartLevel] = {} end
                    if not HasValue(LevelGroups[ChartLevel], Song) then
                        table.insert(LevelGroups[ChartLevel], Song) 
                    end
                end
            end
        end
    end
    
    for i, v in PairsByKeys(LevelGroups) do
        MasterGroupsList[#MasterGroupsList].SubGroups[#MasterGroupsList[#MasterGroupsList].SubGroups + 1] = {
            Name = "Half-Double " .. i,
            Banner = THEME:GetPathG("", "Common fallback banner"), -- something appending v at the end
            Songs = v,
        }
        
        Trace("Group added: " .. MasterGroupsList[#MasterGroupsList].Name .. "/" .. 
        MasterGroupsList[#MasterGroupsList].SubGroups[#MasterGroupsList[#MasterGroupsList].SubGroups].Name  .. " - " .. 
        #MasterGroupsList[#MasterGroupsList].SubGroups[#MasterGroupsList[#MasterGroupsList].SubGroups].Songs .. " songs")
	end
    
    -- If nothing is available, remove the main entry completely
    if #MasterGroupsList[#MasterGroupsList].SubGroups == 0 then table.remove(MasterGroupsList) end
    
    -- ======================================== Double levels ========================================
    LevelGroups = {}
    MasterGroupsList[#MasterGroupsList + 1] = {
        Name = "Double",
        Banner = THEME:GetPathG("", "Common fallback banner"),
        SubGroups = {}
    }
    
    for j, Song in ipairs(AllSongs) do
        for i, Chart in ipairs(Song:GetAllSteps()) do
            -- Filter out unwanted charts
            local ShouldRemove = false
            local CurrentGameMode = GAMESTATE:GetCurrentGame():GetName()

            if not ShowUCS and string.find(ToUpper(Chart:GetDescription()), "UCS") then ShouldRemove = true
            elseif not ShowQuest and string.find(ToUpper(Chart:GetDescription()), "QUEST") then ShouldRemove = true
            elseif not ShowHidden and string.find(ToUpper(Chart:GetDescription()), "HIDDEN") then ShouldRemove = true end
            
            if string.find( Chart:GetStepsType():lower(), CurrentGameMode ) then
                if ToEnumShortString(ToEnumShortString(Chart:GetStepsType())) == "Double" and not ShouldRemove then
                    local ChartLevel = Chart:GetMeter()
                    if LevelGroups[ChartLevel] == nil then LevelGroups[ChartLevel] = {} end
                    if not HasValue(LevelGroups[ChartLevel], Song) then
                        table.insert(LevelGroups[ChartLevel], Song) 
                    end
                end
            end
        end
    end
    
    for i, v in PairsByKeys(LevelGroups) do
        MasterGroupsList[#MasterGroupsList].SubGroups[#MasterGroupsList[#MasterGroupsList].SubGroups + 1] = {
            Name = "Double " .. i,
            Banner = THEME:GetPathG("", "Common fallback banner"), -- something appending v at the end
            Songs = v,
        }
        
        Trace("Group added: " .. MasterGroupsList[#MasterGroupsList].Name .. "/" .. 
        MasterGroupsList[#MasterGroupsList].SubGroups[#MasterGroupsList[#MasterGroupsList].SubGroups].Name  .. " - " .. 
        #MasterGroupsList[#MasterGroupsList].SubGroups[#MasterGroupsList[#MasterGroupsList].SubGroups].Songs .. " songs")
	end
    
    -- If nothing is available, remove the main entry completely
    if #MasterGroupsList[#MasterGroupsList].SubGroups == 0 then table.remove(MasterGroupsList) end
	
	Trace("Group sorting created!")
end

function UpdateGroupSorting()
    Trace("Creating group list copy from master...")
    GroupsList = deepcopy(MasterGroupsList)
    
    Trace("Removing unplayable songs from list...")
    for MainGroup in pairs(GroupsList) do
        for SubGroup in pairs(GroupsList[MainGroup].SubGroups) do
            GroupsList[MainGroup].SubGroups[SubGroup].Songs = PlayableSongs(GroupsList[MainGroup].SubGroups[SubGroup].Songs)
            
            if #GroupsList[MainGroup].SubGroups[SubGroup].Songs == 0 then
                table.remove(GroupsList[MainGroup].SubGroups, SubGroup)
            end
        end
        
        if #GroupsList[MainGroup].SubGroups == 0 then
            table.remove(GroupsList, MainGroup)
        end
    end
    
    MESSAGEMAN:Broadcast("UpdateChartDisplay")
    Trace("Group sorting updated!")
end

----
-- vvvv POI PROJECT vvvv
----

function AssembleGroupSorting_POI()
	if not (SONGMAN and GAMESTATE) then
        Warn("SONGMAN or GAMESTATE were not ready! Aborting!")
        return
    end
	
	MasterGroupsList = {}
	
	--[[
	-- ================================================================================================== EVERYTHING ==================================================================================================    
    MasterGroupsList[#MasterGroupsList + 1] = {
        Name = "Temp (everything)",
        Banner = THEME:GetPathG("", "Common fallback banner"),
        SubGroups = {
            {   
                Name = "All Tunes",
                Banner = THEME:GetPathG("", "Common fallback banner"),
                Songs = SONGMAN:GetAllSongs()
            }
        }
    }
	
	
	-- ================================================================================================== FOLDERS ==================================================================================================    
    local SongGroups = {}
    MasterGroupsList[#MasterGroupsList + 1] = {
        Name = "Folders (temp)",
        Banner = THEME:GetPathG("", "Common fallback banner"),
        SubGroups = {}
    }

	-- Iterate through the song groups and check if they have AT LEAST one song with valid charts.
	-- If so, add them to the group.
	for GroupName in ivalues(SONGMAN:GetSongGroupNames()) do
		for Song in ivalues(SONGMAN:GetSongsInGroup(GroupName)) do
			local Steps = Song:GetAllSteps()
			if #Steps > 0 then
				SongGroups[#SongGroups + 1] = GroupName
				break
			end
		end
	end
    table.sort(SongGroups)
    
	for i, v in ipairs(SongGroups) do
		if SongGroups[i] ~= "OffsetControl" then
			MasterGroupsList[#MasterGroupsList].SubGroups[#MasterGroupsList[#MasterGroupsList].SubGroups + 1] = {
				Name = SongGroups[i],
				Banner = SONGMAN:GetSongGroupBannerPath(SongGroups[i]),
				Songs = SONGMAN:GetSongsInGroup(SongGroups[i])
			}
		end
	end
    
    -- If nothing is available, remove the main entry completely
    if #MasterGroupsList[#MasterGroupsList].SubGroups == 0 then table.remove(MasterGroupsList) end
	
	]]--
	-- ================================================================================================== POI PLAYLISTS ==================================================================================================
	local numberOfMastergroupsBeforeAdding = #MasterGroupsList
	local playlistNames = GetPlaylistNames_POI()
	for i, thisPlaylistName in ipairs(playlistNames) do
		--local thisPlaylistBanner = "Playlists/01-the1stdf.png"
		local thisPlaylistBanner = GetPlaylistBanner_POI(thisPlaylistName)
		local bannerPath = THEME:GetPathG("", thisPlaylistBanner)
		MasterGroupsList[#MasterGroupsList + 1] = {
			Name = thisPlaylistName,
			Banner = bannerPath,
			SubGroups = {}
		}		
	end
	
	-- for each playlist hard-coded into POI,
	for i = numberOfMastergroupsBeforeAdding + 1, #MasterGroupsList do
		-- grabs name of the playlist we're currently working on
		local nameOfCurrentPlaylist = MasterGroupsList[i].Name
		-- grabs number of sublists this playlist possess
		local numberOfSublists = #GetPlaylistData_POI(nameOfCurrentPlaylist)
		-- for each sublist obtained related to that playlist, which were hard-coded into POI,
		for j = 1, numberOfSublists do
			-- grabs name of this sublist
			local nameOfCurrentSublist = GetPlaylistData_POI(nameOfCurrentPlaylist)[j][1]
			-- grabs sublist description
			local descriptionOfCurrentSublist = GetPlaylistData_POI(nameOfCurrentPlaylist)[j][2]
			-- grab an array of strings which is the list of songs allowed in
			local listOfAllowedSongsAsString = GetSongDirsFromSublist_POI(nameOfCurrentPlaylist, nameOfCurrentSublist)
			-- creates an array of Song objects that match the list of songs allowed in
			local arrayOfAllowedSongs = CreateSongArrayBasedOnList_POI(listOfAllowedSongsAsString)
			-- if and only if there are more than 0 allowed songs, create a subgroup with them
			if #arrayOfAllowedSongs > 0 then
				table.insert(MasterGroupsList[i].SubGroups, #(MasterGroupsList[i].SubGroups) + 1, {
					Name = nameOfCurrentPlaylist .. descriptionOfCurrentSublist,
					Banner = THEME:GetPathG("", "Common fallback banner"),
					Songs = arrayOfAllowedSongs
					}
				)
			else end
		end
	end
	
	
	
	
	--[[
	MasterGroupsList = {}    	
	local playlists = {}
	local playlistNames = ListOfPlaylists_POI()
	
	-- populates MasterGroupList with all Playlists, and add its songs to a local playlist called "playlists"
	for i, thisPlaylistName in ipairs(playlistNames) do		
		MasterGroupsList[i] = {
			Name = thisPlaylistName,
			Banner = THEME:GetPathG("", "Common fallback banner"),
			SubGroups = {}
		}
		playlists[i] = GetArrayOfSongsFromPlaylist_POI(thisPlaylistName)
	end
	
	-- creates MasterGroupsList.SubGroups for each playlist
	for i = 1, #MasterGroupsList do
		-- grabs name of the playlist we're currently working on
		local nameOfCurrentPlaylist = MasterGroupsList[i].Name
		
		-- grabs list of the possible sublists for this playlist
		local listOfSublists = ListOfPossibleSublists_POI(nameOfCurrentPlaylist)
		
		-- for each of the possible sublists, create them
		for j, thisSublist in ipairs(listOfSublists) do
			if thisSublist == "No filters" then
				table.insert(MasterGroupsList[i].SubGroups, #(MasterGroupsList[i].SubGroups) + 1, {
					Name = playlistNames[i] .. "\n\n\nAll songs",
					Banner = THEME:GetPathG("", "Common fallback banner"),
					Songs = playlists[i]
					}
				)
			else
				-- creates the temporary string that contains the matched description of the sublist
				local sublistDesc = ""
				for _, sublist in ipairs(TableOfSublists_POI()) do if sublist[1] == thisSublist then sublistDesc = sublist[2] break end end
				-- grabs all the songs from current playlist
				local filteredSongs = playlists[i]
				
				-- filters the playlist allowing only what this sublist allows
				filteredSongs = SublistOfSongs_POI(filteredSongs, nameOfCurrentPlaylist, thisSublist)
				
				-- if and only if the filtered result has any matches, create a subgroup with those filtered songs
				if #filteredSongs > 0 then
					table.insert(MasterGroupsList[i].SubGroups, #(MasterGroupsList[i].SubGroups) + 1, {
						Name = playlistNames[i] .. sublistDesc,
						Banner = THEME:GetPathG("", "Common fallback banner"),
						Songs = filteredSongs
						}
					)
				else end			
			end
		end		
	end
		
		
	]]--	
		
		
		
		
		--[[
		
		
		-- "All Tunes" sublist		
		table.insert(MasterGroupsList[i].SubGroups, 1, {
			Name = playlistNames[i] .. "\n\n\nAll Tunes",
			Banner = THEME:GetPathG("", "Common fallback banner"),
			Songs = playlists[i]
			}
		)
		
		local TableSublistToText = {
			-- first element is the input into SublistOfSongs_POI | second element is the displayed text in GroupSelect
			{ "ORIGINAL", "\n\n\nFilter by genre\n(Original Only)" },
			{ "KPOP", "\n\n\nFilter by genre\n(K-Pop Only)" },
			{ "WORLDMUSIC", "\n\n\nFilter by genre\n(World Music Only)" },
			{ "SHORTCUT", "\n\n\nShort Cut Only\n(1 Heart)" },
			{ "ARCADE", "\n\n\nArcade Only\n(2 Hearts)" },
			{ "REMIX", "\n\n\nRemix Only\n(3 Hearts)" },
			{ "FULLSONG", "\n\n\nFull Songs Only\n(4 Hearts)" },			
		}
		
		-- creates HEARTS Sublists and GENRE Sublists
		for j = 1, #TableSublistToText do
			-- grabs all the songs from current playlist
			local filteredSongs = playlists[i]
			-- filters the playlist allowing only what this sublist allows
			filteredSongs = SublistOfSongs_POI(filteredSongs, TableSublistToText[j][1])
			-- if and only if the filtered result has any matches, create a subgroup with those filtered songs
			if #filteredSongs > 0 then
				table.insert(MasterGroupsList[i].SubGroups, #(MasterGroupsList[i].SubGroups) + 1, {
					Name = playlistNames[i] .. TableSublistToText[j][2],
					Banner = THEME:GetPathG("", "Common fallback banner"),
					Songs = filteredSongs
					}
				)
			else end
		end
		
	
		


	
	-- ================================================================================================== CUSTOM GROUPS ==================================================================================================        
	MasterGroupsList[#MasterGroupsList + 1] = {
        Name = "Custom Groups",
        Banner = THEME:GetPathG("", "Common fallback banner"),
        SubGroups = {}
    }
	
    -- ============================================================== CUSTOM GROUPS > Custom Group 01 ==============================================================
	-- Define the folder names to match
	local folderNamesToMatch = {
		"/Songs/POI-database/104 - PASSION/","/Songs/POI-database/204 - FINAL AUDITION/",
	}

	-- Initialize an empty array to store songs matching the folder names
	local filteredSongs = {}

	-- Iterate through each folder name to match
	for _, folderNameToMatch in ipairs(folderNamesToMatch) do
		-- Iterate through all songs
		for _, song in ipairs(SONGMAN:GetAllSongs()) do
			-- Extract the folder name from the song's directory
			local folderName = song:GetSongDir()

			-- Check if the folder name matches the current folder name to match
			if string.find(folderName, folderNameToMatch, 1, true) then
				-- Add the song to the filtered array
				table.insert(filteredSongs, song)
			end
		end
	end

	if #filteredSongs > 0 then
		table.insert(MasterGroupsList[#MasterGroupsList].SubGroups, #(MasterGroupsList[#MasterGroupsList].SubGroups) + 1, {
			Name = "Custom Group 01",
			Banner = THEME:GetPathG("", "Common fallback banner"),
			Songs = filteredSongs
			}
		)
	else end

	-- ================================================================================================== FOLDERS ==================================================================================================    
    MasterGroupsList[#MasterGroupsList + 1] = {
        Name = "Folders",
        Banner = THEME:GetPathG("", "Common fallback banner"),
        SubGroups = {}
    }
	
	-- ============================================================== FOLDERS > iterates for each one ==============================================================
	local SongGroups = {}

	-- Iterate through the song groups and check if they have AT LEAST one song with valid charts.
	-- If so, add them to the group.
	for GroupName in ivalues(SONGMAN:GetSongGroupNames()) do
		for Song in ivalues(SONGMAN:GetSongsInGroup(GroupName)) do
			local Steps = Song:GetAllSteps()
			if #Steps > 0 then
				SongGroups[#SongGroups + 1] = GroupName
				break
			end
		end
	end
    table.sort(SongGroups)
    
	for i, v in ipairs(SongGroups) do
	
		local sortedSongs = ReorderSongs_POI(SONGMAN:GetSongsInGroup(SongGroups[i]))
		MasterGroupsList[#MasterGroupsList].SubGroups[#MasterGroupsList[#MasterGroupsList].SubGroups + 1] = {
			Name = SongGroups[i],
			Banner = SONGMAN:GetSongGroupBannerPath(SongGroups[i]),
			Songs = sortedSongs
		}
	end
    
    -- If nothing is available, remove the main entry completely
    if #MasterGroupsList[#MasterGroupsList].SubGroups == 0 then table.remove(MasterGroupsList) end

	-- ================================================================================================== SINGLE LEVELS (TIERS) ==================================================================================================    
	MasterGroupsList[#MasterGroupsList + 1] = {
		Name = "Single",
		Banner = THEME:GetPathG("", "Common fallback banner"),
		SubGroups = {}
	}
	
    -- ============================================================== SINGLE LEVELS (TIERS) > iterates for each one ==============================================================
    -- Initialization
	local LevelGroups = {}
	local tiersOrder = {"Tier E\n(S01~S03)", "Tier D\n(S04~S06)", "Tier C\n(S07~S10)", "Tier B\n(S11~S14)", "Tier A\n(S15~S18)", "Tier A+\n(S19~S22)", "Tier S\n(S23+)"}

	-- Helper function to determine the subgroup name based on chart level
	local function GetSubgroupName(chartLevel)
		if chartLevel >= 1 and chartLevel <= 3 then
			return "Tier E\n(S01~S03)"
		elseif chartLevel >= 4 and chartLevel <= 6 then
			return "Tier D\n(S04~S06)"
		elseif chartLevel >= 7 and chartLevel <= 10 then
			return "Tier C\n(S07~S10)"
		elseif chartLevel >= 11 and chartLevel <= 14 then
			return "Tier B\n(S11~S14)"
		elseif chartLevel >= 15 and chartLevel <= 18 then
			return "Tier A\n(S15~S18)"
		elseif chartLevel >= 19 and chartLevel <= 22 then
			return "Tier A+\n(S19~S22)"
		else
			return "Tier S\n(S23+)"
		end
	end

	-- Loop through Songs and Charts
	for j, Song in ipairs(AllSongs) do
		for i, Chart in ipairs(Song:GetAllSteps()) do
			-- Filter out unwanted charts
			local ShouldRemove = false
			local CurrentGameMode = GAMESTATE:GetCurrentGame():GetName()

			if not ShowUCS and string.find(ToUpper(Chart:GetDescription()), "UCS") then ShouldRemove = true
			elseif not ShowQuest and string.find(ToUpper(Chart:GetDescription()), "QUEST") then ShouldRemove = true
			elseif not ShowHidden and string.find(ToUpper(Chart:GetDescription()), "HIDDEN") then ShouldRemove = true end
			
			if string.find( Chart:GetStepsType():lower(), CurrentGameMode ) then
				if ToEnumShortString(ToEnumShortString(Chart:GetStepsType())) == "Single" and not ShouldRemove then
					local ChartLevel = Chart:GetMeter()
					local subgroupName = GetSubgroupName(ChartLevel)
					if LevelGroups[subgroupName] == nil then LevelGroups[subgroupName] = {} end
					if not HasValue(LevelGroups[subgroupName], Song) then
						table.insert(LevelGroups[subgroupName], Song) 
					end
				end
			end
		end
	end

	-- Building Subgroups
	for _, subgroupName in ipairs(tiersOrder) do
		if LevelGroups[subgroupName] ~= nil then
			MasterGroupsList[#MasterGroupsList].SubGroups[#MasterGroupsList[#MasterGroupsList].SubGroups + 1] = {
				Name = subgroupName,
				Banner = THEME:GetPathG("", "Common fallback banner"),
				Songs = LevelGroups[subgroupName],
			}
		end
	end

	-- Cleanup
	if #MasterGroupsList[#MasterGroupsList].SubGroups == 0 then table.remove(MasterGroupsList) end
    
	-- ================================================================================================== HALF-DOUBLE LEVELS (TIERS) ==================================================================================================
	MasterGroupsList[#MasterGroupsList + 1] = {
		Name = "Half-Double",
		Banner = THEME:GetPathG("", "Common fallback banner"),
		SubGroups = {}
	}
	
    -- ============================================================== HALF-DOUBLE LEVELS (TIERS) > iterates for each one ==============================================================
    -- Initialization
	local LevelGroups = {}
	local tiersOrder = {"Tier E\n(HD01~HD03)", "Tier D\n(HD04~HD06)", "Tier C\n(HD07~HD10)", "Tier B\n(HD11~HD14)", "Tier A\n(HD15~HD18)", "Tier A+\n(HD19~HD22)", "Tier S\n(HD23+)"}

	-- Helper function to determine the subgroup name based on chart level
	local function GetSubgroupName(chartLevel)
		if chartLevel >= 1 and chartLevel <= 3 then
			return "Tier E\n(HD01~HD03)"
		elseif chartLevel >= 4 and chartLevel <= 6 then
			return "Tier D\n(HD04~HD06)"
		elseif chartLevel >= 7 and chartLevel <= 10 then
			return "Tier C\n(HD07~HD10)"
		elseif chartLevel >= 11 and chartLevel <= 14 then
			return "Tier B\n(HD11~HD14)"
		elseif chartLevel >= 15 and chartLevel <= 18 then
			return "Tier A\n(HD15~HD18)"
		elseif chartLevel >= 19 and chartLevel <= 22 then
			return "Tier A+\n(HD19~HD22)"
		else
			return "Tier S\n(HD23+)"
		end
	end

	-- Loop through Songs and Charts
	for j, Song in ipairs(AllSongs) do
		for i, Chart in ipairs(Song:GetAllSteps()) do
			-- Filter out unwanted charts
			local ShouldRemove = false
			local CurrentGameMode = GAMESTATE:GetCurrentGame():GetName()

			if not ShowUCS and string.find(ToUpper(Chart:GetDescription()), "UCS") then ShouldRemove = true
			elseif not ShowQuest and string.find(ToUpper(Chart:GetDescription()), "QUEST") then ShouldRemove = true
			elseif not ShowHidden and string.find(ToUpper(Chart:GetDescription()), "HIDDEN") then ShouldRemove = true end
			
			if string.find( Chart:GetStepsType():lower(), CurrentGameMode ) then
				if ToEnumShortString(ToEnumShortString(Chart:GetStepsType())) == "Halfdouble" and not ShouldRemove then
					local ChartLevel = Chart:GetMeter()
					local subgroupName = GetSubgroupName(ChartLevel)
					if LevelGroups[subgroupName] == nil then LevelGroups[subgroupName] = {} end
					if not HasValue(LevelGroups[subgroupName], Song) then
						table.insert(LevelGroups[subgroupName], Song) 
					end
				end
			end
		end
	end

	-- Building Subgroups
	for _, subgroupName in ipairs(tiersOrder) do
		if LevelGroups[subgroupName] ~= nil then
			MasterGroupsList[#MasterGroupsList].SubGroups[#MasterGroupsList[#MasterGroupsList].SubGroups + 1] = {
				Name = subgroupName,
				Banner = THEME:GetPathG("", "Common fallback banner"),
				Songs = LevelGroups[subgroupName],
			}
		end
	end

	-- Cleanup
	if #MasterGroupsList[#MasterGroupsList].SubGroups == 0 then table.remove(MasterGroupsList) end
    
	-- ================================================================================================== DOUBLE LEVELS (TIERS) ==================================================================================================
	MasterGroupsList[#MasterGroupsList + 1] = {
		Name = "Double",
		Banner = THEME:GetPathG("", "Common fallback banner"),
		SubGroups = {}
	}
	
    -- ============================================================== DOUBLE LEVELS (TIERS) > iterates for each one ==============================================================
    -- Initialization
	local LevelGroups = {}
	local tiersOrder = {"Tier E\n(D01~D03)", "Tier D\n(D04~D06)", "Tier C\n(D07~D10)", "Tier B\n(D11~D14)", "Tier A\n(D15~D18)", "Tier A+\n(D19~D22)", "Tier S\n(D23+)", "Special Charts"}

	-- Helper function to determine the subgroup name based on chart level
	local function GetSubgroupName(chartLevel)
		if chartLevel >= 1 and chartLevel <= 3 then
			return "Tier E\n(D01~D03)"
		elseif chartLevel >= 4 and chartLevel <= 6 then
			return "Tier D\n(D04~D06)"
		elseif chartLevel >= 7 and chartLevel <= 10 then
			return "Tier C\n(D07~D10)"
		elseif chartLevel >= 11 and chartLevel <= 14 then
			return "Tier B\n(D11~D14)"
		elseif chartLevel >= 15 and chartLevel <= 18 then
			return "Tier A\n(D15~D18)"
		elseif chartLevel >= 19 and chartLevel <= 22 then
			return "Tier A+\n(D19~D22)"
		elseif chartLevel == 99 then
			return "Special Charts"
		else
			return "Tier S\n(D23+)"
		end
	end

	-- Loop through Songs and Charts
	for j, Song in ipairs(AllSongs) do
		for i, Chart in ipairs(Song:GetAllSteps()) do
			-- Filter out unwanted charts
			local ShouldRemove = false
			local CurrentGameMode = GAMESTATE:GetCurrentGame():GetName()

			if not ShowUCS and string.find(ToUpper(Chart:GetDescription()), "UCS") then ShouldRemove = true
			elseif not ShowQuest and string.find(ToUpper(Chart:GetDescription()), "QUEST") then ShouldRemove = true
			elseif not ShowHidden and string.find(ToUpper(Chart:GetDescription()), "HIDDEN") then ShouldRemove = true end
			
			if string.find( Chart:GetStepsType():lower(), CurrentGameMode ) then
				if ToEnumShortString(ToEnumShortString(Chart:GetStepsType())) == "Double" and not ShouldRemove then
					local ChartLevel = Chart:GetMeter()
					local subgroupName = GetSubgroupName(ChartLevel)
					if LevelGroups[subgroupName] == nil then LevelGroups[subgroupName] = {} end
					if not HasValue(LevelGroups[subgroupName], Song) then
						table.insert(LevelGroups[subgroupName], Song) 
					end
				end
			end
		end
	end

	-- Building Subgroups
	for _, subgroupName in ipairs(tiersOrder) do
		if LevelGroups[subgroupName] ~= nil then
			MasterGroupsList[#MasterGroupsList].SubGroups[#MasterGroupsList[#MasterGroupsList].SubGroups + 1] = {
				Name = subgroupName,
				Banner = THEME:GetPathG("", "Common fallback banner"),
				Songs = LevelGroups[subgroupName],
			}
			
			Trace("Group added: " .. MasterGroupsList[#MasterGroupsList].Name .. "/" .. 
			MasterGroupsList[#MasterGroupsList].SubGroups[#MasterGroupsList[#MasterGroupsList].SubGroups].Name  .. " - " .. 
			#MasterGroupsList[#MasterGroupsList].SubGroups[#MasterGroupsList[#MasterGroupsList].SubGroups].Songs .. " songs")
		end
	end

	-- Cleanup
	if #MasterGroupsList[#MasterGroupsList].SubGroups == 0 then table.remove(MasterGroupsList) end

	]]--
	
end