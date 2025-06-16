local get = aegisub.gettext

script_name = get "绘图坐标取整"
script_description = get "把选中行的绘图坐标取整"
script_author = "松坂さとう"
script_version = "2.0"

function shape_round(subs,sel)
    for _,i in ipairs(sel) do
        local line = subs[i]
        line.text = string.gsub(line.text,"([-.%d]+) ([-.%d]+)",
        function (x,y)
            x = math.floor(x + 0.5)
            y = math.floor(y + 0.5)
            return string.format("%s %s",x,y)
        end)
        subs[i] = line
    end
end

aegisub.register_macro(script_name,script_description,shape_round)