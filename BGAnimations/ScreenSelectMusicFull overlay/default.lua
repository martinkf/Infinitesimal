local MenuButtonsOnly = PREFSMAN:GetPreference("OnlyDedicatedMenuButtons")

local t = Def.ActorFrame {
    OnCommand=function(self)
        local pn = GAMESTATE:GetMasterPlayerNumber()
        GAMESTATE:UpdateDiscordProfile(GAMESTATE:GetPlayerDisplayName(pn))
        if GAMESTATE:IsCourseMode() then
            GAMESTATE:UpdateDiscordScreenInfo("Selecting Course", "", 1)
        else
            local StageIndex = GAMESTATE:GetCurrentStageIndex()
            GAMESTATE:UpdateDiscordScreenInfo("Selecting Song (Stage " .. StageIndex+1 .. ")", "", 1)
        end
    end,
}

if GAMESTATE:GetNumSidesJoined() < 2 then
    local PosX = SCREEN_CENTER_X + SCREEN_WIDTH * (GAMESTATE:IsSideJoined(PLAYER_1) and 0.35 or -0.35)
    local PosY = (IsUsingWideScreen() and (SCREEN_HEIGHT * 0.4) or SCREEN_HEIGHT * 0.35)

    t[#t+1] = Def.ActorFrame {
        InitCommand=function(self)
            self:xy((IsUsingWideScreen() and PosX or (PosX * 1.045)), PosY)
            :playcommand('Refresh')
        end,

        SongChosenMessageCommand=function(self)
            self:stoptweening():easeoutquad(0.25):y(PosY - 40)
        end,
        SongUnchosenMessageCommand=function(self)
            self:stoptweening():easeoutquad(0.25):y(PosY)
        end,

        CoinInsertedMessageCommand=function(self) self:playcommand('Refresh') end,

        RefreshCommand=function(self)
            self:GetChild("CenterStep"):visible(NoSongs or GAMESTATE:GetCoins() >= GAMESTATE:GetCoinsNeededToJoin())
            self:GetChild("InsertCredit"):visible(NoSongs or GAMESTATE:GetCoinsNeededToJoin() > GAMESTATE:GetCoins())
        end,

        OffCommand=function(self)
            self:GetChild("CenterStep"):visible(true)
            self:GetChild("InsertCredit"):visible(false)
            self:stoptweening():easeoutexpo(0.25):zoom(2):diffusealpha(0)
        end,

        LoadActor(THEME:GetPathG("", "PressCenterStep")) .. {
            Name="CenterStep",
        },

        LoadActor(THEME:GetPathG("", "InsertCredit")) .. {
            Name="InsertCredit",
        }
    }
end

t[#t+1] = Def.ActorFrame {
    -- Background for the group select wheel
    Def.Quad {
        InitCommand=function(self)
            self:FullScreen():diffuse(Color.Black):diffusebottomedge(color("#001122")):diffusealpha(0)
        end,
        CloseGroupWheelMessageCommand=function(self) self:stoptweening():easeoutexpo(0.25):diffusealpha(0) end,
        OpenGroupWheelMessageCommand=function(self) self:stoptweening():easeoutexpo(1):diffusealpha(0.8) end,
    },

    LoadActor("GroupSelect") .. {
        -- Zoom doesn't center things so we need to recenter them
        InitCommand=function(self)
            self:zoom(1.25):xy(-SCREEN_WIDTH / 8, -SCREEN_HEIGHT / 8)
        end
    },
    
    LoadActor("../HudPanels"),

    LoadActor("../CornerArrows"),
    
    LoadActor("OptionsList"),

    Def.Sound {
        File=THEME:GetPathS("Common", "start"),
        IsAction=true,
        PlayerJoinedMessageCommand=function(self)
            self:play()
            SOUND:DimMusic(0, 1)
            SCREENMAN:GetTopScreen():SetNextScreenName("ScreenSelectProfile")
            SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
        end
    }
}

for pn in ivalues(GAMESTATE:GetHumanPlayers()) do
    t[#t+1] = Def.Quad {
        InitCommand=function(self)
            local side = (pn == PLAYER_1 and SCREEN_LEFT or SCREEN_RIGHT)
            local alignment = (pn == PLAYER_1 and 0 or 1)

            if pn == PLAYER_1 then self:faderight(50) else self:fadeleft(75) end

            self:diffuse(1,1,1,1):halign(alignment):xy(side, SCREEN_CENTER_Y-70):zoomto(0, 360)
        end,
        CodeMessageCommand=function(self, params)
            if ((params.Name == "OpenOpList" and not MenuButtonsOnly) or
                params.Name == "OpenOpListButton") and params.PlayerNumber == pn then
                self:diffusealpha(100):zoomto(0, 360)
                :linear(0.25)
                :diffusealpha(0):zoomto(60, 360)
            end
        end
    }
end

----
-- vvvv POI PROJECT vvvv
----

local usingPOIUX = LoadModule("Config.Load.lua")("ActivatePOIProjectUX", "Save/OutFoxPrefs.ini") or false
if usingPOIUX then
	-- levers	
	local modIcons_X = 94
	local modIcons_Y = 49
	local joinAnotherPlayer_X = 0.475
	local joinAnotherPlayer_Y = 258
	local joinAnotherPlayer_zoom = 0.4
	
	-- code
	t = Def.ActorFrame {}
	t = Def.ActorFrame {
		OnCommand=function(self)
			local pn = GAMESTATE:GetMasterPlayerNumber()
			GAMESTATE:UpdateDiscordProfile(GAMESTATE:GetPlayerDisplayName(pn))
			if GAMESTATE:IsCourseMode() then
				GAMESTATE:UpdateDiscordScreenInfo("Selecting Course", "", 1)
			else
				local StageIndex = GAMESTATE:GetCurrentStageIndex()
				GAMESTATE:UpdateDiscordScreenInfo("Selecting Song (Stage " .. StageIndex+1 .. ")", "", 1)
			end
		end,
	}

	t[#t+1] = Def.ActorFrame {
		LoadActor("../HudPanels"),
	}

	for pn in ivalues(GAMESTATE:GetHumanPlayers()) do
		t[#t+1] = Def.ActorFrame {
			Def.Actor {
				-- If no AV is defined, do it before it causes any issues
				OnCommand=function(self)
					local AV = LoadModule("Config.Load.lua")("AutoVelocity", CheckIfUserOrMachineProfile(string.sub(pn,-1)-1).."/OutFoxPrefs.ini")
					if not AV then
						LoadModule("Config.Save.lua")("AutoVelocity", tostring(200), CheckIfUserOrMachineProfile(string.sub(pn,-1)-1).."/OutFoxPrefs.ini")
					end
					LoadModule("Player.SetSpeed.lua")(pn)
				end,

				-- Make sure the speed is set relative to the selected song when going to gameplay
				OffCommand=function(self)
					LoadModule("Player.SetSpeed.lua")(pn)
				end
			},

			-- mod icons
			LoadActor("../ModIcons", pn) .. {
				InitCommand=function(self)
					--self:xy(pn == PLAYER_2 and SCREEN_RIGHT + modIcons_X * 2 or -(modIcons_X) * 2, modIcons_Y)
					self:xy(pn == PLAYER_2 and modIcons_X * 2 or modIcons_X * -2, modIcons_Y)
					:easeoutexpo(1):x(pn == PLAYER_2 and SCREEN_RIGHT - modIcons_X or modIcons_X)
				end,
				OffCommand=function(self)
					self:stoptweening():easeoutexpo(1):x(pn == PLAYER_2 and SCREEN_RIGHT + modIcons_X * 2 or -(modIcons_X) * 2)
				end
			},
		}
	end

	if GAMESTATE:GetNumSidesJoined() < 2 then    
		local PosX = SCREEN_CENTER_X + SCREEN_WIDTH * (GAMESTATE:IsSideJoined(PLAYER_1) and joinAnotherPlayer_X or -(joinAnotherPlayer_X))
		local PosY = ((IsUsingWideScreen() and (SCREEN_HEIGHT * 0.4) or SCREEN_HEIGHT * 0.35))-joinAnotherPlayer_Y

		t[#t+1] = Def.ActorFrame {
			InitCommand=function(self)
				self:xy((IsUsingWideScreen() and PosX or (PosX * 1.045)), PosY):zoom(joinAnotherPlayer_zoom)
				:playcommand('Refresh')
			end,
		
			CoinInsertedMessageCommand=function(self) self:playcommand('Refresh') end,

			RefreshCommand=function(self)
				self:GetChild("CenterStep"):visible(NoSongs or GAMESTATE:GetCoins() >= GAMESTATE:GetCoinsNeededToJoin())
				self:GetChild("InsertCredit"):visible(NoSongs or GAMESTATE:GetCoinsNeededToJoin() > GAMESTATE:GetCoins()):y(18)
			end,

			OffCommand=function(self)
				self:GetChild("CenterStep"):visible(true)
				self:GetChild("InsertCredit"):visible(false)
				self:stoptweening():easeoutexpo(0.25):zoom(2):diffusealpha(0)
			end,

			LoadActor(THEME:GetPathG("", "PressCenterStep")) .. {
				Name="CenterStep",
			},

			LoadActor(THEME:GetPathG("", "InsertCredit")) .. {
				Name="InsertCredit",
			}
		}
	end

	t[#t+1] = Def.ActorFrame {
		-- Background for the group select wheel
		Def.Quad {
			InitCommand=function(self)
				self:FullScreen():diffuse(Color.Black):diffusebottomedge(color("#001122")):diffusealpha(0)
			end,
			CloseGroupWheelMessageCommand=function(self) self:stoptweening():easeoutexpo(0.25):diffusealpha(0) end,
			OpenGroupWheelMessageCommand=function(self) self:stoptweening():easeoutexpo(1):diffusealpha(0.95) end,
		},

		LoadActor("GroupSelect") .. {
			-- Zoom doesn't center things so we need to recenter them
			InitCommand=function(self)
				self:zoom(1.25):xy(-SCREEN_WIDTH / 8, -SCREEN_HEIGHT / 8)
			end
		},    
		
		LoadActor("OptionsList"),

		Def.Sound {
			File=THEME:GetPathS("Common", "start"),
			IsAction=true,
			PlayerJoinedMessageCommand=function(self)
				self:play()
				SOUND:DimMusic(0, 1)
				SCREENMAN:GetTopScreen():SetNextScreenName("ScreenSelectProfile")
				SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
			end
		}
	}

	for pn in ivalues(GAMESTATE:GetHumanPlayers()) do
		t[#t+1] = Def.Quad {
			InitCommand=function(self)
				local side = (pn == PLAYER_1 and SCREEN_LEFT or SCREEN_RIGHT)
				local alignment = (pn == PLAYER_1 and 0 or 1)

				if pn == PLAYER_1 then self:faderight(50) else self:fadeleft(75) end

				self:diffuse(1,1,1,1):halign(alignment):xy(side, SCREEN_CENTER_Y-70):zoomto(0, 360)
			end,
			CodeMessageCommand=function(self, params)
				if ((params.Name == "OpenOpList" and not MenuButtonsOnly) or
					params.Name == "OpenOpListButton") and params.PlayerNumber == pn then
					self:diffusealpha(100):zoomto(0, 360)
					:linear(0.25)
					:diffusealpha(0):zoomto(60, 360)
				end
			end
		}
	end
end

return t