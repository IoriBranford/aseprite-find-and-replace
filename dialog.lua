require "find"

---@alias PatternType "Lua pattern"|"Plain string"

function FindAndReplaceDialog()
    local dialog = Dialog {
        title = "Find and Replace"
    }

    dialog:entry {
        id = "textToFind",
        label = "Find:",
        focus = true
    }
    dialog:check {
        id = "checkExact",
        text = "Exact match",
        selected = false
    }
    dialog:combobox {
        id = "comboPatternType",
        label = "Find as:",
        option = "Plain string",
        options = {
            "Plain string",
            "Lua pattern"
        }
    }

    dialog:newrow()

    dialog:check {
        id = "checkFindInTagNames",
        label = "Find in:",
        text = "Tag names",
        selected = true
    }
    dialog:check {
        id = "checkFindInTagData",
        text = "Tag data",
        selected = true
    }

    dialog:newrow()

    dialog:button {
        text = "Find",
        onclick = function()
            local data = dialog.data
            ---@cast data {textToFind:string, comboPatternType:PatternType, checkExact:boolean, checkFindInTagNames:boolean, checkFindInTagData:boolean}

            FindResultsDialog(dialog, FindInSprite {
                sprite = app.sprite,
                pattern = data.textToFind,
                patternType = data.comboPatternType,
                exact = data.checkExact,
                inTagNames = data.checkFindInTagNames,
                inTagData = data.checkFindInTagData
            })
        end
    }

    dialog:show()
end

function FindResultsDialog(parent, results)
    local dialog = Dialog {
        title = "Search results",
        parent = parent
    }

    if results and #results > 0 then
        for _, result in ipairs(results) do
            dialog:label {
                text = tostring(result)
            }
            dialog:newrow()
        end

        dialog:show {
            autoscrollbars = true,
        }
    else
        app.alert "No results."
    end
end