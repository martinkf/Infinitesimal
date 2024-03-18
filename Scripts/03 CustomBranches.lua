local UseBasicMode

-- Fallback fix
Branch.TitleMenu = function()
    -- home mode is the most assumed use of sm-ssc.
    if GAMESTATE:GetCoinMode() == "CoinMode_Home" then
        return "ScreenTitleMenu"
    end
    -- arcade junk:
    if GAMESTATE:GetCoinsNeededToJoin() > GAMESTATE:GetCoins() then
        -- if no credits are inserted, don't show the Join screen. SM4 has
        -- this as the initial screen, but that means we'd be stuck in a
        -- loop with ScreenInit. No good.
        return "ScreenLogo"
    else
        return "ScreenTitleJoin"
    end
end

function SelectMusicOrCourse()
    UseBasicMode = LoadModule("Config.Load.lua")("BasicMode","Save/OutFoxPrefs.ini") or false
    
    -- Required to avoid unplayable songs and more
    UpdateGroupSorting()
    
    if GAMESTATE:IsCourseMode() then
        return "ScreenSelectCourse"
    elseif getenv("IsBasicMode") and UseBasicMode then
        return "ScreenSelectMusicBasic"
    else
        return "ScreenSelectMusicFull"
    end
end

function ToLoadOrNotToLoad()
    if GAMESTATE:IsAnyHumanPlayerUsingMemoryCard() then
        return "ScreenProfileLoad"
    else
        return SelectMusicOrCourse()
    end
end

CustomBranch = {
    StartGame = function()
        if SONGMAN:GetNumSongs() == 0 and SONGMAN:GetNumAdditionalSongs() == 0 then
            return "ScreenHowToInstallSongs"
        end
        if PROFILEMAN:GetNumLocalProfiles() > 0 then
            return "ScreenSelectProfile"
        else
            setenv("IsBasicMode", true)
            return SelectMusicOrCourse()
        end
    end,
    AfterSelectProfile = function()
        UseBasicMode = LoadModule("Config.Load.lua")("BasicMode","Save/OutFoxPrefs.ini") or false
        
        return ToLoadOrNotToLoad()
    end,
    AfterProfileSave = function()
        if GAMESTATE:IsEventMode() then
            return SelectMusicOrCourse()
        elseif STATSMAN:GetCurStageStats():AllFailed() then
            return GameOverOrContinue()
        end
        
        -- If a player has ran out of stages, unjoin them
        if GAMESTATE:GetNumStagesLeft(PLAYER_1) <= 0 then GAMESTATE:UnjoinPlayer(PLAYER_1) end
        if GAMESTATE:GetNumStagesLeft(PLAYER_2) <= 0 then GAMESTATE:UnjoinPlayer(PLAYER_2) end
        
        -- This is done so that if a player has joined mid
        -- session can still play the rest of their stages.
        if GAMESTATE:GetNumSidesJoined() <= 0 then
            return GameOverOrContinue()
        else
            return SelectMusicOrCourse()
        end
    end,

}

----
-- vvvv POI PROJECT vvvv
----

function POIBranch_AssembleGroupSorting()
	local usingPOIUX = LoadModule("Config.Load.lua")("ActivatePOIProjectUX", "Save/OutFoxPrefs.ini") or false
	if usingPOIUX then
		AssembleGroupSorting_POI()
	else
		AssembleGroupSorting()
	end
end