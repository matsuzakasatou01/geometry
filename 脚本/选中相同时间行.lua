local get = aegisub.gettext

script_name = get "选中相同时间行"
script_description = get "选中相同时间行"
script_author = "松坂さとう"
script_version = "1.0"

function same_time(subs,sel)
    local time = {}
    for i = 1,#subs do
        local line = subs[i]
        if line.start_time == subs[sel[1]].start_time and line.end_time == subs[sel[1]].end_time then
            table.insert(time,i)
        end
    end
    return time
end

aegisub.register_macro(script_name,script_description,same_time)