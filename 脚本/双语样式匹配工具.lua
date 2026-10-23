script_name = "双语样式匹配工具"
script_description = "根据参考样式计算目标样式的参数，使之在视觉上与参考样式相匹配（支持中日韩字体）"
script_author = "松坂さとう"
script_version = "2.0.0"

include("karaskel.lua")
local OK,Yutils = pcall(require,"Yutils")

function match_bilingual_styles(subs)
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
    aegisub_exit(not meta.playresy,"请先打开视频")
    local style_names = {}
    for name in pairs(styles) do
        if type(name) == "string" and string.find(name,"^%S") and string.find(name,"%S$") and name ~= "n" and not string.find(name,"-furigana$") then
            style_names[#style_names+1] = name
        end
    end
    aegisub_exit(#style_names < 2,"至少需要两个非假名样式")
    local real_first = #subs + 1
    for i,line in ipairs(subs) do
        if line.section == "[Events]" then
            real_first = i
            break
        end
    end
    aegisub_exit(#subs - real_first + 1 < 2,"至少需要两行字幕")
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
            hint = "目标样式需要设置好以下参数：样式名、字体、粗体、斜体、对齐方式和编码\n并且当样式名列表中包含 CN/HK/TW/KR/JP 语言标识的样式数量 ≥2 时，会按照语言优先级选择默认值\n当参考样式和目标样式对齐方式相同且为底部或顶部对齐时，保证目标样式更靠近画面中心",
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
            x = 1,y = 2,width = 1,height = 1
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
            x = 1,y = 3,width = 1,height = 1
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
            x = 1,y = 4,width = 1,height = 1
        },
        {
            class = "checkbox",
            label = "复制颜色",
            name = "copy_colors",
            value = true,
            hint = "只在边框样式为 1 时生效",
            x = 0,y = 5,width = 1,height = 1
        },
        {
            class = "checkbox",
            label = "计算边框阴影",
            name = "calculate_outline_and_shadow",
            value = true,
            hint = "只在边框样式为 1 时生效",
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
    aegisub_exit(source.fontsize == 0,"参考样式字号不能为 0")
    aegisub_exit(source.margin_l < 0,"参考样式左边距不能小于 0")
    aegisub_exit(source.margin_r < 0,"参考样式右边距不能小于 0")
    aegisub_exit(source.scale_x == 0,"参考样式水平缩放不能为 0")
    aegisub_exit(source.scale_y == 0,"参考样式垂直缩放不能为 0")
    aegisub_exit(not source.italic and target.italic,"参考样式未开启斜体时，目标样式也不能开启斜体")
    source.italic = source.italic == target.italic and source.italic
    local source_font = Yutils.decode.create_font(source.fontname,source.bold,source.italic,false,false,source.fontsize,source.scale_x/100,source.scale_y/100,source.spacing)
    aegisub_exit(source_font.text_to_shape("一") == "","参考样式字号过大")
    local target_font = Yutils.decode.create_font(target.fontname,target.bold,source.italic,false,false,source.fontsize,source.scale_x/100,source.scale_y/100,source.spacing)
    aegisub_exit(target_font.text_to_shape("一") == "","参考样式字号过大")
    local function check_align(s,t)
        local map = {[1]={1,7,9},[2]={2,8},[3]={3,7,9},[4]={},[5]={5},[6]={},[7]={1,3,7},[8]={2,8},[9]={1,3,9}}
        if #map[s] == 0 then
            return false,"参考样式的对齐方式不能为 "..tostring(s)
        end
        for i = 1,#map[s] do
            if map[s][i] == t then
                return true
            end
        end
        return false,"目标样式的对齐方式必须为 "..table.concat(map[s]," 或 ")
    end
    local ok,message = check_align(source.align,target.align)
    aegisub_exit(not ok,message)
    local text = {"二","十","三","上","川","口","日","月","夕","木","田","白","目","生","血","自","走","品","星","重"}
    local long_text = table.concat(text)
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
            if math.abs(a) < 1e-9 then
                if math.abs(b) > 1e-9 then
                    update_extreme(-c / b)
                end
                return min_val,max_val
            end
            local delta = b^2 - 4*a*c
            if delta < 0 then
                return min_val,max_val
            end
            update_extreme((-b + delta^0.5) / (2*a))
            update_extreme((-b - delta^0.5) / (2*a))
            return min_val,max_val
        end
        string.gsub(ass_shape,"m[^m]+",function(m)
            local cx,cy = 0,0
            for cmd,nums in string.gmatch(m,"([mlb])([- .%d]+)") do
                local pt = {}
                for num in string.gmatch(nums,"[-.%d]+") do
                    pt[#pt+1] = tonumber(num)
                end
                if cmd == "m" then
                    cx,cy = pt[#pt-1],pt[#pt]
                elseif cmd == "l" then
                    for i = 1,#pt-1,2 do
                        xmin,xmax = math.min(xmin,cx,pt[i]),math.max(xmax,cx,pt[i])
                        ymin,ymax = math.min(ymin,cy,pt[i+1]),math.max(ymax,cy,pt[i+1])
                        cx,cy = pt[i],pt[i+1]
                    end
                else
                    for i = 1,#pt-5,6 do
                        local minx,maxx = bezier_bounding(cx,pt[i],pt[i+2],pt[i+4])
                        local miny,maxy = bezier_bounding(cy,pt[i+1],pt[i+3],pt[i+5])
                        xmin,xmax = math.min(xmin,minx),math.max(xmax,maxx)
                        ymin,ymax = math.min(ymin,miny),math.max(ymax,maxy)
                        cx,cy = pt[i+4],pt[i+5]
                    end
                end
            end
        end)
        return xmax-xmin,ymax-ymin,ymin,ymax
    end
    local _,_,y0,y1 = real_bounding(source_font.text_to_shape(long_text))
    local source_body_width,source_body_height = aegisub.text_extents(source,text[1])
    local margin = 0
    if source.align >= 7 then
        margin = source.margin_t + y0
    elseif source.align <= 3 then
        margin = source.margin_t + source_body_height - y1
    end
    aegisub_exit(margin < 0,"参考样式字幕边缘到视频边缘的距离不能为负值\n请把垂直边距至少调大 %d",-math.floor(margin))
    local same_align = source.align == target.align and (source.align <= 3 or source.align >= 7)
    result.area_ratio = same_align and result.area_ratio or 100
    local length_ratio = (result.area_ratio / 100) ^ 0.5
    local source_wids,source_heis,target_wids,target_heis = 0,0,0,0
    local source_bounding = {}
    for i = 1,#text do
        local sw,sh = real_bounding(source_font.text_to_shape(text[i]))
        local tw,th = real_bounding(target_font.text_to_shape(text[i]))
        source_bounding[i] = {w = sw,h = sh}
        source_wids = source_wids + sw
        target_wids = target_wids + tw
        source_heis = source_heis + sh
        target_heis = target_heis + th
    end
    local new_fontsize = Yutils.math.round(source.fontsize * source_wids / target_wids * length_ratio)
    local new_fscy = Yutils.math.round(source.scale_y * target_wids / source_wids * source_heis / target_heis)
    local transition_font = Yutils.decode.create_font(target.fontname,target.bold,source.italic,false,false,new_fontsize,source.scale_x/100,new_fscy/100,source.spacing)
    aegisub_exit(transition_font.text_to_shape("一") == "","参考样式字号过大或面积比值过大")
    local temporary_target = table.copy(source)
    temporary_target.fontname = target.fontname
    temporary_target.bold = target.bold
    temporary_target.underline = false
    temporary_target.strikeout = false
    temporary_target.fontsize = new_fontsize
    temporary_target.scale_y = new_fscy
    local _,_,y2,y3 = real_bounding(transition_font.text_to_shape(long_text))
    local target_body_width,target_body_height = aegisub.text_extents(temporary_target,text[1])
    local source_x,target_x = 0,0
    for i = 1,#text do
        source_x = source_x + source_body_width - source_bounding[i].w
        target_x = target_x + target_body_width - real_bounding(transition_font.text_to_shape(text[i]))
    end
    local margin_offset = math.min(0.2*margin,tonumber(meta.playresy)/216)
    local function find_style(style)
        for i,line in ipairs(subs) do
            if line.name == style then
                return i
            end
        end
    end
    local target_index = find_style(result.target_style)
    local target_line = subs[target_index]
    target_line.fontsize = new_fontsize
    target_line.underline = source.underline
    target_line.strikeout = source.strikeout
    if source.borderstyle ~= 1 or result.copy_colors then
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
        else
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
        else
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
    if source.borderstyle ~= 1 or result.calculate_outline_and_shadow then
        target_line.outline = Yutils.math.round(source.outline * (result.area_ratio / 100) ^ (1/6),1)
        target_line.shadow = Yutils.math.round(source.shadow * (result.area_ratio / 100) ^ (1/6),1)
    end
    target_line.borderstyle = source.borderstyle
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
    local spacing = source.spacing + ((source_x*length_ratio - target_x) / #text + spacing_offset*length_ratio) / source.scale_x * 100
    local target_spacing = Yutils.math.round(spacing,1)
    local source_spacing = same_align and -math.floor(spacing/length_ratio*10)/10 or -target_spacing
    local have_template = false
    for i = real_first,math.min(real_first+99,#subs) do
        if subs[i].effect:headtail():lower() == "template" then
            have_template = true
            break
        end
    end
    if target_spacing < 0 then
        local dlg_cfg = {
            {
                class = "label",
                label = string.format("目标样式字间距计算结果为负值，可以从以下两种方案中选择进行调整：\n方案一：参考样式字间距调大 %s\n方案二：目标样式字幕行添加标签 \\fsp%s（仅在没有特效模板行时可选）\n\n注：此错误通常是因为参考样式字体侧边距过小或目标样式字体侧边距过大",source_spacing,target_spacing),
                x = 0,y = 0,width = 1,height = 1
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
                if not line.comment and line.style == result.target_style then
                    if string.find(line.text,"\\ *fsp") then
                        line.text = string.gsub(line.text,"\\ *fsp *[-.%d]+",string.format("\\fsp%s",target_spacing))
                    else
                        if string.find(line.text,"^{") then
                            line.text = string.gsub(line.text,"^{",string.format("{\\fsp%s",target_spacing))
                        else
                            line.text = string.format("{\\fsp%s}",target_spacing)..line.text
                        end
                    end
                    subs[i] = line
                end
            end
        else
            aegisub.cancel()
        end
        target_line.spacing = 0
    else
        target_line.spacing = target_spacing
    end
    subs[target_index] = target_line
    local change_source_layer,change_target_layer = result.source_layer ~= -1,result.target_layer ~= -1
    if same_align and not have_template and (change_source_layer or change_target_layer) then
        for i = real_first,#subs do
            local line = subs[i]
            if line.effect == "fx" then
                break
            end
            if not line.comment then
                if change_source_layer and line.style == result.source_style then
                    line.layer = result.source_layer
                    subs[i] = line
                elseif change_target_layer and line.style == result.target_style then
                    line.layer = result.target_layer
                    subs[i] = line
                end
            end
        end
    end
    aegisub.set_undo_point(script_name.."："..result.source_style.." -> "..result.target_style)
end

aegisub.register_macro(script_name,script_description,match_bilingual_styles)