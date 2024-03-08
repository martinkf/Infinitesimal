local topPanel_Y = 0 --default Infinitesimal behavior
local screenName_Y = 40 --default Infinitesimal behavior
local amountLives_X = WideScale(200, 225) --default Infinitesimal behavior
local amountLives_Y = 40 --default Infinitesimal behavior
local bottomPanel_Y = SCREEN_BOTTOM --default Infinitesimal behavior
local profileNameBG_X = 232 --default Infinitesimal behavior
local profileNameBG_Y = 32 --default Infinitesimal behavior
local profileNameText_X = 292 --default Infinitesimal behavior
local profileNameText_Y = 48 --default Infinitesimal behavior
local profileLevelBG_X = 212 --default Infinitesimal behavior
local profileLevelBG_Y = 10 --default Infinitesimal behavior
local profileLevelText_X = 281 --default Infinitesimal behavior
local profileLevelText_Y = 26 --default Infinitesimal behavior
local profilePic_X = 172 --default Infinitesimal behavior
local profilePic_Y = 39 --default Infinitesimal behavior

local usingPOIUX = LoadModule("Config.Load.lua")("ActivatePOIProjectUX", "Save/OutFoxPrefs.ini") or false

if usingPOIUX then
	topPanel_Y = -37
	screenName_Y = 20
	amountLives_X = 240
	amountLives_Y = 22
	bottomPanel_Y = 762
	profileNameBG_X = 570
	profileNameBG_Y = 668
	profileNameText_X = 510
	profileNameText_Y = 653
	profileLevelBG_X = profileNameBG_X
	profileLevelBG_Y = 640
	profileLevelText_X = 510
	profileLevelText_Y = 625
	profilePic_X = 600
	profilePic_Y = 637
end

local t = Def.ActorFrame {
    Def.ActorFrame {
        InitCommand=function(self)
            self:xy(SCREEN_CENTER_X, -128)
        end,
        OnCommand=function(self)
            self:easeoutexpo(0.5):xy(SCREEN_CENTER_X, 0)
        end,
        OffCommand=function(self)
            self:easeoutexpo(0.5):xy(SCREEN_CENTER_X, -128)
        end,

        -- Top panel
        Def.Sprite {
            Texture=THEME:GetPathG("", "UI/PanelTop"),
            InitCommand=function(self)
                self:scaletofit(0, 0, 1280, 128):xy(0, topPanel_Y):valign(0)
            end,
        },

        -- Screen name
        Def.BitmapText {
            Name="ScreenName",
            Font="Montserrat normal 40px",
            Text=ToUpper(Screen.String("HeaderText")),
            InitCommand=function(self)
                self:xy(-WideScale(200, 200), screenName_Y):halign(1):zoom(0.6)
                :diffuse(Color.Black):shadowlength(1)

                if not IsUsingWideScreen() then
                    local IsSelectMusic = self:GetText() == "SELECT MUSIC"
                    if IsSelectMusic then self:x(-WideScale(170, 170)) end

                    local WidthLimit = (IsSelectMusic and 181 or 160) / self:GetZoom()
                    self:maxwidth(WidthLimit):wrapwidthpixels(WidthLimit):vertspacing(-16)
                end
            end,
        },

        -- Stage count
        Def.BitmapText {
            Font="Montserrat normal 40px",
            InitCommand=function(self)
                self:visible(Screen.String("HeaderText") == "Select Music" and true or false)
                self:settext("STAGE "..string.format("%02d", GAMESTATE:GetCurrentStageIndex() + 1))
                self:xy(-WideScale(200, 200), 60):halign(1):zoom(0.5):diffuse(Color.Black)
            end,
        },

        -- Amount of lives left
        Def.ActorFrame {
            InitCommand=function(self)
                self:xy(amountLives_X, amountLives_Y)
            end,

            Def.Sprite {
                Texture=THEME:GetPathG("", "UI/Button"),
                InitCommand=function(self) self:zoom(0.65) end,
            },

            Def.Sprite {
                Texture=THEME:GetPathG("", "UI/Heart"),
                InitCommand=function(self)
                    self:x(-21):zoom(0.3)
                end,
            },

            Def.BitmapText {
                Font="Montserrat semibold 40px",
                InitCommand=function(self)
                    self:x(-6):zoom(0.6):halign(0)

                    local Hearts = GAMESTATE:GetNumStagesLeft(PLAYER_1) + GAMESTATE:GetNumStagesLeft(PLAYER_2)
                    self:settext("x " .. (GAMESTATE:IsEventMode() and "∞" or Hearts))
                end
            },
        }
    },

    -- Bottom panel
    Def.Sprite {
        Texture=THEME:GetPathG("", "UI/PanelBottom"),
        InitCommand=function(self)
            self:scaletofit(0, 0, 1280, 128)
            :xy(SCREEN_CENTER_X, SCREEN_BOTTOM + 128):valign(1)
        end,
        OnCommand=function(self)
            self:easeoutexpo(0.5)
            :xy(SCREEN_CENTER_X, bottomPanel_Y)
        end,
        OffCommand=function(self)
            self:easeoutexpo(0.5)
            :xy(SCREEN_CENTER_X, SCREEN_BOTTOM + 128)
        end,
    },
}

-- Avatar display and info on bottom panel
for pn in ivalues(GAMESTATE:GetHumanPlayers()) do
    if PROFILEMAN:GetProfile(pn) and (PROFILEMAN:IsPersistentProfile(pn) or PROFILEMAN:ProfileWasLoadedFromMemoryCard(pn)) then
        t[#t+1] = Def.ActorFrame {            
			Def.ActorFrame {
                InitCommand=function(self) self:y(128) end,
                OnCommand=function(self) self:easeoutexpo(0.5):y(0) end,
                OffCommand=function(self) self:easeoutexpo(0.5):y(128) end,

                Def.Sprite {
                    Texture=THEME:GetPathG("", "UI/AvatarSlotMask"),
                    InitCommand=function(self)
						if usingPOIUX then
							self:diffusealpha(0) -- not used in POI Project
						else
							self:xy(SCREEN_CENTER_X + (pn == PLAYER_2 and 172 or -172), SCREEN_BOTTOM - 39)
							:rotationy(pn == PLAYER_2 and 180 or 0):MaskSource()
						end                       
                    end
                },

                Def.Sprite {
                    Texture=THEME:GetPathG("", "UI/NameTag" .. ToEnumShortString(pn)),
                    InitCommand=function(self)
						if usingPOIUX then
							self:xy(SCREEN_CENTER_X + (pn == PLAYER_2 and profileNameBG_X or -profileNameBG_X), SCREEN_BOTTOM - profileNameBG_Y)
							:halign(pn == PLAYER_2 and 0 or 1):valign(1):rotationz(180)
						else
							self:xy(SCREEN_CENTER_X + (pn == PLAYER_2 and 232 or -232), SCREEN_BOTTOM - 32)
							:halign(pn == PLAYER_2 and 0 or 1):valign(1):MaskDest()
						end
                    end
                },

                Def.BitmapText {
                    Font="Montserrat semibold 20px",
                    Text=PROFILEMAN:GetProfile(pn):GetDisplayName(),
                    InitCommand=function(self)
                        self:xy(SCREEN_CENTER_X + (pn == PLAYER_2 and profileNameText_X or -profileNameText_X), SCREEN_BOTTOM - profileNameText_Y):zoom(0.9)
                        :maxwidth(112 / self:GetZoom()):skewx(-0.2):shadowlength(1)

                        if PROFILEMAN:GetProfile(pn):GetDisplayName() == "" then
                            self:settext(THEME:GetString("ProfileStats", "No Profile"))
                        end
                    end
                },

                Def.Sprite {
                    Texture=THEME:GetPathG("", "UI/NameTag" .. ToEnumShortString(pn)),
                    InitCommand=function(self)
						if usingPOIUX then
							self:xy(SCREEN_CENTER_X + (pn == PLAYER_2 and profileLevelBG_X or -profileLevelBG_X), SCREEN_BOTTOM - profileLevelBG_Y)
							:halign(pn == PLAYER_2 and 0 or 1):valign(1):rotationz(180)
						else
							self:xy(SCREEN_CENTER_X + (pn == PLAYER_2 and 212 or -212), SCREEN_BOTTOM - 10)
							:halign(pn == PLAYER_2 and 0 or 1):valign(1):MaskDest()
						end
                    end
                },

                Def.BitmapText {
                    Font="Montserrat semibold 20px",
                    -- This ingenious level system was made up at 4am
                    InitCommand=function(self)
                        self:xy(SCREEN_CENTER_X + (pn == PLAYER_2 and profileLevelText_X or -profileLevelText_X), SCREEN_BOTTOM - profileLevelText_Y):zoom(0.9)
                        :maxwidth(96 / self:GetZoom()):skewx(-0.2):shadowlength(1)
                        lvl = math.floor(math.sqrt(PROFILEMAN:GetProfile(pn):GetTotalDancePoints() / 500)) + 1
                        -- You can check if a number is "nan" by comparing it to itself
                        -- because "nan" is not equal to anything, not even itself
                        if (lvl < 0) or (lvl ~= lvl) then lvl = 0 end
                        self:settext(THEME:GetString("ProfileStats", "Level") .. " " .. lvl)
                    end
                },

                Def.Sprite {
                    Texture=LoadModule("Options.GetProfileData.lua")(pn)["Image"],
                    InitCommand=function(self)
						if usingPOIUX then
							self:diffusealpha(0) -- not used in POI Project
						else
							self:scaletocover(0, 0, 128, 64)
							:xy(SCREEN_CENTER_X + (pn == PLAYER_2 and 172 or -172), SCREEN_BOTTOM - 39)
							:MaskDest():ztestmode("ZTestMode_WriteOnFail"):diffusealpha(0.5)
						end
                    end
                },

                Def.Sprite {
                    Texture=THEME:GetPathG("", "UI/AvatarSlotOverlay"),
                    InitCommand=function(self)
						if usingPOIUX then
							self:diffusealpha(0) -- not used in POI Project
						else
							self:xy(SCREEN_CENTER_X + (pn == PLAYER_2 and 172 or -172), SCREEN_BOTTOM - 39)
							:rotationy(pn == PLAYER_2 and 180 or 0)
						end
                    end
                },

                Def.Sprite {
                    Texture=LoadModule("Options.GetProfileData.lua")(pn)["Image"],
                    InitCommand=function(self)
						if usingPOIUX then
							self:scaletocover(0, 0, 64, 64)
							:xy(SCREEN_CENTER_X + (pn == PLAYER_2 and profilePic_X or -profilePic_X), SCREEN_BOTTOM - profilePic_Y)
						else
							self:scaletocover(0, 0, 64, 64)
							:xy(SCREEN_CENTER_X + (pn == PLAYER_2 and 172 or -172), SCREEN_BOTTOM - 39)
							:MaskDest():ztestmode("ZTestMode_WriteOnFail")
						end
                    end
                }
            }
        }
    end
end

return t