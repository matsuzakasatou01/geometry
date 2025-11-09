local get = aegisub.gettext

script_name = get "勾选、取消注释"
script_description = get "这玩意就得用快捷键的，你不用反而还麻烦"
script_author = "松坂さとう"
script_version = "1.0"

function comment(subs,sel)
    for _,i in ipairs(sel) do
        local line = subs[i]
        if line.comment then
            line.comment = false
        else
            line.comment = true
        end
        subs[i] = line
    end
end

aegisub.register_macro(script_name,script_description,comment)