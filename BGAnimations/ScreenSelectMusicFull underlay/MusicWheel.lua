local Songs = {}
local Targets = {}

local ChartPreview = LoadModule("Config.Load.lua")("ChartPreview","Save/OutFoxPrefs.ini")

local WheelSize = 16
local WheelCenter = math.ceil( WheelSize * 0.5 )
local WheelItem = { Width = 160, Height = 120 }
local WheelSpacing = 190
local WheelRotation = -0.025
local curvature = 65
local fieldOfView = 90
local EntireWheel_SelectingSongY = 168
local EntireWheel_SelectingChartY = -460 -- this must match SmallerBGAPreview_SelectingChartY from SongPreview.lua
local WheelNumberQuad_Alpha = 0.6 - 0.6
local WheelNumberText_Alpha = 0.9 - 0.9


--


-- Not load anything if no group sorts are available (catastrophic event or no songs)
if next(GroupsList) == nil then
	POIBranch_AssembleGroupSorting()
    UpdateGroupSorting()
    
    if next(GroupsList) == nil then
        Warn("Groups list is currently inaccessible, halting music wheel!")
        return Def.Actor {}
    end
end

LastGroupMainIndex = tonumber(LoadModule("Config.Load.lua")("GroupMainIndex", CheckIfUserOrMachineProfile(string.sub(GAMESTATE:GetMasterPlayerNumber(),-1)-1).."/OutFoxPrefs.ini")) or 1
LastGroupSubIndex = tonumber(LoadModule("Config.Load.lua")("GroupSubIndex", CheckIfUserOrMachineProfile(string.sub(GAMESTATE:GetMasterPlayerNumber(),-1)-1).."/OutFoxPrefs.ini")) or 1
LastSongIndex = tonumber(LoadModule("Config.Load.lua")("SongIndex", CheckIfUserOrMachineProfile(string.sub(GAMESTATE:GetMasterPlayerNumber(),-1)-1).."/OutFoxPrefs.ini")) or 1
--reset LastGroup/Sub/Song if they were deleted since last session to avoid "attempt to index nil" crashes
if GroupsList[LastGroupMainIndex] == nil then
    LastGroupMainIndex = 1
    LastGroupSubIndex = 1
    LastSongIndex = 1
    Warn("ScreenSelectMusicFull underlay / MusicWheel.lua: LastGroupMainIndex no longer present, reset performed")
end
if GroupsList[LastGroupMainIndex].SubGroups[LastGroupSubIndex] == nil then
    LastGroupSubIndex = 1
    LastSongIndex = 1
    Warn("ScreenSelectMusicFull underlay / MusicWheel.lua: LastGroupSubIndex no longer present, reset performed")
end
if GroupsList[LastGroupMainIndex].SubGroups[LastGroupSubIndex].Songs == nil then 
    LastSongIndex = 1
    Warn("ScreenSelectMusicFull underlay / MusicWheel.lua: LastSongIndex no longer present, reset performed")
end


local SongIndex = LastSongIndex > 0 and LastSongIndex or 1
local GroupMainIndex = LastGroupMainIndex > 0 and LastGroupMainIndex or 1
local GroupSubIndex = LastGroupSubIndex > 0 and LastGroupSubIndex or 1

local IsBusy = false

-- Default is to start at All for now
Songs = GroupsList[GroupMainIndex].SubGroups[GroupSubIndex].Songs

-- Update Songs item targets
local function UpdateItemTargets(val)
    for i = 1, WheelSize do
        Targets[i] = val + i - WheelCenter
        -- Wrap to fit to Songs list size
        while Targets[i] > #Songs do Targets[i] = Targets[i] - #Songs end
        while Targets[i] < 1 do Targets[i] = Targets[i] + #Songs end
    end
end

local function InputHandler(event)
	local pn = event.PlayerNumber
    if not pn then return end
    
    -- Don't want to move when releasing the button
    if event.type == "InputEventType_Release" then return end

    local button = event.GameButton
    
    -- If an unjoined player attempts to join and has enough credits, join them
    if (button == "Center" or (not IsGame("pump") and button == "Start")) and 
        not GAMESTATE:IsSideJoined(pn) and GAMESTATE:GetCoins() >= GAMESTATE:GetCoinsNeededToJoin() then
        GAMESTATE:JoinPlayer(pn)
        -- The command above does not deduct credits so we'll do it ourselves
        GAMESTATE:InsertCoin(-(GAMESTATE:GetCoinsNeededToJoin()))
        MESSAGEMAN:Broadcast("PlayerJoined", { Player = pn })
    end

    -- To avoid control from a player that has not joined, filter the inputs out
    if pn == PLAYER_1 and not GAMESTATE:IsPlayerEnabled(PLAYER_1) then return end
    if pn == PLAYER_2 and not GAMESTATE:IsPlayerEnabled(PLAYER_2) then return end

    if not IsBusy then
        if button == "Left" or button == "MenuLeft" or button == "DownLeft" then
            SongIndex = SongIndex - 1
            if SongIndex < 1 then SongIndex = #Songs end
            
            GAMESTATE:SetCurrentSong(Songs[SongIndex])
            UpdateItemTargets(SongIndex)
            MESSAGEMAN:Broadcast("Scroll", { Direction = -1 })

        elseif button == "Right" or button == "MenuRight" or button == "DownRight" then
            SongIndex = SongIndex + 1
            if SongIndex > #Songs then SongIndex = 1 end
            
            GAMESTATE:SetCurrentSong(Songs[SongIndex])
            UpdateItemTargets(SongIndex)
            MESSAGEMAN:Broadcast("Scroll", { Direction = 1 })
            
        elseif button == "Start" or button == "MenuStart" or button == "Center" then
            -- Save this for later
            LastSongIndex = SongIndex
            LoadModule("Config.Save.lua")("SongIndex", LastSongIndex, CheckIfUserOrMachineProfile(string.sub(pn,-1)-1).."/OutFoxPrefs.ini")
            
            MESSAGEMAN:Broadcast("MusicWheelStart")

        elseif button == "Back" then
            SCREENMAN:GetTopScreen():Cancel()
        end
    end

	MESSAGEMAN:Broadcast("UpdateMusic")
end

-- Manages banner on sprite
local function UpdateBanner(self, Song)
    self:LoadFromSongBanner(Song):scaletoclipped(WheelItem.Width, WheelItem.Height)
end


--


local t = Def.ActorFrame {
	InitCommand=function(self)        
		self:y(SCREEN_HEIGHT / 2 + EntireWheel_SelectingSongY):fov(fieldOfView):SetDrawByZPosition(true)
	:vanishpoint(SCREEN_CENTER_X, SCREEN_BOTTOM - 150 + curvature)
		UpdateItemTargets(SongIndex)
	end,

	OnCommand=function(self)
		GAMESTATE:SetCurrentSong(Songs[SongIndex])
		SCREENMAN:GetTopScreen():AddInputCallback(InputHandler)
		
		self:easeoutexpo(1):y(SCREEN_HEIGHT / 2 - EntireWheel_SelectingSongY)
	end,
	
	-- Race condition workaround (yuck)
	MusicWheelStartMessageCommand=function(self) self:sleep(0.01):queuecommand("Confirm") end,
	ConfirmCommand=function(self) MESSAGEMAN:Broadcast("SongChosen") end,

	-- These are to control the functionality of the music wheel
	SongChosenMessageCommand=function(self)			
		self:stoptweening():easeoutexpo(1):vanishpoint(SCREEN_CENTER_X, SCREEN_BOTTOM - 150 + 7000):y(EntireWheel_SelectingChartY):zoom(2):x(-640)
		:playcommand("Busy")
	end,
	SongUnchosenMessageCommand=function(self)			
		self:stoptweening():easeoutexpo(0.5):vanishpoint(SCREEN_CENTER_X, SCREEN_BOTTOM - 150 + curvature):y(SCREEN_HEIGHT / 2 - EntireWheel_SelectingSongY):zoom(1):x(0)
		:playcommand("NotBusy")
	end,
	
	OpenGroupWheelMessageCommand=function(self) IsBusy = true end,
	CloseGroupWheelMessageCommand=function(self, params)
		if params.Silent == false then
			-- Grab the new list of songs from the selected group
			Songs = GroupsList[GroupIndex].SubGroups[SubGroupIndex].Songs
			-- Reset back to the first song of the list
			SongIndex = 1
			GAMESTATE:SetCurrentSong(Songs[SongIndex])
		end
		-- Update wheel yada yada
		UpdateItemTargets(SongIndex)
		MESSAGEMAN:Broadcast("ForceUpdate")
		self:sleep(0.01):queuecommand("NotBusy")
	end,
	
	BusyCommand=function(self) IsBusy = true end,
	NotBusyCommand=function(self) IsBusy = false end,
	
	-- Play song preview (thanks Luizsan)
	Def.Actor {
		CurrentSongChangedMessageCommand=function(self)
			SOUND:StopMusic()
			self:stoptweening():sleep(0.25):queuecommand("PlayMusic")
		end,
		
		PlayMusicCommand=function(self)
			local Song = GAMESTATE:GetCurrentSong()
			if Song then
				if ChartPreview then
					local StepList = Song:GetAllSteps()
					local FirstStep = StepList[1]
					local Duration = FirstStep:GetChartLength()
					SOUND:PlayMusicPart(Song:GetMusicPath(), Song:GetSampleStart(), 
					(Duration - Song:GetSampleStart()), 0, 1, false, false, false, Song:GetTimingData())
				else
					SOUND:PlayMusicPart(Song:GetMusicPath(), Song:GetSampleStart(), 
					Song:GetSampleLength(), 0, 1, false, false, false, Song:GetTimingData())
				end
			end
		end
	},

	Def.Sound {
		File=THEME:GetPathS("MusicWheel", "change"),
		IsAction=true,
		ScrollMessageCommand=function(self) self:play() end
	},

	Def.Sound {
		File=THEME:GetPathS("Common", "Start"),
		IsAction=true,
		MusicWheelStartMessageCommand=function(self) self:play() end
	},
}

-- The Wheel: originally made by Luizsan
for i = 1, WheelSize do

	t[#t+1] = Def.ActorFrame {
		OnCommand=function(self)
			-- Load banner
			UpdateBanner(self:GetChild("Banner"), Songs[Targets[i]])

			-- Set initial position, Direction = 0 means it won't tween
			self:playcommand("Scroll", {Direction = 0})
		end,
		
		ForceUpdateMessageCommand=function(self)
			-- Load banner
			UpdateBanner(self:GetChild("Banner"), Songs[Targets[i]])
			
			--SCREENMAN:SystemMessage(GroupsList[GroupIndex].Name)

			-- Set initial position, Direction = 0 means it won't tween
			self:playcommand("Scroll", {Direction = 0})
		end,
		
		ScrollMessageCommand=function(self,param)
			self:stoptweening()

			-- Calculate position
			local xpos = SCREEN_CENTER_X + (i - WheelCenter) * WheelSpacing

			-- Calculate displacement based on input
			local displace = -param.Direction * WheelSpacing

			-- Only tween if a direction was specified
			local tween = param and param.Direction and math.abs(param.Direction) > 0
			
			-- Adjust and wrap actor index
			i = i - param.Direction
			while i > WheelSize do i = i - WheelSize end
			while i < 1 do i = i + WheelSize end

			-- If it's an edge item, load a new banner. Edge items should never tween
			if i == 1 or i == WheelSize then
				UpdateBanner(self:GetChild("Banner"), Songs[Targets[i]])
			elseif tween then
				self:easeoutexpo(0.4)
			end

			-- Animate!
			self:xy(xpos + displace, SCREEN_CENTER_Y)
			self:rotationy((SCREEN_CENTER_X - xpos - displace) * -WheelRotation)
			self:z(-math.abs(SCREEN_CENTER_X - xpos - displace) * 0.25)
			self:GetChild(""):GetChild("Index"):playcommand("Refresh")
			self:GetChild("FrameForSong"):playcommand("Refresh")
			self:GetChild(""):GetChild("OriginLabel"):playcommand("Refresh")
			self:GetChild(""):GetChild("CategoryQuad"):playcommand("Refresh")
			self:GetChild(""):GetChild("CategoryLabel"):playcommand("Refresh")
		end,


		-- drawing!
		
		Def.Banner {
			Name="Banner",
			SongChosenMessageCommand=function(self)				
				self:stoptweening():easeoutexpo(1):diffusealpha(0)
			end,
			SongUnchosenMessageCommand=function(self)				
				self:stoptweening():easeoutexpo(0.5):diffusealpha(1)
			end
		},
		
		Def.Sprite {
			Name="FrameForSong",
			Texture=THEME:GetPathG("", "MusicWheel/Res43SongFrame"),
			SongChosenMessageCommand=function(self)
				self:stoptweening():easeoutexpo(1):zoomx(1.35):diffusealpha(0)
			end,
			SongUnchosenMessageCommand=function(self)
				self:stoptweening():easeoutexpo(0.5):zoomx(1):diffusealpha(1)
			end,
			RefreshCommand=function(self, param)
				self:diffuse(ColorFromSongGenre_POI(Songs[Targets[i]]))
			end,
		},

		Def.ActorFrame {
			SongChosenMessageCommand=function(self)
				self:visible(false)
			end,
			SongUnchosenMessageCommand=function(self)
				self:visible(true)
			end,
			
			-- quad WheelSongNumber
			Def.Quad {
				InitCommand=function(self)
					self:zoomto(60, 18):addy(73)
					:diffuse(0,0,0,WheelNumberQuad_Alpha)
					:fadeleft(0.3):faderight(0.3)
				end
			},
			-- text WheelSongNumber
			Def.BitmapText {
				Name="Index",
				Font="Montserrat semibold 40px",
				InitCommand=function(self)
					self:addy(73):zoom(0.4):skewx(-0.1):shadowlength(1.5)
				end,
				RefreshCommand=function(self,param) self:settext(Targets[i]):diffuse(ColorFromSongGenre_POI(Songs[Targets[i]])):diffusealpha(WheelNumberText_Alpha) end
			},
			
			-- quad SongOrigin
			Def.Quad {
				InitCommand=function(self)
					self:zoomto(140, 18):addy(-73)
					:diffuse(0,0,0,0.6)
					:fadeleft(0.2):faderight(0.2)
				end
			},
			-- text SongOrigin
			Def.BitmapText {				
				Name="OriginLabel",
				Font="Montserrat semibold 40px",				
				InitCommand=function(self)
					self:addy(-73):zoom(0.4):skewx(-0.1):shadowlength(1.5)
				end,
				
				RefreshCommand=function(self,param)						
					self:diffuse(ColorFromSongOrigin_POI(Songs[Targets[i]])):settext(Songs[Targets[i]]:GetOrigin())
				end
			},
			
			-- quad songCategory
			Def.Quad {
				Name="CategoryQuad",
				InitCommand=function(self)
					self:zoomto(170, 24)
					:diffuse(0,0,0,0.8)
					:fadeleft(0.2):faderight(0.2)
					:rotationz(-20):visible(false)
				end,
				RefreshCommand = function(self, param)
					local visibility = false
					local song_firstTag = FetchFirstTag_POI(Songs[Targets[i]])
					local song_secondTag = FetchSecondTag_POI(Songs[Targets[i]])
					
					if song_firstTag == "SHORTCUT" or song_firstTag == "REMIX" or song_firstTag == "FULLSONG" or song_secondTag == "ANOTHER" then visibility = true end
					
					self:visible(visibility)
				end
			},
			-- text songCategory
			Def.BitmapText {
				Name="CategoryLabel",
				Font="Montserrat semibold 40px",
				InitCommand=function(self)
					self:addy(-1):zoom(0.6):skewx(-0.1):shadowlength(1.5):rotationz(-20)
				end,
				RefreshCommand = function(self, param)
					local song_firstTag = FetchFirstTag_POI(Songs[Targets[i]])
					local song_secondTag = FetchSecondTag_POI(Songs[Targets[i]])
					local outputText = ""
					local colour = GetColor_POI("Black")
					
					if song_firstTag == "SHORTCUT" then
						outputText = "SHORT CUT"
						colour = GetColor_POI(song_firstTag)
					elseif song_firstTag == "REMIX" then
						outputText = "REMIX"
						colour = GetColor_POI(song_firstTag)
					elseif song_firstTag == "FULLSONG" then
						outputText = "FULL SONG"
						colour = GetColor_POI(song_firstTag)
					elseif song_secondTag == "ANOTHER" then
						outputText = "ANOTHER"
						colour = GetColor_POI(song_secondTag)
					end
					
					self:diffuse(colour):settext(outputText)
				end
			},
		}
	}
end


return t