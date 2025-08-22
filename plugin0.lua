local function InputDialog(args)
    args = args or {}
    local dialog = Dialog("Find/Replace in Names")

    dialog:separator({
        text = "Find in..."
    })
    dialog:check({
        id = "findInLayerNames",
        text = "Layer names",
        selected = args.findInLayerNames
    })
    dialog:check({
        id = "findInTagNames",
        text = "Tag names",
        selected = args.findInTagNames
    })
    dialog:newrow()
    dialog:entry({
        id = "findPattern",
        label = "Find regex:",
        text = args.findPattern or "",
        focus = true
    })
    dialog:button({
        text = "Regex help",
        onclick = function()
            app.command.Launch({
                type = "url",
                path = "https://www.lua.org/manual/5.3/manual.html#6.4.1"
            })
        end
    })
    dialog:entry({
        id = "replacePattern",
        label = "Replace with:",
        text = args.replacePattern or ""
    })
    dialog:button({
        id = "buttonFindAll",
        text = "Find all",
        focus = true
    })
    dialog:button({
        id = "buttonReplaceAll",
        text = "Replace all",
    })
    dialog:show()
    return dialog
end

---@param layerresults Layer[]
---@param tagresults Tag[]
---@param findpattern string?
---@param replacepattern string?
local function FindResultsDialog(layerresults, tagresults, findpattern, replacepattern)
    local dialog = Dialog(replacepattern and findpattern and "Replace preview" or "Find results")

    local function makeList(title, a)
        if not a then
            return
        end

        dialog:separator({
            text = title
        })
        dialog:newrow()
        if #a <= 0 then
            dialog:label({
                text = "No results."
            })
            dialog:newrow()
        else
            local lines = {}
            if findpattern and replacepattern then
                for _, o in ipairs(a) do
                    dialog:label({
                        text = o.name .. " > " .. o.name:gsub(findpattern, replacepattern)
                    })
                    dialog:newrow()
                end
            else
                for _, o in ipairs(a) do
                    dialog:label({
                        text = o.name
                    })
                    dialog:newrow()
                end
            end

            for _, line in ipairs(lines) do
                dialog:label({
                    text = line
                })
                dialog:newrow()
            end
        end
    end
    makeList("Layers", layerresults)
    makeList("Tags", tagresults)

    if findpattern and replacepattern then
        dialog:button({
            id = "buttonCancel",
            text = "Cancel"
        })
        dialog:button({
            id = "buttonReplaceAll",
            text = "Replace all",
            enabled = layerresults and #layerresults > 0 or tagresults and #tagresults > 0
        })
    else
        dialog:button({
            id = "buttonOK",
            text = "OK"
        })
    end
    dialog:show()
    return dialog
end

---@param layers Layer[]
---@param pattern string
---@param results Layer[]?
local function FindInLayerNames(layers, pattern, results)
    results = results or {}

    for _, layer in ipairs(layers) do
        if layer.name:find(pattern) then
            results[#results+1] = layer
        end
        if layer.layers then
            FindInLayerNames(layer.layers, pattern, results)
        end
    end

    return results
end

---@param tags Tag[]
---@param pattern string
---@param results Tag[]?
local function FindInTagNames(tags, pattern, results)
    results = results or {}

    for _, tag in ipairs(tags) do
        if tag.name:find(pattern) then
            results[#results+1] = tag
        end
    end

    return results
end

function init(plugin)
    plugin:newMenuSeparator({
        group="edit_clear"
    })
    plugin:newCommand({
        id="FindAndReplace",
        title="Find/Replace in Names...",
        group="edit_clear",
        onclick=function()
            local sheet = app.sprite
            if not sheet then
                app.alert("No file open.")
                return
            end

            local dialog = InputDialog(plugin.preferences.lastargs or {
                findInLayerNames = true,
                findInTagNames = true
            })

            local data = dialog.data
            local pattern = data.findPattern
            local replacepattern = data.replacePattern
            ---@cast pattern string
            ---@cast replacepattern string

            plugin.preferences.lastargs = {
                findInLayerNames = data.findInLayerNames,
                findInTagNames = data.findInTagNames,
                findPattern = pattern,
                replacePattern = replacepattern,
            }

            if not data.findInTagNames and not data.findInLayerNames then
                app.alert("Neither tag names nor layer names selected.")
                return
            end

            if not data.buttonFindAll and not data.buttonReplaceAll then
                return
            end

            local tagresults = data.findInTagNames and FindInTagNames(app.sprite.tags, pattern)
            local layerresults = data.findInLayerNames and FindInLayerNames(app.sprite.layers, pattern)

            dialog = FindResultsDialog(
                layerresults,
                tagresults,
                data.buttonReplaceAll and pattern,
                data.buttonReplaceAll and replacepattern)

            data = dialog.data
            if data.buttonReplaceAll then
                app.transaction("Find/Replace '"..pattern.."' > '"..replacepattern.."'", function()
                    if tagresults then
                        for _, tag in ipairs(tagresults) do
                            tag.name = tag.name:gsub(pattern, replacepattern)
                        end
                    end
                    if layerresults then
                        for _, layer in ipairs(layerresults) do
                            layer.name = layer.name:gsub(pattern, replacepattern)
                        end
                    end
                end)
            end
        end
    })
end