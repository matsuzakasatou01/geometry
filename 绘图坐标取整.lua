local get = aegisub.gettext

script_name = get "绘图坐标取整"
script_description = get "把选中行的绘图坐标取整"
script_author = "松坂さとう"
script_version = "1.0"

function round(num,decimal)
    decimal = decimal or 0
    local mult = 10^decimal
    return math.floor(num*mult + 0.5)/mult
end

function shape_round(subs,sel)
    for _,i in ipairs(sel) do
        local line = subs[i]
        line.text = string.gsub(line.text,"([-.%d]+) ([-.%d]+)",
        function (x,y)
            x = round(tonumber(x))
            y = round(tonumber(y))
            return string.format("%s %s",x,y)
        end)
        subs[i] = line
    end
end

aegisub.register_macro(script_name,script_description,shape_round)