function round(diameter,clockwise)--固定直径圆形，可指定路径方向
    if clockwise == nil then
        clockwise = 0
    end
    local a = diameter/2
    local b = a*4/3
    if clockwise == 0 then
        return string.format("m %.3f %.3f b %.3f %.3f %.3f %.3f %.3f %.3f b %.3f %.3f %.3f %.3f %.3f %.3f ",-a,0,-a,-b,a,-b,a,0,a,b,-a,b,-a,0)
    elseif clockwise == 1 then
        return string.format("m %.3f %.3f b %.3f %.3f %.3f %.3f %.3f %.3f b %.3f %.3f %.3f %.3f %.3f %.3f ",a,0,a,-b,-a,-b,-a,0,-a,b,a,b,a,0)
    end
end

function random_round(min,max,clockwise)--随机范围直径圆形，可指定路径方向
    if clockwise == nil then
        clockwise = 0
    end
    local a = math.random(min/2,max/2)
    local b = a*4/3
    if clockwise == 0 then
        return string.format("m %.3f %.3f b %.3f %.3f %.3f %.3f %.3f %.3f b %.3f %.3f %.3f %.3f %.3f %.3f ",-a,0,-a,-b,a,-b,a,0,a,b,-a,b,-a,0)
    elseif clockwise == 1 then
        return string.format("m %.3f %.3f b %.3f %.3f %.3f %.3f %.3f %.3f b %.3f %.3f %.3f %.3f %.3f %.3f ",a,0,a,-b,-a,-b,-a,0,-a,b,a,b,a,0)
    end
end

function regular_triangle(length,clockwise)--固定大小正三角形，可指定路径方向
    if clockwise == nil then
        clockwise = 0
    end
    local a = length
    local b = a/2*3^0.5
    local c = a/2
    if clockwise == 0 then
        return string.format("m %.3f %.3f l %.3f %.3f l %.3f %.3f ",-b,c,0,-a,b,c)
    elseif clockwise == 1 then
        return string.format("m %.3f %.3f l %.3f %.3f l %.3f %.3f ",b,c,0,-a,-b,c)
    end
end

function square(length,clockwise)--固定边长正方形，可指定路径方向
    if clockwise == nil then
        clockwise = 0
    end
    local a = length
    if clockwise == 0 then
        return string.format("m -%.1f -%.1f l %.1f -%.1f l %.1f %.1f l -%.1f %.1f ",a/2,a/2,a/2,a/2,a/2,a/2,a/2,a/2)
    elseif clockwise == 1 then
        return string.format("m -%.1f -%.1f l -%.1f %.1f l %.1f %.1f l %.1f -%.1f ",a/2,a/2,a/2,a/2,a/2,a/2,a/2,a/2)
    end
end

function random_square(min,max,clockwise)--随机范围边长正方形，可指定路径方向
    if clockwise == nil then
        clockwise = 0
    end
    local a = math.random(min,max)
    if clockwise == 0 then
        return string.format("m -%.1f -%.1f l %.1f -%.1f l %.1f %.1f l -%.1f %.1f ",a/2,a/2,a/2,a/2,a/2,a/2,a/2,a/2)
    elseif clockwise == 1 then
        return string.format("m -%.1f -%.1f l -%.1f %.1f l %.1f %.1f l %.1f -%.1f ",a/2,a/2,a/2,a/2,a/2,a/2,a/2,a/2)
    end
end

function rectangle(length,height,clockwise)--固定长宽矩形，可指定路径方向
    if clockwise == nil then
        clockwise = 0
    end
    local a = length
    local b = height
    if clockwise == 0 then
        return string.format("m -%.1f -%.1f l %.1f -%.1f l %.1f %.1f l -%.1f %.1f ",a/2,b/2,a/2,b/2,a/2,b/2,a/2,b/2)
    elseif clockwise == 1 then
        return string.format("m -%.1f -%.1f l -%.1f %.1f l %.1f %.1f l %.1f -%.1f ",a/2,b/2,a/2,b/2,a/2,b/2,a/2,b/2)
    end
end

function rhombus(length,height,clockwise)--固定长高菱形，可指定路径方向
    if clockwise == nil then
        clockwise = 0
    end
    local a = length
    local b = height
    if clockwise == 0 then
        return string.format("m %.1f %.1f l %.1f %.1f l %.1f %.1f l %.1f %.1f ",0,-b/2,a/2,0,0,b/2,-a/2,0)
    elseif clockwise == 1 then
        return string.format("m %.1f %.1f l %.1f %.1f l %.1f %.1f l %.1f %.1f ",0,-b/2,-a/2,0,0,b/2,a/2,0)
    end
end

function parallelogram(length,height,incline,directivity,clockwise)--固定长高平行四边形，可指定倾斜量、倾斜方向和路径方向
    if directivity == nil then
        directivity = 1
    end    
    if clockwise == nil then
        clockwise = 0
    end
    local a = length
    local b = height
    local c = incline
    if clockwise == 0 and directivity == 0 then
        return string.format("m %.1f %.1f l %.1f %.1f l %.1f %.1f l %.1f %.1f ",-a/2-c,-b/2,a/2-c,-b/2,a/2+c,b/2,-a/2+c,b/2)
    elseif clockwise == 0 and directivity == 1 then
        return string.format("m %.1f %.1f l %.1f %.1f l %.1f %.1f l %.1f %.1f ",-a/2+c,-b/2,a/2+c,-b/2,a/2-c,b/2,-a/2-c,b/2)
    elseif clockwise == 1 and directivity == 0 then
        return string.format("m %.1f %.1f l %.1f %.1f l %.1f %.1f l %.1f %.1f ",-a/2-c,-b/2,-a/2+c,b/2,a/2+c,b/2,a/2-c,-b/2)
    elseif clockwise == 1 and directivity == 1 then
        return string.format("m %.1f %.1f l %.1f %.1f l %.1f %.1f l %.1f %.1f ",-a/2+c,-b/2,-a/2-c,b/2,a/2-c,b/2,a/2+c,-b/2)
    end
end

function pentagram(length,clockwise,proportion)--五角星形，可指定路径方向和形状
    if clockwise == nil then
        clockwise = 0
    end
    if proportion == nil then
        proportion = math.sin(math.rad(18))/math.sin(math.rad(54))
    end
    if proportion <= 0 then
        proportion = 0.01
    end
    if proportion > math.sin(math.rad(54)) then
        proportion = math.sin(math.rad(54))
    end
    local a = length
    local b = a*proportion
    local c = b*math.cos(math.rad(54))
    local d = b*math.sin(math.rad(54))
    local e = a*math.cos(math.rad(18))
    local f = a*math.sin(math.rad(18))
    local g = b*math.cos(math.rad(18))
    local h = b*math.sin(math.rad(18))
    local i = a*math.cos(math.rad(54))
    local j = a*math.sin(math.rad(54))
    if clockwise == 0 then
        return string.format("m %.3f %.3f l %.3f %.3f l %.3f %.3f l %.3f %.3f l %.3f %.3f l %.3f %.3f l %.3f %.3f l %.3f %.3f l %.3f %.3f l %.3f %.3f l %.3f %.3f ",0,-a,c,-d,e,-f,g,h,i,j,0,b,-i,j,-g,h,-e,-f,-c,-d,0,-a)
    elseif clockwise == 1 then
        return string.format("m %.3f %.3f l %.3f %.3f l %.3f %.3f l %.3f %.3f l %.3f %.3f l %.3f %.3f l %.3f %.3f l %.3f %.3f l %.3f %.3f l %.3f %.3f l %.3f %.3f ",0,-a,-c,-d,-e,-f,-g,h,-i,j,0,b,i,j,g,h,e,-f,c,-d,0,-a)
    end
end

function regular_hexagon(length,clockwise)--固定边长正六边形，可指定路径方向
    if clockwise == nil then
        clockwise = 0
    end
    local a = length
    local b = a/2
    local c = a/2*3^0.5
    if clockwise == 0 then
        return string.format("m %.3f %.3f l %.3f %.3f l %.3f %.3f l %.3f %.3f l %.3f %.3f l %.3f %.3f ",-b,-c,b,-c,a,0,b,c,-b,c,-a,0)
    elseif clockwise == 1 then
        return string.format("m %.3f %.3f l %.3f %.3f l %.3f %.3f l %.3f %.3f l %.3f %.3f l %.3f %.3f ",-b,-c,-a,0,-b,c,b,c,a,0,b,-c)
    end
end

function note(x)--七个音符，可指定任意一个
    local shape_G_clef="m 3 -93 b -7 -93 -18 -68 -9 -38 b -24 -24 -41 -1 -37 14 b -32 44 -8 49 8 45 l 12 65 b 13 88 -10 89 -12 81 b -9 80 0 81 -3 67 b -6 57 -22 58 -23 74 b -20 96 17 94 15 67 l 11 44 b 20 38 29 30 27 12 b 24 4 14 -9 1 -6 l -3 -24 b 20 -41 18 -85 3 -93 m 6 -78 b 14 -77 9 -50 -6 -41 b -9 -58 -7 -78 6 -78 m 7 41 b -21 55 -51 10 -6 -21 l -2 -5 b -33 14 -8 36 -3 34 l -3 33 b -13 28 -16 12 0 7 m 10 40 l 2 7 b 21 4 27 31 10 40" 
    local shape_half_note="m -2 -85 l -2 51 b -11 44 -56 48 -51 85 b -48 106 -4 94 2 69 l 2 -85 m -46 86 b -50 72 -12 48 -4 56 b -2 75 -43 96 -46 86"
    local shape_quarter_note="m -2 -85 l -2 51 b -11 44 -56 48 -51 85 b -48 106 -4 94 2 69 l 2 -85 "
    local shape_eighth_note="m -2 -87 l -2 47 b -24 35 -53 56 -49 75 b -41 98 -4 83 2 61 l 2 -40 b 27 -38 55 -5 28 43 l 30 43 b 39 26 54 1 36 -30 b 24 -43 2 -60 2 -87 "
    local shape_two_eighth_notes="m -44 -60 l -44 43 b -54 35 -82 44 -81 65 b -72 85 -42 67 -41 52 l -41 -48 l 43 -63 l 43 28 b 30 20 5 31 6 50 b 13 67 43 54 46 38 l 46 -76 "
    local shape_sixteenth_note="m -2 -73 l -2 47 b -13 37 -48 50 -44 73 b -38 91 -2 83 2 58 l 2 -11 b 20 0 53 10 32 54 l 35 54 b 40 42 46 28 38 9 b 42 -3 42 -25 23 -41 b 13 -53 2 -57 2 -73 m 2 -44 b 17 -36 40 -21 36 5 b 25 -12 4 -19 2 -44 "
    local shape_two_sixteenth_notes="m -42 -53 l -42 50 b -52 42 -80 51 -79 72 b -70 92 -40 74 -39 59 l -39 -11 l 45 -26 l 45 34 b 29 27 8 38 8 55 b 16 73 45 61 48 45 l 48 -70 m -39 -24 l -39 -41 l 45 -56 l 45 -39 "
    if x == nil then
        x = 7
    end
    if x == 1 then
        return shape_G_clef
    elseif x == 2 then
        return shape_half_note
    elseif x == 3 then
        return shape_quarter_note
    elseif x == 4 then
        return shape_eighth_note
    elseif x == 5 then
        return shape_two_eighth_notes
    elseif x == 6 then
        return shape_sixteenth_note
    elseif x == 7 then
        return shape_two_sixteenth_notes
    end
end
