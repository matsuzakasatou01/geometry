local get = aegisub.gettext

script_name = get "添加平均kf标签"
script_description = get "给选中行添加平均kf标签"
script_author = "松坂さとう"
script_version = "1.0"

include("unicode.lua")

function add_kf(subs,sel)
	for _,i in ipairs(sel) do
		local l = subs[i]
		if string.find(l.text,"\\k%d+") or string.find(l.text,"\\kf%d+") or string.find(l.text,"\\ko%d+") then
			break
		end
		local text = ""
		local syl_n = unicode.len(l.text)
		l.duration = l.end_time - l.start_time
		local kf_value = math.floor(l.duration/10/syl_n)
		for char in string.gmatch(l.text,"[%z\x01-\x7F\xC2-\xFD][\x80-\xBF]*") do
			text = text..string.format("{\\kf%d}",kf_value)..char
		end
		l.text = text
		subs[i] = l
	end
end

aegisub.register_macro(script_name,script_description,add_kf)