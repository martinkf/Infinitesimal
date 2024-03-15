function ChartTypeToColorPOI(Chart)
	-- returns: a COLOR
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