local get = aegisub.gettext

script_name = get "除闪除叠"
script_description = get "修正闪轴叠轴的错误"
script_author = "霜庭云花Sub  松坂さとう"
script_version = "1.01"

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

function find_an(text)
    local an = string.match(text,"(\\an%d+)")
    return an
end

function correct_time(subs,sel)
    local cnt1 = 0
    local cnt2 = 0
    for _, i in ipairs(sel) do
        local line_1 = subs[i-1+cnt1]
        local line_2 = subs[i+cnt1]
        if line_1.comment == false and line_2.comment == false and line_1.section == "[Events]" and line_1.end_time < line_2.start_time and line_2.start_time - line_1.end_time <= 300 then
            line_1.comment = true
            subs[i+cnt1-1] = line_1
            line_1.comment = false
            line_1.end_time = line_2.start_time
            subs[-i-cnt1] = line_1
            cnt1 = cnt1 + 1
        end
    end
    for _, i in ipairs(sel) do
        local line_1 = subs[i-1+cnt2]
        local line_2 = subs[i+cnt2]
        if line_1.comment == false and line_2.comment == false and line_1.section == "[Events]" and line_1.end_time > line_2.start_time and line_1.end_time - line_2.start_time <= 300 and line_1.margin_l == line_2.margin_l and line_1.margin_r == line_2.margin_r and find_an(line_1.text) == find_an(line_2.text) then
            line_2.comment = true
            subs[i+cnt2] = line_2
            line_2.comment = false
            line_2.start_time = line_1.end_time
            subs[-i-cnt2] = line_2
            cnt2 = cnt2 + 1
        end
    end
end

function delate_comment(subs)
    local i = 1
    while i <= #subs do
        local line = subs[i]
        if line.comment then
            subs.delete(i)
        else
            i = i + 1
        end
    end
end

aegisub.register_macro(script_name.."/1.选中相同样式行",script_description,same_style)
aegisub.register_macro(script_name.."/2.修正闪轴叠轴",script_description,correct_time)
aegisub.register_macro(script_name.."/3.删除错误行",script_description,delate_comment)