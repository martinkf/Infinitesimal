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

function CustomFolderOrderPOI(inputArrayOfSongs)
	-- returns AN ARRAY OF SONGS (ORDERED BY THE DEFAULT POI ORDER)
	local output = inputArrayOfSongs
	local customOrder = {
		"101 - IGNITION STARTS","102 - HYPNOSIS","103 - FOREVER LOVE","104 - PASSION","105 - BLACK CAT","106 - POM POM POM","107 - THE RAP","108 - COME TO ME","109 - FUNKY TONIGHT","110 - WHAT DO U REALLY WANT",
		"111 - HATRED","112 - ANOTHER TRUTH","113 - I WANT U","114 - I DON'T KNOW ANYTHING","115 - NO PARTICULAR REASON","201 - CREAMY SKINNY","202 - HATE","203 - KOUL","204 - FINAL AUDITION","205 - EXTRAVAGANZA",
		"206 - REWIND","207 - I-YAH","208 - FIGHTING SPIRITS","210 - LOVE","211 - PLEASE","212 - COM'BACK","213 - MOBIUS STRIP","214 - FEVER","215 - CURIOSITY","216 - LOVE","217 - TELL ME TELL ME","218 - HEART BREAK",
		"301 - FINAL AUDITION 2","302 - NAISSANCE","303 - TURKEY MARCH","304 - WITH MY LOVER","305 - AN INTERESTING VIEW","306 - NIGHTMARE","307 - CLOSE YOUR EYES","308 - FREE STYLE","309 - MIDNIGHT BLUE","310 - SHE LIKES PIZZA",
		"311 - PUMPING UP","312 - DON'T BOTHER ME","313 - LOVE SONG","314 - LOVER'S GRIEF","315 - TO THE TOP","316 - SEPARATION WITH HER","317 - PUYO PUYO","318 - WE ARE","319 - TIME TO SAY GOODBYE","320 - TELL ME",
		"321 - OK OK (BEAUTY AND THE BEAST)","401 - OH! ROSA","A26 - OH! ROSA (SPANISH VER.)","402 - FIRST LOVE","A27 - FIRST LOVE (SPANISH VER.)","403 - BETRAYER","404 - SOLITARY","405 - MR. LARPUS","406 - SAD SALSA",
		"407 - SUMMER OF LOVE","408 - KISS","409 - MAN & WOMAN","410 - FIRST LOVE","411 - A TRAP","412 - DISCO BUS","413 - RUN!","414 - RUN TO YOU","501 - PUMP JUMP","502 - N","503 - ROLLING CHRISTMAS","504 - ALL I WANT FOR X-MAS",
		"505 - BEETHOVEN VIRUS","506 - I WILL ACCEPT YOU","507 - COME BACK TO ME","508 - AS I TOLD YOU","509 - I KNOW","510 - MY FANTASY","511 - UNFORGETTABLE MEMORY","512 - HAYUGA","513 - CERTAIN VICTORY","514 - ULTRAMANIA",
		"515 - BONACCIA","516 - SLAM","517 - SPACE FANTASY","922 - FINAL AUDITION EPISODE 1","911 - CHICKEN WING","912 - HOLIDAY","913 - RADEZKY CAN CAN","901 - FLOWER OF NIGHT","902 - CIRCUS MAGIC","903 - MOVE YOUR HEAD","904 - TRASH MAN",
		"919 - LAZENCA, SAVE US","905 - FUNKY JOCKEY","906 - STARIAN","907 - BIG MONEY","908 - WAYO WAYO","909 - MISTAKE","910 - THE RAP ACT 3","914 - WISH YOU COULD FIND","915 - LONER","916 - MONKEY MAGIC","917 - OUT OF THE RING",
		"921 - PIERROT","918 - BLIND FAITH","920 - FERRY BOAT","923 - FIRST LOVE (TECHNO MIX)","601 - OOPS I DID IT AGAIN","602 - BYE BYE BYE","603 - I NEED TO KNOW","604 - LET'S GET LOUD","605 - MAMBO #5","606 - TAKE ON ME",
		"611 - A CERCA","612 - DE VOLTA AO PLANETA","616 - SEMPRE ASSIM","613 - PENSAMENTO","614 - POPOZUDA ROCK N' ROLL","615 - REBOLA NA BOA","617 - UMA BOMBA","618 - VAQUEIRO BOM DEMAIS","735 - VOOK","736 - CSIKOS POST","701 - DR. M",
		"702 - EMPEROR","703 - GET YOUR GROOVE ON","704 - LOVE IS A DANGER ZONE","705 - MARIA","706 - MISSION POSSIBLE","707 - MY WAY","708 - POINT BREAK","709 - STREET SHOW DOWN","710 - TOP CITY","711 - WINTER","712 - WILL O' THE WISP",
		"713 - TILL THE END OF TIME","714 - OY OY OY","715 - WE WILL MEET AGAIN","716 - MISS'S STORY","717 - SET ME UP","718 - DANCE WITH ME","719 - GO AWAY","726 - RUNAWAY","720 - I LOVE YOU","721 - GOTTA BE KIDDING!","722 - ZZANGA",
		"729 - Y","723 - A PRISON WITHOUT BARS","727 - SWING BABY","724 - A WHISTLE","725 - GENTLEMAN QUALITY","728 - TEMPTATION","730 - PERFECT","731 - LET'S BOOGIE","732 - MY BEST DAY IS GONE","733 - THE WAVES","734 - ALWAYS",
		"802 - BEE","807 - D GANG","811 - HELLO","820 - BEAT OF THE WAR","803 - BURNING KRYPT","804 - CAN YOU FEEL DIS OR DAT","808 - DJ NIGHTMARE","819 - YOU DON'T WANNA RUNUP","801 - BAMBOLE","805 - CLAP YOUR HANDS","806 - CONGA",
		"809 - ERES PARA MI","818 - MEXI MEXI","810 - FIEST A MACARENA PT. 1","812 - ON YOUR SIDE","813 - EVERYBODY","814 - JOIN THE PARTY","815 - LAY IT DOWN","816 - LET THE SUNSHINE","817 - LOVETHING","826 - COME TO ME",
		"821 - EMPIRE OF THE SUN","823 - LET'S GET THE PARTY STARTED","828 - MASTER OF PUPPETS","822 - JUST A GIRL","824 - OBJECTION","825 - IT'S MY PARTY","827 - MUSIC","A01 - FINAL AUDITION 3 U.F","A02 - NAISSANCE 2","A03 - MONKEY FINGERS",
		"A04 - BLAZING","A05 - PUMP ME AMADEUS","A06 - X-TREAM","A07 - GET UP!","A08 - DIGNITY","B51 - DIGNITY -FULL SONG-","A11 - WHAT DO U REALLY WANT","A09 - SHAKE THAT BOOTIE","A10 - VALENTI","A12 - GO","A13 - FLAMENCO","A19 - ONE LOVE",
		"A14 - KISS ME","A15 - ESSA MANEIRA","A16 - BA BEE LOO BE RA","A17 - LA CUBANITA","A18 - SHAKE IT UP","A20 - POWER OF DREAM","A21 - WATCH OUT","A22 - FIESTA","A23 - SOCA MAKE YUH RAM RAM","A24 - BORN TO BE ALIVE","A25 - XIBOM BOMBOM",
		"AE01 - A LITTLE LESS CONVERSATION","AE03 - LET'S GROOVE","AE04 - NAME OF THE GAME","AE05 - RAPPER'S DELIGHT","AE06 - WALKIE TALKIE MAN","B16 - J BONG","B17 - HI-BI","B18 - SOLITARY 2","B19 - CANON-D","B57 - CANON-D -FULL SONG-",
		"B01 - GREENHORN","B02 - HOT","B03 - PRAY","B06 - DEJA VU","B04 - GO AWAY","B05 - DRUNKEN IN MELODY","B07 - U","B08 - SAJAHU (LION'S ROAR)","B09 - TYPHOON","B10 - ETERNITY","B11 - FOXY LADY","B12 - TOO LATE","B13 - I'LL GIVE YOU ALL MY LOVE",
		"B14 - HUU YAH YEAH","B15 - WE DON'T STOP","B20 - LE CODE DE BONNE CONDUITE",
		"116 - -REMIX- 1ST DIVA REMIX","117 - -REMIX- 1ST DISCO REMIX","118 - -REMIX- 1ST TECHNO REMIX","119 - -REMIX- TURBO REMIX","120 - -REMIX- 1ST BATTLE HIP-HOP","121 - -REMIX- 1ST BATTLE DISCO","122 - -REMIX- 1ST BATTLE TECHNO",
		"123 - -REMIX- 1ST BATTLE HARDCORE","219 - -REMIX- JO SUNG MO REMIX","220 - -REMIX- UHM JUNG HWA REMIX","221 - -REMIX- DRUNKEN FAMILY REMIX","223 - -REMIX- SM TOWN REMIX","224 - -REMIX- REPEATORMENT REMIX",
		"225 - -REMIX- 2ND HIDDEN REMIX","322 - -REMIX- 3RD O.B.G DIVA REMIX","323 - -REMIX- PARK MEE KYUNG REMIX","324 - -REMIX- BANYA HIP-HOP REMIX","325 - -REMIX- PARK JIN YOUNG REMIX","326 - -REMIX- NOVASONIC REMIX",
		"327 - -REMIX- BANYA HARD REMIX","415 - -REMIX- SECHSKIES REMIX","924 - -REMIX- EXTRA HIP-HOP REMIX","925 - -REMIX- E-PAK-SA REMIX","926 - -REMIX- EXTRA DISCO REMIX","927 - -REMIX- EXTRA DEUX REMIX","928 - -REMIX- EXTRA BANYA MIX",
		"B26 - -REMIX- NOVARASH REMIX","B27 - -REMIX- LEXY & 1TYM REMIX","B28 - -REMIX- TREAM-VOOK OF THE WAR","B29 - -REMIX- BANYA CLASSIC REMIX","B30 - -REMIX- DEUX REMIX","B31 - -REMIX- DIVA REMIX","B50 - -REMIX- THE WORLD REMIX",
		"1059 - EXCEED 2 OPENING -SHORT CUT-",
	}	
	local reorderedSongs = {}	
	-- Iterate through each ordered element
	for _, folderNameToMatch in ipairs(customOrder) do
		-- Iterate through the songs provided by input
		for _, song in ipairs(inputArrayOfSongs) do
			-- Extract the folder name from the song's directory
			local folderName = song:GetSongDir()
			-- Check if the folder name matches the current folder name to match
			if string.find(folderName, folderNameToMatch, 1, true) then
				-- Add the song to the filtered array
				table.insert(reorderedSongs, song)
			end
		end
	end	
	output = reorderedSongs
	return output
end

function ReturnOnly_ArcadePOI(inputArrayOfSongs)
	-- returns AN ARRAY OF SONGS (ORDERED BY THE DEFAULT POI ORDER, FILTERED TO THE ARCADE SONGS ONLY (2 HEARTS))
	local output = inputArrayOfSongs
	local customOrder = {
		"101 - IGNITION STARTS","102 - HYPNOSIS","103 - FOREVER LOVE","104 - PASSION","105 - BLACK CAT","106 - POM POM POM","107 - THE RAP","108 - COME TO ME","109 - FUNKY TONIGHT","110 - WHAT DO U REALLY WANT",
		"111 - HATRED","112 - ANOTHER TRUTH","113 - I WANT U","114 - I DON'T KNOW ANYTHING","115 - NO PARTICULAR REASON","201 - CREAMY SKINNY","202 - HATE","203 - KOUL","204 - FINAL AUDITION","205 - EXTRAVAGANZA",
		"206 - REWIND","207 - I-YAH","208 - FIGHTING SPIRITS","210 - LOVE","211 - PLEASE","212 - COM'BACK","213 - MOBIUS STRIP","214 - FEVER","215 - CURIOSITY","216 - LOVE","217 - TELL ME TELL ME","218 - HEART BREAK",
		"301 - FINAL AUDITION 2","302 - NAISSANCE","303 - TURKEY MARCH","304 - WITH MY LOVER","305 - AN INTERESTING VIEW","306 - NIGHTMARE","307 - CLOSE YOUR EYES","308 - FREE STYLE","309 - MIDNIGHT BLUE","310 - SHE LIKES PIZZA",
		"311 - PUMPING UP","312 - DON'T BOTHER ME","313 - LOVE SONG","314 - LOVER'S GRIEF","315 - TO THE TOP","316 - SEPARATION WITH HER","317 - PUYO PUYO","318 - WE ARE","319 - TIME TO SAY GOODBYE","320 - TELL ME",
		"321 - OK OK (BEAUTY AND THE BEAST)","401 - OH! ROSA","A26 - OH! ROSA (SPANISH VER.)","402 - FIRST LOVE","A27 - FIRST LOVE (SPANISH VER.)","403 - BETRAYER","404 - SOLITARY","405 - MR. LARPUS","406 - SAD SALSA",
		"407 - SUMMER OF LOVE","408 - KISS","409 - MAN & WOMAN","410 - FIRST LOVE","411 - A TRAP","412 - DISCO BUS","413 - RUN!","414 - RUN TO YOU","501 - PUMP JUMP","502 - N","503 - ROLLING CHRISTMAS","504 - ALL I WANT FOR X-MAS",
		"505 - BEETHOVEN VIRUS","506 - I WILL ACCEPT YOU","507 - COME BACK TO ME","508 - AS I TOLD YOU","509 - I KNOW","510 - MY FANTASY","511 - UNFORGETTABLE MEMORY","512 - HAYUGA","513 - CERTAIN VICTORY","514 - ULTRAMANIA",
		"515 - BONACCIA","516 - SLAM","517 - SPACE FANTASY","922 - FINAL AUDITION EPISODE 1","911 - CHICKEN WING","912 - HOLIDAY","913 - RADEZKY CAN CAN","901 - FLOWER OF NIGHT","902 - CIRCUS MAGIC","903 - MOVE YOUR HEAD","904 - TRASH MAN",
		"919 - LAZENCA, SAVE US","905 - FUNKY JOCKEY","906 - STARIAN","907 - BIG MONEY","908 - WAYO WAYO","909 - MISTAKE","910 - THE RAP ACT 3","914 - WISH YOU COULD FIND","915 - LONER","916 - MONKEY MAGIC","917 - OUT OF THE RING",
		"921 - PIERROT","918 - BLIND FAITH","920 - FERRY BOAT","923 - FIRST LOVE (TECHNO MIX)","601 - OOPS I DID IT AGAIN","602 - BYE BYE BYE","603 - I NEED TO KNOW","604 - LET'S GET LOUD","605 - MAMBO #5","606 - TAKE ON ME",
		"611 - A CERCA","612 - DE VOLTA AO PLANETA","616 - SEMPRE ASSIM","613 - PENSAMENTO","614 - POPOZUDA ROCK N' ROLL","615 - REBOLA NA BOA","617 - UMA BOMBA","618 - VAQUEIRO BOM DEMAIS","735 - VOOK","736 - CSIKOS POST","701 - DR. M",
		"702 - EMPEROR","703 - GET YOUR GROOVE ON","704 - LOVE IS A DANGER ZONE","705 - MARIA","706 - MISSION POSSIBLE","707 - MY WAY","708 - POINT BREAK","709 - STREET SHOW DOWN","710 - TOP CITY","711 - WINTER","712 - WILL O' THE WISP",
		"713 - TILL THE END OF TIME","714 - OY OY OY","715 - WE WILL MEET AGAIN","716 - MISS'S STORY","717 - SET ME UP","718 - DANCE WITH ME","719 - GO AWAY","726 - RUNAWAY","720 - I LOVE YOU","721 - GOTTA BE KIDDING!","722 - ZZANGA",
		"729 - Y","723 - A PRISON WITHOUT BARS","727 - SWING BABY","724 - A WHISTLE","725 - GENTLEMAN QUALITY","728 - TEMPTATION","730 - PERFECT","731 - LET'S BOOGIE","732 - MY BEST DAY IS GONE","733 - THE WAVES","734 - ALWAYS",
		"802 - BEE","807 - D GANG","811 - HELLO","820 - BEAT OF THE WAR","803 - BURNING KRYPT","804 - CAN YOU FEEL DIS OR DAT","808 - DJ NIGHTMARE","819 - YOU DON'T WANNA RUNUP","801 - BAMBOLE","805 - CLAP YOUR HANDS","806 - CONGA",
		"809 - ERES PARA MI","818 - MEXI MEXI","810 - FIEST A MACARENA PT. 1","812 - ON YOUR SIDE","813 - EVERYBODY","814 - JOIN THE PARTY","815 - LAY IT DOWN","816 - LET THE SUNSHINE","817 - LOVETHING","826 - COME TO ME",
		"821 - EMPIRE OF THE SUN","823 - LET'S GET THE PARTY STARTED","828 - MASTER OF PUPPETS","822 - JUST A GIRL","824 - OBJECTION","825 - IT'S MY PARTY","827 - MUSIC","A01 - FINAL AUDITION 3 U.F","A02 - NAISSANCE 2","A03 - MONKEY FINGERS",
		"A04 - BLAZING","A05 - PUMP ME AMADEUS","A06 - X-TREAM","A07 - GET UP!","A08 - DIGNITY","A11 - WHAT DO U REALLY WANT","A09 - SHAKE THAT BOOTIE","A10 - VALENTI","A12 - GO","A13 - FLAMENCO","A19 - ONE LOVE",
		"A14 - KISS ME","A15 - ESSA MANEIRA","A16 - BA BEE LOO BE RA","A17 - LA CUBANITA","A18 - SHAKE IT UP","A20 - POWER OF DREAM","A21 - WATCH OUT","A22 - FIESTA","A23 - SOCA MAKE YUH RAM RAM","A24 - BORN TO BE ALIVE","A25 - XIBOM BOMBOM",
		"AE01 - A LITTLE LESS CONVERSATION","AE03 - LET'S GROOVE","AE04 - NAME OF THE GAME","AE05 - RAPPER'S DELIGHT","AE06 - WALKIE TALKIE MAN","B16 - J BONG","B17 - HI-BI","B18 - SOLITARY 2","B19 - CANON-D",
		"B01 - GREENHORN","B02 - HOT","B03 - PRAY","B06 - DEJA VU","B04 - GO AWAY","B05 - DRUNKEN IN MELODY","B07 - U","B08 - SAJAHU (LION'S ROAR)","B09 - TYPHOON","B10 - ETERNITY","B11 - FOXY LADY","B12 - TOO LATE","B13 - I'LL GIVE YOU ALL MY LOVE",
		"B14 - HUU YAH YEAH","B15 - WE DON'T STOP","B20 - LE CODE DE BONNE CONDUITE",
	}	
	local reorderedSongs = {}	
	-- Iterate through each ordered element
	for _, folderNameToMatch in ipairs(customOrder) do
		-- Iterate through the songs provided by input
		for _, song in ipairs(inputArrayOfSongs) do
			-- Extract the folder name from the song's directory
			local folderName = song:GetSongDir()
			-- Check if the folder name matches the current folder name to match
			if string.find(folderName, folderNameToMatch, 1, true) then
				-- Add the song to the filtered array
				table.insert(reorderedSongs, song)
			end
		end
	end	
	output = reorderedSongs
	return output
end

function ReturnOnly_RemixPOI(inputArrayOfSongs)
	-- returns AN ARRAY OF SONGS (ORDERED BY THE DEFAULT POI ORDER, FILTERED TO THE REMIX SONGS ONLY (3 HEARTS))
	local output = inputArrayOfSongs
	local customOrder = {
		"116 - -REMIX- 1ST DIVA REMIX","117 - -REMIX- 1ST DISCO REMIX","118 - -REMIX- 1ST TECHNO REMIX","119 - -REMIX- TURBO REMIX","120 - -REMIX- 1ST BATTLE HIP-HOP","121 - -REMIX- 1ST BATTLE DISCO","122 - -REMIX- 1ST BATTLE TECHNO",
		"123 - -REMIX- 1ST BATTLE HARDCORE","219 - -REMIX- JO SUNG MO REMIX","220 - -REMIX- UHM JUNG HWA REMIX","221 - -REMIX- DRUNKEN FAMILY REMIX","223 - -REMIX- SM TOWN REMIX","224 - -REMIX- REPEATORMENT REMIX",
		"225 - -REMIX- 2ND HIDDEN REMIX","322 - -REMIX- 3RD O.B.G DIVA REMIX","323 - -REMIX- PARK MEE KYUNG REMIX","324 - -REMIX- BANYA HIP-HOP REMIX","325 - -REMIX- PARK JIN YOUNG REMIX","326 - -REMIX- NOVASONIC REMIX",
		"327 - -REMIX- BANYA HARD REMIX","415 - -REMIX- SECHSKIES REMIX","924 - -REMIX- EXTRA HIP-HOP REMIX","925 - -REMIX- E-PAK-SA REMIX","926 - -REMIX- EXTRA DISCO REMIX","927 - -REMIX- EXTRA DEUX REMIX","928 - -REMIX- EXTRA BANYA MIX",
		"B26 - -REMIX- NOVARASH REMIX","B27 - -REMIX- LEXY & 1TYM REMIX","B28 - -REMIX- TREAM-VOOK OF THE WAR","B29 - -REMIX- BANYA CLASSIC REMIX","B30 - -REMIX- DEUX REMIX","B31 - -REMIX- DIVA REMIX","B50 - -REMIX- THE WORLD REMIX",
	}	
	local reorderedSongs = {}	
	-- Iterate through each ordered element
	for _, folderNameToMatch in ipairs(customOrder) do
		-- Iterate through the songs provided by input
		for _, song in ipairs(inputArrayOfSongs) do
			-- Extract the folder name from the song's directory
			local folderName = song:GetSongDir()
			-- Check if the folder name matches the current folder name to match
			if string.find(folderName, folderNameToMatch, 1, true) then
				-- Add the song to the filtered array
				table.insert(reorderedSongs, song)
			end
		end
	end	
	output = reorderedSongs
	return output
end

function ReturnOnly_FullsongPOI(inputArrayOfSongs)
	-- returns AN ARRAY OF SONGS (ORDERED BY THE DEFAULT POI ORDER, FILTERED TO THE FULL SONGS ONLY (4 HEARTS))
	local output = inputArrayOfSongs
	local customOrder = {
		"B51 - DIGNITY -FULL SONG-","B57 - CANON-D -FULL SONG-",
	}
	local reorderedSongs = {}	
	-- Iterate through each ordered element
	for _, folderNameToMatch in ipairs(customOrder) do
		-- Iterate through the songs provided by input
		for _, song in ipairs(inputArrayOfSongs) do
			-- Extract the folder name from the song's directory
			local folderName = song:GetSongDir()
			-- Check if the folder name matches the current folder name to match
			if string.find(folderName, folderNameToMatch, 1, true) then
				-- Add the song to the filtered array
				table.insert(reorderedSongs, song)
			end
		end
	end	
	output = reorderedSongs
	return output
end

function ReturnOnly_ShortcutPOI(inputArrayOfSongs)
	-- returns AN ARRAY OF SONGS (ORDERED BY THE DEFAULT POI ORDER, FILTERED TO THE SHORT CUT SONGS ONLY (1 HEARTS))
	local output = inputArrayOfSongs
	local customOrder = {
		"1059 - EXCEED 2 OPENING -SHORT CUT-",
	}
	local reorderedSongs = {}	
	-- Iterate through each ordered element
	for _, folderNameToMatch in ipairs(customOrder) do
		-- Iterate through the songs provided by input
		for _, song in ipairs(inputArrayOfSongs) do
			-- Extract the folder name from the song's directory
			local folderName = song:GetSongDir()
			-- Check if the folder name matches the current folder name to match
			if string.find(folderName, folderNameToMatch, 1, true) then
				-- Add the song to the filtered array
				table.insert(reorderedSongs, song)
			end
		end
	end	
	output = reorderedSongs
	return output
end

function AssembleGroupSorting_POI()
    Trace("Creating group sorts...")
    
	if not (SONGMAN and GAMESTATE) then
        Warn("SONGMAN or GAMESTATE were not ready! Aborting!")
        return
    end
	
	-- Empty current table
	MasterGroupsList = {}
    GroupsList = {}
    
	-- ======================================== MAIN ========================================
    -- ======================================== MAIN / All songs ========================================
    local AllSongs = SONGMAN:GetAllSongs()
    
	local orderedSongs = CustomFolderOrderPOI(AllSongs)
	
    MasterGroupsList[#MasterGroupsList + 1] = {
        Name = "Main",
        Banner = THEME:GetPathG("", "Common fallback banner"),
        SubGroups = {
            {   
                Name = "All Tunes",
                Banner = THEME:GetPathG("", "Common fallback banner"),
                Songs = orderedSongs
            }
        }
    }
    
    Trace("Group added: " .. MasterGroupsList[#MasterGroupsList].Name .. "/" .. 
    MasterGroupsList[#MasterGroupsList].SubGroups[#MasterGroupsList[#MasterGroupsList].SubGroups].Name  .. " - " .. 
    #MasterGroupsList[#MasterGroupsList].SubGroups[#MasterGroupsList[#MasterGroupsList].SubGroups].Songs .. " songs")
    
	-- ======================================== MAIN / Only "Short Cut" songs (1 Hearts) ========================================
	local AllSongs = SONGMAN:GetAllSongs()
	local filteredSongs = ReturnOnly_ShortcutPOI(AllSongs)
	
	-- Create the new subgroup if there are matching songs
	if #filteredSongs > 0 then
		local shortcutOnly = {
			Name = "Short Cut Songs\n(1 Hearts)",
			Banner = THEME:GetPathG("", "Common fallback banner"),
			Songs = filteredSongs
		}

		-- Insert the new subgroup into the "Main" group
		table.insert(MasterGroupsList[#MasterGroupsList].SubGroups, 2, shortcutOnly)
	else
		Warn("No songs found in 'Short Cut Songs (1 Hearts)' subgroup. Not adding it to the Main group.")
	end
	
	-- ======================================== MAIN / Only "Arcade" songs (2 Hearts) ========================================
	local AllSongs = SONGMAN:GetAllSongs()
	local filteredSongs = ReturnOnly_ArcadePOI(AllSongs)
	
	-- Create the new subgroup if there are matching songs
	if #filteredSongs > 0 then
		local arcadeOnly = {
			Name = "Arcade Songs\n(2 Hearts)",
			Banner = THEME:GetPathG("", "Common fallback banner"),
			Songs = filteredSongs
		}

		-- Insert the new subgroup into the "Main" group
		table.insert(MasterGroupsList[#MasterGroupsList].SubGroups, 3, arcadeOnly)
	else
		Warn("No songs found in 'Arcade Songs (2 Hearts)' subgroup. Not adding it to the Main group.")
	end
	
	-- ======================================== MAIN / Only "Remix" songs (3 Hearts) ========================================
	local AllSongs = SONGMAN:GetAllSongs()
	local filteredSongs = ReturnOnly_RemixPOI(AllSongs)
	
	-- Create the new subgroup if there are matching songs
	if #filteredSongs > 0 then
		local remixOnly = {
			Name = "Remix Songs\n(3 Hearts)",
			Banner = THEME:GetPathG("", "Common fallback banner"),
			Songs = filteredSongs
		}

		-- Insert the new subgroup into the "Main" group
		table.insert(MasterGroupsList[#MasterGroupsList].SubGroups, 4, remixOnly)
	else
		Warn("No songs found in 'Remix Songs (3 Hearts)' subgroup. Not adding it to the Main group.")
	end
	
	-- ======================================== MAIN / Only "Full Songs" songs (4 Hearts) ========================================
	local AllSongs = SONGMAN:GetAllSongs()
	local filteredSongs = ReturnOnly_FullsongPOI(AllSongs)
	
	-- Create the new subgroup if there are matching songs
	if #filteredSongs > 0 then
		local fullsongOnly = {
			Name = "Full Songs\n(4 Hearts)",
			Banner = THEME:GetPathG("", "Common fallback banner"),
			Songs = filteredSongs
		}

		-- Insert the new subgroup into the "Main" group
		table.insert(MasterGroupsList[#MasterGroupsList].SubGroups, 5, fullsongOnly)
	else
		Warn("No songs found in 'Full Songs (4 Hearts)' subgroup. Not adding it to the Main group.")
	end
	
	-- ======================================== CUSTOM GROUPS ========================================    
    -- ======================================== CUSTOM GROUPS / Custom Group 01 ========================================
	MasterGroupsList[#MasterGroupsList + 1] = {
        Name = "Custom Groups",
        Banner = THEME:GetPathG("", "Common fallback banner"),
        SubGroups = {}
    }
	
	-- Define the folder names to match
	local folderNamesToMatch = {
		"101 - IGNITION STARTS","102 - HYPNOSIS","104 - PASSION","103 - FOREVER LOVE","802 - BEE"
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

	-- Create the new subgroup if there are matching songs
	if #filteredSongs > 0 then
		local customGroup01 = {
			Name = "Custom Group 01", -- Change "Your New Subgroup" to the desired name
			Banner = THEME:GetPathG("", "Common fallback banner"),
			Songs = filteredSongs
		}

		-- Insert the new subgroup into the "Main" group
		table.insert(MasterGroupsList[#MasterGroupsList].SubGroups, 1, customGroup01)
	else
		Warn("No songs found in Custom Group 01 subgroup. Not adding it to the Main group.")
	end

	-- ======================================== FOLDERS ========================================    
	-- ======================================== FOLDERS / Each one ========================================
	local SongGroups = {}
    MasterGroupsList[#MasterGroupsList + 1] = {
        Name = "Folders",
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
	
		local sortedSongs = CustomFolderOrderPOI(SONGMAN:GetSongsInGroup(SongGroups[i]))
		MasterGroupsList[#MasterGroupsList].SubGroups[#MasterGroupsList[#MasterGroupsList].SubGroups + 1] = {
			Name = SongGroups[i],
			Banner = SONGMAN:GetSongGroupBannerPath(SongGroups[i]),
			Songs = sortedSongs
		}
        
        Trace("Group added: " .. MasterGroupsList[#MasterGroupsList].Name .. "/" .. 
        MasterGroupsList[#MasterGroupsList].SubGroups[#MasterGroupsList[#MasterGroupsList].SubGroups].Name  .. " - " .. 
        #MasterGroupsList[#MasterGroupsList].SubGroups[#MasterGroupsList[#MasterGroupsList].SubGroups].Songs .. " songs")
	end
    
    -- If nothing is available, remove the main entry completely
    if #MasterGroupsList[#MasterGroupsList].SubGroups == 0 then table.remove(MasterGroupsList) end
    
	-- ======================================== SINGLE LEVELS (TIERS) ========================================    
    -- ======================================== SINGLE LEVELS (TIERS) / Each one ========================================
    -- Initialization
	local LevelGroups = {}
	local tiersOrder = {"Tier E\n(S01~S03)", "Tier D\n(S04~S06)", "Tier C\n(S07~S10)", "Tier B\n(S11~S14)", "Tier A\n(S15~S18)", "Tier A+\n(S19~S22)", "Tier S\n(S23+)"}
	MasterGroupsList[#MasterGroupsList + 1] = {
		Name = "Single",
		Banner = THEME:GetPathG("", "Common fallback banner"),
		SubGroups = {}
	}

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
			
			Trace("Group added: " .. MasterGroupsList[#MasterGroupsList].Name .. "/" .. 
			MasterGroupsList[#MasterGroupsList].SubGroups[#MasterGroupsList[#MasterGroupsList].SubGroups].Name  .. " - " .. 
			#MasterGroupsList[#MasterGroupsList].SubGroups[#MasterGroupsList[#MasterGroupsList].SubGroups].Songs .. " songs")
		end
	end

	-- Cleanup
	if #MasterGroupsList[#MasterGroupsList].SubGroups == 0 then table.remove(MasterGroupsList) end
    
	-- ======================================== HALF-DOUBLE LEVELS (TIERS) ========================================    
    -- ======================================== HALF-DOUBLE LEVELS (TIERS) / Each one ========================================
    -- Initialization
	local LevelGroups = {}
	local tiersOrder = {"Tier E\n(HD01~HD03)", "Tier D\n(HD04~HD06)", "Tier C\n(HD07~HD10)", "Tier B\n(HD11~HD14)", "Tier A\n(HD15~HD18)", "Tier A+\n(HD19~HD22)", "Tier S\n(HD23+)"}
	MasterGroupsList[#MasterGroupsList + 1] = {
		Name = "Half-Double",
		Banner = THEME:GetPathG("", "Common fallback banner"),
		SubGroups = {}
	}

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
			
			Trace("Group added: " .. MasterGroupsList[#MasterGroupsList].Name .. "/" .. 
			MasterGroupsList[#MasterGroupsList].SubGroups[#MasterGroupsList[#MasterGroupsList].SubGroups].Name  .. " - " .. 
			#MasterGroupsList[#MasterGroupsList].SubGroups[#MasterGroupsList[#MasterGroupsList].SubGroups].Songs .. " songs")
		end
	end

	-- Cleanup
	if #MasterGroupsList[#MasterGroupsList].SubGroups == 0 then table.remove(MasterGroupsList) end
    
	-- ======================================== DOUBLE LEVELS (TIERS) ========================================    
    -- ======================================== DOUBLE LEVELS (TIERS) / Each one ========================================
    -- Initialization
	local LevelGroups = {}
	local tiersOrder = {"Tier E\n(D01~D03)", "Tier D\n(D04~D06)", "Tier C\n(D07~D10)", "Tier B\n(D11~D14)", "Tier A\n(D15~D18)", "Tier A+\n(D19~D22)", "Tier S\n(D23+)", "Special Charts"}
	MasterGroupsList[#MasterGroupsList + 1] = {
		Name = "Double",
		Banner = THEME:GetPathG("", "Common fallback banner"),
		SubGroups = {}
	}

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
	
	
	
	Trace("Group sorting created!")
end