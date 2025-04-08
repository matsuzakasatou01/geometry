local get = aegisub.gettext

script_name = get "只留歌词"
script_description = get "只留歌词"
script_author = "霜庭云花Sub  松坂さとう"
script_version = "1.0"

function lyric(subs)
    local a = 0
    local b = 0
    local c = 0
    for i = 1,#subs do
        if subs[i].comment then
            a = i
            break
        end
    end
    for i = 1,#subs do
        if subs[i].section == "[Events]" and subs[i].effect == "karaoke" then
            b = i - 1
            break
        end
    end
    for i = 1,#subs do
        if subs[i].section == "[Events]" and subs[i].effect == "fx" then
            c = i
            break
        end
    end
    subs.deleterange(c,#subs)
    subs.deleterange(a,b)
    for i = 1,#subs do
        local l = subs[i]
        if l.section == "[Events]" then
        l.text = l.text:gsub("{[^}]+}","")
        l.comment = false
        l.actor = ""
        l.effect = ""
        end
        subs[i] = l
    end
end

aegisub.register_macro(script_name,script_description,lyric)