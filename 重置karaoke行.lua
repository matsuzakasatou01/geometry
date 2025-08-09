local get = aegisub.gettext

script_name = get "重置karaoke行"
script_description = get "重置karaoke行"
script_author = "松坂さとう"
script_version = "1.1"

function reset_karaoke(subs)
    for i = 1,#subs do
        local l = subs[i]
        if l.section == "[Events]" and l.effect == "fx" then
            break
        end
        if l.section == "[Events]" and l.effect == "karaoke" then
            l.text = l.text:gsub("{[^}]+}","")
            l.comment = false
            l.actor = ""
            l.effect = ""
        end
        subs[i] = l
    end
end

aegisub.register_macro(script_name,script_description,reset_karaoke)