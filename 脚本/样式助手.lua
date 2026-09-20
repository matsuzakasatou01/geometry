script_name = "样式助手"
script_description = "辅助设置样式（支持中日韩字体）"
script_author = "松坂さとう"
script_version = "1.0"

include("karaskel.lua")
local OK,Yutils = pcall(require,"Yutils")

function styles_helper(subs)
    local function aegisub_exit(condition,log,...)
        if condition then
            if log then
                aegisub.log(log,...)
            end
            aegisub.cancel()
        end
    end
    aegisub_exit(not OK,"请先安装 Yutils 库\nhttps://github.com/Youka/Yutils/blob/T1/src/Yutils.lua")
    local meta,styles = karaskel.collect_head(subs)
    local style_names = {}
    for name in pairs(styles) do
        if type(name) == "string" and string.find(name,"%S") and name ~= "n" and not string.find(name,"-furigana$") then
            style_names[#style_names+1] = name
        end
    end
    aegisub_exit(#style_names < 2,"至少需要两个非假名样式")
    local function check_language(style,mode)
        mode = mode or "cjk"
        style = string.upper(style)
        local _,cn = string.gsub(style,"CN","")
        local _,tw = string.gsub(style,"TW","")
        local _,hk = string.gsub(style,"HK","")
        local _,jp = string.gsub(style,"JP","")
        local _,kr = string.gsub(style,"KR","")
        if mode == "c" then
            return cn + tw + hk == 1
        elseif mode == "jk" then
            return jp + kr == 1
        elseif mode == "cjk" then
            return cn + tw + hk + jp + kr == 1
        end
    end
    local lang_style_names = {}
    for i = 1,#style_names do
        if check_language(style_names[i]) then
            table.insert(lang_style_names,style_names[i])
        end
    end
    table.sort(style_names,function(a,b)
        return a > b
    end)
    table.sort(lang_style_names,function(a,b)
        return a > b
    end)
    local function find_default_style(styles_tbl,mode)
        if #styles_tbl < 2 then
            return nil
        end
        local priority_list = {}
        if mode == "source" then
            priority_list = {"JP","KR","TW","HK","CN"}
        elseif mode == "target" then
            priority_list = {"CN","HK","TW","KR","JP"}
        end
        for _,lang in ipairs(priority_list) do
            for _,style in ipairs(styles_tbl) do
                if style:upper():find(lang) then
                    return style
                end
            end
        end
    end
    local dialog_config = {
        {
            class = "label",
            label = "   参考样式：",
            x = 0,y = 0,width = 1,height = 1
        },
        {
            class = "dropdown",
            name = "source_style",
            items = style_names,
            value = find_default_style(lang_style_names,"source") or style_names[1],
            hint = "参考样式需要设置好全部参数\n并且当样式名列表中包含 JP/KR/TW/HK/CN 语言标识的样式数量 ≥2 时，会按照语言优先级选择默认值\n当参考样式和目标样式对齐方式相同且为底部或顶部对齐时，保证参考样式更靠近画面边缘",
            x = 1,y = 0,width = 1,height = 1
        },
        {
            class = "label",
            label = "   目标样式：",
            x = 0,y = 1,width = 1,height = 1
        },
        {
            class = "dropdown",
            name = "target_style",
            items = style_names,
            value = find_default_style(lang_style_names,"target") or style_names[2],
            hint = "目标样式需要设置好样式名、字体、粗体、斜体、对齐方式\n并且当样式名列表中包含 CN/HK/TW/KR/JP 语言标识的样式数量 ≥2 时，会按照语言优先级选择默认值\n当参考样式和目标样式对齐方式相同且为底部或顶部对齐时，保证目标样式更靠近画面中心",
            x = 1,y = 1,width = 1,height = 1
        },
        {
            class = "label",
            label = "   面积比值：",
            x = 0,y = 2,width = 1,height = 1
        },
        {
            class = "intedit",
            name = "area_ratio",
            value = 250,
            min = 25,
            max = 400,
            hint = "目标样式平均字面框面积 / 参考样式平均字面框面积\n底部对齐推荐值为 250 ，顶部对齐推荐值为 40\n仅在参考样式和目标样式对齐方式相同且为底部或顶部对齐时生效",
            x = 1, y = 2, width = 1, height = 1,
        },
        {
            class = "label",
            label = "%",
            x = 2,y = 2,width = 1,height = 1
        },
        {
            class = "label",
            label = "   参考层数：",
            x = 0,y = 3,width = 1,height = 1
        },
        {
            class = "intedit",
            name = "source_layer",
            value = -1,
            min = -1,
            max = 2^31-1,
            hint = "设定参考样式字幕行的层数，-1 表示不修改层数\n仅在参考样式和目标样式对齐方式相同且为底部或顶部对齐且没有特效模板行时生效",
            x = 1, y = 3, width = 1, height = 1,
        },
        {
            class = "label",
            label = "   目标层数：",
            x = 0,y = 4,width = 1,height = 1
        },
        {
            class = "intedit",
            name = "target_layer",
            value = -1,
            min = -1,
            max = 2^31-1,
            hint = "设定目标样式字幕行的层数，-1 表示不修改层数\n仅在参考样式和目标样式对齐方式相同且为底部或顶部对齐且没有特效模板行时生效",
            x = 1, y = 4, width = 1, height = 1,
        },
        {
            class = "checkbox",
            label = "复制颜色",
            name = "copy_colors",
            value = true,
            x = 0,y = 5,width = 1,height = 1
        },
        {
            class = "checkbox",
            label = "计算边框阴影",
            name = "calculate_outline_and_shadow",
            value = true,
            x = 1,y = 5,width = 1,height = 1
        },
        {
            class = "checkbox",
            label = "互换左右边距",
            name = "swap_lr_margin",
            value = false,
            hint = "只在对齐方式为 2 + 8 时生效",
            x = 0,y = 6,width = 2,height = 1
        }
    }
    if #lang_style_names < #style_names then
        table.insert(dialog_config,5,{
            class = "label",
            label = "   对应语言：",
            x = 0,y = 2,width = 1,height = 1
        })
        table.insert(dialog_config,6,{
            class = "dropdown",
            name = "language",
            items = {"日/韩 -> 中","中 -> 日/韩","中 -> 中","日/韩 -> 日/韩"},
            value = "日/韩 -> 中",
            hint = "参考样式语言 -> 目标样式语言\n参考样式和目标样式都含有语言标识时不生效\n所有合法样式都含有语言标识时不显示",
            x = 1,y = 2,width = 1,height = 1
        })
        for i = 7,#dialog_config do
            dialog_config[i].y = dialog_config[i].y + 1
        end
    end
    local button,result = aegisub.dialog.display(
        dialog_config,
        {"确定","取消"},
        {ok = "确定",cancel = "取消"}
    )
    aegisub_exit(button ~= "确定")
    aegisub_exit(result.source_style == result.target_style,"目标样式不能与参考样式相同")
    local function check_object(a,b)
        local function strip_lang(s)
            return s:upper():gsub("CN",""):gsub("TW",""):gsub("HK",""):gsub("JP",""):gsub("KR","")
        end
        return strip_lang(a) == strip_lang(b)
    end
    aegisub_exit(check_language(result.source_style) and check_language(result.target_style) and not check_object(result.source_style,result.target_style),"目标样式除语言标识外应与参考样式相同")
    local source,target = styles[result.source_style],styles[result.target_style]
    local same_align = source.align == target.align and (source.align <= 3 or source.align >= 7)
    local function check_align(s,t)
        local map = {[1]={7,9},[2]={8},[3]={7,9},[4]={6},[5]={5},[6]={4},[7]={1,3},[8]={2},[9]={1,3}}
        for i = 1,#map[s] do
            if map[s][i] == t then
                return true
            end
        end
        return false
    end
    if not same_align then
        if not check_align(source.align,target.align) then
            if source.align % 2 == 1 and source.align ~= 5 then
                if source.align == 1 or source.align == 3 then
                    aegisub.log("目标样式的对齐方式必须为 7 或 9")
                else
                    aegisub.log("目标样式的对齐方式必须为 1 或 3")
                end
            else
                aegisub.log("目标样式的对齐方式必须为 %d",10 - source.align)
            end
            aegisub.cancel()
        end
        result.area_ratio = 100
    end
    local area_coefficient = (result.area_ratio / 100) ^ 0.5
    local text = {"二","十","人","三","上","川","口","日","月","夕","水","木","田","白","目","生","血","米","自","者","夜","走","青","雨","品","星","高","音","夏","重"}
    local long_text = table.concat(text)
    local source_font = Yutils.decode.create_font(source.fontname,source.bold,source.italic,source.underline,source.strikeout,source.fontsize,source.scale_x/100,source.scale_y/100,source.spacing)
    local target_font = Yutils.decode.create_font(target.fontname,target.bold,target.italic,target.underline,target.strikeout,source.fontsize,source.scale_x/100,source.scale_y/100,source.spacing)
    local source_wids,source_heis,target_wids,target_heis = 0,0,0,0
    local source_bounding = {}
    local function standardize(ass_shape)
        local new = {}
        for m in string.gmatch(ass_shape,"m[^m]+") do
            for mlb in string.gmatch(m,"[mlb][- .%d]+") do
                if string.find(mlb,"^m") then
                    new[#new+1] = mlb
                elseif string.find(mlb,"^l") then
                    local l_points = {}
                    for l_p in string.gmatch(mlb,"[-.%d]+ [-.%d]+") do
                        l_points[#l_points+1] = "l "..l_p.." "
                    end
                    new[#new+1] = table.concat(l_points)
                elseif string.find(mlb,"^b") then
                    local b_points = {}
                    for b_p in string.gmatch(mlb,"[-.%d]+ [-.%d]+ [-.%d]+ [-.%d]+ [-.%d]+ [-.%d]+") do
                        b_points[#b_points+1] = "b "..b_p.." "
                    end
                    new[#new+1] = table.concat(b_points)
                end
            end
        end
        return table.concat(new)
    end
    local function real_bounding(ass_shape)
        local xmin,ymin,xmax,ymax = math.huge,math.huge,-math.huge,-math.huge
        local function bezier_bounding(x1,x2,x3,x4)
            local a,b,c = 3*x4 - 9*x3 + 9*x2 - 3*x1,6*x3 - 12*x2 + 6*x1,3*x2 - 3*x1
            local min_val,max_val = math.min(x1,x4),math.max(x1,x4)
            local function update_extreme(t)
                if t > 0 and t < 1 then
                    local val = x1*(1-t)^3 + 3*x2*t*(1-t)^2 + 3*x3*t^2*(1-t) + x4*t^3
                    min_val,max_val = math.min(min_val,val),math.max(max_val,val)
                end
            end
            if math.abs(a) < 1e-10 then
                if math.abs(b) > 1e-10 then
                    update_extreme(-c / b)
                end
                return min_val,max_val
            end
            local delta = b^2 - 4*a*c
            if delta < 0 then
                if delta > -1e-10 then
                    delta = 0
                else
                    return min_val,max_val
                end
            end
            local t1 = (-b + delta^0.5) / (2*a)
            local t2 = (-b - delta^0.5) / (2*a)
            update_extreme(t1)
            update_extreme(t2)
            return min_val,max_val
        end
        string.gsub(ass_shape,"m[^m]+",function(m)
            local cmd = {}
            for mlb in string.gmatch(m,"[mlb][- .%d]+") do
                local pt = {}
                for num in string.gmatch(mlb,"([-.%d]+)") do
                    pt[#pt+1] = tonumber(num)
                end
                cmd[#cmd+1] = pt
            end
            for i = 2,#cmd do
                local prev,curr = cmd[i-1],cmd[i]
                local x1,y1 = prev[#prev-1],prev[#prev]
                if #curr == 2 then
                    local minx,maxx = math.min(x1,curr[1]),math.max(x1,curr[1])
                    local miny,maxy = math.min(y1,curr[2]),math.max(y1,curr[2])
                    xmin,ymin,xmax,ymax = math.min(xmin,minx),math.min(ymin,miny),math.max(xmax,maxx),math.max(ymax,maxy)
                else
                    local minx,maxx = bezier_bounding(x1,curr[1],curr[3],curr[5])
                    local miny,maxy = bezier_bounding(y1,curr[2],curr[4],curr[6])
                    xmin,ymin,xmax,ymax = math.min(xmin,minx),math.min(ymin,miny),math.max(xmax,maxx),math.max(ymax,maxy)
                end
            end
        end)
        return xmax-xmin,ymax-ymin,ymin,ymax
    end
    for i = 1,#text do
        local w,h = real_bounding(standardize(source_font.text_to_shape(text[i])))
        source_bounding[#source_bounding+1] = {w = w,h = h}
    end
    for i = 1,#text do
        local w,h = real_bounding(standardize(target_font.text_to_shape(text[i])))
        source_wids = source_wids + source_bounding[i].w
        target_wids = target_wids + w
        source_heis = source_heis + source_bounding[i].h
        target_heis = target_heis + h
    end
    local new_fontsize = Yutils.math.round(source.fontsize * source_wids / target_wids * area_coefficient)
    local new_fscy = Yutils.math.round(source.scale_y * target_wids / source_wids * source_heis / target_heis)
    local transition_font = Yutils.decode.create_font(target.fontname,target.bold,target.italic,target.underline,target.strikeout,new_fontsize,source.scale_x/100,new_fscy/100,source.spacing)
    local temporary_target = util.copy(target)
    temporary_target.fontsize = new_fontsize
    temporary_target.scale_x = source.scale_x
    temporary_target.scale_y = new_fscy
    temporary_target.spacing = source.spacing
    local _,_,y0,y1 = real_bounding(standardize(source_font.text_to_shape(long_text)))
    local _,_,y2,y3 = real_bounding(standardize(transition_font.text_to_shape(long_text)))
    local source_x,target_x = 0,0
    local source_body_width,source_body_height = aegisub.text_extents(source,text[1])
    local target_body_width,target_body_height = aegisub.text_extents(temporary_target,text[1])
    for i = 1,#text do
        local w = real_bounding(standardize(transition_font.text_to_shape(text[i])))
        source_x = source_x + source_body_width - source_bounding[i].w
        target_x = target_x + target_body_width - w
    end
    local margin,max_margin,margin_offset = 0,0,0
    if source.align >= 7 then
        margin = source.margin_t + y0
    elseif source.align <= 3 then
        margin = source.margin_t + source_body_height - y1
    end
    aegisub_exit(margin < 0,"参考样式字幕边缘到视频边缘的距离不能为负值\n请把垂直边距至少调大 %d",-math.floor(margin))
    if meta.playresy then
        max_margin = tonumber(meta.playresy)/216
    else
        aegisub.log("请先打开视频")
        aegisub.cancel()
    end
    margin_offset = math.min(0.2*margin,max_margin)
    local function find_style(style)
        for i,line in ipairs(subs) do
            if line.class == "style" and line.name == style then
                return i
            end
        end
    end
    local target_index = find_style(result.target_style)
    local target_line = subs[target_index]
    target_line.fontsize = new_fontsize
    if result.copy_colors then
        target_line.color1 = source.color1
        target_line.color2 = source.color2
        target_line.color3 = source.color3
        target_line.color4 = source.color4
    end
    if same_align then
        target_line.margin_l = source.margin_l
        target_line.margin_r = source.margin_r
        if source.align <= 3 then
            target_line.margin_t = Yutils.math.round(source.margin_t + source_body_height + (y1-y0+y3-y2)*0.15 - y0 - target_body_height + y3)
        elseif source.align >= 7 then
            target_line.margin_t = Yutils.math.round(source.margin_t + (y1-y0+y3-y2)*0.15 + y1 - y2)
        end
    else
        if source.align == 2 or source.align == 8 then
            if result.swap_lr_margin then
                target_line.margin_l = source.margin_r
                target_line.margin_r = source.margin_l
            else
                target_line.margin_l = source.margin_l
                target_line.margin_r = source.margin_r
            end
        elseif math.abs(source.align - target.align) == 6 then
            target_line.margin_l = source.margin_l
            target_line.margin_r = source.margin_r
        elseif source.align + target.align == 10 then
            target_line.margin_l = source.margin_r
            target_line.margin_r = source.margin_l
        end
        if source.align >= 7 then
            target_line.margin_t = Yutils.math.round(source.margin_t + y0 - target_body_height + y3 + margin_offset)
        elseif source.align <= 3 then
            target_line.margin_t = Yutils.math.round(source.margin_t + source_body_height - y1 - y2 - margin_offset)
        else
            target_line.margin_t = source.margin_t
        end
    end
    if result.calculate_outline_and_shadow then
        target_line.outline = Yutils.math.round(source.outline * (result.area_ratio / 100) ^ (1/6),1)
        target_line.shadow = Yutils.math.round(source.shadow * (result.area_ratio / 100) ^ (1/6),1)
    end
    target_line.scale_x = source.scale_x
    target_line.scale_y = new_fscy
    target_line.angle = source.angle
    local spacing_offset,abs_spacing_offset = 0,source_wids / #text * 0.015
    if check_language(result.source_style) and check_language(result.target_style) then
        if check_language(result.source_style,"jk") and check_language(result.target_style,"c") then
            spacing_offset = abs_spacing_offset
        elseif check_language(result.source_style,"c") and check_language(result.target_style,"jk") then
            spacing_offset = -abs_spacing_offset
        end
    else
        if result.language == "日/韩 -> 中" then
            spacing_offset = abs_spacing_offset
        elseif result.language == "中 -> 日/韩" then
            spacing_offset = -abs_spacing_offset
        end
    end
    local spacing = source.spacing + ((source_x*area_coefficient - target_x) / #text + spacing_offset*area_coefficient) / source.scale_x * 100
    local target_spacing = Yutils.math.round(spacing,1)
    local source_spacing = same_align and -math.floor(spacing/area_coefficient*10)/10 or -target_spacing
    local real_first = 0
    for i,line in ipairs(subs) do
        if line.section == "[Events]" then
            real_first = i
            break
        end
    end
    local have_template = false
    for i = real_first,math.min(real_first+99,#subs) do
        if string.find(subs[i].effect,"^template") then
            have_template = true
            break
        end
    end
    if target_spacing < 0 then
        local dlg_cfg = {
            {
                class = "textbox",
                text = string.format("目标样式字间距计算结果为负值，可从以下两种方案中选择进行调整：\n方案一：参考样式字间距调大 %s\n方案二：目标样式字幕行添加标签 \\fsp%s（仅在没有特效模板行时可选）\n\n注：此错误通常是因为参考样式字体侧边距过小或目标样式字体侧边距过大",source_spacing,target_spacing),
                x = 0,y = 0,width = 46,height = 7,
            }
        }
        local btn = aegisub.dialog.display(
            dlg_cfg,
            have_template and {"方案一","取消"} or {"方案一","方案二","取消"},
            {ok = "方案一",cancel = "取消"}
        )
        if btn == "方案一" then
            local source_index = find_style(result.source_style)
            local source_line = subs[source_index]
            source_line.spacing = source_line.spacing + source_spacing
            subs[source_index] = source_line
        elseif btn == "方案二" then
            for i = real_first,#subs do
                local line = subs[i]
                if line.effect == "fx" then
                    break
                end
                if line.style == result.target_style then
                    if string.find(line.text,"\\fsp") then
                        line.text = string.gsub(line.text,"\\fsp[-.%d]+",string.format("\\fsp%s",target_spacing),1)
                    else
                        if string.find(line.text,"^{") then
                            line.text = string.gsub(line.text,"^{",string.format("{\\fsp%s",target_spacing))
                        else
                            line.text = string.format("{\\fsp%s}",target_spacing)..line.text
                        end
                    end
                end
                subs[i] = line
            end
        else
            aegisub.cancel()
        end
        target_line.spacing = 0
    else
        target_line.spacing = target_spacing
    end
    subs[target_index] = target_line
    if same_align and not have_template and (result.source_layer ~= -1 or result.target_layer ~= -1) then
        local keep_source_layer,keep_target_layer = result.source_layer == -1,result.target_layer == -1
        for i = real_first,#subs do
            local line = subs[i]
            if line.effect == "fx" then
                break
            end
            if line.style == result.source_style then
                line.layer = keep_source_layer and line.layer or result.source_layer
            elseif line.style == result.target_style then
                line.layer = keep_target_layer and line.layer or result.target_layer
            end
            subs[i] = line
        end
    end
    aegisub.set_undo_point(script_name.."："..result.source_style.." → "..result.target_style)
end

aegisub.register_macro(script_name,script_description,styles_helper)