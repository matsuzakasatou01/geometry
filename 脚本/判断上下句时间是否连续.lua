local get = aegisub.gettext

script_name = get "判断上下句时间是否连续"
script_description = get "定义时间连续性判断表"
script_author = "松坂さとう"
script_version = "2.0"

local function style_time(subs,mode)
    local function tbl_to_str(tbl)
        local parts = {}
        for _,arr in ipairs(tbl) do
            table.insert(parts,"{"..table.concat(arr,",").."}")
        end
        return "bool_time={"..table.concat(parts,",").."}"
    end
    local function tbl_to_str2(tbl)
        return "bool_time={"..table.concat(tbl,",").."}"
    end
    local n = 0
    local res,result = {},{}
    for i = 1,#subs do
        local line = subs[i]
        n = n + 1
        if line.section == "[Events]" then
            break
        end
    end
    local m = n
    for i = n,#subs do
        local line = subs[i]
        if line.effect == "" or line.effect == "karaoke" then
            break
        end
        m = m + 1
    end
    local style = subs[m].style
    for i = m,#subs do
        local line = subs[i]
        if line.effect == "fx" then
            break
        end
        if line.style == style then
            res[#res+1] = {line.start_time,line.end_time}
        end
    end
    res[1][1] = 0
    res[#res][2] = 0
    for i = 1,#res-1 do
        if res[i][2] == res[i+1][1] then
            res[i][2] = 1
            res[i+1][1] = 1
        else
            res[i][2] = 0
            res[i+1][1] = 0
        end
    end
    if mode == 1 then
        for i = 1,#res do
            result[i] = res[i][1]
        end
    end
    for i = n,#subs do
        local line = subs[i]
        if line.effect:find("^template") or line.effect == "" then
            if mode == 0 then
                line.text = tbl_to_str(res)
            elseif mode == 1 then
                line.text = tbl_to_str2(result)
            end
            line.comment = true
            line.effect = "code once"
            line.start_time = 0
            line.end_time = 0
            subs[-n] = line
            break
        end
        if line.effect == "code once" then
            if line.text:find("bool_time") then
                if mode == 0 then
                    line.text = tbl_to_str(res)
                elseif mode == 1 then
                    line.text = tbl_to_str2(result)
                end
                subs[i] = line
                break
            end
        end
    end
end

function zero(subs)
    return style_time(subs,0)
end

function one(subs)
    return style_time(subs,1)
end

aegisub.register_macro(script_name.."/前向判断",script_description,one)
aegisub.register_macro(script_name.."/双向判断",script_description,zero)