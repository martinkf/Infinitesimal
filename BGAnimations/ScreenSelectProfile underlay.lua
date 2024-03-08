if LoadModule("Config.Load.lua")("ActivatePOIProjectUX", "Save/OutFoxPrefs.ini") then
	return Def.ActorFrame {
		LoadActor("HudPanels")
		--LoadActor("CornerArrows") --POI Project removes CornerArrows from this screen
	}
else --default Infinitesimal behavior
	return Def.ActorFrame {
		LoadActor("HudPanels"),
		LoadActor("CornerArrows")	
	}
end

return