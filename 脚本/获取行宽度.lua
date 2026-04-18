local get = aegisub.gettext

script_name = get "获取行宽度"
script_description = get "定义每种样式的行宽度表"
script_author = "松坂さとう"
script_version = "1.0"

include("karaskel.lua")

local function styles_widths(subs,mode)
    local function tbl_to_str(tbl)
        local parts = {}
        for k,v in pairs(tbl) do
            local arr_parts = {}
            for i = 1,#v do
                table.insert(arr_parts,tostring(v[i]))
            end
            local arr_str = "{"..table.concat(arr_parts,",").."}"
            table.insert(parts,k.."="..arr_str)
        end
        return table.concat(parts," ")
    end
    local function search_keys(text,tbl)
        for k in pairs(tbl) do
            if string.find(text,k,1,true) then
                return true
            end
        end
        return false
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
    for i = n,#subs do
        local line = subs[i]
        if line.effect == "fx" then
            break
        end
        if line.effect == "" or line.effect == "karaoke" then
            local style = string.lower(line.style).."_wid"
            if not res[style] then
                res[style] = {}
            end
            local _,styles_tbl = karaskel.collect_head(subs)
            local clean_text = line.text:gsub("{[^}]-}","")
            local width = aegisub.text_extents(styles_tbl[line.style],clean_text)
            table.insert(res[style],width)
        end
    end
    if mode == 1 then
        for _,arr in pairs(res) do
            table.insert(arr,1,0)
            arr[#arr+1] = 0
        end
    elseif mode == 2 then
        for _,arr in pairs(res) do
            table.insert(arr,1,arr[1])
            arr[#arr+1] = arr[#arr]
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
            if search_keys(line.text,res) then
                line.text = tbl_to_str(res)
                subs[i] = line
                break
            end
        end
    end
end

function zero(subs)
    return styles_widths(subs,0)
end

function one(subs)
    return styles_widths(subs,1)
end

function two(subs)
    return styles_widths(subs,2)
end

aegisub.register_macro(script_name.."/获取原宽度表",script_description,zero)
aegisub.register_macro(script_name.."/用 0 填充首尾",script_description,one)
aegisub.register_macro(script_name.."/用首尾元素填充首尾",script_description,two)