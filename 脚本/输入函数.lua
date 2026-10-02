script_name = "输入函数"
script_description = "保留换行和缩进，能够便捷地输入和修改函数"
script_author = "松坂さとう"
script_version = "1.0"

local function split_utf8(s)
    local i = 1
    local t = {}
    while i <= #s do
        local b = s:byte(i)
        local len = 1
        if b >= 0xF0 then
            len = 4
        elseif b >= 0xE0 then
            len = 3
        elseif b >= 0xC0 then
            len = 2
        end
        t[#t+1] = s:sub(i,i+len-1)
        i = i + len
    end
    return t
end

local function match_long_bracket(chars,i)
    if chars[i] ~= "[" then
        return nil
    end
    local eq = 0
    local j = i + 1
    while chars[j] == "=" do
        eq = eq + 1
        j = j + 1
    end
    if chars[j] ~= "[" then
        return nil
    end
    local close = "]"..string.rep("=",eq).."]"
    local close_chars = split_utf8(close)
    local clen = #close_chars
    local k = j + 1
    while k <= #chars do
        if chars[k] == "]" then
            local ok = true
            for m = 1,clen do
                if chars[k+m-1] ~= close_chars[m] then
                    ok = false
                    break
                end
            end
            if ok then
                return k + clen - 1
            end
        end
        k = k + 1
    end
    return #chars
end

local function fullwidth_space_to_newline(text)
    local chars = split_utf8(text)
    local out = {}
    local i = 1
    while i <= #chars do
        local c = chars[i]
        if c == '"' or c == "'" then
            local quote = c
            out[#out+1] = c
            i = i + 1
            while i <= #chars do
                local d = chars[i]
                out[#out+1] = d
                if d == "\\" then
                    if i + 1 <= #chars then
                        out[#out+1] = chars[i+1]
                        i = i + 2
                    else
                        i = i + 1
                    end
                elseif d == quote then
                    i = i + 1
                    break
                else
                    i = i + 1
                end
            end
        elseif c == "[" then
            local fin = match_long_bracket(chars,i)
            if fin then
                for k = i,fin do
                    out[#out+1] = chars[k]
                end
                i = fin + 1
            else
                out[#out+1] = c
                i = i + 1
            end
        elseif c == "　" then
            out[#out+1] = "\n"
            i = i + 1
        else
            out[#out+1] = c
            i = i + 1
        end
    end
    return table.concat(out)
end

local function newline_to_fullwidth_space(text)
    return text:gsub("\n","　")
end

local function linebreak_tag_to_fullwidth_space(text)
    return text:gsub("\\N","　")
end

local function count_lines(text)
    local n = 1
    for _ in text:gmatch("\n") do
        n = n + 1
    end
    return n
end

function enter_function(subs,sel)
    if #sel == 0 then
        aegisub.cancel()
    end
    local line = subs[sel[1]]
    local text = line.text
    if text:find("\\N") then
        line.text = linebreak_tag_to_fullwidth_space(text)
        subs[sel[1]] = line
    else
        local shown = fullwidth_space_to_newline(text)
        local rows = count_lines(shown) + 2
        local height = math.max(20,math.min(40,rows))
        local dlg = {
            {
                class = "textbox",
                name = "txt",
                value  = shown,
                x = 0,y = 0,width = height*2,height = height
            }
        }
        local btn,res = aegisub.dialog.display(
            dlg,
            {"确定","取消"},
            {ok = "确定",cancel = "取消"}
        )
        if btn ~= "确定" then
            aegisub.cancel()
        end
        line.text = newline_to_fullwidth_space(res.txt)
        subs[sel[1]] = line
    end
    aegisub.set_undo_point(script_name)
end

aegisub.register_macro(script_name,script_description,enter_function)