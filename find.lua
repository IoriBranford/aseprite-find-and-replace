---@alias ObjectToSearch Tag
---@alias ObjectTypeToSearch "Tag"
---@alias ObjectFieldToSearch "name"|"data"

---@class SearchResult
---@field foundin ObjectToSearch
---@field type ObjectTypeToSearch
---@field field ObjectFieldToSearch
---@field from integer
---@field to integer
local SearchResult = {}
SearchResult.__index = SearchResult

function SearchResult:__tostring()
    return string.format("%s \"%s\" %s (%d - %d)",
        self.type, self.foundin.name, self.field, self.from, self.to)
end

---@param object ObjectToSearch
---@param objectType ObjectTypeToSearch
---@param field ObjectFieldToSearch
---@param pattern string
---@param plain boolean
---@return SearchResult?
function FindPatternInObjectField(object, objectType, field, pattern, plain)
    local value = object[field]
    if type(value) ~= "string" then return end
    local i, j = string.find(value, pattern, 1, plain)
    if i and j then
        return setmetatable({
            from = i,
            to = j,
            foundin = object,
            type = objectType,
            field = field
        }, SearchResult)
    end
end

---@param object ObjectToSearch
---@param objectType ObjectTypeToSearch
---@param field ObjectFieldToSearch
---@param pattern string
---@return SearchResult?
function FindExactStringInObjectField(object, objectType, field, pattern)
    local value = object[field]
    if value == pattern then
        return setmetatable({
            from = 1,
            to = #pattern,
            foundIn = object,
            type = objectType,
            field = field
        }, SearchResult)
    end
end

---@param objects ObjectToSearch[]
---@param objectType ObjectTypeToSearch
---@param field ObjectFieldToSearch
---@param pattern string
---@param exact boolean
---@param plain boolean
---@param results SearchResult[]?
---@return SearchResult[]?
function FindInObjectsField(objects, objectType, field, pattern, exact, plain, results)
    results = results or {}
    if exact and plain then
        for _, object in ipairs(objects) do
            results[#results+1] = FindExactStringInObjectField(object, objectType, field, pattern)
        end
    else
        if exact then
            pattern = "^"..pattern.."$"
        end
        for _, object in ipairs(objects) do
            results[#results+1] = FindPatternInObjectField(object, objectType, field, pattern, plain)
        end
    end
    return results
end

---@class FindInSpriteArgs
---@field sprite Sprite
---@field pattern string
---@field patternType PatternType
---@field exact boolean
---@field inTagNames boolean
---@field inTagData boolean

---@param args FindInSpriteArgs
function FindInSprite(args)
    local sprite = args.sprite
    local text = args.pattern or ""
    if text == "" then return end

    local exact = args.exact
    local findAs = args.patternType
    local plain = findAs == "Plain string"

    local results = {}
    if args.inTagNames then
        FindInObjectsField(sprite.tags, "Tag", "name",
            text, exact, plain, results)
    end
    if args.inTagData then
        FindInObjectsField(sprite.tags, "Tag", "data",
            text, exact, plain, results)
    end
    return results
end