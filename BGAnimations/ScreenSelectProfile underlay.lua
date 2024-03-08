local t = Def.ActorFrame {
    LoadActor("HudPanels"),
    LoadActor("CornerArrows")
}

----
-- vvvv POI PROJECT vvvv
----

local usingPOIUX = LoadModule("Config.Load.lua")("ActivatePOIProjectUX", "Save/OutFoxPrefs.ini") or false
if usingPOIUX then
	t = Def.ActorFrame {
		LoadActor("HudPanels"),
		--LoadActor("CornerArrows") -- no corner arrows in POI Project
	}
end

return t