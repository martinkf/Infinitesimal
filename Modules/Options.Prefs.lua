local Rates = {
    Val = {},
    Str = {},
}
for i = 0.3, 2.01, 0.01 do
    table.insert( Rates.Val, string.format( "%.2f",i ) )
    table.insert( Rates.Str, string.format( "%.2fx",i ) )
end
--table.insert( Rates.Str, "Haste" )
--table.insert( Rates.Val, "haste" )


return {
    AutoVelocityType =
    {
        UserPref = true,
        Default = false,
        Choices = { OptionNameString('Multiply'), OptionNameString('Automatic'), OptionNameString('Constant') },
        Values = { false, "Auto", "Constant" }
    },
    ScreenFilter =
    {
        UserPref = true,
        Default = 0,
        Choices = { THEME:GetString('OptionNames','Off'), '0.1', '0.2', '0.3', '0.4', '0.5', '0.6', '0.7', '0.8', '0.9', '1.0' },
        Values = { 0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1 }
    },
    ScreenFilterColor =
    {
        UserPref = true,
        Default = 2, -- Since the filter is now full screen by default, it makes more sense making it black.
        Choices = { OptionNameString('DarkPlayerScreenFilter'), OptionNameString('DarkScreenFilter'), OptionNameString('LightPlayerScreenFilter'), OptionNameString('LightScreenFilter'), OptionNameString('GrayScreenFilter') },
        Values = {1,2,3,4,5}
    },
    ScreenFilterSize =
    {
        UserPref = true,
        Default = "Full",
        Choices = { OptionNameString('ScreenFilterFull'), OptionNameString('ScreenFilterLane') },
        Values = { "Full", "Lane" }
    },
    MeasureCounter =
    {
        UserPref = true,
        Default = false,
        Choices = { OptionNameString('Off'), OptionNameString('StreamOnly'), OptionNameString('All') },
        Values = {false, 'StreamOnly', 'All' }
    },
    JudgmentItems =
    {
        UserPref = true,
        SelectMultiple = true,
        Default = false,
        Choices = { OptionNameString('OffsetBar'), OptionNameString('ProTiming'), OptionNameString('HideJudgment') },
        Values = { "OffsetBar", "ProTiming", "HideJudgment" }
    },
    SmartJudgments =
    {
        UserPref = true,
        OneInRow = true,
        Default = THEME:GetMetric("Common","DefaultJudgment"),
        Choices = LoadModule("Options.SmartJudgeChoices.lua")(),
        Values = LoadModule("Options.SmartJudgeChoices.lua")("Value"),
    },
    SmartTimings =
    {
        GenForOther = {"SmartJudgments", LoadModule("Options.SmartJudgeChoices.lua")},
        GenForUserPref = true,
        Default = TimingModes[3],
        Choices = TimingModes,
        Values = TimingModes
    },
    LuaNoteSkins =
    {
        Default = "default",
        UserPref = true,
        OneInRow = true,
        Choices = NOTESKIN:GetNoteSkinNames(),
        Values = NOTESKIN:GetNoteSkinNames(),
        LoadFunction = function(self,list,pn)
            local CurNoteSkin = GAMESTATE:GetPlayerState(pn):GetPlayerOptions("ModsLevel_Preferred"):NoteSkin()
            for i,v2 in ipairs(self.Choices) do
                if string.lower(tostring(v2)) == string.lower(tostring(CurNoteSkin)) then
                    list[i] = true return
                end
            end
            list[1] = true
        end,
        SaveFunction = function(self,list,pn)
            for i,v2 in ipairs(self.Choices) do
                if list[i] then
                    GAMESTATE:GetPlayerState(pn):GetPlayerOptions("ModsLevel_Preferred"):NoteSkin(v2)
                end
            end
        end,
    },

    -- Infinitesimal mods
    ScoreDisplay =
    {
        UserPref = true,
        Default = false,
        Choices = { OptionNameString('Off'), OptionNameString('Score'), OptionNameString('Percent') },
        Values = {false, "Score", "Percent"}
    },
    SongProgress =
    {
        UserPref = true,
        Default = false,
        Choices = { OptionNameString('Off'), OptionNameString('On') },
        Values = {false, true}
    },
	ProLifebar =
    {
		UserPref = true,
        Default = false,
        Choices = { OptionNameString('Off'), OptionNameString('On') },
        Values = {false, true}
    },
    BasicMode =
    {
        Default = true,
        Choices = { OptionNameString('Off'), OptionNameString('On') },
        Values = {false, true}
    },
    CenterChartList =
    {
        Default = true,
        Choices = { OptionNameString('Off'), OptionNameString('On') },
        Values = {false, true}
    },
    ChartPreview =
    {
        Default = false,
        Choices = { OptionNameString('Off'), OptionNameString('On') },
        Values = {false, true}
    },
    ImagePreviewOnly =
    {
        Default = false,
        Choices = { OptionNameString('Off'), OptionNameString('On') },
        Values = {false, true}
    },
    UseSelToPause =
    {
        Default = false,
        Choices = { OptionNameString('Off'), OptionNameString('On') },
        Values = {false, true}
    },
    UseVideoBackground =
    {
        Default = true,
        Choices = { OptionNameString('Off'), OptionNameString('On') },
        Values = {false, true}
    },
    EvalCenter3xExit =
    {
        Default = false,
        Choices = { OptionNameString('Off'), OptionNameString('On') },
        Values = {false, true}
    },
    ShowBigBall =
    {
        Default = false,
        Choices = { OptionNameString('Off'), OptionNameString('On') },
        Values = {false, true}
    },
    ShowUCSCharts =
    {
        Default = true,
        Choices = { OptionNameString('Off'), OptionNameString('On') },
        Values = {false, true}
    },
    ShowQuestCharts =
    {
        Default = true,
        Choices = { OptionNameString('Off'), OptionNameString('On') },
        Values = {false, true}
    },
    ShowHiddenCharts =
    {
        Default = true,
        Choices = { OptionNameString('Off'), OptionNameString('On') },
        Values = {false, true}
    },
    AutogenBasicMode =
    {
        Default = true,
        Choices = { OptionNameString('Off'), OptionNameString('On') },
        Values = {false, true}
    },
    WrapChartScroll =
    {
        Default = false,
        Choices = { OptionNameString('Off'), OptionNameString('On') },
        Values = {false, true}
    },
    StarField =
    {
        Default = false,
        Choices = { OptionNameString('Off'), OptionNameString('On') },
        Values = {false, true}
    },
    ScoringSystem =
    {
        Default = "Old",
        Choices = { OptionNameString('Old'), OptionNameString('New') },
        Values = { "Old", "New" }
    },
    ClassicGrades =
    {
        Default = false,
        Choices = { OptionNameString('Off'), OptionNameString('On') },
        Values = {false, true}
    },
    LifePositionBelow =
    {
        Default = false,
        Choices = { OptionNameString('Off'), OptionNameString('On') },
        Values = {false, true}
    },
    CarryJudgment =
    {
        Default = false,
        Choices = { OptionNameString('Off'), OptionNameString('On') },
        Values = {false, true}
    },
	ActivatePOIProjectUX =
    {
        Default = false,
        Choices = { OptionNameString('Off'), OptionNameString('On') },
        Values = {false, true}
    },
    -- System Related Options
	VideoRenderer =
	{
		Choices = {"GLAD", "OpenGL"},
		Values = {"glad", "opengl"},
		LoadFunction = function(self,list)
			local savedRender = PREFSMAN:GetPreference("VideoRenderers")
			for i,v2 in ipairs(self.Values) do
				if savedRender == v2 then list[i] = true return end
			end
			list[1] = true
		end,
		SaveFunction = function(self,list)
			for i,v2 in ipairs(self.Values) do
				if list[i] then PREFSMAN:SetPreference("VideoRenderers",v2) return end
			end
		end
	},
    NoteFieldLength =
	{
		Default = SCREEN_HEIGHT,
		Choices = {"Normal", "Long"},
		Values = {SCREEN_HEIGHT, 9000},
	}
}
