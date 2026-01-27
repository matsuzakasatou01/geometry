local get = aegisub.gettext

script_name = get "统计时间较短行"
script_description = get "统计时间较短行"
script_author = "松坂さとう"
script_version = "1.0"

function karaoke_duration(subs)
    local n = 0
    local text = ""
    local info,res = {},{}
    for i = 1,#subs do
        if subs[i].section == "[Events]" then
            break
        end
        n = n + 1
    end
    for i = n+1,#subs do
        if subs[i].effect == "fx" then
            break
        end
        if subs[i].effect == "" or subs[i].effect == "karaoke" then
            local t = subs[i].end_time - subs[i].start_time
            if t ~= 0 then
                info[#info+1] = {{i - n},time = t}
            end
        end
    end
    table.sort(info,function(a,b)
        return a.time > b.time
    end)
    if info[1].time == info[2].time and info[#info-1].time == info[#info].time then
        for i = 1,#info do
            if i % 2 == 1 then
                res[#res+1] = info[i]
            else
                res[i/2][1][2] = info[i][1][1]
            end
        end
        for i = 1,#res do
            table.sort(res[i][1],function(a,b)
                return a < b
            end)
        end
        for i = 1,#res do
            text = text.."\n#"..tostring(res[i][1][1]).."  ".."#"..tostring(res[i][1][2]).."      "..tostring(res[i].time).."ms"
        end
    else
        for i = 1,#info do
            text = text.."\n#"..tostring(info[i][1][1]).."      "..tostring(info[i].time).."ms"
        end
    end
    aegisub.log(text)
end

aegisub.register_macro(script_name,script_description,karaoke_duration)