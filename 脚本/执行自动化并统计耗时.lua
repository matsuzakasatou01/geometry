local get = aegisub.gettext

script_name = get "执行自动化并统计耗时"
script_description = get "执行自动化并统计耗时"
script_author = "松坂さとう"
script_version = "1.0"

function apply_time(subs,sel)
    local script_path = debug.getinfo(1,"S").source
    if script_path:find("^@") then
        script_path = script_path:sub(2)
    end
    local script_dir = script_path:match("(.*[\\/])")
    local kara_path = script_dir.."kara-templater.lua"
    local file = io.open(kara_path,"r")
    if not file then
        aegisub.log("错误：无法找到 kara-templater.lua")
        return subs
    end
    local content = file:read("*all")
    file:close()
    local chunk,err = load(content,"kara-templater.lua")
    if not chunk then
        aegisub.log("加载 kara-templater.lua 失败: "..tostring(err))
        return subs
    end
    local start_time = os.clock()
    chunk()
    macro_apply_templates(subs,sel)
    local elapsed_time = os.clock() - start_time
    aegisub.log(string.format("本次模板执行耗时: %.3f 秒",elapsed_time))
    return subs
end

aegisub.register_macro(script_name, script_description, apply_time)