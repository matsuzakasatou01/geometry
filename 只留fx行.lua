local get = aegisub.gettext

script_name = get "只留fx行"
script_description = get "只留fx行"
script_author = "松坂さとう"
script_version = "1.0"

function fx(subs)
    for i = 1,#subs do
        if subs[i].section == "[Events]" then
            a = i
            break
        end
    end
    for i = 1,#subs do
        if subs[i].section == "[Events]" and subs[i].effect == "fx" then
            b = i - 1
            break
        end
    end
    subs.deleterange(a,b)
end

aegisub.register_macro(script_name,script_description,fx)