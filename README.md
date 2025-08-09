# 有任何疑问先看README

这个仓库里有函数库、脚本和模板。  

函数库均为英文命名，脚本均为中文命名，以后如有新函数库和脚本也将沿用此命名方式。  

## 函数库

目前只有`geometry`一个函数库。每个函数的用法在手册中均有详细说明。  

加载函数库的方法：

1. 把`geometry.lua`放进Aegisub中的`\automation\include`这个文件夹里，例如`C:\Program Files (x86)\Aegisub-3.3.3-win64\automation\include`；然后在同样是`include`这个文件夹里的`utils-auto4.lua`里加一句`require('geometry')`即可。
2. 如果你的Aeg是开启状态，在应用模板前，点击`自动化`→`自动化(A)…`→`重新扫描自动载入文件夹(S)`，重新加载函数库。  

## 脚本

脚本的使用方法可以查看我的这两篇专栏  [专栏一](https://b23.tv/ITY6Ylx)  [专栏二](https://b23.tv/D5qhCk8)。  

加载脚本的方法：

1. 把脚本放进Aegisub中的`\automation\autoload`这个文件夹里，例如`C:\Program Files (x86)\Aegisub-3.3.3-win64\automation\autoload`。
2. 如果你的Aeg是开启状态，在使用脚本前，点击`自动化`→`自动化(A)…`→`重新扫描自动载入文件夹(S)`，重新加载脚本。  

**为你所使用的脚本配置快捷键能更加省时省力**。  

配置快捷键的方法：  

1. Alt+O，`界面`→`热键`→`新建`
2. 在最左边的Hotkey中选择你要使用的按键，中间的Command里写`automation/lua/`，然后选择脚本即可。  

如果懒得配，你可以用我的快捷键配置  [阿里云盘链接](https://www.alipan.com/s/sbKkXdQmPVM)  ~~配好脚本快捷键后你就可以光速连招爽玩Aeg~~  

快捷键配置文件的路径为`C:\Users\你的用户名\AppData\Roaming\Aegisub\hotkey.json`

**注意！！！如果你想用我的快捷键配置，在用我的json覆盖你的json之前一定要备份自己的json！！！**

## 模板

如果还不会自动化，可以先看[我的B站教程](https://www.bilibili.com/video/BV1KmGTzmEp5?vd_source=6df8fb6687b936d34db1b244f6a15be5)  

这些模板均没有留fx行（因为实在是太多了）  

### 1. 三つ葉の結びめ（来自风平浪静的明天NCED3）

这个模板不需要加载任何函数库，但是需要加载[mod滤镜](https://github.com/qwe7989199/aegisub_scripts/tree/master/VSFilterMod_bin)  

加载mod滤镜的方法：

1. 把dll放进`C:\Program Files (x86)\Aegisub-3.3.3-win64\csri`这个文件夹中
2. Alt+O，`高级`→`视频`→`字幕来自`，选择`CSRI/vsfiltermod_textsub`  

把`1.png`直接放进D盘即可，如果想放别的地方就改一下模板里的路径。  

### 2. GRIDOUT（记忆缝线NCOP）  

*这个算是我最得意的作品*

需要加载`geometry`函数库，加载方法不再赘述。

这里面的逐帧用的是我自己添加的内联变量`$fdur`,你可以在`C:\Program Files (x86)\Aegisub-3.3.3-win64\automation\autoload\kara-templater.lua`中的`varctx`这个表中加一句  

```lua
fdur = aegisub.ms_from_frame(101) and (aegisub.ms_from_frame(101) - aegisub.ms_from_frame(1))/100 or 1001/24
```

如果你不想加的话，就把所有`$fdur`都显式地替换为`(1001/24)`,这是帧率为23.976时一帧的持续时间。  

如果应用出来的效果有所不同，可能是样式的原因，可以根据手册修改模板中`tessellation`这个函数的参数。

### 3. 鏡面の波（宝石之国NCOP）

需要加载`geometry`、还有多华宫前辈的[3D库-space](https://github.com/WitchCraftWorks66/StupidAss/blob/main/3D%E7%9B%B8%E5%85%B3/%E5%87%BD%E6%95%B0%E5%BA%93/b%E7%AB%99BV1zK4y1Q76i/space.lua)和[多边形库-polyc](https://github.com/WitchCraftWorks66/StupidAss/blob/main/%E5%A4%9A%E8%BE%B9%E5%BD%A2%E5%BA%93/ployc%E4%BC%98%E5%8C%96%E6%9B%B4%E6%96%B0%E7%89%88/polyc.lua)。  

`$fdur`的处理方法同上。

`gloop`这个函数也是多华宫前辈写的

```lua
tenv.gloop =
	function(differ_loop,rand_num)
		local cnt={0}
		if type(differ_loop)=="number" then
			if tenv.j==1 then
				tenv.maxloop(differ_loop)
				tenv.num={}
				tenv.gi=1
				tenv.gn=1
				tenv.gin=differ_loop
			end
			tenv.gii=tenv.j
		elseif type(differ_loop[1])=="table" then
			if tenv.j==1 then
				tenv.gn=differ_loop[1][1] tenv.gin=differ_loop[1][2]
				tenv.num={} tenv.maxloop(tenv.gn*tenv.gin)
			end
			tenv.gi=math.ceil(tenv.j/tenv.gin)
			tenv.gii=tenv.j%tenv.gin==0 and tenv.gin or tenv.j%tenv.gin
		else
			for i=1,#differ_loop do
				cnt[i+1]=cnt[i]+differ_loop[i]
			end
			if tenv.j==1 then
				tenv.maxloop(cnt[#cnt])
				tenv.num={} tenv.gn=#cnt-1
			end
			for i=2,#cnt do
				tenv.gi=i-1 tenv.gin=cnt[i]-cnt[i-1]
				tenv.gii=tenv.j-cnt[i-1]
				if tenv.j<=cnt[i] then
					break
				end
			end
		end
		if type(rand_num)=="table" and tenv.gii==1 then
			tenv.num[tenv.gi]={}
			for i=1,#rand_num do
				tenv.num[tenv.gi][rand_num[i][1]]=math.random(rand_num[i][2],rand_num[i][3])
			end
		end
		return ""
	end
```

它是一个分组循环的函数，具体用法可以看[多华宫前辈的教程](https://www.bilibili.com/video/BV1mv411i7Rm?vd_source=6df8fb6687b936d34db1b244f6a15be5)

把它加在`C:\Program Files (x86)\Aegisub-3.3.3-win64\automation\autoload\kara-templater.lua`中的`apply_templates`这个函数的`tenv.maxloop`后面即可。

如果不想加，可以在code行中定义它，也可以用[我的Aeg](https://www.alipan.com/s/sbKkXdQmPVM)

### 4. 为什么别的大佬的模板拿到手之后跑不通？

常见原因无非就两个：

1. 缺函数（没加载函数库、需要自己写的函数没写等）
2. 缺变量（比如上面的`$fdur`）

**缺啥补啥**就行。

拿到别人的模板后的第一件事就是揣测作者的意图。这里为什么这样写？这一行是干什么用的？跑不通是为什么？缺了什么？函数库有没有手册？函数什么用法？参数怎么填？想明白这些之后对模板进行简单的修改就不成问题了。  

### 5. 什么样的模板才是好的？

简洁的、运行速度快的。

比如常用的函数可以放进自己的函数库里，这样就不用在code行里定义，模板看上去就简洁了；如果日文和中文的模板一样就用`all`修饰语等等。[简化模板的技巧](https://b23.tv/mIyhsHb)

至于运行速度，则可以优化函数、优化模板。用更快、更简单的方法实现相同的效果；去掉多余的操作等等。  





**松坂さとう**

**2025.08.09**

