local get = aegisub.gettext

script_name = get "逻辑统计各类行数"
script_description = get "算法快且适用于大多数情况"
script_author = "松坂さとう"
script_version = "1.0"

function lines_number(subs)
    local n,a,b,c,d = 0,0,0,0,0
    for i = 1,#subs do
        if subs[i].section == "[Events]" then
            break
        end
        n = n + 1
    end
    if subs[#subs-1].effect == "fx" then
        if subs[n+1].effect == "fx" then
            if subs[#subs].effect == "fx" then
                d = #subs - n
            else
                d = #subs - n - 1
            end
        else
            for i = n+1,#subs do
                if subs[i].effect == "fx" then
                    if subs[#subs].effect == "fx" then
                        d = #subs - i + 1
                    else
                        d = #subs - i
                    end
                    break
                end
            end
        end
    end
    if string.find(subs[n+1].effect,"^code") or string.find(subs[n+1].effect,"^template") then
        for i = n+1,#subs do
            local l = subs[i]
            if string.find(l.effect,"^code") then
                a = a + 1
            end
            if string.find(l.effect,"^template") then
                b = b + 1
            end
            if l.effect == "karaoke" then
                c = c + 1
            end
            if l.effect == "fx" then
                break
            end
        end
    end
    local e = a + b
    local f = #subs - n
    aegisub.log(a.."行code行\n"..b.."行template行\n"..c.."行karaoke行\n"..d.."行fx行\n\n"..e.."行模板行\n".."总行数为"..f.."行")
end

aegisub.register_macro(script_name,script_description,lines_number)