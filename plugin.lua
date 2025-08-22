require "dialog"

---@param plugin Plugin
function init(plugin)
    plugin:newCommand {
        id = "FindInSprite",
        title = "Find text...",
        group = "edit_insert",
        onenabled = function()
            return #app.sprites > 0
        end,
        onclick = FindAndReplaceDialog
    }
end