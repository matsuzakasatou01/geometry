# 有任何疑问先看README

这个仓库里存放的是用于Aegisub特效字幕制作的函数库、脚本，以及我写过的一部分模板。

## 函数库

图形库 `geometry` ，顾名思义就是“几何”。支持生成几何图形，还能对图形进行复杂的操作。从简单的矩形、菱形到复杂的数学公式、分子结构式，它都能绘制。在此基础上，它还额外提供了随机数类、颜色类等常用函数。

里面的函数大体上可以分为三类：

1. 功能型
2. 生成绘图型
3. 操作绘图型

**每个函数的用法在手册中均有详细说明。**

加载函数库的方法：

1. 把 `geometry.lua` 放进Aegisub中的 `\automation\include` 这个文件夹里，例如 `C:\Program Files (x86)\Aegisub-3.3.3-win64\automation\include` ；然后在同样是 `include` 这个文件夹里的 `utils-auto4.lua` 里加一句 `require('geometry')` 即可。
2. 如果你的Aeg是开启状态，在应用模板前，点击“自动化”→“自动化(A)…”→“重新扫描自动载入文件夹(S)”，重新加载函数库。

## 脚本

### 对所有行生效

- 遍历统计各类行数
- 逻辑统计各类行数
- 统计时间较短行
- 选中奇数行或偶数行
- 执行自动化并统计耗时
- 只留fx行
- 只留k值
- 只留歌词
- 重置karaoke行

### 对选中行生效

- 处理一行AI2ASS转出的字符串
- 勾选、取消注释
- 绘图坐标保留三位小数
- 绘图坐标取整
- 添加常用code行和template行
- 添加平均kf标签
- 选中相同样式行

这些脚本的使用方法都很简单，就不一一说明了。

*注：对选中行生效的脚本需要先选中需要选中的行。*

加载脚本的方法：

1. 把脚本放进Aegisub中的 `\automation\autoload` 这个文件夹里，例如 `C:\Program Files (x86)\Aegisub-3.3.3-win64\automation\autoload` 。
2. 如果你的Aeg是开启状态，在使用脚本前，点击点击“自动化”→“自动化(A)…”→“重新扫描自动载入文件夹(S)”，重新加载脚本。

**为你所使用的脚本配置快捷键能更加省时省力**。

配置快捷键的方法：

1. Alt+O，“界面”→“热键”→“新建”
2. 在最左边的 `Hotkey` 中选择你要使用的按键，中间的 `Command` 里写 `automation/lua/` ，然后选择脚本即可。

如果懒得配，你可以用 [我的快捷键配置](https://www.alipan.com/s/sbKkXdQmPVM) ~~配好脚本快捷键后你就可以光速连招爽玩Aeg~~

快捷键配置文件的路径为 `C:\Users\你的用户名\AppData\Roaming\Aegisub\hotkey.json`

配置完json后需要重启Aegisub配置才会生效。

**注意！！！如果你想用我的快捷键配置，在用我的json覆盖你的json之前一定要先备份自己的json！！！**

## 模板

分为 **砂糖酱の代表作** 和 **给组里做的特效** 。

如果还不会自动化，可以先看[我的B站教程](https://www.bilibili.com/video/BV1KmGTzmEp5?vd_source=6df8fb6687b936d34db1b244f6a15be5)

由于ass字幕文件不是代码，所以如果模板中未声明，均采用 **CC BY-NC-SA 4.0** 协议共享。

模板平均运行时间均使用“执行自动化并统计耗时”脚本计算得出。

### 砂糖酱の代表作

#### 1. 三つ葉の結びめ（来自风平浪静的明天NCED3）

**模板平均运行时间：0.015秒。**

这个模板不需要加载任何函数库，但是需要加载[mod滤镜](https://github.com/qwe7989199/aegisub_scripts/tree/master/VSFilterMod_bin)

加载mod滤镜的方法：

1. 把dll放进 `C:\Program Files (x86)\Aegisub-3.3.3-win64\csri` 这个文件夹中
2. Alt+O，“高级”→“视频”→“字幕来自”，选择 `CSRI/vsfiltermod_textsub`

把 `1.png` 直接放进D盘即可，如果想放别的地方就改一下模板里的路径。

#### 2. GRIDOUT（记忆缝线NCOP）

**模板平均运行时间：1.4秒。**

<u>*这个算是我自认为做得最好的作品*</u>

需要加载 `geometry` 函数库，加载方法不再赘述。

执行模板得出的随机效果以十万秒（1天3小时46分40秒）为周期。（为了解决行宽度相同的行上下句过渡时因跨秒产生随机数不同的问题而设定这个周期。）

如果你没有导入过os模块，就在 `os.time()` 前加个 `_G.`

这里面的逐帧用的是我自己添加的内联变量 `$fdur` ,你可以在 `C:\Program Files (x86)\Aegisub-3.3.3-win64\automation\autoload\kara-templater.lua` 中的 `varctx` 这个表中加一句

```lua
fdur = aegisub.ms_from_frame(101) and (aegisub.ms_from_frame(101) - aegisub.ms_from_frame(1))/100 or 1001/24
```

如果你不想加的话，就把所有 `$fdur` 都显式地替换为 `(1001/24)` ,这是帧率为23.976时一帧的持续时间。

#### 3. 鏡面の波（宝石之国NCOP）

**模板平均运行时间：7秒。**

需要加载 `geometry` 、[Yutils](https://github.com/Youka/Yutils/blob/T1/src/Yutils.lua) 还有多华宫前辈的 [3D库-space](https://github.com/WitchCraftWorks66/StupidAss/blob/main/3D%E7%9B%B8%E5%85%B3/%E5%87%BD%E6%95%B0%E5%BA%93/b%E7%AB%99BV1zK4y1Q76i/space.lua) 和 [多边形库-polyc](https://github.com/WitchCraftWorks66/StupidAss/blob/main/%E5%A4%9A%E8%BE%B9%E5%BD%A2%E5%BA%93/ployc%E4%BC%98%E5%8C%96%E6%9B%B4%E6%96%B0%E7%89%88/polyc.lua)

`$fdur` 的处理方法同上。

`gloop` 这个函数也是多华宫前辈写的

```lua
tenv.gloop =
	function(differ_loop,rand_num)
		local cnt = {0}
		if type(differ_loop) == "number" then
			if tenv.j == 1 then
				tenv.maxloop(differ_loop)
				tenv.num = {}
				tenv.gi = 1
				tenv.gn = 1
				tenv.gin = differ_loop
			end
			tenv.gii = tenv.j
		elseif type(differ_loop[1]) == "table" then
			if tenv.j == 1 then
				tenv.gn = differ_loop[1][1]
            	tenv.gin = differ_loop[1][2]
				tenv.num = {} tenv.maxloop(tenv.gn*tenv.gin)
			end
			tenv.gi = math.ceil(tenv.j/tenv.gin)
			tenv.gii = tenv.j % tenv.gin == 0 and tenv.gin or tenv.j % tenv.gin
		else
			for i = 1,#differ_loop do
				cnt[i + 1] = cnt[i] + differ_loop[i]
			end
			if tenv.j == 1 then
				tenv.maxloop(cnt[#cnt])
				tenv.num = {}
            	tenv.gn = #cnt - 1
			end
			for i=2,#cnt do
				tenv.gi = i - 1
            	tenv.gin = cnt[i] - cnt[i - 1]
				tenv.gii = tenv.j - cnt[i - 1]
				if tenv.j <= cnt[i] then
					break
				end
			end
		end
		if type(rand_num) == "table" and tenv.gii == 1 then
			tenv.num[tenv.gi] = {}
			for i=1,#rand_num do
				tenv.num[tenv.gi][rand_num[i][1]] = math.random(rand_num[i][2],rand_num[i][3])
			end
		end
		return ""
	end
```

它是一个分组循环的函数，具体用法可以看[多华宫前辈的教程](https://www.bilibili.com/video/BV1mv411i7Rm?vd_source=6df8fb6687b936d34db1b244f6a15be5)

把它加在 `C:\Program Files (x86)\Aegisub-3.3.3-win64\automation\autoload\kara-templater.lua` 中的 `apply_templates` 这个函数的 `tenv.maxloop` 后面即可。

如果不想加，可以在code行中定义它，也可以用[我的Aeg](https://www.alipan.com/s/sbKkXdQmPVM)

## 杂项

### 为什么别的大佬的模板拿到手之后跑不通？

常见原因无非就两个：

1. 缺函数（没加载函数库、需要自己写的函数没写等）
2. 缺变量（比如上面的 `$fdur` ）

**缺啥补啥**就行。

拿到别人的模板后，最好揣测一下作者的意图。这里为什么这样写？这一行是干什么用的？跑不通是为什么？缺了什么？函数库有没有手册？函数什么用法？参数怎么填？想明白这些之后对模板进行简单的修改就不成问题了。不过还是推荐新手自己写模板。[给新手的一些建议](https://b23.tv/rHzWKXE)  [特效制作流程](https://b23.tv/It4v3Z0)

### 什么样的模板才是好的？

简洁的、运行速度快的、成品体积小的。

比如常用的函数可以放进自己的函数库里，这样就不用在code行里定义，模板看上去就简洁了；如果日文和中文的模板一样就用all修饰语等等。[简化模板的技巧](https://b23.tv/mIyhsHb)

至于运行速度，则可以优化函数、优化模板。用更快、更简单的方法实现相同的效果；去掉多余的操作等等。





**松坂さとう**

**2025.08.09**

