local get = aegisub.gettext

script_name = get "添加常用code行和template行"
script_description = get "添加常用code行和template行"
script_author = "松坂さとう"
script_version = "1.0"

function insert_s1(subs,sel)
    for i = 1,#sel do
        local line = subs[sel[i]]
        line.comment = true
        line.effect = "code once"
        line.text = ""
        line.start_time = 0
        line.end_time = 0
        subs[-i] = line
    end
end

function insert_s2(subs,sel)
    for i = 1,#sel do
        local line = subs[sel[i]]
        line.comment = true
        line.effect = "code syl noblank"
        line.text = ""
        line.start_time = 0
        line.end_time = 0
        subs[-i] = line
    end
end

function insert_s3(subs,sel)
    for i = 1,#sel do
        local line = subs[sel[i]]
        line.comment = true
        line.effect = "code line"
        line.text = ""
        line.start_time = 0
        line.end_time = 0
        subs[-i] = line
    end
end

function insert_l1(subs,sel)
    for i = 1,#sel do
        local line = subs[sel[i]]
        line.comment = true
        line.effect = "template syl noblank"
        line.text = ""
        line.start_time = 0
        line.end_time = 0
        subs[-i] = line
    end
end

function insert_l2(subs,sel)
    for i = 1,#sel do
        local line = subs[sel[i]]
        line.comment = true
        line.effect = "template syl noblank notext"
        line.text = ""
        line.start_time = 0
        line.end_time = 0
        subs[-i] = line
    end
end

function insert_l3(subs,sel)
    for i = 1,#sel do
        local line = subs[sel[i]]
        line.comment = true
        line.effect = "template line"
        line.text = ""
        line.start_time = 0
        line.end_time = 0
        subs[-i] = line
    end
end

function insert_l4(subs,sel)
    for i = 1,#sel do
        local line = subs[sel[i]]
        line.comment = true
        line.effect = "template line notext"
        line.text = ""
        line.start_time = 0
        line.end_time = 0
        subs[-i] = line
    end
end

function Auto(subs,sel)
    for i = 1,#sel do
        local line = subs[sel[i]]
        line.comment = true
        line.effect = "code once"
        line.text = 'function AutoTags(Intervalo,Dato1,Dato2) local RESULTADO="" local SUERTE = 0 local CONTADOR = 0 local ARREGLO = 0 local count = math.ceil(line.duration/Intervalo) ARREGLO = {Dato1,Dato2} for i = 1, count do CONTADOR = i if Dato1 and Dato2 then if CONTADOR%2 ==0 then SUERTE = ARREGLO[1] else SUERTE = ARREGLO[2] end end RESULTADO = RESULTADO .."\\\\t(" ..(i-1)*Intervalo.. "," ..i*Intervalo.. ",\\\\" ..SUERTE..")".."" end return RESULTADO end'
        line.start_time = 0
        line.end_time = 0
        subs[-i] = line
    end
end

function Auto1(subs,sel)
    for i = 1,#sel do
        local line = subs[sel[i]]
        line.comment = true
        line.effect = "code once"
        line.text = 'function AutoTags1(Intervalo,Dato1,Dato2,Pause) local RESULTADO="" local SUERTE = 0 local CONTADOR = 0 local ARREGLO = 0 local count = math.ceil(line.duration/(Intervalo+Pause)) ARREGLO = {Dato1,Dato2} for i = 1, count do CONTADOR = i if Dato1 and Dato2 then if CONTADOR%2 ==0 then SUERTE = ARREGLO[1] else SUERTE = ARREGLO[2] end end RESULTADO = RESULTADO .."\\\\t(" ..(i-1)*(Intervalo+Pause).. "," ..i*Intervalo+Pause*(i-1).. ",\\\\" ..SUERTE..")".."" end return RESULTADO end'
        line.start_time = 0
        line.end_time = 0
        subs[-i] = line
    end
end

function Auto2(subs,sel)
    for i = 1,#sel do
        local line = subs[sel[i]]
        line.comment = true
        line.effect = "code once"
        line.text = 'function AutoTags2(Intervalo,Dato1,Dato2,Delay) local RESULTADO="" local SUERTE = 0 local CONTADOR = 0 local ARREGLO = Layer local count = math.ceil(line.duration/Intervalo) ARREGLO = {Dato1,Dato2} for i = 1, count do CONTADOR = i if Dato1 and Dato2 then if CONTADOR%2 ==0 then SUERTE = ARREGLO[1] else SUERTE = ARREGLO[2] end end RESULTADO = RESULTADO .."\\\\t(" ..(i-1)*Intervalo+Delay.. "," ..i*Intervalo+Delay.. ",\\\\" ..SUERTE.. ")".."" end return RESULTADO end'
        line.start_time = 0
        line.end_time = 0
        subs[-i] = line
    end
end

function Auto3(subs,sel)
    for i = 1,#sel do
        local line = subs[sel[i]]
        line.comment = true
        line.effect = "code once"
        line.text = 'function AutoTags3(Intervalo1,Intervalo2,Dato1,Dato2) local RESULTADO="" local SUERTE = 0 local CONTADOR = 0 local ARREGLO = 0 local count = 2*math.ceil(line.duration/(Intervalo1+Intervalo2)) local d=math.ceil((Intervalo2-Intervalo1)/count) local t={} ARREGLO = {Dato1,Dato2} for i = 1, count do CONTADOR = i t[1]=0 t[i+1]=t[i]+Intervalo1+(i-1)*d if Dato1 and Dato2 then if CONTADOR%2 ==0 then SUERTE = ARREGLO[1] else SUERTE = ARREGLO[2] end end RESULTADO = RESULTADO .."\\\\t(" ..t[i].. "," ..t[i+1].. ",\\\\" ..SUERTE..")".."" end return RESULTADO end'
        line.start_time = 0
        line.end_time = 0
        subs[-i] = line
    end
end

function fxgroup(subs,sel)
    for i = 1,#sel do
        local line = subs[sel[i]]
        line.comment = true
        line.effect = "code line"
        line.text = 'fxgroup.one=(line.actor=="1") fxgroup.two=(line.actor=="2") fxgroup.three=(line.actor=="3") fxgroup.four=(line.actor=="4") fxgroup.five=(line.actor=="5") fxgroup.six=(line.actor=="6") fxgroup.seven=(line.actor=="7") fxgroup.eight=(line.actor=="8") fxgroup.nine=(line.actor=="9") fxgroup.ten=(line.actor=="10") fxgroup.eleven=(line.actor=="11") fxgroup.twelve=(line.actor=="12") fxgroup.thirteen=(line.actor=="13") fxgroup.fourteen=(line.actor=="14") fxgroup.fifteen=(line.actor=="15") fxgroup.sixteen=(line.actor=="16") fxgroup.seventeen=(line.actor=="17") fxgroup.eighteen=(line.actor=="18") fxgroup.nineteen=(line.actor=="19") fxgroup.twenty=(line.actor=="20")'
        line.start_time = 0
        line.end_time = 0
        subs[-i] = line
    end
end

aegisub.register_macro(script_name.."/code once",script_description,insert_s1)
aegisub.register_macro(script_name.."/code syl noblank",script_description,insert_s2)
aegisub.register_macro(script_name.."/code line",script_description,insert_s3)
aegisub.register_macro(script_name.."/template syl noblank",script_description,insert_l1)
aegisub.register_macro(script_name.."/template syl noblank notext",script_description,insert_l2)
aegisub.register_macro(script_name.."/template line",script_description,insert_l3)
aegisub.register_macro(script_name.."/template line notext",script_description,insert_l4)
aegisub.register_macro(script_name.."/AutoTags系列/AutoTags",script_description,Auto)
aegisub.register_macro(script_name.."/AutoTags系列/AutoTags1",script_description,Auto1)
aegisub.register_macro(script_name.."/AutoTags系列/AutoTags2",script_description,Auto2)
aegisub.register_macro(script_name.."/AutoTags系列/AutoTags3",script_description,Auto3)
aegisub.register_macro(script_name.."/fxgroup",script_description,fxgroup)