script_name = "双语样式匹配工具"
script_description = "根据参考样式计算目标样式的参数，使之在视觉上与参考样式相匹配（支持中日韩字体）"
script_author = "松坂さとう"
script_version = "4.0.2"

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
    table.sort(style_names,function (a,b) return a > b end)
    local function check_language(style,mode)
        style = string.upper(style)
        local _,cn = string.gsub(style,"CN","")
        local _,tw = string.gsub(style,"TW","")
        local _,hk = string.gsub(style,"HK","")
        local _,jp = string.gsub(style,"JP","")
        local _,kr = string.gsub(style,"KR","")
        return (mode == "c" and cn + tw + hk or cn + tw + hk + jp + kr) == 1
    end
    local lang_style_names = {}
    for i = 1,#style_names do
        if check_language(style_names[i]) then
            table.insert(lang_style_names,style_names[i])
        end
    end
    local function find_default_style(styles_tbl,priority_list)
        if #styles_tbl < 2 then
            return nil
        end
        for _,lang in ipairs(priority_list) do
            for _,style in ipairs(styles_tbl) do
                if style:upper():find(lang) then
                    return style
                end
            end
        end
    end
    local function label(text,x,y)
        return {class = "label",label = text,x = x,y = y}
    end
    local function dropdown(name,items,value,y,hint)
        return {class = "dropdown",name = name,items = items,value = value,hint = hint,x = 1,y = y}
    end
    local function intedit(name,value,min,max,y,hint)
        return {class = "intedit",name = name,value = value,min = min,max = max,hint = hint,x = 1,y = y}
    end
    local function checkbox(text,name,value,x,y,width,hint)
        return {class = "checkbox",label = text,name = name,value = value,hint = hint,x = x,y = y,width = width}
    end
    local dialog_config = {
        label("   参考样式：",0,0),
        dropdown("source_style",style_names,find_default_style(lang_style_names,{"JP","KR","TW","HK","CN"}) or style_names[1],0,"参考样式需要设置好全部参数\n并且当样式名列表中包含 JP/KR/TW/HK/CN 语言标识的样式数量 ≥2 时，会按照语言优先级选择默认值\n当参考样式和目标样式对齐方式相同时，保证参考样式更靠近画面边缘"),
        label("   目标样式：",0,1),
        dropdown("target_style",style_names,find_default_style(lang_style_names,{"CN","HK","TW","KR","JP"}) or style_names[2],1,"目标样式需要设置好以下参数：样式名、字体、粗体、斜体、对齐方式\n并且当样式名列表中包含 CN/HK/TW/KR/JP 语言标识的样式数量 ≥2 时，会按照语言优先级选择默认值\n当参考样式和目标样式对齐方式相同时，保证目标样式更靠近画面中心"),
        label("   面积比值：",0,2),
        intedit("area_ratio",250,25,400,2,"目标样式平均字面框面积 / 参考样式平均字面框面积\n底部对齐推荐值为 250 ，顶部对齐推荐值为 40\n仅在参考样式和目标样式对齐方式相同时生效"),
        label("%",2,2),
        label("   参考层数：",0,3),
        intedit("source_layer",-1,-1,2^31-1,3,"设定参考样式字幕行的层数，-1 表示不修改层数\n仅在参考样式和目标样式对齐方式相同且没有特效模板行时生效"),
        label("   目标层数：",0,4),
        intedit("target_layer",-1,-1,2^31-1,4,"设定目标样式字幕行的层数，-1 表示不修改层数\n仅在参考样式和目标样式对齐方式相同且没有特效模板行时生效"),
        checkbox("复制颜色","copy_colors",true,0,5),
        checkbox("计算边框阴影","calculate_outline_and_shadow",true,1,5),
        checkbox("互换左右边距","swap_lr_margin",false,0,6,2,"只在对齐方式为 2 + 8 时生效")
    }
    if #lang_style_names < #style_names then
        table.insert(dialog_config,5,label("   对应语言：",0,2))
        table.insert(dialog_config,6,dropdown("language",{"日/韩 -> 中","中 -> 日/韩","中 -> 中","日/韩 -> 日/韩"},"日/韩 -> 中",2,"参考样式语言 -> 目标样式语言\n参考样式和目标样式都含有语言标识时不生效\n所有合法样式都含有语言标识时不显示"))
        for i = 7,#dialog_config do
            dialog_config[i].y = dialog_config[i].y + 1
        end
    end
    local button,result = aegisub.dialog.display(dialog_config,{"确定","取消"},{ok = "确定",cancel = "取消"})
    aegisub_exit(button ~= "确定")
    aegisub_exit(result.source_style == result.target_style,"目标样式不能与参考样式相同")
    local both_lang = check_language(result.source_style) and check_language(result.target_style)
    local function strip_lang(style)
        return style:upper():gsub("JP",""):gsub("KR",""):gsub("TW",""):gsub("HK",""):gsub("CN","")
    end
    aegisub_exit(both_lang and strip_lang(result.source_style) ~= strip_lang(result.target_style),"目标样式除语言标识外应与参考样式相同")
    local source,target = styles[result.source_style],styles[result.target_style]
    aegisub_exit(source.underline,"参考样式不能开启下划线")
    aegisub_exit(source.strikeout,"参考样式不能开启删除线")
    aegisub_exit(source.fontsize == 0,"参考样式字号不能为 0")
    aegisub_exit(source.encoding ~= 1,"参考样式编码必须为 1")
    aegisub_exit(source.angle ~= 0,"参考样式旋转角度必须为 0")
    aegisub_exit(source.margin_l < 0,"参考样式左边距不能小于 0")
    aegisub_exit(source.margin_r < 0,"参考样式右边距不能小于 0")
    aegisub_exit(source.scale_x == 0,"参考样式水平缩放不能为 0")
    aegisub_exit(source.scale_y == 0,"参考样式垂直缩放不能为 0")
    aegisub_exit(source.borderstyle ~= 1,"参考样式的边框样式必须为 1")
    aegisub_exit(string.find(source.fontname,"^@"),"参考样式字体名称不能以 @ 开头")
    aegisub_exit(string.find(target.fontname,"^@"),"目标样式字体名称不能以 @ 开头")
    aegisub_exit(not source.italic and target.italic,"参考样式未开启斜体时，目标样式也不能开启斜体")
    local source_font = Yutils.decode.create_font(source.fontname,source.bold,false,false,false,source.fontsize,source.scale_x/100,source.scale_y/100)
    aegisub_exit(source_font.text_to_shape("一") == "","参考样式字号过大")
    local target_font = Yutils.decode.create_font(target.fontname,target.bold,false,false,false,source.fontsize,source.scale_x/100,source.scale_y/100)
    aegisub_exit(target_font.text_to_shape("一") == "","参考样式字号过大")
    local max_margin = math.floor(tonumber(meta.playresy)*0.25)
    aegisub_exit(source.margin_t > max_margin,"参考样式垂直边距不能大于 %d",max_margin)
    local function check_align(s,t)
        local map = {[1]={1,7,9},[2]={2,8},[3]={3,7,9},[4]={},[5]={},[6]={},[7]={1,3,7},[8]={2,8},[9]={1,3,9}}
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
    local function update_extreme(t,x1,x2,x3,x4,min_val,max_val)
        if t > 0 and t < 1 then
            local val = x1*(1-t)^3 + 3*x2*t*(1-t)^2 + 3*x3*t^2*(1-t) + x4*t^3
            min_val,max_val = math.min(min_val,val),math.max(max_val,val)
        end
        return min_val,max_val
    end
    local function bezier_bounding(x1,x2,x3,x4)
        local a,b,c = 3*x4 - 9*x3 + 9*x2 - 3*x1,6*x3 - 12*x2 + 6*x1,3*x2 - 3*x1
        local min_val,max_val = math.min(x1,x4),math.max(x1,x4)
        if math.abs(a) < 1e-9 then
            if math.abs(b) > 1e-9 then
                min_val,max_val = update_extreme(-c/b,x1,x2,x3,x4,min_val,max_val)
            end
            return min_val,max_val
        end
        local delta = b^2 - 4*a*c
        if delta < 0 then
            return min_val,max_val
        end
        min_val,max_val = update_extreme((-b+delta^0.5)/(2*a),x1,x2,x3,x4,min_val,max_val)
        min_val,max_val = update_extreme((-b-delta^0.5)/(2*a),x1,x2,x3,x4,min_val,max_val)
        return min_val,max_val
    end
    local function real_bounding(ass_shape)
        local xmin,ymin,xmax,ymax = math.huge,math.huge,-math.huge,-math.huge
        local cx,cy = 0,0
        for cmd,nums in string.gmatch(ass_shape,"([mlb])([- .%d]+)") do
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
        return xmax-xmin,ymax-ymin,ymin,ymax
    end
    local _,_,y0,y1 = real_bounding(source_font.text_to_shape(long_text))
    source.italic = false
    local source_body_width,source_body_height = aegisub.text_extents(source,text[1])
    local margin = source.margin_t + (source.align >= 7 and y0 or source_body_height - y1)
    aegisub_exit(margin < 0,"参考样式文字主体边缘到画面边缘的距离不能为负值\n请把垂直边距至少调大 %d",math.ceil(-margin))
    local same_align = source.align == target.align
    local area_ratio = same_align and result.area_ratio/100 or 1
    local length_ratio = area_ratio ^ 0.5
    local source_wids,source_heis,target_wids,target_heis = 0,0,0,0
    for i = 1,#text do
        local sw,sh = real_bounding(source_font.text_to_shape(text[i]))
        local tw,th = real_bounding(target_font.text_to_shape(text[i]))
        source_wids = source_wids + sw
        target_wids = target_wids + tw
        source_heis = source_heis + sh
        target_heis = target_heis + th
    end
    local round = Yutils.math.round
    local new_fontsize = round(source.fontsize * source_wids / target_wids * length_ratio)
    aegisub_exit(new_fontsize == 0,"参考样式字号过小或面积比值过小")
    local new_scale_y = round(source.scale_y * target_wids / source_wids * source_heis / target_heis)
    aegisub_exit(new_scale_y == 0,"参考样式垂直缩放过小")
    local transition_font = Yutils.decode.create_font(target.fontname,target.bold,false,false,false,new_fontsize,source.scale_x/100,new_scale_y/100)
    aegisub_exit(transition_font.text_to_shape("一") == "","参考样式字号过大或面积比值过大")
    local temporary_target = table.copy(source)
    temporary_target.fontname = target.fontname
    temporary_target.bold = target.bold
    temporary_target.fontsize = new_fontsize
    temporary_target.scale_y = new_scale_y
    local _,_,y2,y3 = real_bounding(transition_font.text_to_shape(long_text))
    local target_body_width,target_body_height = aegisub.text_extents(temporary_target,text[1])
    local target_x = #text * target_body_width
    for i = 1,#text do
        target_x = target_x - real_bounding(transition_font.text_to_shape(text[i]))
    end
    local direction = 0
    if both_lang then
        local source_c = check_language(result.source_style,"c")
        direction = source_c ~= check_language(result.target_style,"c") and (source_c and -1 or 1) or 0
    else
        direction = ({["日/韩 -> 中"] = 1,["中 -> 日/韩"] = -1})[result.language] or 0
    end
    local spacing_offset = source_wids / #text * 0.015 * direction
    local spacing = source.spacing + ((#text*(source_body_width + spacing_offset) - source_wids)*length_ratio - target_x) / #text / source.scale_x * 100
    local target_spacing = round(spacing,1)
    local change_source_layer,change_target_layer = result.source_layer ~= -1,result.target_layer ~= -1
    local need_layer_processing = same_align and (change_source_layer or change_target_layer)
    local have_template = false
    if target_spacing < 0 or need_layer_processing then
        for i = real_first,math.min(real_first+99,#subs) do
            if subs[i].effect:headtail():lower() == "template" then
                have_template = true
                break
            end
        end
    end
    local function find_style(style)
        for i,line in ipairs(subs) do
            if line.name == style then
                return i
            end
        end
    end
    if target_spacing < 0 then
        local source_spacing = same_align and math.ceil(-spacing/length_ratio*10)/10 or -target_spacing
        local dlg_cfg = {label(string.format("目标样式字间距计算结果为负值，可以从以下两种方案中选择进行调整：\n方案一：参考样式字间距调大 %s\n方案二：目标样式字幕行添加标签 \\fsp%s（仅在没有特效模板行时可选）\n\n注：此错误通常是因为参考样式字体侧边距过小或目标样式字体侧边距过大",source_spacing,target_spacing))}
        local btn = aegisub.dialog.display(dlg_cfg,have_template and {"方案一","取消"} or {"方案一","方案二","取消"},{ok = "方案一",cancel = "取消"})
        if btn == "方案一" then
            local source_index = find_style(result.source_style)
            local source_line = subs[source_index]
            source_line.spacing = source_line.spacing + source_spacing
            subs[source_index] = source_line
        elseif btn == "方案二" then
            local fsp_tag = string.format("\\fsp%s",target_spacing)
            for i = real_first,#subs do
                local line = subs[i]
                if line.effect == "fx" then
                    break
                end
                if not line.comment and line.style == result.target_style then
                    local new_text,replaced = string.gsub(line.text,"\\ *fsp *[-.%d]+",fsp_tag)
                    line.text = replaced > 0 and new_text or (string.find(line.text,"^{") and "{"..fsp_tag..string.sub(line.text,2) or "{"..fsp_tag.."}"..line.text)
                    subs[i] = line
                end
            end
        else
            aegisub.cancel()
        end
    end
    local target_index = find_style(result.target_style)
    local target_line = subs[target_index]
    target_line.fontsize = new_fontsize
    target_line.underline = false
    target_line.strikeout = false
    if result.copy_colors then
        target_line.color1 = source.color1
        target_line.color2 = source.color2
        target_line.color3 = source.color3
        target_line.color4 = source.color4
    end
    if result.calculate_outline_and_shadow then
        local border_scale = area_ratio ^ (1/6)
        target_line.outline = round(source.outline * border_scale,1)
        target_line.shadow = round(source.shadow * border_scale,1)
    end
    local swap_lr = source.align + target.align == 10
    if same_align then
        local distance = (y1 - y0 + y3 - y2) * 0.15
        local function alpha_coefficient(color)
            local _,_,_,alpha = extract_color(color)
            return (1-(alpha/255)^2)*0.5
        end
        local outline = source.outline * alpha_coefficient(source.color3) + target_line.outline * alpha_coefficient(target_line.color3)
        if source.align >= 7 then
            target_line.margin_t = round(source.margin_t + distance + y1 - y2 + outline + source.shadow*alpha_coefficient(source.color4))
        else
            target_line.margin_t = round(source.margin_t + distance + source_body_height - y0 - target_body_height + y3 + outline + target_line.shadow*alpha_coefficient(target_line.color4))
        end
    else
        if source.align % 6 == 2 then
            swap_lr = result.swap_lr_margin
        end
        local max_margin_comp = tonumber(meta.playresy)/216
        if source.align >= 7 then
            target_line.margin_t = round(source.margin_t + y0 - target_body_height + y3 + math.min(margin/5,max_margin_comp))
        else
            target_line.margin_t = round(source.margin_t + source_body_height - y1 - y2 - math.min(margin/6,max_margin_comp))
        end
    end
    target_line.margin_l = swap_lr and source.margin_r or source.margin_l
    target_line.margin_r = swap_lr and source.margin_l or source.margin_r
    target_line.borderstyle = 1
    target_line.scale_x = source.scale_x
    target_line.scale_y = new_scale_y
    target_line.angle = 0
    target_line.spacing = math.max(target_spacing,0)
    target_line.encoding = 1
    subs[target_index] = target_line
    if need_layer_processing and not have_template then
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