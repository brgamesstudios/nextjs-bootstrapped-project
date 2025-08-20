Utils = {}

-- Debug logging
function Utils.Debug(message)
    if Config.Debug then
        print('^3[' .. Config.ResourceName .. ']^7 ' .. message)
    end
end

-- Table utilities
function Utils.TableLength(t)
    local count = 0
    for _ in pairs(t) do
        count = count + 1
    end
    return count
end

function Utils.TableContains(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end

-- String utilities
function Utils.StringSplit(str, delimiter)
    local result = {}
    local from = 1
    local delim_from, delim_to = string.find(str, delimiter, from)
    
    while delim_from do
        table.insert(result, string.sub(str, from, delim_from - 1))
        from = delim_to + 1
        delim_from, delim_to = string.find(str, delimiter, from)
    end
    
    table.insert(result, string.sub(str, from))
    return result
end

function Utils.StringTrim(str)
    return str:match("^%s*(.-)%s*$")
end

-- Math utilities
function Utils.Round(num, decimals)
    local mult = 10^(decimals or 0)
    return math.floor(num * mult + 0.5) / mult
end

function Utils.Clamp(value, min, max)
    return math.min(math.max(value, min), max)
end

-- Validation utilities
function Utils.IsValidString(str)
    return str and type(str) == 'string' and str ~= ''
end

function Utils.IsValidNumber(num)
    return num and type(num) == 'number' and not math.isnan(num)
end

function Utils.IsValidTable(t)
    return t and type(t) == 'table'
end

-- Player utilities
function Utils.GetPlayerName(source)
    local player = GetPlayerName(source)
    return player or 'Unknown'
end

function Utils.GetPlayerIdentifier(source)
    local identifiers = GetPlayerIdentifiers(source)
    for _, identifier in pairs(identifiers) do
        if string.find(identifier, 'license:') then
            return identifier
        end
    end
    return nil
end

-- Time utilities
function Utils.GetCurrentTime()
    return os.time()
end

function Utils.FormatTime(timestamp)
    return os.date('%Y-%m-%d %H:%M:%S', timestamp)
end

-- Random utilities
function Utils.RandomInt(min, max)
    return math.random(min, max)
end

function Utils.RandomFloat(min, max)
    return min + math.random() * (max - min)
end

function Utils.RandomChoice(table)
    return table[math.random(#table)]
end