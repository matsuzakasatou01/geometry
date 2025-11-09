local get = aegisub.gettext

script_name = get "选中相同样式行"
script_description = get "选中相同样式行"
script_author = "松坂さとう"
script_version = "1.0"

function same_style(subs,sel)
    local style = {}
    for i = 1,#subs do
        local line = subs[i]
        if line.style == subs[sel[1]].style then
            table.insert(style,i)
        end
    end
    return style
end

aegisub.register_macro(script_name,script_description,same_style)