local get = aegisub.gettext

script_name = get "处理一行AI2ASS转出的字符串"
script_description = get "直接给出颜色表和绘图表"
script_author = "松坂さとう"
script_version = "1.0"

function change_AI2ASS(subs,sel)
    for _,i in ipairs(sel) do
        local line = subs[i]
        local text = line.text
        local color,shape = {},{}
        for a in string.gmatch(text,"\\1c&H......&") do
            color[#color+1] = string.match(a,"\\1c(&H......&)")
        end
        for b in string.gmatch(text,"m[^m]+{\\p0}") do
            shape[#shape+1] = string.match(b,"(m[^m]+){\\p0}")
        end
        line.text = "shape="..'{\"'..table.concat(shape,'\",\"')..'\"}'
        line.comment = true
        line.effect = "code once"
        line.start_time = 0
        line.end_time = 0
        subs[i] = line
        line.text = "color="..'{\"'..table.concat(color,'\",\"')..'\"}'
        subs[-i] = line
    end
end

aegisub.register_macro(script_name,script_description,change_AI2ASS)