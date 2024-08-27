local pn = ...
local IconW = 64
local IconH = 44
local IconAmount = 6

local pnNum = (pn == PLAYER_1) and 0 or 1
local PlayerMods = GAMESTATE:GetPlayerState(pn):GetPlayerOptions("ModsLevel_Preferred")
local PlayerModsArray = GAMESTATE:GetPlayerState(pn):GetPlayerOptionsArray("ModsLevel_Preferred")

-- A list of mods we do not want to display through the icons
local PlayerModsBlacklist = {
    "Overhead",
    "FailImmediate",
    "FailImmediateContinue",
    "FailAtEnd",
    "80Percent",
    "MissCombo",
    "FailOff"
}

-- https://stackoverflow.com/a/32806646
local function removeFirst(tbl, val)
    for i, v in ipairs(tbl) do
        if ToLower(v) == ToLower(val) then
            return table.remove(tbl, i)
        end
    end
end

local t = Def.ActorFrame {
    -- Dynamic icons that will require updating at every options change
    InitCommand=function(self) self:queuecommand("Refresh") end,
    OptionsListStartMessageCommand=function(self) self:queuecommand("Refresh") end,
    RefreshCommand=function(self)
        -- Clean up the list of additional icons
        for i = 1, IconAmount do
            self:GetChild("IconFrame")[i]:GetChild("Icon"):visible(false)
            self:GetChild("IconFrame")[i]:GetChild("Text"):visible(false):settext("")
        end
        local IconCount = 1

        -- Update the local mods
        PlayerMods = GAMESTATE:GetPlayerState(pn):GetPlayerOptions("ModsLevel_Preferred")
        PlayerModsArray = GAMESTATE:GetPlayerState(pn):GetPlayerOptionsArray("ModsLevel_Preferred")

        -- 1x is not included in the engine list by default, so we need to do... this. Ew.
        if (PlayerMods:XMod() == 1 and
            PlayerMods:MMod() == nil and
            PlayerMods:CMod() == nil and
            PlayerMods:AMod() == nil) then
            table.insert(PlayerModsArray, 1, "1x")
        end

        -- Remove unneeded strings from the blacklist, normal speed if Auto Velocity is being used and Noteskin (displayed as an icon instead)
        for i, BlacklistedMod in ipairs(PlayerModsBlacklist) do
            if string.find(ToLower(GAMESTATE:GetPlayerState(pn):GetPlayerOptionsString("ModsLevel_Preferred")), ToLower(BlacklistedMod)) ~= nil then
                removeFirst(PlayerModsArray, BlacklistedMod)
            end
        end

        -- Even though we added 1x above, we'll need it to consistently remove the engine speed so that we can apply our own auto velocity
        local AV = LoadModule("Config.Load.lua")("AutoVelocity", CheckIfUserOrMachineProfile(pnNum).."/OutFoxPrefs.ini") or false
        local AVType = LoadModule("Config.Load.lua")("AutoVelocityType", CheckIfUserOrMachineProfile(pnNum).."/OutFoxPrefs.ini") or false

        if AV then
            table.remove(PlayerModsArray, 1)
            if not AVType then
                table.insert(PlayerModsArray, 1, (AV / 100) .. "X")
            else
                table.insert(PlayerModsArray, 1, (AVType == "Auto" and "AV " or "C") .. AV)
            end
        end

        local CurNoteSkin = ToLower(PlayerMods:NoteSkin())
        local OptionsNoteskin = ToLower(GAMESTATE:GetPlayerState(pn):GetPlayerOptionsString("ModsLevel_Preferred"))
        -- Hyphens will break string searching, we need to remove them and any anything else that could break
        if string.match(string.gsub(OptionsNoteskin, "%p", ""), string.gsub(CurNoteSkin, "%p", "")) ~= nil then
            removeFirst(PlayerModsArray, CurNoteSkin)
        end

        -- Timing mode
        local TimingMode = LoadModule("Config.Load.lua")("SmartTimings","Save/OutFoxPrefs.ini") or "Unknown"
        -- We don't want to display NJ!
        if TimingMode and TimingMode ~= "Pump Normal" then
            table.insert(PlayerModsArray, TimingMode)
        end

        -- Translate all strings so far but speed mods
        for i = 2, #PlayerModsArray do
            local ModText = THEME:GetString("ModIcons", PlayerModsArray[i])
            -- Only override strings if translations are available
            if ModText ~= "" then PlayerModsArray[i] = ModText end
        end

        -- BGA darkness
        local BGAFilter = LoadModule("Config.Load.lua")("ScreenFilter",CheckIfUserOrMachineProfile(pnNum).."/OutFoxPrefs.ini") or 0
        -- Increase the value so that we can use it as percentage
        BGAFilter = round(BGAFilter * 100)
        if BGAFilter ~= 0 then
            table.insert(PlayerModsArray, 2, THEME:GetString("ModIcons", "Filter") .. " " .. (BGAFilter == 100 and "Off" or BGAFilter .. "%"))
        end

        -- Music rate
        local RushAmount = GAMESTATE:GetSongOptionsObject("ModsLevel_Song"):MusicRate()
        if RushAmount ~= nil then
            RushAmount = math.round(RushAmount * 100)
            if RushAmount ~= 100 then
                table.insert(PlayerModsArray, THEME:GetString("ModIcons", "Rush") .. "\n" .. RushAmount)
            end
        end

        -- Populate all of the available icons
        for i = 1, (#PlayerModsArray > IconAmount and IconAmount or #PlayerModsArray) do
            self:GetChild("IconFrame")[i]:GetChild("Icon"):visible(true)
            self:GetChild("IconFrame")[i]:GetChild("Text"):visible(true):settext(PlayerModsArray[i])
            IconCount = i + 1
        end
    end,

    -- Noteskin display
    Def.Sprite {
        Texture=THEME:GetPathG("", "UI/ModIcon"),
        InitCommand=function(self) self:y(IconH) end
    }
}

-- This will be responsible for displaying the selected noteskin
t[#t+1] = Def.ActorProxy {
    OnCommand=function(self)
        self:y(IconH - 1)
        :zoom(0.6)
        :playcommand("Refresh")
    end,
    OptionsListStartMessageCommand=function(self) self:queuecommand("Refresh") end,
    RefreshCommand=function(self)
        if SCREENMAN:GetTopScreen() then
            local CurNoteSkin = PlayerMods:NoteSkin()
            self:SetTarget(SCREENMAN:GetTopScreen():GetChild("NS"..string.lower(CurNoteSkin)))
        end
    end
}

-- Create template icons that will be used depending on the active mods
for i = 1, IconAmount do
    t[#t+1] = Def.ActorFrame {
        Name="IconFrame",
        Def.Sprite {
            Name="Icon",
            Texture=THEME:GetPathG("", "UI/ModIcon"),
            InitCommand=function(self)
                self:y((i > 1 and IconH or 0) + IconH * (i - 1))
                :visible(false)
            end
        },
        Def.BitmapText {
            Name="Text",
            Font="Montserrat semibold 40px",
            InitCommand=function(self)
                self:y((i > 1 and IconH or 0) + IconH * (i - 1) - 1)
                :zoom(0.5):vertspacing(-20):shadowlength(1)
                :wrapwidthpixels((IconW - 4) / self:GetZoom())
                :maxwidth((IconW - 4) / self:GetZoom())
                :maxheight((IconH - 4) / self:GetZoom())
                :visible(false)
            end
        }
    }
end

----
-- vvvv POI PROJECT vvvv
----

local usingPOIUX = LoadModule("Config.Load.lua")("ActivatePOIProjectUX", "Save/OutFoxPrefs.ini") or false
if usingPOIUX then
	-- levers
	IconW = 46
	IconH = 46
	IconAmount = 8
	IconSpacing = 3	
	
	-- A list of mods we do not want to display through the icons
	PlayerModsBlacklist = {
		"Overhead",
		"FailImmediate",
		"FailImmediateContinue",
		"FailAtEnd",
		"80Percent",
		"MissCombo",
		"FailOff"
	}
	
	-- code
	t = Def.ActorFrame {}
	t = Def.ActorFrame {
		-- Dynamic icons that will require updating at every options change
		InitCommand=function(self) self:queuecommand("Refresh") end,
		OptionsListStartMessageCommand=function(self) self:queuecommand("Refresh") end,
		RefreshCommand=function(self)
			-- Clean up the list of additional icons
			for i = 1, IconAmount do
				self:GetChild("IconFrame")[i]:GetChild("Icon"):visible(false)
				self:GetChild("IconFrame")[i]:GetChild("Text"):visible(false):settext("")
			end
			local IconCount = 1

			-- Update the local mods
			PlayerMods = GAMESTATE:GetPlayerState(pn):GetPlayerOptions("ModsLevel_Preferred")
			PlayerModsArray = GAMESTATE:GetPlayerState(pn):GetPlayerOptionsArray("ModsLevel_Preferred")

			-- 1x is not included in the engine list by default, so we need to do... this. Ew.
			if (PlayerMods:XMod() == 1 and
				PlayerMods:MMod() == nil and
				PlayerMods:CMod() == nil and
				PlayerMods:AMod() == nil) then
				table.insert(PlayerModsArray, 1, "1x")
			end

			-- Remove unneeded strings from the blacklist, normal speed if Auto Velocity is being used and Noteskin (displayed as an icon instead)
			for i, BlacklistedMod in ipairs(PlayerModsBlacklist) do
				if string.find(ToLower(GAMESTATE:GetPlayerState(pn):GetPlayerOptionsString("ModsLevel_Preferred")), ToLower(BlacklistedMod)) ~= nil then
					removeFirst(PlayerModsArray, BlacklistedMod)
				end
			end

			-- Even though we added 1x above, we'll need it to consistently remove the engine speed so that we can apply our own auto velocity
			local AV = LoadModule("Config.Load.lua")("AutoVelocity", CheckIfUserOrMachineProfile(pnNum).."/OutFoxPrefs.ini") or false
			local AVType = LoadModule("Config.Load.lua")("AutoVelocityType", CheckIfUserOrMachineProfile(pnNum).."/OutFoxPrefs.ini") or false

			if AV then
				table.remove(PlayerModsArray, 1)
				if not AVType then
					table.insert(PlayerModsArray, 1, (AV / 100) .. "X")
				else
					table.insert(PlayerModsArray, 1, (AVType == "Auto" and "AV " or "C") .. AV)
				end
			end

			local CurNoteSkin = ToLower(PlayerMods:NoteSkin())
			local OptionsNoteskin = ToLower(GAMESTATE:GetPlayerState(pn):GetPlayerOptionsString("ModsLevel_Preferred"))
			-- Hyphens will break string searching, we need to remove them and any anything else that could break
			if string.match(string.gsub(OptionsNoteskin, "%p", ""), string.gsub(CurNoteSkin, "%p", "")) ~= nil then
				removeFirst(PlayerModsArray, CurNoteSkin)
			end

			-- forcing Arrow 70% because fuck you that's why
			GAMESTATE:GetPlayerState(pn):GetPlayerOptions("ModsLevel_Preferred"):Mini(0.3)			
			removeFirst(PlayerModsArray, "30% Mini") -- we don't want it displayed
			
			-- Timing mode
			local TimingMode = LoadModule("Config.Load.lua")("SmartTimings","Save/OutFoxPrefs.ini") or "Unknown"
			-- We don't want to display NJ!
			if TimingMode and TimingMode ~= "Pump Normal" then
				table.insert(PlayerModsArray, TimingMode)
			end

			-- Translate all strings so far but speed mods
			for i = 2, #PlayerModsArray do
				local ModText = THEME:GetString("ModIcons", PlayerModsArray[i])
				-- Only override strings if translations are available
				if ModText ~= "" then PlayerModsArray[i] = ModText end
			end

			-- BGA darkness
			local BGAFilter = LoadModule("Config.Load.lua")("ScreenFilter",CheckIfUserOrMachineProfile(pnNum).."/OutFoxPrefs.ini") or 0
			-- Increase the value so that we can use it as percentage
			BGAFilter = round(BGAFilter * 100)
			if BGAFilter ~= 0 then
				table.insert(PlayerModsArray, 2, THEME:GetString("ModIcons", "Filter") .. " " .. (BGAFilter == 100 and "Off" or BGAFilter .. "%"))
			end

			-- Music rate
			local RushAmount = GAMESTATE:GetSongOptionsObject("ModsLevel_Song"):MusicRate()
			if RushAmount ~= nil then
				RushAmount = math.round(RushAmount * 100)
				if RushAmount ~= 100 then
					table.insert(PlayerModsArray, THEME:GetString("ModIcons", "Rush") .. "\n" .. RushAmount)
				end
			end

			-- Populate all of the available icons
			for i = 1, (#PlayerModsArray > IconAmount and IconAmount or #PlayerModsArray) do
				self:GetChild("IconFrame")[i]:GetChild("Icon"):visible(true)
				self:GetChild("IconFrame")[i]:GetChild("Text"):visible(true):settext(PlayerModsArray[i])
				IconCount = i + 1
			end
		end,

		-- Noteskin display
		Def.Sprite {
			Texture=THEME:GetPathG("", "UI/ModIcon"),
			InitCommand=function(self) 
			self:x(0):zoomx(IconW/64)
			end
		}
	}

	-- This will be responsible for displaying the selected noteskin
	t[#t+1] = Def.ActorProxy {
		OnCommand=function(self)
			self:x(0)
			:zoom(0.6)
			:playcommand("Refresh")
		end,
		OptionsListStartMessageCommand=function(self) self:queuecommand("Refresh") end,
		RefreshCommand=function(self)
			if SCREENMAN:GetTopScreen() then
				local CurNoteSkin = PlayerMods:NoteSkin()
				self:SetTarget(SCREENMAN:GetTopScreen():GetChild("NS"..string.lower(CurNoteSkin)))
			end
		end
	}

	-- Create template icons that will be used depending on the active mods
	for i = 1, IconAmount do
		t[#t+1] = Def.ActorFrame {
			Name="IconFrame",
			Def.Sprite {
				Name="Icon",
				Texture=THEME:GetPathG("", "UI/ModIcon"),
				InitCommand=function(self)					
					self:x((pnNum == 1) and -(IconW + IconSpacing) - (i - 1) * (IconW + IconSpacing) or (IconW + IconSpacing) + (i - 1) * (IconW + IconSpacing))
					:visible(false):zoomx(IconW/64):y(0)
				end
			},
			Def.BitmapText {
				Name="Text",
				Font="Montserrat semibold 40px",
				InitCommand=function(self)
					self:x((pnNum == 1) and -(IconW + IconSpacing) - (i - 1) * (IconW + IconSpacing) or (IconW + IconSpacing) + (i - 1) * (IconW + IconSpacing))
					:zoom(0.4):vertspacing(-20):shadowlength(1)
                    :wrapwidthpixels((IconW - 4) / self:GetZoom())
                    :maxwidth((IconW - 4) / self:GetZoom())
                    :maxheight((IconH - 4) / self:GetZoom())
                    :visible(false):y(0)
				end
			}
		}
	end
end

return t
