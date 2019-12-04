local function calculateMean(dataSetList, len)
	local total = 0
	local startIndex = (len and #dataSetList-len > 1) and #dataSetList-len or 1
	for i = startIndex, #dataSetList do
		local value = dataSetList[i]
		total = total + value.Y
	end
	return total / ((#dataSetList-startIndex)+1)
end

local function calculateAverageDeviation(dataSetList, len)
	local mean = calculateMean(dataSetList, len)

	local total = 0
	local startIndex = (len and #dataSetList-len >= 1) and #dataSetList-len or 1
	for i = startIndex, #dataSetList do
		local value = dataSetList[i]
		total = total + math.abs(value.Y - mean)
	end
	return total / ((#dataSetList-startIndex)+1)
end

local function calculateStandardDeviation(dataSetList, len)
	local mean = calculateMean(dataSetList, len)
	local total = 0
	local startIndex = (len and #dataSetList-len >= 1) and #dataSetList-len or 1
	for i = startIndex, #dataSetList do
		local value = dataSetList[i]
		total = total + (value.Y - mean)*(value.Y - mean)
	end
	return #dataSetList > 1 and math.sqrt(total / ((#dataSetList-startIndex))) or 0
end

local Statistics = {
	calculateStandardDeviation = calculateStandardDeviation,
	calculateAverageDeviation = calculateAverageDeviation,
	calculateMean = calculateMean,
}

return Statistics
