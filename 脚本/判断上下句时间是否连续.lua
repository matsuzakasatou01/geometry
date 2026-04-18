local get = aegisub.gettext

script_name = get "判断上下句时间是否连续"
script_description = get "定义时间连续性判断表"
script_author = "松坂さとう"
script_version = "1.0"

function style_time(subs)
    local function tbl_to_str(tbl)
        local parts = {}
        for _,arr in ipairs(tbl) do
            table.insert(parts,"{"..table.concat(arr,",").."}")
        end
        return "bool_time={"..table.concat(parts,",").."}"
    end
    local n = 0
    local res = {}
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
        m = m + 1
        if line.effect == "" or line.effect == "karaoke" then
            break
        end
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
    for i = n,#subs do
        local line = subs[i]
        if line.effect:find("^template") or line.effect == "" then
            line.comment = true
            line.effect = "code once"
            line.text = tbl_to_str(res)
            line.start_time = 0
            line.end_time = 0
            subs[-n] = line
            break
        end
        if line.effect == "code once" then
            if line.text:find("bool_time") then
                line.text = tbl_to_str(res)
                subs[i] = line
                break
            end
        end
    end
end

aegisub.register_macro(script_name,script_description,style_time)