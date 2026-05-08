local get = aegisub.gettext

script_name = get "执行自动化并统计耗时"
script_description = get "执行自动化并统计耗时"
script_author = "松坂さとう"
script_version = "2.0"

function can_apply(subs)
    local kara_path = debug.getinfo(1,"S").source:match("^@?(.*[\\/])").."kara-templater.lua"
    local file = io.open(kara_path,"r")
    if not file then
        return false
    end
    local content = file:read("*a")
    file:close()
    local chunk = load(content)
    if not chunk then
        return false
    end
    chunk()
    return macro_can_template(subs)
end

function apply_time(subs,sel)
    local kara_path = debug.getinfo(1,"S").source:match("^@?(.*[\\/])").."kara-templater.lua"
    local file = io.open(kara_path,"r")
    local content = file:read("*a")
    file:close()
    local chunk = load(content)
    chunk()
    local start_time = os.clock()
    macro_apply_templates(subs,sel)
    local elapsed_time = os.clock() - start_time
    aegisub.log("本次模板执行耗时: %.3f 秒",elapsed_time)
end

aegisub.register_macro(script_name,script_description,apply_time,can_apply)