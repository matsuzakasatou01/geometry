script_name = "平移字幕行"
script_description = "修改标签中的坐标参数"
script_author = "松坂さとう"
script_version = "1.0"

include("karaskel.lua")

local function round3(num)
    return math.floor(num*1000+0.5)/1000
end

local function shift(v,d)
    return round3(tonumber(v)+d)
end

local function proc_pos(text,dx,dy)
    return text:gsub("\\pos%s*%(%s*([-.%d]+)%s*,%s*([-.%d]+)%s*%)",
    function(x,y)
        return string.format("\\pos(%s,%s)",shift(x,dx),shift(y,dy))
    end)
end

local function proc_move(text,dx,dy)
    return text:gsub("\\move%s*%(%s*([-.%d]+)%s*,%s*([-.%d]+)%s*,%s*([-.%d]+)%s*,%s*([-.%d]+)%s*([^%)]*)%)",
    function(x1,y1,x2,y2,time)
        return string.format("\\move(%s,%s,%s,%s%s)",shift(x1,dx),shift(y1,dy),shift(x2,dx),shift(y2,dy),time)
    end)
end

local function proc_org(text,dx,dy)
    return text:gsub("\\org%s*%(%s*([-.%d]+)%s*,%s*([-.%d]+)%s*%)",
    function(x,y)
        return string.format("\\org(%s,%s)",shift(x,dx),shift(y,dy))
    end)
end

local function proc_clip(text,dx,dy)
    local function handler(prefix,inner)
        local nums = {}
        for n in inner:gmatch("[-.%d]+") do
            nums[#nums+1] = n
        end
        local leftover = inner:gsub("[-.%d%s,]","")
        if leftover == "" and #nums == 4 then
            return string.format("%s(%s,%s,%s,%s)",prefix,shift(nums[1],dx),shift(nums[2],dy),shift(nums[3],dx),shift(nums[4],dy))
        else
            local scale_part = ""
            local body = inner
            if inner:find("^%s*[-.%d]+%s*,") then
                local s = inner:match("^%s*([-.%d]+)%s*,")
                scale_part = s..","
                body = inner:sub(inner:find(",")+1)
            end
            local idx = 0
            local out = body:gsub("[-.%d]+",function(num)
                idx = idx + 1
                if idx % 2 == 1 then
                    return shift(num,dx)
                else
                    return shift(num,dy)
                end
            end)
            return string.format("%s(%s%s)",prefix,scale_part,out)
        end
    end
    text = text:gsub("(\\iclip)%s*%(([^%)]*)%)",handler)
    text = text:gsub("(\\clip)%s*%(([^%)]*)%)",handler)
    return text
end

local function default_pos(line,xres,yres,an,styleref)
    local m = line.text:match("\\an(%d)")
    if m then
        an = tonumber(m)
    end
    local ml,mr,mt,mb = styleref.margin_l,styleref.margin_r,styleref.margin_t,styleref.margin_b
    if an == 1 then return ml,yres-mb
    elseif an == 2 then return xres/2,yres-mb
    elseif an == 3 then return xres-mr,yres-mb
    elseif an == 4 then return ml,yres/2
    elseif an == 5 then return xres/2,yres/2
    elseif an == 6 then return xres-mr,yres/2
    elseif an == 7 then return ml,mt
    elseif an == 8 then return xres/2,mt
    elseif an == 9 then return xres-mr,mt
    end
end

local function is_skippable(line)
    if line.comment then
        return true
    elseif line.effect:find("^code") or line.effect:find("^template") then
        return true
    end
    return false
end

function trans_sel(subs,sel)
    if #sel == 0 then
        aegisub.cancel()
    end
    local xres,yres = aegisub.video_size()
    if not xres or not yres then
        aegisub.log("请先打开视频")
        aegisub.cancel()
    end
    local dialog = {
        {class = "label",label = " x 偏移量：",x = 0,y = 0,width = 1,height = 1},
        {class = "intedit",name = "dx",value = 0,x = 1,y = 0,width = 1,height = 1},
        {class = "label",label = " y 偏移量：",x = 0,y = 1,width = 1,height = 1},
        {class = "intedit",name = "dy",value = 0,x = 1,y = 1,width = 1,height = 1}
    }
    local button,result = aegisub.dialog.display(
        dialog,
        {"确定","取消"},
        {ok = "确定",cancel = "取消"}
    )
    if button ~= "确定" then
        aegisub.cancel()
    end
    local dx,dy = result.dx,result.dy
    if dx == 0 and dy == 0 then
        aegisub.cancel()
    end
    for i,li in ipairs(sel) do
        aegisub.progress.set(i/#sel*100)
        local line = subs[li]
        if not is_skippable(line) then
            local text = line.text
            if not text:find("\\pos%s*%(") and not text:find("\\move%s*%(") then
                local meta,styles = karaskel.collect_head(subs)
                karaskel.preproc_line(subs,meta,styles,line)
                local px,py = default_pos(line,xres,yres,styles[line.style].align,line.styleref)
                px,py = round3(px),round3(py)
                if text:find("^{") then
                    text = text:gsub("^{",string.format("{\\pos(%s,%s)",px,py))
                else
                    text = string.format("{\\pos(%s,%s)}",px,py)..text
                end
            end
            text = proc_pos(text,dx,dy)
            text = proc_move(text,dx,dy)
            text = proc_org(text,dx,dy)
            text = proc_clip(text,dx,dy)
            line.text = text
            subs[li] = line
        end
    end
    aegisub.set_undo_point(script_name.."   x : "..dx.."   y : "..dy)
end

aegisub.register_macro(script_name,script_description,trans_sel)