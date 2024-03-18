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
    GroupsList = {}
    
	--
	local playlists = {}
	local playlistNames = {
		"All Songs",
		"The 1st DF",
		"The 2nd DF",
	}
	
	-- populates MasterGroupLists with all Playlists
	for i, thisPlaylistName in ipairs(playlistNames) do		
		MasterGroupsList[i] = {
			Name = thisPlaylistName,
			Banner = THEME:GetPathG("", "Common fallback banner"),
			SubGroups = {}
		}
		playlists[i] = GetArrayOfSongsBasedOnPlaylist(thisPlaylistName)
	end
	
	-- creates MasterGroupsList.SubGroups for each playlist
	for i = 1, #MasterGroupsList do
		-- "All Tunes" filter		
		table.insert(MasterGroupsList[i].SubGroups, 1, {
			Name = playlistNames[i] .. "\n\n\nAll Tunes",
			Banner = THEME:GetPathG("", "Common fallback banner"),
			Songs = playlists[i]
			}
		)
		
		-- "Short Cut" filter
		-- grabs all the songs from current playlist
		local filteredSongs = playlists[i]
		-- filters the playlist allowing only Short Cuts
		filteredSongs = FilterSongs_POI(filteredSongs, "Shortcuts")
		-- if and only if the filtered result has any matches, create a subgroup with those filtered songs
		if #filteredSongs > 0 then
			table.insert(MasterGroupsList[i].SubGroups, #(MasterGroupsList[i].SubGroups) + 1, {
				Name = playlistNames[i] .. "\n\n\nShort Cut Only\n(1 Heart)",
				Banner = THEME:GetPathG("", "Common fallback banner"),
				Songs = filteredSongs
				}
			)
		else end
		
		-- "Arcade" filter
		-- grabs all the songs from current playlist
		local filteredSongs = playlists[i]
		-- filters the playlist allowing only Short Cuts
		filteredSongs = FilterSongs_POI(filteredSongs, "Arcades")
		-- if and only if the filtered result has any matches, create a subgroup with those filtered songs
		if #filteredSongs > 0 then
			table.insert(MasterGroupsList[i].SubGroups, #(MasterGroupsList[i].SubGroups) + 1, {
				Name = playlistNames[i] .. "\n\n\nArcade Only\n(2 Hearts)",
				Banner = THEME:GetPathG("", "Common fallback banner"),
				Songs = filteredSongs
				}
			)
		else end
		
		-- "Remix" filter
		-- grabs all the songs from current playlist
		local filteredSongs = playlists[i]
		-- filters the playlist allowing only Short Cuts
		filteredSongs = FilterSongs_POI(filteredSongs, "Remixes")
		-- if and only if the filtered result has any matches, create a subgroup with those filtered songs
		if #filteredSongs > 0 then
			table.insert(MasterGroupsList[i].SubGroups, #(MasterGroupsList[i].SubGroups) + 1, {
				Name = playlistNames[i] .. "\n\n\nRemix Only\n(3 Hearts)",
				Banner = THEME:GetPathG("", "Common fallback banner"),
				Songs = filteredSongs
				}
			)
		else end
		
		-- "Full Song" filter
		-- grabs all the songs from current playlist
		local filteredSongs = playlists[i]
		-- filters the playlist allowing only Full Songs
		filteredSongs = FilterSongs_POI(filteredSongs, "Fullsongs")
		-- if and only if the filtered result has any matches, create a subgroup with those filtered songs
		if #filteredSongs > 0 then
			table.insert(MasterGroupsList[i].SubGroups, #(MasterGroupsList[i].SubGroups) + 1, {
				Name = playlistNames[i] .. "\n\n\nFull Songs Only\n(4 Hearts)",
				Banner = THEME:GetPathG("", "Common fallback banner"),
				Songs = filteredSongs
				}
			)
		else end
	end
	

--[[









	
    -- ============================================================== ALL SONGS > Hearts (1 Heart) ==============================================================
	-- grabs the Songs from current playlist
	local filteredSongs = playlist01_allsongs
	-- filters the playlist allowing only Short Cuts
	filteredSongs = FilterSongs_POI(filteredSongs, "Shortcuts")
	
	-- if the filtered result has any matches, create a subgroup with those filtered songs
	if #filteredSongs > 0 then
		table.insert(MasterGroupsList[#MasterGroupsList].SubGroups, #(MasterGroupsList[#MasterGroupsList].SubGroups) + 1, {
			Name = "All Songs\n\n\nShort Cut Only\n(1 Heart)",
			Banner = THEME:GetPathG("", "Common fallback banner"),
			Songs = filteredSongs
			}
		)
	else end
	
	-- ============================================================== ALL SONGS > Hearts (2 Hearts) ==============================================================
	-- grabs the Songs from current playlist
	local filteredSongs = playlist01_allsongs
	-- filters the playlist allowing only Arcades
	filteredSongs = FilterSongs_POI(filteredSongs, "Arcades")
	
	-- if the filtered result has any matches, create a subgroup with those filtered songs
	if #filteredSongs > 0 then
		table.insert(MasterGroupsList[#MasterGroupsList].SubGroups, #(MasterGroupsList[#MasterGroupsList].SubGroups) + 1, {
			Name = "All Songs\n\n\nArcade Only\n(2 Hearts)",
			Banner = THEME:GetPathG("", "Common fallback banner"),
			Songs = filteredSongs
			}
		)
	else end
	
	-- ============================================================== ALL SONGS > Hearts (3 Hearts) ==============================================================
	-- grabs the Songs from current playlist
	local filteredSongs = playlist01_allsongs
	-- filters the playlist allowing only Remixes
	filteredSongs = FilterSongs_POI(filteredSongs, "Remixes")
	
	-- if the filtered result has any matches, create a subgroup with those filtered songs
	if #filteredSongs > 0 then
		table.insert(MasterGroupsList[#MasterGroupsList].SubGroups, #(MasterGroupsList[#MasterGroupsList].SubGroups) + 1, {
			Name = "All Songs\n\n\nRemix Only\n(3 Hearts)",
			Banner = THEME:GetPathG("", "Common fallback banner"),
			Songs = filteredSongs
			}
		)
	else end
	
	-- ============================================================== ALL SONGS > Hearts (4 Hearts) ==============================================================
	-- grabs the Songs from current playlist
	local filteredSongs = playlist01_allsongs
	-- filters the playlist allowing only Full Songs
	filteredSongs = FilterSongs_POI(filteredSongs, "Fullsongs")
	
	-- if the filtered result has any matches, create a subgroup with those filtered songs
	if #filteredSongs > 0 then
		table.insert(MasterGroupsList[#MasterGroupsList].SubGroups, #(MasterGroupsList[#MasterGroupsList].SubGroups) + 1, {
			Name = "All Songs\n\n\nFull Songs Only\n(4 Hearts)",
			Banner = THEME:GetPathG("", "Common fallback banner"),
			Songs = filteredSongs
			}
		)
	else end
	

	
	-- ============================================================== The 1st DF > All Tunes ==============================================================
	-- grabs all the Songs related to this playlist
	local playlist02_allsongs = GetArrayOfSongsBasedOnExperience("The 1st DF")
	
	table.insert(MasterGroupsList[#MasterGroupsList].SubGroups, #(MasterGroupsList[#MasterGroupsList].SubGroups) + 1, {
		Name = "PIU \"The 1st DF\"\n\n\nAll Tunes",
		Banner = THEME:GetPathG("", "Common fallback banner"),
		Songs = playlist02_allsongs
		}
	)
	
    -- ============================================================== The 1st DF > Hearts (1 Heart) ==============================================================
	-- grabs the Songs from current playlist
	local filteredSongs = playlist02_allsongs
	-- filters the playlist allowing only Short Cuts
	filteredSongs = FilterSongs_POI(filteredSongs, "Shortcuts")
	
	-- if the filtered result has any matches, create a subgroup with those filtered songs
	if #filteredSongs > 0 then
		table.insert(MasterGroupsList[#MasterGroupsList].SubGroups, #(MasterGroupsList[#MasterGroupsList].SubGroups) + 1, {
			Name = "PIU \"The 1st DF\"\n\n\nShort Cut Only\n(1 Heart)",
			Banner = THEME:GetPathG("", "Common fallback banner"),
			Songs = filteredSongs
			}
		)
	else end
	
	-- ============================================================== The 1st DF > Hearts (2 Hearts) ==============================================================
	-- grabs the Songs from current playlist
	local filteredSongs = playlist02_allsongs
	-- filters the playlist allowing only Arcades
	filteredSongs = FilterSongs_POI(filteredSongs, "Arcades")
	
	-- if the filtered result has any matches, create a subgroup with those filtered songs
	if #filteredSongs > 0 then
		table.insert(MasterGroupsList[#MasterGroupsList].SubGroups, #(MasterGroupsList[#MasterGroupsList].SubGroups) + 1, {
			Name = "PIU \"The 1st DF\"\n\n\nArcade Only\n(2 Hearts)",
			Banner = THEME:GetPathG("", "Common fallback banner"),
			Songs = filteredSongs
			}
		)
	else end
	
	-- ============================================================== The 1st DF > Hearts (3 Hearts) ==============================================================
	-- grabs the Songs from current playlist
	local filteredSongs = playlist02_allsongs
	-- filters the playlist allowing only Remixes
	filteredSongs = FilterSongs_POI(filteredSongs, "Remixes")
	
	-- if the filtered result has any matches, create a subgroup with those filtered songs
	if #filteredSongs > 0 then
		table.insert(MasterGroupsList[#MasterGroupsList].SubGroups, #(MasterGroupsList[#MasterGroupsList].SubGroups) + 1, {
			Name = "PIU \"The 1st DF\"\n\n\nRemix Only\n(3 Hearts)",
			Banner = THEME:GetPathG("", "Common fallback banner"),
			Songs = filteredSongs
			}
		)
	else end
	
	-- ============================================================== The 1st DF > Hearts (4 Hearts) ==============================================================
	-- grabs the Songs from current playlist
	local filteredSongs = playlist02_allsongs
	-- filters the playlist allowing only Full Songs
	filteredSongs = FilterSongs_POI(filteredSongs, "Fullsongs")
	
	-- if the filtered result has any matches, create a subgroup with those filtered songs
	if #filteredSongs > 0 then
		table.insert(MasterGroupsList[#MasterGroupsList].SubGroups, #(MasterGroupsList[#MasterGroupsList].SubGroups) + 1, {
			Name = "PIU \"The 1st DF\"\n\n\nFull Songs Only\n(4 Hearts)",
			Banner = THEME:GetPathG("", "Common fallback banner"),
			Songs = filteredSongs
			}
		)
	else end
	
	
	
	
	
	
	
	
	
	
	
	
	
	-- ============================================================== PLAYLISTS > PIU "The 2nd DF" Experience ==============================================================
	whichExperienceIsIt = "PIU \"The 2nd DF\"\n\n\nAll Tunes"
	filteredSongs = GetArrayOfSongsBasedOnExperience(whichExperienceIsIt)
	if #filteredSongs > 0 then
		table.insert(MasterGroupsList[#MasterGroupsList].SubGroups, #(MasterGroupsList[#MasterGroupsList].SubGroups) + 1, {
			Name = whichExperienceIsIt,
			Banner = THEME:GetPathG("", "Common fallback banner"),
			Songs = filteredSongs
			}
		)
	else end
	
	-- ============================================================== PLAYLISTS > PIU "O.B.G The 3rd" Experience ==============================================================
	whichExperienceIsIt = "PIU \"O.B.G The 3rd\"\n\n\nAll Tunes"
	filteredSongs = GetArrayOfSongsBasedOnExperience(whichExperienceIsIt)
	if #filteredSongs > 0 then
		table.insert(MasterGroupsList[#MasterGroupsList].SubGroups, #(MasterGroupsList[#MasterGroupsList].SubGroups) + 1, {
			Name = whichExperienceIsIt,
			Banner = THEME:GetPathG("", "Common fallback banner"),
			Songs = filteredSongs
			}
		)
	else end
	

	
	-- ================================================================================================== HEARTS ==================================================================================================
	MasterGroupsList[#MasterGroupsList + 1] = {
		Name = "Hearts",
		Banner = THEME:GetPathG("", "Common fallback banner"),
		SubGroups = {}
    }
	-- ============================================================== HEARTS > Short Cut Songs (1 Hearts) ==============================================================	
	local filteredSongs = FilterSongs_POI(AllSongs, "Shortcuts")
		
	if #filteredSongs > 0 then
		table.insert(MasterGroupsList[#MasterGroupsList].SubGroups, #(MasterGroupsList[#MasterGroupsList].SubGroups) + 1, {
			Name = "Short Cut Songs\n(1 Hearts)",
			Banner = THEME:GetPathG("", "Common fallback banner"),
			Songs = filteredSongs
			}
		)
	else end
	
	-- ============================================================== HEARTS > Arcade Songs (2 Hearts) ==============================================================	
	local filteredSongs = FilterSongs_POI(AllSongs, "Arcades")
	
	if #filteredSongs > 0 then
		table.insert(MasterGroupsList[#MasterGroupsList].SubGroups, #(MasterGroupsList[#MasterGroupsList].SubGroups) + 1, {
			Name = "Arcade Songs\n(2 Hearts)",
			Banner = THEME:GetPathG("", "Common fallback banner"),
			Songs = filteredSongs
			}
		)
	else end
	
	-- ============================================================== HEARTS > Remix Songs (3 Hearts) ==============================================================
	local filteredSongs = FilterSongs_POI(AllSongs, "Remixes")
	
	if #filteredSongs > 0 then
		table.insert(MasterGroupsList[#MasterGroupsList].SubGroups, #(MasterGroupsList[#MasterGroupsList].SubGroups) + 1, {
			Name = "Remix Songs\n(3 Hearts)",
			Banner = THEME:GetPathG("", "Common fallback banner"),
			Songs = filteredSongs
			}
		)
	else end

	-- ============================================================== HEARTS > Full Songs (4 Hearts) ==============================================================
	local filteredSongs = FilterSongs_POI(AllSongs, "Fullsongs")

	if #filteredSongs > 0 then
		table.insert(MasterGroupsList[#MasterGroupsList].SubGroups, #(MasterGroupsList[#MasterGroupsList].SubGroups) + 1, {
			Name = "Full Songs\n(4 Hearts)",
			Banner = THEME:GetPathG("", "Common fallback banner"),
			Songs = filteredSongs
			}
		)
	else end
	
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