local get = aegisub.gettext

script_name = get "选中奇数行或偶数行"
script_description = get "选中奇数行或偶数行"
script_author = "松坂さとう"
script_version = "1.0"

function so(subs)
    local cnt = 0
    local line = {}
    for i = 1,#subs do
        local l = subs[i]
        if l.section == "[Events]" then
            break
        end
        cnt = cnt + 1
    end
    for i = 1,#subs do
        local l = subs[i]
        if l.section == "[Events]" and (i - cnt)%2 == 1 then
            table.insert(line,i)
        end
    end
    return line
end

function se(subs)
    local cnt = 0
    local line = {}
    for i = 1,#subs do
        local l = subs[i]
        if l.section == "[Events]" then
            break
        end
        cnt = cnt + 1
    end
    for i = 1,#subs do
        local l = subs[i]
        if l.section == "[Events]" and (i - cnt)%2 == 0 then
            table.insert(line,i)
        end
    end
    return line
end

aegisub.register_macro(script_name.."/选中奇数行",script_description,so)
aegisub.register_macro(script_name.."/选中偶数行",script_description,se)