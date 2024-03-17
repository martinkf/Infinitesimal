-- ================================================================================================================= RETURNS A STRING (RELATED TO COLOR) 
-- takes: a Chart
-- returns: a string related to color, for example: ["#FF00FF"]
-- based on: the Chart style (single, half-double, double)
-- HAS HARD-CODED CONTENT -- HAS HARD-CODED CONTENT -- HAS HARD-CODED CONTENT -- HAS HARD-CODED CONTENT -- HAS HARD-CODED CONTENT -- HAS HARD-CODED CONTENT -- HAS HARD-CODED CONTENT -- HAS HARD-CODED CONTENT -- HAS HARD-CODED CONTENT
function ChartTypeToColor_POI(Chart)	
    local ChartMeter = Chart:GetMeter()
    local ChartDescription = Chart:GetDescription()
    local ChartType = ToEnumShortString(ToEnumShortString(Chart:GetStepsType()))
	
	local ChartDescriptionText = Chart:GetChartName()
	local ChartNameFromDesc = ""
	local ChartOriginFromDesc = ""
	local openParen = ChartDescriptionText:find("%(")
	local closeParen = ChartDescriptionText:find("%)")
	ChartNameFromDesc = ChartDescriptionText:sub(1, openParen - 2)
	ChartOriginFromDesc = ChartDescriptionText:sub(openParen + 1, closeParen - 1)

	--[[
    if ChartType == "Single" then
		if ChartNameFromDesc:sub(1, 3) == "IDK" then
			return color("#333333") --gray
		elseif ChartMeter <= 3 then
			return color("#ff77aa")
		elseif ChartMeter <= 6 then
			return color("#ffbb33")
		elseif ChartMeter <= 10 then
			return color("#ff9000")
		elseif ChartMeter <= 14 then
			return color("#ff6000")
		elseif ChartMeter <= 18 then
			return color("#ff2b00")
		elseif ChartMeter <= 22 then
			return color("#c80000")
		else -- 23+
			return color("#880000")
		end
	elseif ChartType == "Halfdouble" then
		if ChartNameFromDesc:sub(1, 3) == "IDK" then
			return color("#333333") --gray
		else
			return color("#00ffff")
		end
	elseif ChartType == "Double" then
		if ChartNameFromDesc:sub(1, 3) == "IDK" then
			return color("#333333") --gray
		elseif ChartMeter <= 3 then
			return color("#9977ff")
		elseif ChartMeter <= 6 then
			return color("#00ffa8")
		elseif ChartMeter <= 10 then
			return color("#00e469")
		elseif ChartMeter <= 14 then
			return color("#00c251")
		elseif ChartMeter <= 18 then
			return color("#00aa39")
		elseif ChartMeter <= 22 then
			return color("#007f00")
		else -- 23+
			return color("#005500")
		end
	else
		return color("#9199D4") -- greyed-out lilac
	end	
	return color("#9199D4") -- greyed-out lilac
	]]
	
	if ChartType == "Single" then
		if ChartNameFromDesc:sub(1, 3) == "IDK" then
			return color("#333333") --gray
		else		
			return color("#ff871f")
		end
	elseif ChartType == "Halfdouble" then
		if ChartNameFromDesc:sub(1, 3) == "IDK" then
			return color("#333333") --gray
		else
			return color("#00ffff")
		end
	elseif ChartType == "Double" then
		if ChartNameFromDesc:sub(1, 3) == "IDK" then
			return color("#333333") --gray		
		else
			return color("#21db30")
		end
	else
		return color("#9199D4") -- greyed-out lilac
	end	
	return color("#9199D4") -- greyed-out lilac
end



-- ================================================================================================================= RETURNS A STRING (RELATED TO SONG) 
-- takes: a Song
-- returns: a string, from the list of the following:
-- ARCADE, REMIX, FULLSONG, SHORTCUT
-- based on: the first keyword present in the TAGS attribute in the SSC
function FetchFirstTag_POI(inputSong)
	local output = ""
	
	local fullTagAttribute = inputSong:GetTags()
	
	if fullTagAttribute ~= "" then
		local words = {} -- array of strings, one for each separate word
		for thisWord in fullTagAttribute:gmatch("%S+") do
			table.insert(words, thisWord)
		end		
		output = words[1] -- gets the first word in that array
	end
	
	return output
end

-- takes: a Song
-- returns: a string, from the list of the following:
-- ANOTHER
-- based on: the second keyword present in the TAGS attribute in the SSC
function FetchSecondTag_POI(inputSong)
	local output = ""
	
	local fullTagAttribute = inputSong:GetTags()
	
	if fullTagAttribute ~= "" then
		local words = {} -- array of strings, one for each separate word
		for thisWord in fullTagAttribute:gmatch("%S+") do
			table.insert(words, thisWord)
		end	
		
		-- Check if the words table has more than one element
		if #words >= 2 then
			output = words[2] -- gets the second word in that array		
		end
	end
	
	return output
end



-- ================================================================================================================= RETURNS A STRING (RELATED TO CHART) 
-- takes: (1) a Chart
-- takes: (2) an int, as follows:
-- 1 if you want the Chart POI Name returned, 2 if you want the Chart Origin returned
-- returns: a string, for example: ["EXTRA EXPERT"] for a Chart POI Name, or ["Extra"] for a Chart Origin
-- based on: the CHARTNAME in the SSC of that chart - it either returns the first or the second part, which are separated by parenthesis
function FetchChartNameOrOriginFromChart(inputChart, inputInt)
	local output = ""
    
    local ChartFullChartnameFromSSC = inputChart:GetChartName()
    local ChartPOIName = ""
    local ChartOrigin = ""
    local openParen = ChartFullChartnameFromSSC:find("%(")
    local closeParen = ChartFullChartnameFromSSC:find("%)")
    ChartPOIName = ChartFullChartnameFromSSC:sub(1, openParen - 2)
    ChartOrigin = ChartFullChartnameFromSSC:sub(openParen + 1, closeParen - 1)
    
    if inputInt == 1 then
        output = ChartPOIName
    elseif inputInt == 2 then
        output = ChartOrigin
    end
    
    return output
end



-- ================================================================================================================= RETURNS AN ARRAY OF STRINGS (RELATED TO SONG) 
-- takes: a string related to what kind of list you want returned, from the list of the following:
-- AllSongs, Arcades, Remixes, Fullsongs, Shortcuts, Anothers
-- returns: an array of strings listing SongFolder names, for example: ["101 - IGNITION STARTS","102 - HYPNOSIS"]
-- based on: hard-coded lists
-- HAS HARD-CODED CONTENT -- HAS HARD-CODED CONTENT -- HAS HARD-CODED CONTENT -- HAS HARD-CODED CONTENT -- HAS HARD-CODED CONTENT -- HAS HARD-CODED CONTENT -- HAS HARD-CODED CONTENT -- HAS HARD-CODED CONTENT -- HAS HARD-CODED CONTENT
function ReturnStringFolderList_POI(inputOption)
	local output_list = nil
	
	if inputOption == "AllSongs" then
		output_list = {
		"101 - IGNITION STARTS","102 - HYPNOSIS","103 - FOREVER LOVE","104 - PASSION","105 - BLACK CAT","106 - POM POM POM","107 - THE RAP","108 - COME TO ME","109 - FUNKY TONIGHT","110 - WHAT DO U REALLY WANT",
		"111 - HATRED","112 - ANOTHER TRUTH","113 - I WANT U","114 - I DON'T KNOW ANYTHING","115 - NO PARTICULAR REASON","201 - CREAMY SKINNY","202 - HATE","203 - KOUL","204 - FINAL AUDITION","205 - EXTRAVAGANZA",
		"206 - REWIND","207 - I-YAH","208 - FIGHTING SPIRITS","210 - LOVE","211 - PLEASE","212 - COM'BACK","213 - MOBIUS STRIP","214 - FEVER","215 - CURIOSITY","216 - LOVE","217 - TELL ME TELL ME","218 - HEART BREAK",
		"301 - FINAL AUDITION 2","302 - NAISSANCE","303 - TURKEY MARCH","304 - WITH MY LOVER","305 - AN INTERESTING VIEW","306 - NIGHTMARE","307 - CLOSE YOUR EYES","308 - FREE STYLE","309 - MIDNIGHT BLUE","310 - SHE LIKES PIZZA",
		"311 - PUMPING UP","312 - DON'T BOTHER ME","313 - LOVE SONG","314 - LOVER'S GRIEF","315 - TO THE TOP","316 - SEPARATION WITH HER","317 - PUYO PUYO","318 - WE ARE","319 - TIME TO SAY GOODBYE","320 - TELL ME",
		"321 - OK OK (BEAUTY AND THE BEAST)","401 - OH! ROSA","A26 - OH! ROSA (SPANISH VER.)","402 - FIRST LOVE","A27 - FIRST LOVE (SPANISH VER.)","403 - BETRAYER","404 - SOLITARY","405 - MR. LARPUS","406 - SAD SALSA",
		"407 - SUMMER OF LOVE","408 - KISS","409 - MAN & WOMAN","410 - FIRST LOVE","411 - A TRAP","412 - DISCO BUS","413 - RUN!","414 - RUN TO YOU","501 - PUMP JUMP","502 - N","503 - ROLLING CHRISTMAS","504 - ALL I WANT FOR X-MAS",
		"505 - BEETHOVEN VIRUS","506 - I WILL ACCEPT YOU","507 - COME BACK TO ME","508 - AS I TOLD YOU","509 - I KNOW","510 - MY FANTASY","511 - UNFORGETTABLE MEMORY","512 - HAYUGA","513 - CERTAIN VICTORY","514 - ULTRAMANIA",
		"515 - BONACCIA","516 - SLAM","517 - SPACE FANTASY","922 - FINAL AUDITION EPISODE 1","911 - CHICKEN WING","912 - HOLIDAY","913 - RADEZKY CAN CAN","901 - FLOWER OF NIGHT","902 - CIRCUS MAGIC","903 - MOVE YOUR HEAD","904 - TRASH MAN",
		"919 - LAZENCA, SAVE US","905 - FUNKY JOCKEY","906 - STARIAN","907 - BIG MONEY","908 - WAYO WAYO","909 - MISTAKE","910 - THE RAP ACT 3","914 - WISH YOU COULD FIND","915 - LONER","916 - MONKEY MAGIC","917 - OUT OF THE RING",
		"921 - PIERROT","918 - BLIND FAITH","920 - FERRY BOAT","923 - FIRST LOVE (TECHNO MIX)","601 - OOPS I DID IT AGAIN","602 - BYE BYE BYE","603 - I NEED TO KNOW","604 - LET'S GET LOUD","605 - MAMBO #5","606 - TAKE ON ME",
		"611 - A CERCA","612 - DE VOLTA AO PLANETA","616 - SEMPRE ASSIM","613 - PENSAMENTO","614 - POPOZUDA ROCK N' ROLL","615 - REBOLA NA BOA","617 - UMA BOMBA","618 - VAQUEIRO BOM DEMAIS","735 - VOOK","736 - CSIKOS POST","701 - DR. M",
		"702 - EMPEROR","703 - GET YOUR GROOVE ON","704 - LOVE IS A DANGER ZONE","705 - MARIA","706 - MISSION POSSIBLE","707 - MY WAY","708 - POINT BREAK","709 - STREET SHOW DOWN","710 - TOP CITY","711 - WINTER","712 - WILL O' THE WISP",
		"713 - TILL THE END OF TIME","714 - OY OY OY","715 - WE WILL MEET AGAIN","716 - MISS'S STORY","717 - SET ME UP","718 - DANCE WITH ME","719 - GO AWAY","726 - RUNAWAY","720 - I LOVE YOU","721 - GOTTA BE KIDDING!","722 - ZZANGA",
		"729 - Y","723 - A PRISON WITHOUT BARS","727 - SWING BABY","724 - A WHISTLE","725 - GENTLEMAN QUALITY","728 - TEMPTATION","730 - PERFECT","731 - LET'S BOOGIE","732 - MY BEST DAY IS GONE","733 - THE WAVES","734 - ALWAYS",
		"802 - BEE","807 - D GANG","811 - HELLO","820 - BEAT OF THE WAR","803 - BURNING KRYPT","804 - CAN YOU FEEL DIS OR DAT","808 - DJ NIGHTMARE","819 - YOU DON'T WANNA RUNUP","801 - BAMBOLE","805 - CLAP YOUR HANDS","806 - CONGA",
		"809 - ERES PARA MI","818 - MEXI MEXI","810 - FIEST A MACARENA PT. 1","812 - ON YOUR SIDE","813 - EVERYBODY","814 - JOIN THE PARTY","815 - LAY IT DOWN","816 - LET THE SUNSHINE","817 - LOVETHING","826 - COME TO ME",
		"821 - EMPIRE OF THE SUN","823 - LET'S GET THE PARTY STARTED","828 - MASTER OF PUPPETS","822 - JUST A GIRL","824 - OBJECTION","825 - IT'S MY PARTY","827 - MUSIC","A01 - FINAL AUDITION 3 U.F","A02 - NAISSANCE 2","A03 - MONKEY FINGERS",
		"A04 - BLAZING","A05 - PUMP ME AMADEUS","A06 - X-TREAM","A07 - GET UP!","A08 - DIGNITY","B51 - DIGNITY -FULL SONG-","A11 - WHAT DO U REALLY WANT","A09 - SHAKE THAT BOOTIE","A10 - VALENTI","A12 - GO","A13 - FLAMENCO","A19 - ONE LOVE",
		"A14 - KISS ME","A15 - ESSA MANEIRA","A16 - BA BEE LOO BE RA","A17 - LA CUBANITA","A18 - SHAKE IT UP","A20 - POWER OF DREAM","A21 - WATCH OUT","A22 - FIESTA","A23 - SOCA MAKE YUH RAM RAM","A24 - BORN TO BE ALIVE","A25 - XIBOM BOMBOM",
		"AE01 - A LITTLE LESS CONVERSATION","AE03 - LET'S GROOVE","AE04 - NAME OF THE GAME","AE05 - RAPPER'S DELIGHT","AE06 - WALKIE TALKIE MAN","B16 - J BONG","B17 - HI-BI","B18 - SOLITARY 2","B19 - CANON-D","B57 - CANON-D -FULL SONG-",
		"B01 - GREENHORN","B02 - HOT","B03 - PRAY","B06 - DEJA VU","B04 - GO AWAY","B05 - DRUNKEN IN MELODY","B07 - U","B08 - SAJAHU (LION'S ROAR)","B09 - TYPHOON","B10 - ETERNITY","B11 - FOXY LADY","B12 - TOO LATE","B13 - I'LL GIVE YOU ALL MY LOVE",
		"B14 - HUU YAH YEAH","B15 - WE DON'T STOP","B20 - LE CODE DE BONNE CONDUITE",
		"116 - -REMIX- 1ST DIVA REMIX","117 - -REMIX- 1ST DISCO REMIX","118 - -REMIX- 1ST TECHNO REMIX","119 - -REMIX- TURBO REMIX","120 - -REMIX- 1ST BATTLE HIP-HOP","121 - -REMIX- 1ST BATTLE DISCO","122 - -REMIX- 1ST BATTLE TECHNO",
		"123 - -REMIX- 1ST BATTLE HARDCORE","219 - -REMIX- JO SUNG MO REMIX","220 - -REMIX- UHM JUNG HWA REMIX","221 - -REMIX- DRUNKEN FAMILY REMIX","223 - -REMIX- SM TOWN REMIX","224 - -REMIX- REPEATORMENT REMIX",
		"225 - -REMIX- 2ND HIDDEN REMIX","322 - -REMIX- 3RD O.B.G DIVA REMIX","323 - -REMIX- PARK MEE KYUNG REMIX","324 - -REMIX- BANYA HIP-HOP REMIX","325 - -REMIX- PARK JIN YOUNG REMIX","326 - -REMIX- NOVASONIC REMIX",
		"327 - -REMIX- BANYA HARD REMIX","415 - -REMIX- SECHSKIES REMIX","924 - -REMIX- EXTRA HIP-HOP REMIX","925 - -REMIX- E-PAK-SA REMIX","926 - -REMIX- EXTRA DISCO REMIX","927 - -REMIX- EXTRA DEUX REMIX","928 - -REMIX- EXTRA BANYA MIX",
		"B26 - -REMIX- NOVARASH REMIX","B27 - -REMIX- LEXY & 1TYM REMIX","B28 - -REMIX- TREAM-VOOK OF THE WAR","B29 - -REMIX- BANYA CLASSIC REMIX","B30 - -REMIX- DEUX REMIX","B31 - -REMIX- DIVA REMIX","B50 - -REMIX- THE WORLD REMIX",
		"1059 - EXCEED 2 OPENING -SHORT CUT-",
		}
	elseif inputOption == "Arcades" then
		output_list = {
		"101 - IGNITION STARTS","102 - HYPNOSIS","103 - FOREVER LOVE","104 - PASSION","105 - BLACK CAT","106 - POM POM POM","107 - THE RAP","108 - COME TO ME","109 - FUNKY TONIGHT","110 - WHAT DO U REALLY WANT",
		"111 - HATRED","112 - ANOTHER TRUTH","113 - I WANT U","114 - I DON'T KNOW ANYTHING","115 - NO PARTICULAR REASON","201 - CREAMY SKINNY","202 - HATE","203 - KOUL","204 - FINAL AUDITION","205 - EXTRAVAGANZA",
		"206 - REWIND","207 - I-YAH","208 - FIGHTING SPIRITS","210 - LOVE","211 - PLEASE","212 - COM'BACK","213 - MOBIUS STRIP","214 - FEVER","215 - CURIOSITY","216 - LOVE","217 - TELL ME TELL ME","218 - HEART BREAK",
		"301 - FINAL AUDITION 2","302 - NAISSANCE","303 - TURKEY MARCH","304 - WITH MY LOVER","305 - AN INTERESTING VIEW","306 - NIGHTMARE","307 - CLOSE YOUR EYES","308 - FREE STYLE","309 - MIDNIGHT BLUE","310 - SHE LIKES PIZZA",
		"311 - PUMPING UP","312 - DON'T BOTHER ME","313 - LOVE SONG","314 - LOVER'S GRIEF","315 - TO THE TOP","316 - SEPARATION WITH HER","317 - PUYO PUYO","318 - WE ARE","319 - TIME TO SAY GOODBYE","320 - TELL ME",
		"321 - OK OK (BEAUTY AND THE BEAST)","401 - OH! ROSA","A26 - OH! ROSA (SPANISH VER.)","402 - FIRST LOVE","A27 - FIRST LOVE (SPANISH VER.)","403 - BETRAYER","404 - SOLITARY","405 - MR. LARPUS","406 - SAD SALSA",
		"407 - SUMMER OF LOVE","408 - KISS","409 - MAN & WOMAN","410 - FIRST LOVE","411 - A TRAP","412 - DISCO BUS","413 - RUN!","414 - RUN TO YOU","501 - PUMP JUMP","502 - N","503 - ROLLING CHRISTMAS","504 - ALL I WANT FOR X-MAS",
		"505 - BEETHOVEN VIRUS","506 - I WILL ACCEPT YOU","507 - COME BACK TO ME","508 - AS I TOLD YOU","509 - I KNOW","510 - MY FANTASY","511 - UNFORGETTABLE MEMORY","512 - HAYUGA","513 - CERTAIN VICTORY","514 - ULTRAMANIA",
		"515 - BONACCIA","516 - SLAM","517 - SPACE FANTASY","922 - FINAL AUDITION EPISODE 1","911 - CHICKEN WING","912 - HOLIDAY","913 - RADEZKY CAN CAN","901 - FLOWER OF NIGHT","902 - CIRCUS MAGIC","903 - MOVE YOUR HEAD","904 - TRASH MAN",
		"919 - LAZENCA, SAVE US","905 - FUNKY JOCKEY","906 - STARIAN","907 - BIG MONEY","908 - WAYO WAYO","909 - MISTAKE","910 - THE RAP ACT 3","914 - WISH YOU COULD FIND","915 - LONER","916 - MONKEY MAGIC","917 - OUT OF THE RING",
		"921 - PIERROT","918 - BLIND FAITH","920 - FERRY BOAT","923 - FIRST LOVE (TECHNO MIX)","601 - OOPS I DID IT AGAIN","602 - BYE BYE BYE","603 - I NEED TO KNOW","604 - LET'S GET LOUD","605 - MAMBO #5","606 - TAKE ON ME",
		"611 - A CERCA","612 - DE VOLTA AO PLANETA","616 - SEMPRE ASSIM","613 - PENSAMENTO","614 - POPOZUDA ROCK N' ROLL","615 - REBOLA NA BOA","617 - UMA BOMBA","618 - VAQUEIRO BOM DEMAIS","735 - VOOK","736 - CSIKOS POST","701 - DR. M",
		"702 - EMPEROR","703 - GET YOUR GROOVE ON","704 - LOVE IS A DANGER ZONE","705 - MARIA","706 - MISSION POSSIBLE","707 - MY WAY","708 - POINT BREAK","709 - STREET SHOW DOWN","710 - TOP CITY","711 - WINTER","712 - WILL O' THE WISP",
		"713 - TILL THE END OF TIME","714 - OY OY OY","715 - WE WILL MEET AGAIN","716 - MISS'S STORY","717 - SET ME UP","718 - DANCE WITH ME","719 - GO AWAY","726 - RUNAWAY","720 - I LOVE YOU","721 - GOTTA BE KIDDING!","722 - ZZANGA",
		"729 - Y","723 - A PRISON WITHOUT BARS","727 - SWING BABY","724 - A WHISTLE","725 - GENTLEMAN QUALITY","728 - TEMPTATION","730 - PERFECT","731 - LET'S BOOGIE","732 - MY BEST DAY IS GONE","733 - THE WAVES","734 - ALWAYS",
		"802 - BEE","807 - D GANG","811 - HELLO","820 - BEAT OF THE WAR","803 - BURNING KRYPT","804 - CAN YOU FEEL DIS OR DAT","808 - DJ NIGHTMARE","819 - YOU DON'T WANNA RUNUP","801 - BAMBOLE","805 - CLAP YOUR HANDS","806 - CONGA",
		"809 - ERES PARA MI","818 - MEXI MEXI","810 - FIEST A MACARENA PT. 1","812 - ON YOUR SIDE","813 - EVERYBODY","814 - JOIN THE PARTY","815 - LAY IT DOWN","816 - LET THE SUNSHINE","817 - LOVETHING","826 - COME TO ME",
		"821 - EMPIRE OF THE SUN","823 - LET'S GET THE PARTY STARTED","828 - MASTER OF PUPPETS","822 - JUST A GIRL","824 - OBJECTION","825 - IT'S MY PARTY","827 - MUSIC","A01 - FINAL AUDITION 3 U.F","A02 - NAISSANCE 2","A03 - MONKEY FINGERS",
		"A04 - BLAZING","A05 - PUMP ME AMADEUS","A06 - X-TREAM","A07 - GET UP!","A08 - DIGNITY","A11 - WHAT DO U REALLY WANT","A09 - SHAKE THAT BOOTIE","A10 - VALENTI","A12 - GO","A13 - FLAMENCO","A19 - ONE LOVE",
		"A14 - KISS ME","A15 - ESSA MANEIRA","A16 - BA BEE LOO BE RA","A17 - LA CUBANITA","A18 - SHAKE IT UP","A20 - POWER OF DREAM","A21 - WATCH OUT","A22 - FIESTA","A23 - SOCA MAKE YUH RAM RAM","A24 - BORN TO BE ALIVE","A25 - XIBOM BOMBOM",
		"AE01 - A LITTLE LESS CONVERSATION","AE03 - LET'S GROOVE","AE04 - NAME OF THE GAME","AE05 - RAPPER'S DELIGHT","AE06 - WALKIE TALKIE MAN","B16 - J BONG","B17 - HI-BI","B18 - SOLITARY 2","B19 - CANON-D",
		"B01 - GREENHORN","B02 - HOT","B03 - PRAY","B06 - DEJA VU","B04 - GO AWAY","B05 - DRUNKEN IN MELODY","B07 - U","B08 - SAJAHU (LION'S ROAR)","B09 - TYPHOON","B10 - ETERNITY","B11 - FOXY LADY","B12 - TOO LATE","B13 - I'LL GIVE YOU ALL MY LOVE",
		"B14 - HUU YAH YEAH","B15 - WE DON'T STOP","B20 - LE CODE DE BONNE CONDUITE",
		}
	elseif inputOption == "Remixes" then
		output_list = {
		"116 - -REMIX- 1ST DIVA REMIX","117 - -REMIX- 1ST DISCO REMIX","118 - -REMIX- 1ST TECHNO REMIX","119 - -REMIX- TURBO REMIX","120 - -REMIX- 1ST BATTLE HIP-HOP","121 - -REMIX- 1ST BATTLE DISCO","122 - -REMIX- 1ST BATTLE TECHNO",
		"123 - -REMIX- 1ST BATTLE HARDCORE","219 - -REMIX- JO SUNG MO REMIX","220 - -REMIX- UHM JUNG HWA REMIX","221 - -REMIX- DRUNKEN FAMILY REMIX","223 - -REMIX- SM TOWN REMIX","224 - -REMIX- REPEATORMENT REMIX",
		"225 - -REMIX- 2ND HIDDEN REMIX","322 - -REMIX- 3RD O.B.G DIVA REMIX","323 - -REMIX- PARK MEE KYUNG REMIX","324 - -REMIX- BANYA HIP-HOP REMIX","325 - -REMIX- PARK JIN YOUNG REMIX","326 - -REMIX- NOVASONIC REMIX",
		"327 - -REMIX- BANYA HARD REMIX","415 - -REMIX- SECHSKIES REMIX","924 - -REMIX- EXTRA HIP-HOP REMIX","925 - -REMIX- E-PAK-SA REMIX","926 - -REMIX- EXTRA DISCO REMIX","927 - -REMIX- EXTRA DEUX REMIX","928 - -REMIX- EXTRA BANYA MIX",
		"B26 - -REMIX- NOVARASH REMIX","B27 - -REMIX- LEXY & 1TYM REMIX","B28 - -REMIX- TREAM-VOOK OF THE WAR","B29 - -REMIX- BANYA CLASSIC REMIX","B30 - -REMIX- DEUX REMIX","B31 - -REMIX- DIVA REMIX","B50 - -REMIX- THE WORLD REMIX",
		}
	elseif inputOption == "Fullsongs" then
		output_list = {
		"B51 - DIGNITY -FULL SONG-","B57 - CANON-D -FULL SONG-",
		}
	elseif inputOption == "Shortcuts" then
		output_list = {
		"1059 - EXCEED 2 OPENING -SHORT CUT-",
	}
	elseif inputOption == "Anothers" then
		output_list = {
		"A26 - OH! ROSA (SPANISH VER.)","A27 - FIRST LOVE (SPANISH VER.)",
		}
	else
		output_list = nil
	end
	
	return output_list
end

-- takes: a "POI Nested List"
-- returns: an array of strings listing SongFolder names, for example: ["/Songs/A.1ST~PERFECT/101 - IGNITION STARTS/","/Songs/A.1ST~PERFECT/102 - HYPNOSIS/"]
-- based on: iterating through the input list and obtaining all song dir paths from each song inside it
function GetArrayOfStringsongdirFromPOINestedList_POI(inputPOINestedList)
	local outputList = {}
	for _, innerList in ipairs(inputPOINestedList) do
        table.insert(outputList, innerList[1])
    end
	return outputList
end



-- ================================================================================================================= RETURNS AN ARRAY OF SONG OBJECTS 
-- takes: (1) an array of Songs, usually coming from SONGMAN:GetAllSongs()
-- takes: (2) a string related to what kind of song array you want returned, from the list of the following:
-- "AllSongs" "Arcades" "Remixes "Fullsongs" "Shortcuts"
-- returns: an array of Songs
-- based on: the original array of Songs used for input, but filtered and ordered by the string list provided
function FilterAndOrderSongs_POI(inputArrayOfSongs, inputListType)	
	local output = inputArrayOfSongs
	local customOrder = ReturnStringFolderList_POI(inputListType)
	local reorderedSongs = {}	
	-- Iterate through each ordered element
	for _, folderNameToMatch in ipairs(customOrder) do
		-- Iterate through the songs provided by input
		for _, song in ipairs(inputArrayOfSongs) do
			-- Extract the folder name from the song's directory
			local folderName = song:GetSongDir()
			-- Check if the folder name matches the current folder name to match
			if string.find(folderName, folderNameToMatch, 1, true) then
				-- Add the song to the filtered array
				table.insert(reorderedSongs, song)
			end
		end
	end	
	output = reorderedSongs
	return output
end

-- takes: a string, related to POI Experience versions, from the list of the following:
-- "PIU 'The 1st DF'\nExperience" / "PIU 'The 2nd DF'\nExperience" / etc
-- returns: an array of Songs
-- based on: takes all the songs, filters them according to the input POI Experience version which is hard-coded elsewhere
function GetArrayOfSongsBasedOnExperience(inputExperienceAsString)
	local outputSongArray = {}
	
	local stringArrayOfFolderNamesToMatch = GetArrayOfStringsongdirFromPOINestedList_POI(GetPOINestedList_POI(inputExperienceAsString))		

	-- Iterate through each folder name to match
	for _, folderNameToMatch in ipairs(stringArrayOfFolderNamesToMatch) do
		-- Iterate through all songs
		for _, song in ipairs(SONGMAN:GetAllSongs()) do
			-- Extract the folder name from the song's directory
			local folderName = song:GetSongDir()

			-- Check if the folder name matches the current folder name to match
			if string.find(folderName, folderNameToMatch, 1, true) then
				-- Add the song to the filtered array
				table.insert(outputSongArray, song)
			end
		end
	end
	
	return outputSongArray
end



-- ================================================================================================================= RETURNS AN ARRAY OF CHART OBJECTS 
-- takes: (1) the string related to the current group name
-- takes: (2) the song that's currently being selected by the music wheel
-- takes: (3) the array of Charts of the currently selected song
-- returns: an array of Charts
-- based on: takes into consideration the CurGroupName + which Song we're talking about to look up the POI Experience and filter out charts
-- HAS HARD-CODED CONTENT -- HAS HARD-CODED CONTENT -- HAS HARD-CODED CONTENT -- HAS HARD-CODED CONTENT -- HAS HARD-CODED CONTENT -- HAS HARD-CODED CONTENT -- HAS HARD-CODED CONTENT -- HAS HARD-CODED CONTENT -- HAS HARD-CODED CONTENT
function FilterChartFromGroup_POI(input_CurGroupName,input_CurrentSong,input_ChartArray)
	local outputChartArray = {}		
	outputChartArray = input_ChartArray
	
	local POIExperiencesList = {
		"PIU 'The 1st DF'\nExperience",
		"PIU 'The 2nd DF'\nExperience",
		"PIU 'O.B.G The 3rd'\nExperience",
	}
	
	local found = false
	for _, experience in ipairs(POIExperiencesList) do
		if experience:find(input_CurGroupName) then
			found = true
			break
		end
	end
	
	local poiExperienceNestedList = {{}}
	if found then
		poiExperienceNestedList = GetPOINestedList_POI(input_CurGroupName)
	else -- handle the case where the input group name doesn't have a corresponding POI Experience string
		return input_ChartArray -- in other words, skip this entire thing altogether
	end	

	local currentSongDir = input_CurrentSong:GetSongDir()		
	-- Find the sublist corresponding to the current song
	local allowedDescriptions = {}
	for _, sublist in ipairs(poiExperienceNestedList) do
		if sublist[1] == currentSongDir then
			-- Collect allowed descriptions
			allowedDescriptions = {unpack(sublist, 2)}
			break
		end
	end		
	
	-- Remove charts whose descriptions are not in the allowed list
	for i = #outputChartArray, 1, -1 do
		local description = outputChartArray[i]:GetDescription()
		if not table.find(allowedDescriptions, description) then
			table.remove(outputChartArray, i)
		end
	end
	
	return outputChartArray
end



-- ================================================================================================================= RETURNS A POI NESTED LIST 
-- takes: a string, related to POI Experience versions, from the list of the following:
-- "PIU 'The 1st DF'\nExperience" / "PIU 'The 2nd DF'\nExperience" / etc
-- returns: a "POI Nested List" - list of lists containing songs and charts inside songs
-- based on: hard-coded list of POI Experiences
-- HAS HARD-CODED CONTENT -- HAS HARD-CODED CONTENT -- HAS HARD-CODED CONTENT -- HAS HARD-CODED CONTENT -- HAS HARD-CODED CONTENT -- HAS HARD-CODED CONTENT -- HAS HARD-CODED CONTENT -- HAS HARD-CODED CONTENT -- HAS HARD-CODED CONTENT
function GetPOINestedList_POI(inputExperienceAsString)
	local outputNestedList = {{},{}}
    
	if inputExperienceAsString == "PIU 'The 1st DF'\nExperience" then
        outputNestedList = {
            {
				"/Songs/A.1ST~PERFECT/101 - IGNITION STARTS/",
				"1ST-HARD",
				"1ST-FREESTYLE",
				--"PREX3-CRAZY",
			},
            {
				"/Songs/A.1ST~PERFECT/102 - HYPNOSIS/",
				"1ST-HARD",
				"1ST-FREESTYLE",
				--"PREX3-CRAZY",
				--"PREX3-NIGHTMARE",
			},
			{
				"/Songs/A.1ST~PERFECT/103 - FOREVER LOVE/",
				"1ST-NORMAL",
			},
			{
				"/Songs/A.1ST~PERFECT/104 - PASSION/",
				"1ST-NORMAL",
				"1ST-HARD",
				"1ST-FREESTYLE",
			},
        }
    elseif inputExperienceAsString == "PIU 'The 2nd DF'\nExperience" then
        outputNestedList = {
            {
				"/Songs/A.1ST~PERFECT/201 - CREAMY SKINNY/",
				"2ND-NORMAL",
				"2ND-FREESTYLE",
			},
            {
				"/Songs/A.1ST~PERFECT/202 - HATE/",
				"2ND-NORMAL",
				"2ND-HARD",
				"2ND-FREESTYLE",
			},
			{
				"/Songs/A.1ST~PERFECT/203 - KOUL/",
				"2ND-HARD",
				"2ND-FREESTYLE",
				--"PREX3-CRAZY",
			},
			{
				"/Songs/A.1ST~PERFECT/204 - FINAL AUDITION/",
				"2ND-HARD",
				"2ND-FREESTYLE",
				--"PERF-NORMAL",
				--"PREX3-CRAZY",
				--"PREX3-FREESTYLE",
				--"PREX3-NIGHTMARE",
			},
        }
    elseif inputExperienceAsString == "PIU 'O.B.G The 3rd'\nExperience" then
        outputNestedList = {
            {
				"/Songs/A.1ST~PERFECT/301 - FINAL AUDITION 2/",
				"3RD-HARD",
				"3RD-CRAZY",
				"3RD-FREESTYLE",
			},
            {
				"/Songs/A.1ST~PERFECT/302 - NAISSANCE/",
				"3RD-HARD",
				"3RD-CRAZY",
				"3RD-FREESTYLE",
			},
        }
    else        
        return {{}}
    end
	
	return outputNestedList
end













