local get = aegisub.gettext

script_name = get "遍历统计各类行数"
script_description = get "算法慢但适用于所有情况"
script_author = "松坂さとう"
script_version = "1.0"

function lines_number(subs)
    local n,a,b,c,d = 0,0,0,0,0
    for i = 1,#subs do
        local l = subs[i]
        n = n + 1
        if l.section == "[Events]" then
            break
        end
    end
    for i = n,#subs do
        local l = subs[i]
        aegisub.progress.set(i/#subs*100)
        if string.find(l.effect,"^code") then
            a = a + 1
        elseif string.find(l.effect,"^template") then
            b = b + 1
        elseif l.effect == "karaoke" then
            c = c + 1
        elseif l.effect == "fx" then
            d = d + 1
        end
    end
    local e = a + b
    local f = #subs - n + 1
    aegisub.log(a.."行code行\n"..b.."行template行\n"..c.."行karaoke行\n"..d.."行fx行\n\n"..e.."行模板行\n".."总行数为"..f.."行")
end

aegisub.register_macro(script_name,script_description,lines_number)