function AutoVelocity()
    local t = {
        Name = "AutoVelocity",
        LayoutType = "ShowAllInRow",
        SelectType = "SelectMultiple",
        GoToFirstOnStart = false,
        OneChoiceForAllPlayers = false,
        ExportOnChange = false,
        Choices = {"+25", "-25"},
        -- We'll do our own load/save functions below
        LoadSelections = function(self, list, pn) end,
        SaveSelections = function(self, list, pn) end,
        NotifyOfSelection = function(self, pn, choice)
            local AV = LoadModule("Config.Load.lua")("AutoVelocity", CheckIfUserOrMachineProfile(string.sub(pn,-1)-1).."/OutFoxPrefs.ini")
            
            if not AV then
                AV = 200
            elseif choice == 1 then
                AV = AV + 25
            elseif choice == 2 then
                AV = AV - 25
            end
            
            -- Clamp values
            if AV < 200 then AV = 200 end
            if AV > 900 then AV = 900 end
            
            LoadModule("Config.Save.lua")("AutoVelocity", tostring(AV), CheckIfUserOrMachineProfile(string.sub(pn,-1)-1).."/OutFoxPrefs.ini")
            return true
        end
    }
    setmetatable( t, t )
    return t
end