local FrameW = 620
local FrameH = 76

local t = Def.ActorFrame {
	InitCommand=function(self)
		local Song = GAMESTATE:GetCurrentSong()
		if Song then
			local TitleText = Song:GetDisplayFullTitle()
			if TitleText == "" then TitleText = "Unknown" end

			local AuthorText = Song:GetDisplayArtist()
			if AuthorText == "" then AuthorText = "Unknown" end

			local BPMRaw = Song:GetDisplayBpms()
			local BPMLow = math.ceil(BPMRaw[1])
			local BPMHigh = math.ceil(BPMRaw[2])
			local BPMDisplay = (BPMLow == BPMHigh and BPMHigh or BPMLow .. "-" .. BPMHigh)
			if Song:IsDisplayBpmRandom() or BPMDisplay == 0 then BPMDisplay = "???" end
							
			local FirstTag = ""
			FirstTag = FetchFirstTag_POI(Song)
			local HeartsCost = ""
			if FirstTag == "SHORTCUT" then HeartsCost = 1 
			elseif FirstTag == "ARCADE" then HeartsCost = 2 
			elseif FirstTag == "REMIX" then HeartsCost = 3 
			elseif FirstTag == "FULLSONG" then HeartsCost = 4  
			end
			HeartsCost = "x " .. HeartsCost
			
			self:GetChild("Title"):settext(TitleText)
			self:GetChild("Artist"):settext(AuthorText)
			self:GetChild("Length"):settext(HeartsCost)
			self:GetChild("BPM"):settext(BPMDisplay .. " BPM")
		else
			self:GetChild("Title"):settext("")
			self:GetChild("Artist"):settext("")
			self:GetChild("Length"):settext("")
			self:GetChild("BPM"):settext("")
		end
	end,
	
	RefreshCommand=function(self)
		local Song = GAMESTATE:GetCurrentSong()
		if Song then
			local TitleText = Song:GetDisplayFullTitle()
			if TitleText == "" then TitleText = "Unknown" end

			local AuthorText = Song:GetDisplayArtist()
			if AuthorText == "" then AuthorText = "Unknown" end

			local BPMRaw = Song:GetDisplayBpms()
			local BPMLow = math.ceil(BPMRaw[1])
			local BPMHigh = math.ceil(BPMRaw[2])
			local BPMDisplay = (BPMLow == BPMHigh and BPMHigh or BPMLow .. "-" .. BPMHigh)
			if Song:IsDisplayBpmRandom() or BPMDisplay == 0 then BPMDisplay = "???" end
							
			local FirstTag = ""
			FirstTag = FetchFirstTag_POI(Song)
			local HeartsCost = ""
			if FirstTag == "SHORTCUT" then HeartsCost = 1 
			elseif FirstTag == "ARCADE" then HeartsCost = 2 
			elseif FirstTag == "REMIX" then HeartsCost = 3 
			elseif FirstTag == "FULLSONG" then HeartsCost = 4  
			end
			HeartsCost = "x " .. HeartsCost

			self:GetChild("Title"):settext(TitleText)
			self:GetChild("Artist"):settext(AuthorText)
			self:GetChild("Length"):settext(HeartsCost)
			self:GetChild("BPM"):settext(BPMDisplay .. " BPM")
		else
			self:GetChild("Title"):settext("")
			self:GetChild("Artist"):settext("")
			self:GetChild("Length"):settext("")
			self:GetChild("BPM"):settext("")
		end
	end,

	Def.Sprite {
		Texture=THEME:GetPathG("", "Evaluation/EvalSongInfo"),    },

	Def.BitmapText {
		Font="Montserrat semibold 40px",
		Name="Title",
		InitCommand=function(self)
			self:zoom(0.8):valign(0)
			:maxwidth(FrameW * 0.89 / self:GetZoom())
			:diffuse(Color.Black)
			:y(-33)
		end
	},

	--separator between artist and bpm
	Def.BitmapText {
		Font="Montserrat normal 20px",
		Name="Separator",
		Text="·",
		InitCommand=function(self)
			self:zoom(1):valign(1)			
			:maxwidth(FrameW * 0.5 / self:GetZoom())
			:diffuse(Color.Black)
			:y(16)
		end
	},
	
	Def.BitmapText {
		Font="Montserrat normal 20px",
		Name="Artist",
		InitCommand=function(self)
			self:zoom(1):valign(1)
			:halign(1):x(-10)
			:maxwidth(FrameW * 0.5 / self:GetZoom())
			:diffuse(Color.Black)
			:y(16)
		end
	},
	
	Def.BitmapText {
		Font="Montserrat normal 20px",
		Name="BPM",
		InitCommand=function(self)
			self:zoom(1):halign(0):valign(1)
			:maxwidth(130)
			:diffuse(Color.Black)
			:xy(10, 16)
		end
	},
	
	-- currently disabled since the Hearts system is NYI
	Def.Sprite {
		Texture=THEME:GetPathG("", "UI/Heart"),
		InitCommand=function(self)
			self:xy(FrameW / 2 - 80, 10):zoom(0.3):diffuse(Color.Black)
			:visible(false)
		end,
	},
	
	-- currently disabled since the Hearts system is NYI
	Def.Sprite {
		Texture=THEME:GetPathG("", "UI/Heart"),
		InitCommand=function(self)
			self:xy(FrameW / 2 - 82, 9):zoom(0.3)
			:visible(false)
		end,
	},
	
	-- currently disabled since the Hearts system is NYI
	Def.BitmapText {
		Font="Montserrat normal 20px",
		Name="Length",
		InitCommand=function(self)
			self:zoom(1):halign(1):valign(1)
			:maxwidth(FrameW * 0.2 / self:GetZoom())
			:diffuse(Color.Black)
			:xy(FrameW / 2 - 36, 16)
			:visible(false)
		end
	}		
}


return t