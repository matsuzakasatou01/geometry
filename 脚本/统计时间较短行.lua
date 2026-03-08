local get = aegisub.gettext

script_name = get "统计时间较短行"
script_description = get "统计时间较短行并检测中日文时间是否完全一致"
script_author = "松坂さとう"
script_version = "3.0"

function karaoke_duration(subs)
    local n,num,max_digits = 0,0,0
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
                info[#info+1] = {{i - n},digits = #tostring(i - n),time = t,start_time = subs[i].start_time,end_time = subs[i].end_time}
                max_digits = math.max(max_digits,#tostring(i - n))
            else
                text = "第 "..tostring(i - n).." 行持续时间为0，请修改"
                goto continue
            end
        end
    end
    for i = 1,#info do
        info[i][1][1] = tostring(info[i][1][1])..string.rep("  ",max_digits - info[i].digits)
    end
    table.sort(info,function(a,b)
        if a.time ~= b.time then
            return a.time > b.time
        end
        return a.start_time < b.start_time
    end)
    if #info % 2 == 1 then
        for i = 1,#info do
            text = text.."\n#"..info[i][1][1].."      "..tostring(info[i].time).."ms"
        end
        goto continue
    end
    for i = 1,#info,2 do
        if info[i].start_time ~= info[i+1].start_time or info[i].end_time ~= info[i+1].end_time then
            num = num + 1
        end
    end
    if num == 0 then
        for i = 1,#info do
            if i % 2 == 1 then
                res[#res+1] = info[i]
            else
                res[i/2][1][2] = info[i][1][1]
            end
        end
        for i = 1,#res do
            table.sort(res[i][1],function(a,b)
                return tonumber(a) < tonumber(b)
            end)
        end
        for i = 1,#res do
            text = text.."\n#"..res[i][1][1].."  #"..res[i][1][2].."      "..tostring(res[i].time).."ms"
        end
    elseif num == #info/2 then
        for i = 1,#info do
            text = text.."\n#"..info[i][1][1].."      "..tostring(info[i].time).."ms"
        end
    else
        text = "中日文时间不一致，请把日文时间粘贴到中文上"
    end
    ::continue::
    aegisub.log(text)
end

aegisub.register_macro(script_name,script_description,karaoke_duration)