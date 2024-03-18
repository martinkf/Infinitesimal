local t = Def.ActorFrame {
    LoadActor("HudPanels"),
    LoadActor("CornerArrows")
}

----
-- vvvv POI PROJECT vvvv
----

local usingPOIUX = LoadModule("Config.Load.lua")("ActivatePOIProjectUX", "Save/OutFoxPrefs.ini") or false

-- forces a "re-assembly" of the GroupSelect options that will be used in the screen after this one and throughout the play
-- takes into consideration which UX the player is using
-- this is here to ensure that vanilla Infinitesimal continues to be vanilla
POIBranch_AssembleGroupSorting()

if usingPOIUX then
	t = Def.ActorFrame {
		LoadActor("HudPanels")
	}
end

return t